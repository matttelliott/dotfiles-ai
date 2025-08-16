#!/bin/bash

echo "Claude Code Configuration Diagnostic"
echo "===================================="
echo ""

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# Check Node.js
echo "Node.js:"
if command -v node &>/dev/null; then
    echo "  ✓ $(node --version)"
else
    echo "  ✗ Not installed"
fi

# Check Claude Code settings
echo ""
echo "Claude Code Settings:"
if [[ -f ~/.claude/settings.json ]]; then
    echo "  ✓ User settings exists"
    if [[ -L ~/.claude/settings.json ]]; then
        echo "    Symlinked to: $(readlink ~/.claude/settings.json)"
    fi
    
    # Check if MCP servers are configured
    if command -v jq &>/dev/null; then
        echo "  MCP servers configured:"
        jq -r '.mcpServers | keys[]' ~/.claude/settings.json 2>/dev/null | sed 's/^/    - /'
    fi
else
    echo "  ✗ User settings not found"
fi

# Check authentication
if [[ -f ~/.claude/.credentials.json ]]; then
    echo "  ✓ Authentication credentials exist"
else
    echo "  ℹ No authentication credentials found (run 'claude login' to authenticate)"
fi

# Check MCP servers
echo ""
echo "MCP Server Status:"
for server in tmux neovim playwright; do
    server_path="$DOTFILES_DIR/tools-ai/mcp-$server/server.js"
    echo -n "  $server: "
    if [[ -f "$server_path" ]]; then
        echo -n "✓ installed"
        if [[ -d "$(dirname "$server_path")/node_modules" ]]; then
            echo " (dependencies ✓)"
        else
            echo " (missing dependencies)"
        fi
    else
        echo "✗ not found"
    fi
done

# Check required tools
echo ""
echo "Required Tools:"
echo -n "  tmux: "
command -v tmux &>/dev/null && echo "✓ $(tmux -V)" || echo "✗ not installed"
echo -n "  neovim: "
command -v nvim &>/dev/null && echo "✓ $(nvim --version | head -1)" || echo "✗ not installed"

# Check Claude Desktop config
echo ""
echo "Claude Desktop:"
DESKTOP_CONFIG=""
if [[ -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]]; then
    DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    echo "  ✓ Config exists (macOS)"
elif [[ -f "$HOME/.config/claude/claude_desktop_config.json" ]]; then
    DESKTOP_CONFIG="$HOME/.config/claude/claude_desktop_config.json"
    echo "  ✓ Config exists (Linux)"
else
    echo "  ℹ Config not found (desktop environment may not be available)"
fi

echo ""
echo "Quick Test Commands:"
echo "  Test MCP servers: claude mcp list"
echo "  View settings: claude config list"
echo "  Login to Claude: claude login"
