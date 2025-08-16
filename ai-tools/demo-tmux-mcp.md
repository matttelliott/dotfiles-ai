# Tmux MCP Integration Demo

This guide demonstrates how to use the tmux MCP server with Claude CLI to monitor and analyze dotfiles installations.

## Setup Complete! ✅

The tmux MCP server has been installed and configured. Here's how to use it:

## 1. Manual Tmux Session Creation

First, create a tmux session manually (since we're in a non-terminal environment):

```bash
# In your terminal, create a session for monitoring
tmux new-session -d -s installer -n main

# Split into panes for different outputs
tmux split-window -h -t installer:main
tmux split-window -v -t installer:main.0

# Run an installation in the main pane
tmux send-keys -t installer:main.0 "cd ~/dotfiles-ai && ./install cli" C-m
```

## 2. Using Claude CLI with MCP

Now you can use Claude CLI to monitor the installation. Here are example prompts:

### Monitor Installation Progress
```
Using the tmux MCP server, please:
1. List all tmux sessions
2. Read the last 100 lines from pane 0 in the 'installer' session
3. Identify any errors or warnings in the output
4. Suggest fixes for any issues found
```

### Analyze Specific Errors
```
Please check the installer session using tmux MCP:
1. Read pane 0 from the 'installer' session
2. Look for any error messages
3. Provide exact commands to fix the errors
4. Tell me if I should restart the installation
```

### Get Installation Summary
```
Using tmux MCP, analyze the installer session:
1. Read all panes in the 'installer' session
2. Determine if installation completed successfully
3. List any follow-up actions needed
4. Identify any warnings that need attention
```

## 3. Using the AI-Assisted Installer

We've created a special script that sets up tmux sessions optimized for AI monitoring:

```bash
# Setup monitoring session
./ai-tools/install-with-ai.sh setup

# Install a specific tool with monitoring
./ai-tools/install-with-ai.sh install neovim

# Generate a Claude prompt for analysis
./ai-tools/install-with-ai.sh claude-prompt

# Monitor current status
./ai-tools/install-with-ai.sh monitor

# Clean up when done
./ai-tools/install-with-ai.sh cleanup
```

## 4. Available MCP Commands

The tmux MCP server provides these tools to Claude:

- **tmux_list_sessions**: List all tmux sessions with details
- **tmux_read_pane**: Read content from specific panes
- **tmux_get_pane_info**: Get detailed pane information
- **tmux_send_command**: Send commands to panes
- **tmux_create_session**: Create new sessions
- **tmux_kill_session**: Clean up sessions
- **tmux_create_window**: Add windows to sessions
- **tmux_split_pane**: Create pane layouts

## 5. Real-World Example

Here's a complete workflow:

```bash
# 1. Start an installation in tmux
tmux new-session -d -s build -c ~/dotfiles-ai
tmux send-keys -t build "./tools-lang/go/install 2>&1 | tee /tmp/go-install.log" C-m

# 2. In Claude CLI, monitor it:
# "Using tmux MCP, read the last 50 lines from the 'build' session and tell me if the Go installation is proceeding correctly"

# 3. If errors occur, Claude can help:
# "The Go installation failed. Using tmux MCP, read the error and provide the fix commands"

# 4. Claude can even send fixes directly:
# "Send the command 'sudo apt install build-essential' to pane 0 in the build session"
```

## 6. Configuration Files

The MCP server configuration is stored in:
- `~/.config/claude/claude_desktop_config.json` - Claude Desktop/CLI config
- `~/dotfiles-ai/ai-tools/mcp-servers/tmux/server.js` - MCP server implementation

## 7. Troubleshooting

If the MCP server isn't working:

1. **Check server is accessible**:
   ```bash
   node ~/dotfiles-ai/ai-tools/mcp-servers/tmux/server.js --test
   ```

2. **Verify Claude configuration**:
   ```bash
   cat ~/.config/claude/claude_desktop_config.json
   ```

3. **Restart Claude CLI** to reload MCP servers

4. **Check tmux is installed**:
   ```bash
   tmux -V
   ```

## Benefits of This Integration

1. **Real-time Monitoring**: Claude can watch installations as they happen
2. **Error Analysis**: AI can immediately identify and explain errors
3. **Suggested Fixes**: Get exact commands to resolve issues
4. **Progress Tracking**: Monitor long-running installations
5. **Multi-pane Support**: Watch logs, errors, and output simultaneously
6. **Historical Analysis**: Review what happened after completion

## Next Steps

1. Try running an installation in tmux
2. Use Claude CLI to monitor it with MCP
3. Ask Claude to analyze any errors
4. Let Claude suggest optimizations

The integration is now ready to use! The tmux MCP server allows Claude to be your installation assistant, watching for issues and providing solutions in real-time.