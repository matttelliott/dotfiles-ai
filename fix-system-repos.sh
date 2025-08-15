#!/bin/bash
# Fix system repository issues (run with sudo)

echo "=== Fixing System Repository Issues ==="
echo "This script needs to be run with sudo to fix system repositories"
echo

# Fix PostgreSQL repository
echo "1. Fixing PostgreSQL repository..."
if [ -f /etc/apt/sources.list.d/pgdg.list ]; then
    echo "   Found PostgreSQL repository file"
    # Check current content
    if grep -q "wilma-pgdg" /etc/apt/sources.list.d/pgdg.list; then
        echo "   Fixing wilma -> noble (Mint 22 uses Ubuntu 24.04 base)"
        sudo sed -i 's/wilma-pgdg/noble-pgdg/g' /etc/apt/sources.list.d/pgdg.list
        echo "   ✓ PostgreSQL repository fixed"
    else
        echo "   PostgreSQL repository already correct"
    fi
else
    echo "   No PostgreSQL repository found"
fi

# Fix Chrome duplicate entries
echo
echo "2. Fixing Chrome repository duplicates..."
if [ -f /etc/apt/sources.list.d/google-chrome.list ]; then
    echo "   Found Chrome repository file"
    # Check for duplicates
    lines=$(wc -l < /etc/apt/sources.list.d/google-chrome.list)
    if [ "$lines" -gt 1 ]; then
        echo "   Found $lines lines (duplicates detected)"
        echo "   Current content:"
        cat /etc/apt/sources.list.d/google-chrome.list | nl
        echo
        echo "   Removing duplicates..."
        # Keep only unique lines
        sort -u /etc/apt/sources.list.d/google-chrome.list > /tmp/google-chrome.list.tmp
        sudo mv /tmp/google-chrome.list.tmp /etc/apt/sources.list.d/google-chrome.list
        echo "   ✓ Duplicates removed"
    else
        echo "   No duplicates found"
    fi
    
    # Check if using legacy key format
    if ! grep -q "signed-by=" /etc/apt/sources.list.d/google-chrome.list; then
        echo "   Note: Chrome uses legacy apt-key format (this is OK but shows warnings)"
    fi
else
    echo "   No Chrome repository found"
fi

# Clean and update
echo
echo "3. Cleaning APT cache..."
sudo apt-get clean

echo
echo "4. Updating package lists..."
sudo apt-get update

echo
echo "=== Repository Fixes Complete ==="
echo
echo "To run this fix:"
echo "  sudo bash $0"
echo
echo "To permanently suppress these warnings in the dotfiles installer,"
echo "they are already being filtered by safe_apt_update()"