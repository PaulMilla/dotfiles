[CmdletBinding()]
param (
    [Parameter()]
    [string]
    # If needed use the 'Enterprise Suggestions Token Generator' tool at \\substratetools\Tools\TokenGenerator
    # targeting resource 'b998f6f8-79d0-4b6a-8c25-5791dbe49ad0' for Vivace tokens
    $bearerToken = "",

    [Parameter()]
    [string]
    # TODO: Where does this come from?
    # Best reference I've been able to find is https://mdl/HomePublish for 'OutlookMonarch'
    $workspace = "a5766fee-9478-488b-9fc0-64d1ad72c290",

    [Parameter()]
    [string]
    $metricSetName = "OutlookMonarch"
)


Function Get-JsonContent ([string] $uri)
{
    $headers = @{
        "Authorization" = "Bearer $bearerToken"
    }

    try
    {
        $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -Headers $headers -ErrorAction 'Stop'
        $content = $response.Content | ConvertFrom-Json
        return $content
    }
    catch
    {
        throw;
    }
}

Function Get-AllScorecards
{
    return Get-JsonContent "https://vivace.exp.microsoft.com/api/workspaces/$workspace/metricSets/$metricSetName/ScorecardRequests"
}

Function Get-ScorecardLogs($scorecard = "")
{
    if ([string]::IsNullOrWhiteSpace($scorecard))
    {
        $scorecard = Get-AllScorecards | Select-Object -First 1 -ExpandProperty 'name'
    }

    $content = Get-JsonContent "https://vivace.exp.microsoft.com/api/workspaces/$workspace/metricSets/$metricSetName/ScorecardRequests/$scorecard/log"
    return $content
}

Function Get-ProgressUrlFromLogs($logs)
{
    $logMessage = $logs.message | Where-Object { $_.StartsWith("Started the study") }

    if (!$logMessage -or !($logMessage -match '(http[s]?|[s]?ftp[s]?)(:\/\/)([^\s,]+)'))
    {
        return $null
    }

    $progressUrl = $Matches[0]
    return $progressUrl
}

function Get-AlternativeLink ($progressUrl)
{
    $uri = [System.Uri]"$progressUrl"
    $parsedQueryString = [System.Web.HttpUtility]::ParseQueryString($uri.Query)
    return "https://exp.microsoft.com/analysis/$($parsedQueryString['stepId'])/study/$($parsedQueryString['studyId'])"
}

