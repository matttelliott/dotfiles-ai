# Tmux MCP Server

A comprehensive Model Context Protocol (MCP) server that provides Claude CLI with deep integration into tmux sessions, enabling sophisticated terminal workspace management and automation.

## Overview

This MCP server allows Claude CLI to:
- Read contents from any tmux pane across all sessions
- List all tmux sessions, windows, and panes with detailed information
- Send commands to specific panes
- Create and manage tmux sessions and windows
- Split panes and control tmux layouts
- Monitor process activity across your terminal workspace

## Features

### Core Capabilities

- **Session Management**: List, create, and kill tmux sessions
- **Pane Reading**: Capture content and history from any pane
- **Command Execution**: Send commands to specific panes without switching context
- **Window Control**: Create new windows with custom commands
- **Pane Splitting**: Split existing panes horizontally or vertically
- **Process Monitoring**: Get detailed information about running processes

### Advanced Integration

- **Multi-pane Monitoring**: Read from multiple panes simultaneously
- **Cross-session Operations**: Work across different tmux sessions
- **Intelligent Targeting**: Precise pane targeting with session:window.pane syntax
- **Command Queuing**: Send multiple commands in sequence
- **Content Pagination**: Read large pane histories in chunks

## Installation

### Prerequisites

1. **tmux**: Must be installed and available in PATH
   ```bash
   # macOS
   brew install tmux
   
   # Ubuntu/Debian
   sudo apt install tmux
   ```

2. **Node.js**: Version 14 or higher
   ```bash
   # Check version
   node --version
   
   # Install via dotfiles-ai
   ./tools-lang/node/install
   ```

3. **Claude CLI**: Must be installed and configured

### Automatic Installation

Run the installation script from the dotfiles-ai repository:

```bash
# From dotfiles-ai root directory
./tools-ai/mcp-tmux/setup.sh
```

This will:
- Verify all dependencies
- Set up the MCP server
- Configure Claude CLI integration
- Create convenience scripts and aliases
- Test the installation

### Manual Installation

1. **Make server executable**:
   ```bash
   chmod +x /path/to/dotfiles-ai/tools-ai/mcp-tmux/server.js
   ```

