# Platinum+ Optimizer Setup Launcher
# This script launches the installer

$ErrorActionPreference = "Stop"

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installerPath = Join-Path $scriptDir "\program\installer\install.ps1"

# Check if installer exists
if (-not (Test-Path $installerPath)) {
    Write-Error "Installer not found at: $installerPath"
    exit 1
}

# Launch installer
Write-Host "Launching Platinum+ Optimizer Installer..." -ForegroundColor Cyan
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$installerPath`"" -WorkingDirectory $scriptDir
