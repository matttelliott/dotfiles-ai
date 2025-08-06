# tmux Configuration

## What is tmux?

tmux (terminal multiplexer) is a powerful tool that allows you to create and manage multiple terminal sessions within a single window. It's essential for developers who work with remote servers, need persistent sessions, or want to organize their terminal workflow efficiently.

## Key Benefits
- **Session Persistence**: Sessions survive network disconnections and system reboots
- **Window Management**: Multiple windows and panes in a single terminal
- **Remote Work**: Attach/detach from sessions when working on remote servers
- **Productivity**: Split screens, copy/paste, and efficient navigation

## Our Configuration Features

### Enhanced Key Bindings
- **Prefix Key**: `Ctrl-a` (more ergonomic than default `Ctrl-b`)
- **Intuitive Splits**: `|` for horizontal, `-` for vertical splits
- **Vim-style Navigation**: `h/j/k/l` for pane movement
- **Mouse Support**: Click to select panes and resize

### Visual Improvements
- **Custom Status Bar**: Shows date, time, and session info
- **256 Color Support**: Rich colors for better visual experience
- **Activity Monitoring**: Visual alerts for window activity
- **Custom Pane Borders**: Clear visual separation

### Productivity Features
- **Fast Config Reload**: `Prefix + r` to reload configuration
- **Copy Mode**: Vim-like text selection and copying
- **Current Path**: New windows/panes open in current directory
- **Large History**: 10,000 lines of scrollback buffer

## Integration with dotfiles-ai

### File Structure
```
tmux/
├── tmux.conf       # Main configuration file
├── linux.conf      # Linux-specific settings
├── macos.conf      # macOS-specific settings
└── README.md       # This file
```

### Symlink Integration
The installation script creates a symlink from `~/.dotfiles-ai/tmux/tmux.conf` to `~/.tmux.conf`, making this the active tmux configuration.

### Shared Configuration Philosophy
Our tmux configuration follows a "shared-first" approach where 95% of settings are identical across all platforms. The main `tmux.conf` contains all core functionality that works universally:

**Shared Across All Platforms:**
- Key bindings and prefix settings
- Window and pane management
- Visual styling and colors
- Status bar configuration
- Mouse support and navigation
- Copy mode settings
- Session management

**Platform-Specific Features (Minimal)**
Only clipboard integration differs between platforms, handled by separate files:

**Linux (`linux.conf`):**
- X11 clipboard integration via `xclip`
- Alternative options for `xsel` and Wayland systems
- Linux-specific clipboard commands

**macOS (`macos.conf`):**
- Native macOS clipboard via `pbcopy`/`pbpaste`
- `reattach-to-user-namespace` integration
- macOS clipboard handling

### Cross-Platform Compatibility
- **99% identical experience** across Debian, Linux Mint, and macOS
- **Automatic platform detection** loads only necessary clipboard configs
- **No platform-specific key bindings** - muscle memory works everywhere
- **Consistent behavior** for all core tmux functionality

## Key Bindings Reference

### Session Management
| Key | Action |
|-----|--------|
| `tmux` | Start new session |
| `tmux attach` | Attach to existing session |
| `tmux list-sessions` | List all sessions |
| `Prefix + d` | Detach from session |

### Window Management
| Key | Action |
|-----|--------|
| `Prefix + c` | Create new window |
| `Prefix + n` | Next window |
| `Prefix + p` | Previous window |
| `Prefix + &` | Kill window |

### Pane Management
| Key | Action |
|-----|--------|
| `Prefix + \|` | Split horizontally |
| `Prefix + -` | Split vertically |
| `Prefix + h/j/k/l` | Navigate panes (Vim-style) |
| `Alt + Arrow Keys` | Navigate panes (no prefix) |
| `Prefix + Shift + H/J/K/L` | Resize panes |
| `Prefix + x` | Kill pane |

### Copy Mode
| Key | Action |
|-----|--------|
| `Prefix + [` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy selection |
| `Prefix + p` | Paste |

### Configuration
| Key | Action |
|-----|--------|
| `Prefix + r` | Reload configuration |

## Usage Examples

### Basic Workflow
```bash
# Start new session
tmux

# Create horizontal split
Prefix + |

# Create vertical split
Prefix + -

# Navigate between panes
Prefix + h/j/k/l

# Create new window
Prefix + c

# Detach session
Prefix + d

# Reattach later
tmux attach
```

### Working with Named Sessions
```bash
# Create named session
tmux new-session -s development

# Attach to specific session
tmux attach -t development

# List sessions
tmux list-sessions
```

## Customization

### Adding Custom Key Bindings
Edit `tmux.conf` and add:
```bash
bind-key <key> <command>
```

### Modifying Status Bar
The status bar configuration is in the "Status bar configuration" section of `tmux.conf`.

### Platform-Specific Customizations
- Edit `linux.conf` for Linux-specific settings
- Edit `macos.conf` for macOS-specific settings

## Integration with Other Tools

### Neovim Integration
- Seamless navigation between tmux panes and Neovim splits
- Shared clipboard for copy/paste operations
- Consistent color schemes

### zsh Integration
- Custom aliases: `t` (tmux), `ta` (tmux attach), `tls` (tmux list-sessions)
- Session management functions
- Automatic session restoration

## Troubleshooting

### Clipboard Not Working
**Linux**: Install `xclip` or `xsel`
```bash
sudo apt install xclip
```

**macOS**: Install `reattach-to-user-namespace`
```bash
brew install reattach-to-user-namespace
```

### Colors Not Displaying
Ensure your terminal supports 256 colors and has `TERM` set correctly:
```bash
export TERM=screen-256color
```

### Key Bindings Not Working
Reload configuration:
```bash
tmux source-file ~/.tmux.conf
```
