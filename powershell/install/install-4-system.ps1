#
# Matthew's System Config Script (Phase 4)
#
# System-level configuration that requires Administrator privileges.
# Run after the app install (Phase 3).
#
# Inspired by Chris's setup scripts.
#
# Usage (open PowerShell as Administrator):
#   & (Join-Path $HOME ".matthew" "powershell" "install" "install-4-system.ps1")
#

#Requires -RunAsAdministrator

Write-Host "=== dotmatthew System Config ===" -ForegroundColor Cyan
Write-Host ""

# ── Windows Subsystem for Linux ─────────────────────────────────────────────

Write-Host "Installing WSL..." -ForegroundColor Yellow
wsl --install

# ── Defender Exclusions (dev folders) ────────────────────────────────────────
#
# Consider using a Dev Drive instead, which is automatically trusted by Defender:
#   https://learn.microsoft.com/en-us/windows/dev-drive/
#
# If you still need manual exclusions, uncomment the block below.

# $devExclusions = @(
#     (Join-Path $HOME "dev"),
#     (Join-Path $HOME ".venvs"),
#     "\\wsl$",
#     (Join-Path $env:ProgramFiles "Docker")
# )
#
# Write-Host ""
# Write-Host "Adding Defender exclusions for dev folders..." -ForegroundColor Yellow
# foreach ($path in $devExclusions) {
#     Write-Host "  Excluding: $path" -ForegroundColor Gray
#     Add-MpPreference -ExclusionPath $path
# }

Write-Host ""
Write-Host "=== System Config complete ===" -ForegroundColor Green
