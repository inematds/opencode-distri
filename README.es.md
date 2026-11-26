# opencode-distri

[![Tu agente en todas partes](guia/assets/banner-es.jpg)](https://inematds.github.io/opencode-distri/guia/es/)

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

## Qué es

Instalar un agente de IA desde cero en cada máquina cansa, y cada uno termina siendo diferente. opencode-distri es un kit gratuito que instala **opencode**, un agente de IA de código abierto, de la misma manera en tu computadora, en una VPS y en Windows. El kit permite solo tres motores: tu **suscripción de ChatGPT**, **OpenRouter** (pago por uso) y un **modelo en tu propia computadora** (Ollama). Todo lo demás queda bloqueado, y se prohíbe al agente leer los archivos de contraseñas y claves más comunes. Está hecho para convertirse en el motor de tus bots de Telegram y tus sistemas.

## 📖 Guía de uso

Guía completa (landing + paso a paso): **https://inematds.github.io/opencode-distri/guia/es/**

## Pídele a tu IA que lo instale contigo

Abre Claude Code o Codex en tu computadora y pega:

```
Lee el kit "opencode-distri" en https://github.com/inematds/opencode-distri (README, PENDENCIAS.md y docs/).
Quiero tener opencode igual en todas mis máquinas. En esta computadora:
1. Revisa el sistema (Linux, Windows o VPS), si ya tengo Node, Ollama y una tarjeta gráfica, y si ya existe
   alguna configuración de opencode. Todavía no cambies nada.
2. Explícame en lenguaje sencillo cuáles de los tres motores tienen sentido para mí (suscripción de ChatGPT,
   OpenRouter, modelo local) y cuánto cuesta cada uno.
3. Solo después de que te dé el visto bueno, ejecuta el instalador adecuado del kit (instalar/linux.sh o instalar/windows.ps1)
   y el chequeo "ocd doctor". Muéstrame el resultado.
4. No llames ningún modelo, no uses claves de API ni descargues modelos sin que te lo pida.
   Yo me encargo del inicio de sesión de ChatGPT.
5. Si también lo quiero en mi VPS: pregúntame la dirección y la clave SSH, instálalo desde aquí con
   instalar/remoto.sh y pásame el comando para iniciar sesión en ChatGPT y ejecutarlo allá
   (ssh -t ... opencode auth login openai). Avísame que este método todavía no se ha probado en una VPS real.
```

No hay versión en línea: el agente trabaja con los archivos de tu máquina. Para descargarlo manualmente: [kit en ZIP](https://github.com/inematds/opencode-distri/archive/refs/heads/main.zip).

---

## Instalación técnica

El kit instala [opencode](https://opencode.ai) (CLI de agente abierta, 2.x) de la misma manera en cualquier lugar: esta máquina, una computadora con Windows o una VPS. Lo deja listo para convertirse en el motor de inemaccbot, openpcbotv3, exb (enginebridge) e intelecto.

Tres opciones de modelo, y solo esas:

| Perfil | De dónde viene el modelo | Modelo predeterminado (nivel TOPO) | Bloqueo |
|---|---|---|---|
| `assinatura` | Inicio de sesión de ChatGPT Plus/Pro en opencode (`opencode auth login openai`) | `openai/gpt-6.2-sol` (`INEMA_CODEX_*`) | — |
| `openrouter` | Clave `OPENROUTER_API_KEY` de `.env`, cargada solo en el proceso hijo | `openrouter/anthropic/claude-opus-5.5` (`INEMA_OPENROUTER_*`) | `OCD_APROVADO_OPENROUTER` |
| `local` | Ollama (`127.0.0.1:11434` u otro) | `ollama/qwen3.8:27b` (`INEMA_OLLAMA_*`) | `OCD_APROVADO_LOCAL` (o `APROVADO_MODELO_NEI`) |

- **No existe la suscripción de Claude en opencode 2.x**: el proveedor `anthropic` solo acepta claves de API (comprobado el 26/11/2026). Para usar Claude con una suscripción, el motor sigue siendo el CLI `claude`.
- Todos los demás proveedores quedan bloqueados por `policies` en la configuración global, incluidos los modelos `opencode/*-free`, que usan la API del propio opencode.
- El agente no lee archivos `*.env` ni archivos de credenciales.
- El servidor compartido de opencode queda desactivado: cada ejecución usa `--standalone`, con el cwd, el entorno y el límite de memoria de quien lo invoca.

## El proceso, de principio a fin

1. ⚙️ **Instalar** — elige dónde:
   - esta máquina / Linux con Ollama: `instalar/linux.sh`
   - VPS sin GPU, desde aquí: `instalar/remoto.sh root@<IP> [-i ~/.ssh/<chave>]` (copia el repositorio y ejecuta `linux.sh --vps` allí)
   - VPS que usa Ollama de esta máquina por Tailscale: `instalar/remoto.sh root@<IP> -- --ollama http://<IP-tailscale-da-maquina-com-GPU>:11434/v1`
   - Windows: `powershell -ExecutionPolicy Bypass -File instalar\windows.ps1 [-SemOllama] [-OllamaUrl URL]` (**todavía no se ha probado en Windows real**)
   - los bloqueos están activos en cualquier máquina, incluso en la de otra persona; `--sem-travas` / `-SemTravas` los desactiva y no se recomienda
2. 🧠 **Inicio de sesión con la suscripción** (interactivo, una vez por máquina): `opencode auth login openai` → "Sign in with ChatGPT". En la VPS: `ssh -t root@<IP> opencode auth login openai`. Nunca copies credenciales de una máquina a otra (`auth export`).
3. ⚙️ **Verificar**: `ocd doctor` (versión, configuración con bloqueos, servidor compartido desactivado, inicios de sesión, modelos `opencode/*` bloqueados, modelo de cada perfil).
4. ⚙️ **Usar sin interfaz**: `ocd run [-p assinatura|openrouter|local] [--auto] [--json] "pedido"` o `echo "pedido" | ocd run`. Modo interactivo: `opencode` (TUI) o `opencode mini`.
5. 🧠 **Habilitar un perfil de pago o pesado** (solo con la aprobación explícita de quien es dueño de la máquina y paga la cuenta; en INEMA, la de Nei): `OCD_APROVADO_OPENROUTER="<o que foi aprovado>" ocd run -p openrouter …` · `OCD_APROVADO_LOCAL="<modelo e finalidade>" ocd run -p local …` (en esta máquina, el perfil local se ejecuta mediante `fila-vaga gpu`).
6. 🤖 **Motor en los sistemas**: consulta [integracoes/README.md](integracoes/README.md) — el estado de cada sistema y la prueba de humo que se ejecuta antes.
7. ⚙️ **Probar el kit** (sin llamar a ningún modelo): `testes/rodar.sh` → `N ok, 0 falhas`.
8. ⚙️ **Actualizar opencode**: cambia `VERSAO_OPENCODE` en `instalar/linux.sh` (y `-Versao` en `windows.ps1`), ejecuta `testes/rodar.sh` y vuelve a instalar.

## Proveedores sin censura

Qué modelos sin censura pueden usarse en los perfiles `local` y `openrouter`, y cuáles quedan fuera (Venice, abliteration.ai): [docs/PROVEDORES-SEM-CENSURA.md](docs/PROVEDORES-SEM-CENSURA.md). Artículo de referencia: [Proveedores de IA sin censura](https://inematds.github.io/provedores-semcensura/guia/es/).

## Lo que falta

[PENDENCIAS.md](PENDENCIAS.md): pruebas (pausadas hasta que Nei las autorice), runners de inemaccbot, openpcbotv3 y exb, perfiles de Venice y abliteration.ai.

## Modelos

El orden es: `OCD_MODELO_<PERFIL>` (fijo) → `~/.config/inema/modelos.env` en el nivel `OCD_NIVEL` (`SUPER|TOPO|EXECUTOR|MENOR`) → `OCD_PADRAO_<PERFIL>` en `~/.config/opencode-distri/ocd.env`. Para cambiar el modelo en todos los sistemas, sigue bastando con modificar `modelos.env`.

## Archivos

| Ruta | Qué es |
|---|---|
| `config/opencode.jsonc.modelo` | configuración global (policies, permissions, providers); `__OLLAMA_URL__` se sustituye durante la instalación |
| `bin/ocd`, `bin/ocd.ps1` | interfaz única: `perfis`, `doctor`, `login`, `run` |
| `instalar/linux.sh`, `instalar/windows.ps1`, `instalar/remoto.sh` | instaladores (idempotentes, hacen una copia de seguridad de la configuración anterior) |
| `integracoes/README.md` | dónde se integra opencode en cada sistema |
| `testes/rodar.sh` | pruebas sin modelo |
| `docs/PROVEDORES-SEM-CENSURA.md` | modelos sin censura por perfil |
| `PENDENCIAS.md` | lo que falta, en orden |

Versión: consulta `VERSION` y `CHANGELOG.md`. opencode está fijado en 2.4.2.

## Autoaprendizaje

Cuando Nei corrija algo, o el agente detecte un error, la lección se añade en una línea al principio de la sección Lessons antes de continuar.

## Lessons

- 26/11/2026: opencode 2.x cambió por completo respecto de 1.x (paquete `@opencode/cli`, `providers.*.settings`, `policies`, `permissions` como lista). El material de 1.x (ODS, `opencode-ai`) no sirve como referencia.
