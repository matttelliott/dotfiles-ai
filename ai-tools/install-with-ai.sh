#!/bin/bash
# AI-Assisted Installation Script
# Runs dotfiles installers in tmux sessions that can be monitored by Claude CLI

set -e

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_TOOLS_DIR="$DOTFILES_DIR/ai-tools"
SESSION_NAME="ai-install"
MAIN_PANE_NAME="installer"
LOG_PANE_NAME="logs"
MONITOR_PANE_NAME="monitor"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Show usage
show_usage() {
    cat << EOF
AI-Assisted Installation Script
Runs installations in tmux sessions that Claude CLI can monitor via MCP

Usage: ./install-with-ai.sh [command] [options]

Commands:
    setup               Create tmux session for AI monitoring
    install <tool>      Install a tool with AI monitoring
    monitor             Start monitoring existing session
    claude-prompt       Generate prompt for Claude CLI
    cleanup             Clean up tmux session

Examples:
    # Set up monitoring session
    ./install-with-ai.sh setup
    
    # Install a tool with monitoring
    ./install-with-ai.sh install neovim
    
    # Generate Claude prompt to analyze output
    ./install-with-ai.sh claude-prompt
    
Options:
    -s, --session NAME  Use custom session name (default: ai-install)
    -h, --help          Show this help message

How it works:
1. Creates a tmux session with multiple panes
2. Runs installer in one pane, captures output
3. Claude CLI can read panes via MCP server
4. AI can provide real-time assistance with errors

EOF
}

# Setup tmux session for AI monitoring
setup_session() {
    echo -e "${BLUE}Setting up tmux session for AI monitoring...${NC}"
    
    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo -e "${YELLOW}Session '$SESSION_NAME' already exists${NC}"
        read -p "Kill existing session? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            tmux kill-session -t "$SESSION_NAME"
        else
            echo "Using existing session"
            return 0
        fi
    fi
    
    # Create new session with main window (set default size)
    TMUX="" tmux new-session -d -s "$SESSION_NAME" -n "install" -x 120 -y 40
    
    # Split into panes
    # Main pane (0): Installer output
    # Right pane (1): Logs and errors
    # Bottom pane (2): Monitoring/status
    tmux split-window -h -t "$SESSION_NAME:install" -p 40
    tmux split-window -v -t "$SESSION_NAME:install.0" -p 20
    
    # Set pane titles (if supported)
    tmux select-pane -t "$SESSION_NAME:install.0" -T "Installer"
    tmux select-pane -t "$SESSION_NAME:install.1" -T "Logs"
    tmux select-pane -t "$SESSION_NAME:install.2" -T "Monitor"
    
    # Send initial commands to panes
    tmux send-keys -t "$SESSION_NAME:install.0" "# Main installer pane - ready for commands" C-m
    tmux send-keys -t "$SESSION_NAME:install.1" "# Log viewer pane - will tail logs" C-m
    tmux send-keys -t "$SESSION_NAME:install.2" "# Monitoring pane - status updates" C-m
    
    echo -e "${GREEN}✓ Tmux session '$SESSION_NAME' created with 3 panes${NC}"
    echo
    echo "Pane layout:"
    echo "  Pane 0 (left): Main installer output"
    echo "  Pane 1 (right): Logs and error tracking"
    echo "  Pane 2 (bottom): Status monitoring"
    echo
    echo -e "${BLUE}You can attach to the session with:${NC}"
    echo "  tmux attach -t $SESSION_NAME"
}

