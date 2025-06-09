[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function to download files safely
function Download-File {
    param (
        [string]$url,
        [string]$destination
    )
    if (!(Test-Path $destination)) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $destination -ErrorAction Stop
        } catch {
            Write-Host "Failed to download $url" -ForegroundColor Red
            exit 1
        }
    }
}

# Ensure Tools directory exists
$ToolsDirectory = "C:\Tools"
if (!(Test-Path $ToolsDirectory)) {
    New-Item -Path $ToolsDirectory -ItemType Directory
}

# SYSMON Setup
$SysmonDirectory = "$ToolsDirectory\Sysmon"
$SysmonLocalZip = "$ToolsDirectory\Sysmon.zip"
$SysmonURL = "https://download.sysinternals.com/files/Sysmon.zip"

Download-File -url $SysmonURL -destination $SysmonLocalZip

if (!(Test-Path $SysmonDirectory)) {
    New-Item -Path $SysmonDirectory -ItemType Directory
    Expand-Archive -LiteralPath $SysmonLocalZip -DestinationPath $SysmonDirectory -Force
}

# Download Sysmon Config
$SysmonLocalConfig = "$SysmonDirectory\sysmon-config.xml"
$SysmonConfigURL = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
Download-File -url $SysmonConfigURL -destination $SysmonLocalConfig

# Install and Start Sysmon
$SysmonExe = "$SysmonDirectory\Sysmon.exe"
if (Test-Path $SysmonExe) {
    if (!(Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue)) {
        & $SysmonExe -i $SysmonLocalConfig -accepteula
    }
}

# SILK SERVICE Setup
$SilkServiceURL = "https://github.com/fireeye/SilkETW/releases/download/v0.8/SilkETW_SilkService_v8.zip"
$SilkServiceLocalZip = "$ToolsDirectory\SilkService.zip"
$SilkServiceDirectory = "$ToolsDirectory\SilkService"
Download-File -url $SilkServiceURL -destination $SilkServiceLocalZip

if (!(Test-Path $SilkServiceDirectory)) {
    Expand-Archive -LiteralPath $SilkServiceLocalZip -DestinationPath $SilkServiceDirectory -Force
}

$DotNetInstaller = "$SilkServiceDirectory\v8\Dependencies\dotNetFx45_Full_setup.exe"
$vc2015Installer = "$SilkServiceDirectory\v8\Dependencies\vc2015_redist.x86.exe"

if (Test-Path $DotNetInstaller) { & $DotNetInstaller /SILENT }
if (Test-Path $vc2015Installer) { & $vc2015Installer /SILENT }

# Create SilkService if not exists
if (!(Get-Service -Name "SilkService" -ErrorAction SilentlyContinue)) {
    New-Service -Name "SilkService" -BinaryPathName "$SilkServiceDirectory\v8\SilkService\SilkService.exe" -StartupType Automatic -Description "SilkETW Service"
}

# WINLOGBEAT Setup
$WinlogbeatDirectory = "$ToolsDirectory\Winlogbeat"
$WinlogbeatLocalZip = "$ToolsDirectory\Winlogbeat.zip"
$WinlogbeatURL = "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.6.2-windows-x86_64.zip"

Download-File -url $WinlogbeatURL -destination $WinlogbeatLocalZip

if (!(Test-Path $WinlogbeatDirectory)) {
    Expand-Archive -LiteralPath $WinlogbeatLocalZip -DestinationPath $WinlogbeatDirectory -Force
    Move-Item -Path "$WinlogbeatDirectory\winlogbeat-7.6.2-windows-x86_64" -Destination "C:\Program Files\Winlogbeat" -Force
}

$WinlogbeatLocalConfigLocation = "C:\Program Files\Winlogbeat\winlogbeat-7.6.2-windows-x86_64\winlogbeat.yml"
$HELK_IP = $env:HELK_IP

$WinlogbeatConfig = @"
winlogbeat.event_logs:
  - name: Application
    ignore_older: 30m
  - name: Security
    ignore_older: 30m
  - name: System
    ignore_older: 30m
output.kafka:
  hosts: ["$HELK_IP:9092"]
"@

Set-Content -Path $WinlogbeatLocalConfigLocation -Value $WinlogbeatConfig

# Install Winlogbeat service
Push-Location "C:\Program Files\Winlogbeat"
.\install-service-winlogbeat.ps1
Pop-Location
Start-Service Winlogbeat
