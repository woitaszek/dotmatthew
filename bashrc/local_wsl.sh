# shellcheck shell=bash
#
# Matthew's bash profile for WSL hosts
#

# This script is sourced via ~/.bashrc.local, which should be a symlink:
#   ln -s ~/.matthew/bashrc/local_wsl.sh ~/.bashrc.local
# The stanza in ~/.bashrc (added by bashrc/install.sh) sources ~/.bashrc.local.


# -------------------------------------
# General configuration
# -------------------------------------

# Load the global bash profile (aliases, git, prompt, shell options)
source ~/.matthew/bashrc/global.sh

# Prompt host color: teal (0;36)
PROMPT_HOSTCOLOR="\[\033[0;36m\]"
matthew_prompt


# -------------------------------------
# Environment
# -------------------------------------

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Add scripts directory to PATH if not already present
SCRIPTS_DIR="$HOME/.matthew/scripts"
if [[ ":$PATH:" != *":$SCRIPTS_DIR:"* ]]; then
    export PATH="$SCRIPTS_DIR:$PATH"
fi


# -------------------------------------
# Windows integration
# -------------------------------------

# Use Windows SSH executables
alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
alias ssh-add='/mnt/c/Windows/System32/OpenSSH/ssh-add.exe'
alias ssh-agent='/mnt/c/Windows/System32/OpenSSH/ssh-agent.exe'
alias scp='/mnt/c/Windows/System32/OpenSSH/scp.exe'
alias sftp='/mnt/c/Windows/System32/OpenSSH/sftp.exe'

# Clipboard (pipe-friendly)
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'

# Open URLs / files in the default Windows browser
if command -v wslview &>/dev/null; then
    export BROWSER="wslview"
fi


# -------------------------------------
# Development tools - Python
# -------------------------------------

# pyenv (Python version manager)
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - bash)"
fi

# uv (Python package manager)
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi


# -------------------------------------
# Development tools - Node.js
# -------------------------------------

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
