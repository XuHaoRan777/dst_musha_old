param(
    [switch]$Check
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SourceRoot = Join-Path $RepoRoot "modinfo_src"
$OutputPath = Join-Path $RepoRoot "modinfo.lua"

$OptionFiles = @(
    "options/language.lua",
    "options/keys.lua",
    "options/difficulty.lua",
    "options/recipes.lua",
    "options/character.lua",
    "options/visual.lua",
    "options/containers.lua",
    "options/misc.lua"
)

function Invoke-LuaSyntaxCheck($paths) {
    $luac = Get-Command luac -ErrorAction SilentlyContinue
    if ($null -eq $luac) {
        throw "luac was not found in PATH. Install Lua and make sure luac -p is available."
    }

    $existingPaths = @()
    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Cannot run luac; missing file: $path"
        }
        $existingPaths += $path
    }

    & $luac.Source -p @existingPaths
    if ($LASTEXITCODE -ne 0) {
        throw "Lua syntax check failed."
    }
}

function Read-SourceFile($relativePath) {
    $path = Join-Path $SourceRoot $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing modinfo source file: $relativePath"
    }
    return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8).TrimEnd()
}

function Read-OptionFile($relativePath) {
    $content = (Read-SourceFile $relativePath).Trim()
    $match = [regex]::Match($content, '^\s*return\s*\{(?<body>[\s\S]*)\}\s*$')
    if (-not $match.Success) {
        throw "Option source must be a standalone Lua table: $relativePath"
    }
    $body = $match.Groups["body"].Value
    $body = [regex]::Replace($body, '^\r?\n', '')
    $body = [regex]::Replace($body, '\r?\n\s*$', '')
    return $body
}

$parts = New-Object System.Collections.Generic.List[string]
$parts.Add((Read-SourceFile "meta.lua"))
$parts.Add("")
$parts.Add("configuration_options =")
$parts.Add("{")

foreach ($optionFile in $OptionFiles) {
    $parts.Add((Read-OptionFile $optionFile))
}

$parts.Add("} ")

$content = [string]::Join("`n", $parts) + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$LuaSourcePaths = @((Join-Path $SourceRoot "meta.lua"))
foreach ($optionFile in $OptionFiles) {
    $LuaSourcePaths += (Join-Path $SourceRoot $optionFile)
}

if ($Check) {
    if (-not (Test-Path -LiteralPath $OutputPath)) {
        throw "modinfo.lua does not exist"
    }

    $current = [System.IO.File]::ReadAllText($OutputPath, [System.Text.Encoding]::UTF8)
    if ($current -ne $content) {
        throw "modinfo.lua is out of date. Run tools/build_modinfo.ps1"
    }

    Invoke-LuaSyntaxCheck ($LuaSourcePaths + @($OutputPath))
    Write-Output "modinfo.lua is up to date."
    Write-Output "Lua syntax check passed."
    exit 0
}

[System.IO.File]::WriteAllText($OutputPath, $content, $utf8NoBom)
Invoke-LuaSyntaxCheck ($LuaSourcePaths + @($OutputPath))
Write-Output "Generated modinfo.lua from modinfo_src."
Write-Output "Lua syntax check passed."
