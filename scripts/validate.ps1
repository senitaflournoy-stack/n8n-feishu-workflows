$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$workflowDir = Join-Path $projectRoot 'workflows'
$files = Get-ChildItem -LiteralPath $workflowDir -Filter '*.json' -File

if ($files.Count -eq 0) {
    throw 'No workflow JSON files found.'
}

foreach ($file in $files) {
    $workflow = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    if (-not $workflow.name) { throw "$($file.Name): missing name" }
    if (-not $workflow.nodes -or $workflow.nodes.Count -eq 0) { throw "$($file.Name): missing nodes" }
    if ($null -eq $workflow.connections) { throw "$($file.Name): missing connections" }

    $nodeNames = @($workflow.nodes | ForEach-Object { $_.name })
    if (($nodeNames | Sort-Object -Unique).Count -ne $nodeNames.Count) {
        throw "$($file.Name): duplicate node names"
    }

    foreach ($sourceProperty in $workflow.connections.PSObject.Properties) {
        if ($nodeNames -notcontains $sourceProperty.Name) {
            throw "$($file.Name): connection source '$($sourceProperty.Name)' does not exist"
        }

        foreach ($outputGroup in $sourceProperty.Value.main) {
            foreach ($connection in $outputGroup) {
                if ($nodeNames -notcontains $connection.node) {
                    throw "$($file.Name): connection target '$($connection.node)' does not exist"
                }
            }
        }
    }

    Write-Host "OK  $($file.Name)  ($($workflow.nodes.Count) nodes)"
}
