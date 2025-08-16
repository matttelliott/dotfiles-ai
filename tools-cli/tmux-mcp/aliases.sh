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
