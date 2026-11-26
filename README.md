# opencode-distri

Instala o [opencode](https://opencode.ai) (CLI de agente aberta, 2.x) do mesmo jeito em qualquer lugar — esta máquina, um Windows, uma VPS — e deixa ele pronto para virar motor no inemaccbot, openpcbotv3, exb (enginebridge) e intelecto.

Três caminhos de modelo, e só eles:

| Perfil | De onde vem o modelo | Modelo padrão (nível TOPO) | Trava |
|---|---|---|---|
| `assinatura` | login ChatGPT Plus/Pro no opencode (`opencode auth login openai`) | `openai/gpt-6.2-sol` (`INEMA_CODEX_*`) | — |
| `openrouter` | chave `OPENROUTER_API_KEY` do `.env`, carregada só no processo filho | `openrouter/anthropic/claude-opus-5.5` (`INEMA_OPENROUTER_*`) | `OCD_APROVADO_OPENROUTER` |
| `local` | Ollama (`127.0.0.1:11434` ou outro) | `ollama/qwen3.8:27b` (`INEMA_OLLAMA_*`) | `APROVADO_MODELO_NEI` |

- **Assinatura Claude não existe no opencode 2.x**: o provedor `anthropic` só aceita chave de API (conferido em 26/11/2026). Para Claude pela assinatura, o motor continua sendo o `claude` CLI.
- Todo outro provedor fica bloqueado por `policies` na config global — inclusive os modelos `opencode/*-free`, que são API do próprio opencode.
- O agente não lê `*.env` nem arquivos de credencial.
- O servidor compartilhado do opencode fica desligado: cada execução usa `--standalone`, com o cwd, o ambiente e o teto de memória de quem chamou.

## O processo, do início ao fim

1. ⚙️ **Instalar** — escolha o lugar:
   - esta máquina / Linux com Ollama: `instalar/linux.sh`
   - VPS sem GPU, daqui: `instalar/remoto.sh root@<IP> [-i ~/.ssh/<chave>]` (copia o repo e roda `linux.sh --vps` lá)
   - VPS usando o Ollama desta máquina pela Tailscale: `instalar/remoto.sh root@<IP> -- --ollama http://<IP-tailscale-da-maquina-com-GPU>:11434/v1`
   - Windows: `powershell -ExecutionPolicy Bypass -File instalar\windows.ps1 [-SemOllama] [-OllamaUrl URL]` (**ainda não testado em Windows real**)
   - máquina de outra pessoa: acrescente `--sem-travas` / `-SemTravas`
2. 🧠 **Login da assinatura** (interativo, uma vez por máquina): `opencode auth login openai` → "Sign in with ChatGPT". Na VPS: `ssh -t root@<IP> opencode auth login openai`. Nunca copiar credencial de uma máquina para outra (`auth export`).
3. ⚙️ **Conferir**: `ocd doctor` (versão, config com trava, servidor compartilhado desligado, logins, modelos `opencode/*` bloqueados, modelo de cada perfil).
4. ⚙️ **Usar sem tela**: `ocd run [-p assinatura|openrouter|local] [--auto] [--json] "pedido"` ou `echo "pedido" | ocd run`. Interativo: `opencode` (TUI) ou `opencode mini`.
5. 🧠 **Liberar um perfil pago/pesado** (só com OK do Nei, citado): `OCD_APROVADO_OPENROUTER="<o que foi aprovado>" ocd run -p openrouter …` · `APROVADO_MODELO_NEI="<modelo e finalidade>" ocd run -p local …` (nesta máquina o perfil local entra pela `fila-vaga gpu`).
6. 🤖 **Motor nos sistemas**: ver [integracoes/README.md](integracoes/README.md) — estado de cada sistema e o teste de fumaça que vem antes.
7. ⚙️ **Testar o kit** (sem chamar modelo): `testes/rodar.sh` → `N ok, 0 falhas`.
8. ⚙️ **Atualizar o opencode**: trocar `VERSAO_OPENCODE` em `instalar/linux.sh` (e `-Versao` no `windows.ps1`), rodar `testes/rodar.sh` e reinstalar.

## Provedores sem censura

Quais modelos sem censura cabem nos perfis `local` e `openrouter`, e o que fica de fora (Venice, abliteration.ai): [docs/PROVEDORES-SEM-CENSURA.md](docs/PROVEDORES-SEM-CENSURA.md). Matéria base: [Provedores de IA sem censura](https://inematds.github.io/provedores-semcensura/guia/).

## O que falta

[PENDENCIAS.md](PENDENCIAS.md): testes (pausados até o Nei liberar), runners do inemaccbot, openpcbotv3 e exb, perfis Venice e abliteration.ai.

## Modelos

A ordem é: `OCD_MODELO_<PERFIL>` (fixo) → `~/.config/inema/modelos.env` no nível `OCD_NIVEL` (`SUPER|TOPO|EXECUTOR|MENOR`) → `OCD_PADRAO_<PERFIL>` em `~/.config/opencode-distri/ocd.env`. Trocar o modelo de todos os sistemas continua sendo só no `modelos.env`.

## Arquivos

| Caminho | O que é |
|---|---|
| `config/opencode.jsonc.modelo` | config global (policies, permissions, providers) — `__OLLAMA_URL__` trocado na instalação |
| `bin/ocd`, `bin/ocd.ps1` | porta única: `perfis`, `doctor`, `login`, `run` |
| `instalar/linux.sh`, `instalar/windows.ps1`, `instalar/remoto.sh` | instaladores (idempotentes, fazem backup da config anterior) |
| `integracoes/README.md` | onde o opencode entra em cada sistema |
| `testes/rodar.sh` | testes sem modelo |
| `docs/PROVEDORES-SEM-CENSURA.md` | modelos sem censura por perfil |
| `PENDENCIAS.md` | o que falta, em ordem |

Versão: ver `VERSION` e `CHANGELOG.md`. opencode fixado em 2.4.2.

## Self-learning

Quando o Nei corrigir algo, ou o agente perceber um erro, a lição vira uma linha no topo da seção Lessons abaixo antes de seguir.

## Lessons

- 26/11/2026: o opencode 2.x mudou tudo em relação ao 1.x (pacote `@opencode/cli`, `providers.*.settings`, `policies`, `permissions` em lista). Material de 1.x (ODS, `opencode-ai`) não serve de modelo.
