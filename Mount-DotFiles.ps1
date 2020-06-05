function Mount-DotFiles() {
    $profileDir = Split-Path -Parent $profile
    New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

    Copy-Item ".\home\**" -Recurse -Force -Destination $home
    Copy-Item ".\PowerShell_Profiles\**" -Destination $profileDir

    & .\AppData\Mount-AppData.ps1
}

# Created function so as to not pollute global namespace
Push-Location $PSScriptRoot
Mount-DotFiles
Pop-Location