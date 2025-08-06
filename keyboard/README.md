# Keyboard Configuration

This directory contains keyboard configuration setup to ensure optimal developer productivity across all platforms.

## Files

- `setup-keyboard.sh` - Cross-platform CapsLock -> Ctrl binding setup script
- `README.md` - This documentation file

## What It Does

**Primary Goal:** Ensures CapsLock is always bound to Ctrl for enhanced developer productivity.

## Platform Support

### Linux (X11/Wayland)
- **X11**: Uses `setxkbmap` with persistent `.xprofile` configuration
- **GNOME**: Configures via `gsettings` for GNOME desktop environments
- **Console**: Creates keymap for TTY/console usage
- **Systemd**: Creates user service for automatic application on login

### macOS
- **Modern macOS**: Uses `hidutil` with LaunchAgent for persistence
- **System Integration**: Creates proper macOS LaunchAgent for boot-time application
- **Fallback**: Provides manual System Preferences instructions

## Installation

The keyboard configuration is automatically applied when you run the main dotfiles setup:

```bash
./install.sh
```

Or you can run it separately:

```bash
./keyboard/setup-keyboard.sh
```

## How It Works

### Linux Methods
1. **X11 Mapping**: `setxkbmap -option caps:ctrl_modifier`
2. **GNOME Settings**: `gsettings set org.gnome.desktop.input-sources xkb-options`
3. **Console Keymap**: Custom keymap file for TTY usage
4. **Systemd Service**: Automatic application on user login

### macOS Methods
1. **hidutil Mapping**: Modern keyboard remapping using hidutil
2. **LaunchAgent**: Persistent application via macOS LaunchAgent system
3. **System Integration**: Proper macOS service integration

## Verification

After setup, test the binding:

1. **Press CapsLock** - should act as Ctrl
2. **CapsLock + C** - should copy (Ctrl+C)
3. **CapsLock + V** - should paste (Ctrl+V)

## Troubleshooting

### Linux
- **X11 not working**: Try logging out and back in
- **GNOME not applying**: Check GNOME Tweaks or Settings > Keyboard
- **Console not working**: Run `sudo loadkeys ~/.local/share/kbd/caps2ctrl.map`

### macOS
- **hidutil not working**: Try restarting or check System Preferences > Keyboard > Modifier Keys
- **LaunchAgent not loading**: Check with `launchctl list | grep caps2ctrl`

## Manual Configuration

### Linux (Alternative)
```bash
# Temporary (current session)
setxkbmap -option caps:ctrl_modifier

# Persistent (add to ~/.xprofile)
echo "setxkbmap -option caps:ctrl_modifier" >> ~/.xprofile
```

### macOS (Alternative)
```bash
# Temporary (current session)
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'

# Or use System Preferences:
# System Preferences > Keyboard > Modifier Keys > Caps Lock: Control
```

## Why CapsLock -> Ctrl?

- **Developer Productivity**: Ctrl is used constantly for shortcuts (copy, paste, terminal commands)
- **Ergonomics**: CapsLock is in a more accessible position than Ctrl
- **Reduced Strain**: Minimizes pinky finger stretching to reach Ctrl
- **Industry Standard**: Common practice among developers and power users

This configuration ensures you have consistent, ergonomic keyboard behavior across all your development environments.
