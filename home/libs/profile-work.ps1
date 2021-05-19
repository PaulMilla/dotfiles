# Work-Specific profile (currently @ Microsoft)

${function:cd-Locations} = { cd "C:\git\griffin\sources\dev\Calendar\src\Locations" }
${function:cd-ADF} = { cd "C:\git\office.outlook.owa\Cosmos\ADF" }
${function:cd-Git} = { cd "C:\git" }
${function:cd-Experimentation} = { cd "C:\git\CTExperimentation" }

function powerline() {
    # For some reason 'opening a cmd shell > initGriffin > powershell' causes posh-git to load REALLY slow
    # so instead we'll define our prompt in this `powerline` function to be applied whenever it's safe to do so
    Import-Module Posh-Git
    Import-Module Oh-My-Posh
    Set-PoshPrompt -Theme Paradox
}

function TDS-NewSession([Parameter(Mandatory=$true)]$ipAddress) {
    # Might need to have PS setup, especially if using CredSSP auth
    ## $ winrm quickconfig
    ## $ Enable-WSManCredSSP -Role client -DelegateComputer * -Force
    if (!(Test-Path variable:adminCred) -and !(Test-Path variable:global:adminCred)) {
        $adminCred = Get-Credential -Credential Administrator
        $global:adminCred = $adminCred
    }
    return New-PSSession -Credential $adminCred -Authentication CredSSP -ComputerName $ipAddress 
}

function TDS-Connect([Parameter(Mandatory=$true)]$ipAddress) {
    if (!(Test-Path variable:adminCred) -and !(Test-Path variable:global:adminCred)) {
        $adminCred = Get-Credential -Credential Administrator
        $global:adminCred = $adminCred
    }
    Write-Host "Reminder: To use Exchange Commands load them in via: Add-PSSnapin *2010"
    Enter-PSSession -Credential $adminCred -Authentication CredSSP -ComputerName $ipAddress 
}

function Get-SubstrateAppToken([Parameter(Mandatory=$true)]$ipAddress) {
    if (!(Test-Path variable:adminCred) -and !(Test-Path variable:global:adminCred)) {
        $adminCred = Get-Credential -Credential Administrator
        $global:adminCred = $adminCred
    }
    Invoke-Command -ComputerName $ipAddress -Credential $adminCred -Authentication CredSSP -ScriptBlock { & "C:\Program Files\Microsoft\Exchange Test\Security\SubstrateTestTokenTool\New-SubstrateTestToken.ps1" -AzureAD AppToken -AppId "9bdb0045-3587-47f9-863a-2ca58d11e2e8" -Grants "Locations-Internal.ReadWrite","Place.Read.All","Place.ReadWrite.All" -TokenState PreTransform }
}

function Get-SubstrateUserToken([Parameter(Mandatory=$true)]$ipAddress) {
    if (!(Test-Path variable:adminCred) -and !(Test-Path variable:global:adminCred)) {
        $adminCred = Get-Credential -Credential Administrator
        $global:adminCred = $adminCred
    }

    Invoke-Command -ComputerName $ipAddress -Credential $adminCred -Authentication CredSSP -ScriptBlock {
        Add-PSSnapin *2010;
        $org = Get-Organization |  Where {$_.Name -like "griffin*"} | Select -First 1;
        $smtp = Get-Mailbox -Organization $org | Where { $_.Name -like "Admin*"} | Select -First 1 -ExpandProperty PrimarySmtpAddress;
        & "C:\Program Files\Microsoft\Exchange Test\Security\SubstrateTestTokenTool\New-SubstrateTestToken.ps1" -AppId "9bdb0045-3587-47f9-863a-2ca58d11e2e8" -AzureAD UserToken -TokenState PreTransform -Grants "Locations-Internal.ReadWrite","Place.Read.All","Place.ReadWrite.All" -SmtpAddress $smtp
    }
}

function DeployDll-CalendarLocations([Parameter(Mandatory=$true)]$tdsIp) {
    Copy-Item "${env:INETROOT}\target\dev\calendar\Microsoft.O365.Calendar.Locations\debug\amd64\Microsoft.O365.Calendar.Locations.*" `
              "\\$tdsIp\D$\MicroService\Locations\bin" -Exclude *.config
}

# function DeployResources-OutlookAnalysis() {
# }


function DeployAutoPilot-CalendarMetadataUploader([Parameter(Mandatory=$true)]$tdsIp) {
    $session = TDS-NewSession -ipAddress $tdsIp

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

function DeployDll-CalendarMetadataUploader([Parameter(Mandatory=$true)]$tdsIp) {
    Copy-Item "${env:INETROOT}\target\dev\calendar\Microsoft.O365.Calendar.Locations\debug\amd64\Microsoft.O365.Calendar.Locations.*" `
              "\\$tdsIp\D$\MicroService\Locations\bin" -Exclude *.config
}