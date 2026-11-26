# opencode-distri

[![Tu agente en todas partes](guia/assets/banner-es.jpg)](https://inematds.github.io/opencode-distri/guia/es/)

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

## Qué es

Instalar un agente de IA desde cero en cada máquina cansa, y cada uno termina siendo diferente. opencode-distri es un kit gratuito que instala **opencode**, un agente de IA de código abierto, de la misma manera en tu computadora, en una VPS y en Windows. El kit deja solo tres motores posibles: tu **suscripción de ChatGPT**, **OpenRouter** (pago por uso) y un **modelo en tu propia computadora** (Ollama). Todo lo demás queda bloqueado, y el agente nunca abre tus archivos de contraseñas. Está pensado para ser el motor de tus robots de Telegram y de tus sistemas.

## 📖 Guía de uso

Guía completa (landing + paso a paso): **https://inematds.github.io/opencode-distri/guia/es/**

## Pídele a tu IA que lo instale contigo

Abre Claude Code o Codex en tu computadora y pega:

```
Lee el kit "opencode-distri" en https://github.com/inematds/opencode-distri (README, PENDENCIAS.md y docs/).
Quiero tener opencode igual en todas mis máquinas. En esta computadora:
1. Revisa el sistema (Linux, Windows o VPS), si ya tengo Node, Ollama y tarjeta gráfica, y si ya existe
   alguna configuración de opencode. No cambies nada todavía.
2. Dime en lenguaje sencillo cuáles de los tres motores me convienen (suscripción de ChatGPT,
   OpenRouter, modelo local) y cuánto cuesta cada uno.
3. Solo después de que te dé el visto bueno, ejecuta el instalador adecuado del kit (instalar/linux.sh o instalar/windows.ps1)
   y el chequeo "ocd doctor". Muéstrame el resultado.
4. No llames a ningún modelo, no uses claves de API y no descargues ningún modelo sin que te lo pida.
   Yo hago el inicio de sesión de ChatGPT.
```

No hay una versión en línea: el agente trabaja con los archivos de tu máquina. Para descargarlo manualmente: [kit en ZIP](https://github.com/inematds/opencode-distri/archive/refs/heads/main.zip).

---

## Instalación técnica

El kit instala [opencode](https://opencode.ai) (CLI de agente abierta, 2.x) de la misma manera en cualquier lugar — esta máquina, una computadora con Windows o una VPS — y lo deja listo para ser el motor de inemaccbot, openpcbotv3, exb (enginebridge) e intelecto.

Tres opciones de modelo, y solo esas:

| Perfil | De dónde viene el modelo | Modelo predeterminado (nivel TOPO) | Bloqueo |
|---|---|---|---|
| `assinatura` | inicio de sesión de ChatGPT Plus/Pro en opencode (`opencode auth login openai`) | `openai/gpt-6.2-sol` (`INEMA_CODEX_*`) | — |
| `openrouter` | clave `OPENROUTER_API_KEY` de `.env`, cargada solo en el proceso hijo | `openrouter/anthropic/claude-opus-5.5` (`INEMA_OPENROUTER_*`) | `OCD_APROVADO_OPENROUTER` |
| `local` | Ollama (`127.0.0.1:11434` u otro) | `ollama/qwen3.8:27b` (`INEMA_OLLAMA_*`) | `APROVADO_MODELO_NEI` |

- **La suscripción de Claude no está disponible en opencode 2.x**: el proveedor `anthropic` solo acepta una clave de API (confirmado el 26/11/2026). Para usar Claude con la suscripción, el motor sigue siendo el CLI `claude`.
- Todos los demás proveedores quedan bloqueados mediante `policies` en la configuración global, incluidos los modelos `opencode/*-free`, que usan la API del propio opencode.
- El agente no lee `*.env` ni archivos de credenciales.
- El servidor compartido de opencode permanece apagado: cada ejecución usa `--standalone`, con el cwd, el entorno y el límite de memoria de quien la inició.

## El proceso, de principio a fin

1. ⚙️ **Instalar** — elige dónde:
   - esta máquina / Linux con Ollama: `instalar/linux.sh`
   - VPS sin GPU, desde aquí: `instalar/remoto.sh root@<IP> [-i ~/.ssh/<chave>]` (copia el repo y ejecuta `linux.sh --vps` allí)
   - VPS que usa el Ollama de esta máquina por Tailscale: `instalar/remoto.sh root@<IP> -- --ollama http://<IP-tailscale-da-maquina-com-GPU>:11434/v1`
   - Windows: `powershell -ExecutionPolicy Bypass -File instalar\windows.ps1 [-SemOllama] [-OllamaUrl URL]` (**todavía no se ha probado en Windows real**)
   - máquina de otra persona: agrega `--sem-travas` / `-SemTravas`
2. 🧠 **Iniciar sesión con la suscripción** (interactivo, una vez por máquina): `opencode auth login openai` → "Sign in with ChatGPT". En la VPS: `ssh -t root@<IP> opencode auth login openai`. Nunca copies credenciales de una máquina a otra (`auth export`).
3. ⚙️ **Verificar**: `ocd doctor` (versión, configuración con bloqueo, servidor compartido apagado, inicios de sesión, modelos `opencode/*` bloqueados, modelo de cada perfil).
4. ⚙️ **Usar sin interfaz**: `ocd run [-p assinatura|openrouter|local] [--auto] [--json] "pedido"` o `echo "pedido" | ocd run`. Interactivo: `opencode` (TUI) o `opencode mini`.
5. 🧠 **Habilitar un perfil pago o pesado** (solo con el visto bueno explícito de Nei): `OCD_APROVADO_OPENROUTER="<o que foi aprovado>" ocd run -p openrouter …` · `APROVADO_MODELO_NEI="<modelo e finalidade>" ocd run -p local …` (en esta máquina, el perfil local entra por `fila-vaga gpu`).
6. 🤖 **Motor en los sistemas**: consulta [integracoes/README.md](integracoes/README.md) — estado de cada sistema y la prueba de humo que se ejecuta antes.
7. ⚙️ **Probar el kit** (sin llamar a ningún modelo): `testes/rodar.sh` → `N ok, 0 falhas`.
8. ⚙️ **Actualizar opencode**: cambia `VERSAO_OPENCODE` en `instalar/linux.sh` (y `-Versao` en `windows.ps1`), ejecuta `testes/rodar.sh` y reinstala.

## Proveedores sin censura

Qué modelos sin censura sirven para los perfiles `local` y `openrouter`, y cuáles quedan fuera (Venice, abliteration.ai): [docs/PROVEDORES-SEM-CENSURA.md](docs/PROVEDORES-SEM-CENSURA.md). Artículo de referencia: [Proveedores de IA sin censura](https://inematds.github.io/provedores-semcensura/guia/es/).

## Lo que falta

[PENDENCIAS.md](PENDENCIAS.md): pruebas (pausadas hasta que Nei las autorice), runners de inemaccbot, openpcbotv3 y exb, perfiles Venice y abliteration.ai.

## Modelos

El orden es: `OCD_MODELO_<PERFIL>` (fijo) → `~/.config/inema/modelos.env` en el nivel `OCD_NIVEL` (`SUPER|TOPO|EXECUTOR|MENOR`) → `OCD_PADRAO_<PERFIL>` en `~/.config/opencode-distri/ocd.env`. Cambiar el modelo de todos los sistemas sigue haciéndose solo en `modelos.env`.

## Archivos

| Ruta | Qué es |
|---|---|
| `config/opencode.jsonc.modelo` | configuración global (policies, permissions, providers) — `__OLLAMA_URL__` se reemplaza durante la instalación |
| `bin/ocd`, `bin/ocd.ps1` | interfaz única: `perfis`, `doctor`, `login`, `run` |
| `instalar/linux.sh`, `instalar/windows.ps1`, `instalar/remoto.sh` | instaladores (idempotentes, hacen una copia de seguridad de la configuración anterior) |
| `integracoes/README.md` | dónde se integra opencode en cada sistema |
| `testes/rodar.sh` | pruebas sin modelo |
| `docs/PROVEDORES-SEM-CENSURA.md` | modelos sin censura por perfil |
| `PENDENCIAS.md` | lo que falta, en orden |

Versión: consulta `VERSION` y `CHANGELOG.md`. opencode fijado en 2.4.2.

## Aprendizaje continuo

Cuando Nei corrija algo, o el agente detecte un error, la lección se agrega en una línea al inicio de la sección Lessons de abajo antes de continuar.

## Lecciones

- 26/11/2026: opencode 2.x cambió por completo respecto a 1.x (paquete `@opencode/cli`, `providers.*.settings`, `policies`, `permissions` en una lista). El material de 1.x (ODS, `opencode-ai`) no sirve como modelo.
