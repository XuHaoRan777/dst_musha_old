param(
    [switch]$DryRun,
    [switch]$KeepGit
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSCommandPath
$RootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')

function Assert-ModRoot {
    $required = @("modinfo.lua", "modmain.lua", "scripts")
    foreach ($item in $required) {
        $path = Join-Path $RootFull $item
        if (-not (Test-Path -LiteralPath $path)) {
            throw "This script must be placed in the mod root. Missing: $item"
        }
    }
}

function Get-SafeChildPath {
    param([string]$RelativePath)

    $path = [System.IO.Path]::GetFullPath((Join-Path $RootFull $RelativePath))
    $rootPrefix = $RootFull + [System.IO.Path]::DirectorySeparatorChar
    if ($path -ne $RootFull -and -not $path.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove path outside mod root: $RelativePath"
    }
    return $path
}

function Remove-PathIfExists {
    param([string]$RelativePath)

    $path = Get-SafeChildPath $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        return
    }

    if ($DryRun) {
        Write-Host "[DRY-RUN] Remove $RelativePath"
        return
    }

    Remove-Item -LiteralPath $path -Recurse -Force
    Write-Host "Removed $RelativePath"
}

function Remove-RootFilesByFilter {
    param([string]$Filter)

    $items = Get-ChildItem -LiteralPath $RootFull -File -Force -Filter $Filter
    foreach ($item in $items) {
        $relative = $item.Name
        if ($DryRun) {
            Write-Host "[DRY-RUN] Remove $relative"
            continue
        }
        Remove-Item -LiteralPath $item.FullName -Force
        Write-Host "Removed $relative"
    }
}

Assert-ModRoot

$dirsToRemove = @(
    "docs",
    "modinfo_src",
    "tools",
    ".github",
    ".vscode",
    ".idea"
)

if (-not $KeepGit) {
    $dirsToRemove += ".git"
}

$filesToRemove = @(
    ".gitattributes",
    ".gitignore",
    "AGENTS.md",
    "todo.md",
    "README.md",
    "README.txt"
)

foreach ($dir in $dirsToRemove) {
    Remove-PathIfExists $dir
}

foreach ($file in $filesToRemove) {
    Remove-PathIfExists $file
}

Remove-RootFilesByFilter "*.log"
Remove-RootFilesByFilter "*.tmp"
Remove-RootFilesByFilter "*.bak"

if ($DryRun) {
    Write-Host "Dry run complete. No files were removed."
    exit 0
}

$scriptPath = [System.IO.Path]::GetFullPath($PSCommandPath)
if (Test-Path -LiteralPath $scriptPath) {
    $escapedScriptPath = $scriptPath.Replace("'", "''")
    Start-Process -WindowStyle Hidden -FilePath "powershell" -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-Command",
        "Start-Sleep -Milliseconds 500; Remove-Item -LiteralPath '$escapedScriptPath' -Force -ErrorAction SilentlyContinue"
    )
    Write-Host "Cleanup complete. This script will delete itself."
} else {
    Write-Host "Cleanup complete."
}
