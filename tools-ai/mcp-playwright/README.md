# Playwright MCP Server

This module provides Model Context Protocol (MCP) integration between Playwright and Claude Desktop/CLI, enabling Claude to perform browser automation, web testing, and scraping tasks.

## Features

- **Browser Management**: Launch and control Chromium, Firefox, and WebKit browsers
- **Page Automation**: Navigate, click, type, fill forms, and interact with web pages
- **Content Extraction**: Get text, HTML, query elements, and extract data
- **Screenshots**: Capture full page or element screenshots
- **JavaScript Execution**: Run custom scripts in page context
- **Multi-context Support**: Isolated browser sessions with different configurations
- **Headless/Headful**: Support for both visible and background browser operation

## Installation

```bash
./tools-ai/mcp-playwright/setup.sh
```

The setup script will:
1. Install Playwright and dependencies (~500MB for browser binaries)
2. Download Chromium, Firefox, and WebKit browsers
3. Configure Claude Desktop and CLI
4. Set up shell aliases and functions
5. Create example scripts

## Configuration

The MCP server is configured in two locations:

1. **Claude Desktop**: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `~/.config/Claude/claude_desktop_config.json` (Linux)
2. **Claude CLI**: `.mcp.json` in the dotfiles root

## Usage

### Shell Commands

After installation, these commands are available:

- `playwright-mcp-test` - Test MCP server functionality
- `playwright-mcp-status` - Check MCP configuration status
- `playwright-inspector` - Launch Playwright inspector UI
- `playwright-update-browsers` - Update browser binaries
- `playwright-browser [type]` - Launch a browser for manual testing
- `playwright-docs` - Open Playwright documentation

### In Claude

Once configured, you can ask Claude to:

#### Basic Navigation
- "Launch a browser and go to google.com"
- "Navigate to the GitHub homepage"
- "Go back to the previous page"

#### Interaction
- "Click the 'Sign in' button"
- "Type 'playwright automation' in the search box"
- "Fill the email field with test@example.com"
- "Select 'United States' from the country dropdown"

#### Content Extraction
- "Get all the links on this page"
- "Extract the main heading text"
- "Show me the page title"
- "Get all text from the article section"

#### Screenshots
- "Take a screenshot of the page"
- "Capture just the header element"
- "Take a full-page screenshot"

#### Advanced
- "Wait for the loading spinner to disappear"
- "Execute JavaScript to scroll to the bottom"
- "Extract data from the table on the page"
- "Check if the submit button is enabled"

## MCP Methods

The server provides these methods for Claude:

| Method | Description | Key Parameters |
|--------|-------------|----------------|
| `playwright/initialize` | Initialize the server | None |
| `playwright/launch` | Launch a browser | `browser`, `options` |
| `playwright/context` | Create browser context | `browserId`, `options` |
| `playwright/page` | Create new page | `contextId`, `url` |
| `playwright/navigate` | Navigate to URL | `pageId`, `url` |
| `playwright/click` | Click element | `pageId`, `selector` |
| `playwright/type` | Type text | `pageId`, `selector`, `text` |
| `playwright/fill` | Fill input field | `pageId`, `selector`, `value` |
| `playwright/select` | Select dropdown option | `pageId`, `selector`, `value` |
| `playwright/content` | Get HTML content | `pageId`, `options` |
| `playwright/text` | Get text content | `pageId`, `selector` |
| `playwright/query` | Query elements | `pageId`, `selector` |
| `playwright/screenshot` | Take screenshot | `pageId`, `options` |
| `playwright/wait` | Wait for element | `pageId`, `selector` |
| `playwright/evaluate` | Execute JavaScript | `pageId`, `script` |
| `playwright/title` | Get page title | `pageId` |
| `playwright/url` | Get current URL | `pageId` |
| `playwright/close-page` | Close page | `pageId` |
| `playwright/close-context` | Close context | `contextId` |
| `playwright/close-browser` | Close browser | `browserId` |
| `playwright/sessions` | List active sessions | None |

## Examples

### Web Scraping

```javascript
// Claude can help you scrape websites
"Launch a headless browser and go to news.ycombinator.com"
"Get all the story titles on the page"
"Extract the points and comment counts for each story"
```

### Form Automation

```javascript
// Claude can fill and submit forms
"Go to the contact form page"
"Fill the name field with 'John Doe'"
"Fill the email with 'john@example.com'"
"Type 'This is a test message' in the message box"
"Click the submit button"
```

### Testing Workflows