# Install a tool with AI monitoring
install_tool() {
    local tool="$1"
    
    if [[ -z "$tool" ]]; then
        echo -e "${RED}Error: Please specify a tool to install${NC}"
        echo "Example: ./install-with-ai.sh install neovim"
        exit 1
    fi
    
    # Ensure session exists
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "Creating monitoring session first..."
        setup_session
    fi
    
    echo -e "${BLUE}Installing $tool with AI monitoring...${NC}"
    
    # Create log file
    local log_file="/tmp/ai-install-${tool}-$(date +%Y%m%d-%H%M%S).log"
    
    # Start log tailing in pane 1
    tmux send-keys -t "$SESSION_NAME:install.1" "tail -f $log_file" C-m
    
    # Update monitor pane
    tmux send-keys -t "$SESSION_NAME:install.2" "echo 'Installing: $tool'" C-m
    tmux send-keys -t "$SESSION_NAME:install.2" "echo 'Log: $log_file'" C-m
    tmux send-keys -t "$SESSION_NAME:install.2" "echo 'Started: $(date)'" C-m
    
    # Run the installer in main pane with output capture
    local install_cmd=""
    
    # Determine installation command based on tool location
    if [[ -d "$DOTFILES_DIR/tools-cli/$tool" ]]; then
        install_cmd="$DOTFILES_DIR/tools-cli/$tool/install"
    elif [[ -d "$DOTFILES_DIR/tools-gui/$tool" ]]; then
        install_cmd="$DOTFILES_DIR/tools-gui/$tool/install"
    elif [[ -d "$DOTFILES_DIR/tools-lang/$tool" ]]; then
        install_cmd="$DOTFILES_DIR/tools-lang/$tool/install"
    elif [[ -d "$AI_TOOLS_DIR/mcp-servers/$tool" ]]; then
        install_cmd="$AI_TOOLS_DIR/mcp-servers/$tool/install"
    else
        # Try main installer with specific tool
        install_cmd="$DOTFILES_DIR/install $tool"
    fi
    
    # Clear the main pane and run installer
    tmux send-keys -t "$SESSION_NAME:install.0" C-l
    tmux send-keys -t "$SESSION_NAME:install.0" "echo '=== Installing $tool ===' | tee -a $log_file" C-m
    tmux send-keys -t "$SESSION_NAME:install.0" "echo 'Command: $install_cmd' | tee -a $log_file" C-m
    tmux send-keys -t "$SESSION_NAME:install.0" "echo '========================' | tee -a $log_file" C-m
    tmux send-keys -t "$SESSION_NAME:install.0" "$install_cmd 2>&1 | tee -a $log_file" C-m
    
    echo -e "${GREEN}✓ Installation started in tmux session '$SESSION_NAME'${NC}"
    echo
    echo "Monitor with:"
    echo "  tmux attach -t $SESSION_NAME"
    echo
    echo "Or use Claude CLI with MCP to read output:"
    echo "  ./install-with-ai.sh claude-prompt"
}

# Generate Claude CLI prompt
generate_claude_prompt() {
    echo -e "${BLUE}Claude CLI Prompt for Installation Monitoring:${NC}"
    echo
    cat << 'EOF'
I need help monitoring and troubleshooting an installation. Please use the tmux MCP server to:

1. List all tmux sessions to find the 'ai-install' session
2. Read the last 100 lines from pane 0 (main installer output) in the 'ai-install' session
3. Read the last 50 lines from pane 1 (logs) in the 'ai-install' session
4. Check pane 2 for status information

Based on the output:
- Identify any errors or warnings
- Suggest fixes for any issues found
- Provide commands to resolve problems
- Let me know if the installation completed successfully

If there are errors, please:
1. Explain what went wrong
2. Provide the exact commands to fix it
3. Suggest how to retry the installation
EOF
    
    echo
    echo -e "${YELLOW}Copy the above prompt and paste it into Claude CLI${NC}"
    echo
    
    # Also save to file for convenience
    local prompt_file="/tmp/claude-install-prompt.txt"
    cat > "$prompt_file" << 'EOF'
I need help monitoring and troubleshooting an installation. Please use the tmux MCP server to:

1. List all tmux sessions to find the 'ai-install' session
2. Read the last 100 lines from pane 0 (main installer output) in the 'ai-install' session
3. Read the last 50 lines from pane 1 (logs) in the 'ai-install' session
4. Check pane 2 for status information

Based on the output:
- Identify any errors or warnings
- Suggest fixes for any issues found
- Provide commands to resolve problems
- Let me know if the installation completed successfully
EOF
    
    echo "Prompt also saved to: $prompt_file"
    
    # If pbcopy is available (macOS), copy to clipboard
    if command -v pbcopy &>/dev/null; then
        cat "$prompt_file" | pbcopy
        echo -e "${GREEN}✓ Prompt copied to clipboard${NC}"
    # If xclip is available (Linux)
    elif command -v xclip &>/dev/null; then
        cat "$prompt_file" | xclip -selection clipboard
        echo -e "${GREEN}✓ Prompt copied to clipboard${NC}"
    fi
}

