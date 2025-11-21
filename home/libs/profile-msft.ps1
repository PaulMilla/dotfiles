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
if (!(Get-Command msbuild -ErrorAction SilentlyContinue)) {
    $msbuild2019 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\bin\msbuild.exe"
    $msbuild2022 = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\amd64\MSBuild.exe"

    if (Test-Path $msbuild2022) {
        New-Alias msbuild -Value $msbuild2022
    }
    elseif (Test-Path $msbuild2019) {
        New-Alias msbuild -Value $msbuild2019
    }
}

${function:cd-Git} = { cd "$gitDir" }
${function:cd-Experimentation} = { cd "$gitDir\CTExperimentation" }
${function:cd-CMU} = { cd "$gitDir\OlkDataApps\sources\dev\CalendarMetadataUploaderV2" }
${function:cd-ADF} = { cd "$gitDir\CTData\Cosmos\ADF" }
${function:cd-PlacesCompute} = { cd "$gitDir\EuclidMelbourne\sources\dev\Projects\xplat\placesComputePySpark" }
${function:cd-EWS} = { cd "$gitDir\EuclidMelbourne\sources\dev" }
${function:cd-OutlokServices} = { cd "$gitDir\outlookweb\services" }
${function:cd-OutlookML} = { cd "$gitDir\TEE\TEEGit\Offline\OutlookML\Onboarding\python"; $user = "pamilla";  Write-Host "To activate environment: conda activate outlookml" }
Set-Alias vs2022 "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"


function install-TdsVpn() {
    Write-Host "Installing Azure VPN Client from msstore..."
    winget install --name "Azure VPN Client"

    Write-Host "Downloading vpnclient configs from https://aka.ms/tds/vpnclient and install"
    #Invoke-WebRequest -URI "https://microsoft.sharepoint-df.com/teams/o365esiweb/_layouts/15/download.aspx?UniqueId=adb4e975-aedf-4443-98da-97af65cea0f3" -OutFile M365_EFDC_VPN_Client.exe
}

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