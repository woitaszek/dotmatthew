#
# install-windows.ps1
# Configure Git identity, SSH keys, and commit signing for Windows.
#
# Renders templates from windows/ and common/ with auto-detected defaults,
# shows a diff against any existing config, and prompts before writing.
#
# Usage:
#   & (Join-Path $HOME ".matthew" "ssh-git" "install-windows.ps1")
#

$ErrorActionPreference = 'Stop'

$ScriptDir = $PSScriptRoot

# ── Helper functions ────────────────────────────────────────────────────────

function Write-Info    { param([string]$Msg) Write-Host $Msg -ForegroundColor Cyan }
function Write-Success { param([string]$Msg) Write-Host $Msg -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host $Msg -ForegroundColor Yellow }
function Write-Err     { param([string]$Msg) Write-Host "ERROR: $Msg" -ForegroundColor Red }

function Read-Var {
    param(
        [string]$Prompt,
        [string]$Default = ''
    )

    if ($Default) {
        $input = Read-Host "$Prompt [$Default]"
    } else {
        $input = Read-Host $Prompt
    }

    if ([string]::IsNullOrWhiteSpace($input)) { $input = $Default }
    return $input
}

function Read-YesNo {
    param(
        [string]$Prompt,
        [string]$Default = 'n'
    )

    $hint = if ($Default -eq 'y') { 'Y/n' } else { 'y/N' }
    $input = Read-Host "$Prompt [$hint]"
    if ([string]::IsNullOrWhiteSpace($input)) { $input = $Default }
    return $input -match '^[Yy]'
}

function Invoke-RenderTemplate {
    param(
        [string]$TemplatePath,
        [hashtable]$Vars
    )

    $content = Get-Content $TemplatePath -Raw
    foreach ($key in $Vars.Keys) {
        $content = $content -replace [regex]::Escape("{{$key}}"), $Vars[$key]
    }
    return $content
}

function Invoke-DiffAndInstall {
    param(
        [string]$Rendered,
        [string]$TargetPath,
        [string]$Description
    )

    Write-Host ""
    Write-Host "── $Description ──" -ForegroundColor White
    Write-Host "  Target: $TargetPath"

    $targetDir = Split-Path $TargetPath -Parent
    if (-not (Test-Path $targetDir)) {
        Write-Warn "  Directory $targetDir does not exist."
        if (Read-YesNo "  Create it?") {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Write-Success "  Created $targetDir"
        } else {
            Write-Warn "  Skipping $Description."
            return
        }
    }

    if (Test-Path $TargetPath) {
        $existing = Get-Content $TargetPath -Raw -ErrorAction SilentlyContinue
        if ($existing -eq $Rendered) {
            Write-Success "  Already up to date."
            return
        }

        Write-Info "  Differences from current file:"
        $tmpFile = [System.IO.Path]::GetTempFileName()
        Set-Content -Path $tmpFile -Value $Rendered -NoNewline
        # Show a simple diff using fc (Windows) or Compare-Object
        $existingLines = $existing -split "`n"
        $renderedLines = $Rendered -split "`n"
        $diffs = Compare-Object $existingLines $renderedLines -IncludeEqual |
            Where-Object { $_.SideIndicator -ne '==' }
        foreach ($d in $diffs) {
            if ($d.SideIndicator -eq '<=') {
                Write-Host "  - $($d.InputObject)" -ForegroundColor Red
            } else {
                Write-Host "  + $($d.InputObject)" -ForegroundColor Green
            }
        }
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        Write-Host ""

        if (-not (Read-YesNo "  Apply changes?")) {
            Write-Warn "  Skipped."
            return
        }
    } else {
        Write-Info "  New file (does not exist yet)."
        $preview = ($Rendered -split "`n" | Select-Object -First 20) -join "`n"
        Write-Host $preview
        $lineCount = ($Rendered -split "`n").Count
        if ($lineCount -gt 20) {
            Write-Warn "  ... (truncated)"
        }
        Write-Host ""

        if (-not (Read-YesNo "  Install?")) {
            Write-Warn "  Skipped."
            return
        }
    }

    Set-Content -Path $TargetPath -Value $Rendered -NoNewline
    Write-Success "  Installed."
}

function Invoke-SafeGitConfigInstall {
    param(
        [string]$Rendered,
        [string]$TargetPath,
        [string]$Description
    )

    if (Test-Path $TargetPath) {
        $existing = Get-Content $TargetPath -Raw -ErrorAction SilentlyContinue
        if ($existing -ne $Rendered) {
            $candidatePath = "$TargetPath.dotmatthew-candidate"
            Set-Content -Path $candidatePath -Value $Rendered -NoNewline

            Write-Host ""
            Write-Host "── $Description ──" -ForegroundColor White
            Write-Warn "  Existing config differs; refusing to overwrite it."
            Write-Host "  Current:   $TargetPath"
            Write-Host "  Candidate: $candidatePath"
            Write-Warn "  Move machine-specific settings to ~/.gitconfig.local, merge the candidate manually, or ask an AI assistant for help."
            return $false
        }
    }

    Invoke-DiffAndInstall $Rendered $TargetPath $Description
    if (-not (Test-Path $TargetPath)) { return $false }

    $installed = Get-Content $TargetPath -Raw -ErrorAction SilentlyContinue
    return $installed -eq $Rendered
}

