# eza - Modern Replacement for ls

A modern, maintained replacement for ls with colors, icons, and Git integration.

## Installation

```bash
./tools-cli/eza/setup.sh
```

## Features

- **Color coding** - Different colors for different file types
- **Icons** - File type icons (requires Nerd Font)
- **Git integration** - Shows git status for files
- **Tree view** - Built-in tree functionality
- **Extended attributes** - Show permissions, size, dates
- **Hyperlinks** - Clickable links in supported terminals

## Common Usage

### Basic listing
```bash
eza                 # Basic listing
eza -l              # Long format
eza -la             # Long format with hidden files
eza -1              # One file per line
```

### Long format options
```bash
eza -l              # Long listing
eza -lh             # Human-readable sizes
eza -lah            # All files, human sizes
eza -laH            # Follow symlinks
eza -la --no-user   # Hide user column
eza -la --no-time   # Hide time column
```

### Sorting
```bash
eza --sort=name     # By name (default)
eza --sort=size     # By size
eza --sort=modified # By modification time
eza --sort=accessed # By access time
eza --sort=created  # By creation time
eza --sort=type     # By file type
eza --sort=extension # By extension
eza -r              # Reverse order
```

### Tree view
```bash
eza --tree          # Tree view
eza -T              # Short for --tree
eza -T -L 2         # Tree with depth 2
eza -Ta             # Tree with hidden files
```

### Git integration
```bash
eza -l --git        # Show git status
eza -l --git-ignore # Hide git-ignored files
eza --git-repos     # Show git repo status
```

### Filtering
```bash
eza -d */           # Directories only
eza -f              # Files only
eza -D              # Directories only (alt)
eza -F              # Add indicators (/ for dirs)
```

### Icons and colors
```bash
eza --icons         # Show icons
eza --no-icons      # Hide icons
eza --color=always  # Force colors
eza --color=never   # No colors
```

### Extended information
```bash
eza -l@             # Extended attributes
eza -lZ             # SELinux context
eza -lb             # Binary sizes (bytes)
eza -lB             # Binary sizes (KiB, MiB)
eza -lm             # Modified time
eza -lu             # Accessed time
eza -lU             # Created time
```

## Configured Aliases

- `ls` - eza with icons and directories first
- `ll` - Long format with icons
- `la` - All files, long format
- `lt` - Tree view
- `l` - All files, long format (alt)
- `ld` - Directories only
- `lf` - Files only
- `lh` - Hidden files only
- `lz` - Sort by size
- `lg` - Show git status
- `ltg` - Tree respecting .gitignore

## Advanced Examples

### Custom formats
```bash
# Only names and sizes
eza -l --no-permissions --no-user --no-time

# Grid with icons
eza --icons --grid

# Detailed with headers
eza -lah --header
```

### Recursive operations
```bash
# Recursive listing
eza -R

# Recursive tree (careful!)
eza -T --git-ignore

# Find all .js files
eza -R | grep '\.js$'
```

### With other tools
```bash
# Count files by type
eza -1 | awk -F. '{print $NF}' | sort | uniq -c

# Total size of directory
eza -lb | awk '{sum+=$5} END {print sum}'

# Interactive navigation
eza -la | fzf
```

## Comparison with ls

| Feature | ls | eza |
|---------|----|----|
| Basic listing | ✓ | ✓ |
| Colors | Basic | Rich |
| Icons | ✗ | ✓ |
| Git status | ✗ | ✓ |
| Tree view | ✗ | ✓ |
| Hyperlinks | ✗ | ✓ |
| Human dates | ✗ | ✓ |

## Color Codes

- **Blue** - Directories
- **Green** - Executable files
- **Yellow** - Device files
- **Cyan** - Symlinks
- **Red** - Broken symlinks
- **Purple** - Images/media
- **White** - Regular files

## Tips

1. Use `--group-directories-first` to list dirs first
2. Combine `-la` for most detailed view
3. Use `--git` to see file changes
4. Use tree view instead of separate tree command
5. Set `EZA_COLORS` environment variable for custom colors