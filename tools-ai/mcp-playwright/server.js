#!/usr/bin/env node

/**
 * Playwright MCP Server
 * Provides Model Context Protocol interface for browser automation via Playwright
 * Enables Claude to perform web testing, scraping, and automation tasks
 */

const { chromium, firefox, webkit } = require('playwright');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');

class PlaywrightMCPServer {
    constructor() {
        this.browsers = new Map();
        this.contexts = new Map();
        this.pages = new Map();
        this.sessionCounter = 0;
        this.screenshotDir = path.join(os.tmpdir(), 'playwright-mcp');
    }

    /**
     * Initialize the server
     */
    async initialize() {
        try {
            await fs.mkdir(this.screenshotDir, { recursive: true });
            return { initialized: true, screenshotDir: this.screenshotDir };
        } catch (error) {
            return { initialized: false, error: error.message };
        }
    }

    /**
     * Launch a browser instance
     */
    async launchBrowser(browserType = 'chromium', options = {}) {
        try {
            const browserId = `browser-${++this.sessionCounter}`;
            
            // Select browser type
            let browserEngine;
            switch (browserType.toLowerCase()) {
                case 'firefox':
                    browserEngine = firefox;
                    break;
                case 'webkit':
                case 'safari':
                    browserEngine = webkit;
                    break;
                default:
                    browserEngine = chromium;
            }

            // Default options
            const launchOptions = {
                headless: options.headless !== false,
                ...options
            };

            // Launch browser
            const browser = await browserEngine.launch(launchOptions);
            this.browsers.set(browserId, {
                browser,
                type: browserType,
                launched: new Date()
            });

            return {
                success: true,
                browserId,
                type: browserType,
                headless: launchOptions.headless
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Create a new browser context (isolated session)
     */
    async createContext(browserId, options = {}) {
        try {
            const browserInfo = this.browsers.get(browserId);
            if (!browserInfo) {
                throw new Error(`Browser ${browserId} not found`);
            }

            const contextId = `context-${++this.sessionCounter}`;
            
            // Context options
            const contextOptions = {
                viewport: options.viewport || { width: 1280, height: 720 },
                userAgent: options.userAgent,
                locale: options.locale,
                timezone: options.timezone,
                permissions: options.permissions,
                geolocation: options.geolocation,
                colorScheme: options.colorScheme,
                ...options
            };

            const context = await browserInfo.browser.newContext(contextOptions);
            this.contexts.set(contextId, {
                context,
                browserId,
                created: new Date()
            });

            return {
                success: true,
                contextId,
                browserId,
                viewport: contextOptions.viewport
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Create a new page in a context
     */
    async newPage(contextId, url = null) {
        try {
            const contextInfo = this.contexts.get(contextId);
            if (!contextInfo) {
                throw new Error(`Context ${contextId} not found`);
            }

            const pageId = `page-${++this.sessionCounter}`;
            const page = await contextInfo.context.newPage();
            
            if (url) {
                await page.goto(url, { waitUntil: 'domcontentloaded' });
            }

            this.pages.set(pageId, {
                page,
                contextId,
                created: new Date(),
                url: url || 'about:blank'
            });

            return {
                success: true,
                pageId,
                contextId,
                url: url || 'about:blank'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Navigate to a URL
     */
    async navigate(pageId, url, options = {}) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            const navigationOptions = {
                waitUntil: options.waitUntil || 'domcontentloaded',
                timeout: options.timeout || 30000
            };

            const response = await pageInfo.page.goto(url, navigationOptions);
            pageInfo.url = url;

            return {
                success: true,
                url,
                status: response.status(),
                ok: response.ok()
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Click an element
     */
    async click(pageId, selector, options = {}) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            await pageInfo.page.click(selector, {
                timeout: options.timeout || 30000,
                ...options
            });

            return {
                success: true,
                selector,
                action: 'clicked'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                selector
            };
        }
    }

    /**
     * Type text into an input
     */
    async type(pageId, selector, text, options = {}) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            await pageInfo.page.type(selector, text, {
                timeout: options.timeout || 30000,
                delay: options.delay || 0,
                ...options
            });

            return {
                success: true,
                selector,
                text: text.substring(0, 50) + (text.length > 50 ? '...' : ''),
                action: 'typed'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                selector
            };
        }
    }

    /**
     * Fill a form field
     */
    async fill(pageId, selector, value) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            await pageInfo.page.fill(selector, value);

            return {
                success: true,
                selector,
                value,
                action: 'filled'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                selector
            };
        }
    }

    /**
     * Select from dropdown
     */
    async select(pageId, selector, value) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            const selected = await pageInfo.page.selectOption(selector, value);

            return {
                success: true,
                selector,
                value,
                selected
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                selector
            };
        }
    }

    /**
     * Get page content
     */
    async getContent(pageId, options = {}) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            if (options.selector) {
                // Get specific element content
                const element = await pageInfo.page.$(options.selector);
                if (!element) {
                    throw new Error(`Element ${options.selector} not found`);
                }
                
                const content = await element.innerText();
                return {
                    success: true,
                    content,
                    selector: options.selector
                };
            } else {
                // Get full page content
                const content = await pageInfo.page.content();
                return {
                    success: true,
                    content: content.substring(0, options.maxLength || 10000),
                    truncated: content.length > (options.maxLength || 10000)
                };
            }
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Extract text from page
     */
    async getText(pageId, selector = null) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            let text;
            if (selector) {
                const element = await pageInfo.page.$(selector);
                if (!element) {
                    throw new Error(`Element ${selector} not found`);
                }
                text = await element.innerText();
            } else {
                text = await pageInfo.page.innerText('body');
            }

            return {
                success: true,
                text,
                selector: selector || 'body'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Query elements
     */
    async queryElements(pageId, selector, options = {}) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            const elements = await pageInfo.page.$$(selector);
            
            const results = [];
            for (let i = 0; i < Math.min(elements.length, options.limit || 100); i++) {
                const element = elements[i];
                const result = {
                    index: i,
                    text: await element.innerText().catch(() => null),
                    href: await element.getAttribute('href').catch(() => null),
                    class: await element.getAttribute('class').catch(() => null),
                    id: await element.getAttribute('id').catch(() => null)
                };
                
                // Filter out null values
                Object.keys(result).forEach(key => {
                    if (result[key] === null) delete result[key];
                });
                
                results.push(result);
            }

            return {
                success: true,
                selector,
                count: elements.length,
                elements: results
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                selector
            };
        }
    }

    /**
     * Take a screenshot
     */
    async screenshot(pageId, options = {}) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            const filename = options.filename || `screenshot-${Date.now()}.png`;
            const filepath = path.join(this.screenshotDir, filename);

            const screenshotOptions = {
                path: filepath,
                fullPage: options.fullPage !== false,
                ...options
            };

            if (options.selector) {
                const element = await pageInfo.page.$(options.selector);
                if (!element) {
                    throw new Error(`Element ${options.selector} not found`);
                }
                await element.screenshot(screenshotOptions);
            } else {
                await pageInfo.page.screenshot(screenshotOptions);
            }

            return {
                success: true,
                path: filepath,
                filename,
                fullPage: screenshotOptions.fullPage
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Wait for selector
     */
    async waitFor(pageId, selector, options = {}) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            await pageInfo.page.waitForSelector(selector, {
                timeout: options.timeout || 30000,
                state: options.state || 'visible'
            });

            return {
                success: true,
                selector,
                found: true
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                selector,
                found: false
            };
        }
    }

