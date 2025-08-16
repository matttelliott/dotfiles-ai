#!/bin/bash
# Comprehensive AI tools installation script
# Installs all available AI and MCP tools with progress tracking

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Track installation status
TOTAL_TOOLS=0
INSTALLED_TOOLS=()
FAILED_TOOLS=()

# Install a tool and track status
install_tool() {
    local category="$1"
    local tool="$2"
    local install_path="$category/$tool/install"
    
    ((TOTAL_TOOLS++))
    
    if [[ -f "$install_path" ]]; then
        log_info "[$TOTAL_TOOLS] Installing $tool..."
        if bash "$install_path" > /dev/null 2>&1; then
            INSTALLED_TOOLS+=("$tool")
            log_success "$tool installed"
        else
            FAILED_TOOLS+=("$tool")
            log_error "Failed to install $tool"
        fi
    else
        FAILED_TOOLS+=("$tool (install script not found)")
        log_warning "Install script not found for $tool"
    fi
}

main() {
    log_info "Starting comprehensive AI tools installation..."
    echo
    log_info "This will install all available AI and MCP tools:"
    echo
    
    # List all tools to be installed
    echo "MCP Servers:"
    echo "  • mcp-tmux - Tmux integration for Claude Desktop/CLI"
    echo "  • mcp-neovim - Neovim integration for Claude Desktop/CLI"
    echo "  • mcp-playwright - Browser automation via Playwright for Claude Desktop/CLI"
    echo
    
    echo "AI Model Configurations:"
    echo "  • model-configs - Centralized AI model configuration management"
    echo
    
    echo "Future Tools (Planned):"
    echo "  • mcp-filesystem - File system access for Claude"
    echo "  • mcp-web - Web browsing capabilities"
    echo "  • mcp-database - Database interaction"
    echo "  • prompt-library - Curated prompt templates"
    echo "  • ai-clients - Various AI client configurations"
    echo
    
    read -p "Do you want to proceed with installation? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
    
    # Start installation
    log_info "Installing AI tools..."
    echo
    
    # MCP Servers
    install_tool "tools-ai" "mcp-tmux"
    install_tool "tools-ai" "mcp-neovim"
    install_tool "tools-ai" "mcp-playwright"
    
    # Model Configurations
    install_tool "tools-ai" "model-configs"
    
    # Summary
    echo
    echo "========================================="
    echo "         Installation Summary"
    echo "========================================="
    
    if [[ ${#INSTALLED_TOOLS[@]} -gt 0 ]]; then
        log_success "Successfully installed (${#INSTALLED_TOOLS[@]} tools):"
        for tool in "${INSTALLED_TOOLS[@]}"; do
            echo "  ✓ $tool"
        done
    fi
    
    if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
        echo
        log_error "Failed to install (${#FAILED_TOOLS[@]} tools):"
        for tool in "${FAILED_TOOLS[@]}"; do
            echo "  ✗ $tool"
        done
    fi
    
    echo
    echo "========================================="
    echo
    
    # Next steps
    log_info "Next steps:"
    echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    echo "  2. Restart Claude Desktop and/or CLI to load MCP servers"
    echo "  3. Test MCP integration: tmux-mcp-test"
    echo "  4. Check AI model configs: ai-models-status"
    echo
    
    if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
        log_warning "Some tools failed to install. Check individual setup scripts for details."
        exit 1
    else
        log_success "All AI tools installed successfully!"
    fi
}

main "$@"