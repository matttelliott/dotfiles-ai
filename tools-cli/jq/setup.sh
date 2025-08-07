#!/bin/bash
# jq setup script - lightweight JSON processor

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

install_jq() {
    log_info "Installing jq..."
    
    if command -v jq &> /dev/null; then
        log_info "jq is already installed: $(jq --version)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install jq
            else
                log_warning "Homebrew not found, installing via curl..."
                curl -L https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-amd64 -o /tmp/jq
                chmod +x /tmp/jq
                sudo mv /tmp/jq /usr/local/bin/jq
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y jq
            ;;
        linux)
            # Generic Linux installation
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y jq
            elif command -v yum &> /dev/null; then
                sudo yum install -y jq
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y jq
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm jq
            else
                log_warning "Package manager not found, installing via curl..."
                curl -L https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -o /tmp/jq
                chmod +x /tmp/jq
                sudo mv /tmp/jq /usr/local/bin/jq
            fi
            ;;
    esac
    
    log_success "jq installed successfully: $(jq --version)"
}

setup_jq_config() {
    log_info "Setting up jq configuration..."
    
    # Create config directory
    mkdir -p "$HOME/.config/jq"
    
    # Link custom jq modules if they exist
    if [[ -f "$PWD/jq/modules.jq" ]]; then
        ln -sf "$PWD/jq/modules.jq" "$HOME/.config/jq/modules.jq"
        log_success "Linked jq custom modules"
    fi
    
    # Link jqrc if it exists (custom startup file)
    if [[ -f "$PWD/jq/jqrc" ]]; then
        ln -sf "$PWD/jq/jqrc" "$HOME/.jqrc"
        log_success "Linked jqrc configuration"
    fi
}

# Main installation
main() {
    log_info "Setting up jq..."
    
    install_jq
    setup_jq_config
    
    # Verify installation
    if command -v jq &> /dev/null; then
        log_success "jq setup complete!"
        echo "Testing jq with sample JSON..."
        echo '{"test": "hello world"}' | jq .
    else
        log_warning "jq installation may have failed"
        exit 1
    fi
}

main "$@"