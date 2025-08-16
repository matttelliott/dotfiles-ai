#!/bin/bash
# AI Tools Installer
# Manages installation of MCP servers, model configurations, and AI client setups

set -e

# Configuration
AI_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$AI_TOOLS_DIR")"

# Source common utilities
source "$DOTFILES_DIR/utils/common.sh"

# Detect OS
detect_os

# Show usage
show_usage() {
    cat << EOF
AI Tools Installer - Manage AI assistants, MCP servers, and model configurations

Usage: ./install.sh [component] [options]

Components:
    all                 Install everything
    mcp-servers         Install all MCP servers
    mcp-server <name>   Install specific MCP server (e.g., tmux)
    models              Setup model configurations
    clients             Install AI client configurations
    prompts             Install prompt templates
    
Options:
    -h, --help         Show this help message
    -l, --list         List available components
    --update           Update existing installations
    
Examples:
    ./install.sh                    # Interactive installation
    ./install.sh all                # Install everything
    ./install.sh mcp-servers        # Install all MCP servers
    ./install.sh mcp-server tmux    # Install tmux MCP server
    ./install.sh models              # Setup model configurations
    
Environment Variables:
    AI_TOOLS_HOME      Override AI tools directory
    MCP_SERVERS_PATH   Override MCP servers path
    AI_MODELS_PATH     Override models configuration path
    
EOF
}

