#!/bin/bash
# Test dotfiles installation in Docker container

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   DOTFILES-AI INSTALLATION TEST${NC}"
echo -e "${BLUE}=========================================${NC}"
echo

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${BLUE}Building test container...${NC}"
echo -e "${YELLOW}This will test the installation of all CLI tools${NC}"
echo

# Build the comprehensive test container
if docker build -f test/Dockerfile.comprehensive -t dotfiles-test-comprehensive . ; then
    echo
    echo -e "${GREEN}Build successful!${NC}"
    echo
    echo -e "${BLUE}Running installation test...${NC}"
    echo
    
    # Run the container and capture the test output
    docker run --rm dotfiles-test-comprehensive /home/testuser/test-tools.sh
    
    echo
    echo -e "${GREEN}Test complete!${NC}"
    echo
    echo -e "${BLUE}To explore the test container interactively:${NC}"
    echo "  docker run -it --rm dotfiles-test-comprehensive /bin/bash"
    echo
    echo -e "${BLUE}To check the installation log:${NC}"
    echo "  docker run --rm dotfiles-test-comprehensive cat /tmp/install.log"
else
    echo
    echo -e "${RED}Build failed!${NC}"
    echo -e "${YELLOW}Check the output above for errors${NC}"
    exit 1
fi