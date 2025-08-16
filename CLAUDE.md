# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL CONTEXT

**This dotfiles repository is meant to be installed on target machines, NOT the host development machine.** 
IMPORTANT: Always update this repo dotfiles-ai before making changes on the host machine. Changes to the host machine should be done through the installers.

When the user says "let's install X" or "add X", interpret this as **adding X to the dotfiles configuration**, not installing it on the current host. All changes should be made to the installation scripts and configuration files in this repository.

## Project Overview

A comprehensive dotfiles configuration repository for developer tools across macOS and Debian-based Linux platforms. The repository uses a modular architecture where each tool is self-contained with its own setup script and documentation.

## Repository Structure

```
dotfiles-ai/
├── install.sh              # Main installer orchestrator
├── install-cli.sh          # CLI tools installer
├── install-gui.sh          # GUI applications installer  
├── post-install.sh         # Interactive post-install wizard
├── CLAUDE.md              # This file - AI assistant context
├── README.md              # User documentation
├── system/                # System-level configurations
│   ├── macos/            # macOS-specific setup
│   └── debian/           # Debian/Ubuntu setup
├── tools-cli/            # CLI tool modules
│   ├── ripgrep/         # Each tool has:
│   │   ├── setup.sh     # - Installation script
│   │   └── README.md    # - Documentation
│   └── ...              # 30+ CLI tools
├── tools-gui/           # GUI application modules
│   └── browsers/        # Browser configurations
└── tools-lang/          # Programming languages
    ├── node/           # Node.js via nvm
    ├── python/         # Python via uv/pyenv
    ├── rust/           # Rust via rustup
    ├── go/             # Go installation
    └── ruby/           # Ruby via rbenv
```

## Key Commands

### Installation Commands
```bash
# Full installation (run on target machine)
./install.sh

# CLI tools only
./install-cli.sh

# GUI applications only  
./install-gui.sh

# Interactive post-install wizard
./post-install.sh

# Individual tool installation
./tools-cli/ripgrep/setup.sh
```

### Development Commands
```bash
# When developing/testing, always commit frequently
git add . && git commit -m "Description"

# Run linting/checking if available
npm run lint      # If Node project
npm run typecheck # If TypeScript
ruff check       # If Python
```

## Adding New Tools

### For CLI Tools
1. Create directory: `tools-cli/toolname/`
2. Create `setup.sh` with installation logic
3. Create comprehensive `README.md`
4. Handle multiple platforms (macOS, Debian)
5. Add configuration files if needed
6. Update parent installer if necessary

### For GUI Applications
1. Create directory: `tools-gui/appname/`
2. Follow same pattern as CLI tools
3. Use cask on macOS, apt/snap on Linux

### For Programming Languages
1. Create directory: `tools-lang/language/`
2. Use version managers when available
3. Install common global packages/tools
4. Configure shell integration

## Architecture Principles

### Modular Design
- Each tool is completely self-contained
- Individual `setup.sh` handles all installation
- Tools can be installed independently
- No cross-dependencies between tools

### Platform Support
- Primary: macOS (Darwin) and Debian-based Linux
- Detection via `uname` and `/etc/os-release`
- Graceful fallbacks for unsupported platforms
- Binary downloads as last resort

### Configuration Management
- Configs stored in dotfiles repo
- Symlinked to target locations
- Preserves existing configs with backups
- Uses XDG Base Directory spec when possible

### Package Management Priority
1. **Python**: uv (primary), pipx, pip3 (fallbacks)
2. **Node**: nvm for version management
3. **Ruby**: rbenv for version management
4. **macOS**: Homebrew (brew)
5. **Linux**: apt, then binary downloads

## Important Patterns

### Shell Configuration
- Support both zsh and bash
- Add to both `.zshrc` and `.bashrc`
- Check for existing entries before adding
- Use heredocs for multi-line additions

### Error Handling
```bash
set -e  # Exit on error
log_info "Message"
log_success "Success"
log_warning "Warning"
```

### Installation Verification
- Always check if tool is already installed
- Show version after installation
- Provide quick start commands
- List configuration file locations

## Current Tool Inventory

### CLI Tools (30+)
- Search: ripgrep, fd, fzf, bat, eza
- Git: lazygit, git-delta
- Development: jq, yq, httpie, entr
- Cloud: aws-cli, gcloud, terraform
- Containers: docker, kubernetes tools
- Databases: postgresql, sqlite clients
- Modern tools: zoxide, atuin, starship

### Programming Languages
- Node.js (via nvm)
- Python (via uv with pyenv fallback)
- Rust (via rustup)
- Go (direct installation)
- Ruby (via rbenv)

### System Tools
- 1Password CLI
- Homebrew (macOS)
- Essential build tools

## Testing Strategy

- Primary testing via clean VMs
- Idempotent installers (safe to re-run)
- Platform-specific GitHub Actions (planned)
- Docker containers for Linux testing (planned)

## AI Assistant Notes

When Claude Code is working on this repository:

1. **Always interpret "install X" as adding to dotfiles**, not installing locally
2. **Create modular, self-contained tool directories**
3. **Write comprehensive READMEs with examples**
4. **Support both macOS and Debian platforms**
5. **Make frequent commits as requested**
6. **Use the TodoWrite tool to track progress**
7. **Don't prompt for input - make decisions and proceed**
8. **Follow existing patterns in the codebase**
9. **Add useful aliases and functions for each tool**
10. **Include templates and examples where applicable**

## Future Development

- Browser configurations and extensions
- VS Code settings and extensions
- Terminal emulator configurations
- Automated testing in CI/CD
- Ansible playbooks for remote deployment
- Backup and restore functionality
