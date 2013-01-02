#
# Matthew's global profile for utility configuration
#
# October 2012
#

# -------------------------------------
# Git
# -------------------------------------

# Source the git-completion library for use when constructing
# the prompt.
if [ -e /usr/share/git-core/git-completion.bash ]
then
    # First choice -- works on Macs
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

