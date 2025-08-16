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

const execAsync = promisify(exec);

// Tool schemas
const ListSessionsSchema = z.object({
  include_details: z.boolean().optional().default(false).describe("Include detailed information about each pane")
});

const ReadPaneSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  pane: z.string().describe("Pane index"),
  lines: z.number().optional().default(100).describe("Number of lines to capture"),
  start_line: z.number().optional().default(-1).describe("Starting line number (for pagination)")
});

const SendCommandSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  pane: z.string().describe("Pane index"),
  command: z.string().describe("Command to send to the pane"),
  enter: z.boolean().optional().default(true).describe("Whether to send Enter key after command")
});

const CreateSessionSchema = z.object({
  name: z.string().describe("Session name"),
  command: z.string().optional().describe("Initial command to run"),
  directory: z.string().optional().describe("Starting directory"),
  detached: z.boolean().optional().default(true).describe("Create session in detached mode")
});

const SplitPaneSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  pane: z.string().optional().describe("Source pane index (defaults to current)"),
  direction: z.enum(["horizontal", "vertical"]).default("horizontal").describe("Split direction"),
  command: z.string().optional().describe("Command to run in new pane"),
  percentage: z.number().optional().describe("Size percentage for new pane")
});

const KillPaneSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  pane: z.string().describe("Pane index to kill")
});

const ResizePaneSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  pane: z.string().describe("Pane index"),
  direction: z.enum(["up", "down", "left", "right"]).describe("Resize direction"),
  amount: z.number().default(5).describe("Number of cells to resize")
});

const RenameWindowSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  new_name: z.string().describe("New window name")
});

const SelectPaneSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  pane: z.string().describe("Pane index to select")
});

const GetPaneInfoSchema = z.object({
  session: z.string().describe("Session name or ID"),
  window: z.string().describe("Window name or index"),
  pane: z.string().describe("Pane index")
});

