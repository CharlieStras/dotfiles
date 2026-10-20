#!/usr/bin/env bash
# scripts/install-node-tools.sh - Install global Node.js tools for Neovim

set -eo pipefail

if ! command -v npm &>/dev/null; then
  echo "✗ npm is required. Install and activate Node.js with NVM first."
  exit 1
fi

NODE_TOOLS=(
  "@vtsls/language-server"
  "typescript"
  "vscode-langservers-extracted"
  "@fsouza/prettierd"
  "prettier"
)

echo "→ Installing global Node.js tools..."
npm install --global "${NODE_TOOLS[@]}"
echo "→ Global Node.js tools installed."
