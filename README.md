# Dotfiles-AI

A comprehensive, modular dotfiles repository with 40+ developer tools, modern CLI utilities, and complete development environment setup for macOS and Linux.

## Supported Platforms
- macOS (Darwin)
- Debian/Ubuntu Linux
- Linux Mint

## What's Included

### 🛠️ Core Development Tools
- **Neovim**: Modern editor with LSP, treesitter, and AI integrations
- **tmux**: Terminal multiplexer with custom configuration
- **zsh**: Advanced shell with oh-my-zsh and extensive aliases
- **Starship**: Cross-shell prompt with git integration
- **1Password**: CLI and SSH agent for secure credential management

### 🔍 Modern CLI Tools (30+)
- **Search & Navigation**: ripgrep, fd, fzf, zoxide, broot
- **File Management**: eza (ls replacement), bat (cat with syntax highlighting)
- **Git Tools**: lazygit, git-delta, GitHub CLI
- **Development**: jq, yq, httpie, curl, entr (file watcher)
- **Database Clients**: PostgreSQL (pgcli), SQLite (litecli), datasette
- **Cloud Tools**: AWS CLI v2, Google Cloud SDK, Terraform
- **Container Tools**: Docker, Docker Compose, Kubernetes (kubectl, helm, k9s)

### 🚀 Programming Languages
- **Node.js**: via nvm with global packages (yarn, pnpm, typescript)
- **Python**: via uv (10-100x faster) with pyenv fallback
- **Rust**: via rustup with cargo extensions
- **Go**: Latest version with essential tools
- **Ruby**: via rbenv with Rails and common gems

### 🎨 Terminal Enhancement
- **Terminal**: gnome-terminal (Linux) / iTerm2 (macOS)
- **Theme**: Tokyo Night across all tools
- **Fonts**: JetBrains Mono, Fira Code support
- **Keyboard**: CapsLock → Ctrl remapping

## Quick Install

```bash
git clone https://github.com/yourusername/dotfiles-ai.git ~/dotfiles-ai
cd ~/dotfiles-ai

# Full installation (all tools)
./install.sh

# Or install selectively:
./install-cli.sh   # CLI tools only
./install-gui.sh   # GUI applications only

# After installation, run the setup wizard:
./post-install.sh
```

The installation is modular and idempotent - safe to run multiple times.

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

## Individual Tool Installation

Each tool can be installed independently:

```bash
# Install a specific tool
./tools-cli/ripgrep/setup.sh
./tools-cli/docker/setup.sh
./tools-lang/python/setup.sh

# Install by category
for tool in tools-cli/*/setup.sh; do
  $tool
done
```

## Repository Structure

```
dotfiles-ai/
├── install.sh              # Main installer orchestrator
├── install-cli.sh          # CLI tools installer
├── install-gui.sh          # GUI applications installer
├── post-install.sh         # Interactive setup wizard
├── CLAUDE.md              # AI assistant context
├── system/                # System-level configurations
│   ├── macos/            # macOS-specific setup
│   └── debian/           # Debian/Ubuntu setup
├── tools-cli/            # CLI tool modules (30+ tools)
│   ├── ripgrep/         # Each tool has:
│   │   ├── setup.sh     # - Installation script
│   │   └── README.md    # - Documentation
│   ├── fd/
│   ├── bat/
│   ├── httpie/
│   ├── aws/
│   ├── gcloud/
│   ├── docker/
│   ├── kubernetes/
│   └── ...              # And many more
├── tools-gui/           # GUI application modules
│   └── browsers/        # Browser configurations
├── tools-lang/          # Programming languages
│   ├── node/           # Node.js via nvm
│   ├── python/         # Python via uv/pyenv
│   ├── rust/           # Rust via rustup
│   ├── go/             # Go installation
│   └── ruby/           # Ruby via rbenv
├── 1password/          # 1Password integration
├── claude/             # Claude CLI setup
├── nvim/               # Neovim configuration
├── tmux/               # tmux configuration
└── zsh/                # Zsh configuration
```

## Key Features

### 🎯 Modular Architecture
- Each tool is self-contained with its own setup script
- Install individual tools or everything at once
- No cross-dependencies between modules
- Platform-specific installations handled automatically

### ⚡ Performance Focused
- **uv** for Python - 10-100x faster than pip
- **ripgrep** - Blazingly fast search
- **fd** - Fast alternative to find
- **eza** - Modern, fast ls replacement
- **zoxide** - Smarter cd command

### 🔧 Developer Productivity
- Comprehensive aliases and functions for all tools
- Pre-configured templates and examples
- Integrated file watchers and auto-reload
- Modern HTTP clients for API testing
- Database clients with auto-completion

## Tool Highlights

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

## Notable Tool Configurations

### Cloud Development
- **AWS CLI v2** with SSO, aws-vault, SAM CLI, eksctl
- **Google Cloud SDK** with all components, Cloud SQL Proxy, Terraform
- Pre-configured aliases and helper functions for both platforms

### Container & Orchestration
- **Docker** with Docker Compose, lazydocker, dive, ctop
- **Kubernetes** tools: kubectl, helm, k9s, kubectx, stern
- **Colima** as Docker Desktop alternative on macOS

### Modern CLI Replacements
- `ls` → `eza` (with git integration and tree view)
- `cat` → `bat` (with syntax highlighting)
- `find` → `fd` (faster and user-friendly)
- `grep` → `ripgrep` (much faster)
- `cd` → `zoxide` (smart directory jumping)
- `ctrl-r` → `atuin` (better shell history)

### File Watching & Automation
- **entr** - Run commands when files change
- Pre-configured watchers for testing, building, and reloading
- Integration with all major build tools and test runners

## Customization

All configurations are modular and easily customizable:
- Shell aliases in each tool's setup script
- Configuration files in tool directories
- Templates in `~/.config/[tool]/templates/`
- Comprehensive README in each tool directory

## License

MIT License - see LICENSE file for details.
