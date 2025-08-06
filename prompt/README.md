# Shell Prompt Configuration

This directory contains the shell prompt configuration for a beautiful, fast, and customizable prompt. Currently using Starship prompt.

## Features

- **Tokyo Night Theme**: Custom colors matching the overall dotfiles theme
- **Git Integration**: Shows branch, commit hash, and status
- **Language Support**: Displays versions for various programming languages (Rust, Node.js, Python, Go, etc.)
- **Directory Shortcuts**: Custom icons and names for common directories
- **Performance Info**: Shows command duration and exit status
- **Battery Status**: Battery indicator with color-coded levels
- **Time Display**: Current time in the prompt

## Installation

Starship is automatically installed by the setup scripts. The configuration is symlinked to `~/.config/starship.toml`.

## Manual Installation

If you need to install Starship manually:

```bash
# Install Starship
curl -sS https://starship.rs/install.sh | sh

# Add to your shell config (.zshrc, .bashrc, etc.)
eval "$(starship init zsh)"  # for zsh
eval "$(starship init bash)" # for bash
```

## Customization

The prompt format uses Tokyo Night colors:
- Primary: `#7aa2f7` (blue)
- Background: `#3b4261` (dark blue-gray)
- Accent: `#73daca` (cyan)
- Error: `#b2555b` (red)

Modify `starship.toml` to customize the prompt appearance and behavior.

## Directory Substitutions

The prompt includes custom directory substitutions with icons:
- Documents → 📄 Documents
- Desktop → 🖥️ Desktop
- Downloads → 📥 Downloads
- Music → 🎵 Music
- Pictures → 🖼️ Pictures
- Projects → 📁 Projects
- dotfiles → ⚙️ dotfiles

## Language Support

The prompt automatically detects and displays versions for:
- C, Elixir, Elm, Go, Haskell, Java, Julia, Node.js, Nim, Rust
- Docker context when available
