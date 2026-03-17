#
# Matthew's App Install Script (Phase 3)
#
# Installs common applications via winget. Run after cloning the dotmatthew
# repository and configuring the PowerShell profile (Phases 1-2).
#
# This script does NOT require Administrator. Individual winget installs
# may prompt for UAC elevation if needed.
#
# Inspired by Chris's setup scripts.
#
# Note: Some packages use Microsoft Store IDs (e.g. XP99C9G0KRDZ27) instead of
# named winget IDs. Store versions auto-update through the Microsoft Store, which
# is convenient for GUI apps. Use `winget search <name>` to find either format.
#
# Usage:
#   & (Join-Path $HOME ".matthew" "powershell" "install-3-apps.ps1")
#

Write-Host "=== dotmatthew App Install ===" -ForegroundColor Cyan
Write-Host ""

# ── Development ─────────────────────────────────────────────────────────────

# GitHub CLI
Write-Host "Installing GitHub CLI..." -ForegroundColor Yellow
winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements

# Visual Studio Code
Write-Host "Installing VS Code..." -ForegroundColor Yellow
winget install --id Microsoft.VisualStudioCode -e --source winget --accept-package-agreements --accept-source-agreements

# Visual Studio Code Insiders
Write-Host "Installing VS Code Insiders..." -ForegroundColor Yellow
winget install --id Microsoft.VisualStudioCode.Insiders -e --source winget --accept-package-agreements --accept-source-agreements

# Python 3
Write-Host "Installing Python 3.13..." -ForegroundColor Yellow
winget install --id Python.Python.3.13 -e --source winget --accept-package-agreements --accept-source-agreements

# PowerShell Preview
# Write-Host "Installing PowerShell Preview..." -ForegroundColor Yellow
# winget install --id Microsoft.PowerShell.Preview -e --source winget --accept-package-agreements --accept-source-agreements

# Docker Desktop
Write-Host "Installing Docker Desktop..." -ForegroundColor Yellow
winget install --id Docker.DockerDesktop -e --source winget --accept-package-agreements --accept-source-agreements

# Azure Developer CLI
Write-Host "Installing Azure Developer CLI..." -ForegroundColor Yellow
winget install --id Microsoft.Azd -e --source winget --accept-package-agreements --accept-source-agreements

# GitHub Copilot CLI
Write-Host "Installing GitHub Copilot CLI..." -ForegroundColor Yellow
winget install --id GitHub.Copilot -e --source winget --accept-package-agreements --accept-source-agreements

# ── Security ────────────────────────────────────────────────────────────────

# 1Password (Microsoft Store: AgileBits.1Password)
# Write-Host "Installing 1Password..." -ForegroundColor Yellow
# winget install --id XP99C9G0KRDZ27 -e --source msstore --accept-package-agreements --accept-source-agreements

# 1Password CLI
# Write-Host "Installing 1Password CLI..." -ForegroundColor Yellow
# winget install --id AgileBits.1Password.CLI -e --source winget --accept-package-agreements --accept-source-agreements

# ── Productivity ────────────────────────────────────────────────────────────

# PowerToys (Microsoft Store: Microsoft.PowerToys)
Write-Host "Installing PowerToys..." -ForegroundColor Yellow
winget install --id XP89DCGQ3K6VLD -e --source msstore --accept-package-agreements --accept-source-agreements

# Pandoc
Write-Host "Installing Pandoc..." -ForegroundColor Yellow
winget install --id JohnMacFarlane.Pandoc -e --source winget --accept-package-agreements --accept-source-agreements

# ── PowerShell Modules ──────────────────────────────────────────────────────

# Azure PowerShell (uncomment if needed - large install, takes a while)
# Install-Module -Name Az -Scope CurrentUser -Force

# ── Work (uncomment if needed) ──────────────────────────────────────────────

# Visual Studio 2022 Enterprise (requires license)
# Write-Host "Installing Visual Studio 2022 Enterprise..." -ForegroundColor Yellow
# winget install --id Microsoft.VisualStudio.2022.Enterprise -e --source winget --accept-package-agreements --accept-source-agreements

Write-Host ""
Write-Host "=== App Install complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next step (run as Admin):" -ForegroundColor Cyan
Write-Host "  & `"$(Join-Path $HOME '.matthew' 'powershell' 'install-4-system.ps1')`"" -ForegroundColor White
