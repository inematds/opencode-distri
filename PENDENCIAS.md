# Pendências — opencode-distri

Estado em 26/11/2026 (v0.2.0). O que falta para continuar depois, em ordem. Mais recente no topo dentro de cada bloco.

**Ordem do Nei (26/11/2026): "não vamos testar em nada por hora".** Nenhum modelo foi chamado e nenhum login foi feito. Os itens 1 e 2 só andam quando ele liberar.

## Testes (pausados)

1. [ ] **Teste de fumaça (6 passos)** de [integracoes/README.md](integracoes/README.md). O modelo combinado é o `qwen3.8:27b` (~17 GB). Roda com `APROVADO_MODELO_NEI` pela `fila-vaga gpu`, e no fim `ollama stop qwen3.8:27b`. Responde três perguntas: se o `ask` trava sem `--auto`, se o `run` lê stdin, e qual é o formato do `--format json` e da `--session`.
2. [ ] **Login da assinatura ChatGPT** (`ocd login` → "Sign in with ChatGPT"). Feito pelo Nei, uma vez por máquina. Repetir o teste de fumaça com `-p assinatura`.
3. [ ] **Perfil OpenRouter**: o mesmo teste com `-p openrouter`, só com o OK da API citado em `OCD_APROVADO_OPENROUTER`.
4. [ ] **Windows real**: `instalar/windows.ps1` e `bin/ocd.ps1` nunca rodaram num Windows.
5b. [ ] **Trava de segredos na prática**: no teste de fumaça, pedir ao agente que leia um `.env`, um `id_ed25519` e um `.pem` falsos e confirmar que ele recusa. Os padrões de `permissions` só foram conferidos no arquivo, não no opencode.
5. [ ] **VPS real**: `instalar/remoto.sh` nunca rodou numa VPS, nem com Ollama local nem pela Tailscale.

## Motor nos sistemas (depois dos testes)

A v1 entra com os **três perfis**: assinatura ChatGPT, OpenRouter e Ollama. Pelo Nei, em 26/11/2026, o OpenRouter entra já na v1 em vez de ficar para a v2. A trava continua, e cada uso de API pede OK.

6. [ ] **inemaccbot**: corrigir `src/fila/runner-opencode.ts`:
   - `OPENCODE_BIN` padrão → `~/.npm-global/bin/opencode`, ou melhor, chamar o `ocd`;
   - acrescentar `--standalone --archived`;
   - para job sem tela, `--auto` ou regras `permissions`;
   - escolher o perfil (`assinatura|openrouter|local`).
7. [ ] **openpcbotv3**: runner copiado do inemaccbot (item B7 de `docs/INCORPORAR-V3.md`):
   - alargar `MotorAgente`, o mapa de runners em `src/index.ts` e `/motor`;
   - parser em `agente-cli.ts`.

   O serviço está no ar e a árvore suja. Commitar só o que for do motor e **não reiniciar sem OK**. Versão 3.43.23 → 3.44.23.
8. [ ] **exb (enginebridge)**: adapter `opencode` em `enginebridge/adapters.py`, sem ferramentas: regras `deny` de ferramenta, não `--auto`. Hoje o exb só aceita `tipo: assinatura` e limpa `*API_KEY*`. Para o OpenRouter entrar, criar um tipo `api` com trava, como pede a v1. Decidir stdin × argv pelo item 1.
9. [ ] **intelecto-v2**: nada a fazer pela assinatura, que ele já tem desde a v2.4.2 (provedores `claude` e `codex`). O OpenRouter já é provedor nativo dele.

## Provedores sem censura

Ver [docs/PROVEDORES-SEM-CENSURA.md](docs/PROVEDORES-SEM-CENSURA.md).

10. [ ] **Venice e abliteration.ai como perfis próprios**:
    - provedor OpenAI-compatível novo na config, com `allow` na policy;
    - perfil no `ocd` com trava própria e chave só no processo filho.

    Precisa do OK do Nei para cada API.
11. [ ] **Preços**: reconferir a tabela (é de 09/11/2026) antes de qualquer vídeo ou post citar número.
12. [ ] **Modelos sem censura locais** (`orcarouter/Qwen3.8-27B-Uncensored`, huihui-ai): só com aprovação do modelo. O `ollama pull` é bloqueado pelo hook sem ela.

## Divulgação

Feito em 26/11/2026: guia PT/EN/ES no ar (revisor independente aprovou na 5ª rodada), portal inema.club + catálogo PRO, tópico no INEMA.AGENTES (https://t.me/c/2433384436/7504).

13. [ ] **Vídeo do guia** (regra D21: todo guia tem explicavideo com avatar em `#video`, nos 3 idiomas). Sai depois do guia.

## Não fazer

- Chamar OpenRouter, Venice ou abliteration.ai sem OK explícito.
- Carregar modelo Ollama sem aprovação.
- Copiar credencial do opencode entre máquinas (`opencode auth export`).
- Reiniciar o openpcbotv3 sem OK.
