#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";
import { chromium } from 'playwright';

// Tool schemas
const NavigateSchema = z.object({
  url: z.string().describe("URL to navigate to"),
  waitUntil: z.enum(["load", "domcontentloaded", "networkidle"]).optional().default("load").describe("When to consider navigation complete")
});

const ScreenshotSchema = z.object({
  fullPage: z.boolean().optional().default(false).describe("Capture full page screenshot"),
  path: z.string().optional().describe("Path to save screenshot")
});

const ClickSchema = z.object({
  selector: z.string().describe("CSS selector of element to click"),
  timeout: z.number().optional().default(30000).describe("Timeout in milliseconds")
});

const TypeSchema = z.object({
  selector: z.string().describe("CSS selector of input element"),
  text: z.string().describe("Text to type"),
  delay: z.number().optional().default(0).describe("Delay between keystrokes in milliseconds")
});

const GetTextSchema = z.object({
  selector: z.string().describe("CSS selector of element to get text from")
});

const WaitForSelectorSchema = z.object({
  selector: z.string().describe("CSS selector to wait for"),
  state: z.enum(["attached", "detached", "visible", "hidden"]).optional().default("visible").describe("State to wait for"),
  timeout: z.number().optional().default(30000).describe("Timeout in milliseconds")
});

// Create MCP server
const server = new Server(
  {
    name: "playwright-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Browser state
let browser = null;
let page = null;

// Helper to ensure browser is initialized
async function ensureBrowser() {
  if (!browser) {
    browser = await chromium.launch({ headless: true });
  }
  if (!page) {
    const context = await browser.newContext();
    page = await context.newPage();
  }
  return { browser, page };
}

// List tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "playwright_navigate",
        description: "Navigate to a URL",
        inputSchema: zodToJsonSchema(NavigateSchema),
      },
      {
        name: "playwright_screenshot",
        description: "Take a screenshot of the current page",
        inputSchema: zodToJsonSchema(ScreenshotSchema),
      },
      {
        name: "playwright_click",
        description: "Click an element on the page",
        inputSchema: zodToJsonSchema(ClickSchema),
      },
      {
        name: "playwright_type",
        description: "Type text into an input field",
        inputSchema: zodToJsonSchema(TypeSchema),
      },
      {
        name: "playwright_get_text",
        description: "Get text content from an element",
        inputSchema: zodToJsonSchema(GetTextSchema),
      },
      {
        name: "playwright_wait_for",
        description: "Wait for an element to appear",
        inputSchema: zodToJsonSchema(WaitForSelectorSchema),
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    await ensureBrowser();

    switch (name) {
      case "playwright_navigate": {
        const validated = NavigateSchema.parse(args);
        await page.goto(validated.url, { waitUntil: validated.waitUntil });
        return {
          content: [
            {
              type: "text",
              text: `Navigated to ${validated.url}`,
            },
          ],
        };
      }

      case "playwright_screenshot": {
        const validated = ScreenshotSchema.parse(args);
        const screenshot = await page.screenshot({
          fullPage: validated.fullPage,
          path: validated.path,
        });
        
        return {
          content: [
            {
              type: "text",
              text: validated.path ? `Screenshot saved to ${validated.path}` : "Screenshot captured",
            },
          ],
        };
      }

      case "playwright_click": {
        const validated = ClickSchema.parse(args);
        await page.click(validated.selector, { timeout: validated.timeout });
        return {
          content: [
            {
              type: "text",
              text: `Clicked element: ${validated.selector}`,
            },
          ],
        };
      }

      case "playwright_type": {
        const validated = TypeSchema.parse(args);
        await page.type(validated.selector, validated.text, { delay: validated.delay });
        return {
          content: [
            {
              type: "text",
              text: `Typed text into ${validated.selector}`,
            },
          ],
        };
      }

      case "playwright_get_text": {
        const validated = GetTextSchema.parse(args);
        const text = await page.textContent(validated.selector);
        return {
          content: [
            {
              type: "text",
              text: text || "(empty)",
            },
          ],
        };
      }

      case "playwright_wait_for": {
        const validated = WaitForSelectorSchema.parse(args);
        await page.waitForSelector(validated.selector, {
          state: validated.state,
          timeout: validated.timeout,
        });
        return {
          content: [
            {
              type: "text",
              text: `Element ${validated.selector} is ${validated.state}`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// Cleanup on exit
process.on('SIGINT', async () => {
  if (browser) {
    await browser.close();
  }
  process.exit(0);
});

process.on('SIGTERM', async () => {
  if (browser) {
    await browser.close();
  }
  process.exit(0);
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});