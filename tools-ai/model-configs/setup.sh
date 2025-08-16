#!/bin/bash

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

detect_os

# AI Model Configurations setup script - Centralized LLM configuration management

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    PLATFORM="macos"
elif [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then
        PLATFORM="debian"
    else
        PLATFORM="linux"
    fi
else
    log_warning "Unknown platform: $OS"
    exit 1
fi

setup_model_configs() {
    log_info "Setting up AI model configurations..."
    
    # Create config directory in user's home
    mkdir -p "$HOME/.config/ai-models"
    
    # Create symlinks for each provider config
    local providers=("claude" "openai" "ollama")
    
    for provider in "${providers[@]}"; do
        if [[ -f "$SCRIPT_DIR/$provider/config.json" ]]; then
            ln -sf "$SCRIPT_DIR/$provider/config.json" "$HOME/.config/ai-models/${provider}-config.json"
            log_success "Linked $provider configuration"
        fi
    done
    
    log_success "Model configurations setup complete"
}

setup_environment_variables() {
    log_info "Setting up environment variables..."
    
    local shell_config="
# AI Model Configuration
export AI_MODELS_CONFIG_DIR=\"\$HOME/.config/ai-models\"

# Model provider endpoints
export ANTHROPIC_API_URL=\"https://api.anthropic.com/v1\"
export OPENAI_API_URL=\"https://api.openai.com/v1\"
export OLLAMA_HOST=\"http://localhost:11434\"

# Default model settings
export DEFAULT_AI_PROVIDER=\"claude\"
export DEFAULT_CLAUDE_MODEL=\"claude-3-sonnet-20240229\"
export DEFAULT_OPENAI_MODEL=\"gpt-4\"
export DEFAULT_OLLAMA_MODEL=\"llama2\"

# AI configuration aliases
alias ai-config-claude=\"cat \$HOME/.config/ai-models/claude-config.json\"
alias ai-config-openai=\"cat \$HOME/.config/ai-models/openai-config.json\"
alias ai-config-ollama=\"cat \$HOME/.config/ai-models/ollama-config.json\"
alias ai-config-list=\"ls -la \$HOME/.config/ai-models/\"
"
    
    # Add to zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "AI Model Configuration" "$HOME/.zshrc"; then
            echo "$shell_config" >> "$HOME/.zshrc"
            log_success "Added AI model config to .zshrc"
        else
            log_info "AI model configuration already present in .zshrc"
        fi
    fi
    
    # Add to bashrc if it exists
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "AI Model Configuration" "$HOME/.bashrc"; then
            echo "$shell_config" >> "$HOME/.bashrc"
            log_success "Added AI model config to .bashrc"
        else
            log_info "AI model configuration already present in .bashrc"
        fi
    fi
}

create_helper_scripts() {
    log_info "Creating helper scripts..."
    
    # Create a model selector script
    cat > "$HOME/.local/bin/ai-model-select" << 'EOF'
#!/bin/bash

# AI Model Selector - Choose which model configuration to use

set -e

CONFIG_DIR="$HOME/.config/ai-models"

if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "Error: AI models config directory not found at $CONFIG_DIR"
    exit 1
fi

show_usage() {
    echo "Usage: ai-model-select [provider] [model]"
    echo ""
    echo "Available providers:"
    for config in "$CONFIG_DIR"/*-config.json; do
        if [[ -f "$config" ]]; then
            provider=$(basename "$config" | sed 's/-config.json//')
            echo "  $provider"
        fi
    done
    echo ""
    echo "Examples:"
    echo "  ai-model-select claude                 # List Claude models"
    echo "  ai-model-select claude opus           # Set Claude Opus as default"
    echo "  ai-model-select openai gpt-4          # Set GPT-4 as default"
}

list_models() {
    local provider="$1"
    local config_file="$CONFIG_DIR/${provider}-config.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Configuration file not found for provider: $provider"
        exit 1
    fi
    
    echo "Available models for $provider:"
    if command -v jq >/dev/null 2>&1; then
        jq -r '.available_models[]? | "\(.id) - \(.name)"' "$config_file" 2>/dev/null || echo "Unable to parse models from config"
    else
        echo "Install jq to list available models, or view config manually:"
        echo "cat $config_file"
    fi
}

set_default_model() {
    local provider="$1"
    local model="$2"
    local config_file="$CONFIG_DIR/${provider}-config.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Configuration file not found for provider: $provider"
        exit 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Update the default model in the config
        jq --arg model "$model" '.default_model = $model' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
        echo "Set default model for $provider to: $model"
    else
        echo "jq is required to modify configurations. Please install jq or edit manually:"
        echo "Edit: $config_file"
    fi
}

case "${1:-}" in
    ""|"-h"|"--help")
        show_usage
        ;;
    *)
        if [[ -z "${2:-}" ]]; then
            list_models "$1"
        else
            set_default_model "$1" "$2"
        fi
        ;;
esac
EOF
    
    mkdir -p "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/ai-model-select"
    
    log_success "Created ai-model-select helper script"
}

install_dependencies() {
    log_info "Checking dependencies..."
    
    # Check if jq is installed for JSON manipulation
    if ! command -v jq &> /dev/null; then
        log_info "Installing jq for JSON configuration management..."
        
        case "$PLATFORM" in
            macos)
                if command -v brew &> /dev/null; then
                    brew install jq
                else
                    log_warning "Homebrew not found. Please install jq manually: https://stedolan.github.io/jq/"
                fi
                ;;
            debian)
                safe_sudo apt update
                safe_sudo apt install -y jq
                ;;
            linux)
                if command -v apt &> /dev/null; then
                    safe_sudo apt update && safe_sudo apt install -y jq
                elif command -v dnf &> /dev/null; then
                    safe_sudo dnf install -y jq
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm jq
                else
                    log_warning "Package manager not recognized. Please install jq manually."
                fi
                ;;
        esac
        
        if command -v jq &> /dev/null; then
            log_success "jq installed successfully"
        else
            log_warning "jq installation failed. Some features may not work."
        fi
    else
        log_success "jq is already installed"
    fi
}

# Main installation
main() {
    log_info "Setting up AI model configurations..."
    
    install_dependencies
    setup_model_configs
    setup_environment_variables
    create_helper_scripts
    
    log_success "AI model configurations setup complete!"
    echo
    echo "AI Model Configurations - Centralized LLM configuration management"
    echo
    echo "Configuration files created in: $HOME/.config/ai-models/"
    echo
    echo "Available commands:"
    echo "  ai-model-select           - Interactive model selection"
    echo "  ai-config-claude          - View Claude configuration"
    echo "  ai-config-openai          - View OpenAI configuration"
    echo "  ai-config-ollama          - View Ollama configuration"
    echo "  ai-config-list            - List all configuration files"
    echo
    echo "Environment variables set:"
    echo "  AI_MODELS_CONFIG_DIR      - Configuration directory"
    echo "  DEFAULT_AI_PROVIDER       - Default provider (claude)"
    echo "  DEFAULT_CLAUDE_MODEL      - Default Claude model"
    echo "  DEFAULT_OPENAI_MODEL      - Default OpenAI model"
    echo
    echo "Restart your shell or run 'source ~/.zshrc' to load new configurations"
}

main "$@"