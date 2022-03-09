# Profile for the Microsoft.Powershell Shell, only. (Not Visual Studio, VS Code, or other PoSh instances)
# Layered on top of Profile.ps1
# ===========

if (Test-Path "$home\libs\profile-console.ps1") {
  . $home\libs\profile-console.ps1
}

## TODO: Create profile for Visual Studio
#. $home\libs\profile-visualstudio.ps1 
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# VS Code for some reason maps ctrl+backspace to ctrl+w, and when we try and ctrl+backspace
# in the VS Code terminal we instead get the characters ^W
if ($env:TERM_PROGRAM -eq "vscode") {
  Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord
}