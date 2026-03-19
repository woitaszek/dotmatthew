# Zsh Setup

Standalone zsh configuration with a custom prompt, history tuning,
and tab-completion styling.

## Directory Structure

```text
zshrc/
└── zshrc              # Main zsh configuration file
```

## Installation

Symlink the configuration file:

```bash
ln -s ~/.matthew/zshrc/zshrc ~/.zshrc
```

## Features

The configuration includes:

- History: 20,000 saved entries with timestamps, deduplication, and `hgrep` search
- Keyboard bindings: Home/End key mappings for common terminal emulators
- Prompt: username@host, working directory (blue), git branch (cyan),
  virtualenv (yellow), history number (grey), green/red status indicator
- Tab completion: interactive menu with color-highlighted partial matches
- Window title: automatically set to `user@host cwd`
