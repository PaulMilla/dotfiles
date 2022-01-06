# Check if we're running in a window with Administrator privileges - needed to make hard links
# If not then create a new window and execute
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

function Mount-HomeDir($dstDir) {
    # TODO: These 2 functions could definitely be merged, but this works for now
    $files_src = Get-ChildItem -Recurse -File "$PSScriptRoot\home"
    $files_map = $files_src | Resolve-Path -Relative |% { @{ src = $_; dst = (Join-Path -Path $dstDir -ChildPath ($_ -replace "^.[\\\/]home[\\\/]","")) } }

    foreach ($file in $files_map) {
        $src = $file.src | Resolve-Path
        $dst = $file.dst
        New-Item -ItemType HardLink -Force -Path $dst -Target $src
    }
}

function Mount-PowerShellProfiles($dstDir) {
    # TODO: These 2 functions could definitely be merged, but this works for now
    $files_src = Get-ChildItem -Recurse -File "$PSScriptRoot\PowerShell_Profiles"
    $files_map = $files_src | Resolve-Path -Relative |% { @{ src = $_; dst = (Join-Path -Path $dstDir -ChildPath ($_ -replace "^.[\\\/]PowerShell_Profiles[\\\/]","")) } }

    foreach ($file in $files_map) {
        $src = $file.src | Resolve-Path
        $dst = $file.dst
        New-Item -ItemType HardLink -Force -Path $dst -Target $src
    }
}

function Mount-PowerShellProfilesOneDrive {
    $profile_src = Get-ChildItem -File "$PSScriptRoot\PowerShell_Profiles\Profile.ps1"
    $profile_dst = "$($HOME)\OneDrive - Microsoft\Documents\WindowsPowerShell\profile.ps1"
    New-Item -ItemType HardLink -Force -Path $profile_dst -Target $profile_src
}

function Mount-DotFiles() {
    ## PowerShell 5.X and below was windows-only and had its profile under 'WindowsPowerShell'
    ## PowerShell 6.X (core) and above changed profile dir to be just 'PowerShell'
    $profileDir = Split-Path -Parent (Split-Path -Parent $profile)
    $profileDir_ps5 = Join-Path $profileDir "WindowsPowerShell"
    $profileDir_ps6 = Join-Path $profileDir "PowerShell"

    Write-Host -ForegroundColor Yellow "Linking AppData directory..."
    & "$PSScriptRoot\AppData\Mount-AppData.ps1"

    Write-Host -ForegroundColor Yellow "`nLinking user home directory..."
    Mount-HomeDir -dstDir $HOME

    Write-Host -ForegroundColor Yellow "`nLinking PowerShell 5.X profiles..."
    Mount-PowerShellProfiles -dstDir $profileDir_ps5

    Write-Host -ForegroundColor Yellow "`nLinking PowerShell 6.X (core) profiles..."
    Mount-PowerShellProfiles -dstDir $profileDir_ps6

    Write-Host -ForegroundColor Yellow "`nLinking PowerShell OneDrive profiles..."
    Mount-PowerShellProfilesOneDrive
}

# Created function so as to not pollute global namespace
Push-Location $PSScriptRoot
Mount-DotFiles
Pop-Location

Write-Host "Press any key to exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null