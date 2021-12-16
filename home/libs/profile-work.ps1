# Work-Specific profile (currently @ Microsoft)

Import-Module -Force -DisableNameChecking -Name G:\PowerShell-Libs\src\lib-TDS.psm1
Import-Module -Force -DisableNameChecking -Name G:\PowerShell-Libs\src\lib-CMU.psm1 -ArgumentList @("G:\OlkDataApps")
Import-Module -Force -DisableNameChecking -Name G:\PowerShell-Libs\src\lib-Cosmos.psm1

${function:cd-Locations} = { cd "C:\git\griffin\sources\dev\Calendar\src\Locations" }
${function:cd-ADF} = { cd "C:\git\office.outlook.owa\Cosmos\ADF" }
${function:cd-Git} = { cd "C:\git" }
${function:cd-Experimentation} = { cd "C:\git\CTExperimentation" }
${function:cd-OutlookML} = { cd "C:\git\TEE\TEEGit\Offline\OutlookML\Onboarding\python"; $user = "pamilla";  Write-Host "To activate environment: conda activate outlookml" }

function powerline() {
    # For some reason 'opening a cmd shell > initGriffin > powershell' causes posh-git to load REALLY slow
    # so instead we'll define our prompt in this `powerline` function to be applied whenever it's safe to do so
    Import-Module Posh-Git
    Import-Module Oh-My-Posh
    Set-PoshPrompt -Theme Paradox
}