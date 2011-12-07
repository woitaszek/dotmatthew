#
# Matthew's profile for all other systems
#
# July 2011
#

# -------------------------------------
# Prompt Configuration
# -------------------------------------

# Unconfigured servers are teal by default
PROMPT_HOSTCOLOR="\[\033[0;36m\]"

# For certain hosts, override the colors
hostname_sha=`echo \`hostname\` | shasum | awk '{print $1}'`
case $hostname_sha in

    # primary and secondary servers
    4eb7* )
        PROMPT_HOSTCOLOR="\[\033[0;91;41m\]" # bright red on dark red
        ;;
    8a47* )
        PROMPT_HOSTCOLOR="\[\033[0;93;41m\]" # yellow on dark red
        ;;

    # development stage
    b952* )
        PROMPT_HOSTCOLOR="\[\033[0;30;103m\]" # on yellow
        ;;

    # back-end processing
esac

matthew_prompt


# -------------------------------------
# Local Configuration
# -------------------------------------

