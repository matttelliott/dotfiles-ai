#!/usr/bin/env bash

# Start the Neovim MCP Server
export NVIM_LISTEN_ADDRESS="/tmp/nvim.pipe"
cd "/home/matt/dotfiles-ai/tools-ai/mcp-neovim"
exec node server.js
