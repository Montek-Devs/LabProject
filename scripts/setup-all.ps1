# LabProject - Master setup orchestrator (run as Administrator)
# Usage: Set-ExecutionPolicy Bypass -Scope Process -Force; .\scripts\setup-all.ps1
param(
    [switch]$SkipWindowsFeatures,
    [switch]$SkipWsl,
    [switch]$SkipFrontend
)

$ErrorActionPreference = "Stop"
$root = "C:\LabProject"
Set-Location $root

Write-Host @"

╔══════════════════════════════════════════════════════════╗
║  LabProject - Enterprise Dev Environment Setup           ║
║  Windows Server 2022 + WSL2 + Docker + Frappe + React    ║
╚══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

if (-not $SkipWindowsFeatures) {
    & "$root\scripts\01-setup-windows.ps1"
}

& "$root\scripts\03-setup-docker.ps1"

if (-not $SkipWsl) {
    Write-Host "`nRunning WSL setup (may take 15-30 min on first run)..." -ForegroundColor Cyan
    wsl -d Ubuntu -e bash -lc "chmod +x /mnt/c/LabProject/scripts/*.sh && /mnt/c/LabProject/scripts/02-setup-wsl.sh"
}

if (-not $SkipFrontend) {
    & "$root\scripts\04-init-frontend.ps1"
}

& "$root\scripts\05-git-init.ps1"

Write-Host @"

╔══════════════════════════════════════════════════════════╗
║  Setup complete - see README.md for start commands       ║
╚══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green
