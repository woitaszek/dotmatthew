#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Tests the Windows SSH and Git installer without changing live configuration.
.DESCRIPTION
    Loads installer helpers and exercises profile validation, config detection,
    portable gitdir matching, template rendering, and overwrite refusal using
    temporary files and repositories.
.EXAMPLE
    ./ssh-git/tests/Test-WindowsInstaller.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$InstallerPath = Join-Path $PSScriptRoot '..\install-windows.ps1'
$TemplatePath = Join-Path $PSScriptRoot '..\windows\gitconfig.template'

. $InstallerPath

#region Functions

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]
        $Actual,

        [Parameter(Mandatory = $true)]
        $Expected,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected '$Expected', got '$Actual'."
    }
}

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) { throw $Message }
}

#endregion Functions

#region Main Execution

if ($MyInvocation.InvocationName -ne '.') {
    $TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) "dotmatthew-installer-$([guid]::NewGuid())"

    try {
        New-Item -ItemType Directory -Path $TestRoot -Force | Out-Null

        Assert-True (Test-ProfileName 'work_2') 'A valid profile name was rejected.'
        Assert-True (-not (Test-ProfileName 'personal')) 'The reserved personal profile name was accepted.'
        Assert-True (-not (Test-ProfileName '../escape')) 'An unsafe profile name was accepted.'

        $NormalizedKey = ConvertTo-PublicKey 'key::ssh-ed25519 AAAATEST comment'
        Assert-Equal $NormalizedKey 'ssh-ed25519 AAAATEST' 'Public key normalization failed.'

        $FixtureConfig = Join-Path $TestRoot '.gitconfig'
        Set-Content -Path $FixtureConfig -Value @'
[includeIf "gitdir/i:**/wingit-personal/**"]
  path = ~/.gitconfig-personal
[includeIf "gitdir/i:**/wingit-work/**"]
  path = ~/.gitconfig-work
'@
        Assert-Equal (Get-DetectedReposDir '~/.gitconfig-work' $FixtureConfig) '**/wingit-work' 'Profile path detection failed.'
        Assert-Equal (Get-DetectedAdditionalProfileName $FixtureConfig) 'work' 'Profile name detection failed.'

        $ExistingConfig = Join-Path $TestRoot 'existing.gitconfig'
        $ExistingContent = "[custom]`n  keep = true`n"
        Set-Content -Path $ExistingConfig -Value $ExistingContent -NoNewline
        $InstallResult = Invoke-SafeGitConfigInstall "[managed]`n  value = new`n" $ExistingConfig 'test config'
        Assert-True (-not $InstallResult) 'A differing existing config was not rejected.'
        Assert-Equal (Get-Content $ExistingConfig -Raw) $ExistingContent 'The existing config was modified.'
        Assert-True (Test-Path "$ExistingConfig.dotmatthew-candidate") 'The candidate config was not created.'

        function Read-YesNo { return $false }
        $MissingConfig = Join-Path $TestRoot 'missing.gitconfig'
        $InstallResult = Invoke-SafeGitConfigInstall "[managed]`n  value = new`n" $MissingConfig 'test config'
        Assert-True (-not $InstallResult) 'Declining a new config was reported as success.'
        Assert-True (-not (Test-Path $MissingConfig)) 'A declined config was created.'

        $ProfilePath = Join-Path $TestRoot 'profile.gitconfig'
        Set-Content -Path $ProfilePath -Value "[test]`n  matched = true`n"
        $PatternConfig = Join-Path $TestRoot 'pattern.gitconfig'
        $PortableProfilePath = $ProfilePath -replace '\\', '/'
        Set-Content -Path $PatternConfig -Value "[includeIf `"gitdir/i:**/wingit-anywhere/**`"]`n  path = $PortableProfilePath`n"

        $OriginalGlobalConfig = $env:GIT_CONFIG_GLOBAL
        try {
            $env:GIT_CONFIG_GLOBAL = $PatternConfig
            foreach ($RelativeRepoPath in @('first/wingit-anywhere/repo', 'second/nested/wingit-anywhere/repo')) {
                $RepoPath = Join-Path $TestRoot $RelativeRepoPath
                git init --quiet $RepoPath
                if ($LASTEXITCODE -ne 0) { throw "Could not initialize test repository: $RepoPath" }
                Assert-Equal (git -C $RepoPath config --get test.matched) 'true' "Portable path pattern did not match $RepoPath."
            }
        }
        finally {
            $env:GIT_CONFIG_GLOBAL = $OriginalGlobalConfig
        }

        $Template = Get-Content $TemplatePath -Raw
        Assert-True ($Template -match '(?m)^\s*path\s*=\s*~/\.gitconfig\.local\s*$') 'The Windows template does not include ~/.gitconfig.local.'

        Write-Host 'Windows installer tests: PASS' -ForegroundColor Green
    }
    finally {
        Remove-Item -Path $TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

#endregion Main Execution