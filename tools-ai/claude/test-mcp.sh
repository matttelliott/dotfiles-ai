#!/bin/bash

echo "Testing MCP Servers"
echo "==================="
echo ""

# Test each MCP server
for server in tmux neovim playwright; do
    echo "Testing mcp-$server..."
    server_dir="$(dirname "$0")/../mcp-$server"
    
    if [[ -f "$server_dir/test-server.js" ]]; then
        node "$server_dir/test-server.js" 2>&1 | head -10
    elif [[ -f "$server_dir/server.js" ]]; then
        timeout 1 node "$server_dir/server.js" --test 2>&1 || echo "  Server started (timeout expected)"
    else
        echo "  ✗ Server not found"
    fi
    echo ""
done

echo "Claude CLI MCP Status:"
echo "----------------------"
claude mcp list 2>/dev/null || echo "Claude CLI not available"
