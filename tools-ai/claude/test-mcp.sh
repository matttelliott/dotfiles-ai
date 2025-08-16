#!/bin/bash

echo "Testing MCP Servers for Claude Code"
echo "===================================="
echo ""

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# Test each MCP server
for server in tmux neovim playwright; do
    echo "Testing mcp-$server..."
    server_dir="$DOTFILES_DIR/tools-ai/mcp-$server"
    
    if [[ -f "$server_dir/test-server.js" ]]; then
        node "$server_dir/test-server.js" 2>&1 | head -10
    elif [[ -f "$server_dir/server.js" ]]; then
        timeout 1 node "$server_dir/server.js" --test 2>&1 || echo "  Server started (timeout expected)"
    else
        echo "  ✗ Server not found"
    fi
    echo ""
done

echo "Claude Code Configuration:"
echo "-------------------------"
if [[ -f ~/.claude/settings.json ]]; then
    echo "✓ User settings: ~/.claude/settings.json"
    echo "  MCP servers configured:"
    jq -r '.mcpServers | keys[]' ~/.claude/settings.json 2>/dev/null | sed 's/^/    - /'
else
    echo "✗ User settings not found"
fi
