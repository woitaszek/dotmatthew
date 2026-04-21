#!/usr/bin/env bash
#
# install-wsl.sh
# Configure Git identity, SSH keys, and commit signing for WSL.
#
# Renders templates from wsl/ and common/ with auto-detected defaults,
# shows a diff against any existing config, and prompts before writing.
#
# Usage:
#   ~/.matthew/ssh-git/install-wsl.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors (ANSI-C quoting so the ESC byte is stored in the variable)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# ── Helper functions ────────────────────────────────────────────────────────

info()    { printf "${CYAN}%s${RESET}\n" "$1"; }
success() { printf "${GREEN}%s${RESET}\n" "$1"; }
warn()    { printf "${YELLOW}%s${RESET}\n" "$1"; }
err()     { printf "${RED}ERROR: %s${RESET}\n" "$1" >&2; }

prompt_var() {
  local var_name="$1"
  local prompt_text="$2"
  local default_val="${3:-}"

  if [[ -n "${default_val}" ]]; then
    printf "${BOLD}%s${RESET} [${GREEN}%s${RESET}]: " "${prompt_text}" "${default_val}"
  else
    printf "${BOLD}%s${RESET}: " "${prompt_text}"
  fi

  local input
  read -r input
  input="${input:-${default_val}}"

  if [[ -z "${input}" ]]; then
    return 1
  fi

  eval "${var_name}=\"${input}\""
  return 0
}

prompt_yn() {
  local prompt_text="$1"
  local default="${2:-n}"
  local hint="y/N"
  if [[ "${default}" == "y" ]]; then
    hint="Y/n"
  fi

  printf "${BOLD}%s${RESET} [%s]: " "${prompt_text}" "${hint}"
  local input
  read -r input
  input="${input:-${default}}"

  [[ "${input}" =~ ^[Yy] ]]
}

# Render a template by replacing {{VAR}} placeholders
render_template() {
  local template_file="$1"
  local output
  output="$(cat "${template_file}")"

  output="${output//\{\{GIT_NAME\}\}/${GIT_NAME}}"
  output="${output//\{\{EMAIL_WORK\}\}/${EMAIL_WORK}}"
  output="${output//\{\{SIGNING_KEY\}\}/${SIGNING_KEY}}"
  output="${output//\{\{WINDOWS_USER\}\}/${WINDOWS_USER}}"

  if [[ -n "${EMAIL_PERSONAL:-}" ]]; then
    output="${output//\{\{EMAIL_PERSONAL\}\}/${EMAIL_PERSONAL}}"
  fi

  if [[ -n "${PERSONAL_BLOCK:-}" ]]; then
    output="${output//\{\{PERSONAL_BLOCK\}\}/${PERSONAL_BLOCK}}"
  else
    output="${output//\{\{PERSONAL_BLOCK\}\}/}"
  fi

  printf '%s\n' "${output}"
}

# Show diff and prompt to install a file
diff_and_install() {
  local rendered="$1"
  local target="$2"
  local description="$3"

  printf "\n${BOLD}── %s ──${RESET}\n" "${description}"
  printf "  Target: %s\n" "${target}"

  local target_dir
  target_dir="$(dirname "${target}")"
  if [[ ! -d "${target_dir}" ]]; then
    warn "  Directory ${target_dir} does not exist."
    if prompt_yn "  Create it?"; then
      mkdir -p "${target_dir}"
      success "  Created ${target_dir}"
    else
      warn "  Skipping ${description}."
      return
    fi
  fi

  if [[ -f "${target}" ]]; then
    local tmp
    tmp="$(mktemp)"
    printf '%s\n' "${rendered}" > "${tmp}"

    if diff -q "${target}" "${tmp}" &>/dev/null; then
      success "  Already up to date."
      rm -f "${tmp}"
      return
    fi

    info "  Differences from current file:"
    diff --color=always -u "${target}" "${tmp}" || true
    rm -f "${tmp}"
    echo ""

    if ! prompt_yn "  Apply changes?"; then
      warn "  Skipped."
      return
    fi
  else
    info "  New file (does not exist yet)."
    printf '%s\n' "${rendered}" | head -20
    if [[ "$(printf '%s\n' "${rendered}" | wc -l)" -gt 20 ]]; then
      warn "  ... (truncated)"
    fi
    echo ""

    if ! prompt_yn "  Install?"; then
      warn "  Skipped."
      return
    fi
  fi

  printf '%s\n' "${rendered}" > "${target}"
  success "  Installed."
}