Function Request-BuddyScorecard
{
    $startDate = "2020-11-29 00:00:00"
    $endDate = "2020-11-30 00:00:00"
    $treatmentFlight = "aa-testflight82319:26593"
    $controlFlight = "aa-testflight82319cf:26594"
    $vc = "vc://cosmos14/office.engineering"
    $branchName = "VCBridge_pamilla_outlookMonarch"
    $filePath = "UserDefinedFiles\\Scorecard\\OutlookMonarchCore.UserBased.xml"

    $headers = @{
        "Authorization" = "Bearer $bearerToken"
    }
    $headers = @{
        "X-ExP-SessionId"="ixp2ujpmu"
        "Authorization"="Bearer "
        "Accept"="application/json, text/plain, */*"
        "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.146 Safari/537.36 Edg/88.0.705.62"
        "x-ms-request-id"="05xu6ivysfhi"
        "Request-Id"="|9e73663794fd46cbb72d7f9c5b67f965.8f39abed00ea42fe"
        "Request-Context"="appId=cid-v1:9b19c155-2bb3-485a-91a0-f7f55cd3d68a"
        "Origin"="https://vivace.exp.microsoft.com"
        "Sec-Fetch-Site"="same-origin"
        "Sec-Fetch-Mode"="cors"
        "Sec-Fetch-Dest"="empty"
        "Referer"="https://vivace.exp.microsoft.com/"
        "Accept-Encoding"="gzip, deflate, br"
        "Accept-Language"="en-US,en;q=0.9"
        "Cookie"="at_check=true; MC1=GUID=ec36dd164dec4da7a115d6393a77a5e4&HASH=ec36&LV=202101&V=4&LU=1609884919574; check=true; optimizelyEndUserId=oeu1609912396134r0.16412402893282785; AMCVS_EA76ADE95776D2EC7F000101%40AdobeOrg=1; ARRAffinity=4197d049638650129443eb95780b91c492f4c2f1abaf427620bc221870bc9e93; ARRAffinitySameSite=4197d049638650129443eb95780b91c492f4c2f1abaf427620bc221870bc9e93; ai_user=mkvqL|2021-01-07T22:12:58.820Z; _ga=GA1.2.1463654974.1610574716; MUID=0BCBB00D2E8D6F9C2237BFBA2F436E88; market=US; fptctx2=H3ihr9e92IdW6yd1ZgQ9S%252b%252bPnfKhdBkBGb7PErxi%252bY9%252faoBknaVaJF3Sv%252fCUc9tbVO09wVXKGoPD4uIbhvI%252fVLbcZCHs6Su3u3YMeZtC%252bJ5nQ292jbnNHmIp8tiSW6d1x%252f4dRBIzxnuvmMHSd3UH%252fq8BkA8MigAV2QTTO0NavYAtgML3vr0RDS8XXUL2BTEocRcELyrW%252boBWWIWSZI7Pc%252fe0WuLMC9Caz1LpSLEckiBM1pYdnaS07nB9shNSKRUBFmDkMYX5s2AYlp9OFD1C8qCjxTCsBu3XYw9hgUeHBkI%253d; msdn=L=1033; _cs_c=0; _mkto_trk=id:157-GQE-382&token:_mch-microsoft.com-1612298834519-39177; WRUID=3149470670422320; ARRAffinity=b6463d9e8f20f2a205287f2ad40b6a57f836fd659ec8fba809c4dc9f86d3a033; ARRAffinitySameSite=b6463d9e8f20f2a205287f2ad40b6a57f836fd659ec8fba809c4dc9f86d3a033; aam_uuid=43453108146695720449136650582108982990; aamoptsegs=aam%3D7328310%2Caam%3D12512847%2Caam%3D12322074%2Caam%3D12321304; AMCV_EA76ADE95776D2EC7F000101%40AdobeOrg=1585540135%7CMCIDTS%7C18664%7CMCMID%7C43892105312789418919110740106439501761%7CMCOPTOUT-1612504803s%7CNONE%7CvVersion%7C4.4.0%7CMCAID%7CNONE%7CMCAAMLH-1613102403%7C9%7CMCAAMB-1613102403%7Cj8Odv6LonN4r3an7LhD3WZrU1bUpAkFkkiY1ncBR96t2PTI%7CMCCIDH%7C-411275152%7CMCSYNCSOP%7C411-18669; mbox=PC#c9c24fe9613f42ecbed40944001e989b.35_0#1675742404|session#12a8c15a174a410b97e4aa64caf5e8b4#1612499461; __CT_Data=gpv=4&ckp=tld&dm=microsoft.com&apv_1067_www32=4&cpv_1067_www32=4&rpv_1067_www32=2; MSCC=NR; _cs_id=69f8ef90-67b5-a1ab-be54-b4f151a65d04.1612298834.9.1612550550.1612550550.1594299326.1646462834553.Lax.0; ai_session=QLNZh|1612568972585|1612569287618.015"
    }

    $body = @{
        "startDate" = $startDate;
        "endDate" = $endDate;
        "useIso8601" = $false;
        "useFlightAllocation" = $false;
        "ParamToOverride" = @(
            @{
                "Name" = "TreatmentAssignmentDataSource";
                "Value" = "\`"odinvariantconfigv2\`""; #TODO: do we need the extra quotes?
                "Type" = "System.String";
            },
            @{
                "Name" = "Flights";
                "Value" = "\`"#Flights#\`""; #TODO: do we need the extra quotes?
                "Type" = "System.String";
            }
        );
        "asyncCosmosRun" = $false;
        "primarySegment" = "MKT";
        "secondarySegmentList" = @();
        "isNewExperiment" = $false;
        "description" = "";
        "vcName" = $vc;
        "treatmentFlights" = $treatmentFlight;
        "controlFlights" = $controlFlight;
        "FilePath" = $filePath;
    } | ConvertTo-Json -Depth 5
    $body = "{`"startDate`":`"2020-11-29 00:00:00`",`"endDate`":`"2020-11-30 00:00:00`",`"useIso8601`":false,`"useFlightAllocation`":false,`"ParamToOverride`":[{`"Name`":`"TreatmentAssignmentDataSource`",`"Value`":`"\`"odinvariantconfigv2\`"`",`"Type`":`"System.String`"},{`"Name`":`"Flights`",`"Value`":`"\`"#Flights#\`"`",`"Type`":`"System.String`"}],`"asyncCosmosRun`":false,`"primarySegment`":`"MKT`",`"secondarySegmentList`":[],`"isNewExperiment`":false,`"description`":`"`",`"vcName`":`"vc://cosmos14/office.engineering`",`"treatmentFlights`":`"aa-testflight82319:26593`",`"controlFlights`":`"aa-testflight82319cf:26594`",`"FilePath`":`"UserDefinedFiles\\Scorecard\\OutlookMonarchCore.UserBased.xml`"}"

    $response = Invoke-WebRequest -Uri "https://vivace.exp.microsoft.com/api/workspaces/$workspace/metricSets/$metricSetName/ScorecardRequests?version=$branchName" `
                      -Method "POST" `
                      -Headers $headers `
                      -ContentType "application/json;charset=UTF-8" `
                      -Body $body
    $content = $response.Content
    $scorecardId = $content
    return $scorecardId
}


##### Main ######

$scorecardId = "2021_02_03_21_57_10_712"
$scorecardId = "2021_02_05_23_54_54_132"
#$logs = Get-ScorecardLogs
$logs = Get-ScorecardLogs($scorecardId)

Write-Output $logs | Format-Table date,messageType,stepId,message

$progressUrl = Get-ProgressUrlFromLogs($logs)
$altLink = Get-AlternativeLink($progressUrl)

Write-Output @"
To track progress visit: $progressUrl
Alternative link: $altLink
"@