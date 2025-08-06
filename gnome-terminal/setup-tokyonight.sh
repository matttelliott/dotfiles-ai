#!/bin/bash

# Tokyo Night color scheme for GNOME Terminal
# Based on the popular Tokyo Night theme

set -e

# Get the default profile UUID
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

# If no default profile, get the first one
if [ -z "$PROFILE" ]; then
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList list | grep -oP "[a-f0-9-]+" | head -1)
fi

# Profile path
PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/"

echo "🎨 Applying Tokyo Night color scheme to GNOME Terminal..."
echo "   Profile: $PROFILE"

# Tokyo Night color palette
PALETTE="['#15161e', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#a9b1d6', '#414868', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#c0caf5']"

# Background and foreground colors
BACKGROUND_COLOR="'#1a1b26'"
FOREGROUND_COLOR="'#c0caf5'"
BOLD_COLOR="'#c0caf5'"
CURSOR_BACKGROUND_COLOR="'#c0caf5'"
CURSOR_FOREGROUND_COLOR="'#1a1b26'"
HIGHLIGHT_BACKGROUND_COLOR="'#283457'"
HIGHLIGHT_FOREGROUND_COLOR="'#c0caf5'"

# Apply the color scheme
gsettings set "${PROFILE_PATH}" use-theme-colors false
gsettings set "${PROFILE_PATH}" background-color "${BACKGROUND_COLOR}"
gsettings set "${PROFILE_PATH}" foreground-color "${FOREGROUND_COLOR}"
gsettings set "${PROFILE_PATH}" bold-color "${BOLD_COLOR}"
gsettings set "${PROFILE_PATH}" bold-color-same-as-fg false
gsettings set "${PROFILE_PATH}" cursor-background-color "${CURSOR_BACKGROUND_COLOR}"
gsettings set "${PROFILE_PATH}" cursor-foreground-color "${CURSOR_FOREGROUND_COLOR}"
gsettings set "${PROFILE_PATH}" cursor-colors-set true
gsettings set "${PROFILE_PATH}" highlight-background-color "${HIGHLIGHT_BACKGROUND_COLOR}"
gsettings set "${PROFILE_PATH}" highlight-foreground-color "${HIGHLIGHT_FOREGROUND_COLOR}"
gsettings set "${PROFILE_PATH}" highlight-colors-set true
gsettings set "${PROFILE_PATH}" palette "${PALETTE}"

# Optional: Set font (uncomment if you want to set a specific font)
# gsettings set "${PROFILE_PATH}" use-system-font false
# gsettings set "${PROFILE_PATH}" font 'JetBrainsMono Nerd Font 11'

# Optional: Set transparency (uncomment for slight transparency)
# gsettings set "${PROFILE_PATH}" background-transparency-percent 5
# gsettings set "${PROFILE_PATH}" use-transparent-background true

echo "✅ Tokyo Night color scheme applied successfully!"
echo "   You may need to close and reopen your terminal for changes to take full effect."