# ── Auto-detection ──────────────────────────────────────────────────────────

detect_windows_user() {
  # Ask Windows for the current username directly
  local name
  name="$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')" || true
  if [[ -n "${name}" ]]; then
    printf '%s' "${name}"
  fi
}

detect_git_name() {
  git config --global user.name 2>/dev/null || true
}

detect_email_work() {
  git config --global user.email 2>/dev/null || true
}

detect_email_personal() {
  if [[ -f "${HOME}/.gitconfig-personal" ]]; then
    grep -Po '(?<=email = ).*' "${HOME}/.gitconfig-personal" 2>/dev/null | head -1 || true
  fi
}

detect_signing_key() {
  git config --global user.signingkey 2>/dev/null || true
}

detect_personal_repos_dir() {
  if [[ -f "${HOME}/.gitconfig" ]]; then
    grep -Po '(?<=gitdir:)[^"]+(?=/\*\*")' "${HOME}/.gitconfig" 2>/dev/null | head -1 || true
  fi
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
  printf '\n%s=== dotmatthew SSH & Git Setup (WSL) ===%s\n\n' "${BOLD}${CYAN}" "${RESET}"

  # ── Prerequisites ──

  info "Step 1: Primary (work) account"
  echo ""

  local detected
  detected="$(detect_git_name)"
  if ! prompt_var GIT_NAME "  Full name" "${detected}"; then
    err "Name is required."; exit 1
  fi

  detected="$(detect_email_work)"
  if ! prompt_var EMAIL_WORK "  Work email" "${detected}"; then
    err "Work email is required."; exit 1
  fi

  echo ""
  info "Step 2: Personal account (optional)"
  echo ""

  EMAIL_PERSONAL=""
  PERSONAL_REPOS_DIR=""
  PERSONAL_BLOCK=""

  # Default to "y" if a personal config already exists
  local personal_default="n"
  if [[ -f "${HOME}/.gitconfig-personal" ]]; then
    personal_default="y"
  fi

  if prompt_yn "  Configure a personal Git identity?" "${personal_default}"; then
    detected="$(detect_email_personal)"
    if prompt_var EMAIL_PERSONAL "  Personal email" "${detected}"; then
      detected="$(detect_personal_repos_dir)"
      if prompt_var PERSONAL_REPOS_DIR "  Personal repos directory" "${detected}"; then
        PERSONAL_BLOCK="[includeIf \"gitdir:${PERSONAL_REPOS_DIR}/**\"]
  path = ~/.gitconfig-personal"
      else
        warn "  No repos directory; skipping includeIf."
        PERSONAL_BLOCK=""
      fi
    fi
  fi

  echo ""
  info "Step 3: Commit signing"
  echo ""

  detected="$(detect_signing_key)"
  if [[ -z "${detected}" ]]; then
    # Try to detect from Windows SSH agent
    detected="$(/mnt/c/Windows/System32/OpenSSH/ssh-add.exe -L 2>/dev/null | head -1 || true)"
  fi
  if ! prompt_var SIGNING_KEY "  SSH signing key (public key)" "${detected}"; then
    err "Signing key is required."; exit 1
  fi

  echo ""
  info "Step 4: Windows username (for cross-OS paths)"
  echo ""

  detected="$(detect_windows_user)"
  if ! prompt_var WINDOWS_USER "  Windows username" "${detected}"; then
    err "Windows username is required."; exit 1
  fi

  # ── Summary ──

  printf '\n%s── Configuration ──%s\n' "${BOLD}" "${RESET}"
  printf "  Name:             %s\n" "${GIT_NAME}"
  printf "  Work email:       %s\n" "${EMAIL_WORK}"
  if [[ -n "${EMAIL_PERSONAL}" ]]; then
    printf "  Personal email:   %s\n" "${EMAIL_PERSONAL}"
    printf "  Personal repos:   %s\n" "${PERSONAL_REPOS_DIR}"
  fi
  printf "  Signing key:      %s\n" "${SIGNING_KEY}"
  printf "  Windows user:     %s\n" "${WINDOWS_USER}"
  echo ""

  if ! prompt_yn "Proceed with installation?"; then
    warn "Aborted."
    exit 0
  fi

  # ── Render and install ──

  local rendered

  # .gitconfig
  rendered="$(render_template "${SCRIPT_DIR}/wsl/gitconfig.template")"
  diff_and_install "${rendered}" "${HOME}/.gitconfig" ".gitconfig (WSL)"

  # .gitconfig-personal
  if [[ -n "${EMAIL_PERSONAL}" ]]; then
    rendered="$(render_template "${SCRIPT_DIR}/common/gitconfig-personal.template")"
    diff_and_install "${rendered}" "${HOME}/.gitconfig-personal" ".gitconfig-personal"
  fi

  # allowed_signers
  rendered="$(render_template "${SCRIPT_DIR}/common/allowed_signers.template")"
  local signers_rendered="${rendered}"
  # If no personal email, strip the comma-separated format
  if [[ -z "${EMAIL_PERSONAL}" ]]; then
    signers_rendered="${EMAIL_WORK} ${SIGNING_KEY}"
  fi
  diff_and_install "${signers_rendered}" "${HOME}/.ssh/allowed_signers" ".ssh/allowed_signers"

  # ── SSH key symlinks ──

  printf '\n%s── SSH Key Symlinks ──%s\n' "${BOLD}" "${RESET}"
  local win_ssh="/mnt/c/Users/${WINDOWS_USER}/.ssh"

  if [[ -d "${win_ssh}" ]]; then
    for key_file in id_ed25519 id_ed25519.pub; do
      local win_key="${win_ssh}/${key_file}"
      local wsl_key="${HOME}/.ssh/${key_file}"

      if [[ ! -f "${win_key}" ]]; then
        warn "  ${win_key} not found; skipping ${key_file} symlink."
        continue
      fi

      if [[ -L "${wsl_key}" ]] && [[ "$(readlink "${wsl_key}")" == "${win_key}" ]]; then
        success "  ~/.ssh/${key_file} already symlinked."
      elif [[ -f "${wsl_key}" ]]; then
        warn "  ~/.ssh/${key_file} exists (not a symlink)."
        if prompt_yn "  Replace with symlink to ${win_key}?"; then
          rm -f "${wsl_key}"
          ln -s "${win_key}" "${wsl_key}"
          success "  Symlinked."
        fi
      else
        info "  Creating symlink: ~/.ssh/${key_file} -> ${win_key}"
        if prompt_yn "  Create?"; then
          ln -s "${win_key}" "${wsl_key}"
          success "  Symlinked."
        fi
      fi
    done
  else
    warn "  Windows .ssh directory not found at ${win_ssh}"
    warn "  Generate a key on Windows first, then re-run."
  fi

  # ── Verification ──

  printf '\n%s── Verification ──%s\n' "${BOLD}" "${RESET}"

  printf "  git user.name:  %s\n" "$(git config --global user.name 2>/dev/null || echo '(not set)')"
  printf "  git user.email: %s\n" "$(git config --global user.email 2>/dev/null || echo '(not set)')"
  printf "  git gpg.format: %s\n" "$(git config --global gpg.format 2>/dev/null || echo '(not set)')"
  printf "  Signing key:    %s\n" "$(git config --global user.signingkey 2>/dev/null || echo '(not set)')"

  local agent_keys
  agent_keys="$(/mnt/c/Windows/System32/OpenSSH/ssh-add.exe -l 2>/dev/null || echo '(agent not reachable)')"
  printf "  SSH agent keys: %s\n" "${agent_keys}"

  printf '\n%s=== Done ===%s\n\n' "${GREEN}${BOLD}" "${RESET}"
}

main "$@"
