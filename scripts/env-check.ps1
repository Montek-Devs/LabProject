# LabProject - Windows / WSL environment report
$path = "C:\LabProject\logs\env-check.txt"
New-Item -ItemType Directory -Force -Path "C:\LabProject\logs" | Out-Null
$sb = [System.Text.StringBuilder]::new()
function Add($s) { [void]$sb.AppendLine($s) }

Add "=== LabProject Environment Check ==="
Add "Date: $(Get-Date -Format o)"
Add ""
Add "=== OS ==="
Get-CimInstance Win32_OperatingSystem | ForEach-Object {
    Add "Caption: $($_.Caption)"
    Add "Version: $($_.Version)"
    Add "Build: $($_.BuildNumber)"
    Add "RAM GB: $([math]::Round($_.TotalVisibleMemorySize/1MB,2))"
}
Add ""
Add "=== Hyper-V / Virtualization ==="
try {
    Get-ComputerInfo | Select HyperVisorPresent, HyperVRequirementVMMonitorModeExtensionsEnabled | Format-List | Out-String | ForEach-Object { Add $_ }
} catch { Add "Get-ComputerInfo failed: $_" }
Add ""
Add "=== Tools ==="
foreach ($t in @("git","node","npm","docker","wsl","winget","yarn")) {
    Add "--- $t ---"
    if (Get-Command $t -EA SilentlyContinue) { & $t --version 2>&1 | ForEach-Object { Add $_ } }
    else { Add "(not in PATH)" }
}
Add ""
Add "=== WSL ==="
wsl --status 2>&1 | ForEach-Object { Add $_ }
wsl -l -v 2>&1 | ForEach-Object { Add $_ }
Add ""
Add "=== LabProject ==="
Add "Exists: $(Test-Path C:\LabProject)"
Add "whoami: $(whoami)"

$sb.ToString() | Set-Content $path -Encoding UTF8
Write-Host "Report saved: $path"
Get-Content $path
