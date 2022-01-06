# Profile for the Microsoft.Powershell Shell, only. (Not Visual Studio, VS Code, or other PoSh instances)
# Layered on top of Profile.ps1
# ===========

if (Test-Path "$home\libs\profile-console.ps1") {
  # For some reason this is only working on Core now?
  if ($PSVersionTable.PSEdition -eq "Core") {
    . $home\libs\profile-console.ps1
  }
}

## TODO: Create profile for Visual Studio
#. $home\libs\profile-visualstudio.ps1 
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
