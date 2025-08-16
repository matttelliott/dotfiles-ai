#!/usr/bin/env node

/**
 * Neovim MCP Server
 * Provides Model Context Protocol interface for Neovim integration
 * Allows Claude to interact with Neovim instances via RPC
 */

const { spawn, exec } = require('child_process');
const { promisify } = require('util');
const net = require('net');
const path = require('path');
const fs = require('fs').promises;
const os = require('os');

const execAsync = promisify(exec);

class NeovimMCPServer {
    constructor() {
        this.nvimInstances = new Map();
        this.socketPath = null;
    }

    /**
     * Execute a shell command
     */
    async execCommand(command) {
        try {
            const { stdout, stderr } = await execAsync(command);
            return stdout.trim();
        } catch (error) {
            if (error.code === 127) {
                throw new Error('Command not found: ' + command.split(' ')[0]);
            }
            throw error;
        }
    }

    /**
     * Check if Neovim is installed
     */
    async checkNeovim() {
        try {
            const version = await this.execCommand('nvim --version');
            return {
                installed: true,
                version: version.split('\n')[0]
            };
        } catch (error) {
            return {
                installed: false,
                error: 'Neovim not found. Please install Neovim first.'
            };
        }
    }

    /**
     * List running Neovim instances with server sockets
     */
    async listInstances() {
        try {
            // Check for Neovim server sockets in tmp directories
            const tmpDirs = ['/tmp', os.tmpdir()];
            const instances = [];

            for (const dir of tmpDirs) {
                try {
                    const files = await fs.readdir(dir);
                    const nvimSockets = files.filter(f => 
                        f.startsWith('nvim') || f.includes('nvim.sock')
                    );

                    for (const socket of nvimSockets) {
                        const socketPath = path.join(dir, socket);
                        try {
                            const stats = await fs.stat(socketPath);
                            if (stats.isSocket()) {
                                instances.push({
                                    socket: socketPath,
                                    name: socket,
                                    pid: null // Could extract from socket name if formatted
                                });
                            }
                        } catch (e) {
                            // Skip if can't stat
                        }
                    }
                } catch (e) {
                    // Skip if can't read directory
                }
            }

            // Also check for nvim processes
            try {
                const processes = await this.execCommand('pgrep -f "nvim" || true');
                const pids = processes.split('\n').filter(Boolean);
                
                return {
                    instances,
                    processes: pids.length,
                    sockets: instances.length
                };
            } catch (e) {
                return { instances, processes: 0, sockets: instances.length };
            }
        } catch (error) {
            return { instances: [], processes: 0, sockets: 0, error: error.message };
        }
    }

