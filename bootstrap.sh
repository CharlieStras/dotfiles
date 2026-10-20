#!/usr/bin/env bash
# bootstrap.sh - Entry point for setting up a new machine
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/CharlieStras/dotfiles/main/bootstrap.sh)"
# Or after cloning: cd dotfiles && bash bootstrap.sh

set -eo pipefail

DOTFILES_REPO="https://github.com/CharlieStras/dotfiles.git"

# BASH_SOURCE is empty under `bash -c "$(curl ...)"`; fall back to ~/dotfiles
if [[ -n "${BASH_SOURCE[0]:-}" && -f "$(dirname "${BASH_SOURCE[0]}")/Brewfile" ]]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  DOTFILES_DIR="$HOME/dotfiles"
fi

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
  if [[ -e "$DOTFILES_DIR" ]]; then
    echo "✗ $DOTFILES_DIR exists but is not this dotfiles repo. Move it away and re-run."
    exit 1
  fi
  echo "→ Cloning dotfiles repo..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ── 3. Homebrew ───────────────────────────────────────────────────────────────
# Put an existing brew on PATH first: /opt/homebrew is not on the default PATH,
# so `command -v brew` alone would re-run the installer on Apple Silicon
load_brew() {
  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      return 0
    fi
  done
  return 1
}

if ! load_brew; then
  echo "→ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew || { echo "✗ Homebrew installed but brew was not found."; exit 1; }
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
# --keep-zshrc: ~/.zshrc is written by symlink.sh in the next step
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "→ Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# ── 6. Sync config files ─────────────────────────────────────────────────────
# Before NVM/SDKMAN, so their installers append to the final local ~/.zshrc
echo "→ Syncing config files..."
bash "$DOTFILES_DIR/scripts/symlink.sh"

# ── 7. NVM + Node.js ─────────────────────────────────────────────────────────
NVM_VERSION="v0.40.4"
export NVM_DIR="$HOME/.nvm"

CURRENT_NVM_VERSION=""
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
  CURRENT_NVM_VERSION="v$(nvm --version)"
fi

# The installer appends its loader to ~/.zshrc unless one is already there
if [[ "$CURRENT_NVM_VERSION" != "$NVM_VERSION" ]]; then
  echo "→ Installing NVM ${NVM_VERSION}..."
  PROFILE="$HOME/.zshrc" NVM_DIR="$NVM_DIR" bash -c \
    "$(curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh")"
  source "$NVM_DIR/nvm.sh"
fi

echo "→ Installing the latest LTS Node.js..."
nvm install --lts
nvm alias default "lts/*"
nvm use default
echo "→ Node.js $(node --version) installed via NVM."

echo "→ Installing Node.js tools..."
bash "$DOTFILES_DIR/scripts/install-node-tools.sh"

# ── 8. SDKMAN + Java + Maven + Sbt ───────────────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"

# On first install, the installer appends its loader to ~/.zshrc and ~/.bash_profile
if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  echo "→ Installing SDKMAN..."
  curl -fsSL "https://get.sdkman.io" | bash
fi

# Source SDKMAN so sdk command is available in this session
source "$SDKMAN_DIR/bin/sdkman-init.sh"
# Set after sourcing init, which loads etc/config (sdkman_auto_answer=false)
sdkman_auto_answer=true

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

# Loaders live in the local ~/.zshrc, not in config/.zshrc; warn if one is missing
for loader in "/nvm.sh:NVM" "sdkman-init.sh:SDKMAN"; do
  if ! grep -Fq "${loader%%:*}" "$HOME/.zshrc"; then
    echo "⚠ ~/.zshrc does not load ${loader##*:}; add its loader snippet manually."
  fi
done

# ── 9. macOS system preferences ──────────────────────────────────────────────
read -p "Apply macOS system preferences? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$DOTFILES_DIR/scripts/macos-defaults.sh"
fi

echo ""
echo "✅ Setup complete! It's recommended to restart your terminal."

