# Web Browsers

Modern web browsers for development and testing.

## Installation

```bash
./tools-gui/browsers/setup.sh
```

## Available Browsers

### Google Chrome
- **Purpose**: Primary development browser with excellent DevTools
- **Features**: V8 JavaScript engine, extensive extension ecosystem
- **DevTools**: Advanced debugging, performance profiling, Lighthouse

### Firefox
- **Purpose**: Standards compliance testing, privacy-focused browsing
- **Features**: Gecko rendering engine, developer edition available
- **DevTools**: CSS Grid inspector, font editor, accessibility tools

### Brave
- **Purpose**: Privacy-focused Chromium-based browser
- **Features**: Built-in ad blocking, Tor integration, crypto wallet
- **DevTools**: Same as Chrome with privacy enhancements

### Chromium
- **Purpose**: Open-source Chrome base for testing
- **Features**: Pure Chromium without Google services
- **DevTools**: Identical to Chrome DevTools

## Configured Aliases

### Launch Browsers
```bash
# macOS
chrome [url]        # Open in Chrome
firefox [url]       # Open in Firefox
brave [url]         # Open in Brave
chromium [url]      # Open in Chromium

# Linux
google-chrome-stable [url]
firefox [url]
brave-browser [url]
chromium-browser [url]
```

### Browser Functions
- `chrome-open <url>` - Open URL in Chrome
- `firefox-open <url>` - Open URL in Firefox
- `brave-open <url>` - Open URL in Brave
- `chrome-profile <name>` - Launch Chrome with specific profile
- `firefox-profile <name>` - Launch Firefox with specific profile

### Development Shortcuts
- `chrome-dev` - Chrome with disabled web security (CORS bypass)
- `chrome-incognito` - Chrome in incognito mode
- `firefox-private` - Firefox private window

### Cache Management
- `clear-chrome-cache` - Clear Chrome cache
- `clear-firefox-cache` - Clear Firefox cache
- `kill-browsers` - Kill all browser processes

## Chrome Development Flags

Located in `~/.config/browsers/chrome-flags.conf`:

### Performance Flags
```bash
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
```

### Development Flags
```bash
--enable-devtools-experiments
--force-color-profile=srgb
--auto-open-devtools-for-tabs
```

### Security Flags (Development Only!)
```bash
--disable-web-security          # Disable CORS
--allow-file-access-from-files  # Local file access
--disable-site-isolation-trials # For testing
```

## Firefox Configuration

Located in `~/.config/browsers/firefox-user.js`:

### Developer Settings
```javascript
user_pref("devtools.theme", "dark");
user_pref("devtools.editor.keymap", "vim");
user_pref("devtools.toolbox.host", "right");
```

### Performance
```javascript
user_pref("gfx.webrender.all", true);
user_pref("layers.acceleration.force-enabled", true);
```

## Recommended Extensions

### Developer Tools
- **React Developer Tools** - React component inspector
- **Redux DevTools** - Redux state debugging
- **Vue.js devtools** - Vue component inspector
- **Angular DevTools** - Angular debugging
- **Lighthouse** - Performance auditing
- **Wappalyzer** - Technology profiler
- **JSON Viewer** - Format JSON responses
- **Octotree** - GitHub code tree
- **Refined GitHub** - GitHub enhancements

### API & Network
- **Postman Interceptor** - Capture requests
- **ModHeader** - Modify HTTP headers
- **EditThisCookie** - Cookie management
- **CORS Unblock** - Disable CORS (dev only)

### CSS & Design
- **ColorZilla** - Color picker
- **WhatFont** - Font inspector
- **Pesticide** - CSS layout debugger
- **PerfectPixel** - Pixel-perfect development
- **Dimensions** - Measure screen dimensions

### Productivity
- **Vimium** - Vim keybindings for browser
- **Dark Reader** - Universal dark mode
- **uBlock Origin** - Ad blocker
- **Session Buddy** - Session management
- **1Password/Bitwarden** - Password manager

### Performance Testing
- **Web Vitals** - Core Web Vitals monitoring
- **Performance Monitor** - Real-time metrics
- **Network Monitor** - Request analysis

## Browser Profiles

### Creating Profiles

#### Chrome
```bash
# Create new profile
chrome --profile-directory="Development"

# List profiles
ls ~/Library/Application\ Support/Google/Chrome/  # macOS
ls ~/.config/google-chrome/  # Linux
```

#### Firefox
```bash
# Profile manager
firefox -ProfileManager

# Create and use profile
firefox -CreateProfile "Development"
firefox -P "Development"
```

## Testing & Debugging

### Mobile Emulation
1. Open DevTools (F12)
2. Toggle device toolbar (Ctrl+Shift+M)
3. Select device or create custom

### Network Throttling
1. DevTools → Network tab
2. Throttling dropdown
3. Select speed (3G, 4G, etc.)

### JavaScript Debugging
```javascript
// Breakpoints
debugger;

// Console methods
console.log('Log message');
console.table(data);
console.time('timer');
console.timeEnd('timer');
console.trace();
```

### Performance Profiling
1. DevTools → Performance tab
2. Start recording
3. Perform actions
4. Stop and analyze

## Browser Automation

### Puppeteer (Chrome)
```javascript
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('https://example.com');
  await page.screenshot({ path: 'example.png' });
  await browser.close();
})();
```

### Playwright (Cross-browser)
```javascript
const { chromium, firefox, webkit } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('https://example.com');
  await browser.close();
})();
```

## Security Testing

### Content Security Policy
```bash
# Test CSP headers
chrome --enable-logging --v=1
```

### Certificate Inspection
1. Click padlock icon in address bar
2. Certificate → Details
3. Export or view certificate chain

## Tips

1. **Use profiles** - Separate work/personal/testing
2. **DevTools shortcuts** - Learn keyboard shortcuts
3. **Preserve log** - Don't lose console on navigation
4. **Workspaces** - Edit files directly in DevTools
5. **Snippets** - Save JavaScript snippets
6. **Local overrides** - Mock network responses
7. **Lighthouse CI** - Automate performance testing
8. **Browser sync** - Multi-device testing
9. **Extension development** - Test unpacked extensions
10. **User agent switching** - Test different clients

## Troubleshooting

### High Memory Usage
```bash
# Check Chrome processes
ps aux | grep -i chrome
chrome://memory  # In browser

# Kill all Chrome
pkill -f chrome
```

### Extension Conflicts
1. Disable all extensions
2. Enable one by one
3. Identify problematic extension

### Cache Issues
```bash
# Hard reload
Cmd+Shift+R (Mac) / Ctrl+Shift+R (Linux)

# Clear all data
chrome://settings/clearBrowserData
```

### SSL/Certificate Errors
```bash
# Ignore certificate errors (dev only!)
chrome --ignore-certificate-errors

# Import custom CA
chrome://settings/certificates
```