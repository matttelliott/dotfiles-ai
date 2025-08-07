#!/bin/bash
# lazygit setup script - simple terminal UI for git

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

install_lazygit() {
    log_info "Installing lazygit..."
    
    if command -v lazygit &> /dev/null; then
        log_info "lazygit is already installed: $(lazygit --version | head -n1)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install lazygit
            else
                log_warning "Homebrew not found, installing from binary..."
                install_from_github
            fi
            ;;
        debian)
            install_from_github
            ;;
        linux)
            install_from_github
            ;;
    esac
    
    log_success "lazygit installed successfully"
}

install_from_github() {
    log_info "Installing lazygit from GitHub releases..."
    
    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            ARCH_STRING="x86_64"
            ;;
        aarch64|arm64)
            ARCH_STRING="arm64"
            ;;
        armv7l)
            ARCH_STRING="armv6"
            ;;
        *)
            log_warning "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    # Detect OS for download
    if [[ "$PLATFORM" == "macos" ]]; then
        OS_STRING="Darwin"
    else
        OS_STRING="Linux"
    fi
    
    # Get latest version
    LATEST_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    # Download and install
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LATEST_VERSION}/lazygit_${LATEST_VERSION}_${OS_STRING}_${ARCH_STRING}.tar.gz"
    log_info "Downloading from: $DOWNLOAD_URL"
    
    curl -L -o lazygit.tar.gz "$DOWNLOAD_URL"
    tar xzf lazygit.tar.gz
    
    # Install the binary
    if [[ -f "lazygit" ]]; then
        sudo mv lazygit /usr/local/bin/lazygit
        sudo chmod +x /usr/local/bin/lazygit
        log_success "lazygit installed to /usr/local/bin/lazygit"
    else
        log_warning "Could not find lazygit binary in archive"
        exit 1
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

