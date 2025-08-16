#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";
import { exec } from 'child_process';
import { promisify } from 'util';
import { attach } from 'neovim';
import fs from 'fs/promises';
import net from 'net';

const execAsync = promisify(exec);

// Tool schemas
const CheckNeovimSchema = z.object({});

const ListInstancesSchema = z.object({});

const StartInstanceSchema = z.object({
  name: z.string().optional().describe("Name for the Neovim instance"),
  headless: z.boolean().optional().default(false).describe("Start in headless mode"),
  socket: z.string().optional().describe("Custom socket path")
});

const ConnectSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path")
});

const ExecuteCommandSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  command: z.string().describe("Vim command to execute")
});

const OpenFileSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  file: z.string().describe("File path to open"),
  line: z.number().optional().describe("Line number to jump to")
});

const GetBuffersSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path")
});

const GetCurrentBufferSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path")
});

const SaveBufferSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  force: z.boolean().optional().default(false).describe("Force save without confirmation")
});

const InsertTextSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  text: z.string().describe("Text to insert at cursor position"),
  mode: z.enum(["insert", "append", "newline"]).optional().default("insert").describe("Insert mode")
});

const SearchSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  pattern: z.string().describe("Search pattern"),
  backwards: z.boolean().optional().default(false).describe("Search backwards")
});

const GetSelectionSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path")
});

const GetBufferContentSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  start: z.number().optional().describe("Start line (0-indexed)"),
  end: z.number().optional().describe("End line (0-indexed)")
});

const SetBufferContentSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  content: z.array(z.string()).describe("Lines of content to set"),
  start: z.number().optional().default(0).describe("Start line (0-indexed)"),
  end: z.number().optional().default(-1).describe("End line (0-indexed, -1 for end of buffer)")
});

