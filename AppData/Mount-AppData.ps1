# Check if we're running in a window with Administrator privileges
# Though we shouldn't need this as long as we're only creating links in user-writable locations and developer mode is turned on in windows
# If not then create a new window and execute
function Test-Elevated() {
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
    # Relaunch as an elevated process:
    Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
    }
}
function Mount-AppData() {
    # AppData
    #########

    ## Settings/Configs for files that are app-specific
    ## Typically stored under the user's AppData Directory in Windows, but might not always be the case
    ## We'll install each app explicitly and define the path for windows, osx, and linux

    ## Best guess at different appData locations across different OS
    $appData_roaming = if ($IsLinux) { Get-Item "$home/.config/" } `
                      elseif ($IsMacOS) { Get-Item "$home/Library/Application Support/" } `
                      else { Get-Item $env:APPDATA }

    $appData_local = if ($IsLinux) { Get-Item "$home/.config/" } `
                      elseif ($IsMacOS) { Get-Item "$home/Library/Application Support/" } `
                      else { Get-Item "$env:APPDATA\..\Local" }

    ## Visual Studio Code
    ## https://vscode.readthedocs.io/en/latest/getstarted/settings/#settings-file-locations
    ## Removing for now since VS Code has it's own way of syncing settings files
    #New-Item -ItemType HardLink -Force -Path "$appData_roaming\Code\User\keybindings.json" -Target "$PSScriptRoot\Code\User\keybindings.json"
    #New-Item -ItemType HardLink -Force -Path "$appData_roaming\Code\User\settings.json" -Target "$PSScriptRoot\Code\User\settings.json"

    ## ConEmu
    New-Item -ItemType HardLink -Force -Path "$appData_roaming\ConEmu.xml" -Target "$PSScriptRoot\ConEmu\ConEmu.xml"

    ## FreeCommander
    New-Item -ItemType HardLink -Force -Path "$appData_local\FreeCommanderXE\Settings\FreeCommander.fav.xml"   -Target "$PSScriptRoot\FreeCommanderXE\Settings\FreeCommander.fav.xml"
    New-Item -ItemType HardLink -Force -Path "$appData_local\FreeCommanderXE\Settings\FreeCommander.find.ini"  -Target "$PSScriptRoot\FreeCommanderXE\Settings\FreeCommander.find.ini"
    New-Item -ItemType HardLink -Force -Path "$appData_local\FreeCommanderXE\Settings\FreeCommander.ftp.ini"   -Target "$PSScriptRoot\FreeCommanderXE\Settings\FreeCommander.ftp.ini"
    New-Item -ItemType HardLink -Force -Path "$appData_local\FreeCommanderXE\Settings\FreeCommander.ini"       -Target "$PSScriptRoot\FreeCommanderXE\Settings\FreeCommander.ini"
    New-Item -ItemType HardLink -Force -Path "$appData_local\FreeCommanderXE\Settings\FreeCommander.shc"       -Target "$PSScriptRoot\FreeCommanderXE\Settings\FreeCommander.shc"
    New-Item -ItemType HardLink -Force -Path "$appData_local\FreeCommanderXE\Settings\FreeCommander.views.ini" -Target "$PSScriptRoot\FreeCommanderXE\Settings\FreeCommander.views.ini"
    New-Item -ItemType HardLink -Force -Path "$appData_local\FreeCommanderXE\Settings\FreeCommander.wcx.ini"   -Target "$PSScriptRoot\FreeCommanderXE\Settings\FreeCommander.wcx.ini"
    New-Item -ItemType SymbolicLink -Force -Path "$appData_local\FreeCommanderXE\Settings\ColorSchemes"        -Target "$PSScriptRoot\FreeCommanderXE\Settings\ColorSchemes"
}

# Created function so as to not pollute global namespace
# Test-Elevated
Push-Location $PSScriptRoot
Mount-AppData
Pop-Location
