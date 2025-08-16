# MCP Servers for dotfiles-ai

This directory contains Model Context Protocol (MCP) servers that extend Claude CLI with powerful integrations for the tools and configurations managed by dotfiles-ai.

## What is MCP?

Model Context Protocol (MCP) is a standard that allows AI assistants like Claude to connect to external tools and data sources. MCP servers provide specific capabilities that AI assistants can use to help you with complex tasks.

## Available MCP Servers

### Tmux Integration (`tmux/`)

A comprehensive MCP server that gives Claude CLI deep integration with tmux sessions.

**Capabilities:**
- Read contents from any tmux pane
- List all sessions, windows, and panes
- Send commands to specific panes
- Create and manage tmux sessions
- Control pane splitting and layouts
- Monitor processes across your terminal workspace

**Use Cases:**
- Development environment automation
- Multi-service monitoring
- Debugging session management
- Log analysis across multiple panes
- Intelligent terminal workspace organization

**Installation:**
```bash
./mcp-servers/tmux/install
```

## Integration with dotfiles-ai

These MCP servers are designed to work seamlessly with the tools and configurations provided by dotfiles-ai:

### Tmux Integration
- Works with the enhanced tmux configuration from `tools-cli/tmux/`
- Leverages the improved key bindings and layouts
- Integrates with development workflows established by other tools

### Development Workflow Enhancement
- **Editor Integration**: Works with neovim configurations
- **Shell Integration**: Leverages zsh configurations and aliases
- **Language Tools**: Monitors language servers and development tools
- **Cloud Tools**: Integrates with AWS, kubectl, and other cloud utilities

### Cross-Tool Coordination
- **Git Operations**: Can monitor git processes in tmux panes
- **Build Systems**: Can watch build outputs and test results
- **Database Work**: Can monitor database clients and query outputs
- **Docker/Kubernetes**: Can manage container-related workflows

## Getting Started

1. **Install Prerequisites**:
   - Ensure tmux is installed via `tools-cli/tmux/install`
   - Install Node.js via `tools-lang/node/install`
   - Have Claude CLI installed and configured

2. **Install MCP Servers**:
   ```bash
   # Install tmux MCP server
   ./mcp-servers/tmux/install
   ```

3. **Restart Claude CLI** to load the new capabilities

4. **Test Integration**:
   ```bash
   # Test the tmux MCP server
   ./mcp-servers/tmux/test-server.js
   ```

5. **Start Using Enhanced Capabilities**:
   - Ask Claude to read from your tmux panes
   - Have Claude help set up development environments
   - Use Claude to monitor and manage your terminal workspace

## Usage Examples

### Development Environment Setup
```
Create a new development session for my React project with editor, dev server, and test runner
```

### Multi-Service Monitoring
```
Check the status of all services running in my monitoring session and alert me to any issues
```

### Debugging Assistance
```
Read the error output from my application logs and help me understand what's failing
```

### Workflow Automation
```
Set up my usual development environment with all the sessions and panes I need for this project
```

## Security Considerations

MCP servers provide powerful access to your development environment:

- **Command Execution**: Can send commands to tmux panes
- **Content Access**: Can read all content from tmux sessions
- **Process Control**: Can create and manage tmux sessions

**Best Practices:**
- Only use in trusted environments
- Review automated commands before execution
- Monitor what actions are being performed
- Keep MCP server configurations secure

## Troubleshooting

### Common Issues

1. **MCP Server Not Loading**:
   - Check Claude CLI configuration file
   - Verify server script is executable
   - Ensure Node.js is available in PATH

2. **Tmux Integration Issues**:
   - Verify tmux is installed and running
   - Check that tmux sessions exist
   - Ensure proper session/window/pane targeting

3. **Permission Problems**:
   - Make sure server scripts are executable
   - Check file permissions on configuration files
   - Verify user has access to tmux socket

### Debug Mode

Run MCP servers in debug mode to troubleshoot issues:

```bash
# Run tmux MCP server manually
cd mcp-servers/tmux
node server.js
```

Then test with JSON-RPC messages to isolate problems.

## Contributing

To add new MCP servers to dotfiles-ai:

1. **Create New Directory**: `mcp-servers/toolname/`
2. **Implement MCP Server**: Following the standard MCP protocol
3. **Create Installation Script**: Automated setup and configuration
4. **Write Documentation**: Comprehensive usage guide
5. **Add Integration**: Update this README and main installers
6. **Test Thoroughly**: Ensure compatibility across platforms

### Development Guidelines

- **Self-Contained**: Each MCP server should be independent
- **Platform Support**: Support both macOS and Linux where possible
- **Error Handling**: Graceful failure and helpful error messages
- **Documentation**: Clear examples and troubleshooting guides
- **Security**: Safe defaults and clear capability boundaries

## Future MCP Servers

Planned additions to enhance Claude CLI integration:

### Development Tools
- **Git MCP Server**: Advanced git operations and history analysis
- **Docker MCP Server**: Container management and monitoring
- **Database MCP Server**: Query execution and schema analysis
- **Test MCP Server**: Test execution and result analysis

### System Integration
- **File System MCP Server**: Advanced file operations
- **Process MCP Server**: System process monitoring and control
- **Network MCP Server**: Network diagnostics and monitoring
- **Log MCP Server**: Centralized log aggregation and analysis

### Cloud and Infrastructure
- **AWS MCP Server**: Cloud resource management
- **Kubernetes MCP Server**: Cluster operations and monitoring
- **Terraform MCP Server**: Infrastructure as code operations
- **CI/CD MCP Server**: Build pipeline integration

## Resources

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Claude CLI Documentation](https://claude.ai/cli)
- [Tmux Documentation](https://tmux.github.io/)
- [dotfiles-ai Repository](../README.md)