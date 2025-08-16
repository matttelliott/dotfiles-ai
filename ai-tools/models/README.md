# AI Model Configurations

Centralized configuration for various AI models and providers.

## 📁 Structure

```
models/
├── claude/           # Anthropic Claude configurations
├── openai/          # OpenAI GPT configurations
├── ollama/          # Local Ollama models
├── bedrock/         # AWS Bedrock configurations
├── vertex/          # Google Vertex AI
└── custom/          # Custom model configurations
```

## 🔧 Configuration Files

Each model provider directory contains:
- `config.json` - Main configuration
- `models.json` - Available models and their parameters
- `api-keys.env` - API keys (gitignored)
- `prompts/` - Provider-specific prompts

## 🔐 Security

**Never commit API keys!** All `*.env` and `*-keys.*` files are gitignored.

### Setting API Keys

```bash
# Create local API keys file (gitignored)
cat > models/openai/api-keys.env << EOF
OPENAI_API_KEY=sk-...
OPENAI_ORG_ID=org-...
EOF

# For Claude
cat > models/claude/api-keys.env << EOF
ANTHROPIC_API_KEY=sk-ant-...
EOF
```

## 🤖 Provider Configurations

### Claude (Anthropic)
- Models: Claude 3 Opus, Sonnet, Haiku
- Claude 2.1, Claude Instant
- Configuration for both API and Desktop app

### OpenAI
- GPT-4, GPT-4 Turbo, GPT-3.5
- Custom fine-tuned models
- Function calling configurations

### Ollama (Local)
- Llama 2/3
- Mistral
- CodeLlama
- Custom quantized models

### AWS Bedrock
- Multiple provider models
- Region-specific endpoints
- IAM configuration

### Google Vertex AI
- Gemini Pro/Ultra
- PaLM 2
- Custom models

## 📝 Example Configuration

### models/claude/config.json
```json
{
  "provider": "anthropic",
  "default_model": "claude-3-opus-20240229",
  "api_version": "2024-01-01",
  "max_tokens_default": 4096,
  "temperature_default": 0.7,
  "endpoint": "https://api.anthropic.com/v1",
  "timeout": 300,
  "retry_attempts": 3,
  "rate_limit": {
    "requests_per_minute": 50,
    "tokens_per_minute": 100000
  }
}
```

### models/ollama/config.json
```json
{
  "provider": "ollama",
  "endpoint": "http://localhost:11434",
  "default_model": "llama2:latest",
  "gpu_layers": 35,
  "context_window": 4096,
  "models_path": "~/.ollama/models",
  "auto_pull": true
}
```

## 🚀 Usage

### With Scripts
```bash
# Load configuration
source ai-tools/models/claude/api-keys.env
CONFIG=$(cat ai-tools/models/claude/config.json)

# Use in API calls
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: $(echo $CONFIG | jq -r .api_version)" \
  ...
```

### With Python
```python
import json
import os
from pathlib import Path

# Load model configuration
config_path = Path.home() / "dotfiles-ai/ai-tools/models/claude/config.json"
with open(config_path) as f:
    config = json.load(f)

# Load API keys
from dotenv import load_dotenv
load_dotenv(config_path.parent / "api-keys.env")

# Use configuration
api_key = os.getenv("ANTHROPIC_API_KEY")
model = config["default_model"]
```

## 🔄 Model Switching

The configuration supports easy model switching:

```bash
# Set default model
export AI_DEFAULT_PROVIDER="claude"
export AI_DEFAULT_MODEL="claude-3-opus-20240229"

# Override for specific tasks
export AI_CODING_MODEL="claude-3-sonnet-20240229"
export AI_WRITING_MODEL="gpt-4-turbo-preview"
```

## 📊 Model Comparison

| Provider | Model | Context | Strengths | Best For |
|----------|-------|---------|-----------|----------|
| Claude | Opus | 200k | Reasoning, code | Complex tasks |
| Claude | Sonnet | 200k | Balance | General use |
| GPT-4 | Turbo | 128k | Broad knowledge | Research |
| Llama 2 | 70B | 4k | Open source | Local/private |
| Gemini | Pro | 32k | Multimodal | Images+text |

## 🔗 Integration

These configurations integrate with:
- MCP servers (for tool access)
- Client applications (CLI, desktop apps)
- Development environments (VS Code, Cursor)
- Custom scripts and automations