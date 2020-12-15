# Work-Specific profile (currently @ Microsoft)

${function:cd-Locations} = { cd "C:\git\griffin\sources\dev\Calendar\src\Locations" }
${function:cd-ADF} = { cd "C:\git\office.outlook.owa\Cosmos\ADF" }

function powerline() {
    # For some reason 'opening a cmd shell > initGriffin > powershell' causes posh-git to load REALLY slow
    # so instead we'll define our prompt in this `powerline` function to be applied whenever it's safe to do so
    Import-Module Posh-Git
    Import-Module Oh-My-Posh
    Set-Theme Paradox
}

function Connect-TDS([Parameter(Mandatory=$true)]$ipAddress) {
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