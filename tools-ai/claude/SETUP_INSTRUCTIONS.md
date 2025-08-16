# Claude Code MCP Server Setup Instructions

## Installation Complete! 🎉

The MCP servers have been successfully installed and configured for Claude Code on this machine.

## Current Status

### ✅ Installed Components
- **Node.js**: v22.18.0 (required for MCP servers)
- **MCP Servers**:
  - `mcp-tmux`: Terminal multiplexer control
  - `mcp-neovim`: Neovim editor integration  
  - `mcp-playwright`: Browser automation
- **Configuration Files**:
  - `~/.claude/settings.json`: Symlinked to dotfiles configuration
  - `~/.config/claude/claude_desktop_config.json`: Claude Desktop config (if GUI available)

### 🔧 How MCP Servers Work

MCP servers are **launched on-demand** by Claude Code when you use them. They don't run continuously in the background. When you ask Claude to:
- Control tmux sessions → `mcp-tmux` launches
- Edit files in Neovim → `mcp-neovim` launches
- Automate browser tasks → `mcp-playwright` launches

## Quick Start Guide

### 1. Verify Installation
```bash
# Run diagnostic check
/home/matt/dotfiles-ai/tools-ai/claude/diagnose.sh

# Check MCP server configuration
claude config get mcpServers
```

### 2. Test MCP Servers

#### Test tmux MCP
```bash
# Start a tmux session first
tmux new -s test

# In Claude Code, try:
# "List all tmux sessions"
# "Create a new tmux window"
# "Send 'ls -la' to the current tmux pane"
```

#### Test Neovim MCP
```bash
# Start Neovim with a socket
nvim --listen /tmp/nvim.pipe

# In Claude Code, try:
# "Open file.txt in Neovim"
# "Navigate to line 10 in Neovim"
```

#### Test Playwright MCP
```bash
# In Claude Code, try:
# "Launch a browser and go to google.com"
# "Take a screenshot of the current page"
# "Extract all links from the page"
```

### 3. Using MCP Servers in Claude Code

The MCP servers are now available in your Claude Code sessions. You can:

1. **Control terminal sessions** with tmux commands
2. **Edit files** through Neovim integration
3. **Automate browsers** for web scraping and testing

## Troubleshooting

### MCP Servers Show "Failed to connect"
This is **normal** when servers aren't actively being used. They launch when Claude needs them.

### Authentication Issues
If you haven't logged in yet:
```bash
claude login
```

### Verify Settings
```bash
# View all Claude settings
claude config list

# Check MCP server paths
cat ~/.claude/settings.json | jq '.mcpServers'
```

### Test Individual Servers
```bash
# Test tmux server
node /home/matt/dotfiles-ai/tools-ai/mcp-tmux/server.js --test

# Test neovim server  
node /home/matt/dotfiles-ai/tools-ai/mcp-neovim/server.js --info

# Test playwright server
cd /home/matt/dotfiles-ai/tools-ai/mcp-playwright && npm test
```

## Configuration Files

### User Settings Location
- **Primary**: `~/.claude/settings.json`
- **Source**: `/home/matt/dotfiles-ai/tools-ai/claude/.claude/settings.json`
- **Management**: Via GNU Stow (symlinked)

### What's Configured
- Model: claude-3-5-sonnet-20241022
- Permissions: File operations, bash commands, git, npm
- MCP Servers: tmux, neovim, playwright
- Features: Auto-save, syntax highlighting

## Maintenance

### Update MCP Servers
```bash
cd /home/matt/dotfiles-ai
git pull
./tools-ai/install --all
```

### Reinstall Specific Server
```bash
./tools-ai/install
# Then choose option 4 for specific MCP server
```

### Check for Issues
```bash
./tools-ai/install --diagnose
```

## Security Notes

- ✅ Your authentication credentials (`~/.claude/.credentials.json`) are:
  - Excluded from git (in .gitignore)
  - Excluded from GNU Stow (won't be symlinked)
  - Kept separate from configuration files

## Next Steps

1. **Start using MCP servers** in your Claude Code sessions
2. **Customize settings** if needed in `~/.claude/settings.json`
3. **Report issues** at the dotfiles-ai repository

## Example Claude Code Commands

Try these in your Claude Code session to test MCP functionality:

```
"Create a new tmux session called 'dev' and split it into 4 panes"
"Open my dotfiles README in Neovim and jump to the installation section"
"Launch a browser, search for 'MCP protocol docs', and save a screenshot"
```

## Support

- **Diagnostics**: `/home/matt/dotfiles-ai/tools-ai/claude/diagnose.sh`
- **Documentation**: This file and README files in each MCP server directory
- **Official Docs**: https://docs.anthropic.com/claude-code