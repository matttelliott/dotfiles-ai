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

# Track what gets installed
INSTALLED_TOOLS=()
FAILED_TOOLS=()

# Function to run setup scripts
run_setup() {
    local tool_name="$1"
    local setup_script="$2"
    
    if [[ -f "$setup_script" ]]; then
        log_info "Installing $tool_name..."
        if bash "$setup_script"; then
            INSTALLED_TOOLS+=("$tool_name")
            log_success "$tool_name installed successfully"
        else
            FAILED_TOOLS+=("$tool_name")
            log_error "Failed to install $tool_name"
        fi
    else
        log_warning "Setup script not found: $setup_script"
        FAILED_TOOLS+=("$tool_name")
    fi
    echo
}

# Install GUI applications
install_gui_apps() {
    log_info "Installing GUI applications for $OS..."
    
    case $OS in
        macos)
            # Use modular setup scripts for GUI tools
            run_setup "Browsers" "./tools-gui/browsers/setup.sh"
            run_setup "VS Code" "./tools-gui/vscode/setup.sh"
            
            # Additional GUI tools can still be installed directly
            if command_exists brew; then
                log_info "Installing database tools..."
                brew install --cask dbeaver-community || log_warning "DBeaver already installed or failed"
                
                log_info "Installing Docker Desktop..."
                brew install --cask docker || log_warning "Docker Desktop already installed or failed"
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
            
            # VS Code
            if ! command_exists code; then
                log_info "Installing VS Code..."
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                sudo apt update
                sudo apt install -y code
            else
                log_info "VS Code already installed"
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
    
    echo
    echo "======================================="
    echo
    
    if [[ ${#INSTALLED_TOOLS[@]} -gt 0 ]]; then
        log_success "Successfully installed:"
        for tool in "${INSTALLED_TOOLS[@]}"; do
            echo "  ✓ $tool"
        done
        echo
    fi
    
    if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
        log_error "Failed to install:"
        for tool in "${FAILED_TOOLS[@]}"; do
            echo "  ✗ $tool"
        done
        echo
        log_info "Check the output above for error details"
        echo
    fi
    
    log_success "GUI installation complete!"
    log_info ""
    log_info "Installed applications may include:"
    log_info "  • Web Browsers (Chrome, Firefox, Brave, etc.)"
    log_info "  • VS Code - Code editor"
    log_info "  • DBeaver - Database management"
    log_info "  • Docker Desktop - Container management"
    log_info "  • 1Password - Password management"
    log_info ""
    log_info "Run 'post-install-gui.sh' to configure GUI applications"
}

# Run main function
main "$@"