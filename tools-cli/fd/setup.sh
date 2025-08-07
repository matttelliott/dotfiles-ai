#!/bin/bash
# fd setup script - simple, fast alternative to find

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

install_fd() {
    log_info "Installing fd..."
    
    # Check if fd or fdfind is already installed
    if command -v fd &> /dev/null; then
        log_info "fd is already installed: $(fd --version)"
        return 0
    elif command -v fdfind &> /dev/null; then
        log_info "fd is already installed as fdfind: $(fdfind --version)"
        # Create symlink for consistency
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install fd
            else
                log_warning "Homebrew not found, installing via binary..."
                install_from_github
            fi
            ;;
        debian)
            # On Debian/Ubuntu, fd is often packaged as fd-find
            sudo apt update
            if apt-cache show fd-find &> /dev/null; then
                sudo apt install -y fd-find
                # Create symlink for fd command
                mkdir -p "$HOME/.local/bin"
                ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
                log_info "Created symlink: fd -> fdfind"
            else
                log_info "fd-find not in apt, installing from GitHub..."
                install_from_github
            fi
            ;;
        linux)
            # Generic Linux installation
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y fd-find 2>/dev/null || install_from_github
                if command -v fdfind &> /dev/null; then
                    mkdir -p "$HOME/.local/bin"
                    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
                fi
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y fd-find 2>/dev/null || install_from_github
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm fd 2>/dev/null || install_from_github
            else
                install_from_github
            fi
            ;;
    esac
    
    log_success "fd installed successfully"
}

install_from_github() {
    log_info "Installing fd from GitHub releases..."
    
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
        OS_STRING="unknown-linux-gnu"
    fi
    
    # Get latest version
    LATEST_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    # Download and install
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    DOWNLOAD_URL="https://github.com/sharkdp/fd/releases/download/v${LATEST_VERSION}/fd-v${LATEST_VERSION}-${ARCH_STRING}-${OS_STRING}.tar.gz"
    log_info "Downloading from: $DOWNLOAD_URL"
    
    curl -L -o fd.tar.gz "$DOWNLOAD_URL"
    tar xzf fd.tar.gz
    
    # Find the fd binary and install it
    FD_BIN=$(find . -name "fd" -type f | head -n1)
    if [[ -n "$FD_BIN" ]]; then
        sudo mv "$FD_BIN" /usr/local/bin/fd
        sudo chmod +x /usr/local/bin/fd
        log_success "fd installed to /usr/local/bin/fd"
    else
        log_warning "Could not find fd binary in archive"
        exit 1
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

setup_fd_aliases() {
    log_info "Setting up fd aliases..."
    
    local aliases="
# fd aliases
alias fdd='fd --type d'      # directories only
alias fdf='fd --type f'      # files only
alias fdh='fd --hidden'      # include hidden files
alias fde='fd --extension'   # search by extension
alias fdi='fd --ignore-case' # case insensitive
alias fdx='fd --type x'      # executable files
alias fds='fd --size'        # filter by size
"
    
    # Add to zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "# fd aliases" "$HOME/.zshrc"; then
            echo "$aliases" >> "$HOME/.zshrc"
            log_success "Added fd aliases to .zshrc"
        else
            log_info "fd aliases already configured in .zshrc"
        fi
    fi
    
    # Add to bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "# fd aliases" "$HOME/.bashrc"; then
            echo "$aliases" >> "$HOME/.bashrc"
            log_success "Added fd aliases to .bashrc"
        else
            log_info "fd aliases already configured in .bashrc"
        fi
    fi
    
    # Ensure ~/.local/bin is in PATH
    ensure_local_bin_in_path
}

ensure_local_bin_in_path() {
    local path_addition='
# Add ~/.local/bin to PATH if it exists
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi'
    
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "HOME/.local/bin" "$HOME/.zshrc"; then
            echo "$path_addition" >> "$HOME/.zshrc"
            log_info "Added ~/.local/bin to PATH in .zshrc"
        fi
    fi
    
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "HOME/.local/bin" "$HOME/.bashrc"; then
            echo "$path_addition" >> "$HOME/.bashrc"
            log_info "Added ~/.local/bin to PATH in .bashrc"
        fi
    fi
}

# Main installation
main() {
    log_info "Setting up fd..."
    
    install_fd
    setup_fd_aliases
    
    log_success "fd setup complete!"
    echo
    echo "fd - A simple, fast alternative to 'find'"
    echo
    echo "Common commands:"
    echo "  fd pattern           - Find files/dirs matching pattern"
    echo "  fd -e txt            - Find all .txt files"
    echo "  fd -t d pattern      - Find directories only"
    echo "  fd -t f pattern      - Find files only"
    echo "  fd -H pattern        - Include hidden files"
    echo "  fd -I pattern        - Don't respect .gitignore"
    echo
    echo "Configured aliases: fdd, fdf, fdh, fde, fdi, fdx, fds"
}

main "$@"