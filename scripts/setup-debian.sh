#!/bin/bash
# Debian/Ubuntu/Linux Mint setup script for dotfiles-ai

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Smart sudo management - minimize password prompts
log_info "Setting up sudo access..."
if sudo -n true 2>/dev/null; then
    log_success "Passwordless sudo detected - no password required"
    SUDO_SETUP=true
else
    echo "🔐 This script requires sudo access for package installation and system configuration."
    echo "Please enter your password once - it will be cached for the entire installation:"
    
    # Authenticate and extend timeout
    if sudo -v; then
        # Extend sudo timeout to 30 minutes for this session
        sudo sh -c 'echo "Defaults:$USER timestamp_timeout=30" > /etc/sudoers.d/dotfiles_install_temp'
        
        # Keep sudo session alive in background
        while true; do 
            sudo -n true
            sleep 60
            kill -0 "$$" 2>/dev/null || exit
        done 2>/dev/null &
        SUDO_KEEPALIVE_PID=$!
        
        log_success "Sudo session established and will remain active during installation"
        SUDO_SETUP=true
        
        # Cleanup function
        cleanup_sudo() {
            if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
                kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
            fi
            sudo rm -f /etc/sudoers.d/dotfiles_install_temp 2>/dev/null
        }
        trap cleanup_sudo EXIT
    else
        log_error "Failed to authenticate. Exiting."
        exit 1
    fi
fi

# Update package lists
log_info "Updating package lists..."
sudo apt update

# Install essential packages
log_info "Installing essential packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    zsh \
    tmux \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    xclip \
    ripgrep \
    fd-find \
    nodejs \
    npm \
    python3 \
    python3-pip

# Install Neovim (latest stable - ensure 0.10+)
log_info "Installing Neovim 0.10+..."
# Check if nvim exists and get version for proper numeric comparison
NEEDS_UPGRADE=false
if ! command -v nvim &> /dev/null; then
    NEEDS_UPGRADE=true
    log_info "Neovim not found, will install latest version"
else
    CURRENT_VERSION=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
    MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
    if [[ $MAJOR -lt 1 ]] && [[ $MINOR -lt 10 ]]; then
        NEEDS_UPGRADE=true
        log_info "Current Neovim version $CURRENT_VERSION is less than 0.10, upgrading..."
    fi
fi

if [[ "$NEEDS_UPGRADE" == "true" ]]; then
    # Uninstall old Neovim if it exists
    if command -v nvim &> /dev/null; then
        log_info "Uninstalling old Neovim version..."
        sudo apt remove -y neovim || true
        sudo rm -f /usr/bin/nvim /usr/local/bin/nvim || true
        sudo rm -rf /opt/nvim || true
    fi
    
    log_info "Downloading latest Neovim from GitHub releases..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Get the latest release download URL from GitHub API for x86_64
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.assets[] | select(.name == "nvim-linux-x86_64.appimage") | .browser_download_url')
    
    if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
        log_error "Failed to get Neovim download URL"
        exit 1
    fi
    
    log_info "Downloading from: $DOWNLOAD_URL"
    # Download latest Neovim AppImage
    curl -L -o nvim.appimage "$DOWNLOAD_URL"
    chmod u+x nvim.appimage
    
    # Extract the AppImage
    ./nvim.appimage --appimage-extract
    
    # Move to /opt and create symlink
    sudo mv squashfs-root /opt/nvim
    sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    log_success "Neovim $(nvim --version | head -n1) installed"
else
    NVIM_VERSION=$(nvim --version | head -n1)
    log_info "Neovim already installed: $NVIM_VERSION"
fi

# Install programming languages and version managers
log_info "Installing programming languages and version managers..."

# Install Rust via rustup (version manager for Rust)
log_info "Installing Rust via rustup..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    # Install common Rust tools
    cargo install ripgrep fd-find bat exa
    log_success "Rust and tools installed"
else
    log_info "Rust already installed"
fi

# Install Go (latest stable)
log_info "Installing Go..."
if ! command -v go &> /dev/null; then
    GO_VERSION="1.21.5"
    wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    rm "go${GO_VERSION}.linux-amd64.tar.gz"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.profile"
    log_success "Go installed"
else
    log_info "Go already installed"
fi

