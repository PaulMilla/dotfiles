[CmdletBinding()]
param (
    [Parameter()]
    [string]
    # If needed use the 'Enterprise Suggestions Token Generator' tool at \\substratetools\Tools\TokenGenerator
    # targeting resource '059671f7-fa93-4e61-b81d-0df27627df96' for Exp Control Tower tokens
    $bearerToken = "",

    [Parameter()]
    [string]
    # TODO: Where does this come from?
    # Best reference I've been able to find is https://mdl/HomePublish for 'OutlookMonarch'
    $workspace = "a5766fee-9478-488b-9fc0-64d1ad72c290",

    [Parameter()]
    [string]
    $metricSetName = "OutlookMonarch",

    [Parameter()]
    [string]
    $progressUrl = "https://exp.microsoft.com/Analysis/Details?stepId=953654da-e5e7-432d-900f-0c5b2b9ec618&studyId=2534090"
)


Function Get-JsonContent ([string] $uri) {
    $headers = @{
        "Authorization" = "Bearer $bearerToken"
    }
    $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -ErrorAction 'Stop' -Headers $headers
    if ($response.StatusCode -ge 400) {
        throw $response
    }

    $content = $response.Content | ConvertFrom-Json
    return $content
}


Function Get-PreviewScorecardTask([string] $progressUrl)
{
    $uri = [System.Uri]"$progressUrl"
    $parsedQueryString = [System.Web.HttpUtility]::ParseQueryString($uri.Query)
    $stepId = $parsedQueryString['stepId']
    $studyId = $parsedQueryString['studyId']

    $content = Get-JsonContent "https://exp.microsoft.com/api/analysis/steps/${stepId}/studyAbstracts/${studyId}?includeTasks=true&json"
    $taskInfo = $content.AnalysisTaskAbstracts | Where-Object { $_.ExecutionConfiguration.ScorecardPurposeUsedForPrioritization -eq 'PreviewScorecard' } | Select-Object -First 1
    return $taskInfo.TaskId
}


Function Get-ExpTaskLogs([string] $taskId)
{
    return Get-JsonContent "https://exp.microsoft.com/api/analysis/tasks/$taskId/logs?includePipelineJournalLogs=true&json"
}

Function Get-GeneratedScriptFromLogs($logs)
{
    $scriptGeneratedLogs = $logs | Where-Object { @('CosmosJobQueued', 'CosmosJobRunning', 'JobCompleted').Contains($_.State)  } | Select-Object -ExpandProperty 'EntryComment'
    
    if ([string]::IsNullOrWhiteSpace($scriptGeneratedLogs))
    {
        return $null
    } 

    $foo = $scriptGeneratedLogs | Select-String -Pattern "JobLink = <a href='((http[s]?|[s]?ftp[s]?)(:\/\/)([^\s,]+))'" | Select-Object -First 1
    return $foo.Captures[0]
}

$expTaskId = Get-PreviewScorecardTask($progressUrl)
$logs = Get-ExpTaskLogs($expTaskId)
Write-Output $logs | Format-Table State,LogOrigin,EntryTime,EntryComment -Wrap

$generatedScriptUrl = Get-GeneratedScriptFromLogs($logs) 

Write-Output @"
To see generated foray script see: $generatedScriptUrl
"@