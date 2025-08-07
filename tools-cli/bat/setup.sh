#!/bin/bash
# bat setup script - cat with syntax highlighting and git integration

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

install_bat() {
    log_info "Installing bat..."
    
    # Check if bat or batcat is already installed
    if command -v bat &> /dev/null; then
        log_info "bat is already installed: $(bat --version)"
        return 0
    elif command -v batcat &> /dev/null; then
        log_info "bat is already installed as batcat: $(batcat --version)"
        # Create symlink for consistency
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat" 2>/dev/null || true
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install bat
            else
                log_warning "Homebrew not found, installing via binary..."
                install_from_github
            fi
            ;;
        debian)
            # On Debian/Ubuntu, bat is often packaged as batcat
            sudo apt update
            if apt-cache show bat &> /dev/null; then
                sudo apt install -y bat
                # On some systems it's installed as batcat
                if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
                    mkdir -p "$HOME/.local/bin"
                    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
                    log_info "Created symlink: bat -> batcat"
                fi
            else
                log_info "bat not in apt, installing from GitHub..."
                install_from_github
            fi
            ;;
        linux)
            # Generic Linux installation
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y bat 2>/dev/null || install_from_github
                if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
                    mkdir -p "$HOME/.local/bin"
                    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
                fi
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y bat 2>/dev/null || install_from_github
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm bat 2>/dev/null || install_from_github
            else
                install_from_github
            fi
            ;;
    esac
    
    log_success "bat installed successfully"
}

install_from_github() {
    log_info "Installing bat from GitHub releases..."
    
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
    LATEST_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    # Download and install
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    DOWNLOAD_URL="https://github.com/sharkdp/bat/releases/download/v${LATEST_VERSION}/bat-v${LATEST_VERSION}-${ARCH_STRING}-${OS_STRING}.tar.gz"
    log_info "Downloading from: $DOWNLOAD_URL"
    
    curl -L -o bat.tar.gz "$DOWNLOAD_URL"
    tar xzf bat.tar.gz
    
    # Find the bat binary and install it
    BAT_BIN=$(find . -name "bat" -type f | head -n1)
    if [[ -n "$BAT_BIN" ]]; then
        sudo mv "$BAT_BIN" /usr/local/bin/bat
        sudo chmod +x /usr/local/bin/bat
        log_success "bat installed to /usr/local/bin/bat"
    else
        log_warning "Could not find bat binary in archive"
        exit 1
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

setup_bat_config() {
    log_info "Setting up bat configuration..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # Create config directory
    mkdir -p "$HOME/.config/bat"
    
    # Create bat config
    if [[ -f "$SCRIPT_DIR/config" ]]; then
        ln -sf "$SCRIPT_DIR/config" "$HOME/.config/bat/config"
        log_success "bat configuration linked"
    else
        # Create a sensible default config
        cat > "$HOME/.config/bat/config" << 'EOF'
# bat configuration file

# Set the theme
--theme="TwoDark"

# Show line numbers
--style="numbers,changes,header"

# Use italic text on the terminal (not supported on all terminals)
--italic-text=always

# Use C++ syntax for Arduino .ino files
--map-syntax "*.ino:C++"

# Use JSON syntax for .prettierrc files
--map-syntax ".prettierrc:JSON"

# Use YAML syntax for .yamllint files
--map-syntax ".yamllint:YAML"
EOF
        log_success "Created default bat configuration"
    fi
    
    setup_shell_integration
}

setup_shell_integration() {
    log_info "Setting up shell integration..."
    
    local shell_config='
# bat configuration
export BAT_CONFIG_PATH="$HOME/.config/bat/config"

# bat aliases
alias cat="bat"
alias catp="bat -p"           # plain output (no line numbers)
alias catl="bat -l"           # specify language
alias catn="bat --style=numbers"  # only line numbers
alias batdiff="bat --diff"    # show diff
alias batman="bat --language=man"  # syntax highlight man pages

# Use bat as manpager
export MANPAGER="sh -c '\''col -bx | bat -l man -p'\''"

# bat + fzf integration
alias batf="fzf --preview '\''bat --color=always --style=numbers --line-range=:500 {}'\''"
'
    
    # Add to zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "BAT_CONFIG_PATH" "$HOME/.zshrc"; then
            echo "$shell_config" >> "$HOME/.zshrc"
            log_success "Added bat config to .zshrc"
        else
            log_info "bat already configured in .zshrc"
        fi
    fi
    
    # Add to bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "BAT_CONFIG_PATH" "$HOME/.bashrc"; then
            echo "$shell_config" >> "$HOME/.bashrc"
            log_success "Added bat config to .bashrc"
        else
            log_info "bat already configured in .bashrc"
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
    log_info "Setting up bat..."
    
    install_bat
    setup_bat_config
    
    log_success "bat setup complete!"
    echo
    echo "bat - A cat clone with syntax highlighting and Git integration"
    echo
    echo "Common commands:"
    echo "  bat file.txt         - View file with syntax highlighting"
    echo "  bat -p file.txt      - Plain output (no decorations)"
    echo "  bat -l rust file     - Force language syntax"
    echo "  bat -n file.txt      - Show line numbers only"
    echo "  bat --diff f1 f2     - Show diff between files"
    echo
    echo "Configured aliases: cat, catp, catl, catn, batdiff, batman, batf"
    echo "Man pages will now use bat for syntax highlighting!"
}

main "$@"