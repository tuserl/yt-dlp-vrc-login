# Create ytnew folder if it doesn't exist
$ytNewDir = "ytnew"
if (-not (Test-Path $ytNewDir)) {
    New-Item -ItemType Directory -Path $ytNewDir
}

# Change into ytnew directory
Set-Location $ytNewDir

# Clone the yt-dlp repository
git clone https://github.com/yt-dlp/yt-dlp

# Change into the cloned repo
Set-Location ".\yt-dlp"

# Copy custom __main__.py into place
$sourceMain = "..\..\..\yt_dlp\__main__.py"
$targetMain = ".\yt_dlp\__main__.py"
Copy-Item -Path $sourceMain -Destination $targetMain -Force



# Try to find a working python command
if (Get-Command python3 -ErrorAction SilentlyContinue) {
    $python = "python3"
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $python = "python"
} else {
    Write-Error "Python is not installed or not found in PATH."
    exit 1
}

# Example usage
#& $python --version
#& $python -c "print('Hello from dynamic python!')"

& $python devscripts/install_deps.py --include pyinstaller
& $python devscripts/make_lazy_extractors.py
& $python -m bundle.pyinstaller


# Install dependencies including pyinstaller
#python3 devscripts\install_deps.py --include pyinstaller

# Generate lazy extractors
#python3 devscripts\make_lazy_extractors.py

# Build the executable
#python3 -m bundle.pyinstaller

# Move the built executable to the parent ytnew folder
Move-Item ".\dist\yt-dlp.exe" "..\"

