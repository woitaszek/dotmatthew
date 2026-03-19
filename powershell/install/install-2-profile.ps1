#
# Matthew's PowerShell Install Script (Phase 2)
#
# Run this after cloning the dotmatthew repository to configure the
# PowerShell profile. Parallels install_rc.sh for bash.
#
# Usage:
#   & (Join-Path $HOME ".matthew" "powershell" "install" "install-2-profile.ps1")
#

$matthewDir = Join-Path $HOME ".matthew"
$globalProfile = Join-Path $matthewDir "powershell" "profile" "global.ps1"

# Verify the repo is present
if (-not (Test-Path $globalProfile)) {
    Write-Error "dotmatthew not found at $matthewDir. Clone it first: git clone https://github.com/woitaszek/dotmatthew.git `"$matthewDir`""
    exit 1
}

# Build the shim content for $PROFILE
$shimContent = @"
# dotmatthew PowerShell profile (https://github.com/woitaszek/dotmatthew)
`$matthewProfile = Join-Path `$HOME ".matthew" "powershell" "profile" "global.ps1"
if (Test-Path `$matthewProfile) {
    . `$matthewProfile
} else {
    Write-Host "dotmatthew not found. Run: git clone https://github.com/woitaszek/dotmatthew.git `$(Join-Path `$HOME '.matthew')" -ForegroundColor Yellow
}
"@

# Check if $PROFILE already sources dotmatthew
if (Test-Path $PROFILE) {
    $existingContent = Get-Content $PROFILE -Raw

    # Warn about existing oh-my-posh invocations that may conflict with global.ps1
    $ompLines = Get-Content $PROFILE | Select-String -Pattern '^\s*oh-my-posh\b' | Where-Object { $_.Line -notmatch '^\s*#' }
    if ($ompLines) {
        Write-Host "WARNING: Existing oh-my-posh invocation(s) found in profile:" -ForegroundColor Yellow
        foreach ($line in $ompLines) {
            Write-Host "  Line $($line.LineNumber): $($line.Line.Trim())" -ForegroundColor Gray
        }
        Write-Host "These may conflict with global.ps1. Consider commenting them out." -ForegroundColor Yellow
        Write-Host ""
    }

    if ($existingContent -match 'dotmatthew') {
        Write-Host "PowerShell profile already references dotmatthew - skipping." -ForegroundColor Yellow
        Write-Host "  $PROFILE" -ForegroundColor Gray
    } else {
        # Append to existing profile
        Add-Content -Path $PROFILE -Value "`n$shimContent"
        Write-Host "Appended dotmatthew loader to existing profile:" -ForegroundColor Green
        Write-Host "  $PROFILE" -ForegroundColor Gray
    }
} else {
    # Create profile directory if needed
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }
    # Write new profile
    Set-Content -Path $PROFILE -Value $shimContent
    Write-Host "Created PowerShell profile with dotmatthew loader:" -ForegroundColor Green
    Write-Host "  $PROFILE" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Install complete. Restart PowerShell or run:" -ForegroundColor Cyan
Write-Host "  . `$PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  Install apps:        & `"$matthewDir\powershell\install\install-3-apps.ps1`"" -ForegroundColor White
Write-Host "  System config (Admin): & `"$matthewDir\powershell\install\install-4-system.ps1`"" -ForegroundColor White
