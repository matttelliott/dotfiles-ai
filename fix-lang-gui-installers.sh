#\!/bin/bash
# Fix language and GUI installers

set -e

echo "=== Fixing Language and GUI Installers ==="

for file in tools-lang/*/install tools-gui/*/install; do
    if [ \! -f "$file" ]; then
        continue
    fi
    
    echo "Fixing $file"
    
    # Create temp file
    temp_file=$(mktemp)
    
    # Write new header
    cat > "$temp_file" << 'HEADER'
#\!/bin/bash

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

detect_os

HEADER
    
    # Skip old header and add rest of file
    # Skip shebang, set -e, and any custom logging functions
    awk '
    BEGIN { skip = 1 }
    /^#\!/ { next }
    /^set -e/ { next }
    /^# Colors for output/ { skip = 1; next }
    /^GREEN=/ { next }
    /^BLUE=/ { next }
    /^YELLOW=/ { next }
    /^RED=/ { next }
    /^NC=/ { next }
    /^log_info\(\)/ { skip = 1; next }
    /^log_success\(\)/ { skip = 1; next }
    /^log_error\(\)/ { skip = 1; next }
    /^log_warning\(\)/ { skip = 1; next }
    /^}$/ { 
        if (skip) { skip = 0; next }
        else { print }
    }
    skip == 0 { print }
    ' "$file" >> "$temp_file"
    
    # Replace sudo with safe_sudo
    sed -i 's/\bsudo apt\b/safe_sudo apt/g' "$temp_file" 2>/dev/null || true
    sed -i 's/\bsudo dnf\b/safe_sudo dnf/g' "$temp_file" 2>/dev/null || true
    sed -i 's/\bsudo yum\b/safe_sudo yum/g' "$temp_file" 2>/dev/null || true
    sed -i 's/\bsudo snap\b/safe_sudo snap/g' "$temp_file" 2>/dev/null || true
    sed -i 's/\bsudo systemctl\b/safe_sudo systemctl/g' "$temp_file" 2>/dev/null || true
    
    # Move temp file to original
    mv "$temp_file" "$file"
    chmod +x "$file"
done

echo "Done fixing language and GUI installers"
