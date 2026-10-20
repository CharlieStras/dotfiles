# .zshrc - Zsh configuration
# Symlinked from dotfiles/config/.zshrc to ~/.zshrc

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # Theme, change as needed

plugins=(
  aliases
  colored-man-pages
  brew
  git
  mvn
  sbt
  z
)

source $ZSH/oh-my-zsh.sh

# ── Homebrew (Apple Silicon) ──────────────────────────────────────────────────
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Aliases ───────────────────────────────────────────────────────────────────
alias vim="nvim"

# ── Environment variables ──────────────────────────────────────────────────────
export EDITOR="nvim"
export LANG="en_US.UTF-8"

# ── NVM ───────────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# ── SDKMAN ────────────────────────────────────────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# ── PATH ──────────────────────────────────────────────────────────────────────
path=("$HOME/.local/bin" $path)

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

typeset -U path PATH
