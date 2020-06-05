# Profile for all PowerShell Hosts (Visual Studio, VSCode, or other PoSh instances)
# host-specific profile is layered on top of this (`echo $profile`)
# ===========

# Source libs
. $home\libs\profile-functions.ps1
. $home\libs\profile-aliases.ps1

# 3rd-party imports
if (($null -ne (Get-Command git -ErrorAction SilentlyContinue)) -and ($null -ne (Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue))) {
  Import-Module Posh-Git
}

# Exports
############

# Make vim the default editor
Set-Environment "EDITOR" "nvim-qt"
# Set-Environment "GIT_EDITOR" $Env:EDITOR
Set-Environment "PATH" "$Env:PATH;$(Join-Path $home "libs")"

if (Test-Path "$home\libs\profile-extras.ps1") {
    . $home\libs\profile-extras.ps1
}
