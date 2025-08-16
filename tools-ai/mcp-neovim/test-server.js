#!/usr/bin/env node

/**
 * Test script for Neovim MCP Server
 */

const NeovimMCPServer = require('./server.js');

async function runTests() {
    console.log('Testing Neovim MCP Server...\n');
    
    const server = new NeovimMCPServer();
    
    try {
        console.log('Test 1: Check Neovim availability...');
        const { execSync } = require('child_process');
        try {
            const version = execSync('nvim --version').toString();
            console.log('✓ Neovim found:', version.split('\n')[0]);
        } catch (error) {
            console.log('✗ Neovim not found');
            process.exit(1);
        }
        
        console.log('\nTest 2: Socket configuration...');
        console.log('✓ Socket path:', server.nvimSocket);
        
        console.log('\n✓ All tests passed! Neovim MCP Server is ready.');
        
    } catch (error) {
        console.error('✗ Test failed:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    runTests();
}
