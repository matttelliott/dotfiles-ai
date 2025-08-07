# Python - Modern Python Development with uv and pyenv

Fast, modern Python development using **uv** as the primary package manager with pyenv for version management.

## Installation

```bash
./tools-lang/python/setup.sh
```

## What Gets Installed

### Primary Tools
- **uv** - Ultra-fast Python package manager (10-100x faster than pip)
- **pyenv** - Python version management (fallback/version control)
- **Python 3.11 & 3.12** - Latest stable versions

### Global Development Tools (in ~/.python-tools)
- **black** - Code formatter
- **ruff** - Fast linter (replaces flake8, isort, and more)
- **mypy** - Static type checker
- **pytest** - Testing framework
- **ipython** - Enhanced Python REPL
- **jupyter** - Notebook environment
- **poetry** - Dependency management
- **pre-commit** - Git hooks
- **pipx** - Install Python applications

## uv - Primary Package Manager

### Why uv?
- **10-100x faster** than pip
- **Drop-in replacement** for pip, pip-tools, pipx, poetry, pyenv, virtualenv
- **Space efficient** - Global cache for packages
- **Rust-powered** - Extremely fast and reliable

### Virtual Environment Management
```bash
# Create virtual environment
uv venv                     # Creates .venv
uv venv myenv              # Creates myenv

# Activate (or use uva alias)
source .venv/bin/activate
uva                        # Alias for above

# Deactivate
deactivate
uvd                        # Alias for above
```

### Package Management
```bash
# Install packages
uv pip install django       # Install single package
uv pip install -r requirements.txt  # From file
uv pip install -e .        # Editable install

# List packages
uv pip list                # List installed
uv pip freeze              # Show versions

# Sync packages (fast!)
uv pip sync requirements.txt  # Exact sync

# Compile requirements
uv pip compile requirements.in -o requirements.txt
```

### Running Python
```bash
# Run with automatic venv
uv run python script.py     # Auto-creates/uses venv
uv run pytest              # Run commands in venv
uv run jupyter notebook    # Launch Jupyter
```

### Project Management
```bash
# Initialize project
uv venv && uv pip install -e .

# Development dependencies
uv pip install -r requirements-dev.txt

# Lock dependencies
uv pip freeze > requirements.txt
```

## pyenv - Version Management (Fallback)

### Installing Python Versions
```bash
pyenv install 3.12         # Install Python 3.12
pyenv install 3.11.7       # Specific version
pyenv install --list       # List available
```

### Setting Python Versions
```bash
pyenv global 3.12          # Set global default
pyenv local 3.11           # Set for current directory
pyenv shell 3.10           # Set for current shell
```

### Managing Versions
```bash
pyenv versions             # List installed
pyenv which python         # Show python path
pyenv uninstall 3.10       # Remove version
```

## Common Workflows

### New Project with uv
```bash
mkdir my-project && cd my-project
uv venv                    # Create venv
uva                        # Activate (alias)
uv pip install django pytest black ruff
uv pip freeze > requirements.txt
```

### Fast Package Installation
```bash
# Traditional pip (slow)
time pip install pandas numpy scipy  # ~30 seconds

# With uv (fast!)
time uv pip install pandas numpy scipy  # ~3 seconds
```

### Development Setup
```bash
# Clone project
git clone <repo> && cd <repo>

# Set Python version (optional)
pyenv local 3.12

# Setup with uv
uv venv
source .venv/bin/activate
uv pip sync requirements.txt       # Fast exact sync
uv pip install -r requirements-dev.txt
```

### Testing Workflow
```bash
# Run tests with coverage
uv run pytest --cov=mypackage tests/

# Run specific test
uv run pytest tests/test_module.py::test_function

# With watch mode
uv run pytest-watch
```

### Jupyter Workflow
```bash
# Quick notebook
uv run jupyter notebook

# With specific packages
uv venv jupyter-env
source jupyter-env/bin/activate
uv pip install jupyter pandas matplotlib
jupyter notebook
```

## Configured Aliases

### uv aliases
- `uvv` - Create venv
- `uvi` - Install package
- `uvs` - Sync packages
- `uvl` - List packages
- `uvf` - Freeze packages
- `uvr` - Run command
- `uva` - Activate venv
- `uvd` - Deactivate venv
- `venv` - Smart venv activation

### pyenv aliases
- `pyv` - List versions
- `pyi` - Install version
- `pyg` - Set global
- `pyl` - Set local
- `pys` - Set shell
- `pyu` - Uninstall
- `pyup` - Update pyenv

## Global Tools Usage

Tools installed in ~/.python-tools are available globally:

```bash
# Format code
black myfile.py
black .                    # Format all Python files

# Lint code
ruff check .               # Check for issues
ruff check --fix .         # Auto-fix issues

# Type checking
mypy mypackage/

# Run tests
pytest
pytest -v                  # Verbose
pytest --cov              # With coverage

# Interactive Python
ipython

# Jupyter
jupyter notebook
jupyter lab
```

## Best Practices

1. **Use uv for everything** - It's much faster than pip
2. **Create venvs per project** - Don't pollute global
3. **Pin dependencies** - Use exact versions in production
4. **Use .python-version** - Specify Python version per project
5. **Sync, don't install** - Use `uv pip sync` for reproducible envs
6. **Cache packages** - uv shares packages across venvs automatically
7. **Use ruff** - Replaces multiple linters, very fast
8. **Type hints** - Use mypy for type checking
9. **Format on save** - Configure editor to use black
10. **Pre-commit hooks** - Ensure code quality

## Performance Comparison

| Operation | pip | uv | Speedup |
|-----------|-----|-----|---------|
| Create venv | 3s | 0.01s | 300x |
| Install Django | 5s | 0.2s | 25x |
| Install numpy | 10s | 0.5s | 20x |
| Sync 50 packages | 45s | 2s | 22x |

## Tips

1. **uv is a game-changer** - Seriously, it's that fast
2. **Global cache** - uv shares downloads across all venvs
3. **No more pip cache issues** - uv handles it better
4. **Works with pip** - Can still use pip if needed
5. **Replaces many tools** - One tool instead of pip, pip-tools, pipx, etc.
6. **Rust-powered** - No Python overhead for package management
7. **Great for CI/CD** - Much faster Docker builds
8. **Compatible** - Works with requirements.txt, pyproject.toml
9. **Smart resolution** - Better dependency conflict resolution
10. **Future-proof** - Active development, growing adoption