#!/bin/bash
# git-credential-manager-wrapper.sh - Resilient GCM locator for WSL
#
# Problem: Windows/Git updates can relocate git-credential-manager.exe
# between architecture-specific folders under "Git for Windows"
# (mingw64 for x64 builds, clangarm64 for ARM64 builds), or it may
# move to cmd/ in future releases. A hardcoded path in .gitconfig
# breaks silently when this happens.
#
# Solution: probe known locations at invocation time instead of
# hardcoding a single path in .gitconfig.

CANDIDATES=(
    "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
    "/mnt/c/Program Files/Git/clangarm64/bin/git-credential-manager.exe"
    "/mnt/c/Program Files/Git/cmd/git-credential-manager.exe"
)

# Run the first candidate that exists and is executable, passing all arguments through.
for candidate in "${CANDIDATES[@]}"; do
    if [[ -x "${candidate}" ]]; then
        exec "${candidate}" "$@"
    fi
done

echo "git-credential-manager-wrapper.sh: git-credential-manager.exe not found in any known location." >&2
echo "Checked:" >&2
printf '  %s\n' "${CANDIDATES[@]}" >&2
exit 1
