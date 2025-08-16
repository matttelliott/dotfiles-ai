#!/usr/bin/env bash

# Playwright MCP Server Setup Script
# Installs and configures Playwright MCP server for Claude Desktop and CLI

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common utilities
if [[ -f "$DOTFILES_DIR/utils/common.sh" ]]; then
    source "$DOTFILES_DIR/utils/common.sh"
else
    # Fallback logging functions
    log_info() { echo "[INFO] $*"; }
    log_success() { echo "[SUCCESS] $*"; }
    log_warning() { echo "[WARNING] $*"; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

log_info "Setting up Playwright MCP Server for Claude integration..."

# Check for Node.js
check_node() {
    if ! command -v node >/dev/null 2>&1; then
        log_warning "Node.js is not installed. Please install Node.js first."
        log_info "You can install it via: $DOTFILES_DIR/tools-lang/node/setup.sh"
        exit 1
    fi
    
    # Check Node.js version (requires >= 14)
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $NODE_VERSION -lt 14 ]]; then
        log_error "Node.js version 14 or higher required. Current: $(node --version)"
        exit 1
    fi
    
    log_success "Node.js is installed: $(node --version)"
}

# Check for npm
check_npm() {
    if ! command -v npm >/dev/null 2>&1; then
        log_error "npm is not installed. Please install Node.js with npm."
        exit 1
    fi
    log_success "npm is installed: $(npm --version)"
}

# Install Playwright and dependencies
install_playwright() {
    log_info "Installing Playwright and dependencies..."
    
    cd "$SCRIPT_DIR"
    
    # Install npm packages
    log_info "Installing npm packages..."
    npm install
    
    # Install browser binaries
    log_info "Installing browser binaries (Chromium, Firefox, WebKit)..."
    log_info "This may take a few minutes and requires ~500MB of disk space..."
    npx playwright install
    
    # Install system dependencies for browsers
    log_info "Checking system dependencies for browsers..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "macOS detected - browser dependencies should be handled automatically"
    elif [[ -f /etc/debian_version ]]; then
        log_info "Installing system dependencies for browsers on Debian/Ubuntu..."
        # Playwright can install its own deps
        npx playwright install-deps || {
            log_warning "Could not install system dependencies automatically."
            log_warning "You may need to run: sudo npx playwright install-deps"
        }
    else
        log_warning "Please ensure browser dependencies are installed for your system"
        log_warning "See: https://playwright.dev/docs/browsers#install-system-dependencies"
    fi
    
    log_success "Playwright installation complete"
}

