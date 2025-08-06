# Neovim Configuration

## What is Neovim?

Neovim is a modern, extensible text editor based on Vim. It's designed for developers who want a powerful, keyboard-driven editing experience with modern features like built-in LSP (Language Server Protocol) support, better plugin architecture, and improved performance.

## Our Configuration Features

### Core Setup
- **Leader Key**: Space bar (`<Space>`) for easy access to commands
- **Modern UI**: Tokyo Night colorscheme with clean aesthetics
- **Smart Defaults**: Relative line numbers, proper indentation, persistent undo

### Plugin Management
- **lazy.nvim**: Modern plugin manager that loads plugins on-demand for faster startup
- **Automatic Installation**: Plugins install automatically on first launch

### Language Support
- **LSP Integration**: Built-in language server support via `nvim-lspconfig`
- **Mason**: Automatic installation and management of language servers
- **Treesitter**: Advanced syntax highlighting and code understanding
- **Auto-completion**: Intelligent code completion with `nvim-cmp`

### Language Support (Extensible)
- **Lua**: Full Neovim API support with lazydev
- **Ready for any language**: Easy to add support for Python, Rust, JavaScript, Go, etc.
- **Mason integration**: Automatic LSP server installation

### Plugin Management
- **lazy.nvim**: Modern plugin manager with lazy loading
- Automatic plugin installation and health checks
- Optimized startup performance

## Key Bindings

### Leader Key
- Leader key: `<Space>` (spacebar)

### Search Operations (Telescope)
- `<leader>sh` - Search help tags
- `<leader>sk` - Search keymaps
- `<leader>sf` - Search files
- `<leader>ss` - Search select (Telescope pickers)
- `<leader>sw` - Search current word
- `<leader>sg` - Search by grep (live)
- `<leader>sd` - Search diagnostics
- `<leader>sr` - Search resume
- `<leader>s.` - Search recent files
- `<leader>sn` - Search Neovim config files
- `<leader><leader>` - Find existing buffers
- `<leader>/` - Fuzzy search in current buffer
- `<leader>s/` - Search in open files

### LSP Bindings (when LSP is active)
- `gd` - Go to definition
- `gr` - Go to references  
- `gI` - Go to implementation
- `gD` - Go to declaration
- `<leader>D` - Type definition
- `<leader>ds` - Document symbols
- `<leader>ws` - Workspace symbols
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>th` - Toggle inlay hints

### Window Navigation
- `<C-h>` - Move to left window
- `<C-j>` - Move to bottom window
- `<C-k>` - Move to top window
- `<C-l>` - Move to right window

### Completion (in insert mode)
- `<C-n>` - Next completion item
- `<C-p>` - Previous completion item
- `<C-y>` - Accept completion
- `<C-Space>` - Trigger completion
- `<C-l>` - Expand snippet or jump forward
- `<C-h>` - Jump backward in snippet

### General
- `<Esc>` - Clear search highlights
- `<leader>q` - Open diagnostic quickfix list
- `<Esc><Esc>` - Exit terminal mode

## Installation

The configuration is automatically installed when you run the main dotfiles installation script:

```bash
# From the dotfiles-ai root directory
./install.sh
```

This will:
1. Create symlinks to `~/.config/nvim/`
2. Install lazy.nvim plugin manager on first Neovim launch
3. Automatically download and configure all plugins
4. Set up LSP servers through Mason

## Adding Language Support

To add support for additional programming languages:

1. **Edit the servers table** in `init.lua`:
```lua
local servers = {
  lua_ls = { ... },
  -- Add your language servers here:
  pyright = {},      -- Python
  rust_analyzer = {}, -- Rust
  tsserver = {},     -- TypeScript/JavaScript
  gopls = {},        -- Go
  clangd = {},       -- C/C++
}
```

2. **Update Treesitter parsers** in the treesitter config:
```lua
ensure_installed = { 
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
  -- Add your languages:
  'python', 'rust', 'javascript', 'typescript', 'go'
},
```

3. **Restart Neovim** - Mason will automatically install the new language servers

## Customization

### Colorscheme
The default is Tokyo Night. To change it, modify the colorscheme configuration:
```lua
vim.cmd.colorscheme 'your-preferred-theme'
```

### Adding Plugins
Add new plugins to the `require('lazy').setup({})` table:
```lua
{ 'author/plugin-name', opts = {} },
```

### Nerd Font Support
Set `vim.g.have_nerd_font = true` at the top of `init.lua` if you have a Nerd Font installed.

## File Structure

```
nvim/
├── init.lua          # Complete kickstart.nvim configuration
└── README.md         # This documentation
```

## Dependencies

### Required
- **Neovim 0.9+** (kickstart.nvim requirement)
- **Git** (for plugin management)
- **Make** (for some plugin builds)

### Recommended
- **ripgrep** - Much faster grep for Telescope
- **fd** - Faster file finding
- **A Nerd Font** - For icons and better visual experience

### Language-Specific
- **Node.js** - For many LSP servers (tsserver, etc.)
- **Python** - For Python LSP and tools
- **Rust** - For rust-analyzer
- **Go** - For gopls

## Integration with dotfiles-ai

This Neovim configuration integrates seamlessly with other dotfiles-ai components:

- **tmux**: Works perfectly in tmux sessions with proper key bindings
- **zsh**: Shell integration for external tools and commands
- **Git**: Built-in git integration with gitsigns and Telescope
- **Cross-platform**: Consistent behavior on Debian, Linux Mint, and macOS

## Troubleshooting

### Plugin Management
- `:Lazy` - Check plugin status and manage plugins
- `:Lazy update` - Update all plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy profile` - Check plugin loading performance

### LSP Issues
- `:Mason` - Manage LSP servers and tools
- `:LspInfo` - Show active language servers
- `:checkhealth` - Comprehensive health check

### General Debugging
- `:messages` - Show recent messages
- `:verbose` - Get verbose output for commands
- Check the kickstart.nvim documentation for detailed explanations

## Learning Resources

### Built-in Help
- `:help` - Neovim's comprehensive help system
- `:Tutor` - Interactive Neovim tutorial
- `:help kickstart` - Kickstart-specific help

### External Resources
- [kickstart.nvim GitHub](https://github.com/nvim-lua/kickstart.nvim)
- [Neovim Documentation](https://neovim.io/doc/)
- [lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)

## Philosophy

This configuration follows kickstart.nvim's philosophy:
- **Readable and educational**: Every line is documented
- **Minimal but complete**: Essential features without overwhelming complexity
- **Extensible**: Easy to add your own customizations
- **Modern**: Uses current Neovim best practices

The goal is to provide a solid foundation that you can understand, modify, and extend as your needs grow.