# ── Auto-detection ──────────────────────────────────────────────────────────

function Get-DetectedGitName {
    try { git config --global user.name 2>$null } catch { '' }
}

function Get-DetectedEmailWork {
    try { git config --global user.email 2>$null } catch { '' }
}

function Get-DetectedEmailPersonal {
    $personalConfig = Join-Path $HOME ".gitconfig-personal"
    if (Test-Path $personalConfig) {
        $match = Select-String -Path $personalConfig -Pattern '^\s*email\s*=\s*(.+)$' |
            Select-Object -First 1
        if ($match) { return $match.Matches.Groups[1].Value.Trim() }
    }
    return ''
}

function Get-DetectedSigningKey {
    try { git config --global user.signingkey 2>$null } catch { '' }
}

function Get-DetectedProfileSetting {
    param(
        [string]$ConfigPath,
        [string]$Setting
    )

    if (Test-Path $ConfigPath) {
        $match = Select-String -Path $ConfigPath -Pattern "^\s*$Setting\s*=\s*(.+)$" |
            Select-Object -First 1
        if ($match) { return $match.Matches.Groups[1].Value.Trim() }
    }

    return ''
}

function Get-DetectedAlternateSigningKey {
    param([string]$DefaultSigningKey)

    try {
        foreach ($agentKey in ssh-add -L 2>$null) {
            $candidateKey = ConvertTo-PublicKey $agentKey
            if ($candidateKey -ne $DefaultSigningKey) { return $candidateKey }
        }
    } catch { }

    return ''
}

function Get-DetectedReposDir {
    param(
        [string]$IncludedConfigPath,
        [string]$GitConfigPath = (Join-Path $HOME ".gitconfig")
    )

    if (Test-Path $GitConfigPath) {
        $candidate = ''
        foreach ($line in Get-Content $GitConfigPath) {
            if ($line -match '^\s*\[includeIf\s+"gitdir(?:/i)?:([^"]+)"\]\s*$') {
                $candidate = $Matches[1] -replace '/\*\*$', ''
                continue
            }

            if ($candidate -and $line -match ('^\s*path\s*=\s*' + [regex]::Escape($IncludedConfigPath) + '\s*$')) {
                return $candidate
            }

            if ($line -match '^\s*\[') { $candidate = '' }
        }
    }
    return ''
}

function Get-DetectedAdditionalProfileName {
    param([string]$GitConfigPath = (Join-Path $HOME ".gitconfig"))

    if (Test-Path $GitConfigPath) {
        foreach ($line in Get-Content $GitConfigPath) {
            if ($line -match '^\s*path\s*=\s*~/\.gitconfig-([A-Za-z0-9][A-Za-z0-9_-]*)\s*$' -and
                $Matches[1] -ne 'personal') {
                return $Matches[1]
            }
        }
    }

    return ''
}

function Test-ProfileName {
    param([string]$ProfileName)

    return $ProfileName -ine 'personal' -and
        $ProfileName -match '^[A-Za-z0-9][A-Za-z0-9_-]*$'
}

