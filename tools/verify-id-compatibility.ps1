param(
    [string] $RegistryDumpPath = 'build/reports/ars_instrumentum/registry-ids.json',
    [string] $ReportPath = 'build/reports/ars_instrumentum/id-diff.md'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

function Resolve-RepoPath([string] $Path) {
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return Join-Path $repoRoot $Path
}

function ConvertTo-DataId([string] $Entry) {
    if ($Entry -notmatch '^data/([^/]+)/(advancements?|loot_tables?|recipes?|tags/(?:items?|blocks?))/(.+)\.json$') {
        return $null
    }

    $namespace = $Matches[1]
    $kind = $Matches[2] -replace '^advancements$', 'advancement' `
        -replace '^loot_tables$', 'loot_table' `
        -replace '^recipes$', 'recipe' `
        -replace '^tags/items$', 'tags/item' `
        -replace '^tags/blocks$', 'tags/block'
    return "${namespace}:${kind}/$($Matches[3])"
}

function Get-DataIds([string[]] $ResourceRoots) {
    $ids = foreach ($resourceRoot in $ResourceRoots) {
        $dataRoot = Join-Path $resourceRoot 'data'
        if (-not (Test-Path -LiteralPath $dataRoot)) {
            continue
        }

        $resolvedRoot = (Resolve-Path -LiteralPath $resourceRoot).Path.TrimEnd('\', '/')
        Get-ChildItem -LiteralPath $dataRoot -Recurse -File -Filter '*.json' | ForEach-Object {
            $relative = $_.FullName.Substring($resolvedRoot.Length + 1).Replace('\', '/')
            ConvertTo-DataId $relative
        }
    }
    return @($ids | Where-Object { $_ } | Sort-Object -Unique)
}

$registryDumpPath = Resolve-RepoPath $RegistryDumpPath
$reportPath = Resolve-RepoPath $ReportPath
$baseline = Get-Content -LiteralPath (Join-Path $repoRoot '.ci/compatibility-baseline.json') -Raw | ConvertFrom-Json
$provenance = Get-Content -LiteralPath (Join-Path $repoRoot '.ci/port-provenance.json') -Raw | ConvertFrom-Json
$candidate = Get-Content -LiteralPath $registryDumpPath -Raw | ConvertFrom-Json

$missingRegistries = [System.Collections.Generic.List[string]]::new()
foreach ($category in @('items', 'blocks', 'block_entities')) {
    $candidateIds = [System.Collections.Generic.HashSet[string]]::new([string[]] @($candidate.$category))
    foreach ($path in @($baseline.registries.$category)) {
        $id = "ars_instrumentum:$path"
        if (-not $candidateIds.Contains($id)) {
            $missingRegistries.Add("$category $id")
        }
    }
}

$candidateDataIds = Get-DataIds @(
    (Join-Path $repoRoot 'src/generated/resources'),
    (Join-Path $repoRoot 'src/main/resources')
)
$candidateDataSet = [System.Collections.Generic.HashSet[string]]::new([string[]] $candidateDataIds)
$missingData = @($baseline.data | Where-Object { -not $candidateDataSet.Contains($_) })

$baselineRegistryCount = @($baseline.registries.items).Count +
    @($baseline.registries.blocks).Count +
    @($baseline.registries.block_entities).Count
$baselineIdentity = $provenance.baseline
$targetIdentity = $provenance.target

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Ars Instrumentum $($baselineIdentity.version) to $($targetIdentity.version) ID compatibility")
$lines.Add('')
$lines.Add("- Baseline: ``$($baselineIdentity.jar)``")
$lines.Add("- Baseline SHA-256: ``$($baselineIdentity.sha256)``")
$lines.Add("- Candidate registry dump: ``$([System.IO.Path]::GetFileName($registryDumpPath))``")
$lines.Add("- Registry IDs checked: $baselineRegistryCount")
$lines.Add("- Data IDs checked: $(@($baseline.data).Count)")
$lines.Add('')
$lines.Add('## Missing registry IDs')
$lines.Add('')
if ($missingRegistries.Count -eq 0) { $lines.Add('None.') } else { $missingRegistries | ForEach-Object { $lines.Add("- $_") } }
$lines.Add('')
$lines.Add('## Missing recipe/data IDs')
$lines.Add('')
if ($missingData.Count -eq 0) { $lines.Add('None.') } else { $missingData | ForEach-Object { $lines.Add("- $_") } }
$lines.Add('')
$lines.Add('## Result')
$lines.Add('')
$passed = $missingRegistries.Count -eq 0 -and $missingData.Count -eq 0
$lines.Add($(if ($passed) { "PASS - every $($baselineIdentity.version) registry and normalized recipe/data ID is present." } else { 'FAIL - compatibility gaps remain.' }))

$reportDirectory = Split-Path -Parent $reportPath
if (-not (Test-Path -LiteralPath $reportDirectory)) {
    New-Item -ItemType Directory -Path $reportDirectory | Out-Null
}
[System.IO.File]::WriteAllLines($reportPath, $lines)
$lines | ForEach-Object { Write-Output $_ }

if (-not $passed) { exit 1 }
