# Docker - Container Platform

Complete Docker setup with container management tools.

## Installation

```bash
./tools-cli/docker/setup.sh
```

## What Gets Installed

### Core
- **Docker Engine/Desktop** - Container runtime
- **Docker Compose** - Multi-container orchestration
- **Colima** - Lightweight Docker Desktop alternative (macOS)

### Management Tools
- **lazydocker** - Terminal UI for Docker
- **dive** - Docker image layer explorer
- **ctop** - Real-time container metrics

## Basic Docker Commands

### Container Management
```bash
docker run image                # Run container
docker ps                        # List running containers
docker ps -a                     # List all containers
docker stop container            # Stop container
docker start container           # Start container
docker restart container         # Restart container
docker rm container              # Remove container
docker logs container            # View logs
docker exec -it container bash   # Shell into container
```

### Image Management
```bash
docker images                    # List images
docker pull image                # Download image
docker build -t name .           # Build image
docker push image                # Push to registry
docker rmi image                 # Remove image
docker image prune               # Remove unused images
```

### Volume Management
```bash
docker volume ls                 # List volumes
docker volume create name        # Create volume
docker volume rm name            # Remove volume
docker volume prune              # Remove unused volumes
```

### Network Management
```bash
docker network ls                # List networks
docker network create name       # Create network
docker network rm name           # Remove network
docker network inspect name      # Inspect network
```

## Docker Compose

### Basic Commands
```bash
docker compose up                # Start services
docker compose up -d             # Start in background
docker compose down              # Stop and remove
docker compose ps                # List services
docker compose logs              # View logs
docker compose logs -f           # Follow logs
docker compose build             # Build images
docker compose restart           # Restart services
```

### Service Management
```bash
docker compose exec service bash # Shell into service
docker compose stop service      # Stop specific service
docker compose start service     # Start specific service
docker compose scale service=3   # Scale service
```

## Configured Aliases

### Docker
- `d` - docker
- `dps` - docker ps
- `dpsa` - docker ps -a
- `di` - docker images
- `dex` - docker exec -it
- `dl` - docker logs
- `dlf` - docker logs -f
- `dstop` - docker stop
- `drm` - docker rm
- `drmi` - docker rmi
- `dprune` - docker system prune -a

### Docker Compose
- `dc` - docker compose
- `dcu` - docker compose up
- `dcud` - docker compose up -d
- `dcd` - docker compose down
- `dcl` - docker compose logs
- `dclf` - docker compose logs -f
- `dcps` - docker compose ps
- `dcr` - docker compose restart
- `dcb` - docker compose build

### Functions
- `dsh <container>` - Shell into container
- `dclean` - Remove all containers/images/volumes
- `dbuild <name>` - Build with no cache

## Dockerfile Best Practices

### Multi-stage Build
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]
```

### Security
```dockerfile
# Run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

# Use specific versions
FROM node:18.19.0-alpine

# Minimize layers
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
  && rm -rf /var/lib/apt/lists/*
```

## Docker Compose Examples

### Full Stack Application
```yaml
version: '3.9'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - API_URL=http://backend:5000
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=pass
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

## Using lazydocker

```bash
lazydocker                       # Launch UI
```

Key bindings:
- `↑/↓` - Navigate
- `Enter` - View logs
- `d` - Remove container/image
- `r` - Restart container
- `s` - Stop container
- `x` - Menu
- `q` - Quit

## Using dive

```bash
dive image:tag                   # Analyze image
```

Features:
- View layer contents
- See what changed in each layer
- Identify wasted space
- Calculate efficiency score

## Using ctop

```bash
ctop                            # Launch metrics view
```

Key bindings:
- `a` - Toggle all containers
- `f` - Filter
- `h` - Help
- `s` - Sort
- `r` - Reverse sort
- `q` - Quit

## Colima (macOS)

### Basic Usage
```bash
colima start                    # Start VM
colima start --cpu 4 --memory 8 # With resources
colima stop                     # Stop VM
colima status                   # Check status
colima delete                   # Remove VM
```

### Profiles
```bash
colima start --profile dev      # Development profile
colima start --profile test     # Testing profile
colima list                     # List profiles
```

## Container Best Practices

1. **Use official images** - Start with trusted bases
2. **Minimize layers** - Combine RUN commands
3. **Order matters** - Put changing content last
4. **Use .dockerignore** - Exclude unnecessary files
5. **Multi-stage builds** - Reduce final image size
6. **Non-root user** - Security best practice
7. **Specific tags** - Avoid :latest in production
8. **Health checks** - Add HEALTHCHECK instruction
9. **Signal handling** - Use init system or dumb-init
10. **Resource limits** - Set memory/CPU limits

## Troubleshooting

### Common Issues
```bash
# Permission denied
sudo usermod -aG docker $USER    # Add to docker group
newgrp docker                    # Activate group

# Disk space
docker system df                 # Check usage
docker system prune -a          # Clean everything

# Network conflicts
docker network prune            # Remove unused networks

# Container won't stop
docker kill container           # Force stop

# Can't remove image
docker ps -a | grep image       # Find using containers
docker rm container             # Remove containers first
```

### Debugging
```bash
docker logs container            # Check logs
docker inspect container         # Full details
docker stats                    # Resource usage
docker events                   # Real-time events
docker diff container           # File changes
```

## Registry Operations

### Docker Hub
```bash
docker login                    # Login to Docker Hub
docker tag image user/image:tag # Tag for push
docker push user/image:tag      # Push to registry
docker pull user/image:tag      # Pull from registry
```

### Private Registry
```bash
docker login registry.example.com
docker tag image registry.example.com/image:tag
docker push registry.example.com/image:tag
```

## Tips

1. **Use volumes for data** - Don't store in containers
2. **One process per container** - Unix philosophy
3. **Log to stdout/stderr** - For docker logs
4. **Use environment variables** - For configuration
5. **Keep images small** - Alpine Linux, multi-stage
6. **Version everything** - Images, compose files
7. **Test locally** - Before pushing
8. **Monitor resources** - Set appropriate limits
9. **Backup volumes** - Important data
10. **Stay updated** - Security patches