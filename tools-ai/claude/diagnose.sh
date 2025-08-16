#!/bin/bash

echo "Claude Tools Diagnostic"
echo "======================="
echo ""

# Check Node.js
echo "Node.js:"
if command -v node &>/dev/null; then
    echo "  ✓ $(node --version)"
else
    echo "  ✗ Not installed"
fi

# Check Claude CLI
echo ""
echo "Claude CLI:"
if command -v claude &>/dev/null; then
    echo "  ✓ Installed"
    echo "  Config: ~/.config/claude-cli/config.json"
    if [[ -f ~/.config/claude-cli/config.json ]]; then
        echo "  ✓ Config exists"
    else
        echo "  ✗ Config missing"
    fi
else
    echo "  ✗ Not installed"
fi

# Check Claude Desktop config
echo ""
echo "Claude Desktop:"
if [[ -f ~/.config/claude/claude_desktop_config.json ]]; then
    echo "  ✓ Config exists"
elif [[ -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]]; then
    echo "  ✓ Config exists (macOS)"
else
    echo "  ✗ Config not found"
fi

# Check MCP servers
echo ""
echo "MCP Servers:"
for server in tmux neovim playwright; do
    server_path="$(dirname "$0")/../mcp-$server/server.js"
    echo -n "  $server: "
    if [[ -f "$server_path" ]]; then
        echo -n "✓"
        if [[ -d "$(dirname "$server_path")/node_modules" ]]; then
            echo " (dependencies installed)"
        else
            echo " (missing dependencies)"
        fi
    else
        echo "✗"
    fi
done

# Check project MCP config
echo ""
echo "Project MCP config:"
if [[ -f "$(dirname "$0")/../../.mcp.json" ]]; then
    echo "  ✓ .mcp.json exists"
else
    echo "  ✗ .mcp.json missing"
fi
