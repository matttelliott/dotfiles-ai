#!/bin/bash
# Debian/Ubuntu keyboard configuration
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
    log_info "Setting up CapsLock -> Ctrl binding for Debian/Ubuntu..."
    
    # Method 1: GNOME/GTK Settings (for GNOME-based desktops)
    if command -v gsettings &> /dev/null; then
        log_info "Configuring via gsettings (GNOME)..."
        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
        log_success "GNOME keyboard settings updated"
    fi
    
    # Method 2: X11 configuration (persistent across X sessions)
    if [[ -n "$DISPLAY" ]]; then
        log_info "Configuring for X11..."
        
        # Create xkb options file
        sudo mkdir -p /etc/X11/xorg.conf.d/
        sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbOptions" "caps:ctrl_modifier"
EndSection
EOF
        log_success "X11 keyboard configuration created"
        
        # Apply immediately if in X session
        if command -v setxkbmap &> /dev/null; then
            setxkbmap -option caps:ctrl_modifier
            log_success "Applied keyboard mapping to current X session"
        fi
    fi
    
    # Method 3: Console configuration (for TTY)
    log_info "Configuring for console/TTY..."
    if command -v loadkeys &> /dev/null; then
        # Create custom keymap for console
        sudo mkdir -p /etc/console-setup/
        echo "keycode 58 = Control" | sudo tee /etc/console-setup/remap.inc > /dev/null
        
        # Update console-setup configuration
        if [[ -f /etc/default/keyboard ]]; then
            # Backup original
            sudo cp /etc/default/keyboard /etc/default/keyboard.backup
            
            # Add or update XKBOPTIONS
            if grep -q "^XKBOPTIONS=" /etc/default/keyboard; then
                sudo sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="caps:ctrl_modifier"/' /etc/default/keyboard
            else
                echo 'XKBOPTIONS="caps:ctrl_modifier"' | sudo tee -a /etc/default/keyboard > /dev/null
            fi
            
            # Apply changes
            sudo dpkg-reconfigure -phigh console-setup 2>/dev/null || true
            log_success "Console keyboard configuration updated"
        fi
    fi
    
    # Method 4: Wayland configuration (for Wayland sessions)
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        log_info "Detected Wayland session..."
        log_info "Wayland uses compositor-specific settings (already configured via gsettings for GNOME)"
    fi
    
    log_success "CapsLock -> Ctrl configuration complete!"
    log_info "You may need to restart your session for all changes to take effect"
}

# Main
main() {
    setup_capslock_to_ctrl
}

main "$@"