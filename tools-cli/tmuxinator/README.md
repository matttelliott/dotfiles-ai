# Tmuxinator - Tmux Session Manager

Manage complex tmux sessions with YAML configuration files. Perfect for maintaining consistent development environments.

## Installation

```bash
./tools-cli/tmuxinator/setup.sh
```

**Prerequisites:**
- tmux must be installed
- Ruby must be installed (via rbenv or system Ruby)

## What is Tmuxinator?

Tmuxinator allows you to:
- Define tmux sessions in YAML files
- Start complex multi-window/pane layouts with one command
- Maintain consistent development environments
- Share session configurations with team members
- Quickly switch between projects

## Basic Usage

### Creating Projects
```bash
# Create new project
tmuxinator new myproject
mux new myproject        # Using alias

# Copy existing project
tmuxinator copy existing new
mux copy existing new
```

### Managing Projects
```bash
# Start project
tmuxinator start myproject
mux start myproject
muxs myproject

# Stop project
tmuxinator stop myproject
muxst myproject

# List all projects
tmuxinator list
muxl

# Edit project
tmuxinator edit myproject
muxe myproject

# Delete project
tmuxinator delete myproject
muxd myproject
```

### Other Commands
```bash
# Check configuration
tmuxinator doctor
muxdoc

# Debug project
tmuxinator debug myproject

# Show version
tmuxinator version
muxv
```

## Configuration Format

### Basic Structure
```yaml
# ~/.config/tmuxinator/myproject.yml
name: myproject
root: ~/Projects/myproject

windows:
  - editor: vim
  - server: npm start
  - logs: tail -f logs/app.log
```

### Advanced Configuration
```yaml
name: myproject
root: ~/Projects/myproject

# Optional: Run before creating session
pre: docker-compose up -d

# Optional: Run before creating windows
pre_window: source venv/bin/activate

# Optional: Attach to session on start
attach: false

# Optional: Start on specific window
startup_window: editor

# Optional: Start on specific pane
startup_pane: 1

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server:
      layout: even-horizontal
      panes:
        - npm start
        - npm run watch
  - console: rails console
  - logs:
      layout: even-horizontal
      panes:
        - tail -f log/development.log
        - tail -f log/test.log
```

## Layouts

### Available Layouts
- `even-horizontal` - Panes split evenly horizontally
- `even-vertical` - Panes split evenly vertically
- `main-horizontal` - Large pane on top, others below
- `main-vertical` - Large pane on left, others on right
- `tiled` - Panes in a grid

### Custom Layouts
```yaml
windows:
  - custom:
      layout: "bb7b,208x58,0,0{104x58,0,0,0,103x58,105,0[103x29,105,0,1,103x28,105,30,2]}"
      panes:
        - vim
        - top
        - logs
```

Get custom layout string:
1. Arrange tmux panes manually
2. Run: `tmux list-windows`
3. Copy the layout string

## Configured Aliases

### Short Commands
- `mux` - tmuxinator
- `muxn` - new project
- `muxo` - open project
- `muxs` - start project
- `muxst` - stop project
- `muxe` - edit project
- `muxc` - copy project
- `muxd` - delete project
- `muxl` - list projects
- `muxi` - implode (delete all)
- `muxv` - version
- `muxdoc` - doctor

### Helper Functions
- `mux-create <name>` - Create with guided setup
- `mux-start <name>` - Start or list projects
- `mux-edit <name>` - Edit or list projects
- `mux-delete <name>` - Delete with confirmation
- `mux-debug <name>` - Debug configuration
- `dev-session` - Start development session
- `work-session` - Start work session

## Project Templates

### Development Project
```yaml
# ~/.config/tmuxinator/dev.yml
name: dev
root: ~/Projects

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server: bundle exec rails s
  - logs: tail -f log/development.log
  - console: rails c
  - git:
      layout: main-horizontal
      panes:
        - git status
        - tig
```

### Full Stack Project
```yaml
# ~/.config/tmuxinator/fullstack.yml
name: fullstack
root: <%= ENV["PWD"] %>

windows:
  - frontend:
      layout: main-horizontal
      panes:
        - npm run dev
        - npm run test:watch
  - backend:
      layout: main-horizontal
      panes:
        - npm run server
        - npm run test:backend
  - database:
      panes:
        - psql mydb
  - docker:
      panes:
        - docker-compose logs -f
  - git:
      panes:
        - lazygit
```

