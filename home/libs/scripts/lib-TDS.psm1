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
TDS-GetSession -tdsIp 10.231.237.170

.NOTES
PowerShell global variables only exist within the context of the window. Closing the current
window or opening a new one results in a blank slate.
#>
function TDS-GetSession([Parameter(Mandatory=$true)]$tdsIp) {
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

function TDS-Connect([Parameter(Mandatory=$true)]$tdsIp) {
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

Export-ModuleMember -Function *