#
# Matthew's global profile for shell configuration
#
# July 2011
#

# Themed xterms
alias xterm="xterm -sl 10000 -sb"
alias xblue="xterm -bg 'dark slate blue' -fg white"
alias xgray="xterm -bg gray  -fg navy"
alias xgreen="xterm -bg black  -fg green"
alias xblack="xterm -bg black  -fg white"
alias xsmall="xterm -bg MediumPurple4 -fg white -fn 9X15"
alias xpurple="xterm -bg MediumPurple4 "
alias xsteel="xterm -bg SteelBlue4 -fg 'misty rose' "

# alias ls="ls --color=auto"


#
# git options
#

alias gitlog="git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"
alias gitgraph="git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short --graph"


#
# ack options
#

export ACK_OPTIONS="--flush --color" # --passthru needed only for tailing

function djangotail() {
    tail -n -20 -f $@ | \
    ack --passthru --color-match="green" "celery:" | \
    ack --passthru --color-match="blue" " DEBUG.*" | \
    ack --passthru --color-match="yellow" " WARN.*" | \
    ack --passthru --color-match="red" " ERROR.*" | \
    ack --passthru --color-match="white on_magenta" " CRITICAL.*" | \
    ack --passthru --color-match="white on_red" -i "assert.*| except.*" | \
    ack --passthru --color-match="green" "urlhash=\S+"
}

function nginxtail() {
    tail -n -20 -f $@ | \
    ack --passthru --color-match "green"  "(GET|POST|HEAD).* HTTP/1.1\" 2.. " | \
    ack --passthru --color-match "blue"   "(GET|POST|HEAD).* HTTP/1.1\" 3.. " | \
    ack --passthru --color-match="yellow" "(GET|POST|HEAD).* HTTP/1.1\" 4.. " | \
    ack --passthru --color-match="red"    "(GET|POST|HEAD).* HTTP/1.1\" 5.. "
}

