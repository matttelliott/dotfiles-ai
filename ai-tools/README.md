# AI Tools Ecosystem

A comprehensive collection of AI-related tools, MCP servers, model configurations, and integrations for various AI assistants and agents.

## 📁 Directory Structure

```
ai-tools/
├── mcp-servers/      # Model Context Protocol servers
├── models/           # Model configurations and settings
├── clients/          # AI client configurations (Claude, OpenAI, etc.)
├── prompts/          # Reusable prompt templates
├── templates/        # Project templates for AI development
└── install.sh        # Unified AI tools installer
```

## 🚀 Quick Start

```bash
# Install all AI tools
./ai-tools/install.sh

# Install specific components
./ai-tools/install.sh mcp-servers
./ai-tools/install.sh models
./ai-tools/install.sh clients
```

## 🔧 Components

### MCP Servers
Model Context Protocol servers that provide tools and integrations for AI assistants:
- **tmux**: Read/control tmux sessions and panes
- More servers can be added as needed

### Models
Configuration files for various AI models:
- Claude (Anthropic)
- GPT (OpenAI)
- Llama (Meta)
- Custom/local models

### Clients
Configuration for AI clients and interfaces:
- Claude Desktop
- Claude CLI
- OpenAI CLI
- Ollama
- LM Studio
- Custom clients

### Prompts
Reusable prompt templates for common tasks:
- Code review
- Documentation generation
- Testing
- Refactoring
- Architecture design

### Templates
Project templates for AI development:
- MCP server template
- AI agent template
- RAG application template
- Chatbot template

## 🤖 Supported AI Systems

This ecosystem is designed to work with multiple AI providers and tools:

### Commercial
- **Anthropic Claude** (Desktop, CLI, API)
- **OpenAI GPT** (API, Playground)
- **Google Gemini** (API)
- **Amazon Bedrock** (Multiple models)

### Open Source
- **Ollama** (Local model runner)
- **LM Studio** (Local model GUI)
- **llama.cpp** (Efficient local inference)
- **vLLM** (High-throughput serving)

### Development Tools
- **Cline** (VS Code AI extension)
- **Cursor** (AI-powered editor)
- **Zed** (Editor with AI features)
- **Continue** (IDE extension)

## 🔌 MCP Protocol

The Model Context Protocol (MCP) is an open standard for connecting AI assistants to external tools and data sources. Any AI system that implements MCP client support can use our MCP servers.

### Current MCP Servers
- `tmux`: Full tmux integration for development workflows

### Adding New MCP Servers
1. Create a new directory in `mcp-servers/`
2. Implement the MCP protocol in your preferred language
3. Add installation script and documentation
4. Update the main installer

## 🛠️ Installation

### Prerequisites
- Node.js 18+ (for MCP servers)
- Python 3.11+ (for some AI tools)
- Unix-like environment (macOS, Linux, WSL)

### Full Installation
```bash
cd ~/dotfiles-ai/ai-tools
./install.sh
```

### Component Installation
```bash
# Install only MCP servers
./install.sh mcp-servers

# Install only model configurations
./install.sh models

# Install specific MCP server
./install.sh mcp-server tmux
```

## 📝 Configuration

### Environment Variables
```bash
# Add to ~/.zshrc or ~/.bashrc
export AI_TOOLS_HOME="$HOME/dotfiles-ai/ai-tools"
export MCP_SERVERS_PATH="$AI_TOOLS_HOME/mcp-servers"
export AI_MODELS_PATH="$AI_TOOLS_HOME/models"
```

### Claude Configuration
Claude Desktop and CLI configurations are automatically generated during installation.

### Custom Model Configuration
Edit files in `models/` to configure API keys, endpoints, and model parameters.

## 🔗 Integration with dotfiles-ai

This AI tools ecosystem integrates seamlessly with the main dotfiles-ai repository:
- Uses the same installation patterns
- Follows the same documentation standards
- Compatible with existing shell configurations
- Leverages installed development tools

## 📚 Documentation

- [MCP Servers Documentation](./mcp-servers/README.md)
- [Model Configurations](./models/README.md)
- [Client Setup Guides](./clients/README.md)
- [Prompt Library](./prompts/README.md)
- [Template Usage](./templates/README.md)

## 🤝 Contributing

To add new AI tools or integrations:
1. Follow the existing directory structure
2. Include comprehensive documentation
3. Add installation scripts
4. Update the main installer
5. Test on multiple platforms

## 📄 License

MIT License - See the main dotfiles-ai repository for details.