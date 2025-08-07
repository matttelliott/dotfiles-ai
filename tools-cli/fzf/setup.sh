#!/bin/bash
# fzf (Fuzzy Finder) setup script

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
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
}

# Install fzf based on OS
install_fzf() {
    detect_os
    
    if command_exists fzf; then
        log_info "fzf is already installed ($(fzf --version))"
        return 0
    fi
    
    log_info "Installing fzf for $OS..."
    
    case $OS in
        macos)
            if command_exists brew; then
                brew install fzf
                # Run the install script for key bindings (but we'll use our own config)
                $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh --no-fish 2>/dev/null || true
            else
                log_error "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            ;;
        debian|mint)
            sudo apt update
            sudo apt install -y fzf
            ;;
        *)
            # Fallback: Install from git
            log_info "Installing fzf from git..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh --no-fish
            ;;
    esac
    
    log_success "fzf installed successfully"
}

# Create symlinks for fzf configuration
create_symlinks() {
    log_info "Creating fzf configuration symlinks..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create config directory
    mkdir -p "$HOME/.config/fzf"
    
    # Backup and symlink fzf.zsh if it exists in our dotfiles
    if [[ -f "$SCRIPT_DIR/fzf.zsh" ]]; then
        if [[ -f "$HOME/.config/fzf/fzf.zsh" ]] && [[ ! -L "$HOME/.config/fzf/fzf.zsh" ]]; then
            log_warning "Backing up existing fzf.zsh"
            mv "$HOME/.config/fzf/fzf.zsh" "$HOME/.config/fzf/fzf.zsh.backup"
        fi
        ln -sf "$SCRIPT_DIR/fzf.zsh" "$HOME/.config/fzf/fzf.zsh"
        log_success "Symlinked fzf.zsh"
    fi
    
    # Note: fzf.vim will be handled by nvim configuration
}

# Add fzf to shell configuration
setup_shell_integration() {
    log_info "Setting up fzf shell integration..."
    
    # Check if already configured in our zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "fzf configuration" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# fzf configuration" >> "$HOME/.zshrc"
            echo '[ -f ~/.config/fzf/fzf.zsh ] && source ~/.config/fzf/fzf.zsh' >> "$HOME/.zshrc"
            log_success "Added fzf to .zshrc"
        else
            log_info "fzf already configured in .zshrc"
        fi
    fi
}

# Main installation
main() {
    log_info "Starting fzf setup..."
    
    install_fzf
    create_symlinks
    setup_shell_integration
    
    log_success "fzf setup complete!"
    log_info "Restart your shell or run 'source ~/.zshrc' to use fzf"
    log_info ""
    log_info "Key bindings:"
    log_info "  Ctrl+R  - Search command history"
    log_info "  Ctrl+T  - Search files in current directory"
    log_info "  Alt+C   - Change to directory"
}

main "$@"