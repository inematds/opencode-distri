# Integrações — opencode como motor nos sistemas INEMA

Estado em 26/11/2026. A v1 entra com os três perfis (assinatura, OpenRouter, Ollama). Testes pausados pelo Nei ("não vamos testar em nada por hora"); lista do que falta em [../PENDENCIAS.md](../PENDENCIAS.md). **Nenhum repo de fora foi alterado ainda**: falta o teste de fumaça com um modelo de verdade (ver "Antes de integrar").

| Sistema | Onde o motor entra | Situação |
|---|---|---|
| **inemaccbot** (`~/projetos/inemaccbot`) | `src/fila/runner-opencode.ts` já existe (`OpencodeRunner`, `RUNNERS.opencode`); escolha por `\| motor=opencode`, `perfil.motor` na skill ou `MOTOR_PADRAO=opencode` | Pronto no código, **nunca testado na CLI real**. Ajustes já sabidos: `OPENCODE_BIN` padrão é `~/.opencode/bin/opencode`, mas o npm põe em `~/.npm-global/bin/opencode`; os argumentos (`run [--model] prompt`) precisam de `--standalone --archived` e, para job sem tela, de `--auto` ou de regras `permissions` (sem isso o `ask` trava). |
| **openpcbotv3** (`~/projetos/openpcbotv3`) | Mesmo desenho de `RUNNERS` do inemaccbot (`src/fila/runner.ts:122`); `MotorAgente = 'claude'\|'codex'` em `src/config/agentes-ia.ts`; mapa de runners em `src/index.ts:108-114`; `/motor` em `src/orquestrador/comandos.ts`; parser em `src/orquestrador/agente-cli.ts:280` | A fazer: copiar o runner do inemaccbot (item B7 de `docs/INCORPORAR-V3.md`), alargar o tipo, o mapa, `ambienteAssinatura` e o parser. Serviço vivo e árvore suja: commitar só o que for do motor, sem reiniciar sem OK. Versão 3.43.23 → 3.44.23. |
| **exb / enginebridge** (`~/projetos/enginebridge`) | `enginebridge/adapters.py` (`command`, `parse_output`), `core.py:29,99,109`, `cli.py:24,34`, `config/enginebridge.yaml` (`motores.*`) | A fazer. Os motores de lá rodam **sem ferramentas** (`-s read-only`, `--tools ''`): no opencode isso pede regras `deny` de ferramenta, não `--auto`. O exb só aceita `tipo: assinatura` e limpa toda variável `*API_KEY*` de propósito — OpenRouter entra na v1 (Nei, 26/11/2026): pede um tipo `api` com trava no exb, carregando só `OPENROUTER_API_KEY` no processo filho. Prompt vai por stdin (até 1 MB): conferir se o `opencode run` lê stdin (argv único trava perto de 128 KB). |
| **intelecto-v2** (`~/projetos/intelecto-v2`) | `intelecto/provedores/` (`criar()`), `config.py:10 PROVEDORES` | **Nada a fazer.** Desde a v2.4.2 (26/11/2026) o intelecto roda pela assinatura com os provedores `claude` e `codex`, e o OpenRouter já é provedor nativo dele. O provedor "opencode" ficou desnecessário. |

## Antes de integrar: teste de fumaça (precisa de um modelo liberado)

**Pendente (Nei, 26/11/2026): testar com `qwen3.8:27b` no Ollama desta máquina** (~17 GB, pela `fila-vaga gpu`; depois `ollama stop qwen3.8:27b`).

Com um dos três perfis liberado (`opencode auth login openai`, ou OpenRouter aprovado, ou um modelo Ollama aprovado), rodar e anotar aqui:

1. `ocd run -p <perfil> "responda só: ok"` → sai `ok`, código 0, sem tela.
2. Sem `--auto`, um pedido que escreve arquivo trava no `ask`? (esperado: sim; registrar o tempo até o timeout)
3. `cd /tmp/x && ocd run --auto "crie oc-smoke.txt com ok; última linha: RESULT: /tmp/x/oc-smoke.txt"` → o arquivo nasce no cwd do job e a última linha do stdout casa `RESULT:`.
4. `echo "<prompt grande>" | opencode --standalone run -m … ` lê stdin? (decide stdin × argv no exb)
5. `--format json`: formato dos eventos e onde vem o id da sessão; `--session <id>` retoma?
6. Código de saída em erro (modelo inexistente, sem login).

Só depois disso os runners do openpcbotv3 e do exb são escritos — e o do inemaccbot corrigido com os mesmos achados.
