# Claude CLI aliases and functions for AI-powered coding assistance
# This file is sourced by zshrc when Claude CLI is available

if command -v claude &> /dev/null; then
    # Quick Claude aliases
    alias c='claude'
    alias cask='claude ask'
    alias ccode='claude code'
    alias cfile='claude file'
    alias cauth='claude auth'
    
    # Function to ask Claude about a file
    caskfile() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "$2"
        else
            echo "File '$1' not found"
        fi
    }
    
    # Function to get Claude's help with git commits
    ccommit() {
        local changes=$(git diff --cached)
        if [ -n "$changes" ]; then
            claude ask "$changes" "Generate a concise git commit message for these changes"
        else
            echo "No staged changes found. Run 'git add' first."
        fi
    }
    
    # Function to ask Claude to explain a command
    cexplain() {
        claude ask "Explain this command: $*"
    }
    
    # Function to ask Claude for code review
    creview() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "Please review this code and suggest improvements"
        else
            echo "File '$1' not found"
        fi
    }
    
    # Function to ask Claude to generate documentation
    cdoc() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "Generate documentation for this code"
        else
            echo "File '$1' not found"
        fi
    }
    
    # Function to ask Claude to debug code
    cdebug() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "Help me debug this code and identify potential issues"
        else
            echo "File '$1' not found"
        fi
    }
fi
