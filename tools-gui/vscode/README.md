# Visual Studio Code Setup

Automated installation and configuration of Visual Studio Code with essential extensions for development.

## Installation

```bash
./tools-gui/vscode/setup.sh
```

## What Gets Installed

### Core Application
- **Visual Studio Code** - Microsoft's modern code editor
- **code** command-line tool for launching VS Code from terminal

### Essential Extensions

#### Language Support
- **Python** - Python language support with IntelliSense
- **Go** - Rich Go language support
- **Rust Analyzer** - Rust language server
- **Ruby** - Ruby language support
- **Node.js** - JavaScript and TypeScript support (built-in)

#### Development Tools
- **GitLens** - Git supercharged
- **GitHub Copilot** - AI pair programming
- **Docker** - Docker support for VS Code
- **Remote Development** - SSH, Containers, and WSL
- **Live Share** - Real-time collaborative editing
- **Thunder Client** - REST API client

#### Code Quality
- **ESLint** - JavaScript linting
- **Prettier** - Code formatter
- **EditorConfig** - Maintain consistent coding styles

#### Themes and UI
- **Tokyo Night** - Popular dark theme
- **Material Icon Theme** - Beautiful file icons
- **Bracket Pair Colorizer** - Colorize matching brackets

#### Productivity
- **Project Manager** - Easily switch between projects
- **Todo Tree** - Show TODO, FIXME comments in tree view
- **Code Spell Checker** - Spell checking for code and comments

## Basic Usage

### Command Line

```bash
# Open VS Code in current directory
code .

# Open specific file
code file.txt

# Open multiple files
code file1.txt file2.txt

# Open file at specific line
code file.txt:10

# Open file at specific line and column
code file.txt:10:5

# Create new file
code newfile.txt

# Open with new window
code -n .

# Open with reused window
code -r .

# Compare two files
code -d file1.txt file2.txt

# Install extension from command line
code --install-extension ms-python.python

# List installed extensions
code --list-extensions

# Disable all extensions
code --disable-extensions
```

## Keyboard Shortcuts

### Essential Shortcuts

#### General
- `Cmd+Shift+P` - Command Palette
- `Cmd+P` - Quick Open File
- `Cmd+Shift+N` - New Window
- `Cmd+Shift+W` - Close Window
- `Cmd+,` - Settings
- `Cmd+K Cmd+S` - Keyboard Shortcuts

#### Editing
- `Cmd+X` - Cut line (no selection)
- `Cmd+C` - Copy line (no selection)
- `Alt+Up/Down` - Move line up/down
- `Shift+Alt+Up/Down` - Copy line up/down
- `Cmd+Shift+K` - Delete line
- `Cmd+Enter` - Insert line below
- `Cmd+Shift+Enter` - Insert line above
- `Cmd+/` - Toggle line comment
- `Shift+Alt+A` - Toggle block comment
- `Alt+Z` - Toggle word wrap

#### Multi-cursor
- `Alt+Click` - Insert cursor
- `Cmd+Alt+Up/Down` - Insert cursor above/below
- `Cmd+D` - Select next occurrence
- `Cmd+K Cmd+D` - Skip to next occurrence
- `Cmd+Shift+L` - Select all occurrences

#### Navigation
- `Cmd+G` - Go to line
- `Cmd+T` - Go to symbol in workspace
- `Cmd+Shift+O` - Go to symbol in file
- `Cmd+Shift+M` - View problems panel
- `F8` - Go to next problem
- `Shift+F8` - Go to previous problem
- `Cmd+Shift+F` - Search in files
- `Cmd+Shift+H` - Replace in files

#### Display
- `Cmd+B` - Toggle sidebar
- `Cmd+J` - Toggle panel
- `Cmd+\` - Split editor
- `Cmd+1/2/3` - Focus editor group
- `Cmd+K Cmd+W` - Close all editors
- `Cmd+Shift+E` - Show Explorer
- `Cmd+Shift+F` - Show Search
- `Cmd+Shift+G` - Show Source Control
- `Cmd+Shift+D` - Show Debug
- `Cmd+Shift+X` - Show Extensions

#### Integrated Terminal
- `` Ctrl+` `` - Toggle terminal
- `` Cmd+Shift+` `` - Create new terminal
- `Cmd+Shift+C` - Copy in terminal
- `Cmd+Shift+V` - Paste in terminal
- `Cmd+K` - Clear terminal

## Settings Configuration

### User Settings
Location: `~/.config/Code/User/settings.json`

```json
{
    // Editor
    "editor.fontSize": 14,
    "editor.fontFamily": "'Fira Code', Menlo, Monaco, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "editor.tabSize": 4,
    "editor.renderWhitespace": "selection",
    "editor.rulers": [80, 120],
    "editor.wordWrap": "on",
    "editor.minimap.enabled": true,
    "editor.bracketPairColorization.enabled": true,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "editor.suggestSelection": "first",
    "editor.snippetSuggestions": "top",
    
    // Files
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/__pycache__": true
    },
    
    // Terminal
    "terminal.integrated.fontSize": 14,
    "terminal.integrated.fontFamily": "'Fira Code', monospace",
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.env.osx": {
        "FIG_NEW_SESSION": "1"
    },
    
    // Git
    "git.autofetch": true,
    "git.confirmSync": false,
    "git.enableSmartCommit": true,
    "gitlens.hovers.currentLine.over": "line",
    
    // Language-specific
    "[python]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "ms-python.black-formatter"
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[json]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[markdown]": {
        "editor.wordWrap": "on",
        "editor.quickSuggestions": false
    },
    
    // Extensions
    "extensions.autoUpdate": true,
    "extensions.ignoreRecommendations": false,
    
    // Theme
    "workbench.colorTheme": "Tokyo Night",
    "workbench.iconTheme": "material-icon-theme",
    "workbench.startupEditor": "none",
    
    // Telemetry
    "telemetry.telemetryLevel": "off"
}
```

### Workspace Settings
Location: `.vscode/settings.json` in project root

```json
{
    "editor.tabSize": 2,
    "files.exclude": {
        "**/dist": true,
        "**/build": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/bower_components": true
    }
}
```

## Extension Recommendations

### By Language

#### Python Development
```bash
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.black-formatter
code --install-extension ms-toolsai.jupyter
```

#### JavaScript/TypeScript
```bash
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension formulahendry.auto-rename-tag
code --install-extension dsznajder.es7-react-js-snippets
```

#### Go Development
```bash
code --install-extension golang.go
```

#### Rust Development
```bash
code --install-extension rust-lang.rust-analyzer
code --install-extension vadimcn.vscode-lldb
```

#### Docker/Kubernetes
```bash
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
```

### Productivity Extensions

```bash
# Git
code --install-extension eamodio.gitlens
code --install-extension mhutchie.git-graph

