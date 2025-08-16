# SSH Configuration with 1Password Integration

Configures SSH with 1Password SSH agent for secure key management.

## Features

- 🔐 1Password SSH agent integration
- 🔑 Secure key storage in 1Password
- 🌐 Pre-configured for GitHub, GitLab, Bitbucket
- 📝 Automatic SSH config management
- 🔒 Proper permissions setup

## Installation

```bash
./tools-cli/ssh/install
```

## What It Does

1. **Creates SSH directory** with proper permissions (700)
2. **Backs up existing config** if present
3. **Installs SSH config** with 1Password agent settings
4. **Verifies 1Password** CLI and app installation
5. **Tests SSH agent** connection

## Configuration

The installed SSH config includes:

- **Global settings**: Uses 1Password agent for all hosts
- **GitHub/GitLab/Bitbucket**: Pre-configured for Git operations
- **Custom hosts**: Template for adding your own servers

## 1Password Setup

### Prerequisites

1. **Install 1Password app**
   - macOS: `brew install --cask 1password`
   - Linux: [Download from 1Password](https://1password.com/downloads/linux/)

2. **Install 1Password CLI**
   ```bash
   ./tools-cli/1password-cli/install
   ```

### Enable SSH Agent

1. Open 1Password app
2. Go to **Settings > Developer**
3. Enable **"Use the SSH agent"**
4. Enable **"Integrate with 1Password CLI"**

## Creating SSH Keys

### In 1Password App

1. Click **"+"** to create new item
2. Choose **"SSH Key"**
3. Either:
   - **Generate new key**: Let 1Password create one
   - **Import existing**: Paste your private key

4. Set key details:
   - Name: `GitHub Personal` (or similar)
   - Add comment for identification

### Key Properties

- **Ed25519** recommended (modern, secure, fast)
- **RSA 4096** for compatibility
- Stored encrypted in 1Password vault

## Usage

### Test Connection

```bash
# Test GitHub connection
ssh -T git@github.com

# List available keys
SSH_AUTH_SOCK=~/.1password/agent.sock ssh-add -l
```

### First-Time Connection

1. When connecting to a new host, 1Password prompts
2. Select the appropriate key
3. Authorize for this connection
4. Optionally save authorization

### Git Configuration

```bash
# Verify Git uses SSH
git remote -v

# Should show SSH URLs like:
# origin  git@github.com:username/repo.git
```

## Adding Custom Hosts

Edit `~/.ssh/config`:

```ssh
Host myserver
    HostName server.example.com
    User myuser
    Port 2222
    IdentityAgent "~/.1password/agent.sock"
```

## Troubleshooting

### Agent Not Found

```bash
# Check if socket exists
ls -la ~/.1password/agent.sock

# Restart 1Password app
# Ensure SSH agent is enabled in settings
```

### Permission Denied

1. Check key is in 1Password
2. Verify key is authorized for host
3. Ensure correct user (`git` for GitHub)

### Multiple Keys

1Password will prompt which key to use
- Configure specific keys per host in SSH config
- Use `IdentityFile` with key name from 1Password

### CLI Integration

```bash
# Sign in to 1Password CLI
op signin

# List SSH keys
op item list --categories "SSH Key"
```

## Security Benefits

- **No keys on disk**: Keys stay encrypted in 1Password
- **Biometric unlock**: Use Touch ID/fingerprint
- **Audit trail**: See when keys were used
- **Easy rotation**: Update keys in one place
- **Team sharing**: Share keys via 1Password vaults

## Files

- `~/.ssh/config` - SSH client configuration
- `~/.1password/agent.sock` - Agent socket
- `~/.ssh/config.backup.*` - Config backups

## Resources

- [1Password SSH Documentation](https://developer.1password.com/docs/ssh/)
- [SSH Agent Protocol](https://developer.1password.com/docs/ssh/agent/)
- [Git SSH Setup](https://developer.1password.com/docs/ssh/git-commit-signing/)