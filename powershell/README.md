# PowerShell Setup

PowerShell profile, scripts, and Oh My Posh theme configuration for Windows and macOS.

## Directory Structure

```text
powershell/
├── install/
│   ├── install-1-bootstrap.ps1  # Phase 1: Windows prereq installer (winget)
│   ├── install-1-bootstrap.sh   # Phase 1: macOS prereq installer (Homebrew)
│   ├── install-2-profile.ps1    # Phase 2: configure PowerShell profile (cross-platform)
│   ├── install-3-apps.ps1       # Phase 3: app installs via winget
│   └── install-4-system.ps1     # Phase 4: system config requiring Admin (WSL, Defender)
├── profile/
│   ├── global.ps1       # Shared profile: OMP prompt, aliases, PATH
│   └── local_*.ps1      # Per-machine overrides (optional)
├── scripts/
│   └── jit.ps1          # Azure VM Just-In-Time access provisioning
└── themes/
    └── mytheme-azure.omp.json # Oh My Posh theme (with Azure segments)
```

## Windows Setup (Two-Phase Install)

### Phase 1: Bootstrap a Fresh PC

On a new Windows machine with no tools installed, open PowerShell **as Administrator**,
then either download and inspect first:

```powershell
irm https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/install/install-1-bootstrap.ps1 -OutFile install-1-bootstrap.ps1
cat install-1-bootstrap.ps1   # review the script
.\install-1-bootstrap.ps1    # run it
```

Or run directly (if you trust the source):

```powershell
iex (irm https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/install/install-1-bootstrap.ps1)
```

This installs:

- Git
- Windows Terminal
- Oh My Posh
- CascadiaCode Nerd Font

Then clones this repo to `~/.matthew`.

### Phase 2: Configure Windows PowerShell Profile

After the repo is cloned, run:

```powershell
& "$HOME\.matthew\powershell\install\install-2-profile.ps1"
```

This writes a shim to `$PROFILE` that dot-sources `profile/global.ps1`. The shim
includes a guard so that if OneDrive syncs the profile to a machine where the repo
isn't cloned yet, you get a friendly message instead of errors.

Restart PowerShell or reload:

```powershell
. $PROFILE
```

### Phase 3: Install Apps

Install common development tools and productivity apps via winget (no admin required):

```powershell
& "$HOME\.matthew\powershell\install\install-3-apps.ps1"
```

This installs:

- **Development**: GitHub CLI, VS Code Insiders, Python 3, PowerShell Preview, Docker Desktop, Azure Developer CLI
- **Security**: 1Password, 1Password CLI
- **Productivity**: PowerToys, Pandoc

The Work section (VS 2022 Enterprise) is commented out by default. Uncomment if needed.

### Phase 4: System Config (Admin)

Open PowerShell **as Administrator**, then run:

```powershell
& "$HOME\.matthew\powershell\install\install-4-system.ps1"
```

This configures:

- Windows Subsystem for Linux (WSL)
- Defender exclusions for dev folders (`~/dev`, `~/.venvs`, `\\wsl$`, Docker)

### Configure Windows Terminal Font

Set your terminal font to **CascadiaCode Nerd Font** (required for prompt glyphs):

- **Windows Terminal**: Settings → Profiles → Appearance → Font face
- **VS Code**: Settings → Terminal › Integrated: Font Family → `'CascadiaCode Nerd Font'`

## macOS Setup (Two-Phase Install)

### Phase 1: Bootstrap a Fresh Mac

Download and inspect first:

```bash
curl -fsSL https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/install/install-1-bootstrap.sh -o install-1-bootstrap.sh
cat install-1-bootstrap.sh        # review the script
bash install-1-bootstrap.sh       # run it
```

Or run directly (if you trust the source):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/install/install-1-bootstrap.sh)
```

This installs:

- Xcode Command Line Tools (includes Git)
- Homebrew (if not present)
- Oh My Posh
- PowerShell
- MesloLGS Nerd Font

Then clones this repo to `~/.matthew`.

### Phase 2: Configure macOS PowerShell Profile

Run the same cross-platform install script:

```powershell
& (Join-Path $HOME ".matthew" "powershell" "install" "install-2-profile.ps1")
```

### Configure macOS Terminal Font

Set your terminal font to **MesloLGS Nerd Font** (required for prompt glyphs):

- **Terminal.app**: Preferences → Profiles → Font
- **iTerm2**: Preferences → Profiles → Text → Font
- **VS Code**: Settings → Terminal › Integrated: Font Family → `'MesloLGS Nerd Font'`

## Per-Machine Customization

Create a file named `profile/local_MACHINENAME.ps1` (lowercase) for machine-specific
overrides. It will be dot-sourced automatically by `global.ps1` if present. For example,
`profile/local_vectorvictor.ps1` for a machine named VectorVictor.
