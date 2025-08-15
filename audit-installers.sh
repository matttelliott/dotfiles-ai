#!/bin/bash
# Audit all installers for common issues

echo "=== Auditing All Installers ==="
echo

# Check each installer
for installer in tools-cli/*/install tools-lang/*/install tools-gui/*/install; do
    if [[ ! -f "$installer" ]]; then
        continue
    fi
    
    tool_name=$(basename $(dirname "$installer"))
    issues=""
    
    # Check if sources common.sh
    if ! grep -q "source.*common.sh" "$installer" 2>/dev/null; then
        issues="${issues}NO_COMMON "
    fi
    
    # Check if calls detect_os
    if grep -q "source.*common.sh" "$installer" 2>/dev/null && ! grep -q "^detect_os" "$installer" 2>/dev/null; then
        issues="${issues}NO_DETECT_OS "
    fi
    
    # Check main function
    if ! grep -q "^main()" "$installer" 2>/dev/null; then
        issues="${issues}NO_MAIN "
    fi
    
    # Check if main calls an install function
    if grep -q "^main()" "$installer" 2>/dev/null; then
        # Get what main() calls
        main_calls=$(sed -n '/^main()/,/^}/p' "$installer" | grep -E "^\s+(install_|setup_)" | head -5)
        
        # Check each function that main calls
        while IFS= read -r line; do
            func_name=$(echo "$line" | sed 's/^\s*//;s/\s.*$//')
            if [[ -n "$func_name" ]]; then
                # Check if this function exists
                if ! grep -q "^${func_name}()" "$installer" 2>/dev/null; then
                    issues="${issues}MISSING:${func_name} "
                fi
            fi
        done <<< "$main_calls"
    fi
    
    # Check for sudo vs safe_sudo
    if grep -q "sudo apt" "$installer" 2>/dev/null && ! grep -q "safe_sudo apt" "$installer" 2>/dev/null; then
        issues="${issues}UNSAFE_SUDO "
    fi
    
    # Report issues
    if [[ -n "$issues" ]]; then
        echo "❌ $installer"
        echo "   Issues: $issues"
    else
        echo "✓ $tool_name"
    fi
done

echo
echo "=== Summary ==="
echo "NO_COMMON = doesn't source common.sh"
echo "NO_DETECT_OS = doesn't call detect_os"
echo "NO_MAIN = no main function"
echo "MISSING:func = main calls function that doesn't exist"
echo "UNSAFE_SUDO = uses sudo instead of safe_sudo"