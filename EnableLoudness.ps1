<#
.SYNOPSIS
    Automatically adds and enables loudness equalisation for Windows playback devices.
.DESCRIPTION
    Imports registry keys into FxProperties to activate Audio Processing Objects (APO)
    and enables Loudness Equalisation. Restarts audiosrv to apply changes immediately.
.LINK
    https://github.com/luiso198/enable-loudness-equalisation
.PARAMETER playbackDeviceName
    Device name, interface name, or GUID substring to match against active playback devices.
.PARAMETER maxDeviceCount
    Maximum number of matching active devices to configure (default: 2).
.PARAMETER releaseTime
    Equalisation release time value from 2 (fastest, ideal for gaming) to 7 (slowest). Default: 4.
.PARAMETER ListDevices
    Lists all active playback devices and their current Loudness Equalisation status.
.PARAMETER Quiet
    Suppresses graphical error message boxes and logs errors to console only.
.EXAMPLE
    .\EnableLoudness.ps1 -playbackDeviceName "Altavoces"
.EXAMPLE
    .\EnableLoudness.ps1 -ListDevices
.EXAMPLE
    .\EnableLoudness.ps1 -playbackDeviceName "G432" -releaseTime 2
#>

[CmdletBinding()]
Param(
    [Parameter(Position=0)]
    [ValidateLength(1, 100)]
    [string]$playbackDeviceName,
    
    [ValidateRange(1, 10)]
    [int]$maxDeviceCount = 2,

    [ValidateRange(2, 7)]
    [int]$releaseTime = 4,

    [switch]$ListDevices,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$regBasePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
$enhancementFlagKey = "{fc52a749-4be9-4510-896e-966ba6525980},3"
$releaseTimeKey     = "{9c00eeed-edce-4cd8-ae08-cb05e8ef57a0},3"
$enhancementTabKey  = "{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},3"
$enhancementTabValue = "{5860E1C5-F95C-4a7a-8EC8-8AEF24F379A1}"
$friendlyNameKey    = "{a45c254e-df1c-4efd-8020-67d146a850e0},2"
$interfaceNameKey   = "{b3f8fa53-0004-438e-9003-51a46e139bfc},6"

function Exit-WithErrorMsg ([String]$msg) {
    if (-not $Quiet) {
        try {
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
            [void][System.Windows.Forms.MessageBox]::Show($msg, "Enable Loudness Equalisation",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error)
        } catch {}
    }
    Write-Error $msg
    exit 1
}

function Get-ActiveRenderDevices {
    $deviceKeys = Get-ChildItem $regBasePath -ErrorAction SilentlyContinue
    if (-not $deviceKeys -or $deviceKeys.Count -eq 0) {
        Exit-WithErrorMsg "Cannot access audio devices in registry. Please run as Administrator."
    }

    $results = @()
    foreach ($dev in $deviceKeys) {
        $parentProp = Get-ItemProperty $dev.PSPath -ErrorAction SilentlyContinue
        if ($parentProp -and $parentProp.DeviceState -eq 1) {
            $propsPath = Join-Path $dev.PSPath "Properties"
            $props = Get-ItemProperty $propsPath -ErrorAction SilentlyContinue
            $friendly = if ($props -and $props.$friendlyNameKey) { $props.$friendlyNameKey } else { "Unknown" }
            $interface = if ($props -and $props.$interfaceNameKey) { $props.$interfaceNameKey } else { "" }
            
            $fxPath = Join-Path $dev.PSPath "FxProperties"
            $fxProps = Get-ItemProperty $fxPath -ErrorAction SilentlyContinue
            $status = "Not Configured"
            if ($fxProps -and $fxProps.$enhancementFlagKey) {
                $val = $fxProps.$enhancementFlagKey
                if ($val.Length -ge 10 -and $val[8] -eq 255 -and $val[9] -eq 255) {
                    $status = "Enabled"
                } else {
                    $status = "Disabled"
                }
            }

            $results += [PSCustomObject]@{
                DeviceId     = $dev.PSChildName
                FriendlyName = $friendly
                Interface    = $interface
                Status       = $status
                PSPath       = $dev.PSPath
            }
        }
    }
    return $results
}

# Handle -ListDevices switch
if ($ListDevices) {
    $active = Get-ActiveRenderDevices
    if ($active.Count -eq 0) {
        Write-Host "No active playback devices found." -ForegroundColor Yellow
    } else {
        Write-Host "`n=== Active Playback Devices ===" -ForegroundColor Cyan
        $active | Format-Table -Property FriendlyName, Interface, Status, DeviceId -AutoSize
    }
    exit 0
}

# Auto-detect device name if not supplied
$allActive = Get-ActiveRenderDevices
if ([string]::IsNullOrWhiteSpace($playbackDeviceName)) {
    if ($allActive.Count -eq 1) {
        $playbackDeviceName = $allActive[0].FriendlyName
        Write-Host "Auto-selected single active device: '$playbackDeviceName'" -ForegroundColor Cyan
    } else {
        Write-Host "Available active devices:`n" -ForegroundColor Yellow
        for ($i = 0; $i -lt $allActive.Count; $i++) {
            $num = $i + 1
            $name = $allActive[$i].FriendlyName
            $iface = $allActive[$i].Interface
            $status = $allActive[$i].Status
            Write-Host "  [$num] $name ($iface) - Status: $status" -ForegroundColor Cyan
        }
        Write-Host ""
        if ($Quiet) {
            Exit-WithErrorMsg "Parameter -playbackDeviceName is required when multiple active devices exist."
        }
        $selection = Read-Host "Ingresa el número (1-$($allActive.Count)) o nombre del dispositivo a configurar"
        if ([string]::IsNullOrWhiteSpace($selection)) {
            Exit-WithErrorMsg "No se seleccionó ningún dispositivo. Operación cancelada."
        }
        if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $allActive.Count) {
            $playbackDeviceName = $allActive[[int]$selection - 1].FriendlyName
        } else {
            $playbackDeviceName = $selection.Trim()
        }
    }
}

