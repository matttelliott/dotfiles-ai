# 1Password Integration for Dotfiles

This directory contains scripts and configurations for setting up 1Password CLI and SSH agent integration across multiple platforms.

## Supported Platforms

- macOS (via Homebrew or direct download)
- Debian/Ubuntu Linux
- Linux Mint

## Features

- **1Password CLI Installation**: Automated installation for each platform
- **SSH Agent Integration**: Configure SSH to use 1Password as the SSH agent
- **Shell Integration**: Add convenient aliases and functions to your shell
- **Cross-Platform Support**: Works seamlessly across macOS and Linux

## Installation

Run the setup script from the dotfiles root directory:

```bash
./1password/setup.sh
```

Or directly:

```bash
bash 1password/setup.sh
```

## What Gets Configured

### SSH Configuration
The script adds the 1Password SSH agent to your `~/.ssh/config`:

- **macOS**: Uses `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- **Linux**: Uses `~/.1password/agent.sock`

### Shell Integration
Adds the following to your shell configuration (.zshrc or .bashrc):

- **Environment Variables**:
  - `OP_BIOMETRIC_UNLOCK_ENABLED=true` - Enable biometric unlock
  - `SSH_AUTH_SOCK` - Points to 1Password agent socket

- **Aliases**:
  - `ops` - Sign in to 1Password CLI
  - `opget` - Get an item from 1Password
  - `oplist` - List items in 1Password
  - `opssh` - SSH-related 1Password operations

- **Functions**:
  - `op-get-password <item-name>` - Retrieve a password from 1Password
  - `op-add-ssh-key <key-name>` - Generate and store an SSH key in 1Password
  - `op-list-ssh-keys` - List all SSH keys stored in 1Password

## Usage

### Initial Setup
1. After installation, sign in to 1Password CLI:
   ```bash
   op signin
   ```

2. Generate a new SSH key and store it in 1Password:
   ```bash
   op-add-ssh-key github
   ```

3. List your SSH keys:
   ```bash
   op-list-ssh-keys
   ```

### Daily Usage
Once configured, 1Password will automatically handle SSH authentication:

```bash
# SSH will use 1Password for authentication
ssh git@github.com

# Clone repositories using SSH
git clone git@github.com:username/repo.git
```

### Managing SSH Keys
```bash
# Generate a new SSH key for a specific service
op-add-ssh-key gitlab

# View all SSH keys
op item list --categories "SSH Key"

# Get details of a specific SSH key
op item get "github"
```

## Troubleshooting

### 1Password CLI Not Found
If `op` command is not found after installation:
- **macOS**: Ensure `/opt/homebrew/bin` or `/usr/local/bin` is in your PATH
- **Linux**: Ensure `/usr/bin` is in your PATH

### SSH Agent Not Working
1. Verify the socket exists:
   - **macOS**: `ls -la ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock`
   - **Linux**: `ls -la ~/.1password/agent.sock`

2. Check SSH config:
   ```bash
   cat ~/.ssh/config
   ```

3. Ensure 1Password desktop app is running and unlocked

### Permission Denied
If you get permission denied when using SSH:
1. Ensure the SSH key is added to 1Password
2. The key is authorized for the service you're connecting to
3. 1Password is unlocked

## Security Notes

- SSH keys are stored encrypted in your 1Password vault
- Biometric unlock provides convenient yet secure access
- Keys are never written to disk in plaintext
- Each key access requires 1Password to be unlocked

## Manual Installation

If you prefer to set up components manually:

### 1Password CLI
- **macOS**: `brew install --cask 1password/tap/1password-cli`
- **Linux**: Follow instructions at https://developer.1password.com/docs/cli/get-started/

### SSH Agent Configuration
Add to `~/.ssh/config`:
```
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

## References

- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [1Password SSH Agent Documentation](https://developer.1password.com/docs/ssh)
- [1Password Developer Portal](https://developer.1password.com)