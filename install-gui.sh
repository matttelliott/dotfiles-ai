#!/bin/bash
# GUI application installation script for dotfiles-ai
# For desktop environments only

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

# Install GUI applications
install_gui_apps() {
    log_info "Installing GUI applications for $OS..."
    
    case $OS in
        macos)
            # Install GUI apps via Homebrew Cask
            if command_exists brew; then
                log_info "Installing browsers..."
                brew install --cask firefox || log_warning "Firefox already installed or failed"
                brew install --cask google-chrome || log_warning "Chrome already installed or failed"
                
                log_info "Installing database tools..."
                brew install --cask dbeaver-community || log_warning "DBeaver already installed or failed"
                
                log_info "Installing development tools..."
                brew install --cask docker || log_warning "Docker Desktop already installed or failed"
                
                # Optional GUI apps
                # brew install --cask obsidian || log_warning "Obsidian already installed or failed"
                # brew install --cask spotify || log_warning "Spotify already installed or failed"
            else
                log_error "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            ;;
            
        debian|mint)
            log_info "Installing browsers..."
            
            # Firefox
            if ! command_exists firefox; then
                sudo apt update
                sudo apt install -y firefox-esr
            else
                log_info "Firefox already installed"
            fi
            
            # Chrome
            if ! command_exists google-chrome; then
                log_info "Installing Google Chrome..."
                wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
                sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
                sudo apt update
                sudo apt install -y google-chrome-stable
            else
                log_info "Google Chrome already installed"
            fi
            
            log_info "Installing database tools..."
            # DBeaver would need snap or flatpak
            if command_exists snap; then
                sudo snap install dbeaver-ce || log_warning "DBeaver already installed or failed"
            else
                log_warning "Snap not available, skipping DBeaver. Install manually from https://dbeaver.io"
            fi
            
            # Docker Desktop for Linux (if available)
            log_info "Docker should be installed separately via Docker's official installation method"
            ;;
            
        *)
            log_error "Unsupported OS for GUI installation: $OS"
            exit 1
            ;;
    esac
}

# Install 1Password GUI (in addition to CLI)
install_1password_gui() {
    log_info "Setting up 1Password desktop application..."
    
    case $OS in
        macos)
            if ! command_exists op; then
                brew install --cask 1password || log_warning "1Password already installed"
                brew install --cask 1password-cli || log_warning "1Password CLI already installed"
            else
                log_info "1Password already configured"
            fi
            ;;
            
        debian|mint)
            # 1Password for Linux
            if ! command_exists 1password; then
                log_info "Installing 1Password for Linux..."
                curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
                echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
                sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
                curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
                sudo apt update && sudo apt install -y 1password
            else
                log_info "1Password already installed"
            fi
            ;;
    esac
}

# Main installation function
main() {
    log_info "Starting GUI application installation..."
    
    # Check if we're in the right directory
    if [[ ! -f "install.sh" ]]; then
        log_error "Please run this script from the dotfiles-ai directory"
        exit 1
    fi
    
    # Check if running in a desktop environment
    if [[ -z "$DISPLAY" ]] && [[ "$OS" != "macos" ]]; then
        log_warning "No display detected. GUI applications may not work properly."
        echo "Continue anyway? (y/n)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Exiting GUI installation"
            exit 0
        fi
    fi
    
    detect_os
    install_gui_apps
    install_1password_gui
    
    log_success "GUI installation complete!"
    log_info ""
    log_info "Installed applications:"
    log_info "  • Firefox - Web browser"
    log_info "  • Google Chrome - Web browser"
    log_info "  • DBeaver - Database management"
    log_info "  • Docker Desktop - Container management (macOS)"
    log_info "  • 1Password - Password management"
    log_info ""
    log_info "Run 'post-install-gui.sh' to configure GUI applications"
}

# Run main function
main "$@"