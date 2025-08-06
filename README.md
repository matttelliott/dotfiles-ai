# Dotfiles-AI

A modern dotfiles configuration for developers using AI tools, optimized for Neovim, tmux, and zsh across multiple platforms.

## Supported Platforms
- Debian Linux
- Linux Mint  
- macOS

## Tools Configured
- **Terminal**: gnome-terminal (Linux) / iTerm2 (macOS) - reliable, clean terminals with excellent font rendering
- **Neovim**: Modern Vim-based editor with LSP, treesitter, and AI integrations
- **tmux**: Terminal multiplexer for session management
- **zsh**: Advanced shell with oh-my-zsh and custom configurations
- **1Password**: CLI and SSH agent integration for secure credential management
- **Claude CLI**: AI-powered coding assistance from the terminal
- **Starship**: Cross-shell prompt with git integration and customization
- **Keyboard**: CapsLock → Ctrl remapping for better ergonomics

## Quick Install

```bash
git clone https://github.com/yourusername/dotfiles-ai.git ~/.dotfiles-ai
cd ~/.dotfiles-ai
./install.sh

# After installation completes, run the setup wizard:
./post-install.sh
```

The installation is designed to be non-interactive and will only prompt for sudo password if needed.

## Post-Install Wizard

After running `install.sh`, use the interactive wizard to complete setup:

```bash
./post-install.sh
```

The wizard will guide you through:
- 🔐 1Password CLI authentication and SSH key generation
- 🔑 SSH key setup for GitHub, GitLab, etc.
- 📦 Git configuration (name, email, defaults)
- 🤖 Claude CLI token setup
- 📝 Neovim plugin installation
- 🖥️ Tmux plugin installation

## Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles-ai.git ~/.dotfiles-ai
   ```

2. Run the platform-specific setup:
   ```bash
   # For Debian/Mint
   ./scripts/setup-debian.sh
   
   # For macOS
   ./scripts/setup-macos.sh
   ```

3. Create symlinks:
   ```bash
   ./scripts/symlink.sh
   ```

4. Set up 1Password (optional):
   ```bash
   ./1password/setup.sh
   ```

## Structure

```
dotfiles-ai/
├── 1password/          # 1Password CLI and SSH agent setup
├── claude/             # Claude CLI configuration and setup
├── gnome-terminal/     # Terminal color schemes (Tokyo Night)
├── keyboard/           # Keyboard configuration (CapsLock -> Ctrl)
├── nvim/               # Neovim configuration with LSP support
├── prompt/             # Shell prompt configuration (Starship)
├── tmux/               # tmux terminal multiplexer configuration
├── zsh/                # Zsh shell configuration
├── scripts/            # Installation and setup scripts
├── docs/               # Documentation
├── install.sh          # Main installation script
├── post-install.sh     # Interactive setup wizard
└── README.md           # This file
```

## Features

### 1Password Integration
- **Secure SSH key management** - Generate and store SSH keys in 1Password vault
- **SSH agent integration** - Automatic SSH authentication via 1Password
- **CLI authentication** - Biometric unlock support for CLI operations
- **Helper functions**:
  - `op-add-ssh-key` - Generate new SSH keys
  - `op-get-password` - Retrieve passwords from vault
  - `op-list-ssh-keys` - List all SSH keys
- **Cross-platform support** - Works on macOS, Debian, and Linux Mint

### Neovim
- LSP support for multiple languages
- AI-powered code completion
- Modern plugin management with lazy.nvim
- Treesitter syntax highlighting
- File explorer and fuzzy finding
- Tokyo Night color scheme

### tmux
- Sensible defaults with Ctrl-a prefix
- Custom key bindings for better workflow
- Status bar with system info and battery status
- Session management helpers
- Plugin support via TPM
- Tokyo Night themed

### zsh
- oh-my-zsh integration
- Custom aliases and functions
- Git integration and shortcuts
- Auto-completion enhancements
- Automatic tmux session management
- 1Password CLI integration

### Keyboard Configuration
- CapsLock automatically bound to Ctrl across all platforms
- Cross-platform support (Linux X11/Wayland, macOS)
- Persistent configuration with system integration
- Enhanced developer ergonomics and productivity

### Claude CLI
- AI-powered coding assistance from the terminal
- Integrated aliases and helper functions
- Git commit message generation
- Code explanation and documentation
- File analysis and code review
- Token management system

### Terminal Enhancements
- **Starship prompt** - Fast, customizable prompt with git integration
- **Tokyo Night theme** - Consistent color scheme across all tools
- **gnome-terminal** setup script for Linux
- Modern font support (JetBrains Mono, Fira Code)

## Customization

Each tool's configuration is modular and can be customized by editing files in their respective directories.

## License

MIT License - see LICENSE file for details.
