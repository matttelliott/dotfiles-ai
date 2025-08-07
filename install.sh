#!/bin/bash
# Master installation script for dotfiles-ai
# Runs both CLI and GUI installations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
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

# Show banner
show_banner() {
    echo
    echo -e "${BOLD}${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${MAGENTA}║                                                                ║${NC}"
    echo -e "${BOLD}${MAGENTA}║           DOTFILES-AI MASTER INSTALLER                        ║${NC}"
    echo -e "${BOLD}${MAGENTA}║                                                                ║${NC}"
    echo -e "${BOLD}${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Main installation
main() {
    show_banner
    
    log_info "Starting full dotfiles-ai installation..."
    log_info "This will install both CLI tools and GUI applications"
    echo
    
    # Check if we're in the right directory
    if [[ ! -f "install.sh" ]]; then
        log_error "Please run this script from the dotfiles-ai directory"
        exit 1
    fi
    
    # Run CLI installation
    log_info "Phase 1: Installing CLI tools and configurations..."
    echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
    if [[ -x "./install-cli.sh" ]]; then
        ./install-cli.sh
    else
        log_error "install-cli.sh not found or not executable"
        exit 1
    fi
    
    echo
    echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
    log_success "CLI installation complete!"
    echo
    
    # Run GUI installation
    log_info "Phase 2: Installing GUI applications..."
    echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
    if [[ -x "./install-gui.sh" ]]; then
        ./install-gui.sh
    else
        log_error "install-gui.sh not found or not executable"
        exit 1
    fi
    
    echo
    echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
    log_success "GUI installation complete!"
    echo
    
    # Final message
    echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}"
    log_success "Full installation complete!"
    echo
    log_info "Next steps:"
    echo "  1. Restart your terminal or run: ${BOLD}source ~/.zshrc${NC}"
    echo "  2. Run the post-install wizard: ${BOLD}./post-install.sh${NC}"
    echo
    log_info "For CLI-only systems, use: ${BOLD}./install-cli.sh${NC}"
    log_info "For GUI-only installation, use: ${BOLD}./install-gui.sh${NC}"
    echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}"
}

# Run main function
main "$@"