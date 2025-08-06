#!/usr/bin/env bash

# Post-installation wizard for dotfiles-ai
# Guides users through additional setup steps after main installation

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

# Welcome screen
show_welcome() {
    clear
    echo
    echo -e "${BOLD}${CYAN}"
    echo "    ╔══════════════════════════════════════════════════════╗"
    echo "    ║                                                      ║"
    echo "    ║        🧙 DOTFILES-AI POST-INSTALL WIZARD 🧙        ║"
    echo "    ║                                                      ║"
    echo "    ╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    echo "Welcome! This wizard will help you complete the setup of your"
    echo "development environment. We'll walk through each component and"
    echo "help you configure everything properly."
    echo
    wait_for_enter
}

# Check installation status
check_installation_status() {
    print_header "📋 Checking Installation Status"
    
    local all_good=true
    
    # Check shell
    if [[ -f "$HOME/.zshrc" ]]; then
        print_success "Zsh configuration installed"
    else
        print_error "Zsh configuration not found"
        all_good=false
    fi
    
    # Check oh-my-zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh-My-Zsh installed"
    else
        print_error "Oh-My-Zsh not installed"
        all_good=false
    fi
    
    # Check tmux
    if command_exists tmux && [[ -f "$HOME/.tmux.conf" ]]; then
        print_success "Tmux installed and configured"
    else
        print_warning "Tmux not fully configured"
    fi
    
    # Check Neovim
    if command_exists nvim && [[ -d "$HOME/.config/nvim" ]]; then
        print_success "Neovim installed and configured"
    else
        print_warning "Neovim not fully configured"
    fi
    
    # Check 1Password CLI
    if command_exists op; then
        local op_version=$(op --version 2>/dev/null)
        print_success "1Password CLI installed (version $op_version)"
    else
        print_warning "1Password CLI not installed"
    fi
    
    # Check Claude CLI
    if command_exists claude; then
        print_success "Claude CLI installed"
    else
        print_warning "Claude CLI not installed"
    fi
    
    echo
    if $all_good; then
        print_info "Basic installation looks good! Let's configure everything."
    else
        print_warning "Some components need attention. We'll help you fix them."
    fi
    
    wait_for_enter
}

# Setup 1Password
setup_1password() {
    print_header "🔐 1Password Configuration"
    
    if ! command_exists op; then
        print_warning "1Password CLI is not installed"
        echo "Would you like to install it now?"
        read -p "Install 1Password CLI? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_step "Running 1Password setup..."
            if [[ -x "./1password/setup.sh" ]]; then
                ./1password/setup.sh
            else
                print_error "1Password setup script not found"
            fi
        fi
    else
        print_info "1Password CLI is already installed"
        echo
        print_step "Let's authenticate with 1Password:"
        echo
        echo "Run: ${BOLD}op signin${NC}"
        echo
        echo "After signing in, you can:"
        echo "  • Generate SSH keys: ${BOLD}op-add-ssh-key github${NC}"
        echo "  • List SSH keys: ${BOLD}op-list-ssh-keys${NC}"
        echo "  • Get passwords: ${BOLD}op-get-password <item>${NC}"
        echo
        read -p "Would you like to sign in now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            op signin || print_warning "Sign in later with 'op signin'"
        fi
    fi
    
    wait_for_enter
}

# Setup SSH keys
setup_ssh_keys() {
    print_header "🔑 SSH Key Setup"
    
    if command_exists op && op account list &>/dev/null; then
        print_info "You're signed in to 1Password"
        echo
        echo "Would you like to generate SSH keys for common services?"
        echo
        
        local services=("github" "gitlab" "bitbucket" "personal")
        for service in "${services[@]}"; do
            read -p "Generate SSH key for $service? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_step "Generating SSH key for $service..."
                op ssh generate --title "$service" || print_warning "Failed to generate key for $service"
            fi
        done
        
        echo
        print_success "SSH keys generated!"
        echo
        echo "To use these keys:"
        echo "1. The keys are automatically available via 1Password SSH agent"
        echo "2. Copy the public key: ${BOLD}op item get <service> --fields 'public key'${NC}"
        echo "3. Add to your service (GitHub, GitLab, etc.)"
    else
        print_warning "1Password not configured. Set up 1Password first to manage SSH keys."
        echo
        echo "Traditional SSH key setup:"
        echo "  ${BOLD}ssh-keygen -t ed25519 -C 'your_email@example.com'${NC}"
    fi
    
    wait_for_enter
}

# Setup Git configuration
setup_git() {
    print_header "📦 Git Configuration"
    
    local current_name=$(git config --global user.name 2>/dev/null)
    local current_email=$(git config --global user.email 2>/dev/null)
    
    if [[ -n "$current_name" && -n "$current_email" ]]; then
        print_success "Git already configured:"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
        echo
        read -p "Would you like to change these settings? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            wait_for_enter
            return
        fi
    fi
    
    echo "Let's configure Git:"
    echo
    read -p "Enter your name: " git_name
    read -p "Enter your email: " git_email
    
    if [[ -n "$git_name" ]]; then
        git config --global user.name "$git_name"
        print_success "Git name set to: $git_name"
    fi
    
    if [[ -n "$git_email" ]]; then
        git config --global user.email "$git_email"
        print_success "Git email set to: $git_email"
    fi
    
    # Additional Git settings
    echo
    print_step "Setting recommended Git configurations..."
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor nvim
    
    print_success "Git configuration complete!"
    
    wait_for_enter
}

