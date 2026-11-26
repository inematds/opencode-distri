# CLAUDE.md — opencode-distri

- O que é e o passo a passo: [README.md](README.md). Integrações por sistema: [integracoes/README.md](integracoes/README.md).
- Commits: autor `inematds <inematds@gmail.com>`.
- Nunca chamar modelo em teste sem liberação: assinatura só depois do login do Nei; OpenRouter só com OK explícito (API); Ollama só com o modelo aprovado (`APROVADO_MODELO_NEI`) e pela `fila-vaga gpu`.
- Nunca copiar credencial do opencode entre máquinas (`opencode auth export`).
- Mudou o fluxo → atualizar "O processo, do início ao fim" no README no mesmo commit; mudou versão → `VERSION`, `OCD_VERSAO` em `bin/ocd` e `bin/ocd.ps1`, `CHANGELOG.md`.
- Antes de commitar: `testes/rodar.sh` com 0 falhas.

## Self-learning

When I correct you, or you catch yourself making a mistake: before continuing, add the lesson as a one-line rule at the TOP of the Lessons section below.

## Lessons

- 26/11/2026: opencode 2.x ≠ 1.x — nada de copiar config/instalador do ODS (v1).
