#!/usr/bin/env bash
# bootstrap.sh - Entry point for setting up a new machine
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/CharlieStras/dotfiles/main/bootstrap.sh)"
# Or after cloning: cd dotfiles && ./bootstrap.sh

set -eo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_REPO="https://github.com/CharlieStras/dotfiles.git"

echo "⚡ Starting setup..."

# ── 1. Xcode Command Line Tools ──────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  echo "→ Installing Xcode Command Line Tools..."
  xcode-select --install
  echo " Click \"Install\" in the popup, then re-run this script after it finishes."
  exit 0
fi

# ── 2. Clone dotfiles (in case the script is run directly via curl) ──────────
if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
  echo "→ Cloning dotfiles repo..."
  git clone "$DOTFILES_REPO" "$HOME/dotfiles"
  cd "$HOME/dotfiles"
  DOTFILES_DIR="$HOME/dotfiles"
fi

# ── 3. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "→ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon path
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo "→ Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ── 4. Build NeoVim ──────────────────────────────────────────────────────────
mkdir -p "$HOME/Projects"
if [[ ! -d "$HOME/Projects/neovim" ]]; then
  git clone https://github.com/neovim/neovim "$HOME/Projects/neovim"
  cd "$HOME/Projects/neovim"
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
fi

# ── 5. Oh My Zsh ─────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "→ Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── 6. Sync config files ─────────────────────────────────────────────────────
echo "→ Syncing config files..."
bash "$DOTFILES_DIR/scripts/symlink.sh"

# ── 7. macOS system preferences ──────────────────────────────────────────────
read -p "Apply macOS system preferences? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$DOTFILES_DIR/scripts/macos-defaults.sh"
fi

echo ""
echo "✅ Setup complete! It's recommended to restart your terminal."

