[CmdletBinding()]
param (
    [Parameter()]
    [string]$cmuPath = "C:\git\O365Core\OlkDataApps"
)

Import-Module -DisableNameChecking -Name $PSScriptRoot\lib-TDS.psm1

function CMU-InitDeploy {
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp,

        <# TODO: Find a better process for this
         # For now download from: https://o365exchange.visualstudio.com/O365%20Core/_git/Griffin?path=%2Fsources%2Fdev%2FGriffin%2Fsrc%2FControllerService%2FIniFiles%2FCalendarMetadataUploaderV2TimeBasedProcessor.settings.ini&version=GBusers%2Fanclawso%2FNetCoreTBA&_a=contents
         #>
        [Parameter()]
        [string]$cmuGriffinIniPath = "$env:HOMEPATH\Downloads\CalendarMetadataUploaderV2TimeBasedProcessor.settings.ini"
    )

    if (!(Test-Path "\\${tdsIp}\D$"))
    {
        Write-Host -ForegroundColor Yellow "No connection established to $tdsIp. Attempting 'net use' command..."
        net use "\\${tdsIp}\D$" /u:Administrator
        if (!(Test-Path "\\${tdsIp}\D$"))
        {
            throw "Could not connect to TDS machine: $tdsIp"
        }
    }

    # Copy over DLLs
    robocopy "$cmuPath\target\sources\dev\CalendarMetadataUploaderV2\Debug\netcoreapp3.1\win10-x64\" `
             "\\${tdsIp}\D$\App\CalendarMetadataUploaderV2\" `
             /z /MIR

    Write-Host "Copying over CMI ini file for Griffin"
    Copy-Item "$cmuGriffinIniPath" "\\${tdsIp}\D$\Microservice\Griffin\IniFiles\"

    Write-Host -ForegroundColor Yellow "Please edit MasterProcessorConfig.settings.ini manually. Copy over the CMU settings from the git repo here:
    https://o365exchange.visualstudio.com/O365%20Core/_git/Griffin?path=%2Fsources%2Fdev%2FGriffin%2Fsrc%2FControllerService%2FIniFiles%2FMasterProcessorConfig.settings.ini&version=GBusers%2Fanclawso%2FNetCoreTBA&_a=contents"
    Write-Host "Press any key to edit..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    Start-Process -Wait "\\${tdsIp}\D$\Microservice\Griffin\IniFiles\MasterProcessorConfig.settings.ini"

    Write-Host "Restarting services..."
    $session = TDS-GetSession $tdsIp
    Invoke-Command -Session $session -ScriptBlock {
        Restart-Service "Substrate Auth Service 2",MSExchangeMailboxAssistants,MSExchangeStiSvc
    } | Write-Host

    Write-Host -ForegroundColor Green "Done! To start CMU remote in and start the exe via:"
    Write-Host "
    TDS-Connect ${tdsIp}
    Push-Location D:\App\CalendarMetadataUploaderV2
    ./CalendarMetadataUploaderV2.exe
    "
    Write-Host -ForegroundColor Green "To make griffin send a notification:
    Start-MailboxAssistant -AssistantName CalendarMetadataUploaderV2TimeBasedProcessor -Identity <userMailbox>
    "
    Write-Host -ForegroundColor Green "To check enabled MailboxProcessors(type2):
    https://${tdsIp}:444/griffin/registration/GetEnabledProcessors?version=2&type=2"
}

function CMU-Redeploy {
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    if (!(Test-Path "\\${tdsIp}\D$"))
    {
        Write-Host -ForegroundColor Yellow "No connection established to $tdsIp. Attempting 'net use' command..."
        net use "\\${tdsIp}\D$" /u:Administrator
        if (!(Test-Path "\\${tdsIp}\D$"))
        {
            throw "Could not connect to TDS machine: $tdsIp"
        }
    }

    # Copy over DLLs
    robocopy "$cmuPath\target\sources\dev\CalendarMetadataUploaderV2\Debug\netcoreapp3.1\win10-x64\" `
             "\\${tdsIp}\D$\App\CalendarMetadataUploaderV2\" `
             /z /MIR
}

function CMU-ProcessMailbox
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp,
        [Parameter(Mandatory=$true)]
        [string]$targetMailbox
    )
    $session = TDS-GetSession $tdsIp
    Invoke-Command -Session $session -ScriptBlock {
        # Enable Exchange Commands
        Add-PSSnapin *2010

        <# TODO: We could look into using a "default" user instead of forcing us to specify one
        $org = Get-Organization |  Where {$_.Name -like "griffin*"} | Select -First 1;
        $smtp = Get-Mailbox -Organization $org | Where { $_.Name -like "Admin*"} | Select -First 1 -ExpandProperty PrimarySmtpAddress;
        #>

        # "Logs in" a user if we haven't already done so manually
        Test-MAPIConnectivity -Identity $using:targetMailbox | Out-Null
        # Causes the Griffin MailboxAssitant to send a MailboxProcessor notification to our app for the target mailbox
        Start-MailboxAssistant -AssistantName CalendarMetadataUploaderV2TimeBasedProcessor -Identity $using:targetMailbox
    } | Write-Host
}

function CMU-GenerateUserToken
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp,
        [string]$smtp
    )

    $session = TDS-GetSession $tdsIp
    Invoke-Command -Session $session -ScriptBlock {
        Add-PSSnapin *2010
        $smtp = $using:smtp
        if($null -eq $smtp) {
            $org = Get-Organization |? {$_.Name -like "griffin*"} | Select -First 1;
            $smtp = Get-Mailbox -Organization $org |? { $_.Name -like "Admin*"} | Select -First 1 -ExpandProperty PrimarySmtpAddress;
        }
        # From CalendarMetadataUploaderV2.settings.ini
        $cmuAppId = "e7762c80-392b-4278-80fa-a8fda80b129c"
        $permissions = @(
            "Calendar.Read",
            "Calendars.Read",
            "Calendars.ReadWrite",
            "Calendars-Internal.Read",
            "MailboxSettings.Read",
            "ScheduledWork.Create",
            "ScheduledWork.Delete",
            "ScheduledWork.Read", 
            "SDS-Internal.ReadWrite.All",
            "User.Read",
            "Privilege.AllowPrivateBehaviors"
        )

        & "C:\Program Files\Microsoft\Exchange Test\Security\SubstrateTestTokenTool\New-SubstrateTestToken.ps1" `
            -AzureAD UserToken `
            -SmtpAddress $smtp `
            -AppId $cmuAppId `
            -Grants $permissions
    } | Write-Host
}

Export-ModuleMember -Function *