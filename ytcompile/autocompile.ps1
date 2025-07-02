# Save your Python path
.\save-python-path.ps1

# Read Python path from ytnew/python_path.txt
$pythonPathFile = ".\ytnew\python_path.txt"
if (-not (Test-Path $pythonPathFile)) {
    Write-Error "❌ $pythonPathFile not found. Please run save-python-path.ps1 first."
    exit 1
}

$python = Get-Content -Path $pythonPathFile -ErrorAction Stop

# Ensure ytnew folder exists
if (-not (Test-Path "ytnew")) {
    New-Item -ItemType Directory -Path "ytnew" | Out-Null
}

# Go into ytnew
Set-Location "ytnew"

# Clone yt-dlp if not already present
if (-not (Test-Path "yt-dlp")) {
    git clone https://github.com/yt-dlp/yt-dlp
} else {
    Write-Host "📁 yt-dlp folder already exists — skipping clone"
}

# Enter yt-dlp repo
Set-Location "yt-dlp"

# Copy custom __main__.py
Copy-Item "..\..\..\yt_dlp\__main__.py" "yt_dlp\__main__.py" -Force

# Run build steps
& $python devscripts\install_deps.py --include pyinstaller
& $python devscripts\make_lazy_extractors.py
& $python -m bundle.pyinstaller

# If build was successful, move .exe and test
if (Test-Path ".\dist\yt-dlp.exe") {
    Move-Item ".\dist\yt-dlp.exe" "..\"
    Write-Host "✅ yt-dlp.exe moved to ytnew"

    # Go back to ytnew folder
    Set-Location ".."

    # Run the built exe
    Write-Host "`n🚀 Running yt-dlp.exe to test:"
    .\yt-dlp.exe --version

    # Remove log folder if it exists
    $logFolder = "yt_dlp_argv_log"
    if (Test-Path $logFolder) {
        Remove-Item -Recurse -Force $logFolder
        Write-Host "🧹 Removed folder: $logFolder"
    } else {
        Write-Host "ℹ️ No $logFolder to remove"
    }
} else {
    Write-Warning "❌ Build failed — yt-dlp.exe not found"
    exit 1
}

Set-Location ".."
.\makezip.ps1

