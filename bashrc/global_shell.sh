#
# Matthew's global profile for shell configuration
#
# July 2011
#

export VISUAL=vim
export HISTIZE=20000
export GREP_OPTIONS="--color=auto"

# File creation mask
umask ug+rwx

# Bash shell options
shopt -s extglob

# History control
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTIGNORE="rm*:pwd:sudo rm*:&:ls:exit"
export HISTCONTROL=ignoreboth # ignorespace and ignoredups
export HISTTIMEFORMAT="%F %T    "

shopt -s histverify
shopt -s histappend

