# .zshrc - Zsh configuration
# Sourced from a local ~/.zshrc written by scripts/symlink.sh

# ── Homebrew (Apple Silicon) ──────────────────────────────────────────────────
# Before Oh My Zsh, so brew's site-functions are on fpath when compinit runs
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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

# ── Aliases ───────────────────────────────────────────────────────────────────
alias vim="nvim"

# ── Environment variables ──────────────────────────────────────────────────────
export EDITOR="nvim"
export LANG="en_US.UTF-8"

# NVM and SDKMAN loaders are appended to the local ~/.zshrc by their installers

# ── PATH ──────────────────────────────────────────────────────────────────────
path=("$HOME/.local/bin" $path)
# Homebrew's rustup is keg-only; appended so an existing ~/.cargo/bin wins
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/rustup/bin" ]]; then
  path+=("$HOMEBREW_PREFIX/opt/rustup/bin")
fi

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

typeset -U path PATH