# Setup Claude CLI
setup_claude() {
    print_header "🤖 Claude CLI Configuration"
    
    if ! command_exists claude; then
        print_warning "Claude CLI is not installed"
        echo
        echo "To install Claude CLI:"
        echo "  ${BOLD}./claude/setup.sh${NC}"
        echo
        echo "Would you like to install it now?"
        read -p "Install Claude CLI? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [[ -x "./claude/setup.sh" ]]; then
                ./claude/setup.sh
            else
                print_error "Claude setup script not found"
            fi
        fi
    else
        print_success "Claude CLI is installed"
        echo
        if [[ -f "$HOME/.claude_token" ]]; then
            print_success "Claude token is configured"
        else
            print_warning "Claude token not configured"
            echo
            echo "To set up your Claude API token:"
            echo "1. Get your API key from: https://console.anthropic.com/settings/keys"
            echo "2. Run: ${BOLD}claude-token set${NC}"
            echo
            read -p "Would you like to set your token now? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                claude-token set
            fi
        fi
    fi
    
    wait_for_enter
}

# Setup Neovim
setup_neovim() {
    print_header "📝 Neovim Setup"
    
    if command_exists nvim; then
        print_success "Neovim is installed"
        echo
        print_step "Neovim will automatically install plugins on first launch"
        echo
        echo "Would you like to:"
        echo "1) Open Neovim now to install plugins"
        echo "2) Skip for now"
        echo
        read -p "Choice (1/2): " -n 1 -r
        echo
        
        if [[ "$REPLY" == "1" ]]; then
            print_info "Opening Neovim... Plugins will install automatically."
            print_info "After plugins install, you can quit with :q"
            sleep 2
            nvim +qall
            print_success "Neovim plugins installed!"
        fi
    else
        print_warning "Neovim not installed"
        echo "Install with: ${BOLD}brew install neovim${NC} (macOS)"
        echo "           or: ${BOLD}sudo apt install neovim${NC} (Debian/Ubuntu)"
    fi
    
    wait_for_enter
}

# Setup tmux
setup_tmux() {
    print_header "🖥️  Tmux Configuration"
    
    if command_exists tmux; then
        print_success "Tmux is installed"
        echo
        print_step "Installing Tmux Plugin Manager (TPM)..."
        
        if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
            git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
            print_success "TPM installed"
        else
            print_success "TPM already installed"
        fi
        
        echo
        print_info "To install tmux plugins:"
        echo "1. Start tmux: ${BOLD}tmux${NC}"
        echo "2. Press: ${BOLD}Ctrl-a I${NC} (capital I) to install plugins"
        echo
        print_info "Your tmux prefix is set to ${BOLD}Ctrl-a${NC}"
    else
        print_warning "Tmux not installed"
        echo "Install with: ${BOLD}brew install tmux${NC} (macOS)"
        echo "           or: ${BOLD}sudo apt install tmux${NC} (Debian/Ubuntu)"
    fi
    
    wait_for_enter
}

# Final steps
show_final_steps() {
    print_header "✅ Setup Complete!"
    
    echo "Your development environment is ready! Here's what to do next:"
    echo
    echo "${BOLD}1. Restart your terminal${NC} or run:"
    echo "   ${CYAN}source ~/.zshrc${NC}"
    echo
    echo "${BOLD}2. Start tmux${NC} and install plugins:"
    echo "   ${CYAN}tmux${NC}"
    echo "   Press ${CYAN}Ctrl-a I${NC} to install plugins"
    echo
    echo "${BOLD}3. Open Neovim${NC} to install plugins:"
    echo "   ${CYAN}nvim${NC}"
    echo
    echo "${BOLD}4. Sign in to 1Password${NC} (if using):"
    echo "   ${CYAN}op signin${NC}"
    echo
    echo "${BOLD}Quick Reference:${NC}"
    echo "  • Tmux prefix: ${CYAN}Ctrl-a${NC}"
    echo "  • Claude CLI: ${CYAN}claude <prompt>${NC}"
    echo "  • 1Password SSH: ${CYAN}op-add-ssh-key <name>${NC}"
    echo "  • Neovim: ${CYAN}nvim${NC} or ${CYAN}e${NC}"
    echo
    print_info "Configuration files:"
    echo "  • Zsh: ~/.zshrc"
    echo "  • Tmux: ~/.tmux.conf"
    echo "  • Neovim: ~/.config/nvim/"
    echo "  • SSH: ~/.ssh/config"
    echo
    echo -e "${BOLD}${GREEN}Enjoy your new development environment! 🧙${NC}"
}

# Main function
main() {
    detect_os
    
    show_welcome
    check_installation_status
    
    # Component setup
    setup_1password
    setup_ssh_keys
    setup_git
    setup_claude
    setup_neovim
    setup_tmux
    
    # Final steps
    show_final_steps
}

# Run the wizard
main "$@"