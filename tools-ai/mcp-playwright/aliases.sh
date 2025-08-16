# Playwright MCP aliases and functions

# Test Playwright MCP server
playwright-mcp-test() {
    if [[ -f "$DOTFILES_DIR/tools-ai/mcp-playwright/test-server.js" ]]; then
        node "$DOTFILES_DIR/tools-ai/mcp-playwright/test-server.js"
    else
        echo "MCP test script not found"
    fi
}

# Show MCP configuration
playwright-mcp-status() {
    echo "Playwright MCP Configuration:"
    echo
    echo "Claude Desktop config:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cat "$HOME/Library/Application Support/Claude/claude_desktop_config.json" 2>/dev/null | grep -A5 "playwright" || echo "Not configured"
    else
        cat "$HOME/.config/Claude/claude_desktop_config.json" 2>/dev/null | grep -A5 "playwright" || echo "Not configured"
    fi
    
    echo
    echo "Claude CLI config:"
    cat "$DOTFILES_DIR/.mcp.json" 2>/dev/null | grep -A5 "playwright" || echo "Not configured"
    
    echo
    echo "Playwright installation:"
    if [[ -d "$DOTFILES_DIR/tools-ai/mcp-playwright/node_modules/playwright" ]]; then
        echo "✓ Playwright is installed"
        npx playwright --version 2>/dev/null || echo "Version check failed"
    else
        echo "✗ Playwright not installed"
    fi
}

# Launch Playwright inspector
playwright-inspector() {
    cd "$DOTFILES_DIR/tools-ai/mcp-playwright"
    npx playwright test --ui
}

# Open Playwright documentation
playwright-docs() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "https://playwright.dev"
    elif command -v open >/dev/null 2>&1; then
        open "https://playwright.dev"
    else
        echo "Visit: https://playwright.dev"
    fi
}

# Install/update Playwright browsers
playwright-update-browsers() {
    cd "$DOTFILES_DIR/tools-ai/mcp-playwright"
    npx playwright install
}

# Quick browser launch for testing
playwright-browser() {
    local browser="${1:-chromium}"
    cd "$DOTFILES_DIR/tools-ai/mcp-playwright"
    npx playwright open "$browser"
}
