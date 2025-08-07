# Go - The Go Programming Language

Simple, reliable, and efficient software development with Go.

## Installation

```bash
./tools-lang/go/setup.sh
```

## What Gets Installed

### Core
- **Go** - Latest stable version
- **GOPATH** - Workspace at ~/go

### Development Tools
- **gopls** - Official language server
- **dlv** - Delve debugger
- **staticcheck** - Advanced static analysis
- **golangci-lint** - Fast linters aggregator
- **goimports** - Automatic import management
- **air** - Live reload for development
- **task** - Task runner
- **goreleaser** - Release automation
- **gosec** - Security checker
- **swag** - Swagger generator

## Project Management

### Creating Projects
```bash
# Create new module
go mod init github.com/user/project
gonew myproject           # Custom function

# Create with specific Go version
go mod init github.com/user/project
go mod edit -go=1.21
```

### Dependencies
```bash
# Add dependencies
go get github.com/gin-gonic/gin
go get github.com/stretchr/testify
go get -u ./...           # Update all

# Tidy dependencies
go mod tidy               # Add missing, remove unused

# Download dependencies
go mod download           # Download to cache

# Vendor dependencies
go mod vendor             # Copy to vendor/
```

## Development Workflow

### Building
```bash
go build                  # Build package
go build -o app           # Specify output
go build ./...            # Build all packages
go build -v               # Verbose output
go build -race            # Race detector
```

### Running
```bash
go run main.go            # Run file
go run .                  # Run package
go run main.go arg1 arg2  # With arguments
air                       # Hot reload (if installed)
```

### Testing
```bash
go test                   # Test package
go test ./...             # Test all
go test -v                # Verbose
go test -cover            # Coverage
go test -race             # Race detector
go test -bench .          # Benchmarks
go test -timeout 30s      # With timeout

# Coverage report
go test -coverprofile=coverage.out
go tool cover -html=coverage.out
```

### Formatting & Linting
```bash
go fmt ./...              # Format code
goimports -w .            # Fix imports
go vet ./...              # Basic linting
staticcheck ./...         # Advanced analysis
golangci-lint run         # Comprehensive linting
gosec ./...               # Security check
```

## Configured Aliases

### Build & Run
- `gob` - go build
- `gobv` - go build -v
- `goba` - go build ./...
- `gor` - go run
- `gorv` - go run -v
- `gorm` - go run main.go

### Testing
- `got` - go test
- `gotv` - go test -v
- `gota` - go test ./...
- `gotc` - go test -cover
- `gotb` - go test -bench .

### Module Management
- `gom` - go mod
- `gomi` - go mod init
- `gomt` - go mod tidy
- `gomd` - go mod download
- `gomv` - go mod vendor

### Other
- `gof` - go fmt
- `gofa` - go fmt ./...
- `gog` - go get
- `gogu` - go get -u
- `goi` - go install
- `gov` - go vet
- `gol` - golangci-lint run
- `gow` - go work

### Functions
- `gocover` - Test with coverage report
- `gonew` - Create new module

## Project Structure

### Standard Layout
```
myproject/
├── cmd/                  # Main applications
│   └── app/
│       └── main.go
├── internal/             # Private code
│   ├── config/
│   ├── database/
│   └── server/
├── pkg/                  # Public libraries
│   └── utils/
├── api/                  # API definitions
├── web/                  # Web assets
├── scripts/              # Build/install scripts
├── test/                 # Additional tests
├── docs/                 # Documentation
├── go.mod               # Module definition
├── go.sum               # Dependency checksums
├── Makefile             # Build automation
└── README.md
```

## Common Patterns

### Error Handling
```go
if err != nil {
    return fmt.Errorf("failed to process: %w", err)
}
```

### HTTP Server
```go
package main

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    r.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"message": "hello"})
    })
    r.Run(":8080")
}
```

### Database
```go
import (
    "database/sql"
    _ "github.com/lib/pq"
)

db, err := sql.Open("postgres", "postgres://...")
defer db.Close()
```

### Configuration
```go
import "github.com/spf13/viper"

viper.SetConfigFile(".env")
viper.AutomaticEnv()
viper.ReadInConfig()
```

### CLI Application
```go
import "github.com/spf13/cobra"

var rootCmd = &cobra.Command{
    Use:   "app",
    Short: "Application description",
    Run: func(cmd *cobra.Command, args []string) {
        // Main logic
    },
}
```

## Workspaces (Go 1.18+)

### Multi-module Development
```bash
# Initialize workspace
go work init ./module1 ./module2

# Add module to workspace
go work use ./module3

# Sync workspace
go work sync
```

## Performance Tips

1. **Use pointers** for large structs
2. **Preallocate slices** when size is known
3. **Use sync.Pool** for temporary objects
4. **Profile first** - pprof is your friend
5. **Avoid interface{}** when possible
6. **Buffer channels** appropriately
7. **Use strings.Builder** for concatenation
8. **Benchmark** critical paths
9. **Enable race detector** in tests
10. **Use context** for cancellation

## Common Libraries

### Web Frameworks
- `gin` - Fast HTTP framework
- `fiber` - Express-inspired framework
- `echo` - High performance framework
- `chi` - Lightweight router

### Database
- `gorm` - ORM library
- `sqlx` - Extensions for database/sql
- `ent` - Entity framework
- `migrate` - Database migrations

### Utilities
- `viper` - Configuration management
- `cobra` - CLI applications
- `zap` - Structured logging
- `testify` - Testing toolkit

### Networking
- `grpc` - RPC framework
- `websocket` - WebSocket support
- `nats` - Messaging system

## Debugging

### With Delve
```bash
# Debug binary
dlv debug main.go

# Debug test
dlv test

# Attach to process
dlv attach <pid>

# Common commands in dlv
(dlv) break main.main
(dlv) continue
(dlv) next
(dlv) step
(dlv) print variable
(dlv) list
```

## Cross-compilation

```bash
# Linux
GOOS=linux GOARCH=amd64 go build

# macOS
GOOS=darwin GOARCH=amd64 go build
GOOS=darwin GOARCH=arm64 go build

# Windows
GOOS=windows GOARCH=amd64 go build

# WebAssembly
GOOS=js GOARCH=wasm go build
```

## Best Practices

1. **Handle errors explicitly** - Don't ignore them
2. **Use meaningful names** - Be descriptive
3. **Keep it simple** - Avoid over-engineering
4. **Write tests** - Table-driven tests are great
5. **Document exports** - Godoc is important
6. **Use go fmt** - Consistent formatting
7. **Avoid globals** - Pass dependencies
8. **Use interfaces** - For flexibility
9. **Embed resources** - Use go:embed
10. **Version your modules** - Semantic versioning

## Tips

1. **Start simple** - Go rewards simplicity
2. **Learn the stdlib** - It's comprehensive
3. **Understand pointers** - Different from C
4. **Master goroutines** - Concurrency is key
5. **Use channels wisely** - Don't overuse
6. **Profile before optimizing** - Measure first
7. **Read effective go** - Official best practices
8. **Use the playground** - play.golang.org
9. **Join the community** - Very helpful
10. **Have fun** - Go is enjoyable!