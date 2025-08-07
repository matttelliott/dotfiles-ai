# fzf - Fuzzy Finder

Command-line fuzzy finder that integrates with shell, vim, and tmux.

## Installation

```bash
./fzf/setup.sh
```

## Key Bindings

After installation, these key bindings are available in your shell:

- **Ctrl+R** - Search command history
- **Ctrl+T** - Search and paste file paths
- **Alt+C** - Search and cd to directories
- **Ctrl+/** - Toggle preview window (when searching)

## Configuration

The configuration file `fzf.zsh` is symlinked to `~/.config/fzf/fzf.zsh` and automatically sourced by zsh.

## Features

- Uses `fd` (if available) for faster file searching
- Uses `bat` (if available) for syntax-highlighted previews
- Hidden files are included in searches (except .git)
- Reverse layout with border for better visibility

## Integration

- **Shell**: Command history, file/directory search
- **Vim/Neovim**: File fuzzy finding (if configured in vim)
- **Git**: Can be used with git aliases for branch/commit searching