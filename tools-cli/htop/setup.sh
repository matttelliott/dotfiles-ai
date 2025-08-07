#!/bin/bash
# htop setup script - interactive process viewer

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

install_htop() {
    log_info "Installing htop..."
    
    if command -v htop &> /dev/null; then
        log_info "htop is already installed: $(htop --version | head -n1)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install htop
            else
                log_warning "Homebrew not found, please install htop manually"
                exit 1
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y htop
            ;;
        linux)
            # Generic Linux installation
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y htop
            elif command -v yum &> /dev/null; then
                sudo yum install -y htop
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y htop
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm htop
            elif command -v apk &> /dev/null; then
                sudo apk add htop
            else
                log_warning "Package manager not found, please install htop manually"
                exit 1
            fi
            ;;
    esac
    
    log_success "htop installed successfully"
}

setup_htop_config() {
    log_info "Setting up htop configuration..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # Create config directory
    mkdir -p "$HOME/.config/htop"
    
    # Create htop config
    if [[ -f "$SCRIPT_DIR/htoprc" ]]; then
        ln -sf "$SCRIPT_DIR/htoprc" "$HOME/.config/htop/htoprc"
        log_success "htop configuration linked"
    else
        # Create a sensible default config
        cat > "$HOME/.config/htop/htoprc" << 'EOF'
# htop configuration file
# Beware! This file is rewritten by htop when settings are changed in the interface.

# General settings
highlight_base_name=1
highlight_megabytes=1
highlight_threads=1
tree_view=0
header_margin=1
detailed_cpu_time=1
cpu_count_from_zero=0
show_cpu_usage=1
show_cpu_frequency=1
update_process_names=1
account_guest_in_cpu_meter=0

# Display settings
color_scheme=0
delay=15
left_meters=AllCPUs Memory Swap
left_meter_modes=1 1 1
right_meters=Tasks LoadAverage Uptime
right_meter_modes=2 2 2

# Sort settings
sort_key=46  # Sort by CPU%
sort_direction=1
tree_sort_key=0
tree_sort_direction=1

# Hide kernel threads
hide_kernel_threads=1
hide_userland_threads=0

# Show program path
show_program_path=0

# Highlight new and old processes
highlight_changes=1
highlight_changes_delay_secs=5

# Header layout
header_layout=two_50_50
EOF
        log_success "Created default htop configuration"
    fi
    
    setup_aliases
}

setup_aliases() {
    log_info "Setting up htop aliases..."
    
    local aliases='
# htop aliases
alias top="htop"
alias htop-tree="htop -t"     # Tree view
alias htop-user="htop -u $USER"  # Show only current user processes
'
    
    # Add to zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "# htop aliases" "$HOME/.zshrc"; then
            echo "$aliases" >> "$HOME/.zshrc"
            log_success "Added htop aliases to .zshrc"
        else
            log_info "htop aliases already configured in .zshrc"
        fi
    fi
    
    # Add to bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "# htop aliases" "$HOME/.bashrc"; then
            echo "$aliases" >> "$HOME/.bashrc"
            log_success "Added htop aliases to .bashrc"
        else
            log_info "htop aliases already configured in .bashrc"
        fi
    fi
}

# Main installation
main() {
    log_info "Setting up htop..."
    
    install_htop
    setup_htop_config
    
    log_success "htop setup complete!"
    echo
    echo "htop - Interactive process viewer"
    echo
    echo "Key bindings:"
    echo "  F1/h     - Help"
    echo "  F2/S     - Setup"
    echo "  F3//     - Search"
    echo "  F4/\\     - Filter"
    echo "  F5/t     - Tree view"
    echo "  F6/< >   - Sort by column"
    echo "  F9/k     - Kill process"
    echo "  F10/q    - Quit"
    echo "  Space    - Tag process"
    echo "  U        - Untag all"
    echo "  c        - Tag and children"
    echo
    echo "Configured aliases: top, htop-tree, htop-user"
}

main "$@"