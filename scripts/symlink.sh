#!/bin/bash
# Symlink script for dotfiles-ai
# Creates symbolic links for all configuration files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Create backup directory
backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
log_info "Backup directory created: $backup_dir"

# Function to safely create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    # Create target directory if it doesn't exist
    local target_dir="$(dirname "$target")"
    mkdir -p "$target_dir"
    
    # Backup existing file/directory
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        log_warning "Backing up existing $description"
        mv "$target" "$backup_dir/"
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    log_success "$description linked: $target -> $source"
}

# Main symlink creation
log_info "Creating symlinks from $DOTFILES_DIR..."

# Neovim configuration
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim" "Neovim config"

# Terminal configuration removed - using gnome-terminal (no config needed)
echo "Using gnome-terminal as primary terminal (no additional config required)"

# Create prompt (Starship) config directory and symlink
echo "Setting up prompt configuration..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/prompt/starship.toml" "$HOME/.config/starship.toml"
echo "Prompt configuration symlinked"

# tmux configuration
create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf" "tmux config"

# zsh configuration
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc" "zsh config"

# Claude CLI configuration
if [[ -d "$DOTFILES_DIR/claude" ]]; then
    create_symlink "$DOTFILES_DIR/claude" "$HOME/.dotfiles/claude" "Claude CLI config"
fi

# Keyboard configuration
if [[ -d "$DOTFILES_DIR/keyboard" ]]; then
    create_symlink "$DOTFILES_DIR/keyboard" "$HOME/.dotfiles/keyboard" "Keyboard config"
fi

log_success "All symlinks created successfully!"
log_info "Backup files are stored in: $backup_dir"
log_success "Dotfiles symlinked successfully!"
log_info "Next steps:"
log_info "1. Restart your terminal or run: source ~/.zshrc"
log_info "2. Launch gnome-terminal - your configured terminal with emoji symbols"
log_info "3. Launch tmux - configuration will be applied automatically"
log_info "4. Launch Neovim - plugins will install automatically"
