# Installation Flow Architecture

## Clean Architecture

```
dotfiles-ai/
├── install.sh              # Master installer for desktop (cli + gui)
├── install-cli.sh          # CLI-only installer (servers, containers)
├── install-gui.sh          # GUI-only installer
│
├── system/                 # OS-specific base setup (minimal!)
│   ├── debian/
│   │   ├── setup.sh       # apt update, curl, git, build-essential ONLY
│   │   └── keyboard.sh    # System keybindings
│   ├── macos/
│   │   ├── setup.sh       # xcode tools, homebrew ONLY
│   │   └── keyboard.sh    # System keybindings
│   └── mint/
│       ├── setup.sh       # Inherits from debian
│       └── keyboard.sh    # Cinnamon-specific keybindings
│
├── tools-cli/              # CLI tools (self-contained)
│   ├── zsh/
│   │   └── setup.sh       # Installs zsh, oh-my-zsh, symlinks config
│   ├── tmux/
│   │   └── setup.sh       # Installs tmux, symlinks config
│   ├── neovim/
│   │   └── setup.sh       # Installs neovim, symlinks config
│   ├── fzf/
│   │   └── setup.sh       # Installs fzf, symlinks config
│   └── ...
│
├── tools-gui/              # GUI applications
│   ├── browsers/
│   │   └── setup.sh       # Firefox, Chrome, etc.
│   ├── docker/
│   │   └── setup.sh       # Docker Desktop
│   └── ...
│
└── tools-lang/             # Programming languages
    ├── node/
    │   └── setup.sh       # nvm + node
    ├── python/
    │   └── setup.sh       # pyenv/uv + python
    └── ...
```

## Installation Flow

### 1. CLI Installation (`./install-cli.sh`)
```bash
detect_os()
  ↓
system/$OS/setup.sh         # Minimal base packages
  ↓
for tool in tools-cli/*:
    $tool/setup.sh          # Each tool installs itself
  ↓
for lang in tools-lang/*:
    $lang/setup.sh          # Each language installs itself
```

### 2. GUI Installation (`./install-gui.sh`)
```bash
detect_os()
  ↓
for tool in tools-gui/*:
    $tool/setup.sh          # Each GUI app installs itself
```

### 3. Full Installation (`./install.sh`)
```bash
./install-cli.sh
  ↓
./install-gui.sh
  ↓
./post-install.sh          # Configuration wizard
```

## Key Principles

1. **System setup is MINIMAL** - Only essential packages needed by other tools
2. **Each tool is self-contained** - Handles its own installation, dependencies, and config
3. **No duplication** - Each package installed in exactly one place
4. **Clear responsibility** - Easy to understand what each script does
5. **Platform detection happens once** - At the top level, then passed down

## Benefits

- **Easy to debug** - If tmux fails, look at tools-cli/tmux/setup.sh
- **Easy to add tools** - Just create a new directory with setup.sh
- **Easy to skip tools** - Just don't call that setup.sh
- **Easy to test** - Can test individual tools in isolation
- **Claude-friendly** - Clear structure, single responsibility