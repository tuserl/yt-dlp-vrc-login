#this basically setintegritylevel medium for permission issue and readonly to protect the yt-dlp.exe

# Replace "C:\Users\Username\Downloads\yt-dlp.exe" with the path to a known working copy of yt-dlp:
$PathToGoodYtDlp = "C:\Users\Username\Downloads\yt-dlp.exe"
Remove-Item -Path "$env:APPDATA\..\LocalLow\VRChat\VRChat\Tools\yt-dlp.exe" -Force
Copy-Item -Path $PathToGoodYtDlp -Destination "$env:APPDATA\..\LocalLow\VRChat\VRChat\Tools\yt-dlp.exe"
Set-ItemProperty -Path "$env:APPDATA\..\LocalLow\VRChat\VRChat\Tools\yt-dlp.exe" -Name IsReadOnly -Value $true
icacls "$env:APPDATA\..\LocalLow\VRChat\VRChat\Tools\yt-dlp.exe" /setintegritylevel medium
#or
icacls "C:\Users\phamh\AppData\LocalLow\VRChat" /setintegritylevel M /t
