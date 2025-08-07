#!/usr/bin/env bash

# GUI application post-installation wizard for dotfiles-ai
# For desktop environments only

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
print_header() {
    echo
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo
}

print_step() {
    echo -e "${BOLD}${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

wait_for_enter() {
    echo
    read -p "Press [Enter] to continue..."
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Welcome screen
show_welcome() {
    clear
    echo
    echo -e "${BOLD}${CYAN}"
    echo "    ╔══════════════════════════════════════════════════════╗"
    echo "    ║                                                      ║"
    echo "    ║     🖥️  DOTFILES-AI GUI POST-INSTALL WIZARD 🖥️      ║"
    echo "    ║                                                      ║"
    echo "    ╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    echo "Welcome! This wizard will help you configure GUI applications"
    echo "for your development environment."
    echo
    wait_for_enter
}

# Check GUI applications
check_gui_apps() {
    print_header "🖥️ Checking GUI Applications"
    
    # Browsers
    if command_exists firefox; then
        print_success "Firefox installed"
    else
        print_warning "Firefox not found"
    fi
    
    if command_exists google-chrome; then
        print_success "Google Chrome installed"
    else
        print_warning "Google Chrome not found"
    fi
    
    # Database tools
    if command_exists dbeaver; then
        print_success "DBeaver installed"
    else
        print_warning "DBeaver not found"
    fi
    
    # Docker Desktop
    if command_exists docker; then
        print_success "Docker installed"
        docker --version
    else
        print_warning "Docker not found"
    fi
    
    # 1Password
    if command_exists op; then
        print_success "1Password CLI installed"
    else
        print_warning "1Password CLI not found"
    fi
    
    wait_for_enter
}

# Setup 1Password desktop
setup_1password_desktop() {
    print_header "🔐 1Password Desktop Configuration"
    
    echo "1Password desktop application setup:"
    echo
    echo "1. Open 1Password from your applications menu"
    echo "2. Sign in with your account or create a new one"
    echo "3. Enable browser extensions:"
    echo "   • Firefox: Install 1Password extension from Add-ons"
    echo "   • Chrome: Install 1Password extension from Chrome Web Store"
    echo
    echo "4. Enable SSH agent:"
    echo "   • Go to Settings → Developer"
    echo "   • Enable 'Use the SSH agent'"
    echo "   • Enable 'Display key names when authorizing connections'"
    echo
    print_info "The CLI (op) will use biometric unlock once desktop app is configured"
    
    wait_for_enter
}

# Setup Docker Desktop
setup_docker_desktop() {
    print_header "🐳 Docker Desktop Configuration"
    
    if command_exists docker; then
        print_success "Docker is installed"
        echo
        echo "Docker Desktop configuration:"
        echo "1. Start Docker Desktop from your applications menu"
        echo "2. Sign in to Docker Hub (optional)"
        echo "3. Configure resources in Settings → Resources"
        echo "4. Enable Kubernetes (optional) in Settings → Kubernetes"
        echo
        
        # Test Docker
        echo "Testing Docker installation..."
        if docker run --rm hello-world &>/dev/null; then
            print_success "Docker is working correctly!"
        else
            print_warning "Docker daemon not running. Start Docker Desktop first."
        fi
    else
        print_warning "Docker not installed"
        echo "Install Docker Desktop from https://docker.com"
    fi
    
    wait_for_enter
}

# Setup browsers
setup_browsers() {
    print_header "🌐 Browser Configuration"
    
    echo "Browser setup for web development:"
    echo
    
    if command_exists firefox; then
        echo "${BOLD}Firefox:${NC}"
        echo "  • Install React DevTools"
        echo "  • Install Vue DevTools (if using Vue)"
        echo "  • Install Redux DevTools (if using Redux)"
        echo "  • Install 1Password extension"
        echo "  • Enable Developer Tools (F12)"
        echo
    fi
    
    if command_exists google-chrome; then
        echo "${BOLD}Chrome:${NC}"
        echo "  • Install React DevTools"
        echo "  • Install Vue DevTools (if using Vue)"
        echo "  • Install Redux DevTools (if using Redux)"
        echo "  • Install 1Password extension"
        echo "  • Install Lighthouse for performance testing"
        echo
    fi
    
    print_info "Consider installing these for cross-browser testing:"
    echo "  • Opera"
    echo "  • Vivaldi"
    echo "  • Edge (if on Windows/macOS)"
    
    wait_for_enter
}

# Setup DBeaver
setup_dbeaver() {
    print_header "🗄️ DBeaver Configuration"
    
    if command_exists dbeaver; then
        print_success "DBeaver is installed"
        echo
        echo "DBeaver setup:"
        echo "1. Launch DBeaver from your applications menu"
        echo "2. Create connections to your databases:"
        echo "   • PostgreSQL: Usually port 5432"
        echo "   • MySQL: Usually port 3306"
        echo "   • SQLite: Select local file"
        echo
        echo "3. Install additional drivers as needed"
        echo "4. Configure SSH tunnels if connecting to remote DBs"
        echo
        print_info "Store database passwords in 1Password for security"
    else
        print_warning "DBeaver not installed"
        echo "Install from https://dbeaver.io"
    fi
    
    wait_for_enter
}

# Final steps
show_final_steps() {
    print_header "✅ GUI Setup Complete!"
    
    echo "Your GUI applications are configured! Quick reference:"
    echo
    echo "${BOLD}Web Development:${NC}"
    echo "  • Firefox with DevTools"
    echo "  • Chrome with DevTools"
    echo "  • Cross-browser testing ready"
    echo
    echo "${BOLD}Database Management:${NC}"
    echo "  • DBeaver for all databases"
    echo "  • Store credentials in 1Password"
    echo
    echo "${BOLD}Container Management:${NC}"
    echo "  • Docker Desktop"
    echo "  • Docker CLI tools"
    echo
    echo "${BOLD}Password Management:${NC}"
    echo "  • 1Password with browser extensions"
    echo "  • SSH agent integration"
    echo
    echo -e "${BOLD}${GREEN}Your desktop development environment is ready! 🎉${NC}"
}

# Main function
main() {
    show_welcome
    check_gui_apps
    
    # GUI component setup
    setup_1password_desktop
    setup_docker_desktop
    setup_browsers
    setup_dbeaver
    
    # Final steps
    show_final_steps
}

# Run the wizard
main "$@"