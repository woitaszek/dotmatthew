# macOS KeyBindings

Remaps Home/End keys to behave like Windows instead of the macOS Cocoa
defaults, which is surprising if you switch between platforms.

| Key | Default (macOS) | Remapped |
| --- | --- | --- |
| Home | Scroll to top of document | Beginning of line |
| End | Scroll to bottom of document | End of line |
| Shift+Home | Select to top of document | Select to beginning of line |
| Shift+End | Select to bottom of document | Select to end of line |
| Ctrl+Home | (none) | Beginning of document |
| Ctrl+End | (none) | End of document |
| Shift+Ctrl+Home | (none) | Select to beginning of document |
| Shift+Ctrl+End | (none) | Select to end of document |

## Installation

```bash
mkdir -p ~/Library/KeyBindings
ln -s ~/.matthew/Library/KeyBindings/DefaultKeyBinding.dict ~/Library/KeyBindings/
```

Restart any running apps for the change to take effect.
