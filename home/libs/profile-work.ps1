# Work-Specific profile (currently @ Microsoft)

$gitDir = "C:\git"
if (Test-Path "$gitDir\PowerShell-Libs\")
{
    Import-Module -Force -DisableNameChecking -Name "$gitDir\PowerShell-Libs\src\lib-TDS.psm1"
    Import-Module -Force -DisableNameChecking -Name "$gitDir\PowerShell-Libs\src\lib-CMU.psm1" -ArgumentList @("$gitDir\OlkDataApps")
    Import-Module -Force -DisableNameChecking -Name "$gitDir\PowerShell-Libs\src\lib-Cosmos.psm1"
}
else {
    Write-Warning "Missing additional PowerShell-Libs under git dir '$gitDir'"
    Write-Warning "Consider downloading it from https://ctgain.visualstudio.com/CT%20GAIN/_git/PowerShell-Libs"
}

# If msbuild isn't in our PATH let's try to create an alias for it
if (!(Get-Command msbuild -ErrorAction SilentlyContinue) && Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\bin\msbuild.exe") {
    New-Alias msbuild -Value "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\bin\msbuild.exe"
}

${function:cd-Git} = { cd "$gitDir" }
${function:cd-Experimentation} = { cd "$gitDir\CTExperimentation" }
${function:cd-CMU} = { cd "$gitDir\OlkDataApps\sources\dev\CalendarMetadataUploaderV2" }
${function:cd-ADF} = { cd "$gitDir\CTData\Cosmos\ADF" }
${function:cd-OutlookML} = { cd "$gitDir\TEE\TEEGit\Offline\OutlookML\Onboarding\python"; $user = "pamilla";  Write-Host "To activate environment: conda activate outlookml" }

function powerline() {
    # For some reason 'opening a cmd shell > initGriffin > powershell' causes posh-git to load REALLY slow
    # so instead we'll define our prompt in this `powerline` function to be applied whenever it's safe to do so
    # Oh-my-posh module is deprecated. See Migration Guide: https://ohmyposh.dev/docs/migrating
    Import-Module Posh-Git
    if (!(Get-Command oh-my-posh -ErrorAction 'Silent')) {
        Write-Host "Consider downloading oh-my-posh: https://ohmyposh.dev/docs/installation/windows"
    }
    else {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\Paradox.omp.json" | Invoke-Expression
    }
}
powerline