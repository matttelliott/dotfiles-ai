#!/bin/bash
# Common utilities for all installers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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
            fedora|rhel|centos)
                OS="fedora"
                ;;
            arch|manjaro)
                OS="arch"
                ;;
            *)
                OS="linux"
                ;;
        esac
    else
        OS="unknown"
    fi
    export OS
}

# Check if running in CI/non-interactive mode
is_ci() {
    # Check for explicit CI environment variables
    [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]] || [[ -n "$JENKINS_HOME" ]] || [[ -n "$GITLAB_CI" ]]
}

# Safe sudo that handles CI environments
safe_sudo() {
    if is_ci; then
        log_warning "Running in CI/non-interactive mode, skipping: $*"
        return 1
    else
        sudo "$@"
    fi
}

# Track if apt update has been run in this session
APT_UPDATED="${APT_UPDATED:-false}"

# Safe apt update that ignores repository errors and runs only once per session
safe_apt_update() {
    if is_ci; then
        log_warning "Running in CI/non-interactive mode, skipping apt update"
        return 1
    fi
    
    # Check if we've already updated in this session
    if [[ "$APT_UPDATED" == "true" ]]; then
        # Already updated, skip
        return 0
    fi
    
    log_info "Updating package lists (this may take a moment)..."
    
    # Run apt update but don't fail on repository errors
    # Suppress common warnings and errors that don't affect functionality
    if sudo apt-get update 2>&1 | \
        grep -v "^E: The repository.*does not have a Release file" | \
        grep -v "^W:.*Key is stored in legacy trusted.gpg" | \
        grep -v "^W: Target.*is configured multiple times" | \
        grep -v "^N: Updating from such a repository" | \
        grep -v "^N: See apt-secure" | \
        grep -v "^W: http://dl.google.com/linux/chrome" | \
        grep -v "^$"; then  # Also remove blank lines
        
        # Mark as updated for this session
        export APT_UPDATED=true
        log_success "Package lists updated"
    else
        # Even if it failed, mark as attempted to avoid retrying
        export APT_UPDATED=true
        log_info "Package list update completed with warnings"
    fi
    
    return 0
}

