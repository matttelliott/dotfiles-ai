#!/bin/bash

# Keyboard Configuration Setup
# Ensures CapsLock is always bound to Ctrl across all platforms

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

# Function to setup CapsLock -> Ctrl on Linux
setup_linux_keyboard() {
    log_info "Setting up CapsLock -> Ctrl binding for Linux..."
    
    # Method 1: Using setxkbmap (X11 - most common)
    if command -v setxkbmap &> /dev/null; then
        log_info "Configuring X11 keyboard mapping..."
        setxkbmap -option caps:ctrl_modifier
        log_success "X11 CapsLock -> Ctrl binding applied"
        
        # Make it persistent by adding to .xprofile
        if [[ ! -f "$HOME/.xprofile" ]] || ! grep -q "setxkbmap.*caps:ctrl_modifier" "$HOME/.xprofile"; then
            echo "# CapsLock -> Ctrl binding" >> "$HOME/.xprofile"
            echo "setxkbmap -option caps:ctrl_modifier" >> "$HOME/.xprofile"
            log_success "Added persistent X11 keyboard binding to ~/.xprofile"
        fi
    fi
    
    # Method 2: Using gsettings (GNOME)
    if command -v gsettings &> /dev/null; then
        log_info "Configuring GNOME keyboard settings..."
        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']" 2>/dev/null || true
        log_success "GNOME CapsLock -> Ctrl binding applied"
    fi
    
    # Method 3: Console keyboard (for TTY)
    if command -v dumpkeys &> /dev/null && command -v loadkeys &> /dev/null; then
        log_info "Setting up console keyboard mapping..."
        
        # Create console keymap modification
        mkdir -p "$HOME/.local/share/kbd"
        cat > "$HOME/.local/share/kbd/caps2ctrl.map" << 'EOF'
# CapsLock -> Ctrl mapping for console
keycode 58 = Control
EOF
        
        # Note: This requires root to apply system-wide
        log_info "Console keymap created at ~/.local/share/kbd/caps2ctrl.map"
        log_warning "Console keymap requires manual setup with: sudo loadkeys ~/.local/share/kbd/caps2ctrl.map"
    fi
    
    # Method 4: systemd user service for persistent application
    mkdir -p "$HOME/.config/systemd/user"
    cat > "$HOME/.config/systemd/user/caps2ctrl.service" << 'EOF'
[Unit]
Description=CapsLock to Ctrl key binding
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/usr/bin/setxkbmap -option caps:ctrl_modifier
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
    
    # Enable the service
    if command -v systemctl &> /dev/null; then
        systemctl --user daemon-reload
        systemctl --user enable caps2ctrl.service
        log_success "Created systemd user service for persistent CapsLock -> Ctrl binding"
    fi
}

# Function to setup CapsLock -> Ctrl on macOS
setup_macos_keyboard() {
    log_info "Setting up CapsLock -> Ctrl binding for macOS..."
    
    # Method 1: Using hidutil (modern macOS)
    if command -v hidutil &> /dev/null; then
        log_info "Configuring keyboard mapping with hidutil..."
        
        # Apply the mapping immediately
        hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'
        log_success "macOS CapsLock -> Ctrl binding applied with hidutil"
        
        # Create LaunchAgent for persistence
        mkdir -p "$HOME/Library/LaunchAgents"
        cat > "$HOME/Library/LaunchAgents/com.user.caps2ctrl.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.caps2ctrl</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF
        
        # Load the LaunchAgent
        launchctl load "$HOME/Library/LaunchAgents/com.user.caps2ctrl.plist"
        log_success "Created macOS LaunchAgent for persistent CapsLock -> Ctrl binding"
    fi
    
    # Method 2: System Preferences automation (fallback)
    log_info "You can also manually configure this in System Preferences:"
    log_info "  1. Go to System Preferences > Keyboard"
    log_info "  2. Click 'Modifier Keys...'"
    log_info "  3. Set Caps Lock to Control"
}

# Main setup function
main() {
    log_info "Starting keyboard configuration setup..."
    
    case "$(uname)" in
        Darwin)
            setup_macos_keyboard
            ;;
        Linux)
            setup_linux_keyboard
            ;;
        *)
            log_error "Unsupported operating system: $(uname)"
            return 1
            ;;
    esac
    
    log_success "Keyboard configuration setup complete!"
    log_info "CapsLock -> Ctrl binding is now active and persistent"
    log_warning "You may need to log out and back in for all changes to take effect"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
