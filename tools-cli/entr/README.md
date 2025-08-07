# entr - File Watcher and Command Runner

Run commands when files change. Perfect for development workflows, automated testing, and continuous builds.

## Installation

```bash
./tools-cli/entr/setup.sh
```

## What Gets Installed

### Core Tools
- **entr** - Run arbitrary commands when files change
- **fswatch** - Cross-platform file change monitor (if available)
- **watchman** - Facebook's file watching service (macOS)

## Basic Usage

### Simple File Watching
```bash
# Run command when file changes
echo file.txt | entr echo "File changed!"

# Run command with the changed file as argument
echo file.txt | entr cat /_

# Clear screen before running command
echo file.txt | entr -c echo "File changed!"

# Restart long-running process
echo server.js | entr -r node server.js
```

### Multiple Files
```bash
# Watch multiple specific files
ls *.js | entr npm test

# Watch files recursively with find
find . -name '*.py' | entr python main.py

# Watch all source files
find src -name '*.js' -o -name '*.css' | entr make build
```

## entr Options

### Key Flags
- `-c` - Clear screen before running command
- `-r` - Restart process if it's still running
- `-p` - Postpone first execution until file change
- `-d` - Track directories and exit if new files added
- `-n` - Non-interactive mode (disable TTY)
- `-s` - Use shell to evaluate command

### Special Variables
- `/_` - Replaced with the changed file's path
- `$ENTR_PID` - PID of the running subprocess

## Common Workflows

### Development Server
```bash
# Auto-restart Node.js server
find . -name '*.js' | entr -r node server.js

# Auto-restart Python Flask app
find . -name '*.py' | entr -r python app.py

# Auto-restart Go application
find . -name '*.go' | entr -r go run .
```

### Testing
```bash
# Run tests on file change
find . -name '*.test.js' | entr -c npm test

# Run specific test file that changed
find . -name '*.test.py' | entr -c pytest /_

# Run test suite with coverage
find src test -name '*.js' | entr -c npm run test:coverage
```

### Building
```bash
# Rebuild on source change
find src -name '*.ts' | entr -c npm run build

# Compile Sass/SCSS
find . -name '*.scss' | entr -c sass styles.scss styles.css

# Webpack watch alternative
find src -name '*.js' -o -name '*.jsx' | entr -c webpack
```

### Documentation
```bash
# Regenerate docs
find . -name '*.md' | entr -c mkdocs build

# Update README table of contents
echo README.md | entr -c doctoc README.md
```

## Configured Aliases and Functions

### Basic Watches
- `watch-run <pattern> <command>` - Watch files matching pattern
- `watch-test [pattern]` - Watch and run tests
- `watch-build` - Watch and rebuild project
- `watch-make [target]` - Watch and run make

### Language-Specific
- `watch-python [script]` - Watch Python files
- `watch-node [script]` - Watch Node.js files
- `watch-go [path]` - Watch Go files
- `watch-rust` - Watch Rust files and cargo run
- `watch-typescript` - Watch and compile TypeScript

### Web Development
- `watch-sass <input> [output]` - Compile Sass/SCSS
- `watch-eslint` - Watch and lint JavaScript
- `watch-prettier` - Watch and format code
- `watch-reload [pattern]` - Browser auto-reload

### Testing
- `watch-pytest [args]` - Watch and run pytest
- `watch-rspec [args]` - Watch and run RSpec
- `watch-cargo [command]` - Watch and run cargo

### Docker
- `watch-docker [image]` - Rebuild Docker image
- `watch-compose` - Restart docker-compose

### Utilities
- `watch-git` - Show git status on changes
- `watch-sync <remote>` - Sync to remote on changes
- `watch-notify <pattern> [message]` - Desktop notifications

### Advanced
- `watch-chain <pattern> <cmd1> <cmd2>...` - Run multiple commands
- `watch-debounce <delay> <pattern> <command>` - Debounced execution
- `watch-menu` - Interactive watch mode selector

## Advanced Examples

### Complex Build Pipeline
```bash
# Run multiple commands in sequence
find src -name '*.js' | entr -c sh -c 'npm run lint && npm test && npm run build'

# Parallel watchers
find . -name '*.js' | entr -c npm run build:js &
find . -name '*.scss' | entr -c npm run build:css &
wait
```