# Fix common APT repository issues for Linux Mint
fix_mint_repos() {
    # Only run on Linux Mint
    if [[ "$OS" != "mint" ]]; then
        return 0
    fi
    
    log_info "Checking for repository issues..."
    
    # Fix PostgreSQL repository (Mint uses Ubuntu base)
    if grep -q "wilma-pgdg" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        log_info "Fixing PostgreSQL repository for Mint..."
        # Mint 22 is based on Ubuntu 24.04 (noble)
        sudo sed -i 's/wilma-pgdg/noble-pgdg/g' /etc/apt/sources.list.d/*.list 2>/dev/null || true
    fi
    
    # Note about Chrome repository
    if grep -q "dl.google.com" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        if ! grep -q "signed-by=" /etc/apt/sources.list.d/*google*.list 2>/dev/null; then
            log_info "Note: Chrome repository uses legacy apt-key format"
            log_info "This warning can be safely ignored"
        fi
    fi
}

# Safe Python package installation handling externally managed environments
safe_python_install() {
    local package="$1"
    local package_name="${2:-$1}"  # Display name, defaults to package
    
    log_info "Installing $package_name..."
    
    # Check if already installed (check common command names)
    local cmd_to_check="$package_name"
    case "$package_name" in
        speedtest-cli) cmd_to_check="speedtest" ;;
        awscli) cmd_to_check="aws" ;;
        *) cmd_to_check="$package_name" ;;
    esac
    
    if command -v "$cmd_to_check" &> /dev/null; then
        log_info "$package_name is already installed"
        return 0
    fi
    
    # Try apt first (recommended for system packages)
    if [[ "$OS" == "debian" ]] || [[ "$OS" == "mint" ]]; then
        local apt_package="${package_name}"
        # Map common Python packages to apt names
        case "$package_name" in
            aws|awscli) apt_package="awscli" ;;
            speedtest-cli) apt_package="speedtest-cli" ;;
            httpie) apt_package="httpie" ;;
            glances) apt_package="glances" ;;
            pgcli) apt_package="pgcli" ;;
            litecli) apt_package="litecli" ;;
            mycli) apt_package="mycli" ;;
            *) apt_package="python3-${package_name}" ;;
        esac
        
        safe_apt_update
        if safe_sudo apt install -y "$apt_package" 2>/dev/null; then
            log_success "$package_name installed via apt"
            return 0
        fi
    fi
    
    # Try pipx for isolated installation
    if command -v pipx &> /dev/null; then
        if pipx install "$package" 2>/dev/null; then
            log_success "$package_name installed via pipx"
            # Ensure pipx bin is in PATH
            export PATH="$HOME/.local/bin:$PATH"
            return 0
        fi
    fi
    
    # Try pip with --user flag (may fail on externally managed systems)
    if command -v pip3 &> /dev/null; then
        if pip3 install --user "$package" 2>/dev/null; then
            log_success "$package_name installed via pip (user)"
            export PATH="$HOME/.local/bin:$PATH"
            return 0
        fi
    fi
    
    # Last resort: install with system package manager guidance
    log_warning "Cannot install $package_name via pip (externally managed environment)"
    log_info "Please install using one of these methods:"
    log_info "  1. sudo apt install $apt_package"
    log_info "  2. pipx install $package"
    log_info "  3. Use a virtual environment"
    return 1
}

# Stow configuration helper
stow_configs() {
    local tool_path="$1"
    local tool_name="$(basename "$tool_path")"
    local category_dir="$(dirname "$tool_path")"
    
    # Check if stow is available
    if ! command -v stow &> /dev/null; then
        log_warning "GNU Stow not available - skipping config linking for $tool_name"
        return 1
    fi
    
    # Check if there are stowable configs
    local has_configs=false
    if [[ -f "$tool_path/.zshrc" ]] || [[ -f "$tool_path/.bashrc" ]] || \
       [[ -f "$tool_path/.tmux.conf" ]] || [[ -d "$tool_path/.config" ]] || \
       [[ -f "$tool_path/.gitconfig" ]]; then
        has_configs=true
    fi
    
    if [[ "$has_configs" == "false" ]]; then
        return 0  # Nothing to stow
    fi
    
    log_info "Stowing $tool_name configs..."
    
    # Use -R (restow) to remove any existing links and create new ones
    # Use -v for verbose output
    # Use -t for target directory (home)
    if (cd "$category_dir" && stow -v -t "$HOME" -R "$tool_name" 2>&1 | grep -q "WARNING.*existing"); then
        log_warning "Config conflicts detected for $tool_name"
        log_info "Backing up existing configs..."
        
        # Find conflicting files and back them up
        local conflicts=$(cd "$category_dir" && stow -n -v -t "$HOME" -R "$tool_name" 2>&1 | grep "WARNING.*existing" | sed 's/.*existing target is neither//' | sed 's/:.*//')
        for conflict in $conflicts; do
            if [[ -e "$HOME/$conflict" ]] && [[ ! -L "$HOME/$conflict" ]]; then
                local backup="$HOME/$conflict.backup.$(date +%Y%m%d_%H%M%S)"
                mv "$HOME/$conflict" "$backup"
                log_info "Backed up: $conflict -> $(basename "$backup")"
            fi
        done
        
        # Try again after backing up
        if (cd "$category_dir" && stow -t "$HOME" -R "$tool_name"); then
            log_success "$tool_name configs linked via stow"
        else
            log_error "Failed to stow $tool_name configs"
            return 1
        fi
    elif (cd "$category_dir" && stow -t "$HOME" -R "$tool_name" 2>/dev/null); then
        log_success "$tool_name configs linked via stow"
    else
        log_warning "Could not stow $tool_name configs"
        return 1
    fi
}

# Export functions so they're available in subshells
export -f log_info log_success log_warning log_error detect_os is_ci safe_sudo safe_apt_update safe_python_install fix_mint_repos stow_configs
export APT_UPDATED