# Install Node.js via NVM (Node Version Manager)
log_info "Installing NVM and Node.js..."
if [[ ! -d "$HOME/.nvm" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    # Install global packages
    npm install -g typescript ts-node @types/node
    npm install -g prettier eslint
    npm install -g yarn pnpm
    log_success "NVM and Node.js installed"
else
    log_info "NVM already installed"
fi

# Install Python via uv (modern Python package and project manager)
log_info "Installing uv and Python..."
if ! command -v uv &> /dev/null; then
    # Install uv (fast Python package manager)
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.cargo/env"
    
    # Install Python 3.11 via uv
    uv python install 3.11
    uv python pin 3.11
    
    # Create a global virtual environment for common tools
    uv venv ~/.uv-global
    source ~/.uv-global/bin/activate
    uv pip install black flake8 mypy pytest ruff
    deactivate
    
    # Add uv global tools to PATH
    echo 'export PATH="$HOME/.uv-global/bin:$PATH"' >> "$HOME/.profile"
    
    log_success "uv and Python installed"
else
    log_info "uv already installed"
fi

# Install pyenv as fallback (optional)
log_info "Installing pyenv as fallback Python manager..."
if ! command -v pyenv &> /dev/null && [[ ! -d "$HOME/.pyenv" ]]; then
    log_info "Installing pyenv dependencies..."
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev
    
    # Install pyenv
    curl https://pyenv.run | bash
    
    # Add to shell profile
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.profile"
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.profile"
    echo 'eval "$(pyenv init -)"' >> "$HOME/.profile"
    
    log_success "pyenv installed as fallback"
elif [[ -d "$HOME/.pyenv" ]]; then
    log_info "pyenv directory exists, ensuring it's in PATH..."
    # Ensure pyenv is properly configured in shell profile
    if ! grep -q 'PYENV_ROOT' "$HOME/.profile" 2>/dev/null; then
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.profile"
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.profile"
        echo 'eval "$(pyenv init -)"' >> "$HOME/.profile"
    fi
    log_success "pyenv configuration updated"
else
    log_info "pyenv already installed and configured"
fi

# Install Ruby via rbenv (Ruby version manager)
log_info "Installing rbenv and Ruby..."
if ! command -v rbenv &> /dev/null && [[ ! -d "$HOME/.rbenv" ]]; then
    # Install Ruby build dependencies
    log_info "Installing Ruby build dependencies..."
    sudo apt install -y libyaml-dev libssl-dev libreadline-dev zlib1g-dev \
        libncurses5-dev libffi-dev libgdbm-dev libgdbm-compat-dev
    
    # Install rbenv
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    
    # Add to shell profile
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> "$HOME/.profile"
    echo 'eval "$(rbenv init -)"' >> "$HOME/.profile"
    
    # Install latest Ruby
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    rbenv install 3.2.2
    rbenv global 3.2.2
    
    # Install common gems
    gem install bundler rails
    log_success "rbenv and Ruby installed"
elif [[ -d "$HOME/.rbenv" ]]; then
    log_info "rbenv directory exists, ensuring it's configured properly..."
    # Install Ruby build dependencies if not already installed
    log_info "Installing Ruby build dependencies..."
    sudo apt install -y libyaml-dev libssl-dev libreadline-dev zlib1g-dev \
        libncurses5-dev libffi-dev libgdbm-dev libgdbm-compat-dev
    
    # Ensure rbenv is properly configured in shell profile
    if ! grep -q 'rbenv' "$HOME/.profile" 2>/dev/null; then
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> "$HOME/.profile"
        echo 'eval "$(rbenv init -)"' >> "$HOME/.profile"
    fi
    
    # Try to install Ruby if rbenv is working
    export PATH="$HOME/.rbenv/bin:$PATH"
    if command -v rbenv &> /dev/null; then
        eval "$(rbenv init -)"
        if ! rbenv versions | grep -q "3.2.2"; then
            log_info "Installing Ruby 3.2.2..."
            rbenv install 3.2.2
            rbenv global 3.2.2
            gem install bundler rails
        fi
    fi
    log_success "rbenv configuration updated"
else
    log_info "rbenv already installed and configured"
fi

# Install Java via SDKMAN
log_info "Installing SDKMAN and Java..."
if [[ ! -d "$HOME/.sdkman" ]]; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # Install Java, Maven, Gradle
    sdk install java 21.0.1-tem
    sdk install maven
    sdk install gradle
    log_success "SDKMAN and Java installed"
else
    log_info "SDKMAN already installed"
fi

# Install PHP via phpbrew (if needed)
log_info "Installing PHP..."
if ! command -v php &> /dev/null; then
    sudo apt install -y php php-cli php-common php-curl php-json php-mbstring
    # Install Composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    log_success "PHP and Composer installed"
else
    log_info "PHP already installed"
fi

# Install gnome-terminal (primary terminal - reliable)
echo "Installing gnome-terminal..."
if ! command -v gnome-terminal &> /dev/null; then
    sudo apt install gnome-terminal -y
    echo "gnome-terminal installed successfully"
else
    echo "gnome-terminal already available"
fi

# Configure gnome-terminal to use zsh as default shell
echo "Configuring gnome-terminal to use zsh..."
if command -v gsettings &> /dev/null; then
    # Get the default profile UUID
    DEFAULT_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT_PROFILE/"
    
    # Set custom command to use zsh
    gsettings set "$PROFILE_PATH" use-custom-command true
    gsettings set "$PROFILE_PATH" custom-command '/usr/bin/zsh'
    echo "gnome-terminal configured to use zsh"

    # Configure gnome-terminal to use DejaVu Sans Mono (preferred font)
    echo "Configuring gnome-terminal to use DejaVu Sans Mono..."
    gsettings set "$PROFILE_PATH" use-system-font false
    gsettings set "$PROFILE_PATH" font 'DejaVu Sans Mono 12'
    echo "gnome-terminal font configured with DejaVu Sans Mono"
    
    # Apply Tokyo Night color scheme
    echo "Applying Tokyo Night color scheme to gnome-terminal..."
    if [ -f "./gnome-terminal/setup-tokyonight.sh" ]; then
        ./gnome-terminal/setup-tokyonight.sh
    else
        echo "Warning: Tokyo Night setup script not found at ./gnome-terminal/setup-tokyonight.sh"
    fi
else
    echo "gsettings not available - please manually configure gnome-terminal to use zsh"
fi

# Set zsh as default system shell
echo "Setting zsh as default system shell..."
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    # Use sudo to modify /etc/passwd directly instead of chsh to avoid password prompt
    ZSH_PATH=$(which zsh)
    sudo sed -i "s|^$USER:.*:$HOME:.*$|$USER:x:$(id -u):$(id -g):$USER:$HOME:$ZSH_PATH|" /etc/passwd
    echo "Default shell changed to zsh. Please log out and log back in for full effect."
else
    echo "zsh is already the default shell"
fi

# WezTerm as backup option (has tab bar bug in this version)
echo "WezTerm available as backup terminal if needed"

# Install additional development tools
echo "Installing additional development tools..."
sudo apt update
sudo apt install -y ripgrep fd-find bat fzf eza tree htop neofetch git-delta

# Install essential fonts for terminal use (including Nerd Fonts for glyphs)
echo "Installing essential fonts with Nerd Font support..."

# Install DejaVu fonts (base fonts)
sudo apt install fonts-dejavu fonts-dejavu-core fonts-dejavu-extra -y

# Install system font packages for glyph support (same as old dotfiles)
sudo apt install fonts-powerline fonts-font-awesome -y

# Install additional monospace fonts as fallbacks
sudo apt install fonts-liberation fonts-noto-mono fonts-firacode -y

# Install awesome-terminal-fonts for proper glyph support (same as old dotfiles)
echo "Installing awesome-terminal-fonts for proper glyph support..."
if [ ! -d "$HOME/.fonts" ] || [ ! -f "$HOME/.fonts/fontawesome-webfont.ttf" ]; then
    echo "Downloading and installing awesome-terminal-fonts..."
    cd /tmp
    git clone https://github.com/gabrielelana/awesome-terminal-fonts
    cd awesome-terminal-fonts
    mkdir -p ~/.fonts
    cp -f ./build/*.ttf ~/.fonts
    cp -f ./build/*.sh ~/.fonts
    fc-cache -fv ~/.fonts
    cd ..
    rm -rf awesome-terminal-fonts
    echo "awesome-terminal-fonts installed successfully"
else
    echo "awesome-terminal-fonts already installed"
fi

# Install Starship prompt
echo "Installing Starship prompt..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    echo "Starship installed successfully"
else
    echo "Starship already installed"
fi

# Install Claude CLI for AI-powered coding assistance
echo "Installing Claude CLI..."
if [ -f "./claude/setup.sh" ]; then
    ./claude/setup.sh
else
    echo "Warning: Claude setup script not found at ./claude/setup.sh"
fi

# Configure keyboard (CapsLock -> Ctrl)
echo "Configuring keyboard (CapsLock -> Ctrl)..."
if [ -f "./keyboard/setup-keyboard.sh" ]; then
    ./keyboard/setup-keyboard.sh
else
    echo "Warning: Keyboard setup script not found at ./keyboard/setup-keyboard.sh"
fi

# Create symbolic links for fd (different name on Debian/Ubuntu)
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

# Set zsh as default shell
log_info "Setting zsh as default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    # Use sudo to modify /etc/passwd directly instead of chsh to avoid password prompt
    ZSH_PATH=$(which zsh)
    sudo sed -i "s|^$USER:.*:$HOME:.*$|$USER:x:$(id -u):$(id -g):$USER:$HOME:$ZSH_PATH|" /etc/passwd
    log_success "Default shell changed to zsh (restart terminal to take effect)"
else
    log_info "zsh is already the default shell"
fi

log_success "Debian/Ubuntu setup complete!"
log_info "Please restart your terminal to ensure all changes take effect"
