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

# Added by CodeBuddy CN - shell command
export PATH="/Users/charliestras/.codebuddy/bin:$PATH"
