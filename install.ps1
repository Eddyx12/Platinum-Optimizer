# Platinum+ Optimizer - Installer Launcher
# Executed via: irm https://platinum.optimizer.workers.dev/program | iex

# ── Step 1: If not STA, relaunch this same script in STA mode with bypass ──────
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne [System.Threading.ApartmentState]::STA) {
    $tempLauncher = Join-Path $env:TEMP "PlatinumLauncher.ps1"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $cb = Get-Random
    $scriptContent = Invoke-RestMethod -Uri "https://platinum.optimizer.workers.dev/program.ps1?v=$cb" -UseBasicParsing
    Set-Content -Path $tempLauncher -Value $scriptContent -Encoding UTF8 -Force
    Start-Process powershell.exe -ArgumentList "-sta -NoProfile -ExecutionPolicy Bypass -File `"$tempLauncher`"" -WindowStyle Normal
    return
}

# ── Step 2 (already STA): Download assets and real installer, then launch ──────
$ErrorActionPreference = "Stop"
$baseUrl = "https://platinum.optimizer.workers.dev"
$cacheRoot = Join-Path $env:TEMP "PlatinumInstallerCache"

Write-Host "Platinum+ Optimizer - Downloading installer..." -ForegroundColor Cyan

try {
    # Clean old cache to prevent stale files
    Remove-Item -Path $cacheRoot -Recurse -Force -ErrorAction SilentlyContinue
    
    # Create cache directories
    $xamlDir  = Join-Path $cacheRoot "XAML"
    $icoDir   = Join-Path $cacheRoot "ico"
    foreach ($d in @($cacheRoot, $xamlDir, $icoDir)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $cb = Get-Random
    # Download GUI assets with cache buster
    Write-Host "Downloading installer assets to cache..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "$baseUrl/program/installer/XAML/installer.xaml?v=$cb"   -OutFile "$xamlDir\installer.xaml"   -UseBasicParsing
    Invoke-WebRequest -Uri "$baseUrl/program/installer/ico/logo.png?v=$cb"           -OutFile "$icoDir\logo.png"           -UseBasicParsing -ErrorAction SilentlyContinue
    Invoke-WebRequest -Uri "$baseUrl/program/installer/ico/platinum.png?v=$cb"       -OutFile "$icoDir\platinum.png"       -UseBasicParsing -ErrorAction SilentlyContinue

    # Download the real installer script
    $realInstaller = Join-Path $cacheRoot "installer_main.ps1"
    Write-Host "Downloading main installer script..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "$baseUrl/program/installer/install.ps1?v=$cb" -OutFile $realInstaller -UseBasicParsing

    # Run the real installer (already in STA, already bypassed)
    Write-Host "Launching installer..." -ForegroundColor Green
    & $realInstaller

} catch {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Failed to download installer:`n$_`n`nMake sure you have an active internet connection and try again.",
        "Platinum+ Installer Error", "OK", "Error"
    )
}