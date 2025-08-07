# direnv - Project-Specific Environment Variables

Automatically load and unload environment variables based on your current directory. Perfect for managing per-project configurations, secrets, and development environments.

## Installation

```bash
./tools-cli/direnv/setup.sh
```

## What is direnv?

direnv is an environment switcher that:
- Loads/unloads environment variables based on `.envrc` files
- Provides project isolation without virtualenvs
- Integrates seamlessly with your shell
- Supports multiple languages and frameworks
- Manages secrets and API keys per project
- Enables consistent team development environments

## Basic Usage

### Quick Start
```bash
# Create .envrc in your project
echo 'export API_KEY="secret"' > .envrc

# Allow the file (required for security)
direnv allow

# Variables are now loaded!
echo $API_KEY  # Outputs: secret

# Leave directory - variables unloaded
cd ..
echo $API_KEY  # Empty
```

### Essential Commands
```bash
# Allow .envrc file
direnv allow
da              # Alias

# Block .envrc file
direnv block
db              # Alias

# Reload current environment
direnv reload
dr              # Alias

# Edit .envrc
direnv edit
de              # Alias

# Show direnv status
direnv status
ds              # Alias

# Clean up old environments
direnv prune
dp              # Alias
```

## Helper Functions

### Initialize Project
```bash
# Create basic .envrc
direnv-init

# Creates:
# - Basic .envrc template
# - Loads .env if exists
# - Sets PROJECT_NAME
```

### Language-Specific Setup
```bash
# Python project
direnv-python    # Adds Python virtualenv

# Node.js project
direnv-node      # Adds Node.js environment

# Go project
direnv-go        # Adds Go workspace

# Docker project
direnv-docker    # Adds Docker env vars

# AWS project
direnv-aws [profile]  # Sets AWS profile

# Secrets management
direnv-secrets   # Creates .env template
```

## Configuration Templates

### Python Project
```bash
# .envrc
layout python

# Or with specific Python version
layout python python3.11

# Or with pyenv
layout pyenv 3.11

# Python-specific settings
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Virtual environment in .direnv/
# Auto-activates when entering directory
```

### Node.js Project
```bash
# .envrc
layout node

# Or with nvm
layout nvm 18

# Node-specific settings
export NODE_ENV="${NODE_ENV:-development}"

# Add node_modules/.bin to PATH
PATH_add node_modules/.bin
```

### Go Project
```bash
# .envrc
layout go

# Go-specific settings
export GO111MODULE=on
export GOFLAGS="-mod=vendor"

# GOPATH set to .direnv/go
```

### Ruby Project
```bash
# .envrc
layout rbenv 3.0.0

# Ruby-specific settings
export GEM_HOME="$PWD/.direnv/gems"
PATH_add "$GEM_HOME/bin"
```

### Rust Project
```bash
# .envrc
layout rust

# Rust-specific settings
export RUST_BACKTRACE=1
export RUST_LOG="${RUST_LOG:-debug}"

# CARGO_HOME set to .direnv/cargo
```

### Docker Project
```bash
# .envrc
layout_docker

# Docker settings
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export COMPOSE_PROJECT_NAME="$(basename $PWD)"
```

## Environment Variables

### Loading .env Files
```bash
# .envrc

# Load .env file
dotenv

# Load if exists
dotenv_if_exists

# Load specific file
dotenv_if_exists .env.local

# Load multiple files
dotenv_if_exists .env
dotenv_if_exists .env.local
dotenv_if_exists ".env.${ENVIRONMENT}"
```

### Managing Secrets
```bash
# Create .env template
direnv-secrets

# Creates:
# - .env with template variables
# - .env.local for actual secrets
# - Adds .env.local to .gitignore
# - Updates .envrc to load .env.local
```

Example .env template:
```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost/dbname
REDIS_URL=redis://localhost:6379

# API Keys
SECRET_KEY=change-me
API_KEY=
STRIPE_KEY=

# AWS
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1
```

## Cloud Environments

### AWS Profile
```bash
# .envrc
use_aws production

# Or specify profile
export AWS_PROFILE="production"
export AWS_REGION="us-east-1"
```

### Google Cloud
```bash
# .envrc
use_gcp my-project

# Or manually
export CLOUDSDK_CORE_PROJECT="my-project"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"
```

### Kubernetes
```bash
# .envrc
use_k8s production-cluster

# Or manually
export KUBECONFIG="$PWD/.kube/config"
export NAMESPACE="production"
```

## Advanced Features

### Required Commands
```bash
# .envrc
# Ensure tools are available
require python3 pip poetry
require docker docker-compose
require terraform aws
```

### Required Variables
```bash
# .envrc
# Ensure variables are set
require_env DATABASE_URL API_KEY
```

### Watch Additional Files
```bash
# .envrc
# Reload when these files change
watch_file package.json
watch_file requirements.txt
watch_file Gemfile
```

### Strict Mode
```bash
# .envrc
strict_env  # Sets -euo pipefail

# Any command failure will prevent loading
```

### PATH Management
```bash
# .envrc
# Add to PATH (prepend)
PATH_add bin
PATH_add scripts
PATH_add vendor/bin

# Or append
path_add PATH bin
```

### Custom Functions
```bash
# .envrc
# Define project commands
dev() {
    npm run dev
}

test() {
    pytest "$@"
}

deploy() {
    ./scripts/deploy.sh "$@"
}
```

## Project Templates

