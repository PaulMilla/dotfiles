# Profile for all PowerShell Hosts (Visual Studio, VSCode, or other PoSh instances)
# host-specific profile is layered on top of this (`echo $profile`)
# ===========

# Source libs
if (Test-Path "$home\libs\profile-functions.ps1") {. $home\libs\profile-functions.ps1}
if (Test-Path "$home\libs\profile-aliases.ps1") {. $home\libs\profile-aliases.ps1}
# if (Test-Path "$home\libs\profile-work.ps1") {. $home\libs\profile-work.ps1}
if (Test-Path "$home\libs\profile-azure.ps1") {. $home\libs\profile-azure.ps1}

# 3rd-party imports
if (($null -ne (Get-Command git -ErrorAction SilentlyContinue)) -and ($null -ne (Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue))) {
  # Posh-Git messes up cmd > initGriffin > powershell
  Import-Module Posh-Git
}

# Enable vi mode via PSReadline
Set-PSReadlineOption -EditMode vi
Set-PSReadLineOption -ViModeIndicator Cursor

# Exports
############

# Make vim the default editor
$env:EDITOR = "code --wait"

# ls.exe docs: https://u-tools.com/msls.htm
$env:LS_OPTIONS = "--escape --human-readable --more --color --recent --streams"

# Add libs dir to PATH if needed
$libsPath = Join-Path $home "libs"
if ($env:PATH -contains $libsPath) {
  $newPath = "$env:PATH;$libsPath"
  Write-Host "New Path: $newPath"
  [System.Environment]::SetEnvironmentVariable('PATH', $newPath)
}

if (Test-Path "$home\libs\profile-extras.ps1") {
    . $home\libs\profile-extras.ps1
}

# Init Oh-My-Posh if available
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
  # For all themes see: https://ohmyposh.dev/docs/themes
  oh-my-posh init pwsh --config powerlevel10k_rainbow | Invoke-Expression
  # oh-my-posh init pwsh --config paradox | Invoke-Expression
}
