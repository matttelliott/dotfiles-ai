# Tool Organization

## Directory Structure

```
dotfiles-ai/
├── tools-cli/           # Command-line tools
│   ├── fzf/            # Fuzzy finder
│   ├── jq/             # JSON processor  
│   ├── ripgrep/        # Fast grep
│   ├── tmux/           # Terminal multiplexer
│   ├── zsh/            # Z shell
│   └── neovim/         # Text editor
│
├── tools-gui/           # GUI applications
│   ├── browsers/       # Firefox, Chrome, etc.
│   ├── docker/         # Docker Desktop
│   ├── dbeaver/        # Database client
│   └── 1password/      # Password manager
│
├── tools-lang/          # Programming languages & version managers
│   ├── node/           # Node.js (via nvm)
│   ├── python/         # Python (via pyenv/uv)
│   ├── rust/           # Rust (via rustup)
│   ├── go/             # Go
│   ├── ruby/           # Ruby (via rbenv)
│   └── java/           # Java (via sdkman)
│
├── install-cli.sh       # Calls tools-cli/*/setup.sh
├── install-gui.sh       # Calls tools-gui/*/setup.sh  
└── install.sh          # Master installer (cli + gui)
```

## Tool Structure Pattern

Each tool directory contains:
```
tool-name/
├── setup.sh            # Installation script (handles all platforms)
├── config/             # Configuration files (if any)
│   └── tool.conf       # Main config file
├── README.md           # Tool documentation
└── uninstall.sh        # Optional removal script
```

## Key Principles

1. **Single Setup Script**: Each `setup.sh` handles platform differences internally
2. **Config Symlinks**: Configs live in the repo and are symlinked to target locations
3. **Idempotent**: Scripts check if already installed before installing
4. **Self-Contained**: Each tool manages its own dependencies

## Example: fzf Structure

```
tools-cli/fzf/
├── setup.sh            # Installs fzf, creates symlinks
├── config/
│   ├── fzf.zsh        # Shell integration
│   └── fzf.bash       # Bash integration  
└── README.md          # Usage documentation
```

The `setup.sh` will:
1. Detect the platform (macOS/Linux)
2. Install fzf via appropriate method
3. Symlink configs: `ln -sf $PWD/config/fzf.zsh ~/.fzf.zsh`
4. Add source line to shell rc file

## Installation Flow

```bash
# CLI tools only (for servers/containers)
./install-cli.sh
  → for tool in tools-cli/*; do
      $tool/setup.sh
    done

# GUI tools only  
./install-gui.sh
  → for tool in tools-gui/*; do
      $tool/setup.sh
    done

# Everything (desktop)
./install.sh
  → ./install-cli.sh
  → ./install-gui.sh
```