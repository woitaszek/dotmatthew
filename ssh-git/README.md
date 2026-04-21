# SSH and Git Signing Configuration

Cross-platform Git identity, SSH key management, and commit signing setup
for Windows and WSL using 1Password as the SSH agent.

## Architecture

```text
┌─────────────────────────────────────────────────────────────────────┐
│  1Password Desktop (Windows)                                        │
│  ┌───────────────┐                                                  │
│  │  SSH Agent    │◄── serves keys to Windows OpenSSH + signing      │
│  │  (named pipe) │                                                  │
│  └───────┬───────┘                                                  │
│          │                                                          │
│  ┌───────┴──────────────────────────────────────────────────────┐   │
│  │  Windows OpenSSH (C:\Windows\System32\OpenSSH\)              │   │
│  │  ssh.exe, ssh-add.exe, ssh-agent.exe                         │   │
│  └──────────────────┬──────────────────────┬────────────────────┘   │
│                     │                      │                        │
│  ┌──────────────────┴───┐    ┌─────────────┴───────────────────┐    │
│  │  Windows Git         │    │  WSL (via aliases in bashrc)    │    │
│  │  core.sshCommand =   │    │  alias ssh='.../ssh.exe'        │    │
│  │    ssh.exe           │    │  alias ssh-add='.../ssh-add.exe'│    │
│  │  gpg.ssh.program =   │    │  gpg.ssh.program =              │    │
│  │    op-ssh-sign.exe   │    │    op-ssh-sign-wsl.exe          │    │
│  │  credential.helper = │    │  credential.helper =            │    │
│  │    (built-in GCM)    │    │    git-credential-manager.exe   │    │
│  └──────────────────────┘    └─────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

### Key integration points

1. 1Password replaces the built-in Windows SSH agent (which is disabled)
   and serves keys via a named pipe. Enable this in
   1Password Settings > Developer > SSH Agent.

2. WSL aliases `ssh`, `ssh-add`, `scp`, and `sftp` to Windows OpenSSH
   executables so all SSH operations go through 1Password's agent.
   These aliases live in `bashrc/local_wsl.sh`.

3. Git commit signing uses `op-ssh-sign.exe` (Windows) or
   `op-ssh-sign-wsl.exe` (WSL) from 1Password to sign with an
   SSH key held in the agent.

4. Git Credential Manager on Windows handles HTTPS authentication
   for both Windows Git and WSL Git.

5. SSH keys are stored on the Windows side (`C:\Users\<user>\.ssh\`).
   WSL symlinks `~/.ssh/id_ed25519*` to the Windows copies so both
   environments reference the same key files.

### Personal identity

An optional `includeIf` block in `.gitconfig` loads `.gitconfig-personal`
for repos cloned under a designated directory (e.g., `wslgit-personal/`
on WSL, `wingit-personal/` on Windows). This overrides `user.name` and
`user.email` for personal projects while keeping the work identity as
the default.

## Directory layout

```text
ssh-git/
├── README.md                        # This file
├── install-wsl.sh                   # Interactive installer for WSL
├── install-windows.ps1              # Interactive installer for Windows
├── common/
│   ├── allowed_signers.template     # SSH allowed signers (both platforms)
│   └── gitconfig-personal.template  # Personal identity override
├── windows/
│   ├── gitconfig.template           # Windows .gitconfig
│   └── ssh-config.template          # Windows .ssh/config header
└── wsl/
    └── gitconfig.template           # WSL .gitconfig
```

## Template variables

| Variable             | Description                       | Example                         |
| -------------------- | --------------------------------- | ------------------------------- |
| `GIT_NAME`           | Full name for Git commits         | `Matthew Woitaszek`             |
| `EMAIL_WORK`         | Primary (work) email              | `mwoitaszek@microsoft.com`      |
| `EMAIL_PERSONAL`     | Personal email (optional)         | `matthew.woitaszek@gmail.com`   |
| `PERSONAL_REPOS_DIR` | Path to personal repos (optional) | `/home/matthew/wslgit-personal` |
| `SIGNING_KEY`        | SSH public key for signing        | `ssh-ed25519 AAAA...`           |
| `WINDOWS_USER`       | Windows username (WSL only)       | `mwoitaszek`                    |

## Installation

### WSL

```bash
~/.matthew/ssh-git/install-wsl.sh
```

### Windows (PowerShell)

```powershell
& (Join-Path $HOME ".matthew" "ssh-git" "install-windows.ps1")
```

Both installers:

1. Prompt for each variable with auto-detected defaults from existing config
2. Render templates with your values
3. Show a diff against any existing files before writing
4. Create SSH key symlinks (WSL only)
5. Print a verification summary

## Prerequisites

Before running the installers:

1. Install 1Password and enable the SSH agent
   (Settings > Developer > SSH Agent).
2. Add your SSH key to 1Password (or generate one there).
3. Install Git for Windows (provides Git Credential Manager).
4. On WSL, ensure `bashrc/local_wsl.sh` is sourced (the SSH aliases
   for Windows OpenSSH live there).

## Verification

After installation, confirm the setup:

```bash
# Check Git identity
git config --global user.name
git config --global user.email

# Check signing
git config --global gpg.format        # should be: ssh
git config --global user.signingkey   # should show your public key

# Check SSH agent (keys served by 1Password)
ssh-add -l

# Test commit signing
cd /tmp && git init test-sign && cd test-sign
git commit --allow-empty -m "test signed commit"
git log --show-signature -1
cd .. && rm -rf test-sign
```