// Create MCP server
const server = new Server(
  {
    name: "tmux-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to execute tmux commands
async function execTmux(command) {
  try {
    const { stdout, stderr } = await execAsync(`tmux ${command}`);
    if (stderr && !stderr.includes('no server running')) {
      throw new Error(stderr);
    }
    return stdout.trim();
  } catch (error) {
    if (error.message.includes('no server running')) {
      throw new Error('No tmux server running');
    }
    throw error;
  }
}

// List sessions tool
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "tmux_list_sessions",
        description: "List all tmux sessions with their windows and panes",
        inputSchema: zodToJsonSchema(ListSessionsSchema),
      },
      {
        name: "tmux_read_pane",
        description: "Read the contents/history of a specific tmux pane",
        inputSchema: zodToJsonSchema(ReadPaneSchema),
      },
      {
        name: "tmux_send_command",
        description: "Send a command to a specific tmux pane",
        inputSchema: zodToJsonSchema(SendCommandSchema),
      },
      {
        name: "tmux_create_session",
        description: "Create a new tmux session",
        inputSchema: zodToJsonSchema(CreateSessionSchema),
      },
      {
        name: "tmux_split_pane",
        description: "Split a tmux pane horizontally or vertically",
        inputSchema: zodToJsonSchema(SplitPaneSchema),
      },
      {
        name: "tmux_kill_pane",
        description: "Kill a specific tmux pane",
        inputSchema: zodToJsonSchema(KillPaneSchema),
      },
      {
        name: "tmux_resize_pane",
        description: "Resize a tmux pane",
        inputSchema: zodToJsonSchema(ResizePaneSchema),
      },
      {
        name: "tmux_rename_window",
        description: "Rename a tmux window",
        inputSchema: zodToJsonSchema(RenameWindowSchema),
      },
      {
        name: "tmux_select_pane",
        description: "Select/focus a specific tmux pane",
        inputSchema: zodToJsonSchema(SelectPaneSchema),
      },
      {
        name: "tmux_get_pane_info",
        description: "Get detailed information about a specific pane",
        inputSchema: zodToJsonSchema(GetPaneInfoSchema),
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "tmux_list_sessions": {
        const validated = ListSessionsSchema.parse(args);
        const sessions = await execTmux('list-sessions -F "#{session_name}"').catch(() => '');
        
        if (!sessions) {
          return {
            content: [
              {
                type: "text",
                text: "No tmux sessions found",
              },
            ],
          };
        }

        const sessionList = sessions.split('\n').filter(Boolean);
        let result = `Found ${sessionList.length} tmux session(s):\n`;

        for (const session of sessionList) {
          result += `\nSession: ${session}\n`;
          
          if (validated.include_details) {
            const windows = await execTmux(
              `list-windows -t "${session}" -F "#{window_index}:#{window_name} (#{window_panes} panes)"`
            );
            result += windows.split('\n').filter(Boolean).map(w => `  ${w}`).join('\n') + '\n';
          }
        }

        return {
          content: [
            {
              type: "text",
              text: result,
            },
          ],
        };
      }

      case "tmux_read_pane": {
        const validated = ReadPaneSchema.parse(args);
        const target = `${validated.session}:${validated.window}.${validated.pane}`;
        
        const output = await execTmux(`capture-pane -t "${target}" -p -S ${validated.start_line} -E ${validated.start_line + validated.lines}`);
        
        return {
          content: [
            {
              type: "text",
              text: output || "(empty)",
            },
          ],
        };
      }

      case "tmux_send_command": {
        const validated = SendCommandSchema.parse(args);
        const target = `${validated.session}:${validated.window}.${validated.pane}`;
        
        let sendKeys = `send-keys -t "${target}" "${validated.command.replace(/"/g, '\\"')}"`;
        if (validated.enter) {
          sendKeys += ' Enter';
        }
        
        await execTmux(sendKeys);
        
        return {
          content: [
            {
              type: "text",
              text: `Command sent to ${target}: ${validated.command}`,
            },
          ],
        };
      }

      case "tmux_create_session": {
        const validated = CreateSessionSchema.parse(args);
        let cmd = `new-session -s "${validated.name}"`;
        
        if (validated.detached) {
          cmd += ' -d';
        }
        
        if (validated.directory) {
          cmd += ` -c "${validated.directory}"`;
        }
        
        if (validated.command) {
          cmd += ` "${validated.command}"`;
        }
        
        await execTmux(cmd);
        
        return {
          content: [
            {
              type: "text",
              text: `Created tmux session: ${validated.name}`,
            },
          ],
        };
      }

      case "tmux_split_pane": {
        const validated = SplitPaneSchema.parse(args);
        const target = validated.pane 
          ? `${validated.session}:${validated.window}.${validated.pane}`
          : `${validated.session}:${validated.window}`;
        
        let cmd = `split-window -t "${target}"`;
        
        if (validated.direction === "horizontal") {
          cmd += ' -h';
        } else {
          cmd += ' -v';
        }
        
        if (validated.percentage) {
          cmd += ` -p ${validated.percentage}`;
        }
        
        if (validated.command) {
          cmd += ` "${validated.command}"`;
        }
        
        await execTmux(cmd);
        
        return {
          content: [
            {
              type: "text",
              text: `Split pane ${validated.direction}ly in ${validated.session}:${validated.window}`,
            },
          ],
        };
      }

      case "tmux_kill_pane": {
        const validated = KillPaneSchema.parse(args);
        const target = `${validated.session}:${validated.window}.${validated.pane}`;
        
        await execTmux(`kill-pane -t "${target}"`);
        
        return {
          content: [
            {
              type: "text",
              text: `Killed pane ${target}`,
            },
          ],
        };
      }

      case "tmux_resize_pane": {
        const validated = ResizePaneSchema.parse(args);
        const target = `${validated.session}:${validated.window}.${validated.pane}`;
        
        const directionFlags = {
          up: '-U',
          down: '-D',
          left: '-L',
          right: '-R'
        };
        
        await execTmux(`resize-pane -t "${target}" ${directionFlags[validated.direction]} ${validated.amount}`);
        
        return {
          content: [
            {
              type: "text",
              text: `Resized pane ${target} ${validated.direction} by ${validated.amount} cells`,
            },
          ],
        };
      }

      case "tmux_rename_window": {
        const validated = RenameWindowSchema.parse(args);
        const target = `${validated.session}:${validated.window}`;
        
        await execTmux(`rename-window -t "${target}" "${validated.new_name}"`);
        
        return {
          content: [
            {
              type: "text",
              text: `Renamed window ${target} to "${validated.new_name}"`,
            },
          ],
        };
      }

      case "tmux_select_pane": {
        const validated = SelectPaneSchema.parse(args);
        const target = `${validated.session}:${validated.window}.${validated.pane}`;
        
        await execTmux(`select-pane -t "${target}"`);
        
        return {
          content: [
            {
              type: "text",
              text: `Selected pane ${target}`,
            },
          ],
        };
      }

      case "tmux_get_pane_info": {
        const validated = GetPaneInfoSchema.parse(args);
        const target = `${validated.session}:${validated.window}.${validated.pane}`;
        
        const info = await execTmux(
          `display-message -t "${target}" -p "Pane: #{pane_index}\nTitle: #{pane_title}\nCurrent path: #{pane_current_path}\nCurrent command: #{pane_current_command}\nSize: #{pane_width}x#{pane_height}\nActive: #{pane_active}"`
        );
        
        return {
          content: [
            {
              type: "text",
              text: info,
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

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});