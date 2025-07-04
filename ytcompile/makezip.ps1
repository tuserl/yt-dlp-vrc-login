# Output folder and zip file name
$zipFolder = "yt-dlp-vrc-login-zip"
$zipFile = "ytnew/yt-dlp-vrc-login.zip"

# Paths
$sourceExe = "ytnew\yt-dlp.exe"
$targetExeDir = Join-Path $zipFolder "ytnew"
$targetExe = Join-Path $targetExeDir "yt-dlp.exe"

# Step 1: Clean old staging folder if exists
if (Test-Path $zipFolder) {
    Remove-Item -Recurse -Force $zipFolder
}

# Step 2: Create folder structure
New-Item -ItemType Directory -Path $targetExeDir -Force | Out-Null

# Step 3: Copy main script
Copy-Item -Path "automovefiletovrc.ps1" -Destination $zipFolder -Force

# Step 4: Copy manual.txt as README.txt
if (Test-Path "manual.txt") {
    Copy-Item -Path "manual.txt" -Destination (Join-Path $zipFolder "README.txt") -Force
} else {
    Write-Warning "⚠️ manual.txt not found. Skipping README.txt"
}

# Step 5: Copy yt-dlp.exe into ytnew/
if (Test-Path $sourceExe) {
    Copy-Item -Path $sourceExe -Destination $targetExe -Force
} else {
    Write-Error "❌ File not found: $sourceExe"
    exit 1
}

# Step 6: Remove old zip if exists
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# Step 7: Create zip archive inside ytnew/
Compress-Archive -Path "$zipFolder\*" -DestinationPath $zipFile
Write-Host "✅ Created zip: $zipFile"

# Step 8: Delete temp folder
Remove-Item -Recurse -Force $zipFolder
Write-Host "🧹 Deleted temp folder: $zipFolder"

