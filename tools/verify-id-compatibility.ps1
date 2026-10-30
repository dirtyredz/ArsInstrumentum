param(
    [Parameter(Mandatory = $true)]
    [string] $BaselineJar,

    [Parameter(Mandatory = $true)]
    [string] $CandidateJar,

    [Parameter(Mandatory = $true)]
    [string] $ReportPath
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-ZipEntries([string] $Path) {
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        return @($archive.Entries | Where-Object { -not [string]::IsNullOrEmpty($_.Name) } | ForEach-Object { $_.FullName })
    }
    finally {
        $archive.Dispose()
    }
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

function Get-RegistrationBytecode([string] $Jar) {
    $output = & javap -classpath $Jar -c -p de.sarenor.arsinstrumentum.setup.Registration 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "javap failed for $Jar`n$($output -join "`n")"
    }
    return $output -join "`n"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseline = Get-Content -LiteralPath (Join-Path $repoRoot '.ci/compatibility-baseline.json') -Raw | ConvertFrom-Json
$actualHash = (Get-FileHash -LiteralPath $BaselineJar -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $baseline.sha256) {
    throw "Unexpected baseline SHA-256: $actualHash"
}

$baselineEntries = Get-ZipEntries $BaselineJar
$candidateEntries = Get-ZipEntries $CandidateJar
$candidateEntrySet = [System.Collections.Generic.HashSet[string]]::new([string[]] $candidateEntries)

$baselineDataIds = @($baselineEntries | ForEach-Object { ConvertTo-DataId $_ } | Where-Object { $_ } | Sort-Object -Unique)
$candidateDataIds = @($candidateEntries | ForEach-Object { ConvertTo-DataId $_ } | Where-Object { $_ } | Sort-Object -Unique)
$candidateDataSet = [System.Collections.Generic.HashSet[string]]::new([string[]] $candidateDataIds)
$missingData = @($baselineDataIds | Where-Object { -not $candidateDataSet.Contains($_) })

$baselineBytecode = Get-RegistrationBytecode $BaselineJar
$candidateBytecode = Get-RegistrationBytecode $CandidateJar
$missingRegistries = [System.Collections.Generic.List[string]]::new()

foreach ($id in $baseline.registries.items) {
    if (-not $candidateBytecode.Contains("// String $id")) {
        $missingRegistries.Add("item ars_instrumentum:$id (registration literal missing)")
    }
    if (-not $candidateEntrySet.Contains("assets/ars_instrumentum/models/item/$id.json")) {
        $missingRegistries.Add("item ars_instrumentum:$id (item model missing)")
    }
}
foreach ($id in $baseline.registries.blocks) {
    if (-not $candidateBytecode.Contains("// String $id")) {
        $missingRegistries.Add("block ars_instrumentum:$id (registration literal missing)")
    }
    if (-not $candidateEntrySet.Contains("assets/ars_instrumentum/blockstates/$id.json")) {
        $missingRegistries.Add("block ars_instrumentum:$id (blockstate missing)")
    }
}
foreach ($id in $baseline.registries.block_entities) {
    if (-not $candidateBytecode.Contains("// String $id")) {
        $missingRegistries.Add("block entity ars_instrumentum:$id")
    }
}

foreach ($category in @('items', 'blocks', 'block_entities')) {
    foreach ($id in $baseline.registries.$category) {
        if (-not $baselineBytecode.Contains("// String $id")) {
            throw "Compatibility manifest does not match baseline bytecode: $category $id"
        }
    }
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Ars Instrumentum 4.1.0 to 5.0.0 ID compatibility')
$lines.Add('')
$lines.Add("- Baseline: ``$([System.IO.Path]::GetFileName($BaselineJar))``")
$lines.Add("- Baseline SHA-256: ``$actualHash``")
$lines.Add("- Candidate: ``$([System.IO.Path]::GetFileName($CandidateJar))``")
$lines.Add("- Registry IDs checked: $((@($baseline.registries.items).Count + @($baseline.registries.blocks).Count + @($baseline.registries.block_entities).Count))")
$lines.Add("- Data IDs checked: $($baselineDataIds.Count)")
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
$lines.Add($(if ($passed) { 'PASS - every 4.1.0 registry and normalized recipe/data ID is present.' } else { 'FAIL - compatibility gaps remain.' }))

$reportDirectory = Split-Path -Parent $ReportPath
if (-not (Test-Path -LiteralPath $reportDirectory)) {
    New-Item -ItemType Directory -Path $reportDirectory | Out-Null
}
[System.IO.File]::WriteAllLines($ReportPath, $lines)
$lines | ForEach-Object { Write-Output $_ }

if (-not $passed) { exit 1 }
