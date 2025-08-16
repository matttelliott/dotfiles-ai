#!/usr/bin/env bash

# Tmux MCP Server Setup Script
# Installs and configures tmux MCP server for Claude Desktop and CLI

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common utilities
if [[ -f "$DOTFILES_DIR/utils/common.sh" ]]; then
    source "$DOTFILES_DIR/utils/common.sh"
else
    # Fallback logging functions
    log_info() { echo "[INFO] $*"; }
    log_success() { echo "[SUCCESS] $*"; }
    log_warning() { echo "[WARNING] $*"; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

log_info "Setting up Tmux MCP Server for Claude integration..."

# Check for tmux
check_tmux() {
    if ! command -v tmux >/dev/null 2>&1; then
        log_warning "tmux is not installed. Installing tmux..."
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew >/dev/null 2>&1; then
                brew install tmux
            else
                log_error "Please install Homebrew first or install tmux manually"
                exit 1
            fi
        elif [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y tmux
        else
            log_error "Please install tmux for your platform"
            exit 1
        fi
    fi
    log_success "tmux is installed: $(tmux -V)"
}

# Check for Node.js
check_node() {
    if ! command -v node >/dev/null 2>&1; then
        log_warning "Node.js is not installed. Please install Node.js first."
        log_info "You can install it via: $DOTFILES_DIR/tools-lang/node/setup.sh"
        exit 1
    fi
    
    # Check Node.js version (requires >= 14)
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $NODE_VERSION -lt 14 ]]; then
        log_error "Node.js version 14 or higher required. Current: $(node --version)"
        exit 1
    fi
    
    log_success "Node.js is installed: $(node --version)"
}

# Setup MCP configuration for Claude Desktop
setup_claude_desktop_config() {
    log_info "Configuring Claude Desktop MCP integration..."
    
    # Determine Claude Desktop config directory based on platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
    else
        # Linux
        CLAUDE_CONFIG_DIR="$HOME/.config/Claude"
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$CLAUDE_CONFIG_DIR"
    
    # Create or update claude_desktop_config.json
    CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
    
    # Create the MCP configuration
    cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "tmux": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-tmux/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
    
    log_success "Claude Desktop configuration created at: $CONFIG_FILE"
}

# Setup MCP configuration for Claude CLI
setup_claude_cli_config() {
    log_info "Configuring Claude CLI MCP integration..."
    
    # The .mcp.json file in the dotfiles root
    MCP_CONFIG_FILE="$DOTFILES_DIR/.mcp.json"
    
    # Check if file exists and has content
    if [[ -f "$MCP_CONFIG_FILE" ]]; then
        log_info "MCP configuration already exists at: $MCP_CONFIG_FILE"
    else
        # Create the MCP configuration for CLI
        cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "tmux": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-tmux/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
        log_success "Claude CLI configuration created at: $MCP_CONFIG_FILE"
    fi
}

# Install the MCP server files if they don't exist
install_mcp_server() {
    log_info "Setting up MCP server files..."
    
    # Check if the server already exists
    if [[ -f "$DOTFILES_DIR/tools-ai/mcp-tmux/server.js" ]]; then
        log_info "MCP server files already exist"
        
        # Make sure it's executable
        chmod +x "$DOTFILES_DIR/tools-ai/mcp-tmux/server.js"
        
        # Install Node dependencies if package.json exists
        if [[ -f "$DOTFILES_DIR/tools-ai/mcp-tmux/package.json" ]]; then
            log_info "Installing Node.js dependencies..."
            cd "$DOTFILES_DIR/tools-ai/mcp-tmux"
            if command -v npm >/dev/null 2>&1; then
                npm install
            fi
        fi
    else
        log_error "MCP server files not found. Please ensure tools-ai/mcp-tmux is properly set up"
        exit 1
    fi
    
    log_success "MCP server is ready"
}