# Monitor existing session
monitor_session() {
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo -e "${RED}Error: Session '$SESSION_NAME' not found${NC}"
        echo "Create it first with: ./install-with-ai.sh setup"
        exit 1
    fi
    
    echo -e "${BLUE}Monitoring session '$SESSION_NAME'...${NC}"
    echo
    
    # Show current pane contents summary
    echo "Current status:"
    echo "==============="
    
    # Get last few lines from each pane
    echo -e "${YELLOW}Main Installer (pane 0) - last 5 lines:${NC}"
    tmux capture-pane -t "$SESSION_NAME:install.0" -p | tail -5
    
    echo
    echo -e "${YELLOW}Logs (pane 1) - last 5 lines:${NC}"
    tmux capture-pane -t "$SESSION_NAME:install.1" -p | tail -5
    
    echo
    echo -e "${YELLOW}Monitor (pane 2) - last 5 lines:${NC}"
    tmux capture-pane -t "$SESSION_NAME:install.2" -p | tail -5
    
    echo
    echo "For full output, attach to session: tmux attach -t $SESSION_NAME"
    echo "Or use Claude CLI with the MCP prompt: ./install-with-ai.sh claude-prompt"
}

# Cleanup tmux session
cleanup_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo -e "${YELLOW}Killing tmux session '$SESSION_NAME'...${NC}"
        tmux kill-session -t "$SESSION_NAME"
        echo -e "${GREEN}✓ Session cleaned up${NC}"
    else
        echo "No session to clean up"
    fi
    
    # Also clean up old log files
    echo "Cleaning up old log files..."
    find /tmp -name "ai-install-*.log" -mtime +7 -delete 2>/dev/null || true
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Create AI analysis script
create_analysis_script() {
    cat > "$AI_TOOLS_DIR/analyze-install.sh" << 'EOF'
#!/bin/bash
# Quick script to analyze installation output with Claude CLI

SESSION="${1:-ai-install}"
PANE="${2:-0}"

echo "Analyzing tmux session: $SESSION, pane: $PANE"
echo

# Create a temporary file with the analysis request
PROMPT_FILE="/tmp/claude-analyze-$$.txt"

cat > "$PROMPT_FILE" << EOFI
Please analyze the installation output from tmux. Use the MCP server to:

1. Read the last 200 lines from session '$SESSION', pane $PANE
2. Identify any errors, warnings, or issues
3. For each issue found:
   - Explain what went wrong
   - Provide the exact fix command
   - Suggest prevention for future

4. Summary:
   - Did the installation complete successfully?
   - What follow-up actions are needed?
   - Any configuration required?

Please be concise and focus on actionable items.
EOFI

echo "Prompt created. You can now:"
echo "1. Copy and paste into Claude CLI:"
cat "$PROMPT_FILE"
echo
echo "2. Or if claude CLI supports input redirection:"
echo "   claude < $PROMPT_FILE"

# Cleanup
rm -f "$PROMPT_FILE"
EOF
    
    chmod +x "$AI_TOOLS_DIR/analyze-install.sh"
    echo -e "${GREEN}✓ Created analyze-install.sh script${NC}"
}

# Main execution
main() {
    case "${1:-}" in
        setup)
            setup_session
            create_analysis_script
            ;;
        install)
            shift
            install_tool "$@"
            ;;
        monitor)
            monitor_session
            ;;
        claude-prompt|prompt)
            generate_claude_prompt
            ;;
        cleanup|clean)
            cleanup_session
            ;;
        -h|--help|help)
            show_usage
            ;;
        *)
            echo -e "${RED}Unknown command: ${1:-}${NC}"
            echo
            show_usage
            exit 1
            ;;
    esac
}

# Parse session name option
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--session)
            SESSION_NAME="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Run main function with remaining arguments
main "$@"