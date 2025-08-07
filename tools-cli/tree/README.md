# Tree - Directory Structure Visualizer

A command-line tool for displaying directory structures in a tree-like format.

## Installation

```bash
./tools-cli/tree/setup.sh
```

## Features

- Visual directory structure display
- Configurable depth limits
- File size display
- Pattern filtering
- Git-aware (can respect .gitignore)
- Color output support

## Common Usage

### Basic tree view
```bash
tree
```

### Limit depth
```bash
tree -L 2  # Show only 2 levels deep
```

### Directories only
```bash
tree -d
```

### Show hidden files
```bash
tree -a
```

### Show file sizes
```bash
tree -h  # Human-readable sizes
tree -s  # Raw sizes in bytes
```

### Ignore patterns
```bash
tree -I 'node_modules|*.pyc|__pycache__'
tree --gitignore  # Respect .gitignore file
```

### Output to file
```bash
tree > project-structure.txt
tree --charset ascii  # ASCII characters only (better for docs)
```

## Configured Aliases

After installation, these aliases are available:

- `t` - tree
- `t1` - tree -L 1 (one level)
- `t2` - tree -L 2 (two levels)
- `t3` - tree -L 3 (three levels)
- `ta` - tree -a (show all/hidden)
- `td` - tree -d (directories only)
- `tf` - tree -f (full paths)
- `tg` - tree --gitignore
- `ts` - tree -h (with sizes)
- `tds` - tree -d -h (dirs with sizes)

## Advanced Examples

### Project documentation
```bash
# Create a project structure for README
tree -L 3 --charset ascii -I 'node_modules|.git' > structure.txt
```

### Find large directories
```bash
tree -d -h --du | grep -E '[0-9]+M|[0-9]+G'
```

### Count files by type
```bash
tree -f | grep '\.js$' | wc -l  # Count JavaScript files
```

### Export as JSON
```bash
tree -J > structure.json
```

### Export as HTML
```bash
tree -H . > structure.html
```

## Tips

1. Use `-L` to limit depth for large projects
2. Use `-I` to ignore common build/dependency directories
3. Use `--gitignore` in git repositories
4. Pipe to `less` for large outputs: `tree | less`
5. Use `-C` for colorized output (usually default)
6. Use `--dirsfirst` to list directories before files