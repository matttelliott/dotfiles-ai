#!/usr/bin/env bash

# CLI-only post-installation wizard for dotfiles-ai
# For servers, Docker containers, and headless environments

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
    echo "    ║     🖥️  DOTFILES-AI CLI POST-INSTALL WIZARD 🖥️      ║"
    echo "    ║                                                      ║"
    echo "    ╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    echo "Welcome! This wizard will help you complete the CLI setup of your"
    echo "development environment. We'll configure terminal tools and"
    echo "development utilities for headless/server environments."
    echo
    wait_for_enter
}

# Check installation status
check_installation_status() {
    print_header "📋 Checking CLI Installation Status"
    
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
    
    # Check fzf
    if command_exists fzf; then
        print_success "fzf fuzzy finder installed"
    else
        print_warning "fzf not installed"
    fi
    
    # Check Claude CLI
    if command_exists claude; then
        print_success "Claude CLI installed"
    else
        print_warning "Claude CLI not installed"
    fi
    
    echo
    if $all_good; then
        print_info "Basic CLI installation looks good! Let's configure everything."
    else
        print_warning "Some components need attention. We'll help you fix them."
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

# Setup SSH keys (without 1Password for CLI-only)
setup_ssh_keys() {
    print_header "🔑 SSH Key Setup"
    
    if [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]; then
        print_success "SSH keys already exist"
        echo
        echo "Found existing SSH keys:"
        ls -la ~/.ssh/*.pub 2>/dev/null | awk '{print "  " $NF}'
    else
        echo "Would you like to generate an SSH key?"
        read -p "Generate SSH key? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter your email for the SSH key: " ssh_email
            ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519"
            print_success "SSH key generated at ~/.ssh/id_ed25519"
            echo
            echo "Your public key:"
            cat "$HOME/.ssh/id_ed25519.pub"
            echo
            print_info "Add this key to GitHub, GitLab, or other services"
        fi
    fi
    
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
        echo "Install with: ${BOLD}sudo apt install neovim${NC} (Debian/Ubuntu)"
        echo "           or: ${BOLD}brew install neovim${NC} (macOS)"
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
        echo "Install with: ${BOLD}sudo apt install tmux${NC} (Debian/Ubuntu)"
        echo "           or: ${BOLD}brew install tmux${NC} (macOS)"
    fi
    
    wait_for_enter
}

# Final steps
show_final_steps() {
    print_header "✅ CLI Setup Complete!"
    
    echo "Your CLI development environment is ready! Here's what to do next:"
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
    echo "${BOLD}Quick Reference:${NC}"
    echo "  • Tmux prefix: ${CYAN}Ctrl-a${NC}"
    echo "  • fzf search: ${CYAN}Ctrl-R${NC} (history), ${CYAN}Ctrl-T${NC} (files)"
    echo "  • Neovim: ${CYAN}nvim${NC} or ${CYAN}e${NC}"
    echo
    print_info "Configuration files:"
    echo "  • Zsh: ~/.zshrc"
    echo "  • Tmux: ~/.tmux.conf"
    echo "  • Neovim: ~/.config/nvim/"
    echo
    echo -e "${BOLD}${GREEN}Enjoy your CLI development environment! 🚀${NC}"
}

# Main function
main() {
    detect_os
    
    show_welcome
    check_installation_status
    
    # CLI-only component setup
    setup_git
    setup_ssh_keys
    setup_claude
    setup_neovim
    setup_tmux
    
    # Final steps
    show_final_steps
}

# Run the wizard
main "$@"