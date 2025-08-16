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
