#!/bin/bash

# Claude CLI Token Manager
# Securely manages Claude CLI authentication tokens without modifying shell configs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
CLAUDE_CONFIG_DIR="$HOME/.config/claude"
CLAUDE_TOKEN_FILE="$CLAUDE_CONFIG_DIR/token"
CLAUDE_ENV_FILE="$CLAUDE_CONFIG_DIR/env"

# Create secure config directory
create_config_dir() {
    if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
        mkdir -p "$CLAUDE_CONFIG_DIR"
        chmod 700 "$CLAUDE_CONFIG_DIR"
        log_info "Created secure Claude config directory: $CLAUDE_CONFIG_DIR"
    fi
}

# Store token securely
store_token() {
    local token="$1"
    
    if [[ -z "$token" ]]; then
        log_error "No token provided"
        return 1
    fi
    
    create_config_dir
    
    # Store token in secure file
    echo "$token" > "$CLAUDE_TOKEN_FILE"
    chmod 600 "$CLAUDE_TOKEN_FILE"
    
    # Create environment file for Claude CLI
    cat > "$CLAUDE_ENV_FILE" << EOF
export ANTHROPIC_API_KEY="$token"
EOF
    chmod 600 "$CLAUDE_ENV_FILE"
    
    log_success "Token stored securely in $CLAUDE_TOKEN_FILE"
    log_info "Environment file created at $CLAUDE_ENV_FILE"
}

# Load token from secure storage
load_token() {
    if [[ -f "$CLAUDE_TOKEN_FILE" ]]; then
        cat "$CLAUDE_TOKEN_FILE"
        return 0
    else
        log_error "No token found. Run 'claude-token set <your-token>' first"
        return 1
    fi
}

# Check if token exists
check_token() {
    if [[ -f "$CLAUDE_TOKEN_FILE" ]]; then
        log_success "Claude token is configured"
        return 0
    else
        log_warning "Claude token not found"
        return 1
    fi
}

# Remove token
remove_token() {
    if [[ -f "$CLAUDE_TOKEN_FILE" ]]; then
        rm -f "$CLAUDE_TOKEN_FILE"
        log_success "Token removed"
    fi
    
    if [[ -f "$CLAUDE_ENV_FILE" ]]; then
        rm -f "$CLAUDE_ENV_FILE"
        log_success "Environment file removed"
    fi
}

# Interactive token setup
interactive_setup() {
    echo ""
    log_info "Claude CLI Token Setup"
    echo ""
    echo "To get your Anthropic API key:"
    echo "1. Visit https://console.anthropic.com/"
    echo "2. Sign in to your account"
    echo "3. Go to 'API Keys' section"
    echo "4. Create a new API key"
    echo ""
    
    read -s -p "Enter your Anthropic API key: " token
    echo ""
    
    if [[ -n "$token" ]]; then
        store_token "$token"
        echo ""
        log_success "Token setup complete!"
        log_info "You can now use Claude CLI commands"
    else
        log_error "No token provided. Setup cancelled."
        return 1
    fi
}

# Show usage
show_usage() {
    echo "Claude CLI Token Manager"
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  set <token>     Store API token securely"
    echo "  get             Display current token (masked)"
    echo "  check           Check if token is configured"
    echo "  remove          Remove stored token"
    echo "  setup           Interactive token setup"
    echo "  env             Show environment file path"
    echo "  help            Show this help message"
    echo ""
}

# Main command handling
case "${1:-help}" in
    "set")
        if [[ -n "$2" ]]; then
            store_token "$2"
        else
            log_error "Usage: $0 set <token>"
            exit 1
        fi
        ;;
    "get")
        if token=$(load_token); then
            # Show masked token for security
            masked_token="${token:0:8}...${token: -4}"
            echo "Token: $masked_token"
        fi
        ;;
    "check")
        check_token
        ;;
    "remove")
        remove_token
        ;;
    "setup")
        interactive_setup
        ;;
    "env")
        echo "$CLAUDE_ENV_FILE"
        ;;
    "help"|*)
        show_usage
        ;;
esac
