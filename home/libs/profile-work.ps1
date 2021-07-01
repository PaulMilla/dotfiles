# Work-Specific profile (currently @ Microsoft)

Import-Module -DisableNameChecking -Name $PSScriptRoot\scripts\lib-TDS.psm1
Import-Module -DisableNameChecking -Name $PSScriptRoot\scripts\lib-CMU.psm1

${function:cd-Locations} = { cd "C:\git\griffin\sources\dev\Calendar\src\Locations" }
${function:cd-ADF} = { cd "C:\git\office.outlook.owa\Cosmos\ADF" }
${function:cd-Git} = { cd "C:\git" }
${function:cd-Experimentation} = { cd "C:\git\CTExperimentation" }
${function:cd-CMU} = { cd "C:\git\O365Core\OlkDataApps\sources\dev\CalendarMetadataUploaderV2" }

function powerline() {
    # For some reason 'opening a cmd shell > initGriffin > powershell' causes posh-git to load REALLY slow
    # so instead we'll define our prompt in this `powerline` function to be applied whenever it's safe to do so
    Import-Module Posh-Git
    Import-Module Oh-My-Posh
    Set-PoshPrompt -Theme Paradox
}

function Get-SubstrateAppToken([Parameter(Mandatory=$true)]$ipAddress) {
    $session = TDS-GetSession -tdsIp $ipAddress
    Invoke-Command -Session $session -ScriptBlock {
        & "C:\Program Files\Microsoft\Exchange Test\Security\SubstrateTestTokenTool\New-SubstrateTestToken.ps1" `
            -AzureAD AppToken `
            -AppId "9bdb0045-3587-47f9-863a-2ca58d11e2e8" `
            -TokenState PreTransform `
            -Grants "Calendar.Read","Calendars.Read","Calendars.ReadWrite","Calendars-Internal.Read","MailboxSettings.Read","ScheduledWork.Create","ScheduledWork.Delete","ScheduledWork.Read","SDS-Internal.ReadWrite.All","User.Read"
    }
}

function Get-SubstrateUserToken([Parameter(Mandatory=$true)]$ipAddress) {
    $session = TDS-GetSession -tdsIp $ipAddress
    Invoke-Command -Session $session -ScriptBlock {
        Add-PSSnapin *2010;
        $org = Get-Organization |  Where {$_.Name -like "griffin*"} | Select -First 1;
        $smtp = Get-Mailbox -Organization $org | Where { $_.Name -like "Admin*"} | Select -First 1 -ExpandProperty PrimarySmtpAddress;
        & "C:\Program Files\Microsoft\Exchange Test\Security\SubstrateTestTokenTool\New-SubstrateTestToken.ps1" `
            -AzureAD UserToken `
            -AppId "9bdb0045-3587-47f9-863a-2ca58d11e2e8" `
            -TokenState PreTransform `
            -Grants "Locations-Internal.ReadWrite","Place.Read.All","Place.ReadWrite.All" `
            -SmtpAddress $smtp
    } | Write-Host
}

function DeployDll-CalendarLocations([Parameter(Mandatory=$true)]$tdsIp) {
    Copy-Item "${env:INETROOT}\target\dev\calendar\Microsoft.O365.Calendar.Locations\debug\amd64\Microsoft.O365.Calendar.Locations.*" `
              "\\$tdsIp\D$\MicroService\Locations\bin" -Exclude *.config
}

function DeployAutoPilot-CalendarMetadataUploader([Parameter(Mandatory=$true)]$tdsIp) {
    $session = TDS-GetSession $tdsIp

    ## Zip CMU Autopilot, copy to TDS, and unzip
    Write-Host -Foreground Green "Prepping autopilot files for transfer..."
    Compress-Archive -Path "${env:INETROOT}\target\distrib\product\all\debug\amd64\CalendarMetadataUploaderAutoPilot\CalendarMetadataUploader\*" `
                     -DestinationPath "${env:TEMP}\CalendarMetadataUploaderAutoPilot.zip" -Force
    Copy-Item "${env:TEMP}\CalendarMetadataUploaderAutoPilot.zip" `
              "D:\AutoPilots\CalendarMetadataUploaderAutoPilot.zip" -Force -ToSession $session
    Invoke-Command -Session $session -ScriptBlock {
        Expand-Archive -Path "D:\AutoPilots\CalendarMetadataUploaderAutoPilot.zip" `
                       -DestinationPath "D:\AutoPilots\CalendarMetadataUploader" -Force
    } | Write-Host

    # Run start.bat on TDS
    Write-Host -Foreground Green "Running start.bat..."
    Invoke-Command -Session $session -ScriptBlock {
        Push-Location -Path "D:\AutoPilots\CalendarMetadataUploader"
        & cmd /c start.bat
    } | Write-Host

    # Restart IIS & Services
    Write-Host -Foreground Green "Restarting IIS and Services..."
    Invoke-Command -Session $session -ScriptBlock {
        iisreset
        Restart-Service MsExchangeMailboxAssistants
    } | Write-Host
}