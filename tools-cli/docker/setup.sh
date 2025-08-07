#!/bin/bash
# Docker and container tools setup

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    PLATFORM="macos"
elif [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then
        PLATFORM="debian"
    else
        PLATFORM="linux"
    fi
else
    log_warning "Unknown platform: $OS"
    exit 1
fi

install_docker_macos() {
    log_info "Installing Docker for macOS..."
    
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        log_info "Docker is already installed: $(docker --version)"
        return 0
    fi
    
    # Install Docker Desktop via Homebrew
    if command -v brew &> /dev/null; then
        log_info "Installing Docker Desktop via Homebrew..."
        brew install --cask docker
        log_success "Docker Desktop installed"
        log_info "Please start Docker Desktop from Applications"
    else
        log_error "Homebrew not found. Please install Docker Desktop manually from https://www.docker.com/products/docker-desktop"
        exit 1
    fi
}

install_docker_linux() {
    log_info "Installing Docker for Linux..."
    
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        log_info "Docker is already installed: $(docker --version)"
        return 0
    fi
    
    # Remove old versions
    sudo apt remove docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Install prerequisites
    sudo apt update
    sudo apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    log_success "Docker installed"
    log_warning "Please log out and back in for group changes to take effect"
}

install_docker() {
    case "$PLATFORM" in
        macos)
            install_docker_macos
            ;;
        debian)
            install_docker_linux
            ;;
        *)
            log_error "Unsupported platform for Docker installation"
            exit 1
            ;;
    esac
}

install_docker_compose() {
    log_info "Checking Docker Compose..."
    
    # Docker Desktop includes Compose, but Linux might need it separately
    if docker compose version &> /dev/null; then
        log_info "Docker Compose is available: $(docker compose version)"
    elif command -v docker-compose &> /dev/null; then
        log_info "Docker Compose standalone is available: $(docker-compose --version)"
    else
        log_info "Installing Docker Compose standalone..."
        
        # Get latest version
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        
        if [[ -z "$COMPOSE_VERSION" ]]; then
            COMPOSE_VERSION="2.23.3"  # Fallback version
        fi
        
        # Download and install
        sudo curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        log_success "Docker Compose installed"
    fi
}

install_colima() {
    log_info "Installing Colima (Docker Desktop alternative for macOS)..."
    
    if [[ "$PLATFORM" != "macos" ]]; then
        log_info "Colima is only for macOS, skipping..."
        return 0
    fi
    
    if command -v colima &> /dev/null; then
        log_info "Colima is already installed: $(colima version)"
        return 0
    fi
    
    if command -v brew &> /dev/null; then
        brew install colima
        log_success "Colima installed"
        log_info "Start Colima with: colima start"
    else
        log_warning "Homebrew not found, skipping Colima installation"
    fi
}

install_container_tools() {
    log_info "Installing additional container tools..."
    
    # lazydocker - Terminal UI for Docker
    if ! command -v lazydocker &> /dev/null; then
        log_info "Installing lazydocker..."
        if [[ "$PLATFORM" == "macos" ]] && command -v brew &> /dev/null; then
            brew install lazydocker
        else
            # Install via script
            curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        fi
    else
        log_info "lazydocker already installed"
    fi
    
    # dive - Docker image explorer
    if ! command -v dive &> /dev/null; then
        log_info "Installing dive..."
        if [[ "$PLATFORM" == "macos" ]] && command -v brew &> /dev/null; then
            brew install dive
        else
            # Install via script
            DIVE_VERSION=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
            wget "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
            sudo apt install "./dive_${DIVE_VERSION}_linux_amd64.deb"
            rm "dive_${DIVE_VERSION}_linux_amd64.deb"
        fi
    else
        log_info "dive already installed"
    fi
    
    # ctop - Container metrics
    if ! command -v ctop &> /dev/null; then
        log_info "Installing ctop..."
        if [[ "$PLATFORM" == "macos" ]] && command -v brew &> /dev/null; then
            brew install ctop
        else
            sudo wget https://github.com/bcicen/ctop/releases/latest/download/ctop-linux-amd64 -O /usr/local/bin/ctop
            sudo chmod +x /usr/local/bin/ctop
        fi
    else
        log_info "ctop already installed"
    fi
    
    log_success "Container tools installed"
}

