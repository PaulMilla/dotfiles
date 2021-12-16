[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [String]$defaultCluster = "cosmos14",
    [Parameter(Position=1)]
    [String]$defaultVc = "office.adhoc"
)

# Aliases
${function:Cosmos-GetScubaEventNameCatalog} = { Cosmos-ReadSS -vc "office.engineering" -ssPath "/local/users/pamilla/sample/2021-09-01-Scuba-EventName-Catalog.ss" | Format-Table "EventName","OwaCount","IosCount","AndroidCount","Win32Count"}

# Functions
function Cosmos-TestLogin {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $cluster = $defaultCluster,
        [Parameter()]
        [string] $vc = $defaultVc
    )
    $vcHost = "vc://$cluster/$vc"
    if ($PSVersionTable.PSVersion.Major -gt 5) {
        throw @"
        Cosmos PowerShell works with Windows PowerShell (x64) 5.1 or higher on Windows. PowerShell Core 6.x and later is currently not supported.
        For more info see: https://mscosmos.visualstudio.com/CosmosPowerShell/_wiki/wikis/CosmosPowerShell.wiki/32/Install-Cosmos-PowerShell?anchor=requirements

        To make the PowerShell extension in VSCode use the correct version, make sure to add the following to your settings.json:
            "powershell.powerShellDefaultVersion": "Windows PowerShell (x86)"
"@
    }

    try { Get-Command Test-CosmosFolder | Out-Null }
    catch {
        Write-Error "Please download the powershell module for Cosmos first at:`r`nhttps://mscosmos.visualstudio.com/CosmosPowerShell/_wiki/wikis/CosmosPowerShell.wiki/32/Install-Cosmos-PowerShell"
    }

    try { Test-CosmosFolder "$vcHost/local/" | Out-Null }
    catch {
        Write-Warning "Must be loged in to continue. Attempting login...`r`n Connect-AzAccount -Tenant cdc5aeea-15c5-4db6-b079-fcadd2505dc2 -UseDeviceAuthentication"
        Connect-AzAccount -Tenant cdc5aeea-15c5-4db6-b079-fcadd2505dc2 -UseDeviceAuthentication
    }

    try { Test-CosmosFolder "$vcHost/local/" | Out-Null }
    catch {
        Write-Warning "Could not login to cosmos. Ensure you can login using valid credentials via the following command:`r`n`tConnect-AzAccount -Tenant cdc5aeea-15c5-4db6-b079-fcadd2505dc2"
    }
}

function Cosmos-ReadSS() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ssPath,

        [Parameter()]
        $top = $null,

        [Parameter()]
        [string] $cluster = $defaultCluster,
        [Parameter()]
        [string] $vc = $defaultVc
    )
    Cosmos-TestLogin -cluster $cluster -vc $vc
    $vcHost = "vc://$cluster/$vc"

    if ($null -ne $top) {
        return Export-CosmosStructuredStreamToDataTable -top $top "$vcHost/$ssPath"
    }
    else {
        return Export-CosmosStructuredStreamToDataTable "$vcHost/$ssPath"
    }
}

function Cosmos-ReadFile() {
    param (
        [Parameter(Mandatory = $true)]
        [string] $filePath,

        [Parameter()]
        [string] $cluster = $defaultCluster,
        [Parameter()]
        [string] $vc = $defaultVc
    )
    Cosmos-TestLogin -cluster $cluster -vc $vc
    $vcHost = "vc://$cluster/$vc"

    if ($filePath.EndsWith('.ss')) {
        throw "Cosmos-ReadFile should not be used for a structured stream (.ss), please use Cosmos-ReadSS instead"
    }

    return Get-CosmosStreamContent "$vcHost/$filePath"
}

Export-ModuleMember -Function Cosmos-*