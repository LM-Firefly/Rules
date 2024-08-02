param(
    [string]$SourceDir = (Split-Path -Parent $PSScriptRoot),
    [string]$TargetDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "Clash-RuleSet-Classical")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-NormalizedPath {
    param([string]$PathValue)

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $PathValue))
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    $normalizedBase = [System.IO.Path]::GetFullPath($BasePath).TrimEnd([char[]]"\\/") + [System.IO.Path]::DirectorySeparatorChar
    $normalizedFull = [System.IO.Path]::GetFullPath($FullPath)

    if (-not $normalizedFull.StartsWith($normalizedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path '$normalizedFull' is not under base '$normalizedBase'"
    }

    return $normalizedFull.Substring($normalizedBase.Length)
}

function Convert-ListContentToYaml {
    param([string[]]$Lines)

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.AppendLine("payload:")

    foreach ($line in $Lines) {
        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            [void]$builder.AppendLine()
            continue
        }

        if ($trimmed -match "^(?i)#(DOMAIN(?:-(?:SUFFIX|KEYWORD|REGEX))?|IP-?CIDR6?|IPCIDR6?)(?:,|$)") {
            [void]$builder.AppendLine("  #  - $($trimmed.Substring(1))")
            continue
        }

        if ($trimmed.StartsWith("#")) {
            [void]$builder.AppendLine("  $trimmed")
            continue
        }

        if ($trimmed -match "^(?i)USER-AGENT,") {
            continue
        }

        [void]$builder.AppendLine("  - $trimmed")
    }

    return $builder.ToString()
}

function Write-TextFileUtf8 {
    param(
        [string]$Path,
        [string]$Content
    )

    $directory = Split-Path -Path $Path -Parent
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8Bom)
}

$sourceRoot = Resolve-NormalizedPath $SourceDir
$targetRoot = Resolve-NormalizedPath $TargetDir

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Source directory not found: $sourceRoot"
}

if (-not (Test-Path -LiteralPath $targetRoot)) {
    New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
}

$converted = 0
$skipped = 0
$excludedRelativePaths = @(
    "Special\sources.list",
    "Special\qBittorrent Search Plugin\Search Plugin.list"
)

$listFiles = Get-ChildItem -LiteralPath $sourceRoot -Filter *.list -File -Recurse | Sort-Object FullName

foreach ($file in $listFiles) {
    $relative = Get-RelativePath -BasePath $sourceRoot -FullPath $file.FullName

    if ($excludedRelativePaths -contains $relative) {
        $targetRelative = [System.IO.Path]::ChangeExtension($relative, ".yaml")
        $targetFile = Join-Path $targetRoot $targetRelative
        if (Test-Path -LiteralPath $targetFile) {
            Remove-Item -LiteralPath $targetFile -Force
        }
        $skipped++
        continue
    }

    if ($relative.StartsWith("Clash-RuleSet-Classical\", [System.StringComparison]::OrdinalIgnoreCase) -or
        $relative.StartsWith("Clash-RuleSet-MRS\", [System.StringComparison]::OrdinalIgnoreCase)) {
        $skipped++
        continue
    }

    if ($relative -ieq "CN-IP.list") {
        $targetRelative = "CN-IP-classical.yaml"
        $legacyTargetFile = Join-Path $targetRoot "CN-IP.yaml"
        if (Test-Path -LiteralPath $legacyTargetFile) {
            Remove-Item -LiteralPath $legacyTargetFile -Force
        }
    } else {
        $targetRelative = [System.IO.Path]::ChangeExtension($relative, ".yaml")
    }

    $targetFile = Join-Path $targetRoot $targetRelative
    $lines = Get-Content -LiteralPath $file.FullName -Encoding UTF8
    $content = Convert-ListContentToYaml -Lines $lines

    Write-TextFileUtf8 -Path $targetFile -Content $content
    $converted++
    Write-Host "Converted $relative -> $targetRelative"
}

Write-Host "Done. Converted: $converted, skipped: $skipped"