setup_lazygit_config() {
    log_info "Setting up lazygit configuration..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # Create config directory
    mkdir -p "$HOME/.config/lazygit"
    
    # Create lazygit config
    if [[ -f "$SCRIPT_DIR/config.yml" ]]; then
        ln -sf "$SCRIPT_DIR/config.yml" "$HOME/.config/lazygit/config.yml"
        log_success "lazygit configuration linked"
    else
        # Create a sensible default config
        cat > "$HOME/.config/lazygit/config.yml" << 'EOF'
# lazygit configuration
gui:
  # Theme
  theme:
    activeBorderColor:
      - green
      - bold
    inactiveBorderColor:
      - white
    selectedLineBgColor:
      - reverse
    selectedRangeBgColor:
      - reverse
  
  # Layout
  showFileTree: true
  showCommandLog: false
  showBottomLine: true
  showPanelJumps: true
  
  # UI
  scrollHeight: 2
  scrollPastBottom: true
  mouseEvents: true
  skipDiscardChangeWarning: false
  skipStashWarning: false
  sidePanelWidth: 0.3333
  expandFocusedSidePanel: false
  mainPanelSplitMode: flexible
  
  # Time format
  timeFormat: "02 Jan 06"
  shortTimeFormat: "3:04PM"

git:
  # Pull/Push/Fetch
  autoFetch: true
  autoRefresh: true
  branchLogCmd: "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  allBranchesLogCmd: "git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  overrideGpg: false
  disableForcePushing: false
  parseEmoji: true
  
  # Commit
  signOff: false
  
  # Merging
  merging:
    manualCommit: false
    args: ""

os:
  # Editor
  edit: "nvim"
  editAtLine: "nvim +{{line}} {{filename}}"
  editAtLineAndWait: "nvim +{{line}} {{filename}}"
  openDirInEditor: "nvim {{dir}}"
  
  # Opening files
  open: "open {{filename}}"

keybinding:
  universal:
    quit: 'q'
    quit-alt1: '<c-c>'
    return: '<esc>'
    quitWithoutChangingDirectory: 'Q'
    togglePanel: '<tab>'
    prevItem: '<up>'
    nextItem: '<down>'
    prevItem-alt: 'k'
    nextItem-alt: 'j'
    prevPage: ','
    nextPage: '.'
    scrollLeft: 'H'
    scrollRight: 'L'
    gotoTop: '<'
    gotoBottom: '>'
    toggleRangeSelect: 'v'
    rangeSelectDown: '<s-down>'
    rangeSelectUp: '<s-up>'
    prevBlock: '<left>'
    nextBlock: '<right>'
    prevBlock-alt: 'h'
    nextBlock-alt: 'l'
    nextBlock-alt2: '<tab>'
    prevBlock-alt2: '<backtab>'
    jumpToBlock: ['1', '2', '3', '4', '5']
    nextMatch: 'n'
    prevMatch: 'N'
    startSearch: '/'
    optionMenu: 'x'
    optionMenu-alt1: '?'
    select: '<space>'
    goInto: '<enter>'
    confirm: '<enter>'
    confirmInEditor: '<a-enter>'
    remove: 'd'
    new: 'n'
    edit: 'e'
    openFile: 'o'
    scrollUpMain: '<pgup>'
    scrollDownMain: '<pgdown>'
    scrollUpMain-alt1: 'K'
    scrollDownMain-alt1: 'J'
    scrollUpMain-alt2: '<c-u>'
    scrollDownMain-alt2: '<c-d>'
    executeCustomCommand: ':'
    createRebaseOptionsMenu: 'm'
    
    # Push/pull/fetch
    pushFiles: 'P'
    pullFiles: 'p'
    
    # Refresh
    refresh: 'R'
    
    # Copy
    copyToClipboard: '<c-o>'
    
  files:
    commitChanges: 'c'
    commitChangesWithEditor: 'C'
    amendLastCommit: 'A'
    commitChangesWithoutHook: 'w'
    ignoreFile: 'i'
    refreshFiles: 'r'
    stashAllChanges: 's'
    viewStashOptions: 'S'
    toggleStagedAll: 'a'
    viewResetOptions: 'D'
    fetch: 'f'
    toggleTreeView: '`'
    openMergeTool: 'M'
    openStatusFilter: '<c-b>'
EOF
        log_success "Created default lazygit configuration"
    fi
    
    setup_aliases
}

setup_aliases() {
    log_info "Setting up lazygit aliases..."
    
    local aliases='
# lazygit aliases
alias lg="lazygit"
alias lzg="lazygit"
alias lgit="lazygit"

# Git + lazygit workflow
alias gs="git status"
alias gst="git status"
alias gss="git status -s"
'
    
    # Add to zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "# lazygit aliases" "$HOME/.zshrc"; then
            echo "$aliases" >> "$HOME/.zshrc"
            log_success "Added lazygit aliases to .zshrc"
        else
            log_info "lazygit aliases already configured in .zshrc"
        fi
    fi
    
    # Add to bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "# lazygit aliases" "$HOME/.bashrc"; then
            echo "$aliases" >> "$HOME/.bashrc"
            log_success "Added lazygit aliases to .bashrc"
        else
            log_info "lazygit aliases already configured in .bashrc"
        fi
    fi
}

# Main installation
main() {
    log_info "Setting up lazygit..."
    
    install_lazygit
    setup_lazygit_config
    
    log_success "lazygit setup complete!"
    echo
    echo "lazygit - Simple terminal UI for git commands"
    echo
    echo "Usage:"
    echo "  lazygit      - Launch in current repository"
    echo "  lg           - Short alias"
    echo
    echo "Key bindings:"
    echo "  Space        - Stage/unstage file"
    echo "  c            - Commit changes"
    echo "  p            - Pull"
    echo "  P            - Push"
    echo "  s            - Stash changes"
    echo "  d            - Delete/discard"
    echo "  e            - Edit file"
    echo "  /            - Search"
    echo "  q            - Quit"
    echo
    echo "Configured to use nvim as editor"
}

main "$@"