[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [string]$olkDataAppsPath = "G:\OlkDataApps"
)

Import-Module -Force -DisableNameChecking -Name $PSScriptRoot\lib-TDS.psm1

# Aliases
${function:cd-CMU} = { Push-Location "$olkDataAppsPath\sources\dev\CalendarMetadataUploaderV2" }

# Functions
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

    TDS-TestDirectoryConnection $tdsIp

    # Copy over DLLs
    robocopy "$olkDataAppsPath\target\sources\dev\CalendarMetadataUploaderV2\Debug\netcoreapp3.1\win10-x64\" `
             "\\${tdsIp}\D$\App\CalendarMetadataUploaderV2\" `
             /z /MIR /MT:32

    Write-Host "Copying over CMI ini file for Griffin"
    Copy-Item "$cmuGriffinIniPath" "\\${tdsIp}\D$\Microservice\Griffin\IniFiles\"

    Write-Host -ForegroundColor Yellow "Please edit MasterProcessorConfig.settings.ini manually. Copy over the CMU settings from the git repo here (CalendarMetadataUploaderV2TimeBasedProcessor):
    https://o365exchange.visualstudio.com/O365%20Core/_git/Griffin?path=%2Fsources%2Fdev%2FGriffin%2Fsrc%2FControllerService%2FIniFiles%2FMasterProcessorConfig.settings.ini&version=GBusers%2Fanclawso%2FNetCoreTBA&_a=contents"
    Write-Host "Press any key to edit..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    Start-Process -Wait "\\${tdsIp}\D$\Microservice\Griffin\IniFiles\MasterProcessorConfig.settings.ini"

    Write-Host "Restarting services..."
    $session = TDS-GetSession $tdsIp
    Invoke-Command -Session $session -ScriptBlock {
        Restart-Service "Substrate Auth Service 2",MSExchangeMailboxAssistants,MSExchangeStiSvc
    } | Write-Host

    Write-Host -ForegroundColor Green "Done! To start CMU begin a remote PSSession and start the exe via:"
    Write-Host "
    TDS-Connect ${tdsIp}
    Push-Location D:\App\CalendarMetadataUploaderV2
    ./start.bat
    "
    Write-Host -ForegroundColor Green "To make griffin send a notification (from a remote PSSession):
    Add-PSSnapin *2010
    `$org = Get-Organization |? {`$_.Name -like `"griffin*`"} | Select -First 1;
    `$adminMailbox = `"admin@`$org`"
    Start-MailboxAssistant -AssistantName CalendarMetadataUploaderTimeBasedProcessor -Identity <userMailbox>
    "
    Write-Host -ForegroundColor Green "To check enabled MailboxProcessors(type2):
    https://${tdsIp}:444/griffin/registration/GetEnabledProcessors?version=2&type=2"
}

function CMU-Redeploy {
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    TDS-TestDirectoryConnection $tdsIp

    # Copy over DLLs
    cd-CMU
    & msbuild
    robocopy "$olkDataAppsPath\target\distrib\CalendarMetadataUploaderV2\netcoreapp3.1\win10-x64\autopilot\CalendarMetadataUploaderV2" `
             "\\${tdsIp}\D$\App\CalendarMetadataUploaderV2\" `
             /z /MIR /MT:32 
    Pop-Location
}

function CMU-Run {
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )
    $session = TDS-GetSession $tdsIp

    Invoke-Command -Session $session -ScriptBlock {
        Push-Location "D:\App\CalendarMetadataUploaderV2"

        if (!(Test-Path "start.bat")) {
            Write-Warning "start.bat not found! Running CalendarMetadataUploaderV2.exe directly..."
            & "./CalendarMetadataUploaderV2.exe"
        }

        Write-Host "Running CMU via start.bat..."
        & ./start.bat
    } | Write-Host
}

function CMU-OpenGriffinSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    TDS-TestDirectoryConnection $tdsIp

    $mailboxProcessorSettings = "\\$tdsIp\\D$\MicroService\Griffin\IniFiles\CalendarMetadataUploaderMailboxProcessor.settings.ini"
    if (Test-Path $mailboxProcessorSettings) {
        Write-Host -ForegroundColor Green "Opening $mailboxProcessorSettings.."
        Start-Process $mailboxProcessorSettings
    }
    else {
        Write-Error "Could not find file at $mailboxProcessorSettings"
    }
}

function CMU-OpenSnapshotLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    TDS-TestDirectoryConnection $tdsIp

    $snapshotLog = "\\$tdsIp\D$\OfficeDataLoader\Dump\NRTLoggingSdk\CMUSnapshotLog"
    if (Test-Path $snapshotLog) {
        Write-Host -ForegroundColor Green "Opening $snapshotLog.."
        Start-Process $snapshotLog
    }
    else {
        Write-Error "Could not find file at $snapshotLog"
    }
}

function CMU-ProcessMailbox {
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

function CMU-GenerateUserToken {
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

Export-ModuleMember -Function cd-CMU,CMU-*