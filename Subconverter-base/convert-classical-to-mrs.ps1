param(
    [string]$SourceDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "Clash-RuleSet-Classical"),
    [string]$TargetDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "Clash-RuleSet-MRS"),
    [string]$MihomoDir = (Join-Path $PSScriptRoot "mihomo.exe"),
    [switch]$Clean
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

function Get-NormalizedPayloadItem {
    param([string]$RawLine)

    $trimmed = $RawLine.Trim()
    if (-not $trimmed.StartsWith("-")) {
        return $null
    }

    $item = $trimmed.Substring(1).Trim()
    if ($item.StartsWith("'") -and $item.EndsWith("'")) {
        return $item.Substring(1, $item.Length - 2)
    }
    if ($item.StartsWith('"') -and $item.EndsWith('"')) {
        return $item.Substring(1, $item.Length - 2)
    }
    return $item
}

function Analyze-RuleFile {
    param([string]$YamlFile)

    $lines = Get-Content -LiteralPath $YamlFile -Encoding UTF8
    $domainItems = New-Object System.Collections.Generic.List[string]
    $ipcidrItems = New-Object System.Collections.Generic.List[string]
    $unsupportedItems = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }
        if ($trimmed -eq "payload:" -or $trimmed.StartsWith("##") -or $trimmed.StartsWith("#")) {
            continue
        }
        if (-not $trimmed.StartsWith("-")) {
            continue
        }

        $item = Get-NormalizedPayloadItem -RawLine $trimmed
        if ($null -eq $item -or [string]::IsNullOrWhiteSpace($item)) {
            continue
        }

        if ($item -match "^(IP-CIDR|IP-CIDR6),") {
            $parts = $item.Split(',')
            if ($parts.Length -ge 2 -and -not [string]::IsNullOrWhiteSpace($parts[1])) {
                $ipcidrItems.Add($parts[1].Trim())
            } else {
                $unsupportedItems.Add($item)
            }
            continue
        }
        if ($item -match "^([0-9a-fA-F:.]+)/(12[0-8]|1[01][0-9]|[1-9]?[0-9])$") {
            $ipcidrItems.Add($item)
            continue
        }
        if ($item -match "^DOMAIN,(.+)$") {
            $domainItems.Add($Matches[1].Trim())
            continue
        }
        if ($item -match "^DOMAIN-SUFFIX,(.+)$") {
            $domainItems.Add("+." + $Matches[1].Trim())
            continue
        }
        if ($item -match "^(DOMAIN-KEYWORD|DOMAIN-REGEX|GEOSITE|SRC-GEOSITE),") {
            $unsupportedItems.Add($item)
            continue
        }
        if ($item -match ",") {
            $unsupportedItems.Add($item)
            continue
        }

        # Domain behavior supports plain domain values in payload lines.
        $domainItems.Add($item)
    }

    return [PSCustomObject]@{
        DomainItems = $domainItems
        IPCIDRItems = $ipcidrItems
        UnsupportedItems = $unsupportedItems
    }
}

function Write-YamlPayloadFile {
    param(
        [System.Collections.Generic.List[string]]$Items,
        [string]$Path
    )

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.AppendLine("payload:")
    foreach ($item in $Items) {
        $escaped = $item.Replace("'", "''")
        [void]$builder.AppendLine("  - '$escaped'")
    }
    Set-Content -LiteralPath $Path -Encoding UTF8 -Value $builder.ToString()
}