# Add shell aliases and functions
setup_shell_integration() {
    log_info "Setting up shell integration..."
    
    # Create aliases file if it doesn't exist
    ALIASES_FILE="$SCRIPT_DIR/aliases.sh"
    cat > "$ALIASES_FILE" << 'EOF'
# Tmux MCP aliases and functions

# Quick access to tmux sessions
alias tmux-ls="tmux list-sessions -F '#{session_name}: #{session_windows} windows'"
alias tmux-panes="tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} - #{pane_current_command}'"

# MCP server management
tmux-mcp-test() {
    if [[ -f "$DOTFILES_DIR/ai-tools/mcp-servers/tmux/test-server.js" ]]; then
        node "$DOTFILES_DIR/ai-tools/mcp-servers/tmux/test-server.js"
    else
        echo "MCP test script not found"
    fi
}

tmux-mcp-status() {
    echo "Claude Desktop config:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cat "$HOME/Library/Application Support/Claude/claude_desktop_config.json" 2>/dev/null || echo "Not configured"
    else
        cat "$HOME/.config/Claude/claude_desktop_config.json" 2>/dev/null || echo "Not configured"
    fi
    
    echo -e "\nClaude CLI config:"
    cat "$DOTFILES_DIR/.mcp.json" 2>/dev/null || echo "Not configured"
    
    echo -e "\nTmux sessions:"
    tmux list-sessions 2>/dev/null || echo "No tmux sessions running"
}

# Create a new tmux session optimized for Claude
tmux-claude() {
    local session_name="${1:-claude}"
    tmux new-session -d -s "$session_name" -n "main" 2>/dev/null || tmux attach -t "$session_name"
    tmux send-keys -t "$session_name:main" "# Claude-connected tmux session ready" C-m
    tmux attach -t "$session_name"
}
EOF
    
    # Source in shell configs
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "tmux-mcp/aliases.sh" "$rc"; then
                echo "" >> "$rc"
                echo "# Tmux MCP integration" >> "$rc"
                echo "[[ -f \"$ALIASES_FILE\" ]] && source \"$ALIASES_FILE\"" >> "$rc"
                log_success "Added tmux MCP aliases to $(basename "$rc")"
            fi
        fi
    done
}

# Create a README for the tool
create_documentation() {
    cat > "$SCRIPT_DIR/README.md" << 'EOF'
# Tmux MCP Server

This module provides Model Context Protocol (MCP) integration between tmux and Claude Desktop/CLI, allowing Claude to interact with tmux sessions, windows, and panes.

## Features

- **Session Management**: Create, list, attach, and kill tmux sessions
- **Window Control**: Create, rename, and navigate windows
- **Pane Operations**: Split, navigate, resize, and read pane contents
- **Command Execution**: Send commands to specific panes
- **Content Reading**: Capture and read pane output

## Installation

```bash
./tools-cli/tmux-mcp/setup.sh
```

## Configuration

The setup script configures MCP for both:

1. **Claude Desktop**: Configuration at `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `~/.config/Claude/claude_desktop_config.json` (Linux)
2. **Claude CLI**: Configuration at `.mcp.json` in the dotfiles root

## Usage

### Shell Commands

After installation, these commands are available:

- `tmux-ls` - List all tmux sessions
- `tmux-panes` - List all panes across all sessions
- `tmux-mcp-test` - Test the MCP server functionality
- `tmux-mcp-status` - Check MCP configuration status
- `tmux-claude [name]` - Create a Claude-optimized tmux session

### In Claude

Once configured, you can ask Claude to:

- "Show me what's in my tmux sessions"
- "Create a new tmux session called 'dev'"
- "Send a command to the main window"
- "Read the output from pane 0"
- "Split the current window horizontally"

## Architecture

The MCP server (`tools-ai/mcp-tmux/server.js`) provides a JSON-RPC interface that Claude uses to interact with tmux. It translates Claude's requests into tmux commands and returns structured responses.

## Troubleshooting

1. **Check installation**: Run `tmux-mcp-status` to verify configuration
2. **Test server**: Run `tmux-mcp-test` to test basic functionality
3. **Restart Claude**: After installation, restart Claude Desktop or CLI
4. **Check logs**: Claude's developer console shows MCP communication

## Dependencies

- tmux (installed automatically if missing)
- Node.js >= 14 (must be installed separately)
EOF
    
    log_success "Documentation created at $SCRIPT_DIR/README.md"
}

# Main installation flow
main() {
    log_info "Installing Tmux MCP Server..."
    
    check_tmux
    check_node
    install_mcp_server
    setup_claude_desktop_config
    setup_claude_cli_config
    setup_shell_integration
    create_documentation
    
    log_success "Tmux MCP Server installation complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    echo "  2. Restart Claude Desktop and/or CLI to load the MCP server"
    echo "  3. Test with: tmux-mcp-test"
    echo "  4. Check status with: tmux-mcp-status"
    echo ""
    log_info "You can now use tmux commands directly in Claude!"
}

main "$@"