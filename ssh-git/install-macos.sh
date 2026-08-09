#!/usr/bin/env bash
#
# install-macos.sh
# Configure Git identity and SSH commit signing for macOS.
#
# Renders templates from macos/ and common/ with auto-detected defaults,
# shows a diff against any existing config, and prompts before writing.
#
# Usage:
#   ~/.matthew/ssh-git/install-macos.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SIGNER="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

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
    printf "${BOLD}%s${RESET} [${GREEN}%s${RESET}]: " \
      "${prompt_text}" "${default_val}"
  else
    printf "${BOLD}%s${RESET}: " "${prompt_text}"
  fi

  local input
  read -r input
  input="${input:-${default_val}}"

  if [[ -z "${input}" ]]; then
    return 1
  fi

  printf -v "${var_name}" '%s' "${input}"
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
  output="${output//\{\{SIGNING_PROGRAM\}\}/${SIGNING_PROGRAM}}"

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

  local tmp
  tmp="$(mktemp)"
  printf '%s\n' "${rendered}" >"${tmp}"

  if [[ -f "${target}" ]]; then
    if diff -q "${target}" "${tmp}" &>/dev/null; then
      success "  Already up to date."
      rm -f "${tmp}"
      return
    fi

    info "  Differences from current file:"
    diff --color=always -u "${target}" "${tmp}" || true
    echo ""

    if ! prompt_yn "  Apply changes?"; then
      warn "  Skipped."
      rm -f "${tmp}"
      return
    fi
  else
    info "  New file (does not exist yet)."
    sed -n '1,20p' "${tmp}"
    if [[ "$(wc -l <"${tmp}")" -gt 20 ]]; then
      warn "  ... (truncated)"
    fi
    echo ""

    if ! prompt_yn "  Install?"; then
      warn "  Skipped."
      rm -f "${tmp}"
      return
    fi
  fi

  mv "${tmp}" "${target}"
  success "  Installed."
}

# ── Auto-detection ──────────────────────────────────────────────────────────

detect_git_name() {
  git config --global user.name 2>/dev/null || true
}

detect_email_work() {
  git config --global user.email 2>/dev/null || true
}

detect_email_personal() {
  if [[ -f "${HOME}/.gitconfig-personal" ]]; then
    sed -nE 's/^[[:space:]]*email[[:space:]]*=[[:space:]]*(.*)$/\1/p' \
      "${HOME}/.gitconfig-personal" | head -1
  fi
}

detect_signing_key() {
  git config --global user.signingkey 2>/dev/null || true
}

detect_personal_repos_dir() {
  if [[ -f "${HOME}/.gitconfig" ]]; then
    sed -nE 's/.*gitdir:([^\"]+)\/\*\*.*/\1/p' "${HOME}/.gitconfig" | head -1
  fi
}

detect_signing_program() {
  local configured
  configured="$(git config --global gpg.ssh.program 2>/dev/null || true)"

  # Prefer an existing executable configuration, then the standard app path.
  if [[ -n "${configured}" && -x "${configured}" ]]; then
    printf '%s' "${configured}"
  elif [[ -x "${DEFAULT_SIGNER}" ]]; then
    printf '%s' "${DEFAULT_SIGNER}"
  fi
}

validate_signing_key() {
  local tmp
  tmp="$(mktemp)"
  printf '%s\n' "${SIGNING_KEY}" >"${tmp}"

  if ! ssh-keygen -lf "${tmp}" &>/dev/null; then
    rm -f "${tmp}"
    err "Signing key is not a valid SSH public key."
    return 1
  fi

  rm -f "${tmp}"
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    err "This installer supports macOS only."
    exit 1
  fi

  if ! command -v git &>/dev/null || ! command -v ssh-keygen &>/dev/null; then
    err "Git and OpenSSH are required."
    exit 1
  fi

  printf '\n%s=== dotmatthew SSH & Git Setup (macOS) ===%s\n\n' "${BOLD}${CYAN}" "${RESET}"

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
      if prompt_var PERSONAL_REPOS_DIR \
        "  Personal repos directory" "${detected}"; then
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
  if ! prompt_var SIGNING_KEY \
    "  SSH signing key (public key)" "${detected}"; then
    err "Signing key is required."; exit 1
  fi
  validate_signing_key

  detected="$(detect_signing_program)"
  if ! prompt_var SIGNING_PROGRAM \
    "  1Password signing program" "${detected}"; then
    err "1Password signing program is required."; exit 1
  fi
  if [[ ! -x "${SIGNING_PROGRAM}" ]]; then
    err "Signing program is not executable: ${SIGNING_PROGRAM}"
    exit 1
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
  printf "  Signing program:  %s\n" "${SIGNING_PROGRAM}"
  echo ""

  if ! prompt_yn "Proceed with installation?"; then
    warn "Aborted."
    exit 0
  fi

  # ── Render and install ──

  local rendered

  # .gitconfig
  rendered="$(render_template "${SCRIPT_DIR}/macos/gitconfig.template")"
  diff_and_install "${rendered}" "${HOME}/.gitconfig" ".gitconfig (macOS)"

  # .gitconfig-personal
  if [[ -n "${EMAIL_PERSONAL}" ]]; then
    rendered="$(render_template \
      "${SCRIPT_DIR}/common/gitconfig-personal.template")"
    diff_and_install "${rendered}" "${HOME}/.gitconfig-personal" \
      ".gitconfig-personal"
  fi

  # allowed_signers
  local signers
  if [[ -n "${EMAIL_PERSONAL}" ]]; then
    signers="${EMAIL_WORK},${EMAIL_PERSONAL} namespaces=\"git\" ${SIGNING_KEY}"
  else
    signers="${EMAIL_WORK} namespaces=\"git\" ${SIGNING_KEY}"
  fi
  diff_and_install "${signers}" "${HOME}/.ssh/allowed_signers" \
    ".ssh/allowed_signers"
  if [[ -f "${HOME}/.ssh/allowed_signers" ]]; then
    chmod 0600 "${HOME}/.ssh/allowed_signers"
  fi

  # ── Verification ──

  printf '\n%s── Verification ──%s\n' "${BOLD}" "${RESET}"

  printf "  git user.name:  %s\n" \
    "$(git config --global user.name 2>/dev/null || echo '(not set)')"
  printf "  git user.email: %s\n" \
    "$(git config --global user.email 2>/dev/null || echo '(not set)')"
  printf "  git gpg.format: %s\n" \
    "$(git config --global gpg.format 2>/dev/null || echo '(not set)')"
  printf "  Signing key:    %s\n" \
    "$(git config --global user.signingkey 2>/dev/null || echo '(not set)')"
  printf "  Signing program: %s\n" \
    "$(git config --global gpg.ssh.program 2>/dev/null || echo '(not set)')"

  printf '\n%s=== Done ===%s\n\n' "${GREEN}${BOLD}" "${RESET}"
  warn "No test repository or signed commit was created."
}

main "$@"