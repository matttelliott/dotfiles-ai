#!/bin/bash
# Build and run test container for dotfiles

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Building dotfiles test container...${NC}"
docker build -f test/Dockerfile -t dotfiles-test .

echo -e "${GREEN}Build complete!${NC}"
echo ""
echo "To run the test container:"
echo "  docker run -it --rm dotfiles-test"
echo ""
echo "To run with live dotfiles mounted (for testing changes):"
echo "  docker run -it --rm -v \$(pwd):/home/testuser/dotfiles-ai-live:ro dotfiles-test"
echo ""
echo "To enter the container and test manually:"
echo "  docker run -it --rm dotfiles-test /bin/bash"