setup_docker_aliases() {
    log_info "Setting up Docker aliases..."
    
    local docker_aliases='
# Docker aliases
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias dex="docker exec -it"
alias dl="docker logs"
alias dlf="docker logs -f"
alias dstop="docker stop"
alias dstart="docker start"
alias drm="docker rm"
alias drmi="docker rmi"
alias dprune="docker system prune -a"
alias dvol="docker volume ls"
alias dnet="docker network ls"

# Docker Compose aliases
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs"
alias dclf="docker compose logs -f"
alias dcps="docker compose ps"
alias dcr="docker compose restart"
alias dcb="docker compose build"
alias dce="docker compose exec"

# Docker functions
dsh() {
    # Shell into container
    docker exec -it "$1" /bin/bash 2>/dev/null || docker exec -it "$1" /bin/sh
}

dclean() {
    # Clean up everything
    docker stop $(docker ps -aq) 2>/dev/null || true
    docker rm $(docker ps -aq) 2>/dev/null || true
    docker rmi $(docker images -q) 2>/dev/null || true
    docker volume prune -f
    docker network prune -f
}

dbuild() {
    # Build with cache options
    docker build --no-cache -t "$1" .
}

# Colima aliases (macOS)
if command -v colima &> /dev/null; then
    alias cols="colima start"
    alias colst="colima stop"
    alias colstat="colima status"
    alias colr="colima restart"
fi

# Container tools
alias lzd="lazydocker"
'
    
    # Add to shell RC files
    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "# Docker aliases" "$rc_file"; then
                echo "$docker_aliases" >> "$rc_file"
                log_success "Added Docker aliases to $(basename $rc_file)"
            else
                log_info "Docker aliases already configured in $(basename $rc_file)"
            fi
        fi
    done
}

create_docker_templates() {
    log_info "Creating Docker templates..."
    
    # Create template directory
    mkdir -p "$HOME/.config/docker/templates"
    
    # Create Dockerfile template
    cat > "$HOME/.config/docker/templates/Dockerfile" << 'EOF'
# Multi-stage build example
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application
COPY . .

# Build application
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /app .

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "server.js"]
EOF
    
    # Create docker-compose.yml template
    cat > "$HOME/.config/docker/templates/docker-compose.yml" << 'EOF'
version: "3.9"

services:
  app:
    build: .
    container_name: myapp
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    depends_on:
      - db
      - redis
    volumes:
      - ./data:/app/data
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    container_name: myapp-db
    restart: unless-stopped
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=myapp
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    restart: unless-stopped
    volumes:
      - redis-data:/data
    networks:
      - app-network

volumes:
  postgres-data:
  redis-data:

networks:
  app-network:
    driver: bridge
EOF
    
    # Create .dockerignore template
    cat > "$HOME/.config/docker/templates/.dockerignore" << 'EOF'
# Dependencies
node_modules/
npm-debug.log
yarn-error.log

# Build outputs
dist/
build/
*.log

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
.env.*.local

# Git
.git/
.gitignore

# Documentation
README.md
docs/

# Tests
test/
tests/
*.test.js
*.spec.js
coverage/

# CI/CD
.github/
.gitlab-ci.yml
.travis.yml
EOF
    
    log_success "Docker templates created"
}

# Main installation
main() {
    log_info "Setting up Docker and container tools..."
    
    install_docker
    install_docker_compose
    install_colima
    install_container_tools
    setup_docker_aliases
    create_docker_templates
    
    log_success "Docker setup complete!"
    echo
    if command -v docker &> /dev/null; then
        docker --version || true
    fi
    echo
    echo "Installed tools:"
    echo "  • Docker Engine/Desktop"
    echo "  • Docker Compose"
    echo "  • Colima (macOS alternative)"
    echo "  • lazydocker - Terminal UI"
    echo "  • dive - Image explorer"
    echo "  • ctop - Container metrics"
    echo
    echo "Quick start:"
    echo "  docker run hello-world    - Test installation"
    echo "  lazydocker               - Terminal UI"
    echo "  dive <image>             - Explore image layers"
    echo "  ctop                     - Container metrics"
    echo
    if [[ "$PLATFORM" == "macos" ]]; then
        echo "macOS: Start Docker Desktop or use 'colima start'"
    else
        echo "Linux: Log out and back in for docker group to take effect"
    fi
}

main "$@"