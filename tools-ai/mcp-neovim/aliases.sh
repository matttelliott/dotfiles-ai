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
