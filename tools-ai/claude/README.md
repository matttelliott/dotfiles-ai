# Claude Code Configuration

This directory manages Claude Code (claude.ai/code) configuration according to the official documentation.

## Configuration Structure

According to the official docs, Claude Code uses these configuration files:

### User Settings
- `~/.claude/settings.json` - Global user settings (managed by this installer)

### Project Settings (not managed by dotfiles)
- `.claude/settings.json` - Team-shared project settings
- `.claude/settings.local.json` - Personal project settings
- `CLAUDE.md` - Project context and instructions
- `CLAUDE.local.md` - Personal project context

## What This Installer Does

1. **Installs MCP servers** - tmux, neovim, and playwright integration
2. **Configures user settings** - Creates ~/.claude/settings.json with:
   - MCP server configurations
   - Useful permissions
   - Environment variables
   - Feature flags
3. **Sets up Claude Desktop** - If desktop environment is detected
4. **Uses GNU Stow** - For proper configuration management

## Configuration Hierarchy

Settings are applied in this order (highest to lowest precedence):
1. Enterprise managed settings (if applicable)
2. Project settings (`.claude/settings.json`)
3. User settings (`~/.claude/settings.json`)
4. Project local settings (`.claude/settings.local.json`)

## Available Commands

After installation:
- `claude config list` - List all settings
- `claude config get <key>` - View a specific setting
- `claude config set <key> <value>` - Change a setting
- `./test-mcp.sh` - Test MCP server connectivity
- `./diagnose.sh` - Diagnose configuration

## MCP Servers

The following MCP servers are configured:
- **tmux** - Terminal multiplexer control
- **neovim** - Neovim editor integration
- **playwright** - Browser automation

## Customization

To add project-specific settings, create these files in your project root:
- `.claude/settings.json` - Shared settings
- `.claude/settings.local.json` - Personal settings (gitignored)
- `CLAUDE.md` - Project instructions

## Environment Variables

Key environment variables:
- `ANTHROPIC_API_KEY` - API authentication
- `CLAUDE_CODE_USE_BEDROCK` - Use Amazon Bedrock (default: false)
- `CLAUDE_CODE_USE_VERTEX` - Use Google Vertex AI (default: false)
