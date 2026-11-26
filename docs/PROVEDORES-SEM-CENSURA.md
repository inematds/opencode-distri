# Provedores sem censura no opencode-distri

Modelos "sem censura" são versões que não recusam pedidos. Servem para testar a segurança do próprio sistema, pesquisar ou ter um assistente que não trava em assunto delicado. Este arquivo diz **quais deles cabem nos três perfis do `ocd`** e o que ainda fica de fora.

Base: a matéria e o guia **[Provedores de IA sem censura](https://inematds.github.io/provedores-semcensura/guia/)** (vídeo no lives4: https://www.youtube.com/watch?v=ZsnxZmxcOSQ). Os modelos e preços abaixo vêm de lá, **conferidos em 09/11/2026 nas páginas públicas dos provedores**. Nada foi testado com conta ou chave, e o opencode ainda não rodou nenhum deles.

Relacionados no INEMA: [IA privada em 3 níveis](https://inematds.github.io/ia-privada-3-niveis/guia/) · [IA sem censura defensiva](https://inematds.github.io/ia-sem-censura-defensiva/guia/) · [IA sem censura pronta](https://inematds.github.io/ia-sem-censura-pronta/guia/) · [Modelo do seu jeito (Heretic)](https://inematds.github.io/modelo-do-seu-jeito/guia/).

## Os três tipos, em uma linha

- **uncensored**: retreinado com dados sem recusa (fine-tune, tipo Dolphin).
- **abliterated**: a "direção de recusa" é tirada dos pesos, sem treinar (Arditi et al., 2024; Labonne). "Heretic" é uma variante recente.
- **jailbroken**: o modelo é o normal, e é o prompt que engana as regras. Não entra aqui.

Sem a trava, a qualidade cai um pouco e alucinar fica mais fácil. Tirar a trava do modelo não tira a lei: o uso ilegal continua proibido pelos termos dos provedores.

## Onde cada um entra no `ocd`

### Perfil `local` (Ollama): o mais privado

Nada sai da máquina, sem conta e sem identidade. Para o `ocd`, é um modelo Ollama como outro qualquer:

| Modelo (Ollama) | De onde | Observação |
|---|---|---|
| `orcarouter/Qwen3.8-27B-Uncensored` | ollama.com/orcarouter | abliterated, contexto 262K; "0% de recusa sem perda" é medida do próprio autor |
| `orcarouter/Qwen3.8-Flash-Next-Uncensored` | ollama.com/orcarouter | MoE ~177B/6B ativos, MLX (Apple Silicon), "research use only" |
| abliterated da `huihui-ai` (GGUF) | huggingface.co/huihui-ai | ex.: Huihui-GLM-5.3-Flash-abliterated, Qwen3.8-abliterated |

```bash
# só com aprovação do Nei para o modelo e a finalidade (regra de modelos locais)
APROVADO_MODELO_NEI="<modelo e para quê>" OCD_MODELO_LOCAL="orcarouter/Qwen3.8-27B-Uncensored" \
  ocd run -p local "pedido"
ollama stop orcarouter/Qwen3.8-27B-Uncensored   # depois
```

Baixar o modelo (`ollama pull`) também precisa dessa aprovação, e o hook `modelo-local-sem-aprovacao` bloqueia o comando sem ela. Nesta máquina o perfil local entra pela `fila-vaga gpu`.

### Perfil `openrouter`: sem GPU, por API

O `provider.use` do OpenRouter já está liberado na config. Modelos menos restritivos no catálogo público (entrada/saída em US$ por 1M de tokens, 09/11/2026):

| ID no opencode | Preço | O que é |
|---|---|---|
| `openrouter/cognitivecomputations/dolphin-mistral-24b-venice-edition` | 0,20 / 0,90 | "Venice: Uncensored" |
| `openrouter/nousresearch/hermes-4-405b` | 1,00 / 3,00 | fine-tune menos restritivo |
| `openrouter/thedrummer/cydonia-24b-v4.1` | 0,30 / 0,50 | fine-tune menos restritivo |
| `openrouter/thedrummer/skyfall-36b-v2` | 0,55 / 0,80 | fine-tune menos restritivo |
| `openrouter/sao10k/l3.1-euryale-70b` | 0,85 / 0,85 | fine-tune menos restritivo |
| `openrouter/anthracite-org/magnum-v4-72b` | 2,50 / 5,00 | fine-tune menos restritivo |

Hermes, Cydonia, Euryale e Magnum recusam menos, mas não são garantidamente "zero recusa". Em 09/11/2026 o catálogo não tinha nada com a tag "abliterated" ou "heretic". Antes de mandar dado sensível, confira a retenção e o ZDR na conta do OpenRouter.

```bash
# cada uso pede OK explícito do Nei para a API, citado na trava
OCD_APROVADO_OPENROUTER="<o que foi aprovado>" \
OCD_MODELO_OPENROUTER="cognitivecomputations/dolphin-mistral-24b-venice-edition" \
  ocd run -p openrouter "pedido"
```

### Perfil `assinatura` (ChatGPT): não serve para isso

Os modelos da OpenAI têm trava e a assinatura não muda isso.

## Fora da v1: Venice e abliteration.ai direto

Os dois têm API compatível com OpenAI e os catálogos sem censura mais completos:

| Provedor | Base | Exemplos | Privacidade declarada |
|---|---|---|---|
| Venice.ai | API OpenAI-compatível | `venice-uncensored-1-2` (0,20/0,90), `gemma-4-uncensored` (0,1625/0,50), `deepseek-v4-1-flash-1017-uncensored` (0,33/1,32), `olafangensan-glm-4.7-flash-heretic` (0,07/0,40) | modo Private = retenção zero por contrato; TEE/E2EE em alguns |
| abliteration.ai | `https://api.abliteration.ai/v1` (OpenAI + Anthropic Messages) | Abliterated Large v2 (GLM-5.3), Large Flash | "zero data retention"; planos US$ 20/50/200 |

Eles **ficam bloqueados** pela policy `provider.use * deny`. Entrar com um deles pede três coisas:

1. OK do Nei para aquela API e aquela finalidade.
2. Um provedor OpenAI-compatível novo na config (`providers.<nome>.settings.baseURL` + `apiKey: {env:...}`) e uma linha `allow` em `policies`.
3. Um perfil novo no `ocd`, com trava própria (ex.: `OCD_APROVADO_VENICE`), e a chave carregada só no processo filho, igual ao OpenRouter.

Ver [PENDENCIAS.md](../PENDENCIAS.md).

## O que conferir antes de usar

- As alegações de "zero retenção" são autodeclaradas por Venice, abliteration.ai, Featherless e OrcaRouter, sem auditoria independente verificada.
- Os preços mudam: refazer a conferência (passo 8 do guia provedores-semcensura) antes de citar número.
- O agente do opencode não lê `*.env` nem credenciais (`permissions`), qualquer que seja o modelo.
