#!/bin/bash
# Main installation script for dotfiles-ai
# Supports Debian, Linux Mint, and macOS
#
# NOTE: This script is designed to run with minimal user interaction.
# It should only prompt once for sudo password if needed.
# All optional features (like 1Password) are installed automatically.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            debian|ubuntu)
                OS="debian"
                ;;
            linuxmint)
                OS="mint"
                ;;
            *)
                OS="linux"
                ;;
        esac
    else
        OS="unknown"
    fi
    
    log_info "Detected OS: $OS"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install dependencies based on OS
install_dependencies() {
    log_info "Installing dependencies for $OS..."
    
    case $OS in
        macos)
            ./scripts/setup-macos.sh
            ;;
        debian|mint)
            ./scripts/setup-debian.sh
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

# Install oh-my-zsh
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "oh-my-zsh installed"
    else
        log_info "oh-my-zsh already installed"
    fi
    
    # Install zsh plugins
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
    
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi
}

# Create symlinks
create_symlinks() {
    log_info "Creating symlinks..."
    
    # Backup existing configs
    backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Neovim
    if [[ -d "$HOME/.config/nvim" ]]; then
        log_warning "Backing up existing Neovim config to $backup_dir"
        mv "$HOME/.config/nvim" "$backup_dir/"
    fi
    mkdir -p "$HOME/.config"
    ln -sf "$PWD/nvim" "$HOME/.config/nvim"
    log_success "Neovim config linked"
    
    # tmux
    if [[ -f "$HOME/.tmux.conf" ]]; then
        log_warning "Backing up existing tmux config to $backup_dir"
        mv "$HOME/.tmux.conf" "$backup_dir/"
    fi
    ln -sf "$PWD/tmux/tmux.conf" "$HOME/.tmux.conf"
    log_success "tmux config linked"
    
    # zsh
    if [[ -f "$HOME/.zshrc" ]]; then
        log_warning "Backing up existing zsh config to $backup_dir"
        mv "$HOME/.zshrc" "$backup_dir/"
    fi
    ln -sf "$PWD/zsh/zshrc" "$HOME/.zshrc"
    log_success "zsh config linked"
    
    # Claude global rules
    mkdir -p "$HOME/.claude"
    if [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
        log_warning "Backing up existing Claude rules to $backup_dir"
        cp "$HOME/.claude/CLAUDE.md" "$backup_dir/CLAUDE_GLOBAL.md"
    fi
    ln -sf "$PWD/claude/GLOBAL_CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    log_success "Claude global rules installed"
}

# Main installation function
main() {
    log_info "Starting dotfiles-ai installation..."
    
    # Check if we're in the right directory
    if [[ ! -f "install.sh" ]]; then
        log_error "Please run this script from the dotfiles-ai directory"
        exit 1
    fi
    
    detect_os
    install_dependencies
    install_oh_my_zsh
    create_symlinks
    
    # Install 1Password automatically (no prompts)
    log_info "Setting up 1Password CLI and SSH integration..."
    if [[ -x "./1password/setup.sh" ]]; then
        ./1password/setup.sh
    else
        log_warning "1Password setup script not found, skipping..."
    fi
    
    log_success "Installation complete!"
    log_info ""
    log_info "Run the post-install wizard for guided setup:"
    log_info "  ./post-install.sh"
    log_info ""
    log_info "Or manually:"
    log_info "  • Restart terminal or run 'source ~/.zshrc'"
    log_info "  • For tmux: run 'tmux source ~/.tmux.conf'"
    log_info "  • For Neovim: plugins install on first launch"
    log_info "  • For 1Password: run 'op signin' to authenticate"
}

# Run main function
main "$@"
