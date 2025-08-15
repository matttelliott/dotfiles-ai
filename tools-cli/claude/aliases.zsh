# Claude CLI aliases and functions for AI-powered coding assistance
# This file is sourced by zshrc when Claude CLI is available

if command -v claude &> /dev/null; then
    # Quick Claude aliases
    alias claude_cli='claude'
    alias claude_ask='claude ask'
    alias claude_code='claude code'
    alias claude_file='claude file'
    alias claude_auth='claude auth'
    
    # Function to ask Claude about a file
    claude_askfile() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "$2"
        else
            echo "File '$1' not found"
        fi
    }
    
    # Function to get Claude's help with git commits
    claude_commit() {
        local changes=$(git diff --cached)
        if [ -n "$changes" ]; then
            claude ask "$changes" "Generate a concise git commit message for these changes"
        else
            echo "No staged changes found. Run 'git add' first."
        fi
    }
    
    # Function to ask Claude to explain a command
    claude_explain() {
        claude ask "Explain this command: $*"
    }
    
    # Function to ask Claude for code review
    claude_review() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "Please review this code and suggest improvements"
        else
            echo "File '$1' not found"
        fi
    }
    
    # Function to ask Claude to generate documentation
    claude_doc() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "Generate documentation for this code"
        else
            echo "File '$1' not found"
        fi
    }
    
    # Function to ask Claude to debug code
    claude_debug() {
        if [ -f "$1" ]; then
            claude ask "$(cat "$1")" "Help me debug this code and identify potential issues"
        else
            echo "File '$1' not found"
        fi
    }
fi