### Python Project
```yaml
# ~/.config/tmuxinator/python.yml
name: python
root: <%= ENV["PWD"] %>
pre_window: source venv/bin/activate

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim
        - ipython
  - server:
      panes:
        - python app.py
  - tests:
      panes:
        - pytest --watch
  - shell:
      panes:
        - # Empty shell
```

### Go Project
```yaml
# ~/.config/tmuxinator/go.yml
name: go
root: <%= ENV["PWD"] %>

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim
        - # Shell
  - tests:
      panes:
        - go test -v ./...
  - build:
      panes:
        - air # Auto-reload
  - debug:
      panes:
        - # Delve debugger
```

### Data Science Project
```yaml
# ~/.config/tmuxinator/datascience.yml
name: datascience
root: <%= ENV["PWD"] %>
pre_window: conda activate myenv

windows:
  - jupyter:
      panes:
        - jupyter lab
  - editor:
      layout: main-vertical
      panes:
        - nvim
        - ipython
  - tensorboard:
      panes:
        - tensorboard --logdir logs
  - data:
      panes:
        - # Data exploration
```

## Hooks and Commands

### Project Lifecycle Hooks
```yaml
# Run when project starts (first time)
on_project_first_start: docker-compose up -d

# Run when project starts
on_project_start: echo "Starting project"

# Run when project stops
on_project_stop: docker-compose down

# Run when project exits
on_project_exit: echo "Exiting project"

# Run when project restarts
on_project_restart: echo "Restarting project"
```

### Window/Pane Hooks
```yaml
# Run before creating each window
pre_window: rbenv shell 3.0.0

# Run in specific window
windows:
  - server:
      pre: 
        - cd backend
        - npm install
      panes:
        - npm start
```

## Variables and ERB

### Using Variables
```yaml
name: <%= ENV["USER"] %>_project
root: <%= ENV["PWD"] %>

windows:
  - editor: vim <%= ENV["FILE"] || "." %>
```

### Dynamic Configuration
```yaml
name: project
root: ~/Projects/<%= @args[0] %>

windows:
  - editor: vim <%= @args[1] || "." %>
```

Usage:
```bash
tmuxinator start project myapp main.go
```

## Tips and Tricks

### 1. Quick Project Creation
```bash
# Create from template
mux new myproject --template=python

# Create in current directory
mux new myproject --root=.
```

### 2. Project Switching
```bash
# Stop current and start new
mux stop current && mux start new

# Or create a function
switch-project() {
    tmux kill-session -t $(tmux display-message -p '#S')
    mux start "$1"
}
```

### 3. Temporary Sessions
```bash
# One-time session (not saved)
mux start myproject --no-config
```

### 4. Debugging Issues
```bash
# Check configuration
mux doctor

# Debug specific project
mux debug myproject

# See generated tmux commands
mux debug myproject | less
```

### 5. Sharing Configurations
```bash
# Export project
cp ~/.config/tmuxinator/myproject.yml ./

# Import project
cp myproject.yml ~/.config/tmuxinator/

# Version control
cd ~/.config/tmuxinator
git init
git add .
git commit -m "Tmuxinator configs"
```

## Integration with tmux

### Tmux Configuration
Add to `~/.tmux.conf`:
```bash
# Allow tmuxinator to create windows
set-option -g base-index 1
set-window-option -g pane-base-index 1

# Renumber windows on close
set-option -g renumber-windows on
```

### Custom Key Bindings
```bash
# Quick session switching
bind-key S command-prompt -p "Session:" "run-shell 'tmuxinator start %%'"
```

## Troubleshooting

### Project Not Starting
```bash
# Check for errors
mux doctor

# Check YAML syntax
ruby -ryaml -e "YAML.load_file('$HOME/.config/tmuxinator/myproject.yml')"

# Check tmux is running
tmux ls
```

### Commands Not Running
- Ensure `$EDITOR` is set
- Check shell compatibility
- Verify command paths
- Check pre/pre_window commands

### Layout Issues
- Use standard layouts first
- Test custom layouts in tmux directly
- Ensure enough terminal space

## Best Practices

1. **Use version control** for configurations
2. **Create templates** for common project types
3. **Use environment variables** for flexibility
4. **Document complex configurations**
5. **Test configurations** with `debug` command
6. **Keep projects organized** by type/client
7. **Use meaningful names** for projects
8. **Clean up old projects** regularly
9. **Share team configurations** in repos
10. **Backup configurations** regularly