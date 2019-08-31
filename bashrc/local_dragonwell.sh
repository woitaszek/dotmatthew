#
# Matthew's profile for 'dragonwell`
# MacBook Pro / Mojave
# November 2018
#

#
# This is 
#   .bashrc.local -> ~/.matthew/bashrc/local_SYSTEM.sh
# It relies on variables and functions defined by 
#   .bashrc.global -> ~/.matthew/bashrc/global.sh
# which should be called before this script.
#

# -------------------------------------
# Prompt Configuration
# -------------------------------------

# Git prompt completion
if [ -e /usr/local/git/contrib/completion/git-completion.bash ]
then
    source /usr/local/git/contrib/completion/git-completion.bash
fi

# Custom bash prompt
PROMPT_HOSTCOLOR="\[\033[0;94m\]"
matthew_prompt


# -------------------------------------
# Path Configuration
# -------------------------------------

# Path overrides for packages
#export PATH="/usr/local/Cellar/postgresql/9.1.1/bin:$PATH"

# Path overrides for source packages installed in /opt


# -------------------------------------
# Application Configuration
# -------------------------------------

# Unison
export UNISONLOCALHOSTNAME=dragonwell

# Mac: use ls with colors
export CLICOLOR="True"

# Vim on Mac: Don't rely on X11
#alias vim="vim -X"

# GNU privacy guard should now be set out-of-repository
#export GNUPGHOME=""


# -------------------------------------
# Google Cloud SDK
# -------------------------------------

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/google-cloud-sdk/path.bash.inc' ]; then . '/opt/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/google-cloud-sdk/completion.bash.inc' ]; then . '/opt/google-cloud-sdk/completion.bash.inc'; fi
