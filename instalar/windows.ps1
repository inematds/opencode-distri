# Instala o opencode-distri no Windows 10/11 (PowerShell 5.1+).  AINDA NÃO TESTADO EM WINDOWS REAL.
#   powershell -ExecutionPolicy Bypass -File instalar\windows.ps1
#   ... -OllamaUrl http://192.168.0.10:11434/v1   (Ollama em outra máquina)
#   ... -SemOllama                                (sem modelo local)
#   ... -SemTravas                                (máquina de outra pessoa)
# Não faz login nem chama modelo. Repetir é seguro.
param(
  [string]$OllamaUrl = "http://127.0.0.1:11434/v1",
  [switch]$SemOllama,
  [switch]$SemTravas,
  [string]$Versao = "2.4.2"
)
$ErrorActionPreference = "Stop"
$Raiz = Split-Path -Parent $PSScriptRoot
function Passo($t) { Write-Host "> $t" }

# 1. CLI: npm (versão fixa) se houver Node; senão o binário oficial (última versão)
$oc = (Get-Command opencode -ErrorAction SilentlyContinue).Source
$atual = if ($oc) { (& $oc --version) -replace '^opencode v','' } else { "" }
if ($atual -eq $Versao) {
  Passo "opencode $atual ja instalado"
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
  Passo "instalando @opencode/cli@$Versao pelo npm"
  npm install -g "@opencode/cli@$Versao" | Out-Null
} else {
  $arq = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "opencode-windows-arm64.zip" } else { "opencode-windows-x64.zip" }
  $dest = Join-Path $env:LOCALAPPDATA "opencode-distri\bin"
  New-Item -ItemType Directory -Force $dest | Out-Null
  $zip = Join-Path $env:TEMP $arq
  Passo "baixando $arq"
  Invoke-WebRequest "https://opencode.ai/update/api/latest/cli/opencode/$arq" -OutFile $zip
  Expand-Archive $zip -DestinationPath $dest -Force
  Remove-Item $zip
  $exe = Get-ChildItem $dest -Recurse -Filter opencode.exe | Select-Object -First 1
  $binDir = $exe.DirectoryName
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
    Passo "PATH do usuario atualizado (abra um terminal novo)"
  }
  $env:Path = "$env:Path;$binDir"
}
$oc = (Get-Command opencode).Source
Passo "opencode: $oc ($(& $oc --version))"

# 2. Sem servidor compartilhado
& $oc service set disabled true | Out-Null

# 3. Config global com trava de provedores
$cfg = (& $oc debug paths config).Trim()
New-Item -ItemType Directory -Force $cfg | Out-Null
foreach ($n in "opencode.json","opencode.jsonc") {
  $f = Join-Path $cfg $n
  if ((Test-Path $f) -and -not (Select-String -Quiet -Path $f -Pattern "opencode-distri")) {
    Copy-Item $f "$f.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"; Passo "backup de $f"
  }
}
Remove-Item (Join-Path $cfg "opencode.json") -ErrorAction SilentlyContinue
$modelo = Get-Content (Join-Path $Raiz "config\opencode.jsonc.modelo")
if ($SemOllama) { $modelo = $modelo | Where-Object { $_ -notmatch '"ollama"' } }
else { $modelo = $modelo -replace "__OLLAMA_URL__", $OllamaUrl }
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllLines((Join-Path $cfg "opencode.jsonc"), $modelo, $utf8)
Passo "config: $cfg\opencode.jsonc"

# 4. ocd.ps1 + preferências
$prefDir = Join-Path $env:USERPROFILE ".config\opencode-distri"
New-Item -ItemType Directory -Force $prefDir | Out-Null
$pref = Join-Path $prefDir "ocd.env"
if (-not (Test-Path $pref)) {
  $travas = if ($SemTravas) { 0 } else { 1 }
  $local = if ($SemOllama) { "" } else { "qwen3.8:27b" }
  [IO.File]::WriteAllLines($pref, @(
    "OCD_TRAVAS=$travas", "OCD_PERFIL=assinatura",
    "OCD_PADRAO_ASSINATURA=gpt-6.2-sol",
    "OCD_PADRAO_OPENROUTER=anthropic/claude-sonnet-5.5",
    "OCD_PADRAO_LOCAL=$local"), $utf8)
  Passo "preferencias: $pref"
}
Passo "use: powershell -File $Raiz\bin\ocd.ps1 doctor"
& (Join-Path $Raiz "bin\ocd.ps1") doctor
Write-Host ""
Write-Host "Falta so o login da assinatura (interativo): opencode auth login openai"
