#!/bin/bash
# CLI-only installation script for dotfiles-ai
# Clean architecture version

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

# Install base system packages
install_system_base() {
    log_info "Installing base system packages..."
    
    if [[ "$OS" == "mint" ]]; then
        # Mint uses Debian's base
        if [[ -x "./system/debian/setup.sh" ]]; then
            bash "./system/debian/setup.sh"
        else
            log_error "Debian base setup not found"
            exit 1
        fi
    elif [[ -x "./system/$OS/setup.sh" ]]; then
        bash "./system/$OS/setup.sh"
    else
        log_error "No base setup found for OS: $OS"
        exit 1
    fi
    
    log_success "Base system packages installed"
}

# Configure system-specific settings (keyboard, etc.)
configure_system() {
    log_info "Configuring system settings..."
    
    # Keyboard configuration
    if [[ -x "./system/$OS/keyboard.sh" ]]; then
        log_info "Configuring keyboard..."
        bash "./system/$OS/keyboard.sh"
    else
        log_warning "No keyboard configuration for $OS"
    fi
}

# Install CLI tools
install_cli_tools() {
    log_info "Installing CLI tools..."
    
    # Priority order for tools (dependencies first)
    local priority_tools=("zsh" "tmux" "neovim" "fzf" "jq" "claude" "prompt" "1password")
    local installed_tools=()
    
    # Install priority tools first
    for tool in "${priority_tools[@]}"; do
        if [[ -d "tools-cli/$tool" ]] && [[ -f "tools-cli/$tool/setup.sh" ]]; then
            log_info "Setting up $tool..."
            if bash "tools-cli/$tool/setup.sh"; then
                log_success "$tool setup complete"
                installed_tools+=("$tool")
            else
                log_warning "$tool setup failed, continuing..."
            fi
        fi
    done
    
    # Install remaining tools
    for tool_dir in tools-cli/*/; do
        tool_name=$(basename "$tool_dir")
        
        # Skip if already installed in priority order
        if [[ " ${installed_tools[@]} " =~ " ${tool_name} " ]]; then
            continue
        fi
        
        if [[ -f "$tool_dir/setup.sh" ]]; then
            log_info "Setting up $tool_name..."
            if bash "$tool_dir/setup.sh"; then
                log_success "$tool_name setup complete"
            else
                log_warning "$tool_name setup failed, continuing..."
            fi
        fi
    done
}

# Install programming languages
install_languages() {
    log_info "Installing programming languages..."
    
    for lang_dir in tools-lang/*/; do
        if [[ -d "$lang_dir" ]] && [[ -f "$lang_dir/setup.sh" ]]; then
            lang_name=$(basename "$lang_dir")
            log_info "Setting up $lang_name..."
            if bash "$lang_dir/setup.sh"; then
                log_success "$lang_name setup complete"
            else
                log_warning "$lang_name setup failed, continuing..."
            fi
        fi
    done
}

# Main installation function
main() {
    log_info "Starting CLI-only dotfiles installation..."
    echo
    
    # Check if we're in the right directory
    if [[ ! -f "install-cli.sh" ]]; then
        log_error "Please run this script from the dotfiles-ai directory"
        exit 1
    fi
    
    # Installation steps
    detect_os
    install_system_base
    configure_system
    install_cli_tools
    install_languages
    
    echo
    log_success "CLI installation complete!"
    log_info "Restart your shell or run 'source ~/.zshrc' to apply changes"
}

# Run main function
main "$@"