```javascript
// Claude can help test web applications
"Navigate to our app login page"
"Try logging in with invalid credentials"
"Check if an error message appears"
"Take a screenshot of the error state"
```

### Data Extraction

```javascript
// Claude can extract structured data
"Go to the products page"
"Get all product names and prices"
"Find products under $50"
"Extract the product images URLs"
```

## Browser Contexts

Contexts provide isolated browser sessions with their own:
- Cookies and storage
- Viewport size
- User agent
- Locale and timezone
- Permissions
- Geolocation

Example context options:
```json
{
  "viewport": { "width": 1920, "height": 1080 },
  "userAgent": "Custom User Agent",
  "locale": "en-US",
  "timezone": "America/New_York",
  "permissions": ["geolocation"],
  "geolocation": { "latitude": 40.7128, "longitude": -74.0060 }
}
```

## Selectors

Playwright supports multiple selector engines:

- **CSS**: `.class`, `#id`, `div > span`
- **Text**: `text=Submit`, `text=/regex/`
- **XPath**: `xpath=//button[@type='submit']`
- **React**: `_react=ComponentName`
- **Vue**: `_vue=ComponentName`
- **Role**: `role=button[name="Submit"]`

## Screenshots

Screenshots are saved to the system temp directory by default. Options include:

- `fullPage`: Capture entire scrollable page
- `clip`: Capture specific region `{x, y, width, height}`
- `omitBackground`: Transparent background for PNG
- `quality`: JPEG quality (0-100)
- `type`: 'png' or 'jpeg'

## Error Handling

The server handles common errors gracefully:

- Browser not found → Clear error message
- Element not found → Timeout with selector info
- Navigation failed → Network error details
- Page closed → Session cleanup

## Performance Tips

1. **Reuse contexts**: Create one context for multiple related pages
2. **Headless mode**: Use for automation tasks (faster)
3. **Headful mode**: Use for debugging (visual feedback)
4. **Parallel execution**: Launch multiple contexts for concurrent tasks
5. **Cleanup**: Always close browsers when done

## Troubleshooting

### Browser Launch Issues

If browsers fail to launch:
```bash
# Update browser binaries
playwright-update-browsers

# Install system dependencies (Linux)
cd tools-ai/mcp-playwright
npx playwright install-deps
```

### Permission Errors

On Linux, you might need to install additional dependencies:
```bash
sudo apt-get install libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0
```

### Timeout Errors

Increase timeout for slow pages:
```javascript
{
  "timeout": 60000,  // 60 seconds
  "waitUntil": "networkidle"
}
```

### Memory Issues

Close unused pages and contexts:
```javascript
"Close all pages except the current one"
"Close the browser to free memory"
```

## Security Considerations

- **Sandbox**: Browsers run in sandbox mode by default
- **Isolation**: Each context is isolated from others
- **No persistence**: Data is cleared between sessions
- **HTTPS only**: Prefer secure connections
- **Input validation**: Server validates all parameters

## Advanced Features

### Network Interception
```javascript
// Future enhancement
"Block all images on the page"
"Mock API responses"
"Monitor network requests"
```

### Mobile Emulation
```javascript
// Context with mobile viewport
{
  "viewport": { "width": 375, "height": 667 },
  "userAgent": "Mozilla/5.0 (iPhone...)",
  "deviceScaleFactor": 2,
  "isMobile": true,
  "hasTouch": true
}
```

### File Operations
```javascript
// Future enhancement
"Upload a file to the form"
"Download the PDF document"
```

## Examples Directory

Check out the `examples/` directory for sample scripts:

- `scrape-example.js` - Web scraping demo
- More examples coming soon...

Run examples:
```bash
node tools-ai/mcp-playwright/examples/scrape-example.js
```

## Dependencies

- **Node.js** >= 14.0.0
- **Playwright** >= 1.40.0
- **Disk space** ~500MB for browser binaries
- **Memory** ~200MB per browser instance

## Resources

- [Playwright Documentation](https://playwright.dev)
- [Selector Engines](https://playwright.dev/docs/selectors)
- [API Reference](https://playwright.dev/docs/api/class-playwright)
- [Best Practices](https://playwright.dev/docs/best-practices)

## Future Enhancements

- [ ] Network request interception
- [ ] File upload/download support
- [ ] Video recording
- [ ] PDF generation
- [ ] Accessibility testing
- [ ] Performance metrics
- [ ] Cookie management
- [ ] Proxy support
- [ ] Browser extensions
- [ ] Parallel test execution

## License

MIT - Part of the dotfiles-ai project