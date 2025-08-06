# zsh Configuration

## What is zsh?

zsh (Z Shell) is an advanced Unix shell that serves as both a command interpreter and scripting language. It's an extended version of the Bourne shell (sh) with many improvements, including better tab completion, spelling correction, and extensive customization options. It's the default shell on macOS and increasingly popular on Linux systems.

## Key Benefits
- **Advanced Tab Completion**: Intelligent auto-completion for commands, files, and options
- **Powerful History**: Shared history across sessions with advanced search
- **Customization**: Extensive theming and plugin ecosystem
- **Spelling Correction**: Automatic correction of typos in commands
- **Globbing**: Advanced pattern matching for file operations

## Our Configuration Features

### oh-my-zsh Integration
- **Framework**: Built on the popular oh-my-zsh framework
- **Theme**: Agnoster theme with Git integration and clean design
- **Plugin System**: Curated selection of useful plugins

### Installed Plugins
- **git**: Git aliases and status information
- **zsh-autosuggestions**: Fish-like autosuggestions based on history
- **zsh-syntax-highlighting**: Real-time syntax highlighting
- **docker**: Docker command completion and aliases
- **kubectl**: Kubernetes command completion
- **aws**: AWS CLI completion
- **node/npm**: Node.js and npm completions
- **python**: Python-specific enhancements
- **rust**: Rust development tools
- **golang**: Go development support

### Smart History Configuration
- **Large History**: 10,000 commands stored
- **Shared History**: History shared across all terminal sessions
- **Duplicate Removal**: Automatic deduplication of commands
- **Verification**: Confirm before executing history expansions

### Enhanced Navigation
- **Auto CD**: Type directory name to navigate (no `cd` needed)
- **Smart Pushd**: Automatic directory stack management
- **Tab Completion**: Advanced completion for commands and paths

## Integration with dotfiles-ai

### File Structure
```
zsh/
├── zshrc          # Main configuration file
└── README.md      # This file
```

### Symlink Integration
The installation script creates a symlink from `~/.dotfiles-ai/zsh/zshrc` to `~/.zshrc`, making this the active zsh configuration.

### Cross-Platform Compatibility
The configuration automatically detects your platform and adjusts:

**macOS Specific:**
- Homebrew PATH integration
- `brew` aliases for package management
- `open` command aliased to `o`

**Linux Specific:**
- APT aliases for Debian/Ubuntu/Mint systems
- Pacman aliases for Arch-based systems
- `xdg-open` command aliased to `o`

### Integration with Other Tools
- **Neovim**: `vim` and `vi` aliases point to `nvim`
- **tmux**: Convenient aliases and session management
- **Git**: Extensive Git aliases and workflow helpers

## Aliases Reference

### General Navigation
| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `ls -alF` | Long listing with file types |
| `la` | `ls -A` | List all files except . and .. |
| `l` | `ls -CF` | Compact listing with file types |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |

### Git Workflow
| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show repository status |
| `ga` | `git add` | Stage files |
| `gc` | `git commit` | Commit changes |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `gd` | `git diff` | Show differences |
| `gb` | `git branch` | List/manage branches |
| `gco` | `git checkout` | Switch branches |
| `glog` | `git log --oneline --graph --decorate` | Pretty log |

### Development Tools
| Alias | Command | Description |
|-------|---------|-------------|
| `vim` | `nvim` | Use Neovim instead of Vim |
| `vi` | `nvim` | Use Neovim instead of Vi |
| `tmux` | `tmux -2` | Start tmux with 256 colors |
| `t` | `tmux` | Quick tmux start |
| `ta` | `tmux attach` | Attach to tmux session |
| `tls` | `tmux list-sessions` | List tmux sessions |

### Directory Shortcuts
| Alias | Command | Description |
|-------|---------|-------------|
| `dotfiles` | `cd ~/.dotfiles-ai` | Go to dotfiles directory |
| `projects` | `cd ~/projects` | Go to projects directory |

### System Management
| Platform | Alias | Command | Description |
|----------|-------|---------|-------------|
| macOS | `brewup` | `brew update && brew upgrade` | Update Homebrew packages |
| macOS | `o` | `open` | Open files/directories |
| Linux | `aptup` | `sudo apt update && sudo apt upgrade` | Update APT packages |
| Linux | `aptin` | `sudo apt install` | Install APT packages |
| Linux | `apts` | `apt search` | Search APT packages |
| Linux | `o` | `xdg-open` | Open files/directories |

## Custom Functions

### `mkcd <directory>`
Create a directory and navigate into it:
```bash
mkcd new-project
# Creates 'new-project' directory and cd's into it
```

### `extract <archive>`
Extract various archive formats automatically:
```bash
extract archive.tar.gz
extract file.zip
extract document.rar
```

Supports: `.tar.gz`, `.tar.bz2`, `.zip`, `.rar`, `.7z`, `.gz`, `.bz2`, and more.

### `killp <process-name>`
Find and kill processes by name:
```bash
killp node          # Kill all node processes
killp python        # Kill all python processes
```

### `weather [location]`
Get weather information (requires `curl`):
```bash
weather              # Weather for current location
weather "New York"   # Weather for specific city
```

## Environment Integration

### Development Environments
- **Node.js**: NVM integration for version management
- **Rust**: Cargo environment automatically loaded
- **Go**: GOPATH and Go binary paths configured
- **Python**: Local Python packages in PATH

### Path Management
The configuration intelligently manages your PATH:
- Local binaries (`~/.local/bin`)
- Homebrew binaries (macOS)
- Go binaries (`$GOPATH/bin`)
- Cargo binaries (`~/.cargo/bin`)
- Node.js binaries (via NVM)

## Customization

### Local Customizations
Create these files for personal customizations:

**`~/.zshrc.local`**: Local zsh customizations that won't be overwritten
```bash
# Personal aliases
alias myproject='cd ~/my-special-project'

# Custom functions
my_function() {
    echo "This is my custom function"
}
```

**`~/.env`**: Environment variables
```bash
export MY_API_KEY="your-api-key"
export CUSTOM_PATH="/path/to/custom/tools"
```

### Adding New Aliases
Edit the aliases section in `zshrc` or add them to `~/.zshrc.local`:
```bash
alias myalias='my command here'
```

### Adding New Plugins
Add plugin names to the `plugins` array in `zshrc`:
```bash
plugins=(
    git
    zsh-autosuggestions
    # ... existing plugins
    your-new-plugin
)
```

## Integration with Other dotfiles-ai Components

### Neovim Integration
- Editor aliases point to Neovim
- Consistent environment variables
- Shared clipboard functionality

### tmux Integration
- Convenient tmux aliases
- Session management helpers
- Consistent terminal environment

### Git Integration
- Comprehensive Git aliases
- Status information in prompt
- Branch information display

## Troubleshooting

### oh-my-zsh Not Loading
Ensure oh-my-zsh is installed:
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Plugins Not Working
Check if plugins are installed in `~/.oh-my-zsh/custom/plugins/`:
```bash
ls ~/.oh-my-zsh/custom/plugins/
```

### Theme Not Displaying Correctly
Install a Powerline-compatible font:
- **macOS**: Install via Homebrew: `brew install font-powerline-symbols`
- **Linux**: Install via package manager: `sudo apt install fonts-powerline`

### Slow Startup
Check for heavy plugins or functions in your configuration. Use `zsh -xvs` to debug startup issues.

### History Not Shared
Ensure these options are set in your configuration:
```bash
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
```
