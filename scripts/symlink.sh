#!/usr/bin/env bash
# scripts/symlink.sh - Symlink files and directories under config/ into $HOME

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"

# Files to symlink (paths are relative to config/)
FILES=(
  ".config/git/ignore"
)

# Directories to symlink (paths are relative to config/)
DIRS=(
  ".config/nvim"
)

link_target() {
  local src="$1"
  local dest="$2"
  local label="$3"

  # Already a symlink pointing to the correct target → skip
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "  Skipping $label (already linked)"
    return
  fi

  # Existing non-symlink → back it up
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "  Backing up $dest → ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  # Remove stale symlink
  if [[ -L "$dest" ]]; then
    rm "$dest"
  fi

  ln -sf "$src" "$dest"
  echo "  Linked $label → $dest"
}

# Write a local $dest that loads the repo copy instead of symlinking it, so
# tools that append to it (installers, `git config --global`) stay on this machine
include_target() {
  local src="$1"
  local dest="$2"
  local label="$3"
  local content="$4"

  # Already loads the repo copy → skip
  if [[ -f "$dest" && ! -L "$dest" ]] && grep -Fq "$src" "$dest"; then
    echo "  Skipping $label (already included)"
    return
  fi

  # Existing non-symlink → back it up
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "  Backing up $dest → ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  # Remove previous symlink
  if [[ -L "$dest" ]]; then
    rm "$dest"
  fi

  printf '%s\n' "$content" > "$dest"
  echo "  Included $label → $dest"
}

for file in "${FILES[@]}"; do
  src="$CONFIG_DIR/$file"
  dest="$HOME/$file"

  if [[ ! -f "$src" ]]; then
    echo "  Skipping $file (source not found)"
    continue
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "$dest")"
  link_target "$src" "$dest" "$file"
done

for dir in "${DIRS[@]}"; do
  src="$CONFIG_DIR/$dir"
  dest="$HOME/$dir"

  if [[ ! -d "$src" ]]; then
    echo "  Skipping $dir (source not found)"
    continue
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "$dest")"
  link_target "$src" "$dest" "$dir"
done

include_target "$CONFIG_DIR/.zshrc" "$HOME/.zshrc" ".zshrc" \
  "$(printf '# Local zshrc; machine-specific lines can go below\nsource "%s"' "$CONFIG_DIR/.zshrc")"
include_target "$CONFIG_DIR/.gitconfig" "$HOME/.gitconfig" ".gitconfig" \
  "$(printf '[include]\n  path = %s' "$CONFIG_DIR/.gitconfig")"