# Find matching active devices safely (case-insensitive substring, escaped regex)
$escapedPattern = [regex]::Escape($playbackDeviceName)
$matchedDevices = @($allActive | Where-Object {
    $_.FriendlyName -match $escapedPattern -or
    $_.Interface -match $escapedPattern -or
    $_.DeviceId -match $escapedPattern
})

if ($matchedDevices.Count -lt 1) {
    Exit-WithErrorMsg "Could not find any active playback device matching '$playbackDeviceName'."
}

if ($matchedDevices.Count -gt $maxDeviceCount) {
    Exit-WithErrorMsg "Execution aborted: $($matchedDevices.Count) active devices matched '$playbackDeviceName', exceeding maximum allowed ($maxDeviceCount)."
}

# Check Administrator privileges before modifying registry
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrative privileges..." -ForegroundColor Yellow
    $scriptPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Definition }
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -playbackDeviceName `"$playbackDeviceName`" -maxDeviceCount $maxDeviceCount -releaseTime $releaseTime"
    if ($Quiet) { $argList += " -Quiet" }
    
    $proc = Start-Process powershell -Verb RunAs -ArgumentList $argList -PassThru -Wait
    exit $proc.ExitCode
}

# Build registry configuration
$regFile = Join-Path $env:TEMP "SoundEnhancementsTMP_$([guid]::NewGuid().ToString('N')).reg"
$releaseTimeStr = $releaseTime.ToString().PadLeft(2, '0')
$fxPropertiesImport = @"
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},1"="{62dc1a93-ae24-464c-a43e-452f824c4250}"
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},2"="{637c490d-eee3-4c0a-973f-371958802da2}"
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},3"="{5860E1C5-F95C-4a7a-8EC8-8AEF24F379A1}"
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},5"="{62dc1a93-ae24-464c-a43e-452f824c4250}"
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},6"="{637c490d-eee3-4c0a-973f-371958802da2}"
"{fc52a749-4be9-4510-896e-966ba6525980},3"=hex:0b,00,00,00,01,00,00,00,ff,ff,00,00
"{9c00eeed-edce-4cd8-ae08-cb05e8ef57a0},3"=hex:03,00,00,00,01,00,00,00,$releaseTimeStr,00,00,00
"@

$regContent = New-Object System.Text.StringBuilder
[void]$regContent.AppendLine("Windows Registry Editor Version 5.00")

$needsUpdate = $false
foreach ($dev in $matchedDevices) {
    $rawRegistryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\$($dev.DeviceId)\FxProperties"
    $fxProps = Get-ItemProperty "$($dev.PSPath)\FxProperties" -ErrorAction SilentlyContinue

    $alreadyConfigured = $false
    if ($fxProps -and $fxProps.$enhancementFlagKey -and $fxProps.$releaseTimeKey -and $fxProps.$enhancementTabKey) {
        $flag = $fxProps.$enhancementFlagKey
        $rt   = $fxProps.$releaseTimeKey
        $tab  = $fxProps.$enhancementTabKey
        if ($flag.Length -ge 10 -and $flag[8] -eq 255 -and $flag[9] -eq 255 -and
            $rt.Length -ge 9 -and $rt[8] -eq $releaseTime -and
            $tab -eq $enhancementTabValue) {
            $alreadyConfigured = $true
        }
    }

    if (-not $alreadyConfigured) {
        $needsUpdate = $true
        [void]$regContent.AppendLine("[$rawRegistryPath]")
        [void]$regContent.AppendLine($fxPropertiesImport)
        Write-Host "Configuring Loudness Equalisation for: $($dev.FriendlyName) ($($dev.DeviceId))" -ForegroundColor Green
    } else {
        Write-Host "Loudness Equalisation is already enabled with release time $releaseTime for: $($dev.FriendlyName)" -ForegroundColor Cyan
    }
}

if (-not $needsUpdate) {
    Write-Host "No changes required. All matching devices are already properly configured." -ForegroundColor Green
    exit 0
}

try {
    # Write REG file with UTF8 encoding
    [System.IO.File]::WriteAllText($regFile, $regContent.ToString(), [System.Text.Encoding]::UTF8)

    Write-Host "Importing registry enhancements..." -ForegroundColor Cyan
    $regProc = Start-Process -FilePath "$env:SystemRoot\regedit.exe" -ArgumentList "/s `"$regFile`"" -PassThru -Wait
    if ($regProc.ExitCode -ne 0) {
        Exit-WithErrorMsg "Failed to import registry settings (ExitCode: $($regProc.ExitCode))."
    }

    Write-Host "Restarting Windows Audio Service (audiosrv)..." -ForegroundColor Cyan
    Restart-Service -Name audiosrv -Force
    Write-Host "Loudness Equalisation successfully enabled!" -ForegroundColor Green
}
finally {
    if (Test-Path $regFile) {
        Remove-Item -Path $regFile -Force -ErrorAction SilentlyContinue
    }
}
