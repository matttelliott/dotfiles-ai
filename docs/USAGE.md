# Usage Guide for dotfiles-ai

This guide covers how to use and customize your dotfiles-ai configuration.

## Quick Start

After installation, restart your terminal and you'll have access to all the configured tools.

## Neovim

### Key Bindings
- `<Space>` - Leader key
- `<Leader>pv` - Open file explorer (Ex command)
- `<Leader>e` - Toggle NvimTree file explorer
- `<Leader>ff` - Find files with Telescope
- `<Leader>fg` - Live grep with Telescope
- `<Leader>fb` - Browse buffers with Telescope

### LSP Bindings (when attached to a buffer)
- `gD` - Go to declaration
- `gd` - Go to definition
- `K` - Show hover information
- `gi` - Go to implementation
- `<C-k>` - Show signature help
- `<Leader>rn` - Rename symbol
- `<Leader>ca` - Code actions
- `gr` - Show references

### Plugin Management
Plugins are managed with `lazy.nvim` and will install automatically on first launch.

## tmux

### Key Bindings
- `Ctrl-a` - Prefix key (instead of default Ctrl-b)
- `Prefix + |` - Split window horizontally
- `Prefix + -` - Split window vertically
- `Prefix + h/j/k/l` - Navigate panes (Vim-style)
- `Alt + Arrow Keys` - Navigate panes without prefix
- `Prefix + Shift + H/J/K/L` - Resize panes
- `Prefix + r` - Reload tmux configuration
- `Prefix + c` - Create new window (in current path)

### Copy Mode
- `Prefix + [` - Enter copy mode
- `v` - Start selection (in copy mode)
- `y` - Copy selection (in copy mode)
- `Prefix + p` - Paste

## zsh

### Aliases

#### General
- `ll` - Long listing format
- `la` - List all files
- `..` / `...` / `....` - Navigate up directories
- `vim` / `vi` - Opens Neovim

#### Git
- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gd` - git diff
- `gb` - git branch
- `gco` - git checkout
- `glog` - git log with graph

#### tmux
- `t` - tmux
- `ta` - tmux attach
- `tls` - tmux list-sessions

#### Directories
- `dotfiles` - cd to ~/.dotfiles-ai
- `projects` - cd to ~/projects

### Custom Functions

#### `mkcd <directory>`
Create directory and cd into it:
```bash
mkcd new-project
```

#### `extract <file>`
Extract various archive formats:
```bash
extract archive.tar.gz
extract file.zip
```

#### `killp <process-name>`
Find and kill process by name:
```bash
killp node
```

#### `weather [location]`
Get weather information:
```bash
weather
weather "New York"
```

## Customization

### Local Customizations

Create these files for local customizations that won't be tracked by git:

- `~/.zshrc.local` - Local zsh customizations
- `~/.env` - Environment variables

### Neovim Customizations

Add custom configurations in `~/.config/nvim/lua/custom/` directory.

### tmux Customizations

Platform-specific tmux configurations are automatically loaded:
- `~/.dotfiles-ai/tmux/macos.conf` - macOS specific
- `~/.dotfiles-ai/tmux/linux.conf` - Linux specific

## Troubleshooting

### Neovim Issues
- If plugins don't install: Run `:Lazy sync` in Neovim
- If LSP doesn't work: Run `:Mason` to check language servers

### tmux Issues
- If clipboard doesn't work on Linux: Install `xclip` or `xsel`
- If clipboard doesn't work on macOS: Install `reattach-to-user-namespace`

### zsh Issues
- If oh-my-zsh plugins don't load: Check `~/.oh-my-zsh/custom/plugins/`
- If theme doesn't display correctly: Install a Powerline font

## Updates

To update your dotfiles:

```bash
cd ~/.dotfiles-ai
git pull origin main
./install.sh
```

## Platform-Specific Notes

### Debian/Ubuntu/Linux Mint
- Uses `apt` package manager
- Clipboard integration via `xclip`
- `fd` command linked from `fdfind`

### macOS
- Uses Homebrew package manager
- Clipboard integration via `pbcopy`/`pbpaste`
- Includes GUI applications via Homebrew Cask
