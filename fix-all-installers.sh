#!/bin/bash
# Fix all broken installers systematically

set -e

echo "=== Fixing All Installers ==="

# Fix installers that don't source common.sh
fix_no_common() {
    local file="$1"
    echo "  Adding common.sh to $file"
    
    # Create temp file with fixed content
    temp_file=$(mktemp)
    
    # Get shebang
    head -n1 "$file" > "$temp_file"
    
    # Add common.sh source
    cat >> "$temp_file" << 'EOF'

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

detect_os

EOF
    
    # Add rest of file, skipping old shebang and set -e
    tail -n +2 "$file" | grep -v "^set -e" >> "$temp_file"
    
    mv "$temp_file" "$file"
    chmod +x "$file"
}

# Add missing install functions based on tool name
add_missing_install_function() {
    local file="$1"
    local tool_name="$2"
    local func_name="$3"
    
    echo "  Adding $func_name to $file"
    
    # Create the install function based on tool name
    temp_file=$(mktemp)
    
    # Copy everything before detect_os
    sed '/^detect_os$/q' "$file" > "$temp_file"
    
    # Add the install function
    cat >> "$temp_file" << EOF

${func_name}() {
    log_info "Installing ${tool_name}..."
    
    if command -v ${tool_name} &> /dev/null; then
        log_info "${tool_name} is already installed"
        return 0
    fi
    
    case "\$OS" in
        macos)
            if command -v brew &> /dev/null; then
                brew install ${tool_name}
            else
                log_error "Homebrew not found"
                exit 1
            fi
            ;;
        debian|mint)
            safe_apt_update
            safe_sudo apt install -y ${tool_name}
            ;;
        *)
            log_warning "Please install ${tool_name} manually for your OS"
            ;;
    esac
    
    log_success "${tool_name} installed"
}

EOF
    
    # Add rest of file after detect_os
    sed '1,/^detect_os$/d' "$file" >> "$temp_file"
    
    mv "$temp_file" "$file"
    chmod +x "$file"
}

# Process each broken installer
echo "Fixing tools-cli/entr/install"
add_missing_install_function "tools-cli/entr/install" "entr" "install_entr"

echo "Fixing tools-cli/eza/install"
add_missing_install_function "tools-cli/eza/install" "eza" "install_eza"

echo "Fixing tools-cli/fd/install"
add_missing_install_function "tools-cli/fd/install" "fd-find" "install_fd"

echo "Fixing tools-cli/fzf/install"
# Just needs detect_os
sed -i '/source.*common.sh/a\\ndetect_os' tools-cli/fzf/install

echo "Fixing tools-cli/gcloud/install"
add_missing_install_function "tools-cli/gcloud/install" "gcloud" "install_gcloud_cli"

echo "Fixing tools-cli/htop/install"
add_missing_install_function "tools-cli/htop/install" "htop" "install_htop"

echo "Fixing tools-cli/httpie/install"
# This one calls install_curl but probably meant install_httpie
sed -i 's/install_curl/install_httpie/g' tools-cli/httpie/install
add_missing_install_function "tools-cli/httpie/install" "httpie" "install_httpie"

echo "Fixing tools-cli/kubernetes/install"
add_missing_install_function "tools-cli/kubernetes/install" "kubectl" "install_kubectl"

echo "Fixing tools-cli/lazygit/install"
add_missing_install_function "tools-cli/lazygit/install" "lazygit" "install_lazygit"

echo "Fixing tools-cli/monitoring/install"
# This calls install_htop but needs its own functions
sed -i 's/install_htop/install_monitoring_tools/g' tools-cli/monitoring/install

echo "Fixing tools-cli/network/install"
# This calls install_nmap
add_missing_install_function "tools-cli/network/install" "nmap" "install_nmap"

echo "Fixing tools-cli/postgres/install"
add_missing_install_function "tools-cli/postgres/install" "postgresql-client" "install_postgres_client"

# Fix tools without common.sh
for tool in prompt ripgrep sqlite tmuxinator tmux tree zsh; do
    if [[ -f "tools-cli/$tool/install" ]]; then
        echo "Fixing tools-cli/$tool/install (adding common.sh)"
        fix_no_common "tools-cli/$tool/install"
    fi
done

# Fix sudo -> safe_sudo
echo "Replacing sudo with safe_sudo..."
for file in tools-*/*/install; do
    if [[ -f "$file" ]] && grep -q "source.*common.sh" "$file"; then
        sed -i 's/sudo apt/safe_sudo apt/g' "$file" 2>/dev/null || true
        sed -i 's/sudo dnf/safe_sudo dnf/g' "$file" 2>/dev/null || true
        sed -i 's/sudo yum/safe_sudo yum/g' "$file" 2>/dev/null || true
    fi
done

echo
echo "=== Fixes Applied ==="
echo "Now run: ./audit-installers.sh to verify"