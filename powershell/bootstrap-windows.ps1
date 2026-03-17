#
# Matthew's Windows Bootstrap Script (Phase 1)
#
# Copy-paste this into a fresh Windows PowerShell session to install
# prerequisites and clone the dotmatthew repository.
#
# This script is self-contained and does not depend on the repo being present.
#
# Usage (open PowerShell as Administrator, then pick one):
#
#   Option 1 - Download, inspect, then run:
#     irm https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-windows.ps1 -OutFile bootstrap-windows.ps1
#     cat bootstrap-windows.ps1   # review the script
#     .\bootstrap-windows.ps1    # run it
#
#   Option 2 - Run directly (if you trust the source):
#     iex (irm https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-windows.ps1)
#

#Requires -RunAsAdministrator

Write-Host "=== dotmatthew Windows Bootstrap ===" -ForegroundColor Cyan
Write-Host ""

# Install Git
Write-Host "Installing Git..." -ForegroundColor Yellow
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

# Install Windows Terminal
Write-Host "Installing Windows Terminal..." -ForegroundColor Yellow
winget install --id Microsoft.WindowsTerminal -e --source winget --accept-package-agreements --accept-source-agreements

# Install Oh My Posh
Write-Host "Installing Oh My Posh..." -ForegroundColor Yellow
winget install --id JanDeDobbeleer.OhMyPosh -e --source winget --accept-package-agreements --accept-source-agreements

# Install CascadiaCode Nerd Font (required for prompt glyphs)
Write-Host "Installing CascadiaCode Nerd Font..." -ForegroundColor Yellow
oh-my-posh font install CascadiaCode

Write-Host ""
Write-Host "=== Prerequisites installed ===" -ForegroundColor Green
Write-Host ""

# Refresh PATH so git is available in this session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Clone or update the dotmatthew repository
$matthewDir = "$HOME\.matthew"
if (Test-Path $matthewDir) {
    Write-Host "dotmatthew already exists at $matthewDir - pulling latest..." -ForegroundColor Yellow
    git -C $matthewDir pull
} else {
    Write-Host "Cloning dotmatthew to $matthewDir..." -ForegroundColor Yellow
    git clone https://github.com/woitaszek/dotmatthew.git $matthewDir
}

Write-Host ""
Write-Host "=== Bootstrap complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: run the install script to configure your PowerShell profile:" -ForegroundColor Cyan
Write-Host "  & `"$matthewDir\powershell\install.ps1`"" -ForegroundColor White
Write-Host ""
Write-Host "Configure Windows Terminal to use font: 'CascadiaCode Nerd Font'" -ForegroundColor Cyan
