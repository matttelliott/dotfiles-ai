# Claude CLI Configuration

This directory contains all Claude CLI setup and configuration files for AI-powered coding assistance in your terminal environment.

## Files

- `setup.sh` - Standalone Claude CLI installation script
- `aliases.zsh` - Claude CLI aliases and helper functions for zsh
- `personalities.zsh` - Claude personality modes for different tasks
- `config/settings.json` - Shared Claude configuration and preferences
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

### Claude Personalities

Different modes optimized for specific tasks (use tab completion after `claude-`):

- `claude-coder` - Write production code (temp: 0.3)
- `claude-architect` - Design systems and architecture (temp: 0.5)
- `claude-reviewer` - Review code for issues (temp: 0.2)
- `claude-teacher` - Explain concepts clearly (temp: 0.6)
- `claude-creative` - Brainstorm creative solutions (temp: 0.9)
- `claude-tester` - Write comprehensive tests (temp: 0.2)
- `claude-debugger` - Find and fix bugs (temp: 0.1)
- `claude-refactorer` - Improve code structure (temp: 0.4)
- `claude-documenter` - Write documentation (temp: 0.5)
- `claude-personalities` - List all available personalities

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

### Using Personalities

```bash
# Write production code with TDD
claude-coder "implement a user authentication system"

# Design architecture
claude-architect "design a microservices architecture for an e-commerce platform"

# Review code
claude-reviewer "review this pull request for security issues"

# Learn concepts
claude-teacher "explain how async/await works in JavaScript"

# Write tests
claude-tester "write unit tests for this UserService class"

# Debug issues
claude-debugger "why is this function returning undefined?"

# Refactor code
claude-refactorer "improve this legacy code for better maintainability"

# Document code
claude-documenter "write API documentation for these endpoints"
```

### Using Helper Functions

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
