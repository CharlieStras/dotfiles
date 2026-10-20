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
# Installs into ~/.local (on PATH via .zshrc), so no sudo is needed.
# Skipped once installed; run with NVIM_UPDATE=1 to rebuild from NVIM_REF.
NVIM_REF="nightly" # or a release tag like "v0.12.6"
NVIM_SRC="$HOME/Projects/neovim"
NVIM_PREFIX="$HOME/.local"

if [[ ! -x "$NVIM_PREFIX/bin/nvim" || "${NVIM_UPDATE:-}" == 1 ]]; then
  echo "→ Building NeoVim (${NVIM_REF})..."
  if [[ ! -d "$NVIM_SRC/.git" ]]; then
    mkdir -p "$(dirname "$NVIM_SRC")"
    git clone https://github.com/neovim/neovim "$NVIM_SRC"
  fi
  # nightly/stable are moving tags, so force-update them
  git -C "$NVIM_SRC" fetch --tags --force
  git -C "$NVIM_SRC" checkout --detach "$NVIM_REF"
  make -C "$NVIM_SRC" distclean
  make -C "$NVIM_SRC" CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$NVIM_PREFIX"
  make -C "$NVIM_SRC" install
else
  echo "→ NeoVim already installed in $NVIM_PREFIX (set NVIM_UPDATE=1 to rebuild)."
fi

# ── 5. Oh My Zsh ─────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "→ Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── 6. SDKMAN + Java + Maven + Sbt ───────────────────────────────────────────
if [[ ! -d "$HOME/.sdkman" ]]; then
  echo "→ Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi

# Source SDKMAN so sdk command is available in this session
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Return 0 if any installed version of candidate $1 matches glob $2 (default: any)
sdk_has() {
  local matches=("$SDKMAN_DIR/candidates/$1/"${2:-*})
  [[ -d "${matches[0]}" ]]
}

if sdk_has java "8.*-kona"; then
  echo "→ Tencent Kona JDK 8 already installed."
else
  KONA_JAVA_VERSION="$(sdk list java | awk -F'|' '$NF ~ /^ *8\..*-kona *$/ { gsub(/ /, "", $NF); print $NF; exit }')"
  if [[ -z "$KONA_JAVA_VERSION" ]]; then
    echo "✗ Could not resolve Tencent Kona JDK 8 version from SDKMAN. Skipping Java install."
  else
    echo "→ Installing Tencent Kona JDK 8 (${KONA_JAVA_VERSION})..."
    sdk install java "${KONA_JAVA_VERSION}"
  fi
fi

if ! sdk_has maven; then
  echo "→ Installing Maven..."
  sdk install maven
fi

if ! sdk_has sbt; then
  echo "→ Installing Sbt..."
  sdk install sbt
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

