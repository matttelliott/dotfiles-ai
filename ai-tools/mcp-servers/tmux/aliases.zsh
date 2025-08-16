# Tmux MCP Server aliases
alias tmux-mcp-start="/home/matt/dotfiles-ai/ai-tools/mcp-servers/tmux/start.sh"
alias tmux-mcp-test="/home/matt/dotfiles-ai/ai-tools/mcp-servers/tmux/test-server.js"
alias tmux-mcp-config="cat /home/matt/.config/claude/claude_desktop_config.json"

# Enhanced tmux aliases with MCP awareness
alias tmux-sessions="tmux list-sessions -F '#{session_name}: #{session_windows} windows, created #{session_created_string}'"
alias tmux-panes="tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} - #{pane_current_command} (#{pane_width}x#{pane_height})'"
