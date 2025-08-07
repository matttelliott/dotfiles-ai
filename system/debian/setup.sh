#!/bin/bash
# Minimal Debian/Ubuntu system setup
# ONLY installs base packages needed by other tools

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

# Install ONLY the essential packages that other tools need
install_base_packages() {
    log_info "Installing minimal base packages for Debian/Ubuntu..."
    
    sudo apt update
    
    # Absolute minimum packages needed by other installers
    sudo apt install -y \
        curl \
        wget \
        git \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release \
        unzip
    
    log_success "Base packages installed"
}

# Main
main() {
    log_info "Running minimal Debian/Ubuntu system setup..."
    install_base_packages
    log_success "Debian/Ubuntu base setup complete!"
}

main "$@"