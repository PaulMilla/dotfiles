# Work-Specific profile (currently @ Microsoft)

$gitDir = "C:\git"
Import-Module -Force -DisableNameChecking -Name "$gitDir\PowerShell-Libs\src\lib-TDS.psm1"
Import-Module -Force -DisableNameChecking -Name "$gitDir\PowerShell-Libs\src\lib-CMU.psm1" -ArgumentList @("$gitDir\OlkDataApps")
Import-Module -Force -DisableNameChecking -Name "$gitDir\PowerShell-Libs\src\lib-Cosmos.psm1"

# If msbuild isn't in our PATH let's try to create an alias for it
if (!(Get-Command msbuild -ErrorAction SilentlyContinue)) {
    New-Alias msbuild -Value "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\bin\msbuild.exe"
}

${function:cd-Git} = { cd "$gitDir" }
${function:cd-Experimentation} = { cd "$gitDir\CTExperimentation" }
${function:cd-CMU} = { cd "$gitDir\OlkDataApps\sources\dev\CalendarMetadataUploaderV2" }
${function:cd-OutlookML} = { cd "$gitDir\TEE\TEEGit\Offline\OutlookML\Onboarding\python"; $user = "pamilla";  Write-Host "To activate environment: conda activate outlookml" }

function powerline() {
    # For some reason 'opening a cmd shell > initGriffin > powershell' causes posh-git to load REALLY slow
    # so instead we'll define our prompt in this `powerline` function to be applied whenever it's safe to do so
    Import-Module Posh-Git
    Import-Module Oh-My-Posh
    Set-PoshPrompt -Theme Paradox
}
powerline