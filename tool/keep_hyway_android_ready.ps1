[CmdletBinding()]
param(
    [ValidateRange(1, 60)]
    [int]$PollSeconds = 2
)

$ErrorActionPreference = 'Stop'
$workspacePath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backendPath = Join-Path $workspacePath 'backend'
$backendEntry = Join-Path $backendPath 'dist\src\main.js'
$runtimePath = Join-Path $workspacePath '.runtime'
$logPath = Join-Path $runtimePath 'hyway-dev-bridge.log'
$healthUrl = 'http://127.0.0.1:3000/api/v1/health'
$lastBackendStart = [datetime]::MinValue
$readyDevices = @{}
$lastAdbError = $null

New-Item -ItemType Directory -Path $runtimePath -Force | Out-Null

function Write-BridgeLog {
    param([string]$Message)

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -LiteralPath $logPath -Value "[$timestamp] $Message"
}

function Test-HywayApi {
    try {
        $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 2
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

function Get-NodePath {
    $nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($nodeCommand) {
        return $nodeCommand.Source
    }

    return Join-Path $env:ProgramFiles 'nodejs\node.exe'
}

function Get-AdbPath {
    $adbCommand = Get-Command adb.exe -ErrorAction SilentlyContinue
    if ($adbCommand) {
        return $adbCommand.Source
    }

    return Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
}

function Ensure-HywayBackend {
    if (Test-HywayApi) {
        return
    }

    if (((Get-Date) - $lastBackendStart).TotalSeconds -lt 15) {
        return
    }

    $script:lastBackendStart = Get-Date
    $nodePath = Get-NodePath
    if (-not (Test-Path -LiteralPath $backendEntry)) {
        Write-BridgeLog "Backend build missing: $backendEntry"
        return
    }
    if (-not (Test-Path -LiteralPath $nodePath)) {
        Write-BridgeLog "Node.js missing: $nodePath"
        return
    }

    try {
        Start-Process `
            -FilePath $nodePath `
            -ArgumentList 'dist/src/main.js' `
            -WorkingDirectory $backendPath `
            -WindowStyle Hidden
        Write-BridgeLog 'Backend start requested.'
    }
    catch {
        Write-BridgeLog "Backend start failed: $($_.Exception.Message)"
    }
}

function Get-ConnectedDevices {
    param([string]$AdbPath)

    return @(
        (& $AdbPath devices 2>$null) |
            Where-Object { $_ -match '\sdevice$' } |
            ForEach-Object { ($_ -split '\s+')[0] }
    )
}

function Ensure-DeviceTunnel {
    param(
        [string]$AdbPath,
        [string]$DeviceId
    )

    $rules = (& $AdbPath -s $DeviceId reverse --list 2>$null) -join "`n"
    if ($rules -match 'tcp:3000\s+tcp:3000') {
        $readyDevices[$DeviceId] = $true
        return
    }

    & $AdbPath -s $DeviceId reverse tcp:3000 tcp:3000 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "adb reverse failed for $DeviceId"
    }

    $rules = (& $AdbPath -s $DeviceId reverse --list 2>$null) -join "`n"
    if ($rules -notmatch 'tcp:3000\s+tcp:3000') {
        throw "adb reverse verification failed for $DeviceId"
    }

    $readyDevices[$DeviceId] = $true
    Write-BridgeLog "Tunnel restored: $DeviceId tcp:3000 -> PC tcp:3000"
}

$adbPath = Get-AdbPath
if (-not (Test-Path -LiteralPath $adbPath)) {
    throw "Android adb was not found: $adbPath"
}

Write-BridgeLog 'HYWAY development bridge started.'

while ($true) {
    try {
        Ensure-HywayBackend
        & $adbPath start-server 2>$null | Out-Null
        $devices = @(Get-ConnectedDevices -AdbPath $adbPath)

        foreach ($knownDevice in @($readyDevices.Keys)) {
            if ($knownDevice -notin $devices) {
                $readyDevices.Remove($knownDevice)
                Write-BridgeLog "Device disconnected: $knownDevice"
            }
        }

        foreach ($device in $devices) {
            Ensure-DeviceTunnel -AdbPath $adbPath -DeviceId $device
        }

        $lastAdbError = $null
    }
    catch {
        $currentError = $_.Exception.Message
        if ($currentError -ne $lastAdbError) {
            Write-BridgeLog "Bridge check failed: $currentError"
            $lastAdbError = $currentError
        }
    }

    Start-Sleep -Seconds $PollSeconds
}
