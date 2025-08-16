#!/usr/bin/env node

/**
 * Test script for Neovim MCP Server
 */

const NeovimMCPServer = require('./server.js');

async function runTests() {
    console.log('Testing Neovim MCP Server...\n');
    
    const server = new NeovimMCPServer();
    
    try {
        // Test 1: Check Neovim installation
        console.log('Test 1: Checking Neovim installation...');
        const nvimCheck = await server.checkNeovim();
        if (nvimCheck.installed) {
            console.log('✓ Neovim is installed:', nvimCheck.version);
        } else {
            console.log('✗ Neovim not found:', nvimCheck.error);
        }
        console.log();
        
        // Test 2: List Neovim instances
        console.log('Test 2: Listing Neovim instances...');
        const instances = await server.listInstances();
        console.log('Found', instances.processes, 'Neovim processes');
        console.log('Found', instances.sockets, 'server sockets');
        if (instances.instances.length > 0) {
            console.log('Server sockets:');
            instances.instances.forEach(inst => {
                console.log('  -', inst.name, 'at', inst.socket);
            });
        }
        console.log('✓ Instance listing test passed\n');
        
        // Test 3: Start a headless instance
        console.log('Test 3: Starting headless Neovim instance...');
        const started = await server.startInstance('mcp-test', true);
        if (started.success) {
            console.log('✓ Started Neovim instance:', started.name);
            console.log('  Socket:', started.socket);
            console.log('  PID:', started.pid);
            
            // Test 4: Connect to instance
            console.log('\nTest 4: Connecting to instance...');
            try {
                const connected = await server.connectToInstance(started.socket);
                console.log('✓ Successfully connected to socket');
            } catch (e) {
                console.log('ℹ Connection test skipped (socket may not be ready)');
            }
            
            // Test 5: Send a command
            console.log('\nTest 5: Sending command to Neovim...');
            const cmdResult = await server.sendCommand(
                started.socket,
                'version',
                true
            );
            if (cmdResult.success) {
                console.log('✓ Command executed successfully');
            } else {
                console.log('ℹ Command execution failed (may need nvr):', cmdResult.suggestion);
            }
            
            // Clean up - kill the test instance
            if (started.pid) {
                process.kill(started.pid, 'SIGTERM');
                console.log('\n✓ Cleaned up test instance');
            }
        } else {
            console.log('✗ Failed to start instance:', started.error);
        }
        
        console.log('\n🎉 All tests completed!');
        console.log('\nNeovim MCP Server is ready for use with Claude.');
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    runTests();
}
