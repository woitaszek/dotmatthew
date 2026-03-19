# Bash Setup

Modular bash profile with shared global configuration and per-machine local
overrides. Dates back to July 2011.

## Directory Structure

```text
bashrc/
├── install.sh         # Installer: symlinks rc/ files, appends stanza to .bashrc
├── global.sh          # Aggregator: sources all global_*.sh components
├── global_alias.sh    # Aliases (ls, git, xterm, ack)
├── global_git.sh      # Git prompt and completion support
├── global_prompt.sh   # matthew_prompt() function for PS1 construction
├── global_shell.sh    # Shell options (history, editor, umask)
└── local_*.sh         # Per-machine profiles (one per system)
```

## Architecture

Each machine gets a single entry point via `~/.bashrc.local`:

```text
~/.bashrc                       Stock distro bashrc (untouched)
└── source ~/.bashrc.local      Appended by install.sh
    └── local_wsl.sh            Symlinked per machine
        ├── source global.sh    Loads all global components
        ├── PROMPT_HOSTCOLOR=…  Machine-specific color
        └── matthew_prompt      Activates the prompt
```

`global.sh` is the aggregator that sources the four `global_*.sh` files in the
correct order (git and prompt before aliases and shell options). Local files
source `global.sh` once, optionally set `PROMPT_HOSTCOLOR` or
`PROMPT_USERCOLOR`, and call `matthew_prompt` to activate the prompt.

This architecture allows cluster nodes to share a local file while
differentiating by hostname (see `local_frost.sh`, `local_polynya.sh`).

## Installation

Clone the repo and run the installer:

```bash
git clone https://github.com/woitaszek/dotmatthew.git ~/.matthew
~/.matthew/bashrc/install.sh
```

The installer:

1. Symlinks `rc/` dotfiles (`~/.inputrc`, `~/.vimrc`, `~/.screenrc`)
2. Appends a `.bashrc.local` sourcing stanza to `~/.bashrc` (idempotent)
3. Lists available local profiles

Then create a symlink for your machine:

```bash
ln -s ~/.matthew/bashrc/local_wsl.sh ~/.bashrc.local
```

## Available Local Profiles

| Profile | Description |
| --- | --- |
| `local_default.sh` | Minimal defaults for uncategorized systems |
| `local_wsl.sh` | Windows Subsystem for Linux (WSL) |
| `local_frost.sh` | Frost cluster (hostname-based color switching) |
| `local_polynya.sh` | Polynya cluster |
| `local_totoro.sh` | MacBook Air (High Sierra) |
| `local_pluto.sh` | Pluto (macOS) |
| `local_reset.sh` | VM and server machines (red prompt) |
| `local_dragonwell.sh` | Dragonwell |
| `local_icedecaf.sh` | Iced Decaf |
| `local_notyet.sh` | Not Yet |
| `local_oc.sh` | OC |
| `local_sanbruno.sh` | San Bruno |

## Creating a New Local Profile

Copy `local_wsl.sh` as a starting template:

```bash
cp ~/.matthew/bashrc/local_wsl.sh ~/.matthew/bashrc/local_NEWHOST.sh
```

Edit the new file to:

1. Source `global.sh` (already present from the template)
2. Set `PROMPT_HOSTCOLOR` to an ANSI color escape for the hostname
3. Call `matthew_prompt` to activate the prompt
4. Add any machine-specific configuration (paths, tools, aliases)
