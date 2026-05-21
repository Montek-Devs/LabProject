# LabProject shared helpers (dot-source from other scripts)
$script:LabProjectRoot = "C:\LabProject"
$script:LabProjectWslDistro = "Ubuntu"

function Invoke-LabDockerCompose {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ComposeArgs,
        [string]$ComposeFile = "$script:LabProjectRoot\docker\docker-compose.yml"
    )
    $argLine = ($ComposeArgs -join " ")
    try {
        docker compose -f $ComposeFile @ComposeArgs 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { return }
    } catch {}

    wsl -d $script:LabProjectWslDistro -e bash -lc "cd /mnt/c/LabProject/docker && docker compose $argLine"
    if ($LASTEXITCODE -ne 0) {
        throw "docker compose failed: $argLine"
    }
}

function Test-LabDockerRunning {
    try {
        docker info 2>&1 | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Start-LabDockerDesktop {
    $paths = @(
        "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe",
        "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Start-Process $p -ErrorAction SilentlyContinue
            return $true
        }
    }
    return $false
}
