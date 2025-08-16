# GNU Stow Configuration Management

This document explains how GNU Stow is used in the dotfiles-ai repository for managing configuration symlinks.

## Overview

GNU Stow is a symlink farm manager that helps manage the installation of software packages and configuration files. In this repository, we use Stow to:

1. Create symlinks from the dotfiles repository to your home directory
2. Manage multiple tool configurations without conflicts
3. Easily install/uninstall configurations
4. Keep all configs version-controlled in one place

## Directory Structure for Stow

Each tool directory follows a structure that mirrors the home directory:

```
tools-cli/
├── tmux/
│   ├── .tmux.conf          # Will be symlinked to ~/.tmux.conf
│   ├── install              # Installation script (ignored by stow)
│   └── README.md            # Documentation (ignored by stow)
├── zsh/
│   ├── .zshrc               # Will be symlinked to ~/.zshrc
│   └── install
├── prompt/
│   ├── .config/
│   │   └── starship.toml   # Will be symlinked to ~/.config/starship.toml
│   └── install
└── neovim/
    ├── .config/
    │   └── nvim/            # Will be symlinked to ~/.config/nvim/
    │       ├── init.lua
    │       └── lua/
    └── install
```

## How Stow Works

When you run `stow -t ~ tools-cli/tmux` from the dotfiles directory:

1. Stow looks inside `tools-cli/tmux/`
2. Finds `.tmux.conf`
3. Creates a symlink at `~/.tmux.conf` pointing to `tools-cli/tmux/.tmux.conf`
4. Ignores files listed in `.stow-local-ignore`

## Stow Ignore Files

Each tool directory contains a `.stow-local-ignore` file that tells Stow which files to ignore:

```
# .stow-local-ignore
install
setup.sh
README.md
*.sh
LICENSE
test/
__pycache__/
*.pyc
node_modules/
package.json
package-lock.json
```

## Using Stow Manually

### Install a tool's configs
```bash
cd ~/dotfiles-ai
stow -t ~ tools-cli/tmux
```

### Remove a tool's configs
```bash
cd ~/dotfiles-ai
stow -D -t ~ tools-cli/tmux
```

### Reinstall (update) configs
```bash
cd ~/dotfiles-ai
stow -R -t ~ tools-cli/tmux
```

### Preview what would be done
```bash
cd ~/dotfiles-ai
stow -n -v -t ~ tools-cli/tmux
```

### Handle conflicts

If a file already exists and isn't a symlink:

```bash
# Option 1: Backup existing file
mv ~/.tmux.conf ~/.tmux.conf.backup

# Option 2: Adopt existing file into stow
stow --adopt -t ~ tools-cli/tmux
```

## Automatic Stow Integration

The main installer (`./install`) automatically uses Stow after installing each tool:

1. Installs the tool (binaries, dependencies)
2. Calls `stow_configs()` function to create symlinks
3. Handles conflicts by backing up existing files

## Adding Stow Support to a New Tool

1. **Structure your tool directory** to mirror home:
   ```bash
   tools-cli/newtool/
   ├── .config/
   │   └── newtool/
   │       └── config.toml
   ├── .newtoolrc
   └── install
   ```

2. **Add a `.stow-local-ignore`** file:
   ```bash
   cp tools-cli/.stow-local-ignore tools-cli/newtool/
   ```

3. **Update the install script** to not manually symlink:
   ```bash
   # Don't do this:
   ln -sf "$SCRIPT_DIR/config" "$HOME/.config/newtool/config"
   
   # The main installer will handle it via stow
   ```

## Troubleshooting

### "WARNING: ... conflicts with existing target"
- A non-symlink file exists at the target location
- Solution: Backup or remove the existing file

### Symlinks not created
- Check if Stow is installed: `command -v stow`
- Check for typos in directory structure
- Verify `.stow-local-ignore` isn't excluding needed files

### Wrong symlink location
- Ensure directory structure mirrors home exactly
- Use `.config/` for XDG config directories
- Use dot-prefixed files for home directory configs

### Stow complains about folding
- Stow tries to optimize by "folding" directories
- Use `--no-folding` to prevent this behavior

## Benefits of Using Stow

1. **Clean separation**: Installation logic separate from configuration
2. **Easy rollback**: Just `stow -D` to remove all symlinks
3. **Conflict detection**: Stow warns about existing files
4. **Batch operations**: Can stow/unstow multiple packages at once
5. **Version control friendly**: All configs stay in the repo
6. **No custom scripts**: Stow is a standard tool available everywhere

## Examples

### Install all CLI tool configs
```bash
cd ~/dotfiles-ai/tools-cli
for tool in */; do
    stow -t ~ "$tool"
done
```

### Remove all configs before reinstalling
```bash
cd ~/dotfiles-ai/tools-cli  
for tool in */; do
    stow -D -t ~ "$tool"
done
```

### Check what's currently stowed
```bash
ls -la ~ | grep " -> "
ls -la ~/.config | grep " -> "
```

## See Also

- [GNU Stow Documentation](https://www.gnu.org/software/stow/)
- `man stow` for detailed options
- [Main README](../README.md) for general installation