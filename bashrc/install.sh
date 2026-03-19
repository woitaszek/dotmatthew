#!/bin/bash

#
# Installer for Matthew's Unix dotfiles
#
# This script:
#   1. Symlinks rc/ dotfiles (inputrc, vimrc, screenrc)
#   2. Appends a .bashrc.local sourcing stanza to ~/.bashrc (idempotent)
#   3. Prints guidance for creating the per-machine .bashrc.local symlink
#

MATTHEW_DIR="$HOME/.matthew"


# -------------------------------------
# Symlink rc/ dotfiles
# -------------------------------------

echo "Symlinking rc/ dotfiles..."

for rcfile in inputrc vimrc screenrc; do
    target="$MATTHEW_DIR/rc/$rcfile"
    link="$HOME/.$rcfile"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
        echo "  .$rcfile (already linked)"
    else
        rm -f "$link"
        ln -s "$target" "$link"
        echo "  .$rcfile -> $target"
    fi
done


# -------------------------------------
# Append .bashrc.local stanza to ~/.bashrc
# -------------------------------------

MARKER="# Matthew's dotfiles customization"

if [ -f "$HOME/.bashrc" ] && grep -qF "$MARKER" "$HOME/.bashrc"; then
    echo ""
    echo ".bashrc already contains the dotfiles stanza (skipping)"
else
    echo ""
    echo "Appending dotfiles stanza to ~/.bashrc..."
    cat >> "$HOME/.bashrc" << 'BASHRC_STANZA'

# -------------------------------------
# Matthew's dotfiles customization
# Requires: ln -s ~/.matthew/bashrc/local_SYSTEM.sh ~/.bashrc.local
# This should be the last section of .bashrc
# -------------------------------------
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
BASHRC_STANZA
    echo "  Done."
fi


# -------------------------------------
# Guidance for per-machine profile
# -------------------------------------

echo ""
echo "Available local profiles:"
for profile in "$MATTHEW_DIR"/bashrc/local_*.sh; do
    echo "  $(basename "$profile")"
done

echo ""
if [ -L "$HOME/.bashrc.local" ]; then
    echo ".bashrc.local -> $(readlink "$HOME/.bashrc.local") (already exists)"
else
    echo "Create a per-machine profile symlink:"
    echo "  ln -s ~/.matthew/bashrc/local_SYSTEM.sh ~/.bashrc.local"
fi
echo ""
