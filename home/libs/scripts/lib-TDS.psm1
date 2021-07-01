<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER tdsIp
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function TDS-GetSession([Parameter(Mandatory=$true)]$tdsIp) {
    # Might need to have PS setup, especially if using CredSSP auth
    ## $ winrm quickconfig
    ## $ Enable-WSManCredSSP -Role client -DelegateComputer * -Force
    if (!(Test-Path variable:global:tdsDict)) {
        $global:tdsDict = @{}
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