$toolsDir = "$env:APPDATA\..\LocalLow\VRChat\VRChat\Tools"
$oldPath = Join-Path $toolsDir "yt-dlp.exe"
$bakBase = "$oldPath.bak"
$configPath = Join-Path $toolsDir "yt-dlp.conf"

# Function to find next available numbered backup
function Get-NextBackupName($base) {
    $i = 1
    $candidate = "$base.$i"
    while (Test-Path $candidate) {
        $i++
        $candidate = "$base.$i"
    }
    return $candidate
}

# Step 1: Backup yt-dlp.exe safely
if (Test-Path $oldPath) {
    if (Test-Path $bakBase) {
        $nextBak = Get-NextBackupName $bakBase
        Rename-Item -Path $bakBase -NewName ([System.IO.Path]::GetFileName($nextBak)) -Force
        Write-Host "📦 Existing yt-dlp.exe.bak renamed to: $nextBak"
    }

    Move-Item -Path $oldPath -Destination $bakBase -Force
    Write-Host "🧳 Backed up yt-dlp.exe to: $bakBase"
} else {
    Write-Host "ℹ️ No existing yt-dlp.exe to rename"
}

# Step 2: Restore backup as yt-dlp.exe
if (Test-Path $bakBase) {
    Copy-Item -Path $bakBase -Destination $oldPath -Force
    Write-Host "🔁 Copied backup back to yt-dlp.exe"
} else {
    Write-Warning "❌ Backup file not found: $bakBase"
}

# Step 3: Set yt-dlp.exe to read-only and set integrity level
Set-ItemProperty -Path $oldPath -Name IsReadOnly -Value $true
icacls $oldPath /setintegritylevel medium | Out-Null

# Step 4: Create yt-dlp.conf with Firefox cookie support
$confLine = "--cookies-from-browser firefox"
Set-Content -Path $configPath -Value $confLine -Force
Write-Host "📝 Created yt-dlp.conf with: $confLine"

# Step 5: Make yt-dlp.conf read-only
Set-ItemProperty -Path $configPath -Name IsReadOnly -Value $true
Write-Host "🔒 Set yt-dlp.conf to read-only"

