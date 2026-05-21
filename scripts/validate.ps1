# LabProject - Environment validation
$ErrorActionPreference = "Continue"
$results = @()

function Test-Check($name, $script) {
    try {
        $ok = & $script
        $results += [PSCustomObject]@{ Check = $name; Status = if ($ok) { "PASS" } else { "FAIL" } }
    } catch {
        $results += [PSCustomObject]@{ Check = $name; Status = "FAIL" }
    }
}

Test-Check "Git installed" { [bool](Get-Command git -EA SilentlyContinue) }
Test-Check "Node installed" { [bool](Get-Command node -EA SilentlyContinue) }
Test-Check "Docker installed" { [bool](Get-Command docker -EA SilentlyContinue) }
Test-Check "WSL installed" { [bool](Get-Command wsl -EA SilentlyContinue) }
Test-Check "C:\LabProject exists" { Test-Path "C:\LabProject" }
Test-Check "docker-compose.yml" { Test-Path "C:\LabProject\docker\docker-compose.yml" }
Test-Check "lab_core app" { Test-Path "C:\LabProject\apps\lab_core" }
Test-Check "frontend package.json" { Test-Path "C:\LabProject\frontend\package.json" }

. "$PSScriptRoot\lib\LabProject.ps1"
$dockerUp = $false
try {
    Invoke-LabDockerCompose -ComposeArgs @("ps") 2>&1 | Out-Null
    $dockerUp = $LASTEXITCODE -eq 0
} catch { $dockerUp = $false }
$results += [PSCustomObject]@{ Check = "Docker compose"; Status = if ($dockerUp) { "PASS" } else { "SKIP/FAIL" } }

try {
    $ping = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/method/lab_core.api.ping" -UseBasicParsing -TimeoutSec 5
    $apiOk = $ping.StatusCode -eq 200
} catch { $apiOk = $false }
$results += [PSCustomObject]@{ Check = "Frappe API ping"; Status = if ($apiOk) { "PASS" } else { "SKIP (start bench)" } }

try {
    $vite = Invoke-WebRequest -Uri "http://127.0.0.1:5173" -UseBasicParsing -TimeoutSec 3
    $reactOk = $vite.StatusCode -eq 200
} catch { $reactOk = $false }
$results += [PSCustomObject]@{ Check = "React dev server"; Status = if ($reactOk) { "PASS" } else { "SKIP (npm run dev)" } }

$results | Format-Table -AutoSize
Write-Host "Run scripts\start-dev.ps1 if services are not up." -ForegroundColor Yellow
