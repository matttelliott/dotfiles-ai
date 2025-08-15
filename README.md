# dotfiles-ai

A comprehensive, modular dotfiles configuration repository for developer tools across macOS and Debian-based Linux platforms.

## Features

- **30+ CLI tools** - Modern replacements for traditional Unix tools (ripgrep, fd, fzf, bat, eza, etc.)
- **Programming languages** - Node.js, Python, Rust, Go, Ruby with version managers
- **Cloud tools** - AWS CLI, Google Cloud SDK, Terraform, Kubernetes tools
- **Development tools** - Docker, Git enhancements, database clients, and more
- **Modular architecture** - Each tool is self-contained with its own installer
- **Cross-platform** - Supports macOS and Debian-based Linux distributions
- **Idempotent** - Safe to re-run installers multiple times

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles-ai.git
cd dotfiles-ai

# Run the main installer (installs everything)
./install

# Or install only what you need:
./install cli        # CLI tools only
./install gui        # GUI applications only
./install neovim     # Just Neovim
./install neovim zsh # Multiple specific tools
```

## Installation Options

### Full Installation
Installs all CLI tools, programming languages, and system configurations:
```bash
./install         # or ./install all
```

### Selective Installation
Install specific categories or tools:
```bash
./install cli            # All CLI tools
./install gui            # All GUI applications  
./install lang           # All programming languages
./install neovim         # Just Neovim
./install docker k9s     # Multiple specific tools
```

### Manual Symlink Management
The installer uses GNU Stow for managing configuration symlinks:
```bash
# Manually link configs for a tool
stow -t ~ tools-cli/neovim

# Remove configs
stow -D -t ~ tools-cli/neovim  

# See what would be linked without doing it
stow -n -v -t ~ tools-cli/neovim
```

## Tool Categories

### CLI Tools
Modern, fast alternatives to traditional Unix tools:
- **Search & Find**: ripgrep, fd, fzf, The Silver Searcher
- **File Management**: eza (ls replacement), bat (cat replacement), zoxide (cd replacement)
- **Git Enhancements**: lazygit, git-delta, GitHub CLI
- **Development**: jq, yq, httpie, entr (file watcher)
- **Shell**: Starship prompt, Atuin (shell history), tmux
- **System**: htop, ncdu, 1Password CLI

### Programming Languages
Version-managed installations with common tools:
- **Node.js** - via nvm with npm packages
- **Python** - via uv (primary) or pyenv with pip packages
- **Rust** - via rustup with cargo packages
- **Go** - direct installation with go modules
- **Ruby** - via rbenv with gem packages

### Cloud & DevOps
- **AWS** - AWS CLI v2 with common profiles
- **Google Cloud** - gcloud SDK with components
- **Docker** - Container runtime and compose
- **Kubernetes** - kubectl, helm, k9s

### Database Tools
- PostgreSQL client (psql)
- SQLite with enhanced CLI
- Database migration tools

## Configuration Files

The repository includes configurations for:
- **Shell**: zsh and bash with aliases and functions
- **Git**: Global gitconfig with useful aliases
- **Editors**: Neovim with modern plugins
- **Terminal**: tmux with sensible defaults
- **Tools**: Individual tool configurations

## Platform Support

| Platform | Support | Package Manager |
|----------|---------|-----------------|
| macOS | ✅ Full | Homebrew |
| Ubuntu/Debian | ✅ Full | apt, binary downloads |
| Fedora/RHEL | ⚠️ Partial | dnf (limited) |
| Windows WSL | ✅ Full | apt |
| Other Linux | ⚠️ Varies | Binary downloads |

## Directory Structure

```
dotfiles-ai/
├── install                 # Main installer script
├── system/
│   ├── macos/             # macOS-specific setup
│   └── debian/            # Debian/Ubuntu setup
├── tools-cli/             # CLI tool modules
│   └── neovim/            # Example tool structure
│       ├── install        # Installation script
│       ├── .config/       # Stow-managed configs
│       │   └── nvim/
│       │       └── init.lua
│       └── README.md      # Documentation
├── tools-gui/             # GUI applications
└── tools-lang/            # Programming languages
```

### How It Works

1. **Unified Installer**: Single `./install` script handles everything
2. **GNU Stow**: Automatically manages configuration symlinks
3. **Modular Tools**: Each tool has its own `install` script and config directory
4. **Smart Symlinking**: Configs in stow-compatible structure (`.config/`, `.zshrc`, etc.)

## Customization

### Adding New Tools

1. Create a directory: `tools-cli/toolname/`
2. Add `install` script (no .sh extension) for software installation
3. Put configs in stow-compatible paths:
   - `.config/toolname/` for XDG configs
   - `.toolrc` for dotfiles in home directory
4. Include a `README.md` with documentation
5. The main installer will handle stow automatically

### Modifying Configurations

Edit configuration files directly in the repository. Changes will be applied on next installation or can be manually symlinked.

## Development

### Testing
```bash
# Test in Docker container
docker run -it ubuntu:latest
# Mount and run installer

# Test individual tools
./tools-cli/ripgrep/setup.sh
```

### Contributing

1. Follow the modular architecture pattern
2. Support both macOS and Debian platforms
3. Make installers idempotent
4. Include comprehensive documentation
5. Test on clean systems

## Requirements

### Minimum Requirements
- **macOS**: 10.15+ with Xcode Command Line Tools
- **Linux**: Ubuntu 20.04+ or Debian 10+
- **Memory**: 2GB RAM
- **Disk**: 5GB free space

### Prerequisites
- Git
- curl or wget
- sudo access (for system packages)

## Troubleshooting

### Common Issues

**Homebrew not found (macOS)**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Permission denied**
```bash
chmod +x install.sh
./install.sh
```

**Tool already installed**
The installers are idempotent and will skip already installed tools.

## License

MIT - See LICENSE file for details

## Acknowledgments

Built with inspiration from:
- The Unix philosophy of small, composable tools
- Modern CLI renaissance projects
- The dotfiles community

## Support

For issues, questions, or contributions, please open an issue on GitHub.