#!/usr/bin/env bash
# scripts/symlink.sh - Symlink files under config/ into $HOME

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"

# Files to symlink (paths are relative to config/)
FILES=(
  ".zshrc"
  ".gitconfig"
)

for file in "${FILES[@]}"; do
  src="$CONFIG_DIR/$file"
  dest="$HOME/$file"

  if [[ ! -f "$src" ]]; then
    echo "  Skipping $file (source not found)"
    continue
  fi

  # Already a symlink pointing to the correct target → skip
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "  Skipping $file (already linked)"
    continue
  fi

  # Regular file (not a symlink) → back it up
  if [[ -f "$dest" && ! -L "$dest" ]]; then
    echo "  Backing up $dest → ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  ln -sf "$src" "$dest"
  echo "  Linked $file → $dest"
done

