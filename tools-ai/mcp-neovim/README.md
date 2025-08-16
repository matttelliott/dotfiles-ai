# Neovim MCP Server

This module provides Model Context Protocol (MCP) integration between Neovim and Claude Desktop/CLI, allowing Claude to interact with Neovim instances, edit files, manage buffers, and execute Vim commands.

## Features

- **Instance Management**: Start, list, and connect to Neovim instances
- **File Operations**: Open, save, and navigate files
- **Buffer Management**: List, switch, and query buffer information
- **Text Editing**: Insert text, search, and manipulate content
- **Command Execution**: Run Vim commands and expressions
- **Visual Mode**: Get visual selections
- **Server Sockets**: Communicate with Neovim via RPC sockets

## Installation

```bash
./tools-ai/mcp-neovim/setup.sh
```

The setup script will:
1. Install Neovim if not present
2. Install neovim-remote (nvr) for enhanced functionality
3. Configure Claude Desktop and CLI
4. Set up shell aliases and functions

## Configuration

The MCP server is configured in two locations:

1. **Claude Desktop**: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `~/.config/Claude/claude_desktop_config.json` (Linux)
2. **Claude CLI**: `.mcp.json` in the dotfiles root

## Usage

### Starting Neovim with Server Support

```bash
# Start Neovim with a named server socket
nvim-server myproject file.txt

# Start a Claude-optimized Neovim session
nvim-claude

# Start with custom socket path
nvim --listen /tmp/nvim-custom.sock file.txt
```

### Shell Commands

After installation, these commands are available:

- `nvim-server [name]` - Start Neovim with server socket
- `nvim-claude [name]` - Start Claude-optimized Neovim session
- `nvim-sockets` - List active server sockets
- `nvim-mcp-test` - Test MCP server functionality
- `nvim-mcp-status` - Check MCP configuration status

### In Claude

Once configured, you can ask Claude to:

- "Open file.txt in Neovim"
- "Show me what buffers are open in Neovim"
- "Save the current file in Neovim"
- "Search for 'function' in the current buffer"
- "Insert a new function at the cursor"
- "Run the Vim command :set number"
- "Get the current cursor position"

## MCP Methods

The server provides these methods for Claude:

| Method | Description | Parameters |
|--------|-------------|------------|
| `neovim/check` | Check if Neovim is installed | None |
| `neovim/list` | List running instances | None |
| `neovim/start` | Start new instance | `name`, `headless` |
| `neovim/connect` | Connect to instance | `socket` |
| `neovim/command` | Send command/expression | `socket`, `command`, `expr` |
| `neovim/open` | Open file | `socket`, `file`, `line` |
| `neovim/buffer-info` | Get current buffer info | `socket` |
| `neovim/buffers` | List all buffers | `socket` |
| `neovim/save` | Save current buffer | `socket`, `force` |
| `neovim/vim-command` | Execute Vim command | `socket`, `command` |
| `neovim/insert` | Insert text at cursor | `socket`, `text` |
| `neovim/search` | Search in buffer | `socket`, `pattern`, `backwards` |
| `neovim/selection` | Get visual selection | `socket` |

## Architecture

The MCP server (`server.js`) provides a JSON-RPC interface that Claude uses to interact with Neovim. It communicates with Neovim instances through:

1. **Server sockets**: Unix domain sockets for RPC communication
2. **Remote commands**: Using `nvim --remote` or `nvr` (neovim-remote)
3. **Process management**: Starting and tracking Neovim instances

## Examples

### Starting a Development Session

```bash
# Start Neovim with MCP support for your project
nvim-claude myproject

# In another terminal, verify the socket
nvim-sockets

# Now Claude can interact with this Neovim instance
```

### Editing Files with Claude

```
You: "Open src/main.js in Neovim and go to line 42"
Claude: [Opens file and navigates to line 42]

You: "Search for the function named 'processData'"
Claude: [Searches and positions cursor at function]

You: "Add a comment above this function"
Claude: [Inserts comment at appropriate location]
```

### Managing Multiple Files

```
You: "Show me all open buffers in Neovim"
Claude: [Lists all buffers with their status]

You: "Switch to buffer 3"
Claude: [Switches to specified buffer]

You: "Save all modified buffers"
Claude: [Saves all buffers with changes]
```

## Troubleshooting

### Neovim Not Found
- Run `nvim --version` to check installation
- Install via: `brew install neovim` (macOS) or `apt install neovim` (Linux)

### Connection Issues
- Check if Neovim is running with server socket: `nvim-sockets`
- Ensure socket path is accessible
- Try starting with explicit socket: `nvim --listen /tmp/test.sock`

### Remote Commands Not Working
- Install neovim-remote: `pip3 install neovim-remote`
- Check if `nvr` command is available
- Fallback to native `nvim --remote` commands

### MCP Server Not Loading
- Restart Claude Desktop/CLI after installation
- Check configuration: `nvim-mcp-status`
- Verify Node.js version: `node --version` (requires >= 14)

## Advanced Usage

### Headless Neovim Instances

```javascript
// Start a headless instance for background processing
{
  "method": "neovim/start",
  "params": {
    "name": "background",
    "headless": true
  }
}
```

### Custom Socket Paths

```bash
# Use custom socket location
export NVIM_LISTEN_ADDRESS=/custom/path/nvim.sock
nvim
```

### Integration with tmux

```bash
# Start Neovim in tmux with MCP support
tmux new-session -d -s dev
tmux send-keys -t dev "nvim-server project" C-m
```

## Dependencies

- **Neovim** >= 0.5.0 (for RPC support)
- **Node.js** >= 14.0.0
- **neovim-remote** (optional, for enhanced functionality)

## Security Considerations

- Server sockets are created in `/tmp` by default
- Sockets are only accessible by the current user
- No network exposure (Unix domain sockets only)
- Commands are sanitized before execution

## Future Enhancements

- [ ] LSP integration for code intelligence
- [ ] Debugging support via DAP
- [ ] Plugin management capabilities
- [ ] Snippet insertion
- [ ] Macro recording and playback
- [ ] Window and tab management
- [ ] Terminal integration
- [ ] Git integration via fugitive

## License

MIT - Part of the dotfiles-ai project