// Create MCP server
const server = new Server(
  {
    name: "neovim-mcp-server",
    version: "2.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to check if neovim is installed
async function checkNeovim() {
  try {
    const { stdout } = await execAsync('nvim --version');
    const version = stdout.split('\n')[0];
    return {
      installed: true,
      version: version,
      rpc_support: stdout.includes('msgpack') || true // Assume modern neovim
    };
  } catch (error) {
    return {
      installed: false,
      error: "Neovim not installed"
    };
  }
}

// Helper function to list neovim instances
async function listInstances() {
  try {
    const sockets = [];
    
    // Check common socket locations
    const checkPaths = [
      '/tmp/nvim.pipe',
      '/tmp/nvimsocket',
      `${process.env.HOME}/.cache/nvim/server.pipe`,
      '/tmp/nvim-*'
    ];
    
    for (const path of checkPaths) {
      try {
        if (path.includes('*')) {
          // Handle glob patterns
          const { stdout } = await execAsync(`ls ${path} 2>/dev/null || true`);
          if (stdout.trim()) {
            sockets.push(...stdout.trim().split('\n'));
          }
        } else {
          await fs.access(path);
          sockets.push(path);
        }
      } catch {
        // Socket doesn't exist
      }
    }
    
    // Check for nvim processes
    const { stdout } = await execAsync('pgrep -la nvim').catch(() => ({ stdout: '' }));
    const processes = stdout.trim().split('\n').filter(Boolean);
    
    return {
      sockets: [...new Set(sockets)], // Remove duplicates
      processes: processes.length,
      instances: sockets.length > 0 ? sockets : processes.length > 0 ? ["Running but no socket found"] : []
    };
  } catch (error) {
    return {
      error: error.message
    };
  }
}

// Helper to connect to neovim instance
async function connectToNeovim(socket) {
  try {
    // Check if socket exists
    await fs.access(socket);
    
    // Connect using neovim client
    const nvim = await attach({ socket });
    return nvim;
  } catch (error) {
    throw new Error(`Failed to connect to Neovim at ${socket}: ${error.message}`);
  }
}

// Helper to start neovim instance
async function startNeovimInstance(name = 'default', headless = false, customSocket = null) {
  try {
    const socket = customSocket || `/tmp/nvim-${name}-${Date.now()}.sock`;
    const cmd = headless 
      ? `nvim --headless --listen ${socket}` 
      : `nvim --listen ${socket}`;
    
    // Start neovim in background
    const child = exec(cmd);
    
    // Wait a moment for socket to be created
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Verify socket exists
    await fs.access(socket);
    
    return {
      socket,
      pid: child.pid,
      headless,
      name
    };
  } catch (error) {
    throw new Error(`Failed to start Neovim instance: ${error.message}`);
  }
}

// List tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "neovim_check",
        description: "Check if Neovim is installed and get version",
        inputSchema: zodToJsonSchema(CheckNeovimSchema),
      },
      {
        name: "neovim_list",
        description: "List running Neovim instances",
        inputSchema: zodToJsonSchema(ListInstancesSchema),
      },
      {
        name: "neovim_start",
        description: "Start a new Neovim instance",
        inputSchema: zodToJsonSchema(StartInstanceSchema),
      },
      {
        name: "neovim_connect",
        description: "Test connection to Neovim instance",
        inputSchema: zodToJsonSchema(ConnectSchema),
      },
      {
        name: "neovim_execute",
        description: "Execute a Vim command in Neovim",
        inputSchema: zodToJsonSchema(ExecuteCommandSchema),
      },
      {
        name: "neovim_open",
        description: "Open a file in Neovim",
        inputSchema: zodToJsonSchema(OpenFileSchema),
      },
      {
        name: "neovim_buffers",
        description: "Get list of open buffers in Neovim",
        inputSchema: zodToJsonSchema(GetBuffersSchema),
      },
      {
        name: "neovim_current_buffer",
        description: "Get current buffer information and content",
        inputSchema: zodToJsonSchema(GetCurrentBufferSchema),
      },
      {
        name: "neovim_save",
        description: "Save current buffer",
        inputSchema: zodToJsonSchema(SaveBufferSchema),
      },
      {
        name: "neovim_insert",
        description: "Insert text at cursor position",
        inputSchema: zodToJsonSchema(InsertTextSchema),
      },
      {
        name: "neovim_search",
        description: "Search for pattern in current buffer",
        inputSchema: zodToJsonSchema(SearchSchema),
      },
      {
        name: "neovim_selection",
        description: "Get visual selection text",
        inputSchema: zodToJsonSchema(GetSelectionSchema),
      },
      {
        name: "neovim_get_content",
        description: "Get buffer content (lines)",
        inputSchema: zodToJsonSchema(GetBufferContentSchema),
      },
      {
        name: "neovim_set_content",
        description: "Set buffer content (replace lines)",
        inputSchema: zodToJsonSchema(SetBufferContentSchema),
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "neovim_check": {
        const result = await checkNeovim();
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "neovim_list": {
        const result = await listInstances();
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "neovim_start": {
        const validated = StartInstanceSchema.parse(args);
        try {
          const result = await startNeovimInstance(validated.name, validated.headless, validated.socket);
          return {
            content: [
              {
                type: "text",
                text: `Started Neovim instance: ${JSON.stringify(result, null, 2)}`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error starting Neovim: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_connect": {
        const validated = ConnectSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          const mode = await nvim.mode;
          await nvim.quit();
          
          return {
            content: [
              {
                type: "text",
                text: `Successfully connected to Neovim at ${validated.socket}. Mode: ${mode.mode}`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Connection failed: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_execute": {
        const validated = ExecuteCommandSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          // Execute command
          await nvim.command(validated.command);
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: `Executed command: ${validated.command}`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error executing command: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_open": {
        const validated = OpenFileSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          // Open file
          await nvim.command(`edit ${validated.file}`);
          
          // Jump to line if specified
          if (validated.line) {
            await nvim.command(`${validated.line}`);
          }
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: `Opened file: ${validated.file}${validated.line ? ` at line ${validated.line}` : ''}`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error opening file: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_buffers": {
        const validated = GetBuffersSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          const buffers = await nvim.buffers;
          const bufferInfo = await Promise.all(
            buffers.map(async (buf) => {
              const [name, lineCount, modified] = await Promise.all([
                buf.name,
                buf.length,
                buf.getOption('modified')
              ]);
              return {
                id: buf.id,
                name: name || '[No Name]',
                lines: lineCount,
                modified: modified
              };
            })
          );
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(bufferInfo, null, 2),
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error getting buffers: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_current_buffer": {
        const validated = GetCurrentBufferSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          const buffer = await nvim.buffer;
          const [name, lineCount, modified, cursor, lines] = await Promise.all([
            buffer.name,
            buffer.length,
            buffer.getOption('modified'),
            nvim.window.cursor,
            buffer.lines
          ]);
          
          const result = {
            id: buffer.id,
            name: name || '[No Name]',
            lines: lineCount,
            modified: modified,
            cursor: { line: cursor[0], column: cursor[1] },
            content: lines.slice(0, Math.min(50, lines.length)) // First 50 lines
          };
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(result, null, 2),
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error getting current buffer: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_save": {
        const validated = SaveBufferSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          const command = validated.force ? 'write!' : 'write';
          await nvim.command(command);
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: `Buffer saved successfully`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error saving buffer: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_insert": {
        const validated = InsertTextSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          const buffer = await nvim.buffer;
          const cursor = await nvim.window.cursor;
          const [line, col] = cursor;
          
          if (validated.mode === 'newline') {
            await buffer.insert(line, [validated.text]);
          } else if (validated.mode === 'append') {
            const currentLine = await buffer.getLines(line - 1, line, true);
            if (currentLine.length > 0) {
              await buffer.setLines(line - 1, line, true, [currentLine[0] + validated.text]);
            }
          } else {
            // Insert mode - insert at cursor position
            const currentLine = await buffer.getLines(line - 1, line, true);
            if (currentLine.length > 0) {
              const newLine = currentLine[0].slice(0, col) + validated.text + currentLine[0].slice(col);
              await buffer.setLines(line - 1, line, true, [newLine]);
            }
          }
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: `Inserted text: "${validated.text}" (mode: ${validated.mode})`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error inserting text: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_search": {
        const validated = SearchSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          const direction = validated.backwards ? '?' : '/';
          await nvim.command(`${direction}${validated.pattern}`);
          
          const cursor = await nvim.window.cursor;
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: `Search completed. Cursor at line ${cursor[0]}, column ${cursor[1]}`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Search failed: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_selection": {
        const validated = GetSelectionSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          // Get visual selection
          await nvim.command('normal! gv');
          const [start, end] = await Promise.all([
            nvim.eval("getpos(\"'<\")"),
            nvim.eval("getpos(\"'>\")")
          ]);
          
          const buffer = await nvim.buffer;
          const lines = await buffer.getLines(start[1] - 1, end[1], true);
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify({
                  start: { line: start[1], column: start[2] },
                  end: { line: end[1], column: end[2] },
                  text: lines
                }, null, 2),
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error getting selection: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_get_content": {
        const validated = GetBufferContentSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          const buffer = await nvim.buffer;
          const totalLines = await buffer.length;
          
          const start = validated.start || 0;
          const end = validated.end || totalLines;
          
          const lines = await buffer.getLines(start, end, true);
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify({
                  lines: lines,
                  start: start,
                  end: end < 0 ? totalLines : end,
                  total_lines: totalLines
                }, null, 2),
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error getting content: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_set_content": {
        const validated = SetBufferContentSchema.parse(args);
        try {
          const nvim = await connectToNeovim(validated.socket);
          
          const buffer = await nvim.buffer;
          const totalLines = await buffer.length;
          
          const start = validated.start;
          const end = validated.end < 0 ? totalLines : validated.end;
          
          await buffer.setLines(start, end, true, validated.content);
          
          await nvim.quit();
          return {
            content: [
              {
                type: "text",
                text: `Content updated: replaced lines ${start}-${end} with ${validated.content.length} lines`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error setting content: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
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

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});