# fd - A Simple, Fast Alternative to Find

A simple, fast and user-friendly alternative to the Unix `find` command.

## Installation

```bash
./tools-cli/fd/setup.sh
```

## Features

- **Intuitive syntax** - `fd PATTERN` instead of `find -iname '*PATTERN*'`
- **Smart defaults** - Ignores hidden files and .gitignore by default
- **Fast** - Often faster than find due to parallelism
- **Colorized output** - Different colors for different file types
- **Regular expressions** - Powerful pattern matching by default

## Common Usage

### Basic search
```bash
fd pattern           # Find files/dirs matching pattern
fd README           # Find all READMEs
```

### File type filtering
```bash
fd -t f pattern     # Files only
fd -t d pattern     # Directories only
fd -t l pattern     # Symlinks only
fd -t x pattern     # Executable files
```

### Extension filtering
```bash
fd -e txt           # All .txt files
fd -e js -e ts      # All .js and .ts files
fd pattern -e md    # Pattern in .md files only
```

### Hidden and ignored files
```bash
fd -H pattern       # Include hidden files
fd -I pattern       # Don't respect .gitignore
fd -HI pattern      # Both hidden and ignored
```

### Search in specific directory
```bash
fd pattern /path/to/dir
fd pattern . --max-depth 2
```

### Size filtering
```bash
fd --size +1M       # Files larger than 1MB
fd --size -100k     # Files smaller than 100KB
fd --size 50k       # Files exactly 50KB
```

### Time filtering
```bash
fd --changed-within 1d     # Changed in last day
fd --changed-before 2w     # Changed before 2 weeks ago
fd --newer file.txt        # Newer than file.txt
```

## Configured Aliases

- `fdd` - Directories only
- `fdf` - Files only
- `fdh` - Include hidden files
- `fde` - Search by extension
- `fdi` - Case insensitive
- `fdx` - Executable files
- `fds` - Filter by size

## Integration Examples

### With fzf
```bash
# Interactive file selection
fd --type f | fzf

# Interactive directory navigation
cd $(fd --type d | fzf)
```

### With xargs
```bash
# Delete all .tmp files
fd -e tmp -X rm

# Run command on each result
fd pattern -x echo "Found: {}"
```

### Find and edit
```bash
# Open all Python files in editor
nvim $(fd -e py)

# Open files containing TODO
nvim $(fd -x grep -l TODO {} \;)
```

### Batch operations
```bash
# Convert all .png to .jpg
fd -e png -x convert {} {.}.jpg

# Rename all .txt to .md
fd -e txt -x mv {} {.}.md
```

## Comparison with find

| Task | find | fd |
|------|------|-----|
| Find by name | `find . -name "*.txt"` | `fd -e txt` |
| Case insensitive | `find . -iname "*readme*"` | `fd -i readme` |
| Directories only | `find . -type d` | `fd -t d` |
| Modified recently | `find . -mtime -7` | `fd --changed-within 1w` |
| Execute command | `find . -exec cmd {} \;` | `fd -x cmd` |

## Tips

1. Use `-e` for extension instead of glob patterns
2. Use `-x` or `-X` for command execution
3. Use `--max-depth` to limit recursion
4. Combine with other tools via pipes
5. Use `--base-directory` to change output paths