#!/bin/bash
# ripgrep setup script - blazingly fast grep alternative

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

install_ripgrep() {
    log_info "Installing ripgrep..."
    
    if command -v rg &> /dev/null; then
        log_info "ripgrep is already installed: $(rg --version | head -n1)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install ripgrep
            else
                log_warning "Homebrew not found, installing via binary..."
                install_from_github
            fi
            ;;
        debian)
            # Try apt first
            if apt-cache show ripgrep &> /dev/null; then
                sudo apt update
                sudo apt install -y ripgrep
            else
                log_info "ripgrep not in apt, installing from GitHub releases..."
                install_from_github
            fi
            ;;
        linux)
            # Generic Linux installation
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y ripgrep 2>/dev/null || install_from_github
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y ripgrep 2>/dev/null || install_from_github
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm ripgrep 2>/dev/null || install_from_github
            else
                install_from_github
            fi
            ;;
    esac
    
    log_success "ripgrep installed successfully"
}

install_from_github() {
    log_info "Installing ripgrep from GitHub releases..."
    
    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            ARCH_STRING="x86_64"
            ;;
        aarch64|arm64)
            ARCH_STRING="aarch64"
            ;;
        *)
            log_warning "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    # Detect OS for download
    if [[ "$PLATFORM" == "macos" ]]; then
        OS_STRING="apple-darwin"
    else
        OS_STRING="unknown-linux-musl"
    fi
    
    # Get latest version
    LATEST_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Download and install
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    DOWNLOAD_URL="https://github.com/BurntSushi/ripgrep/releases/download/${LATEST_VERSION}/ripgrep-${LATEST_VERSION}-${ARCH_STRING}-${OS_STRING}.tar.gz"
    log_info "Downloading from: $DOWNLOAD_URL"
    
    curl -L -o ripgrep.tar.gz "$DOWNLOAD_URL"
    tar xzf ripgrep.tar.gz
    
    # Find the rg binary and install it
    RG_BIN=$(find . -name "rg" -type f | head -n1)
    if [[ -n "$RG_BIN" ]]; then
        sudo mv "$RG_BIN" /usr/local/bin/rg
        sudo chmod +x /usr/local/bin/rg
        log_success "ripgrep installed to /usr/local/bin/rg"
    else
        log_warning "Could not find rg binary in archive"
        exit 1
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

setup_ripgrep_config() {
    log_info "Setting up ripgrep configuration..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # Create config directory
    mkdir -p "$HOME/.config/ripgrep"
    
    # Create ripgrep config if we have one
    if [[ -f "$SCRIPT_DIR/ripgreprc" ]]; then
        ln -sf "$SCRIPT_DIR/ripgreprc" "$HOME/.ripgreprc"
        log_success "ripgrep configuration linked"
    else
        # Create a sensible default config
        cat > "$HOME/.ripgreprc" << 'EOF'
# ripgrep configuration file
# Set the colors for match highlighting
--colors=line:fg:yellow
--colors=line:style:bold
--colors=path:fg:green
--colors=path:style:bold
--colors=match:fg:red
--colors=match:style:bold

# Search hidden files/directories by default
--hidden

# But still ignore .git directories
--glob=!.git/

# Ignore node_modules
--glob=!node_modules/

# Ignore Python cache
--glob=!__pycache__/
--glob=!*.pyc

# Set the default max columns
--max-columns=150
--max-columns-preview

# Add file types
--type-add=markdown:*.{md,mkd,markdown}
--type-add=config:*.{json,toml,yaml,yml,ini,conf}

# Smart case search by default
--smart-case
EOF
        log_success "Created default ripgrep configuration"
    fi
    
    # Set RIPGREP_CONFIG_PATH in shell configs
    setup_shell_integration
}

setup_shell_integration() {
    log_info "Setting up shell integration..."
    
    local shell_config="
# Ripgrep configuration
export RIPGREP_CONFIG_PATH=\"\$HOME/.ripgreprc\"

# Ripgrep aliases
alias rg='rg --color=auto'
alias rgi='rg -i'  # case insensitive
alias rgf='rg -F'  # fixed string (literal)
alias rgl='rg -l'  # files with matches
alias rgc='rg -c'  # count matches
alias rgn='rg --no-ignore'  # search ignored files too
alias rgh='rg --hidden'  # search hidden files
alias rgw='rg -w'  # whole words only
"
    
    # Add to zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "RIPGREP_CONFIG_PATH" "$HOME/.zshrc"; then
            echo "$shell_config" >> "$HOME/.zshrc"
            log_success "Added ripgrep config to .zshrc"
        else
            log_info "Ripgrep already configured in .zshrc"
        fi
    fi
    
    # Add to bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "RIPGREP_CONFIG_PATH" "$HOME/.bashrc"; then
            echo "$shell_config" >> "$HOME/.bashrc"
            log_success "Added ripgrep config to .bashrc"
        else
            log_info "Ripgrep already configured in .bashrc"
        fi
    fi
}

# Main installation
main() {
    log_info "Setting up ripgrep..."
    
    install_ripgrep
    setup_ripgrep_config
    
    log_success "ripgrep setup complete!"
    echo
    echo "ripgrep (rg) - A blazingly fast grep alternative"
    echo
    echo "Common commands:"
    echo "  rg pattern           - Search for pattern"
    echo "  rg -i pattern        - Case insensitive search"
    echo "  rg -F literal        - Search for literal string"
    echo "  rg -l pattern        - List files with matches"
    echo "  rg -c pattern        - Count matches"
    echo "  rg --type js pattern - Search only JavaScript files"
    echo
    echo "Configured aliases: rgi, rgf, rgl, rgc, rgn, rgh, rgw"
}

main "$@"