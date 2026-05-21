# LabProject - Initialize React + Vite frontend (Windows host for hot reload)
$ErrorActionPreference = "Stop"
$frontend = "C:\LabProject\frontend"

if (Test-Path "$frontend\package.json") {
    Write-Host "Frontend already initialized. Running npm install..."
    Set-Location $frontend
    npm install
    exit 0
}

Write-Host "Installing frontend dependencies..." -ForegroundColor Cyan
Set-Location $frontend

# package.json is pre-scaffolded; install deps
npm install

Write-Host "Frontend ready. Run: npm run dev" -ForegroundColor Green
