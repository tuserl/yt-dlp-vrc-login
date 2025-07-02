# save-python-path.ps1

$ytnew = "ytnew"

# Create ytnew folder if it doesn't exist
if (-not (Test-Path $ytnew)) {
    New-Item -ItemType Directory -Path $ytnew | Out-Null
}

# Try to detect the full path of 'python'
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue

if ($pythonCmd) {
    $pythonPath = $pythonCmd.Source
    Set-Content -Path "$ytnew\python_path.txt" -Value $pythonPath
    Write-Host "✅ Python path saved to $ytnew\python_path.txt:`n$pythonPath"
} else {
    Write-Error "❌ Python not found in PATH"
    exit 1
}

