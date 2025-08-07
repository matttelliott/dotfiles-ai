# fzf configuration for zsh
# This file is symlinked to ~/.config/fzf/fzf.zsh

# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null || true
[[ $- == *i* ]] && source "/usr/share/doc/fzf/examples/completion.zsh" 2> /dev/null || true
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null || true

# Key bindings
# ------------
source "/usr/local/opt/fzf/shell/key-bindings.zsh" 2> /dev/null || \
source "/usr/share/doc/fzf/examples/key-bindings.zsh" 2> /dev/null || \
source "$HOME/.fzf/shell/key-bindings.zsh" 2> /dev/null || true

# fzf configuration
# -----------------

# Use fd instead of find if available
if command -v fd > /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v rg > /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Default options
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --inline-info
  --preview-window=:hidden
  --bind="ctrl-/:toggle-preview"
  --bind="ctrl-u:preview-half-page-up"
  --bind="ctrl-d:preview-half-page-down"
  --color=dark
  --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
'

# CTRL-T - Paste the selected file path(s) into the command line
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# CTRL-R - Paste the selected command from history
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'"

# ALT-C - cd into the selected directory
export FZF_ALT_C_OPTS="
  --preview 'tree -C {} 2>/dev/null | head -200 || ls -la {}'"