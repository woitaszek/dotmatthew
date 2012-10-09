#
# Matthew's global prompt colorization support file
#
# July 2011
#

function matthew_prompt
{
    #
    # This function sets the prompt. Before calling this function,
    # the local bash profile script should set the following local 
    # environment variables to an ANSI color string.
    #   PROMPT_HOSTCOLOR
    #

    # I used to use this. The new method is a great improvement!
    #  export PS1="\[\033]0;\u@\h: \w\007\]\[\033[1;32m\]\@ 
    #    \[\033[0m\]\[\033[1;1m\]\[\033[1;31m\]\!\[\033[0m\] [\u@\h \W]\$ "
    local NOCOLOR="\[\033[0m\]"

    #
    # Terminal information for title bars
    #
    if [[ $TERM == xterm* || $OSTYPE == darwin* ]]
    then
        TITLESTR="\[\033]2;\u@\h:\w\a\]"
    else
        TITLESTR=""
    fi

    # 
    # Global checks
    #

    # Set the prompt to red if the user account is not matthew or mattheww
    local PROMPT_USERCOLOR=$NOCOLOR
        [[ "$USER" != "mwoitas" && "$USER" != "matthew" ]] && PROMPT_USERCOLOR="\[\033[1;31m\]"

    # Look at VIFs to determine if this system might be running Xen.
    vif_count=`/sbin/ifconfig 2>/dev/null | grep vif | awk -F. '{print $1}' | sort | uniq  | wc -l`
    if [[ "$vif_count" -gt "0" ]]
    then
        WARNSTR=" [\[\033[4;41m\]XEN${NOCOLOR}]"
    else
        WARNSTR=""
    fi
    
    # Determine if __git_ps1 is available
    type -t __git_ps1 > /dev/null
    if [[ "$?" -eq "0" ]]
    then
        local GITSTR="\$(__git_ps1 \" \[\033[0;33m\]%s${NOCOLOR}\")"
    else
        local GITSTR=""
    fi

    #
    # Prompt construction
    #

    # Build the prompt components, wrapping prompt commands in colors
    local TIMESTR="\[\033[0;32m\]\@${NOCOLOR}"          # Light green time
    local HISTSTR="\[\033[0;90m\]\!${NOCOLOR}"          # Light grey history
    local USERSTR="${PROMPT_USERCOLOR}\u${NOCOLOR}"     # User color as determined above
    local HOSTSTR="${PROMPT_HOSTCOLOR}\h${NOCOLOR}"     # Host color from environment
    local DIRSTR="\W"

    # Create the general prompt, and set the command to choose between a
    # good (return = 0) and bad (return != nonzero) version.
    PROMPT_CONTENT="${TITLESTR}${TIMESTR}${WARNSTR} ${HISTSTR} [${USERSTR}@${HOSTSTR} ${DIRSTR}${GITSTR}]"
    PROMPT_GOOD="${PROMPT_CONTENT}\$ "
    PROMPT_BAD="${PROMPT_CONTENT}\[\033[0;31m\]\$${NOCOLOR} "
    export PROMPT_COMMAND='[ $? = 0 ] && PS1=$PROMPT_GOOD || PS1=$PROMPT_BAD'

}

