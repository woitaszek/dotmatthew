#
# Matthew's profile for 'sanbruno'
# MacBook Air / Whatever
# October 2012
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

PROMPT_HOSTCOLOR="\[\033[0;94m\]"
matthew_prompt


# -------------------------------------
# Path Configuration
# -------------------------------------

# Path overrides for packages
export PATH="/usr/local/Cellar/postgresql/9.1.1/bin:$PATH"

# Path overrides for source packages installed in /opt

# -------------------------------------
# Application Configuration
# -------------------------------------

# Unison
export UNISONLOCALHOSTNAME=sanbruno

# Mac: use ls with colors
export CLICOLOR="True"

# Vim on Mac: Don't rely on X11
#alias vim="vim -X"

# GNU privacy guard... should be set out-of-repository
#export GNUPGHOME=""

# -------------------------------------
# Everything Else
# -------------------------------------


