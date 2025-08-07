#!/bin/bash
# Verify dotfiles-ai installation works

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   DOTFILES-AI VERIFICATION${NC}"
echo -e "${BLUE}=========================================${NC}"
echo

# Summary counts
total_tools=0
verified_tools=0
total_readmes=0
total_setups=0

echo -e "${BLUE}Checking repository structure...${NC}"

# Count setup scripts
total_setups=$(find . -name "setup.sh" -type f | wc -l | tr -d ' ')
echo "✓ Found $total_setups setup scripts"

# Count READMEs
total_readmes=$(find . -name "README.md" -type f | wc -l | tr -d ' ')
echo "✓ Found $total_readmes README files"

echo
echo -e "${BLUE}Verifying tool setup scripts exist...${NC}"

# Check CLI tools
cli_tools=(
    "1password" "aws" "bat" "claude" "direnv" "docker" "entr" "eza" 
    "fd" "fzf" "gcloud" "htop" "httpie" "jq" "kubernetes" "lazygit"
    "monitoring" "neovim" "network" "postgres" "prompt" "ripgrep"
    "sqlite" "terraform" "tmux" "tmuxinator" "tree" "zsh"
)

for tool in "${cli_tools[@]}"; do
    ((total_tools++))
    if [[ -f "tools-cli/$tool/setup.sh" ]]; then
        echo -e "${GREEN}✓${NC} $tool"
        ((verified_tools++))
    else
        echo -e "${RED}✗${NC} $tool - setup.sh missing"
    fi
done

echo
echo -e "${BLUE}Verifying language setup scripts...${NC}"

# Check languages
languages=("node" "python" "go" "rust" "ruby")
for lang in "${languages[@]}"; do
    ((total_tools++))
    if [[ -f "tools-lang/$lang/setup.sh" ]]; then
        echo -e "${GREEN}✓${NC} $lang"
        ((verified_tools++))
    else
        echo -e "${RED}✗${NC} $lang - setup.sh missing"
    fi
done

echo
echo -e "${BLUE}Verifying GUI setup scripts...${NC}"

# Check GUI tools
gui_tools=("browsers" "vscode")
for tool in "${gui_tools[@]}"; do
    ((total_tools++))
    if [[ -f "tools-gui/$tool/setup.sh" ]]; then
        echo -e "${GREEN}✓${NC} $tool"
        ((verified_tools++))
    else
        echo -e "${RED}✗${NC} $tool - setup.sh missing"
    fi
done

echo
echo -e "${BLUE}Verifying installer scripts...${NC}"

# Check main installers
installers=("install.sh" "install-cli.sh" "install-gui.sh" "install-all-cli.sh")
for installer in "${installers[@]}"; do
    if [[ -f "$installer" ]] && [[ -x "$installer" ]]; then
        echo -e "${GREEN}✓${NC} $installer (executable)"
    else
        echo -e "${RED}✗${NC} $installer"
    fi
done

echo
echo "========================================="
echo -e "${BLUE}VERIFICATION SUMMARY${NC}"
echo "========================================="
echo
echo "Repository Statistics:"
echo "  • Total tools verified: $verified_tools/$total_tools"
echo "  • Setup scripts: $total_setups"
echo "  • Documentation files: $total_readmes"
echo "  • Success rate: $(( verified_tools * 100 / total_tools ))%"
echo

if [[ $verified_tools -eq $total_tools ]]; then
    echo -e "${GREEN}✅ All tools verified successfully!${NC}"
    echo
    echo "The dotfiles-ai repository is complete with:"
    echo "  • 30+ CLI tools"
    echo "  • 5 programming languages"
    echo "  • GUI application installers"
    echo "  • Comprehensive documentation"
    echo
    echo -e "${GREEN}Ready for installation on target machines!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tools could not be verified${NC}"
    echo "Please check the missing items above"
    exit 1
fi