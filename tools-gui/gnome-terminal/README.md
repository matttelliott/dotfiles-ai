# GNOME Terminal Configuration

Tokyo Night theme configuration for GNOME Terminal on Linux systems.

## Installation

```bash
./tools-gui/gnome-terminal/setup-tokyonight.sh
```

## What Gets Configured

### Tokyo Night Theme
- **Background**: Dark blue (#1a1b26)
- **Foreground**: Light gray (#c0caf5)
- **Cursor**: Cyan (#c0caf5)
- **Selection**: Dark gray (#33467C)
- **Complete 16-color palette** matching Tokyo Night theme

### Terminal Settings
- **Font**: System monospace font
- **Scrollback**: 10000 lines
- **Transparency**: Optional background transparency
- **Bell**: Visual bell instead of audible

## Color Palette

The Tokyo Night theme uses these colors:

### Normal Colors
- **Black**: #15161E
- **Red**: #f7768e
- **Green**: #9ece6a
- **Yellow**: #e0af68
- **Blue**: #7aa2f7
- **Magenta**: #bb9af7
- **Cyan**: #7dcfff
- **White**: #a9b1d6

### Bright Colors
- **Bright Black**: #414868
- **Bright Red**: #f7768e
- **Bright Green**: #9ece6a
- **Bright Yellow**: #e0af68
- **Bright Blue**: #7aa2f7
- **Bright Magenta**: #bb9af7
- **Bright Cyan**: #7dcfff
- **Bright White**: #c0caf5

## Manual Configuration

If the script doesn't work or you prefer manual configuration:

### Using GUI

1. Open GNOME Terminal
2. Go to **Edit → Preferences**
3. Click on **Profiles** tab
4. Select your profile (usually "Unnamed")
5. Click on **Colors** tab
6. Uncheck "Use colors from system theme"
7. Set the following:
   - **Background**: #1a1b26
   - **Foreground**: #c0caf5
   - **Cursor**: #c0caf5
8. Click on each palette color and set the values from above

### Using dconf

```bash
# Get current profile ID
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

# Set colors
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/background-color "'#1a1b26'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/foreground-color "'#c0caf5'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/cursor-background-color "'#c0caf5'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/highlight-background-color "'#33467C'"

# Set palette
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/palette "['#15161E', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#a9b1d6', '#414868', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#c0caf5']"

# Disable system theme
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/use-theme-colors false
```

## Profile Management

### Create New Profile

```bash
# Create a new profile for Tokyo Night
dconf dump /org/gnome/terminal/legacy/profiles:/:$PROFILE/ > tokyo-night-backup.txt

# List all profiles
dconf list /org/gnome/terminal/legacy/profiles:/

# Clone existing profile
# This requires manual intervention through GUI
```

### Export Profile

```bash
# Export current profile settings
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
dconf dump /org/gnome/terminal/legacy/profiles:/:$PROFILE/ > gnome-terminal-profile.dconf
```

### Import Profile

```bash
# Import profile settings
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
dconf load /org/gnome/terminal/legacy/profiles:/:$PROFILE/ < gnome-terminal-profile.dconf
```

## Additional Settings

### Font Configuration

```bash
# Set font
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/font "'Fira Code 12'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/use-system-font false
```

### Transparency

```bash
# Enable transparency
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/background-transparency-percent 10
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/use-transparent-background true
```

### Scrollback

```bash
# Set scrollback lines
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/scrollback-lines 10000
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/scrollback-unlimited false
```

### Cursor

```bash
# Cursor shape (block, ibeam, underline)
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/cursor-shape "'block'"

# Cursor blinking (on, off, system)
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/cursor-blink-mode "'on'"
```

## Keyboard Shortcuts

### Default Shortcuts
- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+N` - New window
- `Ctrl+Shift+W` - Close tab
- `Ctrl+Shift+Q` - Close window
- `Ctrl+PageUp/PageDown` - Switch tabs
- `Ctrl+Shift+PageUp/PageDown` - Move tab
- `Ctrl+Shift+C` - Copy
- `Ctrl+Shift+V` - Paste
- `Ctrl+Shift+F` - Find
- `Ctrl+Plus/Minus` - Zoom in/out
- `Ctrl+0` - Normal size
- `F11` - Fullscreen

### Custom Shortcuts

```bash
# Set custom keybindings
dconf write /org/gnome/terminal/legacy/keybindings/new-tab "'<Primary><Shift>t'"
dconf write /org/gnome/terminal/legacy/keybindings/new-window "'<Primary><Shift>n'"
dconf write /org/gnome/terminal/legacy/keybindings/close-tab "'<Primary><Shift>w'"
```

## Terminal Preferences

### Bell Settings

```bash
# Visual bell
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/audible-bell false
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/visual-bell true
```

### Text Settings

```bash
# Allow bold text
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/bold-is-bright true

# Custom title
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/custom-title "'Tokyo Night Terminal'"
```

### Behavior Settings

```bash
# Exit behavior (close, restart, hold)
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/exit-action "'close'"

# Rewrap on resize
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE/rewrap-on-resize true
```

## Integration with Shell

### Bash Integration

Add to `~/.bashrc`:
```bash
# Set terminal title
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

# Enable 256 colors
export TERM=xterm-256color
```

### Zsh Integration

Add to `~/.zshrc`:
```bash
# Set terminal title
precmd() {
    print -Pn "\e]0;%n@%m: %~\a"
}

# Enable 256 colors
export TERM=xterm-256color
```

## Troubleshooting

### Colors Not Applying

```bash
# Reset profile to defaults
dconf reset -f /org/gnome/terminal/legacy/profiles:/:$PROFILE/

# Reapply theme
./tools-gui/gnome-terminal/setup-tokyonight.sh
```

### Profile Not Found

```bash
# List all profiles
gsettings get org.gnome.Terminal.ProfilesList list

# Create new profile manually through GUI
# Edit → Preferences → Profiles → +
```

### dconf Errors

```bash
# Check if dconf is installed
which dconf

# Install if missing
sudo apt install dconf-cli

# Check GNOME Terminal schema
gsettings list-schemas | grep terminal
```

## Alternative Terminals

If GNOME Terminal doesn't meet your needs, consider:

1. **Alacritty** - GPU-accelerated terminal
2. **Kitty** - Fast, feature-rich terminal
3. **Terminator** - Multiple terminals in one window
4. **Tilix** - Tiling terminal emulator
5. **Konsole** - KDE's terminal emulator

Each can be themed with Tokyo Night colors using their respective configuration files.

## Tips

1. **Save profiles** before making changes
2. **Test colors** with `colortest` scripts
3. **Use tmux/screen** for persistent sessions
4. **Configure shell** prompt to match theme
5. **Install powerline fonts** for better symbols
6. **Enable ligatures** with appropriate fonts
7. **Adjust transparency** for readability
8. **Set appropriate scrollback** buffer
9. **Configure keybindings** for efficiency
10. **Backup settings** regularly