### Full Stack Application
```bash
# .envrc
strict_env

# Frontend
export VITE_API_URL="${API_URL:-http://localhost:3001}"
export NODE_ENV="${NODE_ENV:-development}"

# Backend
export PORT="${PORT:-3001}"
export DATABASE_URL="${DATABASE_URL:-postgresql://localhost/myapp}"
export REDIS_URL="${REDIS_URL:-redis://localhost:6379}"

# Common
export JWT_SECRET="${JWT_SECRET:-development-secret}"
export ENVIRONMENT="${ENVIRONMENT:-development}"

# Load local overrides
dotenv_if_exists .env.local

# Tools
PATH_add node_modules/.bin
PATH_add vendor/bin

# Required
require node npm docker
```

### Microservices
```bash
# .envrc
# Service discovery
export SERVICE_REGISTRY="http://localhost:8500"
export SERVICE_NAME="$(basename $PWD)"
export SERVICE_PORT="${SERVICE_PORT:-3000}"

# Message queue
export RABBITMQ_URL="${RABBITMQ_URL:-amqp://localhost}"
export KAFKA_BROKERS="${KAFKA_BROKERS:-localhost:9092}"

# Tracing
export JAEGER_ENDPOINT="http://localhost:14268"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"

# Load service-specific config
dotenv_if_exists ".env.${SERVICE_NAME}"
```

### Data Science
```bash
# .envrc
# Conda environment
eval "$(conda shell.bash hook)"
conda activate myproject

# Jupyter settings
export JUPYTER_PORT="${JUPYTER_PORT:-8888}"
export JUPYTER_TOKEN="${JUPYTER_TOKEN:-}"

# Data paths
export DATA_DIR="$PWD/data"
export MODELS_DIR="$PWD/models"
export NOTEBOOKS_DIR="$PWD/notebooks"

# GPU settings
export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"

# Python settings
export PYTHONPATH="$PWD:$PYTHONPATH"
```

## Security Best Practices

### 1. Never Commit .envrc with Secrets
```bash
# .gitignore
.envrc.local
.env.local
.env.*.local
```

### 2. Use Templates
```bash
# .envrc.example (commit this)
export API_KEY="your-api-key-here"
export DATABASE_URL="postgresql://user:pass@localhost/db"

# .envrc (don't commit)
source .envrc.local  # Actual secrets
```

### 3. Separate Environments
```bash
# .envrc
ENVIRONMENT="${ENVIRONMENT:-development}"

# Load environment-specific config
if [[ -f ".env.$ENVIRONMENT" ]]; then
    dotenv ".env.$ENVIRONMENT"
fi
```

### 4. Validate Inputs
```bash
# .envrc
# Validate environment
case "$ENVIRONMENT" in
    development|staging|production) ;;
    *) echo "Invalid ENVIRONMENT"; exit 1 ;;
esac
```

### 5. Use Encrypted Secrets
```bash
# .envrc
# Decrypt secrets (example with age)
if [[ -f secrets.age ]]; then
    eval "$(age -d secrets.age)"
fi
```

## Integration Tips

### With Git
```bash
# .gitignore
.direnv/
.envrc.local
.env.local

# Track templates
!.envrc.example
!.env.example
```

### With Docker
```bash
# .envrc
# Pass environment to Docker
docker_env() {
    docker run --env-file <(env | grep -E '^(API_|DB_|REDIS_)') "$@"
}
```

### With Make
```bash
# .envrc
# Make targets available as functions
make() {
    command make "$@"
}

build() { make build; }
test() { make test; }
deploy() { make deploy; }
```

### With CI/CD
```bash
# .envrc
# CI detection
if [[ "${CI:-}" == "true" ]]; then
    export ENVIRONMENT="ci"
    export LOG_LEVEL="debug"
fi
```

## Troubleshooting

### .envrc Not Loading
```bash
# Check if allowed
direnv status

# Re-allow after changes
direnv allow

# Check for errors
direnv reload
```

### Performance Issues
```bash
# Profile loading time
time direnv reload

# Use lazy loading
# Instead of:
eval "$(heavy-command)"

# Use:
lazy_load() {
    eval "$(heavy-command)"
}
# Call when needed
```

### Shell Integration Issues
```bash
# Verify hook is installed
echo $PROMPT_COMMAND | grep direnv  # Bash
echo $precmd_functions | grep direnv # Zsh

# Reinstall hook
eval "$(direnv hook bash)"  # or zsh
```

### Variable Not Unloading
```bash
# Force unload
direnv reload

# Check what's loaded
direnv export bash | jq
```

## Tips and Tricks

### 1. Project Switching
```bash
# Quick project setup
alias new-project='mkdir -p $1 && cd $1 && direnv-init'
```

### 2. Team Sharing
```bash
# Share safe config
git add .envrc.example
echo "Copy .envrc.example to .envrc and customize" > README
```

### 3. Debugging
```bash
# Debug mode
export DIRENV_LOG_FORMAT='[%s] %s'
direnv reload
```

### 4. Caching
```bash
# Cache expensive operations
if [[ ! -f .direnv/cache ]]; then
    expensive-operation > .direnv/cache
fi
source .direnv/cache
```

### 5. Auto-Installation
```bash
# .envrc
# Auto-install dependencies
if [[ -f package.json ]] && [[ ! -d node_modules ]]; then
    npm install
fi

if [[ -f requirements.txt ]] && [[ ! -d .venv ]]; then
    python -m venv .venv
    .venv/bin/pip install -r requirements.txt
fi
```

## Best Practices

1. **Use layouts** for language-specific setups
2. **Separate secrets** from configuration
3. **Version control** templates, not secrets
4. **Document** required variables
5. **Validate** environment on load
6. **Cache** expensive operations
7. **Use functions** for project commands
8. **Watch files** that affect environment
9. **Clean up** with `direnv prune` regularly
10. **Test** .envrc changes before committing