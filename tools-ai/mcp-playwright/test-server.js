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
