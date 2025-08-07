#!/bin/bash
# Comprehensive CLI tools installation script
# Installs all available CLI tools with progress tracking

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Track installation status
TOTAL_TOOLS=0
INSTALLED_TOOLS=()
FAILED_TOOLS=()

# Install a tool and track status
install_tool() {
    local category="$1"
    local tool="$2"
    local setup_path="$category/$tool/setup.sh"
    
    ((TOTAL_TOOLS++))
    
    if [[ -f "$setup_path" ]]; then
        log_info "[$TOTAL_TOOLS] Installing $tool..."
        if bash "$setup_path" > /dev/null 2>&1; then
            INSTALLED_TOOLS+=("$tool")
            log_success "$tool installed"
        else
            FAILED_TOOLS+=("$tool")
            log_error "Failed to install $tool"
        fi
    else
        FAILED_TOOLS+=("$tool (setup script not found)")
        log_warning "Setup script not found for $tool"
    fi
}

main() {
    log_info "Starting comprehensive CLI tools installation..."
    echo
    log_info "This will install all available CLI tools:"
    echo
    
    # List all tools to be installed
    echo "Core Tools:"
    echo "  • zsh - Z shell"
    echo "  • tmux - Terminal multiplexer"
    echo "  • neovim - Text editor"
    echo "  • fzf - Fuzzy finder"
    echo "  • prompt - Starship prompt"
    echo
    
    echo "Modern CLI Replacements:"
    echo "  • ripgrep - Fast grep replacement"
    echo "  • fd - Fast find replacement"
    echo "  • bat - Better cat with syntax highlighting"
    echo "  • eza - Modern ls replacement"
    echo "  • tree - Directory tree viewer"
    echo "  • jq - JSON processor"
    echo "  • htop - Process viewer"
    echo
    
    echo "Development Tools:"
    echo "  • lazygit - Git TUI"
    echo "  • httpie - HTTP client"
    echo "  • entr - File watcher"
    echo "  • direnv - Project environments"
    echo "  • tmuxinator - Tmux session manager"
    echo
    
    echo "Cloud & Infrastructure:"
    echo "  • aws - AWS CLI"
    echo "  • gcloud - Google Cloud SDK"
    echo "  • terraform - Infrastructure as Code"
    echo "  • docker - Container runtime"
    echo "  • kubernetes - Container orchestration"
    echo
    
    echo "Database Tools:"
    echo "  • postgres - PostgreSQL client"
    echo "  • sqlite - SQLite tools"
    echo
    
    echo "Network Tools:"
    echo "  • network - nmap, netcat, mtr, etc."
    echo "  • monitoring - btop, ncdu, glances"
    echo
    
    echo "Languages:"
    echo "  • node - Node.js via nvm"
    echo "  • python - Python via uv/pyenv"
    echo "  • go - Go language"
    echo "  • rust - Rust via rustup"
    echo "  • ruby - Ruby via rbenv"
    echo
    
    echo "Utilities:"
    echo "  • 1password - Password manager CLI"
    echo "  • claude - Claude CLI assistant"
    echo
    
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
    echo
    
    # Start installation
    log_info "Installing tools..."
    echo
    
    # Core tools (install first as others may depend on them)
    install_tool "tools-cli" "zsh"
    install_tool "tools-cli" "tmux"
    install_tool "tools-cli" "neovim"
    install_tool "tools-cli" "fzf"
    install_tool "tools-cli" "jq"
    install_tool "tools-cli" "prompt"
    
    # Modern CLI replacements
    install_tool "tools-cli" "ripgrep"
    install_tool "tools-cli" "fd"
    install_tool "tools-cli" "bat"
    install_tool "tools-cli" "eza"
    install_tool "tools-cli" "tree"
    install_tool "tools-cli" "htop"
    
    # Development tools
    install_tool "tools-cli" "lazygit"
    install_tool "tools-cli" "httpie"
    install_tool "tools-cli" "entr"
    install_tool "tools-cli" "direnv"
    install_tool "tools-cli" "tmuxinator"
    
    # Cloud & Infrastructure
    install_tool "tools-cli" "aws"
    install_tool "tools-cli" "gcloud"
    install_tool "tools-cli" "terraform"
    install_tool "tools-cli" "docker"
    install_tool "tools-cli" "kubernetes"
    
    # Database tools
    install_tool "tools-cli" "postgres"
    install_tool "tools-cli" "sqlite"
    
    # Network and monitoring
    install_tool "tools-cli" "network"
    install_tool "tools-cli" "monitoring"
    
    # Programming languages
    install_tool "tools-lang" "node"
    install_tool "tools-lang" "python"
    install_tool "tools-lang" "go"
    install_tool "tools-lang" "rust"
    install_tool "tools-lang" "ruby"
    
    # Utilities
    install_tool "tools-cli" "1password"
    install_tool "tools-cli" "claude"
    
    # Summary
    echo
    echo "======================================="
    echo "         INSTALLATION SUMMARY"
    echo "======================================="
    echo
    
    local success_count=${#INSTALLED_TOOLS[@]}
    local fail_count=${#FAILED_TOOLS[@]}
    
    echo "Total tools processed: $TOTAL_TOOLS"
    echo "Successfully installed: $success_count"
    echo "Failed installations: $fail_count"
    echo
    
    if [[ $success_count -gt 0 ]]; then
        log_success "Successfully installed tools:"
        for tool in "${INSTALLED_TOOLS[@]}"; do
            echo "  ✓ $tool"
        done
        echo
    fi
    
    if [[ $fail_count -gt 0 ]]; then
        log_error "Failed to install:"
        for tool in "${FAILED_TOOLS[@]}"; do
            echo "  ✗ $tool"
        done
        echo
        log_info "You can try installing failed tools individually"
        echo
    fi
    
    if [[ $success_count -gt 0 ]]; then
        log_success "Installation complete!"
        echo
        echo "Next steps:"
        echo "  1. Restart your shell or run: source ~/.zshrc"
        echo "  2. Run post-install-cli.sh for additional configuration"
        echo "  3. Run install-gui.sh for GUI applications (if on desktop)"
        echo
        echo "Some tools may require additional setup:"
        echo "  • 1Password: Run 'op signin' to connect your account"
        echo "  • Claude: Configure with your API key"
        echo "  • AWS/GCloud: Configure credentials"
        echo "  • Docker: May require daemon to be started"
    else
        log_error "No tools were installed successfully"
        log_info "Please check your system requirements and try again"
    fi
}

# Check if running from correct directory
if [[ ! -f "install-cli.sh" ]]; then
    log_error "Please run this script from the dotfiles-ai root directory"
    exit 1
fi

main "$@"