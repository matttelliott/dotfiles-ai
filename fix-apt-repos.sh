#!/bin/bash
# Fix APT repository issues for Linux Mint 22

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Fixing APT Repository Issues ===${NC}\n"

# 1. Fix PostgreSQL repository
echo -e "${BLUE}1. Fixing PostgreSQL repository...${NC}"
if [[ -f /etc/apt/sources.list.d/pgdg.list ]]; then
    echo "   Current content:"
    cat /etc/apt/sources.list.d/pgdg.list
    
    # PostgreSQL doesn't support Linux Mint directly, use Ubuntu jammy instead
    echo -e "\n   ${YELLOW}Updating to use Ubuntu 22.04 (jammy) repository...${NC}"
    echo "deb http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
    
    echo -e "   ${GREEN}✓ PostgreSQL repository fixed${NC}"
else
    echo -e "   ${YELLOW}PostgreSQL repository not found${NC}"
fi

echo

# 2. Fix Google Chrome duplicate entries
echo -e "${BLUE}2. Fixing Google Chrome repository...${NC}"
if [[ -f /etc/apt/sources.list.d/google-chrome.list ]]; then
    echo "   Current content:"
    cat /etc/apt/sources.list.d/google-chrome.list
    
    echo -e "\n   ${YELLOW}Removing duplicates...${NC}"
    # Keep only one line
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    
    echo -e "   ${GREEN}✓ Chrome repository fixed${NC}"
else
    echo -e "   ${YELLOW}Chrome repository not found${NC}"
fi

echo

# 3. Update APT cache
echo -e "${BLUE}3. Updating APT cache...${NC}"
if sudo apt-get update 2>&1 | tee /tmp/apt-update.log | grep -E "^E:|^W:"; then
    echo -e "\n${YELLOW}Some warnings/errors remain (see /tmp/apt-update.log)${NC}"
else
    echo -e "${GREEN}✓ APT cache updated successfully${NC}"
fi

echo
echo -e "${GREEN}=== Repository fixes applied ===${NC}"
echo
echo "If you still see errors, you may need to:"
echo "1. Remove the PostgreSQL repository if not needed:"
echo "   sudo rm /etc/apt/sources.list.d/pgdg.list"
echo "2. Or install the PostgreSQL GPG key:"
echo "   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -"