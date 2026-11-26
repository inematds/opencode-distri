# ocd para Windows — mesmo contrato do bin/ocd (bash).  AINDA NÃO TESTADO EM WINDOWS REAL.
#   ocd.ps1 perfis | doctor | login
#   ocd.ps1 run [-Perfil assinatura|openrouter|local] [-Modelo p/m] [-Auto] [-Json] "prompt"
param(
  [Parameter(Position = 0)][string]$Cmd = "",
  [string]$Perfil = "",
  [string]$Modelo = "",
  [switch]$Auto,
  [switch]$Json,
  [Parameter(Position = 1, ValueFromRemainingArguments = $true)][string[]]$Prompt
)
$ErrorActionPreference = "Stop"
$Versao = "0.2.0"

$cfg = @{}
$pref = Join-Path $env:USERPROFILE ".config\opencode-distri\ocd.env"
if (Test-Path $pref) {
  foreach ($l in Get-Content $pref) { if ($l -match '^\s*([A-Z_]+)=(.*)$') { $cfg[$matches[1]] = $matches[2] } }
}
function Val($k, $padrao = "") {
  $e = [Environment]::GetEnvironmentVariable($k)
  if ($e) { return $e }; if ($cfg[$k]) { return $cfg[$k] }; return $padrao
}
$oc = Val "OPENCODE_BIN" ((Get-Command opencode -ErrorAction SilentlyContinue).Source)
$travas = (Val "OCD_TRAVAS" "1") -eq "1"

function ModeloDo($p) {
  switch ($p) {
    "assinatura" { "openai/" + (Val "OCD_MODELO_ASSINATURA" (Val "OCD_PADRAO_ASSINATURA")) }
    "openrouter" { "openrouter/" + (Val "OCD_MODELO_OPENROUTER" (Val "OCD_PADRAO_OPENROUTER")) }
    "local"      { "ollama/" + (Val "OCD_MODELO_LOCAL" (Val "OCD_PADRAO_LOCAL")) }
    default { throw "perfil desconhecido: $p" }
  }
}

switch ($Cmd) {
  "perfis" { foreach ($p in "assinatura","openrouter","local") { "{0,-11} {1}" -f $p, (ModeloDo $p) } }
  "login"  { "opencode auth login openai  -> 'Sign in with ChatGPT'. Assinatura Claude nao existe no opencode 2.x." }
  "doctor" {
    "ocd $Versao"
    if (-not $oc) { "X opencode nao achado"; exit 1 }
    "OK opencode: $oc ($(& $oc --version))"
    $dir = (& $oc debug paths config).Trim()
    if (Select-String -Quiet -Path (Join-Path $dir "opencode.jsonc") -Pattern "provider.use") { "OK config com trava: $dir\opencode.jsonc" } else { "X config ausente"; exit 1 }
    $free = (& $oc --standalone models 2>$null | Where-Object { $_ -like "opencode/*" }).Count
    if ($free -eq 0) { "OK modelos opencode/*-free bloqueados" } else { "X $free modelos opencode/* liberados"; exit 1 }
    "travas: $(if ($travas) {'ligadas'} else {'DESLIGADAS'})"
    foreach ($p in "assinatura","openrouter","local") { "{0,-11} {1}" -f $p, (ModeloDo $p) }
  }
  "run" {
    if (-not $Perfil) { $Perfil = Val "OCD_PERFIL" "assinatura" }
    if (-not $Modelo) { $Modelo = ModeloDo $Perfil }
    if ($Modelo.EndsWith("/")) { throw "perfil $Perfil sem modelo definido" }
    $texto = if ($Prompt) { $Prompt -join " " } else { [Console]::In.ReadToEnd() }
    if (-not $texto) { throw "prompt vazio" }
    if ($Perfil -eq "openrouter") {
      if ($travas -and -not $env:OCD_APROVADO_OPENROUTER) { throw "OpenRouter e API paga: defina OCD_APROVADO_OPENROUTER" }
      if (-not $env:OPENROUTER_API_KEY) { throw "defina OPENROUTER_API_KEY neste terminal" }
    }
    if ($Perfil -eq "local" -and $travas -and -not $env:APROVADO_MODELO_NEI) { throw "modelo local: defina APROVADO_MODELO_NEI" }
    $a = @("--standalone", "run", "--archived", "-m", $Modelo)
    if ($Auto) { $a += "--auto" }; if ($Json) { $a += @("--format", "json") }
    & $oc @a $texto
    exit $LASTEXITCODE
  }
  default { Get-Content $PSCommandPath -TotalCount 3 }
}
