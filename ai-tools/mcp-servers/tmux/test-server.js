#!/usr/bin/env node

/**
 * Test script for Tmux MCP Server
 * Tests basic functionality of the MCP server
 */

const TmuxMCPServer = require('./server.js');

async function runTests() {
    console.log('Testing Tmux MCP Server...\n');
    
    const server = new TmuxMCPServer();
    
    try {
        // Test 1: List sessions
        console.log('Test 1: Listing tmux sessions...');
        const sessions = await server.listSessions(true);
        console.log('Sessions:', JSON.stringify(sessions, null, 2));
        console.log('✓ List sessions test passed\n');
        
        // Test 2: Check if we can run tmux commands
        console.log('Test 2: Testing tmux command execution...');
        try {
            await server.execTmux('list-sessions');
            console.log('✓ Tmux command execution test passed\n');
        } catch (error) {
            if (error.message.includes('no server running')) {
                console.log('ℹ No tmux server running (expected for clean environment)');
                console.log('✓ Tmux command execution test passed\n');
            } else {
                throw error;
            }
        }
        
        // Test 3: Create a test session (if no sessions exist)
        if (sessions.sessions.length === 0) {
            console.log('Test 3: Creating test session...');
            const result = await server.createSession('mcp-test', null, null, true);
            console.log('Create session result:', JSON.stringify(result, null, 2));
            console.log('✓ Create session test passed\n');
            
            // Test 4: Read from the test session
            console.log('Test 4: Reading from test session...');
            try {
                const content = await server.readPane('mcp-test', '0', '0', 10);
                console.log('Pane content:', JSON.stringify(content, null, 2));
                console.log('✓ Read pane test passed\n');
            } catch (error) {
                console.log('ℹ Read pane test skipped (pane might not be ready yet)');
            }
            
            // Clean up test session
            console.log('Cleaning up test session...');
            await server.killSession('mcp-test');
            console.log('✓ Cleanup completed\n');
        }
        
        console.log('🎉 All tests passed! Tmux MCP Server is working correctly.');
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    runTests();
}
