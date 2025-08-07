#!/usr/bin/env bash
# Master post-installation wizard for dotfiles-ai
# Runs both CLI and GUI configuration wizards

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show banner
show_banner() {
    clear
    echo
    echo -e "${BOLD}${CYAN}"
    echo "    ╔══════════════════════════════════════════════════════╗"
    echo "    ║                                                      ║"
    echo "    ║      🧙 DOTFILES-AI POST-INSTALL WIZARD 🧙         ║"
    echo "    ║                                                      ║"
    echo "    ╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    echo "This master wizard will run both CLI and GUI configuration."
    echo
    echo "Press [Enter] to continue..."
    read -r
}

# Main function
main() {
    show_banner
    
    # Check if we're in the right directory
    if [[ ! -f "post-install.sh" ]]; then
        log_error "Please run this script from the dotfiles-ai directory"
        exit 1
    fi
    
    # Run CLI post-install wizard
    echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════════${NC}"
    log_info "Phase 1: CLI Configuration"
    echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════════${NC}"
    
    if [[ -x "./post-install-cli.sh" ]]; then
        ./post-install-cli.sh
    else
        log_error "post-install-cli.sh not found or not executable"
        exit 1
    fi
    
    echo
    echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════════${NC}"
    log_success "CLI configuration complete!"
    echo
    
    # Run GUI post-install wizard
    echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════════${NC}"
    log_info "Phase 2: GUI Application Configuration"
    echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════════${NC}"
    
    if [[ -x "./post-install-gui.sh" ]]; then
        ./post-install-gui.sh
    else
        log_error "post-install-gui.sh not found or not executable"
        exit 1
    fi
    
    echo
    echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}"
    log_success "Full configuration complete!"
    echo
    log_info "Your development environment is fully configured!"
    echo
    log_info "For CLI-only configuration: ${BOLD}./post-install-cli.sh${NC}"
    log_info "For GUI-only configuration: ${BOLD}./post-install-gui.sh${NC}"
    echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}"
}

# Run main function
main "$@"