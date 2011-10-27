#
# Matthew's profile for polynya cluster
#
# July 2011
#

# -------------------------------------
# Prompt Configuration
# -------------------------------------

# Polynya is teal by default
PROMPT_HOSTCOLOR="\[\033[0;36m\]"

# For certain hosts, override the colors
case `hostname` in

    # Administrative servers: white on teal
    admin )
        PROMPT_HOSTCOLOR="\[\033[0;97;46m\]"
        ;;

    # Dangerous servers: teal on dark red
    fen01 )
        PROMPT_HOSTCOLOR="\[\033[0;36;41m\]"
        ;;

    # Back-end nodes: teal on dark grey
    dav* | dcs* )
        PROMPT_HOSTCOLOR="\[\033[0;36;100m\]"
        ;;
esac


matthew_prompt


# -------------------------------------
# Local Configuration
# -------------------------------------

