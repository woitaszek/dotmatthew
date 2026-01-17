# PowerShell Installation (Mac & PC)

This guide provides step-by-step instructions to set up PowerShell with a custom theme using Oh My Posh on both macOS and Windows.

## 1. Install oh-my-posh

**macOS:**

```bash
brew install jandedobbeleer/oh-my-posh/oh-my-posh
```

**Windows:**

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```

## 2. Configure PowerShell Profile

Add the following line to your PowerShell profile:

```powershell
oh-my-posh init pwsh --config ~/.matthew/posh/mytheme.omp.json | Invoke-Expression
```

**Profile locations:**

- **macOS/Linux**: `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
- **Windows**: `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

**Quick setup:**

macOS:

```bash
mkdir -p ~/.config/powershell
echo "oh-my-posh init pwsh --config ~/.matthew/posh/mytheme.omp.json | Invoke-Expression" >> ~/.config/powershell/Microsoft.PowerShell_profile.ps1
```

Windows (PowerShell):

```powershell
New-Item -Path $PROFILE -Type File -Force
Add-Content -Path $PROFILE -Value "oh-my-posh init pwsh --config ~/.matthew/posh/mytheme.omp.json | Invoke-Expression"
```

## 3. Install Nerd Fonts (Required for Glyphs)

The theme uses special glyphs that require a Nerd Font to display properly.

**macOS:**

```bash
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lgs-nf
```

**Windows:**

```powershell
oh-my-posh font install CascadiaCode
```

**Configure your terminal to use the Nerd Font:**

- **Terminal.app** (macOS): Preferences → Profiles → Font → Select "MesloLGS Nerd Font"
- **iTerm2** (macOS): Preferences → Profiles → Text → Font → Select "MesloLGS Nerd Font"
- **Windows Terminal**: Settings → Profiles → Appearance → Font face → "Cascadia Mono"
- **VS Code terminal**:
  - macOS: Settings → Terminal › Integrated: Font Family → `'MesloLGS Nerd Font'`
  - Windows: Settings → Terminal › Integrated: Font Family → `'Cascadia Mono'`

## 4. Restart PowerShell

After installation, restart your PowerShell session or run:

```powershell
. $PROFILE
```
