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

# ── 6. SDKMAN + Java + Maven ─────────────────────────────────────────────────
if [[ ! -d "$HOME/.sdkman" ]]; then
  echo "→ Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi

# Source SDKMAN so sdk command is available in this session
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

KONA_JAVA_VERSION="$(sdk list java | grep -E '^\s+.*\bkona\b' | grep '8\.' | awk '{print $NF}' | head -1)"
if [[ -z "$KONA_JAVA_VERSION" ]]; then
  echo "✗ Could not resolve Tencent Kona JDK 8 version from SDKMAN. Skipping Java install."
elif ! sdk list java | grep -q "${KONA_JAVA_VERSION}.*installed"; then
  echo "→ Installing Tencent Kona JDK 8 (${KONA_JAVA_VERSION})..."
  sdk install java "${KONA_JAVA_VERSION}"
else
  echo "→ Tencent Kona JDK 8 (${KONA_JAVA_VERSION}) already installed."
fi

if ! sdk list maven | grep -q "installed"; then
  echo "→ Installing Maven..."
  sdk install maven
fi

# ── 7. Sync config files ─────────────────────────────────────────────────────
echo "→ Syncing config files..."
bash "$DOTFILES_DIR/scripts/symlink.sh"

# ── 8. macOS system preferences ──────────────────────────────────────────────
read -p "Apply macOS system preferences? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$DOTFILES_DIR/scripts/macos-defaults.sh"
fi

echo ""
echo "✅ Setup complete! It's recommended to restart your terminal."

