# Start LabProject development environment
$ErrorActionPreference = "Stop"
$root = "C:\LabProject"
. "$PSScriptRoot\lib\LabProject.ps1"

Write-Host "Starting Docker data layer..." -ForegroundColor Cyan
Invoke-LabDockerCompose -ComposeArgs @("up", "-d", "db", "redis-cache", "redis-queue")

Start-Sleep -Seconds 8

Write-Host "Starting Frappe (WSL bench)..." -ForegroundColor Cyan
Start-Process wsl -ArgumentList "-d", "Ubuntu", "-e", "bash", "-lc", "cd /mnt/c/LabProject/backend/frappe-bench && bench start" -WindowStyle Normal

Start-Sleep -Seconds 3

Write-Host "Starting React (Vite)..." -ForegroundColor Cyan
Set-Location "$root\frontend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$root\frontend'; npm run dev" -WindowStyle Normal

Write-Host @"

LabProject started:
  Frappe Desk : http://127.0.0.1:8000  (Administrator / admin)
  React App   : http://127.0.0.1:5173
  API Ping    : http://127.0.0.1:8000/api/method/lab_core.api.ping

"@ -ForegroundColor Green
