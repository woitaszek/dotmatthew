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

# ── PowerShell Modules ──────────────────────────────────────────────────────

# We install these as AllUsers so they don't clutter up the profile
# that roams via OneDrive because some files trigger Defender alerts

# CompletionPredictor - feeds tab-completion results into PSReadLine inline suggestions
Write-Host "Installing CompletionPredictor..." -ForegroundColor Yellow
Install-Module -Name CompletionPredictor -Scope AllUsers -Force

# Azure PowerShell (large install, takes a while)
Write-Host "Installing Azure PowerShell..." -ForegroundColor Yellow
Install-Module -Name Az -Scope AllUsers -Force

# ── Done ────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== System Config complete ===" -ForegroundColor Green
