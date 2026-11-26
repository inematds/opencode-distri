#!/usr/bin/env bash
# Testes do opencode-distri que NÃO chamam modelo nenhum (nem assinatura, nem API, nem GPU).
#   testes/rodar.sh            tudo (inclui instalar num HOME descartável no modo --vps)
# Saída esperada: "N ok, 0 falhas" e código 0.
set -uo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
OCD="$RAIZ/bin/ocd"
ok=0; falha=0
t() { local nome="$1"; shift; if "$@" >/tmp/ocd-teste.out 2>&1; then ok=$((ok+1)); echo "✔ $nome"; else falha=$((falha+1)); echo "✘ $nome"; sed 's/^/    /' /tmp/ocd-teste.out | head -8; fi; }
nao() { ! "$@"; }

jsonc_ok() { python3 - "$1" <<'EOF'
import json,re,sys
s=open(sys.argv[1]).read()
s=re.sub(r'^\s*//.*$','',s,flags=re.M)
s=re.sub(r',(\s*[}\]])',r'\1',s)
json.loads(s)
EOF
}

# 1. sintaxe
t "bash -n bin/ocd"            bash -n "$OCD"
t "bash -n instalar/linux.sh"  bash -n "$RAIZ/instalar/linux.sh"
t "bash -n instalar/remoto.sh" bash -n "$RAIZ/instalar/remoto.sh"

# 2. modelo de config é JSONC válido nas duas variantes
TMP="$(mktemp -d)"
sed 's#__OLLAMA_URL__#http://127.0.0.1:11434/v1#' "$RAIZ/config/opencode.jsonc.modelo" > "$TMP/com.jsonc"
grep -v '"ollama"' "$RAIZ/config/opencode.jsonc.modelo" > "$TMP/sem.jsonc"
t "config com Ollama é JSONC válido" jsonc_ok "$TMP/com.jsonc"
t "config sem Ollama é JSONC válido" jsonc_ok "$TMP/sem.jsonc"
t "config bloqueia * e libera só 3"  bash -c "grep -c '\"effect\": \"allow\"' '$TMP/com.jsonc' | grep -qx 3 && grep -q '\"resource\": \"\\*\", \"effect\": \"deny\"' '$TMP/com.jsonc'"
t "config não tem chave escrita"     nao grep -qiE 'sk-or-|sk-[a-z0-9]{20}' "$RAIZ/config/opencode.jsonc.modelo"

# 3. perfis e travas (sem rede)
export OCD_CONF=/dev/null OCD_TRAVAS=1
unset OCD_APROVADO_OPENROUTER APROVADO_MODELO_NEI OPENROUTER_API_KEY
t "perfis lista os 3"                 bash -c "'$OCD' perfis | grep -c -E '^(assinatura +openai/|openrouter +openrouter/|local +ollama/)' | grep -qx 3"
t "openrouter recusa sem aprovação"   bash -c "! echo oi | '$OCD' run -p openrouter 2>/dev/null"
t "openrouter: mensagem certa"        bash -c "echo oi | '$OCD' run -p openrouter 2>&1 | grep -q OCD_APROVADO_OPENROUTER"
t "local recusa sem aprovação"        bash -c "echo oi | '$OCD' run -p local 2>&1 | grep -q APROVADO_MODELO_NEI"
t "perfil inválido recusa"            bash -c "! '$OCD' run -p xyz oi 2>/dev/null"
t "prompt vazio recusa"               bash -c "! '$OCD' run -p assinatura </dev/null 2>/dev/null"
t "modelo vem do nível (MENOR)"       bash -c "OCD_NIVEL=MENOR INEMA_CODEX_MENOR=teste-menor OCD_MODELOS_ENV=/dev/null '$OCD' perfis | grep -q 'openai/teste-menor'"
t "OCD_MODELO_ fixo vence o nível"    bash -c "OCD_MODELO_LOCAL=x:1 '$OCD' perfis | grep -q 'ollama/x:1'"

# 4. instalação --vps num HOME descartável (usa o opencode já instalado; sem login, sem modelo)
if command -v opencode >/dev/null; then
  H="$TMP/home-vps"; mkdir -p "$H"
  t "linux.sh --vps instala em HOME limpo" env -u XDG_CONFIG_HOME HOME="$H" PATH="$PATH" OCD_MODELOS_ENV=/dev/null bash "$RAIZ/instalar/linux.sh" --vps
  t "VPS: config sem Ollama"            nao grep -q ollama "$H/.config/opencode/opencode.jsonc"
  t "VPS: só openai/openrouter na lista (sem free, sem ollama)" bash -c "cd /tmp && ! HOME='$H' opencode --standalone models 2>/dev/null | grep -qvE '^(openai|openrouter)/'"
  t "VPS: ocd.env com perfil local vazio" grep -qx 'OCD_PADRAO_LOCAL=' "$H/.config/opencode-distri/ocd.env"
fi

# 5. instalação real desta máquina (se já feita)
if [[ -f "$HOME/.config/opencode/opencode.jsonc" ]] && grep -qs provider.use "$HOME/.config/opencode/opencode.jsonc"; then
  t "aqui: doctor passa"                env -u OCD_CONF "$OCD" doctor
  t "aqui: cwd qualquer não vê opencode/*-free" bash -c "cd / && ! opencode --standalone models 2>/dev/null | grep -q '^opencode/'"
fi

rm -rf "$TMP"
echo "$ok ok, $falha falhas"
[[ $falha == 0 ]]
