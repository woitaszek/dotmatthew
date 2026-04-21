# dotmatthew

This repository contains my personal environment configuration files
accumulated over the years.

## Structure

```text
.matthew/
├── bashrc/          # Bash profile, installer, and per-machine local_*.sh files
├── rc/              # Unix dotfiles (vimrc, inputrc, screenrc)
├── zshrc/           # Zsh configuration
├── Library/         # macOS KeyBindings
├── scripts/         # Bash/Python utility scripts
├── powershell/      # PowerShell profile, scripts, and Oh My Posh theme
└── ssh-git/         # SSH keys, Git identity, and commit signing (Windows + WSL)
```

## Bash/Unix

Modular bash profile with shared globals and per-machine overrides.
See [bashrc/README.md](bashrc/README.md) for installation and architecture.

## PowerShell (Windows & macOS)

PowerShell profile, scripts, and Oh My Posh theme for Windows and macOS.
See [powershell/README.md](powershell/README.md) for the multi-phase setup.

## Zsh

Standalone zsh configuration with a custom prompt and tab-completion styling.
See [zshrc/README.md](zshrc/README.md) for installation.

## macOS KeyBindings

Remaps Home/End keys for line and document navigation on macOS.
See [Library/README.md](Library/README.md) for installation.

## SSH and Git Signing

Cross-platform Git identity, SSH key management, and 1Password commit
signing for Windows and WSL.
See [ssh-git/README.md](ssh-git/README.md) for the architecture and installers.
