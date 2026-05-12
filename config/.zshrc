# .zshrc - Zsh 配置
# 由 dotfiles/config/.zshrc 软链到 ~/.zshrc

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # 主题，按需修改

plugins=(
  git
  z
  zsh-autosuggestions      # 需要额外安装: brew install zsh-autosuggestions
  zsh-syntax-highlighting  # 需要额外安装: brew install zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ── Homebrew (Apple Silicon) ──────────────────────────────────────────────────
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── 别名 ──────────────────────────────────────────────────────────────────────
alias ll="ls -lah"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias vim="nvim"

# ── 环境变量 ───────────────────────────────────────────────────────────────────
export EDITOR="nvim"
export LANG="en_US.UTF-8"
