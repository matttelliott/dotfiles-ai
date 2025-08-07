# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL CONTEXT

**This dotfiles repository is meant to be installed on target machines, NOT the host development machine.** 

When the user says "let's install X" or "add X", interpret this as **adding X to the dotfiles configuration**, not installing it on the current host. All changes should be made to the installation scripts and configuration files in this repository.

## Project Overview

A dotfiles configuration repository for developer tools across macOS, Debian, and Linux Mint platforms.

## Key Commands

### Testing Installation
```bash
# Main installation (run on target machine)
./install.sh

# Interactive post-install wizard
./post-install.sh
```

### Adding New Tools

When adding a new tool:
1. Add installation commands to `scripts/setup-macos.sh` and/or `scripts/setup-debian.sh`
2. Create a directory for configuration files if needed
3. Update `install.sh` to handle symlinking
4. Add to `post-install.sh` if interactive setup required

## Architecture

### Core Scripts
- `install.sh` - Main installer, non-interactive, handles dependencies and symlinks
- `post-install.sh` - Interactive wizard for API keys, SSH setup, etc.
- `scripts/setup-macos.sh` - macOS package installations (Homebrew)
- `scripts/setup-debian.sh` - Debian/Ubuntu/Mint installations (apt)
- `scripts/symlink.sh` - Creates configuration symlinks

### Directory Structure
Each tool gets its own directory with:
- Configuration files
- `setup.sh` script if complex installation needed
- `README.md` for tool-specific documentation

### Platform Detection
Scripts auto-detect OS using `$OSTYPE` and `/etc/os-release`

## Future Development

- Test environments using VMs/Docker containers are planned but TBD
- All development should assume eventual testing in isolated environments