# Setup MCP configuration for Claude Desktop
setup_claude_desktop_config() {
    log_info "Configuring Claude Desktop MCP integration..."
    
    # Determine Claude Desktop config directory based on platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
    else
        # Linux
        CLAUDE_CONFIG_DIR="$HOME/.config/Claude"
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$CLAUDE_CONFIG_DIR"
    
    # Check if configuration already exists
    CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
    
    if [[ -f "$CONFIG_FILE" ]]; then
        # Check if playwright server is already configured
        if grep -q "mcp-playwright" "$CONFIG_FILE" 2>/dev/null; then
            log_info "Playwright MCP already configured in Claude Desktop"
        else
            # Backup existing config
            cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Add playwright server to existing config
            log_info "Adding Playwright MCP to existing Claude Desktop configuration..."
            
            # Create a new merged config
            cat > "$CONFIG_FILE.tmp" << EOF
{
  "mcpServers": {
    "tmux": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-tmux/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "neovim": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-neovim/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "playwright": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-playwright/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        fi
    else
        # Create new configuration
        cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "playwright": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-playwright/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
    fi
    
    log_success "Claude Desktop configuration updated at: $CONFIG_FILE"
}

# Setup MCP configuration for Claude CLI
setup_claude_cli_config() {
    log_info "Configuring Claude CLI MCP integration..."
    
    # The .mcp.json file in the dotfiles root
    MCP_CONFIG_FILE="$DOTFILES_DIR/.mcp.json"
    
    if [[ -f "$MCP_CONFIG_FILE" ]]; then
        # Check if playwright is already configured
        if grep -q "playwright" "$MCP_CONFIG_FILE" 2>/dev/null; then
            log_info "Playwright MCP already configured in Claude CLI"
        else
            # Backup and update
            cp "$MCP_CONFIG_FILE" "$MCP_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Create updated config with all servers
            cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "tmux": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-tmux/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "neovim": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-neovim/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "playwright": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-playwright/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
        fi
    else
        # Create new config
        cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "playwright": {
      "command": "node",
      "args": ["$DOTFILES_DIR/tools-ai/mcp-playwright/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
    fi
    
    log_success "Claude CLI configuration updated at: $MCP_CONFIG_FILE"
}

# Create test script
create_test_script() {
    log_info "Creating test script..."
    
    cat > "$SCRIPT_DIR/test-server.js" << 'EOF'
#!/usr/bin/env node

/**
 * Test script for Playwright MCP Server
 */

const PlaywrightMCPServer = require('./server.js');

async function runTests() {
    console.log('Testing Playwright MCP Server...\n');
    
    const server = new PlaywrightMCPServer();
    
    try {
        // Test 1: Initialize server
        console.log('Test 1: Initializing server...');
        const init = await server.initialize();
        if (init.initialized) {
            console.log('✓ Server initialized');
            console.log('  Screenshot directory:', init.screenshotDir);
        } else {
            console.log('✗ Failed to initialize:', init.error);
            return;
        }
        console.log();
        
        // Test 2: Launch browser (headless)
        console.log('Test 2: Launching headless browser...');
        const browser = await server.launchBrowser('chromium', { headless: true });
        if (browser.success) {
            console.log('✓ Browser launched');
            console.log('  Browser ID:', browser.browserId);
            console.log('  Type:', browser.type);
            console.log('  Headless:', browser.headless);
            
            // Test 3: Create context
            console.log('\nTest 3: Creating browser context...');
            const context = await server.createContext(browser.browserId, {
                viewport: { width: 1280, height: 720 }
            });
            if (context.success) {
                console.log('✓ Context created');
                console.log('  Context ID:', context.contextId);
                console.log('  Viewport:', context.viewport);
                
                // Test 4: Create page
                console.log('\nTest 4: Creating new page...');
                const page = await server.newPage(context.contextId, 'https://example.com');
                if (page.success) {
                    console.log('✓ Page created and navigated');
                    console.log('  Page ID:', page.pageId);
                    console.log('  URL:', page.url);
                    
                    // Test 5: Get page title
                    console.log('\nTest 5: Getting page title...');
                    const title = await server.getTitle(page.pageId);
                    if (title.success) {
                        console.log('✓ Got page title:', title.title);
                    }
                    
                    // Test 6: Get page text
                    console.log('\nTest 6: Getting page text...');
                    const text = await server.getText(page.pageId, 'h1');
                    if (text.success) {
                        console.log('✓ Got h1 text:', text.text);
                    }
                    
                    // Test 7: Take screenshot
                    console.log('\nTest 7: Taking screenshot...');
                    const screenshot = await server.screenshot(page.pageId, {
                        filename: 'test-screenshot.png'
                    });
                    if (screenshot.success) {
                        console.log('✓ Screenshot saved');
                        console.log('  Path:', screenshot.path);
                    }
                    
                    // Clean up
                    console.log('\nCleaning up...');
                    await server.closePage(page.pageId);
                    console.log('✓ Page closed');
                }
                
                await server.closeContext(context.contextId);
                console.log('✓ Context closed');
            }
            
            await server.closeBrowser(browser.browserId);
            console.log('✓ Browser closed');
            
        } else {
            console.log('✗ Failed to launch browser:', browser.error);
        }
        
        // Test 8: List sessions (should be empty)
        console.log('\nTest 8: Listing sessions...');
        const sessions = await server.listSessions();
        console.log('Active sessions:');
        console.log('  Browsers:', sessions.browsers.length);
        console.log('  Contexts:', sessions.contexts.length);
        console.log('  Pages:', sessions.pages.length);
        
        console.log('\n🎉 All tests completed!');
        console.log('\nPlaywright MCP Server is ready for use with Claude.');
        console.log('\nExample Claude commands:');
        console.log('  "Launch a browser and go to example.com"');
        console.log('  "Click the login button"');
        console.log('  "Fill the username field with test@example.com"');
        console.log('  "Take a screenshot of the page"');
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    runTests().then(() => process.exit(0));
}
EOF
    
    chmod +x "$SCRIPT_DIR/test-server.js"
    log_success "Test script created"
}

# Create shell aliases
setup_shell_integration() {
    log_info "Setting up shell integration..."
    
    # Create aliases file
    ALIASES_FILE="$SCRIPT_DIR/aliases.sh"
    cat > "$ALIASES_FILE" << 'EOF'
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
EOF
    
    # Source in shell configs
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "mcp-playwright/aliases.sh" "$rc"; then
                echo "" >> "$rc"
                echo "# Playwright MCP integration" >> "$rc"
                echo "[[ -f \"$ALIASES_FILE\" ]] && source \"$ALIASES_FILE\"" >> "$rc"
                log_success "Added Playwright MCP aliases to $(basename "$rc")"
            fi
        fi
    done
}

# Create example scripts directory
create_examples() {
    log_info "Creating example scripts..."
    
    mkdir -p "$SCRIPT_DIR/examples"
    
    # Create a simple web scraping example
    cat > "$SCRIPT_DIR/examples/scrape-example.js" << 'EOF'
#!/usr/bin/env node

// Example: Web scraping with Playwright MCP Server

const PlaywrightMCPServer = require('../server.js');

async function scrapeExample() {
    const server = new PlaywrightMCPServer();
    await server.initialize();
    
    // Launch browser
    const browser = await server.launchBrowser('chromium', { headless: true });
    const context = await server.createContext(browser.browserId);
    const page = await server.newPage(context.contextId);
    
    // Navigate to a website
    await server.navigate(page.pageId, 'https://news.ycombinator.com');
    
    // Get all links on the page
    const links = await server.queryElements(page.pageId, 'a.storylink, a.titleline');
    
    console.log('Top stories:');
    links.elements.slice(0, 10).forEach((link, i) => {
        console.log(`${i + 1}. ${link.text}`);
    });
    
    // Clean up
    await server.closeBrowser(browser.browserId);
}

scrapeExample().catch(console.error);
EOF
    
    chmod +x "$SCRIPT_DIR/examples/scrape-example.js"
    log_success "Example scripts created in $SCRIPT_DIR/examples/"
}

# Main installation flow
main() {
    log_info "Installing Playwright MCP Server..."
    
    check_node
    check_npm
    install_playwright
    setup_claude_desktop_config
    setup_claude_cli_config
    create_test_script
    setup_shell_integration
    create_examples
    
    log_success "Playwright MCP Server installation complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    echo "  2. Restart Claude Desktop and/or CLI to load the MCP server"
    echo "  3. Test with: playwright-mcp-test"
    echo "  4. Check status with: playwright-mcp-status"
    echo ""
    log_info "Available commands:"
    echo "  playwright-mcp-test         - Test MCP server functionality"
    echo "  playwright-mcp-status       - Check MCP configuration"
    echo "  playwright-inspector        - Launch Playwright inspector"
    echo "  playwright-update-browsers  - Update browser binaries"
    echo "  playwright-browser [type]   - Launch a browser for testing"
    echo ""
    log_info "Example usage in Claude:"
    echo '  "Launch a browser and navigate to google.com"'
    echo '  "Search for Playwright documentation"'
    echo '  "Take a screenshot of the results"'
    echo '  "Extract all the links from the page"'
}

main "$@"