    /**
     * Start a new Neovim instance with server socket
     */
    async startInstance(name = 'default', headless = false) {
        try {
            const socketName = `nvim-${name}-${Date.now()}.sock`;
            const socketPath = path.join(os.tmpdir(), socketName);

            // Start Neovim with server socket
            const args = ['--listen', socketPath];
            if (headless) {
                args.push('--headless');
            }

            const nvim = spawn('nvim', args, {
                detached: !headless,
                stdio: headless ? 'pipe' : 'ignore'
            });

            if (!headless) {
                nvim.unref();
            }

            this.nvimInstances.set(name, {
                process: nvim,
                socket: socketPath,
                pid: nvim.pid
            });

            // Wait for socket to be created
            let attempts = 0;
            while (attempts < 50) {
                try {
                    await fs.access(socketPath);
                    break;
                } catch (e) {
                    await new Promise(resolve => setTimeout(resolve, 100));
                    attempts++;
                }
            }

            return {
                success: true,
                name,
                socket: socketPath,
                pid: nvim.pid,
                headless
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Connect to a Neovim instance via socket
     */
    async connectToInstance(socketPath) {
        return new Promise((resolve, reject) => {
            const client = net.createConnection(socketPath, () => {
                resolve({
                    connected: true,
                    socket: socketPath
                });
                client.end();
            });

            client.on('error', (err) => {
                reject(new Error(`Failed to connect: ${err.message}`));
            });

            client.setTimeout(2000, () => {
                client.destroy();
                reject(new Error('Connection timeout'));
            });
        });
    }

    /**
     * Send a command to Neovim via nvim remote
     */
    async sendCommand(socketPath, command, expr = false) {
        try {
            const cmdType = expr ? '--remote-expr' : '--remote-send';
            const result = await this.execCommand(
                `nvim --server ${socketPath} ${cmdType} '${command}'`
            );
            return {
                success: true,
                result: result || 'Command executed'
            };
        } catch (error) {
            // Try with nvr (neovim-remote) as fallback
            try {
                const nvrCmd = expr ? '--remote-expr' : '--remote-send';
                const result = await this.execCommand(
                    `nvr --servername ${socketPath} ${nvrCmd} '${command}'`
                );
                return {
                    success: true,
                    result: result || 'Command executed',
                    method: 'nvr'
                };
            } catch (nvrError) {
                return {
                    success: false,
                    error: error.message,
                    suggestion: 'Install neovim-remote: pip install neovim-remote'
                };
            }
        }
    }

    /**
     * Open a file in Neovim
     */
    async openFile(socketPath, filePath, lineNumber = null) {
        try {
            let command = `:e ${filePath}`;
            if (lineNumber) {
                command += ` | :${lineNumber}`;
            }
            command += '<CR>';

            return await this.sendCommand(socketPath, command);
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Get current buffer info
     */
    async getBufferInfo(socketPath) {
        try {
            const fileName = await this.sendCommand(socketPath, 'expand("%:p")', true);
            const lineNumber = await this.sendCommand(socketPath, 'line(".")', true);
            const colNumber = await this.sendCommand(socketPath, 'col(".")', true);
            const mode = await this.sendCommand(socketPath, 'mode()', true);

            return {
                file: fileName.result,
                line: parseInt(lineNumber.result),
                column: parseInt(colNumber.result),
                mode: mode.result
            };
        } catch (error) {
            return {
                error: error.message
            };
        }
    }

    /**
     * List all buffers
     */
    async listBuffers(socketPath) {
        try {
            const result = await this.sendCommand(
                socketPath,
                'execute("ls")',
                true
            );
            
            if (result.success) {
                const buffers = result.result.split('\n').map(line => {
                    const match = line.match(/^\s*(\d+)\s+([%#ah]+)?\s*"([^"]+)"/);
                    if (match) {
                        return {
                            number: parseInt(match[1]),
                            flags: match[2] || '',
                            name: match[3],
                            active: (match[2] || '').includes('%'),
                            alternate: (match[2] || '').includes('#'),
                            hidden: (match[2] || '').includes('h')
                        };
                    }
                    return null;
                }).filter(Boolean);

                return { buffers };
            }
            return { buffers: [], error: result.error };
        } catch (error) {
            return { buffers: [], error: error.message };
        }
    }

    /**
     * Save current buffer
     */
    async saveBuffer(socketPath, force = false) {
        const command = force ? ':w!' : ':w';
        return await this.sendCommand(socketPath, command + '<CR>');
    }

    /**
     * Execute Vim command
     */
    async executeVimCommand(socketPath, command) {
        return await this.sendCommand(socketPath, `:${command}<CR>`);
    }

    /**
     * Insert text at cursor
     */
    async insertText(socketPath, text) {
        // Escape special characters
        const escaped = text.replace(/'/g, "''");
        return await this.sendCommand(socketPath, `i${escaped}<Esc>`);
    }

    /**
     * Search in buffer
     */
    async search(socketPath, pattern, backwards = false) {
        const searchCmd = backwards ? '?' : '/';
        return await this.sendCommand(socketPath, `${searchCmd}${pattern}<CR>`);
    }

    /**
     * Get visual selection
     */
    async getVisualSelection(socketPath) {
        try {
            const result = await this.sendCommand(
                socketPath,
                'getline("\'<", "\'>")[:]',
                true
            );
            return {
                success: true,
                selection: result.result
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Main handler for MCP requests
     */
    async handleRequest(method, params) {
        switch (method) {
            case 'neovim/check':
                return await this.checkNeovim();

            case 'neovim/list':
                return await this.listInstances();

            case 'neovim/start':
                return await this.startInstance(
                    params.name,
                    params.headless
                );

            case 'neovim/connect':
                return await this.connectToInstance(params.socket);

            case 'neovim/command':
                return await this.sendCommand(
                    params.socket,
                    params.command,
                    params.expr
                );

            case 'neovim/open':
                return await this.openFile(
                    params.socket,
                    params.file,
                    params.line
                );

            case 'neovim/buffer-info':
                return await this.getBufferInfo(params.socket);

            case 'neovim/buffers':
                return await this.listBuffers(params.socket);

            case 'neovim/save':
                return await this.saveBuffer(params.socket, params.force);

            case 'neovim/vim-command':
                return await this.executeVimCommand(
                    params.socket,
                    params.command
                );

            case 'neovim/insert':
                return await this.insertText(params.socket, params.text);

            case 'neovim/search':
                return await this.search(
                    params.socket,
                    params.pattern,
                    params.backwards
                );

            case 'neovim/selection':
                return await this.getVisualSelection(params.socket);

            default:
                throw new Error(`Unknown method: ${method}`);
        }
    }
}

// MCP Server Interface
if (require.main === module) {
    const server = new NeovimMCPServer();
    
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

    // Handle server info request
    if (process.argv.includes('--info')) {
        console.log(JSON.stringify({
            name: 'Neovim MCP Server',
            version: '1.0.0',
            methods: [
                'neovim/check',
                'neovim/list',
                'neovim/start',
                'neovim/connect',
                'neovim/command',
                'neovim/open',
                'neovim/buffer-info',
                'neovim/buffers',
                'neovim/save',
                'neovim/vim-command',
                'neovim/insert',
                'neovim/search',
                'neovim/selection'
            ]
        }, null, 2));
        process.exit(0);
    }
}

module.exports = NeovimMCPServer;