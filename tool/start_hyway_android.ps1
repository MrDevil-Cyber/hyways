[CmdletBinding()]
param(
    [string]$DeviceId,
    [switch]$RunApp
)

$ErrorActionPreference = 'Stop'
$workspacePath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backendPath = Join-Path $workspacePath 'backend'
$backendEntry = Join-Path $backendPath 'dist\src\main.js'
$healthUrl = 'http://127.0.0.1:3000/api/v1/health'
$apiUrl = 'http://127.0.0.1:3000/api/v1'

function Test-HywayApi {
    try {
        $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 2
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

if (-not (Test-HywayApi)) {
    if (-not (Test-Path -LiteralPath $backendEntry)) {
        throw "Backend build missing: $backendEntry. Run the backend build first."
    }

    $nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue
    $nodePath = if ($nodeCommand) {
        $nodeCommand.Source
    }
    else {
        Join-Path $env:ProgramFiles 'nodejs\node.exe'
    }
    if (-not (Test-Path -LiteralPath $nodePath)) {
        throw 'Node.js was not found.'
    }

    Start-Process `
        -FilePath $nodePath `
        -ArgumentList 'dist/src/main.js' `
        -WorkingDirectory $backendPath `
        -WindowStyle Hidden

    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        if (Test-HywayApi) { break }
        Start-Sleep -Milliseconds 500
    }
    if (-not (Test-HywayApi)) {
        throw 'HYWAY backend did not become healthy on port 3000.'
    }
}

$adbCommand = Get-Command adb.exe -ErrorAction SilentlyContinue
$adbPath = if ($adbCommand) {
    $adbCommand.Source
}
else {
    Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools\adb.exe'
}
if (-not (Test-Path -LiteralPath $adbPath)) {
    throw 'Android adb was not found.'
}

& $adbPath start-server | Out-Null
$connectedDevices = @(
    (& $adbPath devices) |
        Where-Object { $_ -match '\sdevice$' } |
        ForEach-Object { ($_ -split '\s+')[0] }
)

if (-not $DeviceId) {
    if ($connectedDevices.Count -ne 1) {
        throw "Expected one Android device, found $($connectedDevices.Count). Pass -DeviceId explicitly."
    }
    $DeviceId = $connectedDevices[0]
}
elseif ($DeviceId -notin $connectedDevices) {
    throw "Android device '$DeviceId' is not connected and authorized."
}

& $adbPath -s $DeviceId reverse tcp:3000 tcp:3000 | Out-Null
$reverseRules = & $adbPath -s $DeviceId reverse --list
if ($reverseRules -notmatch 'tcp:3000\s+tcp:3000') {
    throw 'Could not create the Android-to-backend tcp:3000 tunnel.'
}

Write-Host "HYWAY backend healthy: $healthUrl" -ForegroundColor Green
Write-Host "Android tunnel ready: $DeviceId tcp:3000 -> PC tcp:3000" -ForegroundColor Green

if ($RunApp) {
    $flutterCommand = Get-Command flutter.bat -ErrorAction SilentlyContinue
    $flutterPath = if ($flutterCommand) {
        $flutterCommand.Source
    }
    else {
        'C:\flutter\bin\flutter.bat'
    }
    if (-not (Test-Path -LiteralPath $flutterPath)) {
        throw 'Flutter was not found.'
    }
    & $flutterPath run -d $DeviceId "--dart-define=API_BASE_URL=$apiUrl"
}
else {
    Write-Host 'Tunnel is ready. Use -RunApp to launch Flutter automatically.'
}
