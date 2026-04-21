#!/bin/bash
# git-ssh-sign.sh — Signing/verification router for WSL + 1Password
#
# Problem: git uses gpg.ssh.program for BOTH signing and verification.
# 1Password's op-ssh-sign-wsl.exe handles signing fine, but garbles
# WSL paths when called for -Y verify / -Y find-principals.
#
# Solution: route signing to 1Password, everything else to ssh-keygen.

OP_SIGN="/mnt/c/Users/{{WINDOWS_USER}}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe"

if [[ "$*" == *"-Y sign"* ]]; then
    exec "${OP_SIGN}" "$@"
else
    exec /usr/bin/ssh-keygen "$@"
fi
