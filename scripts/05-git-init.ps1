# LabProject - Git initialization and GitHub remote
param(
    [string]$GitUserName = "LabProject Dev",
    [string]$GitUserEmail = "dev@labproject.local"
)

$ErrorActionPreference = "Stop"
Set-Location "C:\LabProject"

git config --global user.name $GitUserName
git config --global user.email $GitUserEmail
git config --global init.defaultBranch main

if (-not (Test-Path ".git")) {
    git init
}

if (-not (Test-Path "README.md")) {
    "# LabProject`n`nEnterprise Frappe + React development environment." | Out-File README.md -Encoding utf8
}

git add -A
$status = git status --porcelain
if ($status) {
    git commit -m "Initial LabProject scaffold: Frappe lab_core, React frontend, Docker, docs"
}

git branch -M main 2>$null

$remoteUrl = "https://github.com/Montek-Devs/LabProject.git"
$existing = git remote get-url origin 2>$null
if (-not $existing) {
    git remote add origin $remoteUrl
}

Write-Host "`nGit configured. To push (requires GitHub auth):" -ForegroundColor Yellow
Write-Host "  git push -u origin main"
Write-Host "`nOr with GitHub CLI: gh auth login && gh repo sync"
