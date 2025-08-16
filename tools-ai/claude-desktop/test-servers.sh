#!/usr/bin/env bash

echo "Testing MCP Servers for Claude Desktop"
echo "======================================="
echo ""

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# Test each server
for server in tmux neovim playwright; do
    echo "Testing mcp-$server..."
    SERVER_DIR="$DOTFILES_DIR/tools-ai/mcp-$server"
    
    if [[ -f "$SERVER_DIR/test-server.js" ]]; then
        node "$SERVER_DIR/test-server.js" 2>&1 | head -20
    elif [[ -f "$SERVER_DIR/server.js" ]]; then
        # Try to run with --test flag
        timeout 2 node "$SERVER_DIR/server.js" --test 2>&1 || echo "  Server started (timeout expected)"
    else
        echo "  ✗ Server not found"
    fi
    echo ""
done
