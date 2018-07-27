#
# Matthew's global profile for shell configuration
#
# July 2011
#

# Editor
export VISUAL=vim

# Grep
export GREP_OPTIONS="--color=auto"

# File creation mask
umask ug+rwx


#
# History control
#

export HISTSIZE=200000
export HISTFILESIZE=200000
export HISTIGNORE="rm*:pwd:sudo rm*:&:ls:exit"
export HISTCONTROL=ignoreboth # ignorespace and ignoredups
export HISTTIMEFORMAT="%F %T    "

shopt -s histverify         # Edit before running history
shopt -s histappend         # Append history instead of overwriting history


#
# Other bash shell options
#

set -o ignoreeof            # Disable ^D from closing the shell (because ^D is sometimes screen PageDown)
set -o noclobber            # Don't clobber; I am not sure how I feel about this one

shopt -s extglob            # Enable extended pattern matching
shopt -s checkwinsize       # Check window size after every command
