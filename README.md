# dotmatthew

This repository contains my personal environment configuration files
accumulated over the years.

## Structure

```text
.matthew/
├── bashrc/          # Bash profile (modular: global + per-machine local_*.sh)
├── rc/              # Unix dotfiles (gitconfig, vimrc, inputrc, screenrc)
├── zshrc/           # Zsh configuration
├── Library/         # macOS KeyBindings
├── scripts/         # Bash/Python utility scripts
├── powershell/      # PowerShell profile, scripts, and Oh My Posh theme
└── install_rc.sh    # Bash/Unix dotfile installer (symlinks rc/ files)
```

## Installation

### Bash/Unix

Clone the repo and run the symlink installer:

```bash
git clone https://github.com/woitaszek/dotmatthew.git ~/.matthew
~/.matthew/install_rc.sh
```

Then symlink the appropriate local profile for your machine:

```bash
ln -s ~/.matthew/bashrc/local_SYSTEMNAME.sh ~/.bashrc.local
```

### PowerShell (Windows & macOS)

See [powershell/README.md](powershell/README.md) for the two-phase setup:
bootstrap a fresh Windows PC, then configure your PowerShell profile.
