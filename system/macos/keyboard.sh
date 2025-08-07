#!/bin/bash
# macOS keyboard configuration
# Sets CapsLock -> Ctrl

set -e

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

setup_capslock_to_ctrl() {
    log_info "Setting up CapsLock -> Ctrl binding for macOS..."
    
    # Method 1: Using hidutil (modern macOS, macOS 10.12+)
    log_info "Configuring via hidutil..."
    
    # Apply the remapping immediately
    hidutil property --set '{"UserKeyMapping":[
        {
            "HIDKeyboardModifierMappingSrc": 0x700000039,
            "HIDKeyboardModifierMappingDst": 0x7000000E0
        }
    ]}' > /dev/null
    
    log_success "CapsLock -> Ctrl binding applied with hidutil"
    
    # Method 2: Create LaunchAgent for persistence across reboots
    log_info "Creating LaunchAgent for persistent configuration..."
    
    PLIST_PATH="$HOME/Library/LaunchAgents/com.user.capslock-to-ctrl.plist"
    
    # Create the LaunchAgent plist
    cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.capslock-to-ctrl</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
    
    # Load the LaunchAgent
    launchctl load -w "$PLIST_PATH" 2>/dev/null || true
    
    log_success "Created macOS LaunchAgent for persistent CapsLock -> Ctrl binding"
    
    # Method 3: System Preferences reminder (for older macOS or as alternative)
    log_info "Alternative method: System Preferences"
    log_info "  1. Open System Preferences → Keyboard → Modifier Keys"
    log_info "  2. Change 'Caps Lock' to 'Control'"
    log_info "  3. Click OK"
    
    log_success "CapsLock -> Ctrl configuration complete!"
}

# Main
main() {
    setup_capslock_to_ctrl
}

main "$@"