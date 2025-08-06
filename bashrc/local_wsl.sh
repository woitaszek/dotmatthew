#
# Matthew's bash profile for WSL hosts
#

# This script should be sourced by the user's .bashrc file, usually via:
#   .bashrc.local -> ~/.matthew/profile/local_wsl.sh


# -------------------------------------
# General configuration
# -------------------------------------

# Load the general global bashrc files
source ~/.matthew/bashrc/global_git.sh
source ~/.matthew/bashrc/global_prompt.sh
source ~/.matthew/bashrc/global_alias.sh
source ~/.matthew/bashrc/global_shell.sh

# Prompt configuration
PROMPT_HOSTCOLOR="\[\033[0;36m\]"
matthew_prompt


# -------------------------------------
# Windows integration
# -------------------------------------

# Use Windows SSH executables
alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
alias ssh-add='/mnt/c/Windows/System32/OpenSSH/ssh-add.exe'
alias ssh-agent='/mnt/c/Windows/System32/OpenSSH/ssh-agent.exe'
alias scp='/mnt/c/Windows/System32/OpenSSH/scp.exe'
alias sftp='/mnt/c/Windows/System32/OpenSSH/sftp.exe'


# -------------------------------------
# Optional tools
# -------------------------------------

# Enable pyenv if installed
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - bash)"
fi
