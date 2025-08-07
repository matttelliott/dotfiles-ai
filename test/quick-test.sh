#!/bin/bash
# Quick local test of dotfiles structure

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   DOTFILES-AI STRUCTURE TEST${NC}"
echo -e "${BLUE}=========================================${NC}"
echo

# Test function
test_exists() {
    if [[ -e "$1" ]]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

echo "Testing installation scripts:"
test_exists "install.sh" "Main installer"
test_exists "install-cli.sh" "CLI installer"
test_exists "install-gui.sh" "GUI installer"
test_exists "install-all-cli.sh" "Comprehensive CLI installer"

echo
echo "Testing system setup:"
test_exists "system/debian/setup.sh" "Debian setup"
test_exists "system/macos/setup.sh" "macOS setup"

echo
echo "Testing CLI tools:"
for tool in zsh tmux neovim fzf ripgrep fd bat eza tree jq htop lazygit httpie entr direnv tmuxinator aws gcloud terraform docker kubernetes postgres sqlite network monitoring claude prompt 1password; do
    test_exists "tools-cli/$tool/setup.sh" "$tool setup"
done

echo
echo "Testing languages:"
for lang in node python go rust ruby; do
    test_exists "tools-lang/$lang/setup.sh" "$lang setup"
done

echo
echo "Testing GUI tools:"
test_exists "tools-gui/browsers/setup.sh" "Browsers setup"
test_exists "tools-gui/vscode/setup.sh" "VS Code setup"

echo
echo "Testing documentation:"
# Count READMEs
readme_count=$(find . -name "README.md" -type f | wc -l)
echo -e "${BLUE}Found ${readme_count} README files${NC}"

# Count setup scripts
setup_count=$(find . -name "setup.sh" -type f | wc -l)
echo -e "${BLUE}Found ${setup_count} setup scripts${NC}"

echo
echo "========================================="
echo -e "${GREEN}Structure test complete!${NC}"
echo "========================================="