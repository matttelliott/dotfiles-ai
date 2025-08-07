# lazygit - Simple Terminal UI for Git

A simple terminal UI for git commands with intuitive keyboard shortcuts.

## Installation

```bash
./tools-cli/lazygit/setup.sh
```

## Features

- **Interactive UI** - Navigate with keyboard/mouse
- **Visual staging** - Stage individual lines or hunks
- **Branch management** - Create, checkout, merge branches
- **Commit history** - Interactive rebase, cherry-pick
- **Stash management** - Create and apply stashes
- **Conflict resolution** - Resolve merge conflicts
- **Submodules** - Manage git submodules
- **Worktrees** - Support for git worktrees

## Key Bindings

### Global
- `?` - Show help/keybindings
- `q` or `Esc` - Quit/back
- `Tab` - Next panel
- `Shift+Tab` - Previous panel
- `[/]` - Previous/next tab
- `h/l` - Navigate left/right
- `j/k` - Navigate up/down
- `/` - Search
- `R` - Refresh
- `x` - Open menu

### Files Panel
- `Space` - Stage/unstage file
- `a` - Stage/unstage all
- `c` - Commit changes
- `C` - Commit with editor
- `A` - Amend last commit
- `d` - Discard changes
- `D` - View reset options
- `e` - Edit file
- `o` - Open file
- `i` - Ignore file
- `r` - Refresh files
- `s` - Stash changes
- `S` - View stash options
- `M` - Open merge tool
- `f` - Fetch

### Branches Panel
- `Space` - Checkout branch
- `n` - New branch
- `d` - Delete branch
- `r` - Rebase branch
- `R` - Rename branch
- `M` - Merge into current
- `f` - Fast-forward
- `g` - View git-flow options
- `u` - Set upstream

### Commits Panel
- `Space` - Checkout commit
- `d` - Delete commit (interactive rebase)
- `p` - Pick commit (cherry-pick)
- `r` - Reword commit
- `R` - Reword with editor
- `e` - Edit commit
- `s` - Squash down
- `f` - Fixup commit
- `S` - Squash all fixups
- `v` - Revert commit
- `c` - Copy commit SHA
- `C` - Copy commit message
- `Enter` - View commit files

### Stash Panel
- `Space` - Apply stash
- `g` - Pop stash
- `d` - Drop stash
- `n` - New stash
- `r` - Rename stash

### Staging Panel (Main)
- `Space` - Stage/unstage line
- `a` - Stage/unstage hunk
- `Tab` - Switch to other panel
- `e` - Edit file
- `o` - Open file
- `↑/↓` - Navigate lines
- `←/→` - Navigate hunks

## Common Workflows

### Basic commit workflow
```bash
lazygit                 # Open lazygit
# Navigate to files panel
Space                   # Stage files
c                      # Commit
# Type message and confirm
```

### Interactive rebase
```bash
# In commits panel
e                      # Start interactive rebase
# Navigate commits
d                      # Drop commit
s                      # Squash commit
r                      # Reword commit
# Continue rebase
```

### Stashing workflow
```bash
# In files panel
s                      # Stash all changes
# or
S                      # Stash options (partial)
# In stash panel
Space                  # Apply stash
g                      # Pop stash
```

### Branch management
```bash
# In branches panel
n                      # Create new branch
Space                  # Checkout branch
M                      # Merge branch
d                      # Delete branch
```

### Conflict resolution
```bash
# During merge conflict
# Navigate to conflicted file
e                      # Edit to resolve
# or
M                      # Open merge tool
Space                  # Stage resolved file
c                      # Continue merge
```

## Configuration

Located at `~/.config/lazygit/config.yml`

### Key customizations
```yaml
gui:
  theme:
    activeBorderColor: [green, bold]
  mouseEvents: true
  showFileTree: true

git:
  autoFetch: true
  autoRefresh: true

os:
  edit: 'nvim'
  openCommand: 'open {{filename}}'

keybinding:
  universal:
    quit: 'q'
    return: '<esc>'
```

## Configured Aliases

- `lg` - Launch lazygit
- `lzg` - Alternative alias
- `lgit` - Alternative alias

## Tips

1. **Stage individual lines** - Use Space in staging panel
2. **Quick commit** - `c` for simple, `C` for editor
3. **Undo last action** - `z` to undo
4. **Copy to clipboard** - Various `c` commands
5. **Filter files** - `<c-b>` for filter menu
6. **Custom commands** - `:` to run git commands
7. **Bulk operations** - Tag multiple items with Space
8. **Quick push/pull** - `p` to pull, `P` to push
9. **View logs** - Different log views in commits panel
10. **Submodules** - Enter to dive into submodule

## Integration with Editor

lazygit is configured to use nvim for:
- Editing files
- Commit messages (when using `C`)
- Interactive rebase editing
- Merge conflict resolution

## Comparison with git CLI

| Task | git CLI | lazygit |
|------|---------|---------|
| Stage files | `git add` | `Space` |
| Commit | `git commit` | `c` |
| Branch switch | `git checkout` | `Space` |
| Interactive rebase | `git rebase -i` | `e` |
| Stash | `git stash` | `s` |
| View diff | `git diff` | Automatic |
| Merge | `git merge` | `M` |
| Cherry-pick | `git cherry-pick` | `p` |