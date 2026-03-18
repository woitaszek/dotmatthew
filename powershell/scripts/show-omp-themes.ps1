[CmdletBinding()]
<#!
.SYNOPSIS
Renders Oh My Posh theme previews for one or more theme directories.

.DESCRIPTION
Enumerates Oh My Posh theme files, prints a labeled preview for each theme,
and leaves extra blank lines between entries so the output is easy to scan in
an interactive terminal session.

By default the script renders the primary prompt only. A ready-to-enable
right-prompt preview block is kept in the script as commented code because it
can be useful when comparing themes that rely heavily on rprompt content.

Theme roots are resolved from one of these sources, in order:
1. The -ThemeRoots argument, when supplied.
2. The POSH_THEMES_PATH environment variable.
3. The workspace-local themes directory when -IncludeWorkspaceThemes is enabled.

.PARAMETER ThemeRoots
One or more directories to search for theme files matching *.omp.*.

.PARAMETER Shell
Shell identifier passed to oh-my-posh print. Defaults to pwsh.

.PARAMETER Force
Passes --force to oh-my-posh so segments render even when the current working
directory would normally hide them.

.PARAMETER IncludeWorkspaceThemes
When set, also searches the sibling ..\themes directory relative to this
script. Defaults to true.

.EXAMPLE
.\show-omp-themes.ps1

Renders themes discovered from POSH_THEMES_PATH and the workspace-local themes
directory.

.EXAMPLE
.\show-omp-themes.ps1 -ThemeRoots .\powershell\themes

Renders themes from the specified directory only.

.EXAMPLE
.\show-omp-themes.ps1 -ThemeRoots $env:POSH_THEMES_PATH -Force

Renders all discovered themes and forces segment output where supported.

.NOTES
This script is intended for interactive prompt comparison. It depends on the
oh-my-posh executable being available on PATH.
#>
param(
    [string[]]$ThemeRoots,
    [string]$Shell = "pwsh",
    [switch]$Force,
    [switch]$IncludeWorkspaceThemes = $true
)

$ErrorActionPreference = "Stop"

# Resolve theme search roots from explicit input, environment defaults, and the
# workspace-local themes folder while deduplicating resolved paths.
function Get-ResolvedThemeRoots {
    param(
        [string[]]$InputRoots,
        [bool]$AddWorkspaceThemes
    )

    $roots = [System.Collections.Generic.List[string]]::new()

    if ($InputRoots) {
        foreach ($root in $InputRoots) {
            if ([string]::IsNullOrWhiteSpace($root)) {
                continue
            }

            $roots.Add($root)
        }
    }
    elseif ($env:POSH_THEMES_PATH) {
        $roots.Add($env:POSH_THEMES_PATH)
    }

    if ($AddWorkspaceThemes) {
        $roots.Add((Join-Path $PSScriptRoot "..\themes"))
    }

    $resolvedRoots = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($root in $roots) {
        try {
            $resolvedRoot = (Resolve-Path -Path $root).Path
        }
        catch {
            Write-Warning "Skipping missing theme root: $root"
            continue
        }

        if ($seen.Add($resolvedRoot)) {
            $resolvedRoots.Add($resolvedRoot)
        }
    }

    return $resolvedRoots
}

# Discover candidate theme files beneath the supplied roots.
function Get-ThemeFiles {
    param([string[]]$Roots)

    $files = foreach ($root in $Roots) {
        Get-ChildItem -Path $root -File -Filter "*.omp.*" | Sort-Object Name
    }

    $files |
        Sort-Object FullName -Unique
}

$themeRoots = Get-ResolvedThemeRoots -InputRoots $ThemeRoots -AddWorkspaceThemes $IncludeWorkspaceThemes.ToBool()

if (-not $themeRoots -or $themeRoots.Count -eq 0) {
    throw "No theme roots were found. Set POSH_THEMES_PATH or pass -ThemeRoots explicitly."
}

$themeFiles = @(Get-ThemeFiles -Roots $themeRoots)

if ($themeFiles.Count -eq 0) {
    throw "No Oh My Posh theme files were found under: $($themeRoots -join ', ')"
}

$ohMyPosh = Get-Command oh-my-posh -ErrorAction Stop

# Invoke the requested Oh My Posh prompt kind for a single theme file.
function Invoke-OhMyPoshRender {
    param(
        [string]$PromptKind,
        [string]$ConfigPath,
        [string]$ShellName,
        [switch]$ForceSegments
    )

    $args = @("print", $PromptKind, "--shell=$ShellName")

    if ($ForceSegments) {
        $args += "--force"
    }

    & $ohMyPosh.Source @args --config $ConfigPath
}

foreach ($themeFile in $themeFiles) {
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor DarkGray
    Write-Host $themeFile.Name -ForegroundColor Cyan
    Write-Host $themeFile.FullName -ForegroundColor DarkGray
    Write-Host ("=" * 80) -ForegroundColor DarkGray

    Write-Host "Primary:" -ForegroundColor Yellow
    Invoke-OhMyPoshRender -PromptKind "primary" -ConfigPath $themeFile.FullName -ShellName $Shell -ForceSegments:$Force

    # Optional right-prompt preview. Kept commented out because primary-only
    # output is easier to scan, but this is useful when evaluating rprompt-heavy
    # themes.
    # $rightPrompt = Invoke-OhMyPoshRender -PromptKind "right" -ConfigPath $themeFile.FullName -ShellName $Shell -ForceSegments:$Force
    # if ($rightPrompt) {
    #     Write-Host ""
    #     Write-Host "Right:" -ForegroundColor Yellow
    #     $rightPrompt
    # }

    Write-Host ""
    Write-Host ""
    Write-Host ""
}