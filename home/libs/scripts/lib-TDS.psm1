<#
.SYNOPSIS
Gets or creates a PSSession to target TDS

.DESCRIPTION
Utilizes a custom global variable 'tdsDict' to store sessions for different TDS machines.
If we have never connected to the TDS machine before we establish a new connection for it.
If we have established a previous connection return that session information instead.

.PARAMETER tdsIp
The IP Address of the TDS to connect to

.EXAMPLE
TDS-Connect -tdsIp 10.231.237.170

.NOTES
PowerShell global variables only exist within the context of the window. Closing the current
window or opening a new one results in a blank slate.
#>

[CmdletBinding()]
param (
)

function TDS-TestDirectoryConnection() {
    [CmdletBinding()]
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
}

function TDS-GetSession() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    # Might need to have PS setup, especially if using CredSSP auth
    ## $ winrm quickconfig
    ## $ Enable-WSManCredSSP -Role client -DelegateComputer * -Force
    if (!(Test-Path variable:global:tdsDict)) {
        $global:tdsDict = @{}
    }

    if ($global:tdsDict.ContainsKey($tdsIp) -and ($global:tdsDict[$tdsIp].State -ne "Opened"))
    {
        $state = $global:tdsDict[$tdsIp].State
        Write-Host "TDS session to $tdsIp is '$state'. Removing from cached sessions"
        $global:tdsDict.Remove($tdsIp);
    }
    if (!($global:tdsDict.ContainsKey($tdsIp))) {
        Write-Host "tdsIp not found. Creating new entry. Please provide password..."
        $adminCred = Get-Credential -Credential Administrator
        $newSession = New-PSSession -Credential $adminCred -Authentication CredSSP -ComputerName $tdsIp 
        $global:tdsDict.Add($tdsIp, $newSession)
    }

    return $global:tdsDict[$tdsIp]
}

function TDS-Connect() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    $session = TDS-GetSession $tdsIp
    Write-Host "Reminder: To use Exchange Commands load them in via: Add-PSSnapin *2010"
    Enter-PSSession -Session $session
}

function TDS-ViewSessions() {
    if (!(Test-Path variable:global:tdsDict)) {
        $global:tdsDict = @{}
    }

    $print = $global:tdsDict | ConvertTo-Json -Depth 1
    Write-Host "TDS Sessions`n$print"
}

function TDS-SetupRemoteDebugger() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    Write-Host "TODO: What should these settings be? User: Administrator? Or 'Local System'? 'Network System'?"
    TDS-OpenProgram -tdsIp $tdsIp -program "C:\Program Files\Microsoft Visual Studio 16.0\Common7\IDE\rdbgwiz.exe"
}

function TDS-SetupWatchdog() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    $session = TDS-GetSession $tdsIp
    TDS-TestDirectoryConnection $tdsIp

    Write-Host "Running through setup sets defined in the Substrate Dev Center docs:"
    Write-Host "    https://docs.substrate.microsoft.net/docs/Monitoring/Using-Watchdog-to-monitor-your-app/Test-watchdogs-in-tds.html`n"

    Write-Host "Restarting MSExchangeHM. This service is responsible for setting up health monitoring accounts which the watchdog app uses as resources from which to generate the tokens to be sent along with the watchdog ping request."
	Invoke-Command -Session $session -ScriptBlock {
        Restart-Service MSExchangeHM
    } | Write-Host

    $serviceStatusFile = "\\$ip\D$\Data\servicemanager\servicestatus.csv"
    Write-Host "Replace Ping with your app name (such as CalendarMetadataUploader) in the first column. Also remove the line for TEE if you don't want to see TEE probes...`n"
    code --wait $serviceStatusFile

    Write-Host -ForegroundColor Green "Substrate Watchdog setup complete!`n"
    Write-Host "To run the watchdog from the TDS box (or a remote PSSession):`n    D:\App\SubstrateAppWatchdog\Microsoft.SubstrateAppWatchdog.exe localhost`n"
    Write-Host "Heartbeat files for watchdog can be checked under:`n    D:\data\WatchdogOutput"
    Write-Host "Alternatively you can use the following commands to start watchdog and check heartbeat files:
        * TDS-StartWatchdog
        * TDS-OpenWatchdogHeartbeats"
}

function TDS-StartWatchdog() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    $session = TDS-GetSession $tdsIp
    TDS-TestDirectoryConnection $tdsIp

	Invoke-Command -Session $session -ScriptBlock {
        & D:\App\SubstrateAppWatchdog\Microsoft.SubstrateAppWatchdog.exe localhost
    } | Write-Host

    Write-Host -ForegroundColor Green "Substrate Watchdog setup complete!"
    Write-Host "To run the watchdog from the TDS box (or a remote PSSession):`n    D:\App\SubstrateAppWatchdog\Microsoft.SubstrateAppWatchdog.exe localhost"
    Write-Host "Heartbeat files for watchdog can be checked under:`n    D:\data\WatchdogOutput"
}

function TDS-OpenWatchdogHeartbeats() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    Write-Host "Opening Directory: \\$tdsIp\D$\data\WatchdogOutput"
    TDS-TestDirectoryConnection $tdsIp
    
    Start-Process "\\$tdsIp\D$\data\WatchdogOutput"
}

function TDS-CheckGriffinEnabledProcessors() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp,
        [int]$processorType = 0
    )

    if ($processorType -lt 1 -or $processorType -gt 4) {
        Write-Host "Processor types are as follows:
            1: Item Processor (EBA)
            2: MailboxProcessor (TBA)
            3: SWSS Processor
            4: MailboxDiscoveryProcessor"
        $type = [int](Read-Host "Please select a processor type to check")
        return TDS-CheckGriffinEnabledProcessors -tdsIp $tdsIp -processorType $type
    }

    Start-Process "https://$tdsIp/griffin/registration/GetEnabledProcessors?version=2&type=$processorType"
}

