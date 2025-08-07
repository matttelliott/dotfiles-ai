# Node.js - JavaScript Runtime

Node.js installation and management via nvm (Node Version Manager).

## Installation

```bash
./tools-lang/node/setup.sh
```

## What Gets Installed

### Core Tools
- **nvm** - Node Version Manager for installing/switching Node versions
- **Node.js** - Latest LTS version
- **npm** - Node Package Manager

### Global Packages
- **yarn** - Alternative package manager
- **pnpm** - Fast, disk space efficient package manager
- **typescript** - TypeScript compiler
- **ts-node** - Execute TypeScript directly
- **nodemon** - Auto-restart on file changes
- **prettier** - Code formatter
- **eslint** - JavaScript linter
- **npm-check-updates** - Update dependencies
- **serve** - Static file server
- **concurrently** - Run multiple commands
- **cross-env** - Cross-platform env variables

## nvm Usage

### Installing Node versions
```bash
nvm install 18              # Install Node.js v18
nvm install --lts           # Install latest LTS
nvm install node            # Install latest version
nvm install 18.17.0         # Install specific version
```

### Switching versions
```bash
nvm use 18                  # Use Node.js v18
nvm use --lts               # Use latest LTS
nvm use node                # Use latest version
nvm use system              # Use system Node.js
```

### Listing versions
```bash
nvm list                    # List installed versions
nvm list-remote             # List available versions
nvm list-remote --lts       # List LTS versions
nvm current                 # Show current version
```

### Managing defaults
```bash
nvm alias default 18        # Set default to v18
nvm alias default node      # Set default to latest
nvm unalias default         # Remove default alias
```

### Version-specific commands
```bash
nvm run 18 app.js           # Run with specific version
nvm exec 18 npm test        # Execute command with version
nvm which 18                # Show path to version
```

## Project Configuration

### Using .nvmrc
```bash
# Create .nvmrc in project root
echo "18.17.0" > .nvmrc
echo "lts/*" > .nvmrc       # Use latest LTS

# Use version from .nvmrc
nvm use                     # Reads .nvmrc
nvm install                 # Install from .nvmrc
```

### Auto-switching (configured)
The setup automatically configures your shell to switch Node versions when entering directories with `.nvmrc` files.

## npm Usage

### Package management
```bash
npm init                    # Initialize package.json
npm install                 # Install dependencies
npm install express         # Install package
npm install -D eslint       # Install dev dependency
npm install -g typescript   # Install globally
npm uninstall express       # Remove package
npm update                  # Update packages
npm outdated                # Check for updates
```

### Running scripts
```bash
npm run dev                 # Run dev script
npm test                    # Run test script
npm start                   # Run start script
npm run build               # Run build script
```

### Publishing
```bash
npm login                   # Login to npm
npm publish                 # Publish package
npm version patch           # Bump patch version
npm version minor           # Bump minor version
npm version major           # Bump major version
```

## yarn Usage

### Basic commands
```bash
yarn                        # Install dependencies
yarn add express            # Add package
yarn add -D eslint          # Add dev dependency
yarn global add typescript  # Add globally
yarn remove express         # Remove package
yarn upgrade                # Upgrade packages
```

### Workspaces
```bash
yarn workspaces run build   # Run in all workspaces
yarn workspace app add react # Add to specific workspace
```

## pnpm Usage

### Basic commands
```bash
pnpm install                # Install dependencies
pnpm add express            # Add package
pnpm add -D eslint          # Add dev dependency
pnpm add -g typescript      # Add globally
pnpm remove express         # Remove package
pnpm update                 # Update packages
```

### Advantages
- Faster installations
- Less disk space usage
- Strict dependency resolution

## TypeScript Setup

### Initialize TypeScript
```bash
# In project directory
npx tsc --init              # Create tsconfig.json
npm install -D typescript @types/node
```

### Running TypeScript
```bash
# Compile
npx tsc                     # Compile all .ts files
npx tsc file.ts             # Compile specific file

# Execute directly
npx ts-node script.ts       # Run TypeScript file
npx ts-node -e "console.log('Hi')"  # Run inline
```

## Common Workflows

### New project setup
```bash
mkdir my-project && cd my-project
echo "18" > .nvmrc          # Set Node version
nvm use                     # Switch to version
npm init -y                 # Initialize package.json
npm install express         # Add dependencies
```

### Clone and setup
```bash
git clone <repo>
cd <repo>
nvm install                 # Install from .nvmrc
npm install                 # Install dependencies
npm run dev                 # Start development
```

### Update dependencies
```bash
npx npm-check-updates       # Check what can be updated
npx npm-check-updates -u    # Update package.json
npm install                 # Install updates
```

## Configured Aliases

- `nvmi` - nvm install
- `nvmu` - nvm use
- `nvml` - nvm list
- `nvmr` - nvm run
- `nvme` - nvm exec
- `nvmw` - nvm which
- `nvmlts` - Install and use latest LTS

## Environment Variables

```bash
# Useful nvm environment variables
echo $NVM_DIR               # nvm installation directory
echo $NVM_BIN               # Current version bin directory
echo $NVM_INC               # Current version include directory

# Node/npm variables
echo $NODE_PATH             # Node module path
echo $npm_config_prefix     # npm global prefix
```

## Tips

1. **Use .nvmrc** - Always specify Node version in projects
2. **LTS for production** - Use LTS versions for stability
3. **Lock dependencies** - Use package-lock.json or yarn.lock
4. **Audit regularly** - Run `npm audit` to check vulnerabilities
5. **Clean cache** - `npm cache clean --force` if issues
6. **Use npx** - Run packages without installing globally
7. **Workspaces** - Use for monorepos (npm/yarn/pnpm)
8. **Scripts** - Define common tasks in package.json
9. **Environment** - Use .env files with dotenv package
10. **Version constraints** - Understand ^, ~, and exact versions