    /**
     * Execute JavaScript in page context
     */
    async evaluate(pageId, script) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            const result = await pageInfo.page.evaluate(script);

            return {
                success: true,
                result
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Get page title
     */
    async getTitle(pageId) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            const title = await pageInfo.page.title();

            return {
                success: true,
                title
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Get current URL
     */
    async getUrl(pageId) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            const url = pageInfo.page.url();

            return {
                success: true,
                url
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Close a page
     */
    async closePage(pageId) {
        try {
            const pageInfo = this.pages.get(pageId);
            if (!pageInfo) {
                throw new Error(`Page ${pageId} not found`);
            }

            await pageInfo.page.close();
            this.pages.delete(pageId);

            return {
                success: true,
                pageId,
                closed: true
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Close a context
     */
    async closeContext(contextId) {
        try {
            const contextInfo = this.contexts.get(contextId);
            if (!contextInfo) {
                throw new Error(`Context ${contextId} not found`);
            }

            // Close all pages in this context
            for (const [pageId, pageInfo] of this.pages.entries()) {
                if (pageInfo.contextId === contextId) {
                    this.pages.delete(pageId);
                }
            }

            await contextInfo.context.close();
            this.contexts.delete(contextId);

            return {
                success: true,
                contextId,
                closed: true
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Close a browser
     */
    async closeBrowser(browserId) {
        try {
            const browserInfo = this.browsers.get(browserId);
            if (!browserInfo) {
                throw new Error(`Browser ${browserId} not found`);
            }

            // Close all contexts and pages for this browser
            for (const [contextId, contextInfo] of this.contexts.entries()) {
                if (contextInfo.browserId === browserId) {
                    await this.closeContext(contextId);
                }
            }

            await browserInfo.browser.close();
            this.browsers.delete(browserId);

            return {
                success: true,
                browserId,
                closed: true
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * List active sessions
     */
    async listSessions() {
        const sessions = {
            browsers: [],
            contexts: [],
            pages: []
        };

        for (const [id, info] of this.browsers.entries()) {
            sessions.browsers.push({
                id,
                type: info.type,
                launched: info.launched
            });
        }

        for (const [id, info] of this.contexts.entries()) {
            sessions.contexts.push({
                id,
                browserId: info.browserId,
                created: info.created
            });
        }

        for (const [id, info] of this.pages.entries()) {
            sessions.pages.push({
                id,
                contextId: info.contextId,
                url: info.url,
                created: info.created
            });
        }

        return sessions;
    }

    /**
     * Main handler for MCP requests
     */
    async handleRequest(method, params) {
        switch (method) {
            case 'playwright/initialize':
                return await this.initialize();

            case 'playwright/launch':
                return await this.launchBrowser(params.browser, params.options);

            case 'playwright/context':
                return await this.createContext(params.browserId, params.options);

            case 'playwright/page':
                return await this.newPage(params.contextId, params.url);

            case 'playwright/navigate':
                return await this.navigate(params.pageId, params.url, params.options);

            case 'playwright/click':
                return await this.click(params.pageId, params.selector, params.options);

            case 'playwright/type':
                return await this.type(params.pageId, params.selector, params.text, params.options);

            case 'playwright/fill':
                return await this.fill(params.pageId, params.selector, params.value);

            case 'playwright/select':
                return await this.select(params.pageId, params.selector, params.value);

            case 'playwright/content':
                return await this.getContent(params.pageId, params.options);

            case 'playwright/text':
                return await this.getText(params.pageId, params.selector);

            case 'playwright/query':
                return await this.queryElements(params.pageId, params.selector, params.options);

            case 'playwright/screenshot':
                return await this.screenshot(params.pageId, params.options);

            case 'playwright/wait':
                return await this.waitFor(params.pageId, params.selector, params.options);

            case 'playwright/evaluate':
                return await this.evaluate(params.pageId, params.script);

            case 'playwright/title':
                return await this.getTitle(params.pageId);

            case 'playwright/url':
                return await this.getUrl(params.pageId);

            case 'playwright/close-page':
                return await this.closePage(params.pageId);

            case 'playwright/close-context':
                return await this.closeContext(params.contextId);

            case 'playwright/close-browser':
                return await this.closeBrowser(params.browserId);

            case 'playwright/sessions':
                return await this.listSessions();

            default:
                throw new Error(`Unknown method: ${method}`);
        }
    }
}

// MCP Server Interface
if (require.main === module) {
    const server = new PlaywrightMCPServer();
    
    // Initialize server on startup
    server.initialize().then(result => {
        if (!result.initialized) {
            console.error('Failed to initialize server:', result.error);
            process.exit(1);
        }
    });
    
    // Read JSON-RPC requests from stdin
    let buffer = '';
    
    process.stdin.on('data', async (chunk) => {
        buffer += chunk.toString();
        
        // Try to parse complete JSON objects
        const lines = buffer.split('\n');
        buffer = lines.pop(); // Keep incomplete line in buffer
        
        for (const line of lines) {
            if (line.trim()) {
                try {
                    const request = JSON.parse(line);
                    const result = await server.handleRequest(
                        request.method,
                        request.params || {}
                    );
                    
                    const response = {
                        jsonrpc: '2.0',
                        id: request.id,
                        result
                    };
                    
                    console.log(JSON.stringify(response));
                } catch (error) {
                    const response = {
                        jsonrpc: '2.0',
                        id: request.id || null,
                        error: {
                            code: -32603,
                            message: error.message
                        }
                    };
                    console.log(JSON.stringify(response));
                }
            }
        }
    });

    // Clean up on exit
    process.on('SIGINT', async () => {
        // Close all browsers
        for (const [id] of server.browsers.entries()) {
            await server.closeBrowser(id);
        }
        process.exit(0);
    });

    // Handle server info request
    if (process.argv.includes('--info')) {
        console.log(JSON.stringify({
            name: 'Playwright MCP Server',
            version: '1.0.0',
            methods: [
                'playwright/initialize',
                'playwright/launch',
                'playwright/context',
                'playwright/page',
                'playwright/navigate',
                'playwright/click',
                'playwright/type',
                'playwright/fill',
                'playwright/select',
                'playwright/content',
                'playwright/text',
                'playwright/query',
                'playwright/screenshot',
                'playwright/wait',
                'playwright/evaluate',
                'playwright/title',
                'playwright/url',
                'playwright/close-page',
                'playwright/close-context',
                'playwright/close-browser',
                'playwright/sessions'
            ]
        }, null, 2));
        process.exit(0);
    }
}

module.exports = PlaywrightMCPServer;