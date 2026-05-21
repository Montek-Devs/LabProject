# LabProject - Start Docker data layer (MariaDB + Redis)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lib\LabProject.ps1"

Write-Host "Starting Docker services..." -ForegroundColor Cyan
Set-Location "$LabProjectRoot\docker"

if (-not (Test-LabDockerRunning)) {
    Write-Host "Starting Docker Desktop..."
    Start-LabDockerDesktop | Out-Null
    $retries = 36
    while ($retries -gt 0) {
        Start-Sleep -Seconds 5
        if (Test-LabDockerRunning) { break }
        $retries--
    }
}

if (-not (Test-LabDockerRunning)) {
    Write-Error "Docker is not running. Start Docker Desktop and re-run this script."
}

Invoke-LabDockerCompose -ComposeArgs @("up", "-d", "db", "redis-cache", "redis-queue")
Write-Host "Docker data services started." -ForegroundColor Green
Invoke-LabDockerCompose -ComposeArgs @("ps")
