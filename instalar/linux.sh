#!/usr/bin/env bash
# Instala o opencode-distri num Linux (máquina local ou VPS).
#   instalar/linux.sh                 máquina com Ollama local (127.0.0.1:11434)
#   instalar/linux.sh --vps           VPS sem GPU: perfil local desligado
#   instalar/linux.sh --ollama URL    Ollama em outro lugar (ex.: http://<IP-tailscale>:11434/v1)
#   instalar/linux.sh --sem-travas    DESLIGA as travas de aprovação (não recomendado; a trava vale em qualquer máquina)
# Não faz login nem chama modelo. Repetir é seguro (idempotente).
set -euo pipefail

VERSAO_OPENCODE="${VERSAO_OPENCODE:-2.4.2}"
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
OLLAMA_URL="http://127.0.0.1:11434/v1"
VPS=0; TRAVAS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vps) VPS=1; shift ;;
    --ollama) OLLAMA_URL="$2"; shift 2 ;;
    --sem-travas) TRAVAS=0; shift ;;
    -h|--help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $1" >&2; exit 2 ;;
  esac
done
SEM_OLLAMA=0
[[ $VPS == 1 && "$OLLAMA_URL" == "http://127.0.0.1:11434/v1" ]] && SEM_OLLAMA=1

passo() { echo "▶ $*"; }

# 1. CLI do opencode, versão fixa
atual="$(command -v opencode >/dev/null && opencode --version 2>/dev/null | sed 's/^opencode v//' || true)"
if [[ "$atual" == "$VERSAO_OPENCODE" ]]; then
  passo "opencode $atual já instalado"
elif command -v npm >/dev/null; then
  passo "instalando @opencode/cli@$VERSAO_OPENCODE pelo npm"
  npm install -g "@opencode/cli@$VERSAO_OPENCODE" >/dev/null
else
  passo "sem npm: usando o instalador oficial (última versão)"
  tmp="$(mktemp)"; curl -fsSL --max-time 300 https://opencode.ai/v2/install -o "$tmp"; bash "$tmp"; rm -f "$tmp"
  export PATH="$HOME/.opencode/bin:$PATH"
fi
OC="$(command -v opencode)"; passo "opencode: $OC ($("$OC" --version))"

# 2. Sem servidor compartilhado: cada job roda no próprio cwd/env/teto de memória (--standalone)
"$OC" service set disabled true >/dev/null 2>&1 || true

# 3. Config global com trava de provedores
CFG="$("$OC" debug paths config)"; mkdir -p "$CFG"
for f in "$CFG/opencode.json" "$CFG/opencode.jsonc"; do
  [[ -f "$f" ]] && ! grep -qs 'opencode-distri' "$f" && cp "$f" "$f.bak-$(date +%Y%m%d-%H%M%S)" && passo "backup de $f"
done
rm -f "$CFG/opencode.json"
if [[ $SEM_OLLAMA == 1 ]]; then
  # VPS sem GPU e sem Ollama indicado: o provedor ollama fica bloqueado
  grep -v '"ollama"' "$RAIZ/config/opencode.jsonc.modelo" > "$CFG/opencode.jsonc"
  passo "config: $CFG/opencode.jsonc (sem Ollama)"
else
  sed "s#__OLLAMA_URL__#$OLLAMA_URL#" "$RAIZ/config/opencode.jsonc.modelo" > "$CFG/opencode.jsonc"
  passo "config: $CFG/opencode.jsonc (ollama = $OLLAMA_URL)"
fi

# 4. ocd no PATH + preferências
mkdir -p "$HOME/.local/bin" "$HOME/.config/opencode-distri"
ln -sf "$RAIZ/bin/ocd" "$HOME/.local/bin/ocd"
PREF="$HOME/.config/opencode-distri/ocd.env"
if [[ ! -f "$PREF" ]]; then
  {
    echo "# preferências do ocd (opencode-distri). Gerado em $(date +%F)."
    echo "OCD_TRAVAS=$TRAVAS"
    echo "OCD_PERFIL=assinatura"
    echo "OCD_NIVEL=TOPO"
    echo "# Modelo de cada perfil: 1º OCD_MODELO_<PERFIL> (fixo), 2º ~/.config/inema/modelos.env"
    echo "# (INEMA_CODEX|OPENROUTER|OLLAMA_<NIVEL>), 3º estes padrões:"
    echo "OCD_PADRAO_ASSINATURA=gpt-6.2-sol"
    echo "OCD_PADRAO_OPENROUTER=anthropic/claude-sonnet-5.5"
    [[ $SEM_OLLAMA == 1 ]] && echo "OCD_PADRAO_LOCAL=" || echo "OCD_PADRAO_LOCAL=qwen3.8:27b"
    echo "# Onde procurar OPENROUTER_API_KEY (lida só no processo filho), separado por ':'"
    echo "# OCD_ENV_FILES=/caminho/um/.env:/caminho/outro/.env"
  } > "$PREF"
  passo "preferências: $PREF"
fi
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "⚠ coloque ~/.local/bin no PATH";; esac

# 5. Conferência
"$RAIZ/bin/ocd" doctor || { echo "✘ doctor reprovou"; exit 1; }
echo
echo "Falta só o login da assinatura (interativo): opencode auth login openai"