# Remote Development
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-containers

# AI Assistance
code --install-extension github.copilot
code --install-extension github.copilot-chat

# API Testing
code --install-extension rangav.vscode-thunder-client

# Database
code --install-extension mtxr.sqltools
code --install-extension mtxr.sqltools-driver-pg

# Markdown
code --install-extension yzhang.markdown-all-in-one
code --install-extension bierner.markdown-preview-github-styles

# Other
code --install-extension alefragnani.project-manager
code --install-extension gruntfuggly.todo-tree
code --install-extension streetsidesoftware.code-spell-checker
```

## Debugging Configuration

### Launch Configuration
Location: `.vscode/launch.json`

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal"
        },
        {
            "name": "Node.js: Current File",
            "type": "node",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal"
        },
        {
            "name": "Go: Launch Package",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${fileDirname}"
        }
    ]
}
```

### Tasks Configuration
Location: `.vscode/tasks.json`

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run Python",
            "type": "shell",
            "command": "python3",
            "args": ["${file}"],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "npm test",
            "group": "test"
        }
    ]
}
```

## Snippets

### Custom Snippets
Location: `~/.config/Code/User/snippets/`

Example Python snippets (`python.json`):
```json
{
    "Main Guard": {
        "prefix": "main",
        "body": [
            "if __name__ == \"__main__\":",
            "    ${1:pass}"
        ],
        "description": "Main guard"
    },
    "Import pdb": {
        "prefix": "pdb",
        "body": "import pdb; pdb.set_trace()",
        "description": "Import and set pdb breakpoint"
    }
}
```

## Tips and Tricks

### 1. Command Palette Magic
- Use `>` for commands
- Use `@` for symbols in file
- Use `#` for symbols in workspace
- Use `:` for go to line
- Use `?` for help

### 2. Multi-cursor Editing
- Hold `Alt` and click to add cursors
- Select text, then `Cmd+D` to select next occurrence
- `Cmd+Shift+L` to select all occurrences

### 3. Quick File Navigation
- `Cmd+P` then start typing filename
- Use `Cmd+Tab` to switch between recent files
- `Ctrl+Tab` to see all open editors

### 4. Zen Mode
- `Cmd+K Z` to enter Zen mode for distraction-free coding
- `Esc Esc` to exit

### 5. Terminal Integration
- Create multiple terminals with `` Cmd+Shift+` ``
- Name terminals for easy identification
- Split terminal panes

### 6. Git Integration
- View diffs in the source control panel
- Stage individual lines or hunks
- Resolve merge conflicts visually

### 7. Refactoring
- `F2` to rename symbol
- `Cmd+.` for quick fixes
- Extract method/variable refactoring

### 8. Extensions Management
- Disable extensions per workspace
- Create extension packs for teams
- Sync settings across machines

## Sync Settings

Enable Settings Sync to synchronize:
- Settings
- Keyboard shortcuts
- Extensions
- User snippets
- UI state

```bash
# Turn on Settings Sync
Cmd+Shift+P -> "Settings Sync: Turn On"
```

## Troubleshooting

### Extension Issues
```bash
# Reset VS Code
rm -rf ~/.config/Code
rm -rf ~/.vscode

# Reinstall extensions
code --install-extension <extension-id>
```

### Performance Issues
- Disable unnecessary extensions
- Increase memory limit in settings
- Exclude large folders from search

### Terminal Issues
- Check shell integration
- Verify terminal profile settings
- Reset terminal settings

## Best Practices

1. **Organize workspace** with multi-root workspaces
2. **Use version control** integration
3. **Configure formatters** per language
4. **Set up debugging** configurations
5. **Create project-specific** settings
6. **Use keyboard shortcuts** extensively
7. **Customize snippets** for repetitive code
8. **Enable autosave** to prevent data loss
9. **Regular backup** of settings
10. **Keep extensions updated**