### Conditional Execution
```bash
# Only rebuild if tests pass
find . -name '*.js' | entr -c sh -c 'npm test && npm run build'

# Different commands for different files
find . -name '*' | entr -c sh -c '
  case "$1" in
    *.js) npm run lint "$1" ;;
    *.test.js) npm test "$1" ;;
    *.scss) sass "$1" "${1%.scss}.css" ;;
  esac
' _ /_
```

### Database Migrations
```bash
# Auto-run migrations
find migrations -name '*.sql' | entr -p sh -c 'diesel migration run'

# Reload fixtures
find fixtures -name '*.json' | entr -c python manage.py loaddata /_
```

### Live Reloading
```bash
# With browser-sync
find . -name '*.html' -o -name '*.css' -o -name '*.js' | \
  entr -c browser-sync reload

# With custom notification
find . -name '*.js' | entr -c sh -c '
  npm run build && \
  terminal-notifier -message "Build complete!"
'
```

### Continuous Integration
```bash
# Local CI pipeline
find . -type f -not -path './\.*' | entr -c sh -c '
  echo "Running CI pipeline..."
  npm run lint || exit 1
  npm test || exit 1
  npm run build || exit 1
  echo "✅ All checks passed!"
'
```

## Integration with Git

### Watch Tracked Files
```bash
# Only watch git-tracked files
git ls-files | entr -c make test

# Watch modified files
git diff --name-only | entr -c npm test

# Watch files in current branch
git diff --name-only main...HEAD | entr -c npm run build
```

### Pre-commit Simulation
```bash
# Run pre-commit checks on file change
find . -name '*.js' | entr -c sh -c '
  npm run prettier:check &&
  npm run lint &&
  npm test
'
```

## Performance Tips

### Limiting File Scope
```bash
# Exclude directories
find . -path ./node_modules -prune -o -name '*.js' -print | entr make

# Limit depth
find . -maxdepth 2 -name '*.py' | entr python main.py

# Use specific directories
find src test -name '*.js' | entr npm test
```

### Handling Many Files
```bash
# Use xargs for very long file lists
find . -name '*.js' -print0 | xargs -0 ls | entr make

# Monitor directory for new files
while true; do
  find . -name '*.js' | entr -d make
done
```

## Troubleshooting

### Process Won't Restart
```bash
# Use -r flag for automatic restart
find . -name '*.js' | entr -r node server.js

# Kill existing process first
pkill -f "node server.js"
find . -name '*.js' | entr -r node server.js
```

### Too Many Open Files
```bash
# Increase file descriptor limit
ulimit -n 4096

# Watch fewer files
find src -name '*.js' | entr make  # Instead of find . -name '*.js'
```

### New Files Not Detected
```bash
# Use -d flag and restart entr
while true; do
  find . -name '*.js' | entr -d npm test
done

# Or use a different tool like watchman
watchman-wait . --pattern '**/*.js' | xargs -I {} npm test
```

### Command Not Running
```bash
# Check if files are actually changing
find . -name '*.js' | entr -c sh -c 'date; npm test'

# Verify find output
find . -name '*.js'  # Should list files

# Use absolute paths
find $(pwd) -name '*.js' | entr npm test
```

## Example Scripts

Example scripts are available in `~/.config/entr/examples/`:
- `dev-workflow.sh` - Complete development workflow
- `ci-watcher.sh` - Continuous integration pipeline
- `doc-watcher.sh` - Documentation generator
- `migration-watcher.sh` - Database migration watcher
- `polyglot-watcher.sh` - Multi-language project watcher

## Tips

1. **Use -c flag** - Clear screen for better visibility
2. **Use -r for servers** - Auto-restart long-running processes
3. **Limit file scope** - Watch only necessary files
4. **Exclude build dirs** - Avoid watching generated files
5. **Use find efficiently** - Prune unnecessary paths
6. **Chain commands** - Use && for dependent tasks
7. **Handle errors** - Use || exit 1 to stop on failure
8. **Add notifications** - Use terminal-notifier or notify-send
9. **Create aliases** - For frequently used patterns
10. **Combine tools** - Use with make, npm scripts, etc.

## Alternatives Comparison

| Tool | Pros | Cons |
|------|------|------|
| entr | Simple, lightweight, Unix philosophy | No built-in directory watching |
| watchman | Powerful, efficient, handles large trees | Complex setup, Facebook specific |
| fswatch | Cross-platform, multiple backends | More resource intensive |
| inotify-tools | Linux native, efficient | Linux only, low-level |
| nodemon | Node.js specific, feature-rich | Only for Node.js |
| webpack-dev-server | Hot reload, bundling | Webpack specific |