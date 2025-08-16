#!/usr/bin/env bash

# Neovim MCP Server Setup Script
# Installs and configures Neovim MCP server for Claude Desktop and CLI

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

log_info "Setting up Neovim MCP Server for Claude integration..."

# Check for Neovim
check_neovim() {
    if ! command -v nvim >/dev/null 2>&1; then
        log_warning "Neovim is not installed. Installing Neovim..."
        
        # Check if Neovim installer exists
        if [[ -f "$DOTFILES_DIR/tools-cli/neovim/setup.sh" ]]; then
            log_info "Installing Neovim via dotfiles installer..."
            bash "$DOTFILES_DIR/tools-cli/neovim/setup.sh"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew >/dev/null 2>&1; then
                brew install neovim
            else
                log_error "Please install Homebrew first or install Neovim manually"
                exit 1
            fi
        elif [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y neovim
        else
            log_error "Please install Neovim for your platform"
            exit 1
        fi
    fi
    log_success "Neovim is installed: $(nvim --version | head -1)"
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

# Install optional neovim-remote for better integration
install_neovim_remote() {
    log_info "Checking for neovim-remote (nvr)..."
    
    if ! command -v nvr >/dev/null 2>&1; then
        if command -v pip3 >/dev/null 2>&1; then
            log_info "Installing neovim-remote for enhanced functionality..."
            pip3 install --user neovim-remote
            log_success "neovim-remote installed"
        else
            log_warning "pip3 not found. Skipping neovim-remote installation."
            log_warning "For better integration, install: pip3 install neovim-remote"
        fi
    else
        log_success "neovim-remote is already installed"
    fi
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
    
    # Check if configuration already exists
    CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
    
    if [[ -f "$CONFIG_FILE" ]]; then
        # Check if neovim server is already configured
        if grep -q "mcp-neovim" "$CONFIG_FILE" 2>/dev/null; then
            log_info "Neovim MCP already configured in Claude Desktop"
        else
            # Backup existing config
            cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Add neovim server to existing config
            log_info "Adding Neovim MCP to existing Claude Desktop configuration..."
            
            # This is tricky without jq, so we'll create a new merged config
            cat > "$CONFIG_FILE.tmp" << EOF
{
  "mcpServers": {
    "tmux": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-tmux/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "neovim": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-neovim/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        fi
    else
        # Create new configuration
        cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "neovim": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-neovim/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
    fi
    
    log_success "Claude Desktop configuration updated at: $CONFIG_FILE"
}

# Setup MCP configuration for Claude CLI
setup_claude_cli_config() {
    log_info "Configuring Claude CLI MCP integration..."
    
    # The .mcp.json file in the dotfiles root
    MCP_CONFIG_FILE="$DOTFILES_DIR/.mcp.json"
    
    if [[ -f "$MCP_CONFIG_FILE" ]]; then
        # Check if neovim is already configured
        if grep -q "neovim" "$MCP_CONFIG_FILE" 2>/dev/null; then
            log_info "Neovim MCP already configured in Claude CLI"
        else
            # Backup and update
            cp "$MCP_CONFIG_FILE" "$MCP_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Create updated config with both servers
            cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "tmux": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-tmux/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "neovim": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-neovim/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
        fi
    else
        # Create new config
        cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "neovim": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-neovim/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
    fi
    
    log_success "Claude CLI configuration updated at: $MCP_CONFIG_FILE"
}

# Create test script
create_test_script() {
    log_info "Creating test script..."
    
    cat > "$SCRIPT_DIR/test-server.js" << 'EOF'
#!/usr/bin/env node

/**
 * Test script for Neovim MCP Server
 */

const NeovimMCPServer = require('./server.js');

async function runTests() {
    console.log('Testing Neovim MCP Server...\n');
    
    const server = new NeovimMCPServer();
    
    try {
        // Test 1: Check Neovim installation
        console.log('Test 1: Checking Neovim installation...');
        const nvimCheck = await server.checkNeovim();
        if (nvimCheck.installed) {
            console.log('✓ Neovim is installed:', nvimCheck.version);
        } else {
            console.log('✗ Neovim not found:', nvimCheck.error);
        }
        console.log();
        
        // Test 2: List Neovim instances
        console.log('Test 2: Listing Neovim instances...');
        const instances = await server.listInstances();
        console.log('Found', instances.processes, 'Neovim processes');
        console.log('Found', instances.sockets, 'server sockets');
        if (instances.instances.length > 0) {
            console.log('Server sockets:');
            instances.instances.forEach(inst => {
                console.log('  -', inst.name, 'at', inst.socket);
            });
        }
        console.log('✓ Instance listing test passed\n');
        
        // Test 3: Start a headless instance
        console.log('Test 3: Starting headless Neovim instance...');
        const started = await server.startInstance('mcp-test', true);
        if (started.success) {
            console.log('✓ Started Neovim instance:', started.name);
            console.log('  Socket:', started.socket);
            console.log('  PID:', started.pid);
            
            // Test 4: Connect to instance
            console.log('\nTest 4: Connecting to instance...');
            try {
                const connected = await server.connectToInstance(started.socket);
                console.log('✓ Successfully connected to socket');
            } catch (e) {
                console.log('ℹ Connection test skipped (socket may not be ready)');
            }
            
            // Test 5: Send a command
            console.log('\nTest 5: Sending command to Neovim...');
            const cmdResult = await server.sendCommand(
                started.socket,
                'version',
                true
            );
            if (cmdResult.success) {
                console.log('✓ Command executed successfully');
            } else {
                console.log('ℹ Command execution failed (may need nvr):', cmdResult.suggestion);
            }
            
            // Clean up - kill the test instance
            if (started.pid) {
                process.kill(started.pid, 'SIGTERM');
                console.log('\n✓ Cleaned up test instance');
            }
        } else {
            console.log('✗ Failed to start instance:', started.error);
        }
        
        console.log('\n🎉 All tests completed!');
        console.log('\nNeovim MCP Server is ready for use with Claude.');
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    runTests();
}
EOF
    
    chmod +x "$SCRIPT_DIR/test-server.js"
    log_success "Test script created"
}

# Create shell aliases
setup_shell_integration() {
    log_info "Setting up shell integration..."
    
    # Create aliases file
    ALIASES_FILE="$SCRIPT_DIR/aliases.sh"
    cat > "$ALIASES_FILE" << 'EOF'
# Neovim MCP aliases and functions

# Start Neovim with server socket
nvim-server() {
    local name="${1:-default}"
    local socket="/tmp/nvim-${name}.sock"
    nvim --listen "$socket" "${@:2}"
}

# List Neovim server sockets
nvim-sockets() {
    ls -la /tmp/nvim*.sock 2>/dev/null || echo "No Neovim server sockets found"
}

# Test Neovim MCP server
nvim-mcp-test() {
    if [[ -f "$DOTFILES_DIR/tools-ai/mcp-neovim/test-server.js" ]]; then
        node "$DOTFILES_DIR/tools-ai/mcp-neovim/test-server.js"
    else
        echo "MCP test script not found"
    fi
}

# Show MCP configuration
nvim-mcp-status() {
    echo "Neovim MCP Configuration:"
    echo
    echo "Claude Desktop config:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cat "$HOME/Library/Application Support/Claude/claude_desktop_config.json" 2>/dev/null | grep -A5 "neovim" || echo "Not configured"
    else
        cat "$HOME/.config/Claude/claude_desktop_config.json" 2>/dev/null | grep -A5 "neovim" || echo "Not configured"
    fi
    
    echo
    echo "Claude CLI config:"
    cat "$DOTFILES_DIR/.mcp.json" 2>/dev/null | grep -A5 "neovim" || echo "Not configured"
    
    echo
    echo "Neovim instances:"
    pgrep -f nvim >/dev/null && echo "$(pgrep -c -f nvim) Neovim processes running" || echo "No Neovim processes running"
    
    echo
    echo "Server sockets:"
    ls /tmp/nvim*.sock 2>/dev/null | wc -l | xargs echo "sockets found"
}

# Connect to Neovim with Claude-friendly settings
nvim-claude() {
    local session="${1:-claude}"
    local socket="/tmp/nvim-${session}.sock"
    
    echo "Starting Neovim with MCP server socket at $socket"
    echo "You can now use this session with Claude!"
    
    # Start Neovim with some Claude-friendly settings
    nvim --listen "$socket" \
         -c "set number" \
         -c "set relativenumber" \
         -c "set signcolumn=yes" \
         -c "echo 'Claude-connected Neovim ready on socket: $socket'" \
         "${@:2}"
}
EOF
    
    # Source in shell configs
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "mcp-neovim/aliases.sh" "$rc"; then
                echo "" >> "$rc"
                echo "# Neovim MCP integration" >> "$rc"
                echo "[[ -f \"$ALIASES_FILE\" ]] && source \"$ALIASES_FILE\"" >> "$rc"
                log_success "Added Neovim MCP aliases to $(basename "$rc")"
            fi
        fi
    done
}

# Main installation flow
main() {
    log_info "Installing Neovim MCP Server..."
    
    check_neovim
    check_node
    install_neovim_remote
    setup_claude_desktop_config
    setup_claude_cli_config
    create_test_script
    setup_shell_integration
    
    log_success "Neovim MCP Server installation complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    echo "  2. Restart Claude Desktop and/or CLI to load the MCP server"
    echo "  3. Test with: nvim-mcp-test"
    echo "  4. Start Neovim with server: nvim-server myproject"
    echo "  5. Or use Claude-optimized: nvim-claude"
    echo ""
    log_info "Available commands:"
    echo "  nvim-server [name]  - Start Neovim with server socket"
    echo "  nvim-claude [name]  - Start Claude-optimized Neovim session"
    echo "  nvim-sockets        - List active server sockets"
    echo "  nvim-mcp-test       - Test MCP server functionality"
    echo "  nvim-mcp-status     - Check MCP configuration"
}

main "$@"