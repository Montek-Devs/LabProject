# Stop LabProject services
. "$PSScriptRoot\lib\LabProject.ps1"

Write-Host "Stopping Docker..." -ForegroundColor Cyan
Invoke-LabDockerCompose -ComposeArgs @("down")

Write-Host "Stopping WSL bench (if running)..." -ForegroundColor Cyan
wsl -d $LabProjectWslDistro -e bash -lc "pkill -f 'bench start' 2>/dev/null || true"

Write-Host "Done. Close React/Vite terminal windows manually if still open." -ForegroundColor Green
