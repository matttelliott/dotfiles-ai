# Claude CLI Configuration

This directory contains all Claude CLI setup and configuration files for AI-powered coding assistance in your terminal environment.

## Files

- `setup.sh` - Standalone Claude CLI installation script
- `aliases.zsh` - Claude CLI aliases and helper functions for zsh
- `README.md` - This documentation file

## Installation

The Claude CLI is automatically installed when you run the main dotfiles setup:

```bash
./install.sh
```

Or you can install Claude CLI separately:

```bash
./claude/setup.sh
```

## Setup

After installation, you need to authenticate with your Anthropic API key:

```bash
claude auth
```

## Available Commands

### Quick Aliases

- `c` - Quick Claude access
- `cask` - Ask Claude questions
- `ccode` - Claude code assistance  
- `cfile` - Claude file operations
- `cauth` - Set up your API key

### Helper Functions

- `caskfile <file> <question>` - Analyze any file with Claude
- `ccommit` - Generate git commit messages from staged changes
- `cexplain <command>` - Get explanations for any terminal command
- `creview <file>` - Get code review suggestions
- `cdoc <file>` - Generate documentation for code
- `cdebug <file>` - Get debugging assistance

## Usage Examples

```bash
# Ask Claude a question
cask "How do I optimize this Python function?"

# Generate a commit message
git add .
ccommit

# Explain a complex command
cexplain "find . -name '*.js' -exec grep -l 'TODO' {} \;"

# Analyze a file
caskfile script.py "What does this script do?"

# Get code review
creview mycode.js

# Generate documentation
cdoc myfunction.py
```

## Configuration

The aliases and functions are automatically loaded when you start a new shell session. They are conditionally loaded only when Claude CLI is available on your system.

## Troubleshooting

If Claude CLI is not working:

1. Verify installation: `claude --version`
2. Check authentication: `claude auth`
3. Test basic functionality: `claude ask "Hello"`

For more help, visit the [Claude CLI documentation](https://github.com/anthropics/claude-cli).