2. **Configure Claude CLI**:
   Create or update `~/.config/claude/claude_desktop_config.json` (Linux) or 
   `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS):
   ```json
   {
     "mcpServers": {
       "tmux": {
         "command": "node",
         "args": ["/path/to/dotfiles-ai/tools-ai/mcp-tmux/server.js"],
         "env": {
           "NODE_ENV": "production"
         }
       }
     }
   }
   ```

3. **Restart Claude CLI** to load the new MCP server

## Usage

### Available Tools

The MCP server provides the following tools to Claude CLI:

#### `tmux_list_sessions`
List all tmux sessions with optional detailed information.

**Parameters:**
- `include_details` (boolean, optional): Include windows and panes information

**Example:**
```
List all my tmux sessions
```

#### `tmux_read_pane`
Read the contents/history of a specific tmux pane.

**Parameters:**
- `session` (string): Session name or ID
- `window` (string): Window name or index
- `pane` (string): Pane index
- `lines` (number, optional): Number of lines to capture (default: 100)
- `start_line` (number, optional): Starting line for pagination

**Example:**
```
Read the last 50 lines from pane 0 in window 1 of session "development"
```

#### `tmux_get_pane_info`
Get detailed information about a specific pane.

**Parameters:**
- `session` (string): Session name or ID
- `window` (string): Window name or index
- `pane` (string): Pane index

**Example:**
```
Get information about the current pane in my main session
```

#### `tmux_send_command`
Send a command to a specific tmux pane.

**Parameters:**
- `session` (string): Session name or ID
- `window` (string): Window name or index
- `pane` (string): Pane index
- `command` (string): Command to send
- `enter` (boolean, optional): Send Enter key after command (default: true)

**Example:**
```
Send "npm test" to pane 1 in my development session
```

#### `tmux_create_session`
Create a new tmux session.

**Parameters:**
- `name` (string): Session name
- `command` (string, optional): Initial command to run
- `directory` (string, optional): Starting directory
- `detached` (boolean, optional): Create in detached mode (default: true)

**Example:**
```
Create a new tmux session called "api-dev" in the /home/user/projects directory
```

#### `tmux_kill_session`
Kill a tmux session.

**Parameters:**
- `session` (string): Session name or ID to kill

**Example:**
```
Kill the session named "old-project"
```

#### `tmux_create_window`
Create a new window in an existing session.

**Parameters:**
- `session` (string): Session name or ID
- `name` (string, optional): Window name
- `command` (string, optional): Command to run in the window
- `directory` (string, optional): Starting directory

**Example:**
```
Create a new window called "logs" in my development session running "tail -f app.log"
```

#### `tmux_split_pane`
Split a pane in a tmux window.

**Parameters:**
- `session` (string): Session name or ID
- `window` (string): Window name or index
- `pane` (string): Pane index to split
- `direction` (string, optional): "horizontal" or "vertical" (default: "horizontal")
- `command` (string, optional): Command to run in new pane
- `percentage` (number, optional): Size percentage for new pane

**Example:**
```
Split pane 0 vertically in my development session and run "htop" in the new pane
```

## Examples

### Common Workflows

#### Development Environment Setup
```
Create a new session called "webdev" and set up a typical development layout:
1. Split the main pane to have editor on left, terminal on right
2. Split the right pane to have server logs on top, tests on bottom
3. Start the development server in the logs pane
4. Start the test watcher in the test pane
```

#### Monitoring Multiple Services
```
Show me what's running in all panes of my "monitoring" session
Read the last 20 lines from each pane to see the current status
```

#### Debugging Session Management
```
List all my tmux sessions and show me which ones have active processes
Find any panes that might have error messages in their recent output
```

#### Log Analysis
```
Read the last 100 lines from the logs pane in my production monitoring session
Look for any error patterns in the output
```

### Advanced Usage

#### Cross-Session Operations
```javascript
// Example: Monitor multiple projects simultaneously
const sessions = await tmux_list_sessions({ include_details: true });
for (const session of sessions.sessions) {
  for (const window of session.windows) {
    for (const pane of window.panes) {
      if (pane.command.includes('npm')) {
        const content = await tmux_read_pane(session.name, window.index, pane.index, 10);
        // Analyze content for errors or status
      }
    }
  }
}
```

#### Automated Environment Setup
```javascript
// Create a full development environment
await tmux_create_session("fullstack", null, "/home/user/project");
await tmux_split_pane("fullstack", "0", "0", "vertical");
await tmux_split_pane("fullstack", "0", "1", "horizontal");
await tmux_send_command("fullstack", "0", "0", "nvim .");
await tmux_send_command("fullstack", "0", "1", "npm run dev");
await tmux_send_command("fullstack", "0", "2", "npm run test:watch");
```

## Troubleshooting

### Common Issues

#### "no server running"
This means tmux is not currently running. Start a tmux session first:
```bash
tmux new-session -d -s test
```

#### "can't find session"
Verify the session name exists:
```bash
tmux list-sessions
```

#### "failed to connect to server"
Check that the MCP server is properly configured in Claude CLI and that Node.js is available.

#### Permission Denied
Ensure the server script is executable:
```bash
chmod +x /path/to/dotfiles-ai/mcp-servers/tmux/server.js
```

### Testing

Run the test script to verify everything is working:
```bash
./tools-ai/mcp-tmux/test-server.js
```

This will test basic functionality and report any issues.

### Debug Mode

To debug the MCP server, you can run it manually:
```bash
cd /path/to/dotfiles-ai/tools-ai/mcp-tmux
node server.js
```

Then send JSON-RPC messages to test specific functionality.

## Configuration

### Server Configuration

The MCP server is configured through the Claude CLI configuration file. The default configuration should work for most users, but you can customize:

- **Environment variables**: Add custom environment variables to the `env` section
- **Working directory**: The server runs from the tools-ai/mcp-tmux directory
- **Node.js options**: Modify the `args` array to pass Node.js flags

### Tmux Configuration

This MCP server works with any tmux configuration, but integrates best with the dotfiles-ai tmux setup:

- Enhanced key bindings for easier navigation
- Consistent pane numbering and naming
- Optimized for development workflows

### Claude CLI Integration

To get the most out of this integration:

1. **Use descriptive session names**: "development", "monitoring", "debugging"
2. **Organize panes logically**: Group related processes in the same window
3. **Use consistent workflows**: Develop patterns that Claude can learn and automate

## Security Considerations

The MCP server provides powerful access to your terminal environment. Consider these security aspects:

- **Command execution**: The server can send any command to tmux panes
- **Content access**: The server can read all content from any tmux pane
- **Process control**: The server can create and kill tmux sessions

Best practices:
- Only use in trusted environments
- Review any automated scripts before execution
- Monitor what commands are being sent to your panes
- Keep the MCP server configuration secure

## Contributing

This MCP server is part of the dotfiles-ai project. To contribute:

1. **Report issues**: Use the GitHub issues for bug reports
2. **Suggest features**: Open feature requests for new capabilities
3. **Submit PRs**: Follow the project's contribution guidelines
4. **Test thoroughly**: Ensure changes work across different tmux configurations

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Related Tools

This MCP server integrates well with other dotfiles-ai tools:

- **tmux configuration**: Enhanced tmux setup with useful key bindings
- **neovim integration**: Seamless editor and terminal workflow
- **zsh configuration**: Shell aliases and functions for tmux
- **Development tools**: Monitoring and debugging tool integrations

## Advanced Features

### Planned Enhancements

- **Session templates**: Predefined layouts for different project types
- **Automatic monitoring**: Detect and alert on process failures
- **Log aggregation**: Collect and analyze logs from multiple panes
- **Performance monitoring**: Track resource usage across panes
- **Backup and restore**: Save and restore session states
- **Remote tmux**: Manage tmux sessions on remote servers

### Customization

The MCP server is designed to be extensible. You can modify the server.js file to add custom functionality:

- **Custom commands**: Add new tmux operations
- **Enhanced parsing**: Improve content analysis
- **Integration hooks**: Connect with other tools and services
- **Automation workflows**: Create complex multi-step operations