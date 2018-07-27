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
# Utility Configuration
# -------------------------------------

# Unison
export UNISONLOCALHOSTNAME=sanbruno.local

# Mac: use ls with colors
export CLICOLOR="True"

# Vim on Mac: Don't rely on X11
#alias vim="vim -X"

# GNU privacy guard... should be set out-of-repository
#export GNUPGHOME=""


# -------------------------------------
# Everything Else
# -------------------------------------

# Setting PATH for Python 3.6
# The original version is saved in .profile.pysave
export PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"

