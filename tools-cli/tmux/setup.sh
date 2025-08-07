#!/bin/bash
# tmux setup script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Detect OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    PLATFORM="macos"
elif [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then
        PLATFORM="debian"
    else
        PLATFORM="linux"
    fi
else
    log_warning "Unknown platform: $OS"
    exit 1
fi

install_tmux() {
    log_info "Installing tmux..."
    
    if command -v tmux &> /dev/null; then
        log_info "tmux is already installed: $(tmux -V)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install tmux
            else
                log_warning "Homebrew not found, please install tmux manually"
                exit 1
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y tmux
            ;;
        linux)
            # Generic Linux installation
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y tmux
            elif command -v yum &> /dev/null; then
                sudo yum install -y tmux
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y tmux
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm tmux
            else
                log_warning "Package manager not found, please install tmux manually"
                exit 1
            fi
            ;;
    esac
    
    log_success "tmux installed successfully: $(tmux -V)"
}

setup_tmux_config() {
    log_info "Setting up tmux configuration..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # Backup existing config if it exists
    if [[ -f "$HOME/.tmux.conf" ]]; then
        backup_file="$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing tmux config to $backup_file"
        mv "$HOME/.tmux.conf" "$backup_file"
    fi
    
    # Create symlink to our tmux config
    ln -sf "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"
    log_success "tmux configuration linked"
    
    # Install TPM (Tmux Plugin Manager) if not already installed
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        log_success "TPM installed"
        log_info "Press prefix + I (capital i) in tmux to install plugins"
    else
        log_info "TPM already installed"
    fi
}

# Main installation
main() {
    log_info "Setting up tmux..."
    
    install_tmux
    setup_tmux_config
    
    log_success "tmux setup complete!"
    echo
    echo "tmux shortcuts:"
    echo "  • Start new session: tmux new -s name"
    echo "  • List sessions: tmux ls"
    echo "  • Attach to session: tmux attach -t name"
    echo "  • Detach: Ctrl-a d (prefix is remapped from Ctrl-b)"
    echo "  • Install plugins: Ctrl-a I (capital i)"
}

main "$@"