function TDS-SetupGeneva() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    $session = TDS-GetSession $tdsIp
    TDS-TestDirectoryConnection $tdsIp

    Write-Host "Copying from PassiveMonitoringTDSTesting.."
    robocopy /z /e /mt:8 "\\redmond\exchange\Files\UserFiles\PassiveMonitoringTDSTesting" "\\$tdsIp\D$\PassiveMon"
	Invoke-Command -Session $session -ScriptBlock {
        & D:\PassiveMon\Setup\InstallTdsCert.ps1
    } | Write-Host

    Write-Host "Unsure what do to. Follow guide at`n
        https://docs.substrate.microsoft.net/docs/Monitoring/Get-started-with-app-monitoring/Passive-monitoring-of-your-app/Set-up-Geneva.html?uid=set-up-geneva-on-a-tds-or-dev-machine&toc=%2Fdocs%2FBuild-Model-B2-apps%2Ftoc.html"
}

function TDS-StopNonEssentialServices() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    $session = TDS-GetSession $tdsIp
	Invoke-Command -Session $session -ScriptBlock {
        Invoke-Expression "net stop MSExchangeAntispamUpdate"
        Invoke-Expression "net stop MSExchangeAntimalwareSvc"
        Invoke-Expression "net stop MSComplianceAudit"
        Invoke-Expression "net stop MSExchangeCompliance"
        Invoke-Expression "net stop MSExchangeForwardSync"
        Invoke-Expression "net stop MSExchangeHMRecovery"
        Invoke-Expression "net stop MSExchangeHM"
        Invoke-Expression "net stop MSExchangeIMAP4"
        Invoke-Expression "net stop MSExchangeIMAP4BE"
        Invoke-Expression "net stop MSExchangePOP3"
        Invoke-Expression "net stop MSExchangePOP3BE"
        Invoke-Expression "net stop MSExchangeStreamingOptics"
        Invoke-Expression "net stop MSExchangeUM"
        Invoke-Expression "net stop MSExchangeUMCR"
        Invoke-Expression "net stop MSExchangeTransportLogSearch"
    } | Write-Host
}

function TDS-EnableRemotePrograms() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp
    )

    $session = TDS-GetSession $tdsIp
	Invoke-Command -Session $session -ScriptBlock {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
        Write-Host -NoNewline "Checking $path..."
        $terminalServices = Get-ItemProperty -Path $path
        if ($terminalServices.fAllowUnlistedRemotePrograms -ne 1) {
            Write-Host -ForegroundColor Yellow "!"
            Write-Host -NoNewLine "Setting fAllowUnlistedRemotePrograms to 1..."
            Set-ItemProperty $path "fAllowUnlistedRemotePrograms" 1
        }
        Write-Host -ForegroundColor Green "Ok"

        $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList"
        Write-Host -NoNewline "Checking $path..."
        $tsAppAllowList = Get-ItemProperty -Path $path
        if ($tsAppAllowList.fDisabledAllowList -ne 1) {
            Write-Host -ForegroundColor Yellow "!"
            Write-Host -NoNewLine "Setting fDisabledAllowListSetting to 1..."
            Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList" "fDisabledAllowList" 1
        }
        Write-Host -ForegroundColor Green "Ok"
    } | Write-Host
}

function TDS-OpenProgram() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$tdsIp,
        [string]$program = "powershell",
        [string]$cliArgs = "",
        [string]$username = ".\Administrator",
        [string]$saveTo
    )

    $tempFile = New-TemporaryFile | Rename-Item -Passthru -NewName { [io.path]::ChangeExtension($_.Name, "rdp") }
    try {
        # To learn more about RDP file settings see the page at:
        # https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/rdp-files
@"
screen mode id:i:2
use multimon:i:0
desktopwidth:i:1440
desktopheight:i:900
session bpp:i:32
winposstr:s:0,1,451,102,1897,885
compression:i:1
keyboardhook:i:2
audiocapturemode:i:1
videoplaybackmode:i:1
connection type:i:2
displayconnectionbar:i:1
disable wallpaper:i:1
allow font smoothing:i:0
allow desktop composition:i:0
disable full window drag:i:1
disable menu anims:i:1
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
audiomode:i:0
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
redirectclipboard:i:1
redirectposdevices:i:0
redirectdirectx:i:1
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:0
negotiate security layer:i:1
gatewayusagemethod:i:
gatewaycredentialssource:i:
gatewayprofileusagemethod:i:
promptcredentialonce:i:0
use redirection server name:i:0
administrative session:i:1
drivestoredirect:s:*
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
full address:s:$tdsIp
username:s:$username

remoteapplicationmode:i:1
remoteapplicationname:s:$program
remoteapplicationprogram:s:$program
remoteapplicationcmdline:s:$cliArgs
"@ | Out-File $tempFile
        Write-Host "Launching $program on $tdsIp...`nIf there is an error, try running TDS-EnableRemotePrograms first"
        Start-Process -Wait $tempFile
    }
    finally {
        if ($saveTo) {
            $saveTo = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($saveTo)
            Move-Item -Force $tempFile $saveTo
            Write-Host -ForegroundColor Green "Saved rdp file to: $saveTo"
        }
        else {
            Remove-Item $tempFile
        }
    }

}

Export-ModuleMember -Function TDS-*