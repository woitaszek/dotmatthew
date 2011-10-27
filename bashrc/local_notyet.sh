#
# Matthew's profile for 'notyet'
# MacBook Pro / Snow Leopard
# July 2011
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
export PATH="/Library/Frameworks/Python.framework/Versions/2.6/bin:${PATH}"
export PATH="/usr/local/git/bin:${PATH}"
export PATH="/Library/PostgreSQL/8.4/bin:${PATH}"

# Path overrides for source packages installed in /opt
export PATH="/opt/ruby-1.9.2-p290/bin:$PATH"
export PATH="/opt/swift-0.9/bin:${PATH}"


# -------------------------------------
# Application Configuration
# -------------------------------------

# Unison
export UNISONLOCALHOSTNAME=decaf

# Mac: use ls with colors
export CLICOLOR="True"

# Vim on Mac: Don't rely on X11
alias vim="vim -X"

# GNU privacy guard... should be set out-of-repository
#export GNUPGHOME=""

#
# Globus 
#

# Globus 4.0.x
#export GLOBUS_LOCATION=/opt/globus-4.0.8
#source /opt/globus-4.0.8/etc/globus-user-env.sh 

# Globus 5.0.x
export GLOBUS_LOCATION=/opt/globus-5.0.2
source $GLOBUS_LOCATION/etc/globus-user-env.sh


# -------------------------------------
# Everything Else
# -------------------------------------

# Ruby Version Manager (rvm)
#[[ -s "/Users/matthew/.rvm/scripts/rvm" ]] && source "/Users/matthew/.rvm/scripts/rvm"



