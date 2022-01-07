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
