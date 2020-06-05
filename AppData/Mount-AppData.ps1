function Mount-AppData() {
    # AppData
    #########

    ## Settings/Configs for files that are app-specific
    ## Typically stored under the user's AppData Directory in Windows, but might not always be the case
    ## We'll install each app explicitly and define the path for windows, osx, and linux

    ## Visual Studio Code
    ## https://vscode.readthedocs.io/en/latest/getstarted/settings/#settings-file-locations
    $appData_vscode = if ($IsLinux) { "$home/.config/" } `
                      elseif ($IsMacOS) { "$home/Library/Application Support/" } `
                      else { $env:APPDATA }
    Copy-Item .\Code -Recurse -Force -Destination $appData_vscode
}

# Created function so as to not pollute global namespace
Push-Location $PSScriptRoot
Mount-AppData
Pop-Location