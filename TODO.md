# TODO

## In Progress
- [x] Create migration plan for tools from original dotfiles (completed: 2025-08-07)
- [ ] Add fzf - fuzzy finder

## Implementation Strategy
Each tool gets its own directory with:
- `setup.sh` - Installation script for that tool
- `README.md` - Documentation for the tool  
- Config files that get SYMLINKED to target locations
- The main install.sh calls each tool's setup.sh

Example structure:
```
fzf/
├── setup.sh          # Installs fzf and creates symlinks
├── README.md         # fzf documentation and keybindings
├── fzf.zsh          # Shell integration config -> ~/.config/fzf/fzf.zsh
└── fzf.vim          # Vim integration -> included by nvim config
```

Symlink Strategy:
- Keep ALL config files in the dotfiles repo
- Symlink to appropriate locations on target machine
- Never copy configs (so updates are automatic)
- Backup existing configs before symlinking

Installation Architecture:
- `install.sh` - Master script that runs install-cli.sh + install-gui.sh
- `install-cli.sh` - CLI tools only (for Docker, servers, headless)
- `install-gui.sh` - GUI applications only (browsers, DBeaver, etc.)
- `post-install.sh` - Master wizard that runs post-install-cli.sh + post-install-gui.sh
- `post-install-cli.sh` - CLI configuration wizard
- `post-install-gui.sh` - GUI application configuration wizard

Testing Strategy:
- `test/Dockerfile` - Tests CLI installation in clean Debian container
- `test/build-and-run.sh` - Builds and runs test container
- Docker test runs `install-cli.sh` to verify headless installation
- GUI testing deferred (requires desktop environment)

## High Priority
- [ ] Add remaining CLI tools (fzf, jq, htop, lazygit, entr)
- [ ] Add development infrastructure (Docker + Colima as fallback, docker-compose, kubectl, PostgreSQL client, SQLite3, AWS CLI)
- [ ] Add Lua for Neovim plugin development and scripts
- [ ] Add FFmpeg for media processing
- [ ] Add all browsers for web development testing (Firefox, Chromium, Chrome, Safari already installed)
- [ ] Add DBeaver for database management

## Normal Priority
- [ ] Add alternative shells and terminals (kitty, zellij, nushell, ranger)
- [ ] Add browsers and multimedia tools (Firefox, Chromium, VLC, MPV)
- [ ] Port configurations from original dotfiles
- [ ] Create optional installation groups

## Low Priority
- [ ] Add GUI applications (DBeaver, Obsidian, VSCodium)
- [ ] Add less common tools (youtube-dl, nmap, vagrant)
- [ ] Create tool documentation

## Completed
- [x] Create comprehensive Claude configuration (completed: 2025-08-07)
- [x] Add global Claude rules (completed: 2025-08-07)
- [x] Set up personality modes (completed: 2025-08-07)

## Migration Phases

### Phase 1: Essential CLI Tools
- ripgrep, fzf, fd, bat, jq, htop, lazygit, entr
- These tools significantly improve daily workflow

### Phase 2: Programming Languages
- Python 3 + pip
- Node.js + npm  
- Go
- Rust + cargo
- Version manager (rtx or asdf)

### Phase 3: Development Infrastructure
- Docker + docker-compose
- kubectl
- PostgreSQL client
- SQLite3
- AWS CLI

### Phase 4: Optional Tools
- Alternative terminals (kitty)
- Alternative shells (nushell)
- Terminal multiplexers (zellij)
- File managers (ranger)

### Phase 5: GUI Applications
- Browsers (Firefox, Chromium)
- Database tools (DBeaver)
- Note-taking (Obsidian)
- Media players (VLC, MPV)

## Complete Tool Checklist from Original Dotfiles

### Command-Line Tools
- ~~[ ] ag (silver searcher) - SKIP: ripgrep is better~~
- [ ] ast-grep - Structural search/replace  
- [x] bat - Better cat with syntax highlighting (via cargo)
- [ ] entr - Run commands when files change
- [x] fd - Better find (installed as fd-find via cargo)
- [ ] fzf - Fuzzy finder
- [ ] htop - Process viewer
- [ ] jq - JSON processor
- [ ] lazygit - Git TUI
- ~~[ ] lsd - SKIP: using eza (maintained fork of exa)~~
- [ ] ncdu - Disk usage analyzer
- [ ] neofetch - System info display
- [ ] nmap - Network scanner
- [ ] ranger - Terminal file manager
- [x] ripgrep - Fast grep (via cargo)
- ~~[ ] rtx-cli - SKIP: using nvm, uv, rustup~~
- [ ] shfmt - Shell script formatter
- [ ] watch - Execute commands periodically
- [ ] wget - Download tool
- [ ] youtube-dl - Video downloader

### Programming Languages/Runtimes
- [x] Golang - Go language
- [ ] Julia - Scientific computing language (skip?)
- [ ] Lua - Needed for Neovim plugins
- [x] Node.js - JavaScript runtime (via nvm)
- [ ] PHP - Web scripting language (skip?)
- [x] Python - Python language (via uv/pyenv)
- [ ] Ruby - Ruby language (skip?)
- [x] Rust - Systems programming (via rustup)

### Development & Productivity Tools
- [ ] AWS CLI - Amazon cloud management
- [ ] Docker - Primary containerization
- [ ] Colima - Docker Desktop alternative (fallback)
- [ ] Kubernetes (kubectl) - Container orchestration
- [ ] Mprocs - Process manager
- [x] Neovim - Text editor
- [ ] PostgreSQL client - Database access
- [ ] SQLite3 - Embedded database
- [ ] Vagrant - VM management (skip?)
- [ ] VSCodium - VS Code without telemetry (optional?)

### Terminal & Shell
- [ ] Bash - Shell (usually pre-installed)
- [ ] Kitty - GPU-accelerated terminal
- [ ] Nushell - Modern data-oriented shell
- [x] Tmux - Terminal multiplexer
- [ ] Zellij - Modern terminal workspace
- [x] Zsh - Shell (with oh-my-zsh)

### Multimedia
- [ ] FFmpeg - Media processing
- [ ] MPV - Minimal media player
- [ ] VLC - Media player

### Browsers & Web
- [ ] Chromium - Open-source Chrome
- [ ] Firefox - Mozilla browser
- [ ] Opera - Browser
- [ ] Vivaldi - Feature-rich browser

### Miscellaneous Applications
- [x] 1Password - Password manager
- [ ] DBeaver - Database GUI
- [ ] KeePass - Open-source password manager
- [ ] Obsidian - Note-taking app
- [ ] Spotify - Music streaming
- [ ] Thunderbird - Email client

### Already Configured in dotfiles-ai
- [x] Claude CLI - AI assistant
- [x] Starship - Shell prompt
- [x] gnome-terminal/iTerm2 - Terminal emulators
- [x] Tokyo Night - Color theme
- [x] JetBrains Mono/Fira Code - Fonts
- [x] CapsLock → Ctrl - Keyboard remapping
- [x] eza - Better ls (maintained fork of exa, via cargo)