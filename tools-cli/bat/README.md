# bat - Cat Clone with Syntax Highlighting

A cat clone with syntax highlighting, Git integration, and automatic paging.

## Installation

```bash
./tools-cli/bat/setup.sh
```

## Features

- **Syntax highlighting** - Automatic language detection
- **Git integration** - Shows git modifications in the gutter
- **Line numbers** - Optional line numbering
- **Automatic paging** - Pipes to less for long files
- **Multiple files** - Concatenate with proper headers
- **Theme support** - Multiple color themes available

## Common Usage

### Basic viewing
```bash
bat file.txt              # View with syntax highlighting
bat src/main.rs          # Automatic language detection
```

### Multiple files
```bash
bat file1.txt file2.txt   # Show both with headers
bat *.py                  # All Python files
```

### Plain output (no decorations)
```bash
bat -p file.txt           # Plain, no line numbers
bat -pp file.txt          # Extra plain, no paging
```

### Line numbers and ranges
```bash
bat -n file.txt           # Force line numbers
bat -r 10:20 file.txt     # Lines 10-20 only
bat -r :50 file.txt       # First 50 lines
bat -r 100: file.txt      # From line 100 onwards
```

### Language specification
```bash
bat -l rust file          # Force Rust syntax
bat -l json data.txt      # Treat as JSON
bat -l man README         # Man page formatting
```

### Style options
```bash
bat --style=numbers file.txt       # Only line numbers
bat --style=changes file.txt       # Only git changes
bat --style=header file.txt        # Only file header
bat --style=grid file.txt          # Grid borders
bat --style=full file.txt          # Everything (default)
bat --style=plain file.txt         # Nothing
```

### Themes
```bash
bat --list-themes         # List all themes
bat --theme=TwoDark file  # Use specific theme
```

## Configured Aliases

- `cat` - Replaced with bat
- `catp` - Plain output (no line numbers)
- `catl` - Specify language
- `catn` - Numbers only style
- `batdiff` - Show diff highlighting
- `batman` - Format man pages
- `batf` - bat + fzf integration

## Integration Examples

### As man pager
```bash
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
man ls  # Now with syntax highlighting!
```

### With git
```bash
# Colored diff
git diff | bat --language=diff

# Show file at specific commit
git show HEAD~2:file.txt | bat -l txt
```

### With find/fd
```bash
# View all Python files
fd -e py -x bat {}

# Preview files interactively
fd --type f | fzf --preview 'bat --color=always {}'
```

### With grep/ripgrep
```bash
# Show matches with context
rg pattern -A 2 -B 2 --color=never | bat --language=txt

# Highlight search term
bat file.txt | grep --color=always pattern
```

### As a code reviewer
```bash
# Compare two files
bat --diff file.old file.new

# Show with specific highlighting
bat --highlight-line=42 file.txt
```

## Configuration

bat uses `~/.config/bat/config` for defaults:

```bash
# Set default theme
--theme="TwoDark"

# Set default style
--style="numbers,changes,header"

# Map file types
--map-syntax "*.ino:C++"
--map-syntax ".prettierrc:JSON"
```

## Comparison with cat

| Feature | cat | bat |
|---------|-----|-----|
| Basic output | ✓ | ✓ |
| Syntax highlighting | ✗ | ✓ |
| Line numbers | ✗ | ✓ |
| Git integration | ✗ | ✓ |
| Automatic paging | ✗ | ✓ |
| Themes | ✗ | ✓ |

## Tips

1. Use `-p` for scripts that expect plain output
2. Use `--paging=never` to disable paging
3. Set `BAT_PAGER` to customize pager
4. Use `--wrap` to control line wrapping
5. Combine with other tools via pipes