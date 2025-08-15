#!/bin/bash
# Minimal macOS system setup
# ONLY installs base tools needed by other installers

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    log_info "Checking for Xcode Command Line Tools..."
    
    if xcode-select -p &> /dev/null; then
        log_info "Xcode Command Line Tools already installed"
    else
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation to complete
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
        
        log_success "Xcode Command Line Tools installed"
    fi
}

# Install Homebrew
install_homebrew() {
    log_info "Checking for Homebrew..."
    
    if command -v brew &> /dev/null; then
        log_info "Homebrew already installed"
        brew update
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        log_success "Homebrew installed"
    fi
}

# Main
main() {
    log_info "Running minimal macOS system setup..."
    install_xcode_tools
    install_homebrew
    log_success "macOS base setup complete!"
}

main "$@"