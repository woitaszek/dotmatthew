#!/bin/bash
#
# Matthew's macOS Bootstrap Script (Phase 1)
#
# Run this on a fresh Mac to install prerequisites and clone the
# dotmatthew repository.
#
# This script is self-contained and does not depend on the repo being present.
#
# Usage:
#
#   Option 1 - Download, inspect, then run:
#     curl -fsSL https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-mac.sh -o bootstrap-mac.sh
#     cat bootstrap-mac.sh        # review the script
#     bash bootstrap-mac.sh       # run it
#
#   Option 2 - Run directly (if you trust the source):
#     bash <(curl -fsSL https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-mac.sh)
#

set -euo pipefail

echo "=== dotmatthew macOS Bootstrap ==="
echo ""

# Install Xcode Command Line Tools (required for git and Homebrew)
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key after the CLT installer finishes..."
    read -n 1 -s -r
else
    echo "Xcode Command Line Tools already installed - skipping."
fi

# Verify git is available after CLT install
if ! command -v git &>/dev/null; then
    echo "ERROR: git not found. Please ensure Xcode Command Line Tools installed successfully." >&2
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed - skipping."
fi

# Install Oh My Posh
echo "Installing Oh My Posh..."
brew install jandedobbeleer/oh-my-posh/oh-my-posh

# Install MesloLGS Nerd Font (required for prompt glyphs)
echo "Installing MesloLGS Nerd Font..."
brew install --cask font-meslo-lg-nerd-font

echo ""
echo "=== Prerequisites installed ==="
echo ""

# Clone or update the dotmatthew repository
MATTHEW_DIR="$HOME/.matthew"
if [ -d "$MATTHEW_DIR" ]; then
    echo "dotmatthew already exists at $MATTHEW_DIR - pulling latest..."
    git -C "$MATTHEW_DIR" pull
else
    echo "Cloning dotmatthew to $MATTHEW_DIR..."
    git clone https://github.com/woitaszek/dotmatthew.git "$MATTHEW_DIR"
fi

echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Next steps:"
echo "  1. Run the PowerShell install script to configure your PS profile:"
echo "     & \"\$HOME/.matthew/powershell/install.ps1\""
echo "  2. Or run the bash install script for shell dotfiles:"
echo "     ~/.matthew/install_rc.sh"
echo ""
echo "Configure your terminal font to 'MesloLGS Nerd Font'"
