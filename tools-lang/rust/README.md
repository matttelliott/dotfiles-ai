# Rust - Systems Programming Language

Fast, reliable, and memory-safe systems programming with Rust.

## Installation

```bash
./tools-lang/rust/setup.sh
```

## What Gets Installed

### Core Tools
- **rustup** - Rust toolchain installer and version manager
- **rustc** - Rust compiler
- **cargo** - Rust package manager and build tool

### Components
- **rustfmt** - Code formatter
- **clippy** - Linter with helpful suggestions
- **rust-analyzer** - Language server for IDEs
- **rust-src** - Source code for IDE support

### Cargo Extensions
- **cargo-edit** - Add/remove dependencies from CLI
- **cargo-watch** - Auto-rebuild on file changes
- **cargo-audit** - Security vulnerability scanner
- **cargo-outdated** - Check for outdated dependencies
- **cargo-tree** - Visualize dependency tree
- **cargo-make** - Task runner
- **sccache** - Shared compilation cache
- **bacon** - Background compiler

## Basic Usage

### Creating Projects
```bash
cargo new my_project        # New binary project
cargo new --lib my_lib      # New library project
cargo init                  # Initialize in existing directory
```

### Building & Running
```bash
cargo build                 # Debug build
cargo build --release       # Optimized release build
cargo run                   # Build and run
cargo run --release         # Build and run optimized
cargo run -- arg1 arg2      # Pass arguments
```

### Testing
```bash
cargo test                  # Run all tests
cargo test test_name        # Run specific test
cargo test -- --nocapture   # Show println! output
cargo test -- --test-threads=1  # Run tests serially
```

### Code Quality
```bash
cargo fmt                   # Format code
cargo fmt --check          # Check formatting
cargo clippy               # Run linter
cargo clippy --fix         # Auto-fix linting issues
cargo check                # Quick type check (no build)
```

### Documentation
```bash
cargo doc                   # Build documentation
cargo doc --open           # Build and open in browser
cargo doc --no-deps        # Skip dependencies
```

## Dependency Management

### Adding Dependencies
```bash
# With cargo-edit (installed)
cargo add serde            # Add dependency
cargo add serde --features derive  # With features
cargo add tokio --features full
cargo add --dev proptest   # Dev dependency

# Manual (edit Cargo.toml)
[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
```

### Managing Dependencies
```bash
cargo update               # Update dependencies
cargo update -p serde      # Update specific package
cargo tree                 # Show dependency tree
cargo outdated            # Check for updates
cargo audit               # Security audit
```

## Common Workflows

### Development Workflow
```bash
cargo watch -x run         # Auto-run on changes
cargo watch -x test        # Auto-test on changes
cargo watch -x check       # Auto-check on changes
cargo watch -x "run -- --arg"  # With arguments
```

### Release Workflow
```bash
cargo build --release      # Build optimized
cargo test --release       # Test optimized
strip target/release/binary  # Strip symbols
cargo install --path .     # Install locally
```

### Benchmarking
```bash
cargo bench                # Run benchmarks
cargo bench -- --save-baseline before  # Save baseline
cargo bench -- --baseline before      # Compare to baseline
```

### Cross-compilation
```bash
# Install target
rustup target add x86_64-unknown-linux-musl
rustup target add wasm32-unknown-unknown

# Build for target
cargo build --target x86_64-unknown-linux-musl
cargo build --target wasm32-unknown-unknown
```

## Configured Aliases

- `cb` - cargo build
- `cbr` - cargo build --release
- `cr` - cargo run
- `crr` - cargo run --release
- `ct` - cargo test
- `cc` - cargo check
- `cf` - cargo fmt
- `ccl` - cargo clippy
- `cu` - cargo update
- `ci` - cargo install
- `cn` - cargo new
- `cd` - cargo doc
- `cdo` - cargo doc --open
- `cw` - cargo watch
- `cwr` - cargo watch -x run
- `cwt` - cargo watch -x test

## Project Structure

```
my_project/
├── Cargo.toml          # Project manifest
├── Cargo.lock          # Dependency lock file
├── src/
│   ├── main.rs        # Entry point (binary)
│   ├── lib.rs         # Entry point (library)
│   └── bin/           # Additional binaries
├── tests/             # Integration tests
├── benches/           # Benchmarks
├── examples/          # Example programs
└── target/            # Build artifacts
```

## Common Patterns

### Error Handling
```rust
use anyhow::Result;  // Or thiserror for libraries

fn main() -> Result<()> {
    let data = std::fs::read_to_string("file.txt")?;
    Ok(())
}
```

### Async Programming
```rust
use tokio;

#[tokio::main]
async fn main() {
    let result = fetch_data().await;
}
```

### Command Line Apps
```rust
use clap::Parser;

#[derive(Parser)]
struct Args {
    #[arg(short, long)]
    name: String,
}
```

### Serialization
```rust
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct Config {
    name: String,
    value: i32,
}
```

## Performance Tips

1. **Use release builds** - `cargo build --release` for 10-100x speedup
2. **Enable LTO** - Link-time optimization in Cargo.toml
3. **Use sccache** - Configured for faster rebuilds
4. **Profile first** - Use `cargo flamegraph` or `perf`
5. **Avoid allocations** - Use references when possible
6. **Use const/static** - For compile-time computation
7. **Parallelize** - Use rayon for data parallelism
8. **SIMD** - Use packed_simd for vectorization
9. **Unsafe carefully** - Only when measured improvement
10. **Benchmark** - Use criterion for micro-benchmarks

## Common Crates

### Essential
- `serde` - Serialization/deserialization
- `tokio` - Async runtime
- `anyhow` - Error handling for apps
- `thiserror` - Error handling for libraries
- `clap` - Command line parsing
- `tracing` - Structured logging

### Web Development
- `axum` / `actix-web` - Web frameworks
- `reqwest` - HTTP client
- `sqlx` - Async SQL

### Testing
- `proptest` - Property testing
- `criterion` - Benchmarking
- `pretty_assertions` - Better test assertions

## IDE Setup

### VS Code
Install "rust-analyzer" extension - it will use the installed rust-analyzer component.

### Neovim
Configure your LSP to use rust-analyzer:
```lua
require('lspconfig').rust_analyzer.setup{}
```

### Other Editors
Most modern editors support rust-analyzer LSP.

## Tips

1. **Read the book** - https://doc.rust-lang.org/book/
2. **Use clippy** - It teaches idiomatic Rust
3. **Understand ownership** - Core to Rust's safety
4. **Embrace the borrow checker** - It's your friend
5. **Start with Clone** - Optimize later
6. **Use Result/Option** - Avoid unwrap() in production
7. **Write tests** - Rust makes it easy
8. **Document with examples** - They're tested!
9. **Use cargo-watch** - Instant feedback
10. **Join the community** - Very helpful and welcoming