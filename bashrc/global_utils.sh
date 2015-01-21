#
# Matthew's global profile for utility configuration
#
# October 2012
#

# -------------------------------------
# Git
# -------------------------------------

# Source new-style git prompt preparation
if [ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]
then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
elif [ -e /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh ]
then
    source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
elif [ -e /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh ]
then
    source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
fi

# Source the git-completion library for use when constructing
# the prompt.
if [ -e /usr/share/doc/git-1.8.3.1/contrib/completion/git-completion.bash ]
then
    source /usr/share/doc/git-1.8.3.1/contrib/completion/git-completion.bash
elif [ -e /usr/share/git-core/git-completion.bash ]
then
    # Works on macs
    source /usr/share/git-core/git-completion.bash
elif [ -e /usr/local/git/contrib/completion/git-completion.bash ]
then
    # Second choice -- exists but no __git_ps1 on Macs
    source /usr/local/git/contrib/completion/git-completion.bash
elif [ -e /etc/bash_completion.d/git ]
then
    # CentOS, Fedora, RHEL systems
    source /etc/bash_completion.d/git
fi


# -------------------------------------
# Everything Else
# -------------------------------------

