#
# Matthew's global bash profile
#
# July 2011
#
# Thanks To:
#  Tom Mutsdoch
#  Michael Oberg
#  Wes Hofmann

# Get the directory that this script is installed in. It's tricky, because $0
# is often "-bash", and we might be called via a symlink. If we can't get it,
# guess the usual installation location.
if [[ -n "$BASH_SOURCE" ]]
then
    THISDIR=`dirname $(readlink $BASH_SOURCE)`
else
    eval THISDIR="~/.matthew/bashrc" # expand path
    if [ ! -e "$THISDIR" ]
    then
        echo >&2 "$0: Could not identify directory containing Matthew's bashrc profile ($THISDIR)"
    fi
fi

#
# Source global components
#

# Source git support to get __git_ps1, and then prepare the prompt control function
source ${THISDIR}/global_git.sh
source ${THISDIR}/global_prompt.sh

# Source everything else
source ${THISDIR}/global_alias.sh
source ${THISDIR}/global_shell.sh

