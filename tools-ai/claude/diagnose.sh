#!/bin/bash

echo "Claude Code Configuration Diagnostic"
echo "===================================="
echo ""

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
else
    echo "  ✗ User settings not found"
fi

# Check project settings
if [[ -f .claude/settings.json ]]; then
    echo "  ✓ Project settings exists"
fi
if [[ -f .claude/settings.local.json ]]; then
    echo "  ✓ Project local settings exists"
fi

# Check CLAUDE.md
if [[ -f CLAUDE.md ]]; then
    echo "  ✓ CLAUDE.md exists ($(wc -l < CLAUDE.md) lines)"
fi

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
    echo "  ✗ Config not found"
fi

# Check MCP servers
echo ""
echo "MCP Servers:"
DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
for server in tmux neovim playwright; do
    server_path="$DOTFILES_DIR/tools-ai/mcp-$server/server.js"
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

echo ""
echo "Use 'claude config list' to see current settings"
echo "Use 'claude config get <key>' to view specific settings"
