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
# ack-grep options
#

export ACK_OPTIONS="--flush --color"

function djangotail() {
    tail -n -20 -f $@ | \
    ack-grep --color-match="green" "celery:" | \
    ack-grep --color-match="blue" " DEBUG.*" | \
    ack-grep --color-match="yellow" " WARN.*" | \
    ack-grep --color-match="red" " ERROR.*" | \
    ack-grep --color-match="white on_magenta" " CRITICAL.*" | \
    ack-grep --color-match="white on_red" -i "assert.*| except.*" | \
    ack-grep --color-match="green" "urlhash=\S+"
}

function nginxtail() {
    tail -n -20 -f $@ | \
    ack-grep --color-match "green"  "(GET|POST|HEAD).* HTTP/1.1\" 2.. " | \
    ack-grep --color-match "blue"   "(GET|POST|HEAD).* HTTP/1.1\" 3.. " | \
    ack-grep --color-match="yellow" "(GET|POST|HEAD).* HTTP/1.1\" 4.. " | \
    ack-grep --color-match="red"    "(GET|POST|HEAD).* HTTP/1.1\" 5.. " 
}