function Convert-RuleSet {
    param(
        [string]$Behavior,
        [string]$SourceFile,
        [string]$TargetFile,
        [string]$ConverterCommand
    )

    $targetParent = Split-Path -Path $TargetFile -Parent
    if (-not (Test-Path -LiteralPath $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    $nativeErrVar = Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue
    $previousNativeErr = $null
    if ($null -ne $nativeErrVar) {
        $previousNativeErr = $PSNativeCommandUseErrorActionPreference
        $PSNativeCommandUseErrorActionPreference = $false
    }

    try {
        & $ConverterCommand convert-ruleset $Behavior yaml $SourceFile $TargetFile
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    } finally {
        if ($null -ne $nativeErrVar) {
            $PSNativeCommandUseErrorActionPreference = $previousNativeErr
        }
    }
}

$sourceRoot = Resolve-NormalizedPath $SourceDir
$targetRoot = Resolve-NormalizedPath $TargetDir
$mihomoRoot = Resolve-NormalizedPath $MihomoDir

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Source directory not found: $sourceRoot"
}

$converterCmd = $null
if (Test-Path -LiteralPath $mihomoRoot -PathType Leaf) {
    $converterCmd = $mihomoRoot
} elseif (Test-Path -LiteralPath $mihomoRoot -PathType Container) {
    $tempExe = Join-Path $env:TEMP "mihomo-ruleset-convert.exe"

    Push-Location $mihomoRoot
    try {
        Write-Host "Building mihomo converter binary..."
        & go build -o $tempExe .
        if ($LASTEXITCODE -ne 0) {
            throw "go build failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }

    $converterCmd = $tempExe
} else {
    throw "Mihomo path not found: $mihomoRoot"
}

if ($Clean -and (Test-Path -LiteralPath $targetRoot)) {
    Remove-Item -LiteralPath $targetRoot -Recurse -Force
}

if (-not (Test-Path -LiteralPath $targetRoot)) {
    New-Item -ItemType Directory -Path $targetRoot | Out-Null
}

$converted = 0
$skipped = 0
$failed = 0
$split = 0
$skippedFiles = New-Object System.Collections.Generic.List[string]
$failedFiles = New-Object System.Collections.Generic.List[string]
$splitFiles = New-Object System.Collections.Generic.List[string]
$ignoredUnsupportedEntries = New-Object System.Collections.Generic.List[object]

$yamlFiles = Get-ChildItem -LiteralPath $sourceRoot -Filter *.yaml -Recurse | Sort-Object FullName

foreach ($file in $yamlFiles) {
    $relative = $file.FullName.Substring($sourceRoot.Length).TrimStart([char[]]"\\/")
    $analysis = Analyze-RuleFile -YamlFile $file.FullName

    $domainCount = $analysis.DomainItems.Count
    $ipcidrCount = $analysis.IPCIDRItems.Count
    $unsupportedCount = $analysis.UnsupportedItems.Count

    if ($domainCount -eq 0 -and $ipcidrCount -eq 0) {
        $skipped++
        $skippedFiles.Add($relative)
        Write-Warning "Skipped unsupported rules (no domain/ipcidr payload): $relative"
        continue
    }

    if ($domainCount -gt 0 -and $ipcidrCount -gt 0) {
        $split++
        $splitFiles.Add($relative)

        $targetParentRel = Split-Path -Path $relative -Parent
        $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($relative)
        $domainOutputName = "$nameWithoutExt.domain.mrs"
        $ipcidrOutputName = "$nameWithoutExt.ipcidr.mrs"

        $domainTargetFile = if ([string]::IsNullOrWhiteSpace($targetParentRel)) {
            Join-Path $targetRoot $domainOutputName
        } else {
            Join-Path (Join-Path $targetRoot $targetParentRel) $domainOutputName
        }
        $ipcidrTargetFile = if ([string]::IsNullOrWhiteSpace($targetParentRel)) {
            Join-Path $targetRoot $ipcidrOutputName
        } else {
            Join-Path (Join-Path $targetRoot $targetParentRel) $ipcidrOutputName
        }

        $domainTempFile = [System.IO.Path]::GetTempFileName()
        $ipcidrTempFile = [System.IO.Path]::GetTempFileName()
        try {
            Write-YamlPayloadFile -Items $analysis.DomainItems -Path $domainTempFile
            Write-YamlPayloadFile -Items $analysis.IPCIDRItems -Path $ipcidrTempFile

            Write-Host "Converting [domain split] $relative -> $domainOutputName"
            $domainOk = Convert-RuleSet -Behavior "domain" -SourceFile $domainTempFile -TargetFile $domainTargetFile -ConverterCommand $converterCmd

            Write-Host "Converting [ipcidr split] $relative -> $ipcidrOutputName"
            $ipcidrOk = Convert-RuleSet -Behavior "ipcidr" -SourceFile $ipcidrTempFile -TargetFile $ipcidrTargetFile -ConverterCommand $converterCmd

            if ($domainOk -and $ipcidrOk) {
                $converted += 2
                if ($unsupportedCount -gt 0) {
                    $ignoredUnsupportedEntries.Add([PSCustomObject]@{ File = $relative; Count = $unsupportedCount; Mode = "split" })
                    Write-Warning "Split with unsupported entries ignored ($unsupportedCount): $relative"
                }
            } else {
                $failed++
                $failedFiles.Add($relative)
                Write-Warning "Failed to split-convert: $relative"
            }
        } finally {
            Remove-Item -LiteralPath $domainTempFile -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $ipcidrTempFile -ErrorAction SilentlyContinue
        }
        continue
    }

    $behavior = if ($domainCount -gt 0) { "domain" } else { "ipcidr" }
    $targetParentRel = Split-Path -Path $relative -Parent
    $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($relative)
    $outputName = if ($behavior -eq "domain") { "$nameWithoutExt.domain.mrs" } else { "$nameWithoutExt.ipcidr.mrs" }
    $targetFile = if ([string]::IsNullOrWhiteSpace($targetParentRel)) {
        Join-Path $targetRoot $outputName
    } else {
        Join-Path (Join-Path $targetRoot $targetParentRel) $outputName
    }
    $singleTempFile = [System.IO.Path]::GetTempFileName()
    $itemsToConvert = if ($behavior -eq "domain") { $analysis.DomainItems } else { $analysis.IPCIDRItems }

    try {
        Write-YamlPayloadFile -Items $itemsToConvert -Path $singleTempFile
        Write-Host "Converting [$behavior] $relative"
        if (Convert-RuleSet -Behavior $behavior -SourceFile $singleTempFile -TargetFile $targetFile -ConverterCommand $converterCmd) {
            $converted++
            if ($unsupportedCount -gt 0) {
                $ignoredUnsupportedEntries.Add([PSCustomObject]@{ File = $relative; Count = $unsupportedCount; Mode = $behavior })
                Write-Warning "Converted with unsupported entries ignored ($unsupportedCount): $relative"
            }
        } else {
            $failed++
            $failedFiles.Add($relative)
            Write-Warning "Failed to convert: $relative"
        }
    } finally {
        Remove-Item -LiteralPath $singleTempFile -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "Conversion complete."
Write-Host "Converted: $converted"
Write-Host "Split:     $split"
Write-Host "Skipped:   $skipped"
Write-Host "Failed:    $failed"
Write-Host "Ignored:   $($ignoredUnsupportedEntries.Count)"

if ($ignoredUnsupportedEntries.Count -gt 0) {
    Write-Host ""
    Write-Host "Ignored unsupported entries:"
    $ignoredUnsupportedEntries | ForEach-Object { Write-Host "- $($_.File) [$($_.Count)]" }
}

if ($splitFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Split files:"
    $splitFiles | ForEach-Object { Write-Host "- $_" }
}

if ($skippedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Skipped files:"
    $skippedFiles | ForEach-Object { Write-Host "- $_" }
}

if ($failedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed files:"
    $failedFiles | ForEach-Object { Write-Host "- $_" }
    exit 1
}
