# opencode-distri

[![Your agent everywhere](guia/assets/banner-en.jpg)](https://inematds.github.io/opencode-distri/guia/en/)

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

## What it is

Setting up an AI agent from scratch on every machine gets tiring, and each setup ends up different. opencode-distri is a free kit that installs **opencode**, an open source AI agent, the same way on your computer, a VPS, and Windows. The kit allows only three model backends: your **ChatGPT subscription**, **OpenRouter** (pay per use), and a **model on your own computer** (Ollama). Everything else is locked down, and the agent is prohibited from reading common password and key files. It is designed to power your Telegram bots and systems.

## 📖 User guide

Complete guide (landing page + walkthrough): **https://inematds.github.io/opencode-distri/guia/en/**

## Ask your AI to install it with you

Open Claude Code or Codex on your computer and paste:

```
Read the "opencode-distri" kit at https://github.com/inematds/opencode-distri (README, PENDENCIAS.md, and docs/).
I want opencode set up the same way on all my machines. On this computer:
1. Check the operating system (Linux, Windows, or VPS), whether I already have Node, Ollama, and a graphics card, and whether any opencode configuration already exists. Don't change anything yet.
2. In plain language, tell me which of the three model backends make sense for me (ChatGPT subscription, OpenRouter, local model) and what each costs.
3. Only after I say yes, run the right kit installer (instalar/linux.sh or instalar/windows.ps1) and the "ocd doctor" checkup. Show me the result.
4. Don't call any models, use any API key, or download a model unless I ask. I'll handle the ChatGPT login.
5. If I also want it on my VPS: ask me for the address and SSH key, install from here with instalar/remoto.sh, and give me the ChatGPT login command to run there
   (ssh -t ... opencode auth login openai). Let me know this path hasn't been tested on a real VPS yet.
```

There is no online version: the agent works with files on your machine. To download it manually: [kit ZIP](https://github.com/inematds/opencode-distri/archive/refs/heads/main.zip).

---

## Technical installation

The kit installs [opencode](https://opencode.ai) (open CLI agent, 2.x) the same way everywhere—on this machine, on Windows, or on a VPS—and gets it ready to power inemaccbot, openpcbotv3, exb (enginebridge), and intelecto.

Three model paths, and only these:

| Profile | Where the model comes from | Default model (TOPO tier) | Lock |
|---|---|---|---|
| `assinatura` | ChatGPT Plus/Pro login in opencode (`opencode auth login openai`) | `openai/gpt-6.2-sol` (`INEMA_CODEX_*`) | — |
| `openrouter` | `OPENROUTER_API_KEY` key from `.env`, loaded only in the child process | `openrouter/anthropic/claude-opus-5.5` (`INEMA_OPENROUTER_*`) | `OCD_APROVADO_OPENROUTER` |
| `local` | Ollama (`127.0.0.1:11434` or another address) | `ollama/qwen3.8:27b` (`INEMA_OLLAMA_*`) | `OCD_APROVADO_LOCAL` (or `APROVADO_MODELO_NEI`) |

- **A Claude subscription is not available in opencode 2.x**: the `anthropic` provider only accepts an API key (verified on 11/26/2026). For Claude via subscription, the backend remains the `claude` CLI.
- Every other provider is blocked by `policies` in the global config—including `opencode/*-free` models, which use opencode's own API.
- The agent does not read `*.env` or credential files.
- The shared opencode server stays off: each run uses `--standalone`, with the caller's cwd, environment, and memory limit.

## The process, from start to finish

1. ⚙️ **Install** — choose a location:
   - this machine / Linux with Ollama: `instalar/linux.sh`
   - VPS without a GPU, from here: `instalar/remoto.sh root@<IP> [-i ~/.ssh/<chave>]` (copies the repo and runs `linux.sh --vps` there)
   - VPS using this machine's Ollama over Tailscale: `instalar/remoto.sh root@<IP> -- --ollama http://<IP-tailscale-da-maquina-com-GPU>:11434/v1`
   - Windows: `powershell -ExecutionPolicy Bypass -File instalar\windows.ps1 [-SemOllama] [-OllamaUrl URL]` (**not yet tested on a real Windows machine**)
   - the locks stay enabled on every machine, including someone else's; `--sem-travas` / `-SemTravas` disables them and is not recommended
2. 🧠 **Subscription login** (interactive, once per machine): `opencode auth login openai` → "Sign in with ChatGPT". On a VPS: `ssh -t root@<IP> opencode auth login openai`. Never copy credentials from one machine to another (`auth export`).
3. ⚙️ **Check**: `ocd doctor` (version, locked config, shared server off, logins, `opencode/*` models blocked, model for each profile).
4. ⚙️ **Use without a screen**: `ocd run [-p assinatura|openrouter|local] [--auto] [--json] "pedido"` or `echo "pedido" | ocd run`. Interactive: `opencode` (TUI) or `opencode mini`.
5. 🧠 **Enable a paid/heavy profile** (only with the explicit OK of the person who owns the machine and pays the bill, quoted; for INEMA, Nei): `OCD_APROVADO_OPENROUTER="<o que foi aprovado>" ocd run -p openrouter …` · `OCD_APROVADO_LOCAL="<modelo e finalidade>" ocd run -p local …` (on this machine, the local profile runs through `fila-vaga gpu`).
6. 🤖 **Use as a system backend**: see [integracoes/README.md](integracoes/README.md) — each system's status and the smoke test that comes first.
7. ⚙️ **Test the kit** (without calling a model): `testes/rodar.sh` → `N ok, 0 falhas`.
8. ⚙️ **Update opencode**: change `VERSAO_OPENCODE` in `instalar/linux.sh` (and `-Versao` in `windows.ps1`), run `testes/rodar.sh`, and reinstall.

## Uncensored providers

Which uncensored models fit the `local` and `openrouter` profiles, and what is excluded (Venice, abliteration.ai): [docs/PROVEDORES-SEM-CENSURA.md](docs/PROVEDORES-SEM-CENSURA.md). Source article: [Uncensored AI providers](https://inematds.github.io/provedores-semcensura/guia/en/).

## What’s missing

[PENDENCIAS.md](PENDENCIAS.md): tests (paused until Nei approves), runners for inemaccbot, openpcbotv3, and exb, Venice and abliteration.ai profiles.

## Models

The order is: `OCD_MODELO_<PERFIL>` (fixed) → `~/.config/inema/modelos.env` at the `OCD_NIVEL` tier (`SUPER|TOPO|EXECUTOR|MENOR`) → `OCD_PADRAO_<PERFIL>` in `~/.config/opencode-distri/ocd.env`. Changing the model for all systems is still done only in `modelos.env`.

## Files

| Path | What it is |
|---|---|
| `config/opencode.jsonc.modelo` | global config (policies, permissions, providers) — `__OLLAMA_URL__` is replaced during installation |
| `bin/ocd`, `bin/ocd.ps1` | single entry point: `perfis`, `doctor`, `login`, `run` |
| `instalar/linux.sh`, `instalar/windows.ps1`, `instalar/remoto.sh` | installers (idempotent, back up the previous config) |
| `integracoes/README.md` | where opencode is used in each system |
| `testes/rodar.sh` | tests without a model |
| `docs/PROVEDORES-SEM-CENSURA.md` | uncensored models by profile |
| `PENDENCIAS.md` | what remains, in order |

Version: see `VERSION` and `CHANGELOG.md`. opencode pinned to 2.4.2.

## Self-learning

When Nei corrects something, or the agent notices an error, add the lesson as a line at the top of the Lessons section below before continuing.

## Lessons

- 11/26/2026: opencode 2.x changed everything compared with 1.x (package `@opencode/cli`, `providers.*.settings`, `policies`, `permissions` as a list). 1.x material (ODS, `opencode-ai`) is not a suitable reference.
