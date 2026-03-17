# PowerShell Setup

PowerShell profile, scripts, and Oh My Posh theme configuration for Windows and macOS.

## Directory Structure

```text
powershell/
├── bootstrap-windows.ps1 # Phase 1: Windows prereq installer (winget)
├── bootstrap-mac.sh      # Phase 1: macOS prereq installer (Homebrew)
├── install.ps1           # Phase 2: configure PowerShell profile (cross-platform)
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
irm https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-windows.ps1 -OutFile bootstrap-windows.ps1
cat bootstrap-windows.ps1   # review the script
.\bootstrap-windows.ps1    # run it
```

Or run directly (if you trust the source):

```powershell
iex (irm https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-windows.ps1)
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
& "$HOME\.matthew\powershell\install.ps1"
```

This writes a shim to `$PROFILE` that dot-sources `profile/global.ps1`. The shim
includes a guard so that if OneDrive syncs the profile to a machine where the repo
isn't cloned yet, you get a friendly message instead of errors.

Restart PowerShell or reload:

```powershell
. $PROFILE
```

### Configure Windows Terminal Font

Set your terminal font to **CascadiaCode Nerd Font** (required for prompt glyphs):

- **Windows Terminal**: Settings → Profiles → Appearance → Font face
- **VS Code**: Settings → Terminal › Integrated: Font Family → `'CascadiaCode Nerd Font'`

## macOS Setup (Two-Phase Install)

### Phase 1: Bootstrap a Fresh Mac

Download and inspect first:

```bash
curl -fsSL https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-mac.sh -o bootstrap-mac.sh
cat bootstrap-mac.sh        # review the script
bash bootstrap-mac.sh       # run it
```

Or run directly (if you trust the source):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/woitaszek/dotmatthew/main/powershell/bootstrap-mac.sh)
```

This installs:

- Xcode Command Line Tools (includes Git)
- Homebrew (if not present)
- Oh My Posh
- MesloLGS Nerd Font

Then clones this repo to `~/.matthew`.

### Phase 2: Configure macOS PowerShell Profile

Run the same cross-platform install script:

```powershell
& (Join-Path $HOME ".matthew" "powershell" "install.ps1")
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