function ConvertTo-PublicKey {
    param([string]$SigningKey)

    $parts = (($SigningKey -replace '^key::', '').Trim() -split '\s+')
    if ($parts.Count -lt 2 -or $parts[0] -notmatch '^ssh-') {
        throw "Signing key must be an SSH public key, not a fingerprint or private key path."
    }

    return "$($parts[0]) $($parts[1])"
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

# ── Main ────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== dotmatthew SSH & Git Setup (Windows) ===" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Primary identity ──

Write-Info "Step 1: Primary (work) account"
Write-Host ""

$GitName = Read-Var "  Full name" (Get-DetectedGitName)
if ([string]::IsNullOrWhiteSpace($GitName)) {
    Write-Err "Name is required."; exit 1
}

$EmailWork = Read-Var "  Work email" (Get-DetectedEmailWork)
if ([string]::IsNullOrWhiteSpace($EmailWork)) {
    Write-Err "Work email is required."; exit 1
}

# ── Step 2: Personal identity ──

Write-Host ""
Write-Info "Step 2: Personal account (optional)"
Write-Host ""

$EmailPersonal = ''
$PersonalReposDir = ''
$PersonalBlock = ''

# Default to "y" if a personal config already exists
$personalDefault = if (Test-Path (Join-Path $HOME ".gitconfig-personal")) { 'y' } else { 'n' }

if (Read-YesNo "  Configure a personal Git identity?" $personalDefault) {
    $EmailPersonal = Read-Var "  Personal email" (Get-DetectedEmailPersonal)
    if (-not [string]::IsNullOrWhiteSpace($EmailPersonal)) {
        $detectedPersonalReposDir = Get-DetectedReposDir '~/.gitconfig-personal'
        if ([string]::IsNullOrWhiteSpace($detectedPersonalReposDir)) {
            $detectedPersonalReposDir = '**/wingit-personal'
        }
        $PersonalReposDir = Read-Var "  Personal repos path pattern" $detectedPersonalReposDir
        if (-not [string]::IsNullOrWhiteSpace($PersonalReposDir)) {
            $PersonalBlock = "[includeIf `"gitdir/i:$PersonalReposDir/**`"]`n  path = ~/.gitconfig-personal"
        } else {
            Write-Warn "  No repos directory; skipping includeIf."
        }
    }
}

# ── Step 3: Commit signing ──

Write-Host ""
Write-Info "Step 3: Commit signing"
Write-Host ""

$detectedKey = Get-DetectedSigningKey
if ([string]::IsNullOrWhiteSpace($detectedKey)) {
    try { $detectedKey = (ssh-add -L 2>$null | Select-Object -First 1) } catch { }
}

$SigningKey = Read-Var "  SSH signing key (public key)" $detectedKey
if ([string]::IsNullOrWhiteSpace($SigningKey)) {
    Write-Err "Signing key is required."; exit 1
}
$SigningKey = ConvertTo-PublicKey $SigningKey

# ── Step 4: Additional directory-scoped profile ──

Write-Host ""
Write-Info "Step 4: Additional Git profile (optional)"
Write-Host ""

$ProfileName = ''
$ProfileEmail = ''
$ProfileReposDir = ''
$ProfileSigningKey = ''
$ProfileBlock = ''
$ProfileConfigName = ''
$ProfileConfigPath = ''

$defaultProfileName = Get-DetectedAdditionalProfileName
if ([string]::IsNullOrWhiteSpace($defaultProfileName)) { $defaultProfileName = 'profile' }
$defaultProfileConfigPath = Join-Path $HOME ".gitconfig-$defaultProfileName"
$detectedProfileKey = Get-DetectedProfileSetting $defaultProfileConfigPath 'signingkey'
if ([string]::IsNullOrWhiteSpace($detectedProfileKey)) {
    $detectedProfileKey = Get-DetectedAlternateSigningKey $SigningKey
}
$profileDefault = if ((Test-Path $defaultProfileConfigPath) -or $detectedProfileKey) { 'y' } else { 'n' }

if (Read-YesNo "  Configure another directory-scoped identity and signing key?" $profileDefault) {
    $ProfileName = Read-Var "  Profile name" $defaultProfileName
    if ($ProfileName -ieq 'personal') {
        Write-Err "The profile name 'personal' is reserved."; exit 1
    }
    if (-not (Test-ProfileName $ProfileName)) {
        Write-Err "Profile name may contain only letters, numbers, underscores, and hyphens."; exit 1
    }

    $ProfileConfigName = ".gitconfig-$ProfileName"
    $ProfileConfigPath = Join-Path $HOME $ProfileConfigName
    $ProfileIncludePath = "~/$ProfileConfigName"

    $detectedProfileEmail = Get-DetectedProfileSetting $ProfileConfigPath 'email'
    if ([string]::IsNullOrWhiteSpace($detectedProfileEmail)) { $detectedProfileEmail = $EmailWork }
    $ProfileEmail = Read-Var "  Profile email" $detectedProfileEmail

    $detectedProfileReposDir = Get-DetectedReposDir $ProfileIncludePath
    if ([string]::IsNullOrWhiteSpace($detectedProfileReposDir)) {
        $detectedProfileReposDir = "**/wingit-$ProfileName"
    }
    $ProfileReposDir = Read-Var "  Profile repos path pattern" $detectedProfileReposDir

    $detectedProfileKey = Get-DetectedProfileSetting $ProfileConfigPath 'signingkey'
    if ([string]::IsNullOrWhiteSpace($detectedProfileKey)) {
        $detectedProfileKey = Get-DetectedAlternateSigningKey $SigningKey
    }
    $ProfileSigningKey = Read-Var "  Profile SSH signing key (public key)" $detectedProfileKey

    if ([string]::IsNullOrWhiteSpace($ProfileEmail) -or
        [string]::IsNullOrWhiteSpace($ProfileReposDir) -or
        [string]::IsNullOrWhiteSpace($ProfileSigningKey)) {
        Write-Err "Profile email, repos directory, and signing key are required."; exit 1
    }

    $ProfileSigningKey = ConvertTo-PublicKey $ProfileSigningKey
    $ProfileBlock = "[includeIf `"gitdir/i:$ProfileReposDir/**`"]`n  path = $ProfileIncludePath"
}

$WindowsUser = $env:USERNAME

# ── Summary ──

Write-Host ""
Write-Host "── Configuration ──" -ForegroundColor White
Write-Host "  Name:             $GitName"
Write-Host "  Work email:       $EmailWork"
if (-not [string]::IsNullOrWhiteSpace($EmailPersonal)) {
    Write-Host "  Personal email:   $EmailPersonal"
    Write-Host "  Personal repos:   $PersonalReposDir"
}
Write-Host "  Public key:       $SigningKey"
if (-not [string]::IsNullOrWhiteSpace($ProfileEmail)) {
    Write-Host "  Profile:          $ProfileName"
    Write-Host "  Profile email:    $ProfileEmail"
    Write-Host "  Profile repos:    $ProfileReposDir"
    Write-Host "  Profile key:      $ProfileSigningKey"
}
Write-Host "  Windows user:     $WindowsUser"
Write-Host ""

if (-not (Read-YesNo "Proceed with installation?")) {
    Write-Warn "Aborted."
    exit 0
}

# ── Render and install ──

$vars = @{
    GIT_NAME       = $GitName
    EMAIL_WORK     = $EmailWork
    EMAIL_PERSONAL = $EmailPersonal
    PROFILE_EMAIL  = $ProfileEmail
    SIGNING_KEY    = $SigningKey
    PROFILE_SIGNING_KEY = $ProfileSigningKey
    WINDOWS_USER   = $WindowsUser
    PERSONAL_BLOCK = $PersonalBlock
    PROFILE_BLOCK  = $ProfileBlock
}

# .gitconfig
$rendered = Invoke-RenderTemplate (Join-Path $ScriptDir "windows" "gitconfig.template") $vars
$gitconfigInstalled = Invoke-SafeGitConfigInstall $rendered (Join-Path $HOME ".gitconfig") ".gitconfig (Windows)"
if (-not $gitconfigInstalled) {
    exit 2
}

# .gitconfig-personal
if (-not [string]::IsNullOrWhiteSpace($EmailPersonal)) {
    $rendered = Invoke-RenderTemplate (Join-Path $ScriptDir "common" "gitconfig-personal.template") $vars
    Invoke-DiffAndInstall $rendered (Join-Path $HOME ".gitconfig-personal") ".gitconfig-personal"
}

# Additional directory-scoped profile
if (-not [string]::IsNullOrWhiteSpace($ProfileEmail)) {
    $rendered = Invoke-RenderTemplate (Join-Path $ScriptDir "common" "gitconfig-profile.template") $vars
    Invoke-DiffAndInstall $rendered $ProfileConfigPath $ProfileConfigName
}

# allowed_signers
$publicPrincipals = @($EmailWork, $EmailPersonal) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Select-Object -Unique
$signerLines = @("$($publicPrincipals -join ',') $SigningKey")
if (-not [string]::IsNullOrWhiteSpace($ProfileEmail)) {
    $signerLines += "$ProfileEmail $ProfileSigningKey"
}
$signersContent = ($signerLines -join "`n") + "`n"
Invoke-DiffAndInstall $signersContent (Join-Path $HOME ".ssh" "allowed_signers") ".ssh/allowed_signers"

# ssh config (show template as reference, don't overwrite host entries)
$sshConfigPath = Join-Path $HOME ".ssh" "config"
if (-not (Test-Path $sshConfigPath)) {
    $rendered = Invoke-RenderTemplate (Join-Path $ScriptDir "windows" "ssh-config.template") $vars
    Invoke-DiffAndInstall $rendered $sshConfigPath ".ssh/config"
} else {
    Write-Host ""
    Write-Host "── .ssh/config ──" -ForegroundColor White
    Write-Success "  Already exists; not overwriting host-specific entries."
}

# ── Verification ──

Write-Host ""
Write-Host "── Verification ──" -ForegroundColor White

$n = try { git config --global user.name 2>$null } catch { '(not set)' }
$e = try { git config --global user.email 2>$null } catch { '(not set)' }
$g = try { git config --global gpg.format 2>$null } catch { '(not set)' }
$s = try { git config --global user.signingkey 2>$null } catch { '(not set)' }
Write-Host "  git user.name:  $n"
Write-Host "  git user.email: $e"
Write-Host "  git gpg.format: $g"
Write-Host "  Signing key:    $s"

$agentKeys = try { ssh-add -l 2>$null } catch { '(agent not reachable)' }
Write-Host "  SSH agent keys: $agentKeys"

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host ""
