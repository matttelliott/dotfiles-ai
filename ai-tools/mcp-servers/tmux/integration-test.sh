#!/usr/bin/env bash

# Integration test for Tmux MCP Server
# Tests the complete installation and basic functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_test() { echo -e "${YELLOW}[TEST]${NC} $*"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $*"; }

# Test configuration
DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
MCP_SERVER_DIR="${DOTFILES_DIR}/mcp-servers/tmux"
TEST_SESSION="mcp-integration-test"

cleanup() {
    log_test "Cleaning up test session..."
    tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true
}

# Cleanup on exit
trap cleanup EXIT

log_test "Starting Tmux MCP Server Integration Test..."
echo "=========================================="

# Test 1: Check if all files exist
log_test "Checking required files..."
required_files=(
    "$MCP_SERVER_DIR/server.js"
    "$MCP_SERVER_DIR/package.json"
    "$MCP_SERVER_DIR/install"
    "$MCP_SERVER_DIR/README.md"
    "$MCP_SERVER_DIR/examples.md"
    "$MCP_SERVER_DIR/claude-config.json"
    "$MCP_SERVER_DIR/claude-desktop-config.json"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        log_pass "Found: $(basename "$file")"
    else
        log_fail "Missing: $file"
        exit 1
    fi
done

# Test 2: Check if server script is executable
log_test "Checking server script permissions..."
if [[ -x "$MCP_SERVER_DIR/server.js" ]]; then
    log_pass "Server script is executable"
else
    log_fail "Server script is not executable"
    exit 1
fi

# Test 3: Check Node.js syntax
log_test "Checking Node.js syntax..."
if node -c "$MCP_SERVER_DIR/server.js"; then
    log_pass "Server syntax is valid"
else
    log_fail "Server syntax check failed"
    exit 1
fi

# Test 4: Check dependencies
log_test "Checking system dependencies..."

if command -v tmux >/dev/null 2>&1; then
    log_pass "tmux is available"
else
    log_fail "tmux is not installed"
    exit 1
fi

if command -v node >/dev/null 2>&1; then
    log_pass "Node.js is available"
    NODE_VERSION=$(node --version)
    log_pass "Node.js version: $NODE_VERSION"
else
    log_fail "Node.js is not installed"
    exit 1
fi

# Test 5: Test basic tmux operations
log_test "Testing basic tmux operations..."

# Create a test session
if tmux new-session -d -s "$TEST_SESSION" -c "$HOME"; then
    log_pass "Created test tmux session"
else
    log_fail "Failed to create test tmux session"
    exit 1
fi

# Check if session exists
if tmux has-session -t "$TEST_SESSION" 2>/dev/null; then
    log_pass "Test session is accessible"
else
    log_fail "Test session is not accessible"
    exit 1
fi

# Send a test command
if tmux send-keys -t "$TEST_SESSION" "echo 'MCP test message'" Enter; then
    log_pass "Successfully sent command to test session"
else
    log_fail "Failed to send command to test session"
    exit 1
fi

# Wait a moment for command to execute
sleep 1

# Capture pane content
if tmux capture-pane -t "$TEST_SESSION" -p | grep -q "MCP test message"; then
    log_pass "Successfully captured pane content"
else
    log_fail "Failed to capture expected pane content"
    exit 1
fi

# Test 6: Test MCP server loading (basic syntax and module structure)
log_test "Testing MCP server module loading..."

# Create a simple test script to verify the server can be required
cat > /tmp/mcp-test.js << EOF
try {
    const TmuxMCPServer = require('${MCP_SERVER_DIR}/server.js');
    const server = new TmuxMCPServer();
    
    // Check if server has expected methods
    const expectedMethods = [
        'listSessions',
        'readPane', 
        'getPaneInfo',
        'sendCommand',
        'createSession',
        'killSession',
        'handleToolCall'
    ];
    
    for (const method of expectedMethods) {
        if (typeof server[method] !== 'function') {
            throw new Error(`Missing method: ${method}`);
        }
    }
    
    // Check if tools are defined
    if (!Array.isArray(server.tools) || server.tools.length === 0) {
        throw new Error('No tools defined');
    }
    
    console.log('SUCCESS: MCP server module loaded correctly');
    console.log(`Found ${server.tools.length} tools defined`);
    
} catch (error) {
    console.error('ERROR:', error.message);
    process.exit(1);
}
EOF

cd "$MCP_SERVER_DIR"
if node /tmp/mcp-test.js; then
    log_pass "MCP server module loads correctly"
else
    log_fail "MCP server module failed to load"
    rm -f /tmp/mcp-test.js
    exit 1
fi

rm -f /tmp/mcp-test.js

# Test 7: Test server instantiation and basic operations
log_test "Testing server basic operations..."

# Create a more comprehensive test
cat > /tmp/mcp-operations-test.js << EOF
const TmuxMCPServer = require('${MCP_SERVER_DIR}/server.js');

async function testBasicOperations() {
    const server = new TmuxMCPServer();
    
    try {
        // Test 1: List sessions
        console.log('Testing listSessions...');
        const sessions = await server.listSessions(false);
        console.log(`Found ${sessions.sessions ? sessions.sessions.length : 0} sessions`);
        
        // Test 2: Test tmux command execution
        console.log('Testing tmux command execution...');
        const result = await server.execTmux('list-sessions').catch(err => {
            if (err.message.includes('no server running')) {
                return 'no server running (expected)';
            }
            throw err;
        });
        console.log('Tmux command test passed');
        
        // Test 3: Test tool call handling
        console.log('Testing tool call handling...');
        const toolResult = await server.handleToolCall('tmux_list_sessions', { include_details: false });
        console.log('Tool call handling test passed');
        
        console.log('SUCCESS: All basic operations work correctly');
        
    } catch (error) {
        console.error('ERROR in basic operations:', error.message);
        process.exit(1);
    }
}

testBasicOperations();
EOF

if node /tmp/mcp-operations-test.js; then
    log_pass "Server basic operations work correctly"
else
    log_fail "Server basic operations failed"
    rm -f /tmp/mcp-operations-test.js
    exit 1
fi

rm -f /tmp/mcp-operations-test.js

# Test 8: Check configuration files
log_test "Checking configuration file formats..."

# Test JSON syntax of config files
for config_file in "$MCP_SERVER_DIR/claude-config.json" "$MCP_SERVER_DIR/claude-desktop-config.json" "$MCP_SERVER_DIR/package.json"; do
    if node -e "JSON.parse(require('fs').readFileSync('$config_file', 'utf8')); console.log('Valid JSON: $(basename "$config_file")')"; then
        log_pass "Valid JSON: $(basename "$config_file")"
    else
        log_fail "Invalid JSON: $(basename "$config_file")"
        exit 1
    fi
done

# Test 9: Check if aliases would be created properly
log_test "Checking alias configuration..."

if [[ -f "${DOTFILES_DIR}/tools-cli/zsh/zshrc" ]]; then
    log_pass "Found zsh configuration for alias integration"
else
    log_fail "zsh configuration not found - aliases may not work"
fi

# Final summary
echo ""
echo "=========================================="
log_pass "All integration tests passed!"
echo ""
echo "The Tmux MCP Server is ready for use with Claude CLI"
echo ""
echo "Next steps:"
echo "  1. Run the installation script: ./mcp-servers/tmux/install"
echo "  2. Restart Claude CLI to load the MCP server"
echo "  3. Test with Claude: 'List my tmux sessions'"
echo ""
echo "Test session '$TEST_SESSION' will be cleaned up automatically."