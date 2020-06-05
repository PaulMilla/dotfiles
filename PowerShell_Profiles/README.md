# Powershell Profiles

<https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles>

Powershell utilizes different profiles for different instances, or 'hosts', that are running the language.
For instance, powershell running in VSCode is different than the one running in Visual Studio, and even *that*
is different than the one running in a console (*powershell.exe*/*pwsh*).

Additionally powershell also allows you to layer them based on your local user, or for all users across the entire machine,
with each, more specific layer, adding ontop the previous layer. To see all layers applied to your current host
run `$PROFILE | Get-Member -Type NoteProperty`. In general the bulk of settings should probably be in `CurrentUserAllHosts`,
with any host-specific settings in `CurrentUserCurrentHost`.

* AllUsersAllHosts
  * `C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1`
* AllUsersCurrentHost
  * `C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1`
  * `C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.VSCode_profile.ps1`
* CurrentUserAllHosts
  * `C:\Users\Paul\Documents\WindowsPowerShell\profile.ps1`
  * `C:\Users\Milla\Documents\WindowsPowerShell\profile.ps1`
* CurrentUserCurrentHost
  * `C:\Users\Paul\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
  * `C:\Users\Paul\Documents\WindowsPowerShell\Microsoft.VSCode_profile.ps1`
