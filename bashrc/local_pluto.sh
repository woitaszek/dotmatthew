#
# Matthew's profile for 'pluto'
# 
#

#
# This is 
#   .bashrc.local -> ~/.matthew/profile/local_notyet.sh
# It relies on variables and functions defined by 
#   .bashrc.global -> ~/.matthew/profile/global.sh
# which should be called before this script.
#

# -------------------------------------
# Prompt Configuration
# -------------------------------------

if [ -e /usr/local/git/contrib/completion/git-completion.bash ]
then
    source /usr/local/git/contrib/completion/git-completion.bash
fi

PROMPT_HOSTCOLOR="\[\033[0;94m\]"
matthew_prompt


# -------------------------------------
# Path Configuration
# -------------------------------------

# Path overrides for source packages installed in /opt

# -------------------------------------
# Application Configuration
# -------------------------------------

# Unison
export UNISONLOCALHOSTNAME=pluto

# Mac: use ls with colors
export CLICOLOR="True"

# Vim on Mac: Don't rely on X11
#alias vim="vim -X"

# GNU privacy guard... should be set out-of-repository
#export GNUPGHOME=""

# -------------------------------------
# Everything Else
# -------------------------------------


