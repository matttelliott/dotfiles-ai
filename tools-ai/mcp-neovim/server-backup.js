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
import net from 'net';
import fs from 'fs/promises';

const execAsync = promisify(exec);

// Tool schemas
const CheckNeovimSchema = z.object({});

const ListInstancesSchema = z.object({});

const GetBuffersSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path")
});

const GetCurrentBufferSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path")
});

const ExecuteCommandSchema = z.object({
  socket: z.string().optional().default("/tmp/nvim.pipe").describe("Neovim socket path"),
  command: z.string().describe("Vim command to execute")
});

// Create MCP server
const server = new Server(
  {
    name: "neovim-mcp-server",
    version: "1.0.0",
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
      version: version
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
    // Check for socket files
    const sockets = [];
    
    // Check common socket locations
    const checkPaths = [
      '/tmp/nvim.pipe',
      '/tmp/nvimsocket',
      `${process.env.HOME}/.cache/nvim/server.pipe`
    ];
    
    for (const path of checkPaths) {
      try {
        await fs.access(path);
        sockets.push(path);
      } catch {
        // Socket doesn't exist
      }
    }
    
    // Also check for nvim processes
    const { stdout } = await execAsync('pgrep -la nvim').catch(() => ({ stdout: '' }));
    const processes = stdout.trim().split('\n').filter(Boolean);
    
    return {
      sockets: sockets,
      processes: processes.length,
      instances: sockets.length > 0 ? sockets : processes.length > 0 ? ["Running but no socket found"] : []
    };
  } catch (error) {
    return {
      error: error.message
    };
  }
}

// Helper to send command to neovim
async function sendToNeovim(socket, command) {
  return new Promise((resolve, reject) => {
    const client = net.createConnection(socket, () => {
      // Simple Neovim RPC - this is a basic implementation
      // In production, you'd want to use a proper Neovim RPC client
      client.write(command);
      client.end();
    });
    
    let response = '';
    client.on('data', (data) => {
      response += data.toString();
    });
    
    client.on('end', () => {
      resolve(response);
    });
    
    client.on('error', (err) => {
      reject(err);
    });
  });
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
        name: "neovim_buffers",
        description: "Get list of open buffers in Neovim",
        inputSchema: zodToJsonSchema(GetBuffersSchema),
      },
      {
        name: "neovim_current_buffer",
        description: "Get current buffer information",
        inputSchema: zodToJsonSchema(GetCurrentBufferSchema),
      },
      {
        name: "neovim_execute",
        description: "Execute a Vim command in Neovim",
        inputSchema: zodToJsonSchema(ExecuteCommandSchema),
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

      case "neovim_buffers": {
        const validated = GetBuffersSchema.parse(args);
        try {
          // This is a simplified version - proper implementation would use msgpack-rpc
          const result = await sendToNeovim(validated.socket, ':ls\n');
          return {
            content: [
              {
                type: "text",
                text: result || "Unable to get buffer list",
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error: Could not connect to Neovim at ${validated.socket}. Make sure Neovim is running with --listen ${validated.socket}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_current_buffer": {
        const validated = GetCurrentBufferSchema.parse(args);
        try {
          const result = await sendToNeovim(validated.socket, ':echo expand("%:p")\n');
          return {
            content: [
              {
                type: "text",
                text: result || "Unable to get current buffer",
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error: Could not connect to Neovim at ${validated.socket}`,
              },
            ],
            isError: true,
          };
        }
      }

      case "neovim_execute": {
        const validated = ExecuteCommandSchema.parse(args);
        try {
          const result = await sendToNeovim(validated.socket, `:${validated.command}\n`);
          return {
            content: [
              {
                type: "text",
                text: `Executed: ${validated.command}\n${result || "Command executed"}`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: `Error: Could not execute command in Neovim`,
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