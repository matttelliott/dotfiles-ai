# Ripgrep - Blazingly Fast Search

A line-oriented search tool that recursively searches directories for a regex pattern.

## Installation

```bash
./tools-cli/ripgrep/setup.sh
```

## Features

- **Blazingly fast** - Built on Rust's regex engine
- **Respects .gitignore** - Automatically skips files in .gitignore
- **Smart defaults** - Skips binary files, hidden files configurable
- **Unicode support** - Full UTF-8 support
- **Parallel search** - Uses multiple threads for speed

## Common Usage

### Basic search
```bash
rg "pattern"                 # Search for pattern
rg "TODO"                    # Find all TODOs
```

### Case sensitivity
```bash
rg -i "pattern"              # Case insensitive
rg -s "Pattern"              # Case sensitive (force)
rg -S "Pattern"              # Smart case (default)
```

### File type filtering
```bash
rg --type py "import"        # Search only Python files
rg --type js "console.log"   # Search only JavaScript
rg --type-not md "TODO"      # Exclude markdown files
rg --type-list               # List all available types
```

### Search specific files/directories
```bash
rg "pattern" src/            # Search in src directory
rg "pattern" *.js            # Search in .js files
rg "pattern" -g "*.{js,ts}"  # Search js and ts files
```

### Display options
```bash
rg -l "pattern"              # Files with matches only
rg -c "pattern"              # Count matches per file
rg --files                   # List all files that would be searched
rg -v "pattern"              # Invert match (lines without pattern)
```

### Context lines
```bash
rg -A 2 "pattern"            # 2 lines after match
rg -B 2 "pattern"            # 2 lines before match
rg -C 2 "pattern"            # 2 lines before and after
```

### Advanced patterns
```bash
rg -w "word"                 # Whole word matching
rg -F "literal.string"       # Fixed string (no regex)
rg "^import"                 # Lines starting with import
rg "TODO|FIXME|XXX"          # Multiple patterns
```

### Ignoring files
```bash
rg --no-ignore "pattern"     # Don't respect .gitignore
rg --hidden "pattern"        # Search hidden files
rg -u "pattern"              # Unrestricted (hidden + ignored)
rg -uu "pattern"             # Also search binary files
rg -uuu "pattern"            # Don't respect any ignore files
```

## Configuration

Ripgrep uses `~/.ripgreprc` for default options:

```bash
# Always search hidden files
--hidden

# Exclude directories
--glob=!.git/
--glob=!node_modules/
--glob=!target/

# Set colors
--colors=match:fg:red
--colors=path:fg:green

# Add custom types
--type-add=web:*.{html,css,js,jsx,ts,tsx}
```

## Aliases Configured

- `rgi` - Case insensitive search
- `rgf` - Fixed string search (literal)
- `rgl` - List files with matches
- `rgc` - Count matches
- `rgn` - No ignore (search ignored files)
- `rgh` - Search hidden files
- `rgw` - Whole word matching

## Integration Examples

### With fzf
```bash
# Interactive file search
rg --files | fzf

# Search content and preview
rg "pattern" --files-with-matches | fzf --preview 'rg --color always "pattern" {}'
```

### Replace with sed
```bash
rg -l "old_pattern" | xargs sed -i 's/old_pattern/new_pattern/g'
```

### Find and edit
```bash
nvim $(rg -l "pattern")      # Open all files with matches
```

### Statistics
```bash
rg -c "TODO" | awk -F: '{sum+=$2} END {print sum}'  # Total TODO count
```

## Performance Tips

1. Use `--type` to limit file types
2. Use `-g` glob patterns to limit paths
3. Use `--max-depth` for shallow searches
4. Use `--threads` to control parallelism
5. Create `.rgignore` files for project-specific ignores