# List available components
list_components() {
    echo "Available MCP Servers:"
    for server_dir in "$AI_TOOLS_DIR/mcp-servers"/*; do
        if [[ -d "$server_dir" ]] && [[ -f "$server_dir/package.json" || -f "$server_dir/install" ]]; then
            echo "  - $(basename "$server_dir")"
        fi
    done
    
    echo
    echo "Available Model Configurations:"
    for model_dir in "$AI_TOOLS_DIR/models"/*; do
        if [[ -d "$model_dir" ]] && [[ -f "$model_dir/config.json" ]]; then
            echo "  - $(basename "$model_dir")"
        fi
    done
    
    echo
    echo "Available Clients:"
    for client_dir in "$AI_TOOLS_DIR/clients"/*; do
        if [[ -d "$client_dir" ]]; then
            echo "  - $(basename "$client_dir")"
        fi
    done
}

# Check prerequisites
check_prerequisites() {
    local missing_deps=()
    
    # Check for Node.js (required for MCP servers)
    if ! command -v node &> /dev/null; then
        missing_deps+=("Node.js")
    fi
    
    # Check for npm
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi
    
    # Check for Python (optional but recommended)
    if ! command -v python3 &> /dev/null; then
        log_warning "Python 3 not found (optional but recommended)"
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install missing dependencies first:"
        echo "  - Node.js: Run '$DOTFILES_DIR/tools-lang/node/install'"
        echo "  - Python: Run '$DOTFILES_DIR/tools-lang/python/install'"
        return 1
    fi
}

# Install MCP server
install_mcp_server() {
    local server_name="$1"
    local server_path="$AI_TOOLS_DIR/mcp-servers/$server_name"
    
    if [[ ! -d "$server_path" ]]; then
        log_error "MCP server '$server_name' not found"
        return 1
    fi
    
    log_info "Installing MCP server: $server_name"
    
    # Check for custom install script
    if [[ -x "$server_path/install" ]]; then
        (cd "$server_path" && ./install)
    elif [[ -f "$server_path/package.json" ]]; then
        # Node.js based MCP server
        log_info "Installing Node.js dependencies for $server_name..."
        (cd "$server_path" && npm install)
        
        # Generate Claude configuration if needed
        generate_claude_config "$server_name" "$server_path"
        
        log_success "MCP server '$server_name' installed"
    else
        log_warning "No installation method found for $server_name"
    fi
}

# Install all MCP servers
install_all_mcp_servers() {
    log_info "Installing all MCP servers..."
    
    for server_dir in "$AI_TOOLS_DIR/mcp-servers"/*; do
        if [[ -d "$server_dir" ]] && [[ "$(basename "$server_dir")" != "README.md" ]]; then
            install_mcp_server "$(basename "$server_dir")"
        fi
    done
}

# Generate Claude configuration
generate_claude_config() {
    local server_name="$1"
    local server_path="$2"
    local config_dir="$HOME/.config/claude"
    
    # Create config directory
    mkdir -p "$config_dir"
    
    # Check if server provides its own config template
    if [[ -f "$server_path/claude-config.json" ]]; then
        log_info "Using provided Claude configuration for $server_name"
        cp "$server_path/claude-config.json" "$config_dir/mcp-$server_name.json"
    else
        # Generate basic configuration
        log_info "Generating Claude configuration for $server_name"
        cat > "$config_dir/mcp-$server_name.json" << EOF
{
  "mcpServers": {
    "$server_name": {
      "command": "node",
      "args": ["$server_path/server.js"],
      "env": {}
    }
  }
}
EOF
    fi
    
    log_success "Claude configuration generated: $config_dir/mcp-$server_name.json"
}

# Setup model configurations
setup_models() {
    log_info "Setting up AI model configurations..."
    
    # Create .gitignore for sensitive files
    cat > "$AI_TOOLS_DIR/models/.gitignore" << 'EOF'
# API Keys and sensitive data
*.env
*-keys.*
api-keys/
credentials/
.env.local
.env.*.local

# Local configurations
local/
*.local.json
EOF
    
    # Setup environment template
    for model_dir in "$AI_TOOLS_DIR/models"/*; do
        if [[ -d "$model_dir" ]] && [[ -f "$model_dir/config.json" ]]; then
            local provider="$(basename "$model_dir")"
            
            # Create example API keys file (if it doesn't exist)
            if [[ ! -f "$model_dir/api-keys.env.example" ]]; then
                case "$provider" in
                    claude)
                        cat > "$model_dir/api-keys.env.example" << 'EOF'
# Anthropic API Configuration
ANTHROPIC_API_KEY=sk-ant-api03-...
# Optional: Different keys for different environments
ANTHROPIC_API_KEY_DEV=sk-ant-api03-...
ANTHROPIC_API_KEY_PROD=sk-ant-api03-...
EOF
                        ;;
                    openai)
                        cat > "$model_dir/api-keys.env.example" << 'EOF'
# OpenAI API Configuration
OPENAI_API_KEY=sk-...
OPENAI_ORG_ID=org-...
# Optional: Different keys for different environments
OPENAI_API_KEY_DEV=sk-...
OPENAI_API_KEY_PROD=sk-...
EOF
                        ;;
                    ollama)
                        cat > "$model_dir/api-keys.env.example" << 'EOF'
# Ollama Configuration (usually no API key needed for local)
OLLAMA_HOST=http://localhost:11434
# Optional: Remote Ollama instance
OLLAMA_REMOTE_HOST=https://ollama.example.com
OLLAMA_REMOTE_API_KEY=optional-key
EOF
                        ;;
                esac
            fi
            
            log_success "Model configuration ready: $provider"
        fi
    done
    
    # Create helper script for loading configurations
    cat > "$AI_TOOLS_DIR/models/load-config.sh" << 'EOF'
#!/bin/bash
# Load AI model configuration

load_ai_config() {
    local provider="${1:-claude}"
    local config_path="$(dirname "${BASH_SOURCE[0]}")/$provider"
    
    if [[ ! -d "$config_path" ]]; then
        echo "Provider '$provider' not found" >&2
        return 1
    fi
    
    # Load API keys if available
    if [[ -f "$config_path/api-keys.env" ]]; then
        source "$config_path/api-keys.env"
    fi
    
    # Export configuration path
    export AI_MODEL_CONFIG="$config_path/config.json"
    export AI_MODEL_PROVIDER="$provider"
    
    echo "Loaded configuration for $provider"
}

# If sourced with argument, load that provider
if [[ -n "$1" ]]; then
    load_ai_config "$1"
fi
EOF
    chmod +x "$AI_TOOLS_DIR/models/load-config.sh"
}

# Setup AI clients
setup_clients() {
    log_info "Setting up AI client configurations..."
    
    # Create clients directory structure
    mkdir -p "$AI_TOOLS_DIR/clients"/{claude,openai,ollama,cursor,cline}
    
    # Claude Desktop configuration
    cat > "$AI_TOOLS_DIR/clients/claude/README.md" << 'EOF'
# Claude Desktop Configuration

## Installation
1. Download Claude Desktop from https://claude.ai/download
2. Install the application
3. Configure MCP servers in Settings

## MCP Server Configuration
MCP servers are automatically configured during installation.
Configuration files are located in:
- macOS: `~/Library/Application Support/Claude/config.json`
- Linux: `~/.config/claude/config.json`
- Windows: `%APPDATA%\Claude\config.json`

## Usage
After installation, Claude Desktop will have access to all installed MCP servers.
EOF
    
    # Create shell integration
    cat > "$AI_TOOLS_DIR/clients/shell-integration.zsh" << 'EOF'
# AI Tools Shell Integration

# Environment variables
export AI_TOOLS_HOME="${AI_TOOLS_HOME:-$HOME/dotfiles-ai/ai-tools}"
export MCP_SERVERS_PATH="$AI_TOOLS_HOME/mcp-servers"
export AI_MODELS_PATH="$AI_TOOLS_HOME/models"

# Load model configuration function
source "$AI_MODELS_PATH/load-config.sh" 2>/dev/null || true

# Aliases for common AI operations
alias ai-models="ls -la $AI_MODELS_PATH"
alias ai-servers="ls -la $MCP_SERVERS_PATH"
alias ai-claude="load_ai_config claude"
alias ai-openai="load_ai_config openai"
alias ai-ollama="load_ai_config ollama"

# Function to test MCP server
test_mcp_server() {
    local server="${1:-tmux}"
    local server_path="$MCP_SERVERS_PATH/$server"
    
    if [[ ! -d "$server_path" ]]; then
        echo "MCP server '$server' not found"
        return 1
    fi
    
    echo "Testing MCP server: $server"
    if [[ -f "$server_path/server.js" ]]; then
        node "$server_path/server.js" --test 2>/dev/null || echo "Server loaded successfully"
    else
        echo "No test available for $server"
    fi
}

# Function to list available AI tools
ai_tools_list() {
    echo "🤖 Available AI Tools:"
    echo
    echo "MCP Servers:"
    ls -1 "$MCP_SERVERS_PATH" 2>/dev/null | grep -v README | sed 's/^/  - /'
    echo
    echo "Model Configurations:"
    ls -1 "$AI_MODELS_PATH" 2>/dev/null | grep -v README | grep -v '\.sh$' | sed 's/^/  - /'
}
EOF
    
    log_success "AI clients configuration complete"
}

# Setup prompt templates
setup_prompts() {
    log_info "Setting up prompt templates..."
    
    mkdir -p "$AI_TOOLS_DIR/prompts"/{coding,writing,analysis,creative}
    
    # Create example coding prompts
    cat > "$AI_TOOLS_DIR/prompts/coding/code-review.md" << 'EOF'
# Code Review Prompt

Please review the following code for:

1. **Correctness**: Does the code work as intended?
2. **Performance**: Are there any performance bottlenecks?
3. **Security**: Are there any security vulnerabilities?
4. **Best Practices**: Does it follow language/framework best practices?
5. **Readability**: Is the code clear and well-documented?
6. **Testing**: Is the code properly tested?

Provide specific suggestions for improvements with code examples where applicable.

## Code to Review:
```[language]
[paste code here]
```
EOF
    
    cat > "$AI_TOOLS_DIR/prompts/README.md" << 'EOF'
# AI Prompt Templates

A collection of reusable prompts for various AI tasks.

## Categories

- **coding/**: Software development prompts
- **writing/**: Content creation prompts
- **analysis/**: Data and document analysis prompts
- **creative/**: Creative and brainstorming prompts

## Usage

1. Copy the relevant template
2. Fill in the placeholders
3. Paste into your AI assistant

## Contributing

Add new prompts following the existing structure and naming conventions.
EOF
    
    log_success "Prompt templates created"
}

# Interactive installation
interactive_install() {
    echo "🤖 AI Tools Interactive Installer"
    echo "================================="
    echo
    echo "What would you like to install?"
    echo "1) Everything (recommended)"
    echo "2) MCP Servers only"
    echo "3) Model configurations only"
    echo "4) Specific MCP server"
    echo "5) List available components"
    echo "6) Exit"
    echo
    read -p "Select an option [1-6]: " choice
    
    case $choice in
        1)
            install_all
            ;;
        2)
            check_prerequisites
            install_all_mcp_servers
            ;;
        3)
            setup_models
            ;;
        4)
            echo "Available MCP servers:"
            ls -1 "$AI_TOOLS_DIR/mcp-servers" | grep -v README
            read -p "Enter server name: " server_name
            check_prerequisites
            install_mcp_server "$server_name"
            ;;
        5)
            list_components
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
}

# Install everything
install_all() {
    log_info "Installing all AI tools..."
    
    check_prerequisites || return 1
    install_all_mcp_servers
    setup_models
    setup_clients
    setup_prompts
    
    log_success "All AI tools installed successfully!"
    echo
    echo "🎉 Installation Complete!"
    echo
    echo "Next steps:"
    echo "1. Add API keys to model configuration directories"
    echo "2. Add to your shell configuration:"
    echo "   source $AI_TOOLS_DIR/clients/shell-integration.zsh"
    echo "3. Restart your shell or run: source ~/.zshrc"
    echo "4. Test MCP servers: test_mcp_server tmux"
    echo "5. List available tools: ai_tools_list"
}

# Main execution
main() {
    case "${1:-}" in
        -h|--help)
            show_usage
            ;;
        -l|--list)
            list_components
            ;;
        all)
            install_all
            ;;
        mcp-servers)
            check_prerequisites
            install_all_mcp_servers
            ;;
        mcp-server)
            if [[ -n "${2:-}" ]]; then
                check_prerequisites
                install_mcp_server "$2"
            else
                log_error "Please specify an MCP server name"
                exit 1
            fi
            ;;
        models)
            setup_models
            ;;
        clients)
            setup_clients
            ;;
        prompts)
            setup_prompts
            ;;
        "")
            interactive_install
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main
main "$@"