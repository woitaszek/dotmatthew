#
# Matthew's profile for Frost cluster
#
# October 2011
#

# -------------------------------------
# Prompt Configuration
# -------------------------------------

# Frost is teal by default
PROMPT_HOSTCOLOR="\[\033[0;36m\]"

# For certain hosts, override the colors
case `hostname` in

    # Administrative servers: white on teal
    fr0105en )
        PROMPT_HOSTCOLOR="\[\033[0;97;46m\]"
        ;;

    # Dangerous servers: teal on dark red
    # fr0105 
    #    PROMPT_HOSTCOLOR="\[\033[0;36;41m\]"
    #    ;;

    # Back-end nodes: teal on dark grey
    # dav*
    #    PROMPT_HOSTCOLOR="\[\033[0;36;100m\]"
    #    ;;
esac

matthew_prompt


# -------------------------------------
# Local Configuration
# -------------------------------------

export GREP_OPTIONS='--color=auto'
export LS_OPTIONS="--color"

# Paths to required support libraries
export PATH="$PATH:/opt/git-1.6.5/bin"

#
# Twister stuff
#

export PATH=/fs/local/apps/nco-3.9.9/bin:$PATH

# Path to JAVA
export JAVA_HOME=/ptmp/mattheww/SwiftSupport/jdk1.6.0_21
export PATH=/ptmp/mattheww/SwiftSupport/jdk1.6.0_21/bin:$PATH


