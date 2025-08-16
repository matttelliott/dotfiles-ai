#!/usr/bin/env bash

echo "Claude Desktop MCP Configuration Diagnostic"
echo "==========================================="
echo ""

# Check config file
CONFIG_DIR=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/Claude"
else
    CONFIG_DIR="$HOME/.config/claude"
fi

CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

echo "Configuration location: $CONFIG_FILE"
if [[ -f "$CONFIG_FILE" ]]; then
    echo "✓ Configuration file exists"
    if [[ -L "$CONFIG_FILE" ]]; then
        echo "✓ Configuration is symlinked (managed by stow)"
        echo "  Points to: $(readlink "$CONFIG_FILE")"
    else
        echo "ℹ Configuration is a regular file (not managed by stow)"
    fi
else
    echo "✗ Configuration file not found"
fi

echo ""
echo "MCP Servers Status:"
echo "-------------------"

# Check each MCP server
for server in tmux neovim playwright; do
    SERVER_PATH="$DOTFILES_DIR/tools-ai/mcp-$server/server.js"
    echo -n "$server: "
    
    if [[ -f "$SERVER_PATH" ]]; then
        echo -n "✓ Server exists"
        
        # Check if node_modules exist
        if [[ -d "$(dirname "$SERVER_PATH")/node_modules" ]]; then
            echo " ✓ Dependencies installed"
        else
            echo " ✗ Dependencies not installed"
        fi
    else
        echo "✗ Server not found at $SERVER_PATH"
    fi
done

echo ""
echo "Node.js Status:"
echo "---------------"
if command -v node >/dev/null 2>&1; then
    echo "✓ Node.js installed: $(node --version)"
else
    echo "✗ Node.js not found"
fi

if command -v npm >/dev/null 2>&1; then
    echo "✓ npm installed: $(npm --version)"
else
    echo "✗ npm not found"
fi

echo ""
echo "Current Configuration:"
echo "----------------------"
if [[ -f "$CONFIG_FILE" ]]; then
    echo "Content of $CONFIG_FILE:"
    cat "$CONFIG_FILE" | python3 -m json.tool 2>/dev/null || cat "$CONFIG_FILE"
fi
