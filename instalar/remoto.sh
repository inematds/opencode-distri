#!/usr/bin/env bash
# Instala o opencode-distri numa VPS pelo SSH: copia o repo e roda instalar/linux.sh --vps lá.
#   instalar/remoto.sh root@<IP> [-i ~/.ssh/<chave>] [-- --ollama URL | --sem-travas]
# Não leva login nem chave: o login da assinatura é feito lá, à mão (ssh -t ... opencode auth login openai).
set -euo pipefail
[[ $# -ge 1 ]] || { sed -n '2,4p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
ALVO="$1"; shift
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=15)
if [[ "${1:-}" == "-i" ]]; then SSH+=(-i "$2"); shift 2; fi
[[ "${1:-}" == "--" ]] && shift
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"

"${SSH[@]}" "$ALVO" 'command -v node >/dev/null || echo "aviso: sem node lá; vai pelo instalador oficial"; mkdir -p ~/opencode-distri'
tar -C "$RAIZ" --exclude=.git -czf - . | "${SSH[@]}" "$ALVO" 'tar -C ~/opencode-distri -xzf -'
"${SSH[@]}" "$ALVO" "bash ~/opencode-distri/instalar/linux.sh --vps $*"
