#Requires -RunAsAdministrator
<#
.SYNOPSIS
    LabProject - Windows Server 2022 bootstrap (WSL2, Git, Node LTS, Docker, Yarn)
.DESCRIPTION
    Run once as Administrator in PowerShell:
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\scripts\01-setup-windows.ps1
#>
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

Write-Step "Validating Windows Server"
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "OS: $($os.Caption) $($os.Version) Build $($os.BuildNumber)"
$memGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
Write-Host "RAM: ${memGB} GB"
if ($memGB -lt 8) { Write-Warning "Minimum 8 GB RAM recommended for Frappe + Docker + React" }

Write-Step "Enabling Windows features (WSL, Virtual Machine Platform, Hyper-V)"
$features = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)
foreach ($f in $features) {
    $state = (Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue).State
    if ($state -ne "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -All | Out-Null
        Write-Host "Enabled: $f"
    } else {
        Write-Host "Already enabled: $f"
    }
}
# Hyper-V (Server may already have it)
if ((Get-WindowsOptionalFeature -Online -FeatureName Hyper-V -ErrorAction SilentlyContinue).State -ne "Enabled") {
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Hyper-V -NoRestart -All | Out-Null
    } catch {
        Write-Warning "Hyper-V enable skipped or requires reboot: $_"
    }
}

Write-Step "Installing winget packages"
$packages = @(
    @{ Id = "Git.Git"; Name = "Git" },
    @{ Id = "OpenJS.NodeJS.LTS"; Name = "Node.js LTS" },
    @{ Id = "Docker.DockerDesktop"; Name = "Docker Desktop" },
    @{ Id = "Yarn.Yarn"; Name = "Yarn" }
)
foreach ($pkg in $packages) {
    Write-Host "Installing $($pkg.Name)..."
    winget install --id $pkg.Id -e --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
}

Write-Step "Setting WSL2 as default"
wsl --set-default-version 2 2>&1 | Out-Null

Write-Step "Installing Ubuntu 24.04 LTS (if missing)"
$distros = wsl -l -q 2>&1
if ($distros -notmatch "Ubuntu") {
    wsl --install -d Ubuntu --no-launch
    Write-Host "Ubuntu installed. Reboot may be required, then complete Ubuntu user setup."
} else {
    Write-Host "Ubuntu already present."
}

Write-Step "Refreshing PATH"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Step "Creating project directories"
$dirs = @(
    "C:\LabProject\backend",
    "C:\LabProject\frontend",
    "C:\LabProject\apps",
    "C:\LabProject\docker",
    "C:\LabProject\docs",
    "C:\LabProject\scripts",
    "C:\LabProject\logs"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

Write-Host "`nWindows setup phase complete." -ForegroundColor Green
Write-Host "NEXT: Reboot if prompted, finish Ubuntu first-run (username/password), then run:"
Write-Host "  wsl -d Ubuntu bash /mnt/c/LabProject/scripts/02-setup-wsl.sh"
Write-Host "  .\scripts\03-setup-docker.ps1"
Write-Host "  .\scripts\04-init-frontend.ps1"
