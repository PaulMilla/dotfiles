function Mount-DotFiles() {
    ## PowerShell 5.X and below was windows-only and had its profile under 'WindowsPowerShell'
    ## PowerShell 6.X (core) and above changed profile dir to be just 'PowerShell'
    $profileDir = Split-Path -Parent (Split-Path -Parent $profile)
    $profileDir_ps5 = Join-Path $profileDir "WindowsPowerShell"
    $profileDir_ps6 = Join-Path $profileDir "PowerShell"

    New-Item $profileDir_ps5 -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item $profileDir_ps6 -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

    Copy-Item ".\home\**" -Recurse -Force -Destination $home
    Copy-Item ".\PowerShell_Profiles\**" -Destination $profileDir_ps5
    Copy-Item ".\PowerShell_Profiles\**" -Destination $profileDir_ps6

    & .\AppData\Mount-AppData.ps1
}

# Created function so as to not pollute global namespace
Push-Location $PSScriptRoot
Mount-DotFiles
Pop-Location