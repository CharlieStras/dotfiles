#!/usr/bin/env bash
# scripts/symlink.sh - Symlink files and directories under config/ into $HOME

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"

# Files to symlink (paths are relative to config/)
FILES=(
  ".zshrc"
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

# ~/.gitconfig is a local file that [include]s the repo copy instead of a
# symlink, so `git config --global` writes stay on this machine
include_gitconfig() {
  local src="$1"
  local dest="$2"

  # Already includes the repo copy → skip
  if [[ -f "$dest" && ! -L "$dest" ]] &&
    git config --file "$dest" --get-all include.path | grep -Fqx "$src"; then
    echo "  Skipping .gitconfig (already included)"
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

  printf '[include]\n  path = %s\n' "$src" > "$dest"
  echo "  Included .gitconfig → $dest"
}

for file in "${FILES[@]}"; do
  src="$CONFIG_DIR/$file"
  dest="$HOME/$file"

  if [[ ! -f "$src" ]]; then
    echo "  Skipping $file (source not found)"
    continue
  fi

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

include_gitconfig "$CONFIG_DIR/.gitconfig" "$HOME/.gitconfig"

