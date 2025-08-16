#!/usr/bin/env node

/**
 * Tmux MCP Server
 * 
 * A Model Context Protocol (MCP) server that provides Claude CLI with comprehensive
 * tmux integration capabilities including reading pane contents, managing sessions,
 * and controlling tmux operations.
 * 
 * Features:
 * - List all tmux sessions and their windows/panes
 * - Read contents and history from any pane
 * - Get current pane information and process details
 * - Send commands to specific panes
 * - Create and manage tmux sessions
 * - Monitor pane activity and changes
 */

const { spawn, exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

class TmuxMCPServer {
  constructor() {
    this.tools = [
      {
        name: "tmux_list_sessions",
        description: "List all tmux sessions with their windows and panes",
        inputSchema: {
          type: "object",
          properties: {
            include_details: {
              type: "boolean",
              description: "Include detailed information about each pane",
              default: false
            }
          }
        }
      },
      {
        name: "tmux_read_pane",
        description: "Read the contents/history of a specific tmux pane",
        inputSchema: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "Session name or ID"
            },
            window: {
              type: "string", 
              description: "Window name or index"
            },
            pane: {
              type: "string",
              description: "Pane index"
            },
            lines: {
              type: "number",
              description: "Number of lines to capture (default: 100)",
              default: 100
            },
            start_line: {
              type: "number",
              description: "Starting line number (for pagination)",
              default: -1
            }
          },
          required: ["session", "window", "pane"]
        }
      },
      {
        name: "tmux_get_pane_info",
        description: "Get detailed information about a specific pane",
        inputSchema: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "Session name or ID"
            },
            window: {
              type: "string",
              description: "Window name or index" 
            },
            pane: {
              type: "string",
              description: "Pane index"
            }
          },
          required: ["session", "window", "pane"]
        }
      },
      {
        name: "tmux_send_command",
        description: "Send a command to a specific tmux pane",
        inputSchema: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "Session name or ID"
            },
            window: {
              type: "string",
              description: "Window name or index"
            },
            pane: {
              type: "string", 
              description: "Pane index"
            },
            command: {
              type: "string",
              description: "Command to send to the pane"
            },
            enter: {
              type: "boolean",
              description: "Whether to send Enter key after command",
              default: true
            }
          },
          required: ["session", "window", "pane", "command"]
        }
      },
      {
        name: "tmux_create_session",
        description: "Create a new tmux session",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Session name"
            },
            command: {
              type: "string",
              description: "Initial command to run"
            },
            directory: {
              type: "string",
              description: "Starting directory"
            },
            detached: {
              type: "boolean",
              description: "Create session in detached mode",
              default: true
            }
          },
          required: ["name"]
        }
      },
      {
        name: "tmux_kill_session",
        description: "Kill a tmux session",
        inputSchema: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "Session name or ID to kill"
            }
          },
          required: ["session"]
        }
      },
      {
        name: "tmux_create_window",
        description: "Create a new window in a tmux session",
        inputSchema: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "Session name or ID"
            },
            name: {
              type: "string",
              description: "Window name"
            },
            command: {
              type: "string",
              description: "Command to run in the window"
            },
            directory: {
              type: "string",
              description: "Starting directory"
            }
          },
          required: ["session"]
        }
      },
      {
        name: "tmux_split_pane",
        description: "Split a pane in a tmux window",
        inputSchema: {
          type: "object",
          properties: {
            session: {
              type: "string",
              description: "Session name or ID"
            },
            window: {
              type: "string",
              description: "Window name or index"
            },
            pane: {
              type: "string",
              description: "Pane index to split"
            },
            direction: {
              type: "string",
              enum: ["horizontal", "vertical"],
              description: "Split direction",
              default: "horizontal"
            },
            command: {
              type: "string",
              description: "Command to run in new pane"
            },
            percentage: {
              type: "number",
              description: "Size percentage for new pane",
              minimum: 1,
              maximum: 99
            }
          },
          required: ["session", "window", "pane"]
        }
      }
    ];
  }

  async execTmux(args) {
    try {
      const { stdout, stderr } = await execAsync(`tmux ${args}`);
      if (stderr && !stderr.includes('no server running')) {
        throw new Error(stderr);
      }
      return stdout.trim();
    } catch (error) {
      throw new Error(`Tmux command failed: ${error.message}`);
    }
  }

  async listSessions(includeDetails = false) {
    try {
      // Check if tmux server is running
      const sessions = await this.execTmux('list-sessions -F "#{session_name}:#{session_id}:#{session_created}:#{session_attached}:#{session_windows}"');
      
      if (!sessions) {
        return { sessions: [] };
      }

      const sessionList = [];
      
      for (const sessionLine of sessions.split('\n')) {
        const [name, id, created, attached, windowCount] = sessionLine.split(':');
        
        const sessionInfo = {
          name,
          id,
          created: new Date(parseInt(created) * 1000).toISOString(),
          attached: attached === '1',
          windowCount: parseInt(windowCount)
        };

        if (includeDetails) {
          // Get windows for this session
          const windows = await this.execTmux(`list-windows -t "${name}" -F "#{window_index}:#{window_name}:#{window_panes}:#{window_active}"`);
          sessionInfo.windows = [];

          for (const windowLine of windows.split('\n')) {
            const [index, windowName, paneCount, active] = windowLine.split(':');
            
            const windowInfo = {
              index: parseInt(index),
              name: windowName,
              paneCount: parseInt(paneCount),
              active: active === '1',
              panes: []
            };

            // Get panes for this window
            const panes = await this.execTmux(`list-panes -t "${name}:${index}" -F "#{pane_index}:#{pane_current_command}:#{pane_pid}:#{pane_active}:#{pane_width}:#{pane_height}"`);
            
            for (const paneLine of panes.split('\n')) {
              const [paneIndex, command, pid, paneActive, width, height] = paneLine.split(':');
              
              windowInfo.panes.push({
                index: parseInt(paneIndex),
                command,
                pid: parseInt(pid),
                active: paneActive === '1',
                width: parseInt(width),
                height: parseInt(height)
              });
            }

            sessionInfo.windows.push(windowInfo);
          }
        }

        sessionList.push(sessionInfo);
      }

      return { sessions: sessionList };
    } catch (error) {
      if (error.message.includes('no server running')) {
        return { sessions: [], message: "No tmux server running" };
      }
      throw error;
    }
  }

  async readPane(session, window, pane, lines = 100, startLine = -1) {
    try {
      const target = `${session}:${window}.${pane}`;
      
      // Verify the pane exists
      await this.execTmux(`display-message -t "${target}" -p "#{pane_id}"`);
      
      let captureArgs = `-t "${target}" -p`;
      
      if (startLine >= 0) {
        captureArgs += ` -S ${startLine}`;
      } else {
        captureArgs += ` -S -${lines}`;
      }
      
      if (lines > 0) {
        captureArgs += ` -E ${startLine >= 0 ? startLine + lines - 1 : -1}`;
      }

      const content = await this.execTmux(`capture-pane ${captureArgs}`);
      
      // Get additional pane info
      const paneInfo = await this.getPaneInfo(session, window, pane);
      
      return {
        content,
        lines: content.split('\n').length,
        target,
        paneInfo
      };
    } catch (error) {
      throw new Error(`Failed to read pane ${session}:${window}.${pane}: ${error.message}`);
    }
  }

  async getPaneInfo(session, window, pane) {
    try {
      const target = `${session}:${window}.${pane}`;
      
      const info = await this.execTmux(`display-message -t "${target}" -p "#{pane_id}:#{pane_index}:#{pane_current_command}:#{pane_pid}:#{pane_width}:#{pane_height}:#{pane_left}:#{pane_top}:#{pane_active}:#{pane_current_path}:#{pane_title}"`);
      
      const [id, index, command, pid, width, height, left, top, active, currentPath, title] = info.split(':');
      
      return {
        id,
        index: parseInt(index),
        command,
        pid: parseInt(pid),
        dimensions: {
          width: parseInt(width),
          height: parseInt(height)
        },
        position: {
          left: parseInt(left),
          top: parseInt(top)
        },
        active: active === '1',
        currentPath,
        title,
        target
      };
    } catch (error) {
      throw new Error(`Failed to get pane info for ${session}:${window}.${pane}: ${error.message}`);
    }
  }

  async sendCommand(session, window, pane, command, sendEnter = true) {
    try {
      const target = `${session}:${window}.${pane}`;
      
      // Verify the pane exists
      await this.execTmux(`display-message -t "${target}" -p "#{pane_id}"`);
      
      let sendKeys = `send-keys -t "${target}" "${command.replace(/"/g, '\\"')}"`;
      if (sendEnter) {
        sendKeys += ' Enter';
      }
      
      await this.execTmux(sendKeys);
      
      return {
        success: true,
        target,
        command,
        sentEnter: sendEnter
      };
    } catch (error) {
      throw new Error(`Failed to send command to ${session}:${window}.${pane}: ${error.message}`);
    }
  }

  async createSession(name, command = null, directory = null, detached = true) {
    try {
      let newSessionCmd = `new-session -s "${name}"`;
      
      if (detached) {
        newSessionCmd += ' -d';
      }
      
      if (directory) {
        newSessionCmd += ` -c "${directory}"`;
      }
      
      if (command) {
        newSessionCmd += ` "${command}"`;
      }
      
      await this.execTmux(newSessionCmd);
      
      return {
        success: true,
        sessionName: name,
        detached,
        command,
        directory
      };
    } catch (error) {
      throw new Error(`Failed to create session "${name}": ${error.message}`);
    }
  }

  async killSession(session) {
    try {
      await this.execTmux(`kill-session -t "${session}"`);
      
      return {
        success: true,
        killedSession: session
      };
    } catch (error) {
      throw new Error(`Failed to kill session "${session}": ${error.message}`);
    }
  }

  async createWindow(session, name = null, command = null, directory = null) {
    try {
      let newWindowCmd = `new-window -t "${session}"`;
      
      if (name) {
        newWindowCmd += ` -n "${name}"`;
      }
      
      if (directory) {
        newWindowCmd += ` -c "${directory}"`;
      }
      
      if (command) {
        newWindowCmd += ` "${command}"`;
      }
      
      const result = await this.execTmux(newWindowCmd);
      
      return {
        success: true,
        session,
        windowName: name,
        command,
        directory
      };
    } catch (error) {
      throw new Error(`Failed to create window in session "${session}": ${error.message}`);
    }
  }

  async splitPane(session, window, pane, direction = 'horizontal', command = null, percentage = null) {
    try {
      const target = `${session}:${window}.${pane}`;
      
      let splitCmd = `split-window -t "${target}"`;
      
      if (direction === 'vertical') {
        splitCmd += ' -h';
      } else {
        splitCmd += ' -v';
      }
      
      if (percentage) {
        splitCmd += ` -p ${percentage}`;
      }
      
      if (command) {
        splitCmd += ` "${command}"`;
      }
      
      await this.execTmux(splitCmd);
      
      return {
        success: true,
        target,
        direction,
        command,
        percentage
      };
    } catch (error) {
      throw new Error(`Failed to split pane ${session}:${window}.${pane}: ${error.message}`);
    }
  }

  async handleToolCall(name, args) {
    try {
      switch (name) {
        case 'tmux_list_sessions':
          return await this.listSessions(args.include_details);
          
        case 'tmux_read_pane':
          return await this.readPane(
            args.session, 
            args.window, 
            args.pane, 
            args.lines, 
            args.start_line
          );
          
        case 'tmux_get_pane_info':
          return await this.getPaneInfo(args.session, args.window, args.pane);
          
        case 'tmux_send_command':
          return await this.sendCommand(
            args.session, 
            args.window, 
            args.pane, 
            args.command, 
            args.enter
          );
          
        case 'tmux_create_session':
          return await this.createSession(
            args.name, 
            args.command, 
            args.directory, 
            args.detached
          );
          
        case 'tmux_kill_session':
          return await this.killSession(args.session);
          
        case 'tmux_create_window':
          return await this.createWindow(
            args.session, 
            args.name, 
            args.command, 
            args.directory
          );
          
        case 'tmux_split_pane':
          return await this.splitPane(
            args.session, 
            args.window, 
            args.pane, 
            args.direction, 
            args.command, 
            args.percentage
          );
          
        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    } catch (error) {
      return {
        error: error.message,
        tool: name,
        args
      };
    }
  }

  // MCP Protocol Implementation
  async start() {
    process.stdin.setEncoding('utf8');
    process.stdout.setEncoding('utf8');

    const readLine = () => {
      return new Promise((resolve) => {
        let data = '';
        const onData = (chunk) => {
          data += chunk;
          const lines = data.split('\n');
          if (lines.length > 1) {
            process.stdin.removeListener('data', onData);
            resolve(lines[0]);
          }
        };
        process.stdin.on('data', onData);
      });
    };

    const sendResponse = (response) => {
      process.stdout.write(JSON.stringify(response) + '\n');
    };

    // Send initial capabilities
    sendResponse({
      jsonrpc: "2.0",
      result: {
        capabilities: {
          tools: {}
        },
        serverInfo: {
          name: "tmux-mcp-server",
          version: "1.0.0"
        }
      }
    });

    // Handle incoming messages
    while (true) {
      try {
        const line = await readLine();
        if (!line.trim()) continue;

        const message = JSON.parse(line);

        if (message.method === 'tools/list') {
          sendResponse({
            jsonrpc: "2.0",
            id: message.id,
            result: {
              tools: this.tools
            }
          });
        } else if (message.method === 'tools/call') {
          const result = await this.handleToolCall(
            message.params.name,
            message.params.arguments || {}
          );
          
          sendResponse({
            jsonrpc: "2.0",
            id: message.id,
            result: {
              content: [
                {
                  type: "text",
                  text: JSON.stringify(result, null, 2)
                }
              ]
            }
          });
        } else {
          sendResponse({
            jsonrpc: "2.0",
            id: message.id,
            error: {
              code: -32601,
              message: "Method not found"
            }
          });
        }
      } catch (error) {
        sendResponse({
          jsonrpc: "2.0",
          error: {
            code: -32603,
            message: `Internal error: ${error.message}`
          }
        });
      }
    }
  }
}

// Start the server if run directly
if (require.main === module) {
  const server = new TmuxMCPServer();
  server.start().catch(console.error);
}

module.exports = TmuxMCPServer;