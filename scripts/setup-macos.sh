#!/bin/bash
# macOS setup script for dotfiles-ai

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

# Install Homebrew if not present
log_info "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -d "/opt/homebrew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed"
else
    log_info "Homebrew already installed"
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Install essential packages and development tools
log_info "Installing essential packages..."
brew install \
    git \
    zsh \
    tmux \
    curl \
    wget \
    ripgrep \
    fd \
    fzf \
    bat \
    eza \
    tree \
    htop \
    jq

# Install/upgrade Neovim to ensure we have 0.10+
log_info "Installing/upgrading Neovim to latest version..."
NEEDS_UPGRADE=false
if command -v nvim &> /dev/null; then
    CURRENT_VERSION=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
    MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
    if [[ $MAJOR -lt 1 ]] && [[ $MINOR -lt 10 ]]; then
        NEEDS_UPGRADE=true
        log_info "Uninstalling old Neovim version $CURRENT_VERSION..."
        brew uninstall neovim || true
        log_info "Installing latest Neovim..."
        brew install neovim
    else
        log_info "Neovim $CURRENT_VERSION already meets requirements"
    fi
else
    log_info "Installing Neovim..."
    brew install neovim
    NEEDS_UPGRADE=true
fi
log_success "Neovim $(nvim --version | head -n1) ready"



# Install tmux clipboard utility for macOS
log_info "Installing reattach-to-user-namespace for tmux clipboard support..."
brew install reattach-to-user-namespace

# Install programming languages and version managers
log_info "Installing programming languages and version managers..."

# Install Rust via rustup (version manager for Rust)
log_info "Installing Rust via rustup..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    # Install common Rust tools
    cargo install ripgrep fd-find bat eza
    log_success "Rust and tools installed"
else
    log_info "Rust already installed"
fi

# Install Go via Homebrew
log_info "Installing Go..."
brew install go
log_success "Go installed"

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
    echo 'export PATH="$HOME/.uv-global/bin:$PATH"' >> "$HOME/.zprofile"
    
    log_success "uv and Python installed"
else
    log_info "uv already installed"
fi

# Install pyenv as fallback (optional)
log_info "Installing pyenv as fallback Python manager..."
if ! command -v pyenv &> /dev/null; then
    brew install pyenv
    
    # Add to shell profile
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.zprofile"
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.zprofile"
    echo 'eval "$(pyenv init -)"' >> "$HOME/.zprofile"
    
    log_success "pyenv installed as fallback"
else
    log_info "pyenv already installed"
fi

# Install Ruby via rbenv (Ruby version manager)
log_info "Installing rbenv and Ruby..."
if ! command -v rbenv &> /dev/null; then
    brew install rbenv
    
    # Add to shell profile
    echo 'eval "$(rbenv init -)"' >> "$HOME/.zprofile"
    
    # Install latest Ruby
    eval "$(rbenv init -)"
    rbenv install 3.2.2
    rbenv global 3.2.2
    
    # Install common gems
    gem install bundler rails
    log_success "rbenv and Ruby installed"
else
    log_info "rbenv already installed"
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

# Install PHP via Homebrew
log_info "Installing PHP..."
if ! command -v php &> /dev/null; then
    brew install php
    # Install Composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    log_success "PHP and Composer installed"
else
    log_info "PHP already installed"
fi

# Install additional development tools
log_info "Installing additional development tools..."
brew install \
    gh \
    docker \
    docker-compose \
    kubectl \
    awscli

# Install essential fonts for terminal use (including Nerd Fonts for glyphs)
echo "Installing essential fonts with Nerd Font support..."

# Install Nerd Fonts via Homebrew for proper glyph support in Starship and tmux
brew tap homebrew/cask-fonts
brew install --cask font-dejavu-sans-mono-nerd-font
brew install --cask font-liberation-mono
brew install --cask font-noto-mono  
brew install --cask font-fira-code-nerd-font

echo "Essential fonts with Nerd Font support installed successfully"

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

# Install iTerm2 terminal emulator (macOS primary terminal)
echo "Installing iTerm2 terminal emulator..."
if ! command -v iterm2 &> /dev/null && [ ! -d "/Applications/iTerm.app" ]; then
    brew install --cask iterm2
    echo "iTerm2 installed successfully"
else
    echo "iTerm2 already available"
fi

# Install Cask applications (optional GUI apps)
log_info "Installing GUI applications..."
brew install --cask \
    iterm2 \
    visual-studio-code \
    docker \
    postman



# Set zsh as default shell
log_info "Setting zsh as default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)"
    log_success "Default shell changed to zsh (restart terminal to take effect)"
else
    log_info "zsh is already the default shell"
fi

# Install Oh My Zsh themes and plugins dependencies
log_info "Installing additional zsh dependencies..."
brew install powerlevel10k

log_success "macOS setup complete!"
log_info "Please restart your terminal to ensure all changes take effect"
