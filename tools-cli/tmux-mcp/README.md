# Tmux MCP Server

This module provides Model Context Protocol (MCP) integration between tmux and Claude Desktop/CLI, allowing Claude to interact with tmux sessions, windows, and panes.

## Features

- **Session Management**: Create, list, attach, and kill tmux sessions
- **Window Control**: Create, rename, and navigate windows
- **Pane Operations**: Split, navigate, resize, and read pane contents
- **Command Execution**: Send commands to specific panes
- **Content Reading**: Capture and read pane output

## Installation

```bash
./tools-cli/tmux-mcp/setup.sh
```

## Configuration

The setup script configures MCP for both:

1. **Claude Desktop**: Configuration at `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `~/.config/Claude/claude_desktop_config.json` (Linux)
2. **Claude CLI**: Configuration at `.mcp.json` in the dotfiles root

## Usage

### Shell Commands

After installation, these commands are available:

- `tmux-ls` - List all tmux sessions
- `tmux-panes` - List all panes across all sessions
- `tmux-mcp-test` - Test the MCP server functionality
- `tmux-mcp-status` - Check MCP configuration status
- `tmux-claude [name]` - Create a Claude-optimized tmux session

### In Claude

Once configured, you can ask Claude to:

- "Show me what's in my tmux sessions"
- "Create a new tmux session called 'dev'"
- "Send a command to the main window"
- "Read the output from pane 0"
- "Split the current window horizontally"

## Architecture

The MCP server (`tools-ai/mcp-tmux/server.js`) provides a JSON-RPC interface that Claude uses to interact with tmux. It translates Claude's requests into tmux commands and returns structured responses.

## Troubleshooting

1. **Check installation**: Run `tmux-mcp-status` to verify configuration
2. **Test server**: Run `tmux-mcp-test` to test basic functionality
3. **Restart Claude**: After installation, restart Claude Desktop or CLI
4. **Check logs**: Claude's developer console shows MCP communication

## Dependencies

- tmux (installed automatically if missing)
- Node.js >= 14 (must be installed separately)
