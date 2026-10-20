# dotfiles

Personal macOS setup — bootstraps a fresh machine with Homebrew packages, shell/Git configs, and sensible system defaults, all via a single command.

## Features

- **One-command bootstrap**: installs Xcode CLT, Homebrew, Oh My Zsh, and everything in the `Brewfile`.
- **Declarative package management** via `Brewfile` (`brew bundle`).
- **Node.js via NVM**: installs a pinned NVM release and selects the latest LTS Node.js by default.
- **Safe linking** of config files into `$HOME` — existing regular files are backed up as `*.bak` before being replaced.
- **Machine-local settings stay local**: `~/.zshrc` and `~/.gitconfig` are local files that load the repo copies instead of symlinks, so installers and `git config --global` never write into the repo.
- **Opt-in macOS defaults** (Dock auto-hide, etc.) applied only after confirmation.
- **Idempotent**: re-running the script skips anything already installed or linked.

## Requirements

- macOS (Apple Silicon supported — Homebrew is sourced from `/opt/homebrew`)
- Internet access
- Admin password (for Xcode CLT / Homebrew)

## Quick Start

Run directly via `curl` on a fresh machine:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/CharlieStras/dotfiles/main/bootstrap.sh)"
```

Or clone first and run locally:

```bash
git clone https://github.com/CharlieStras/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh
```

After the script finishes, restart your terminal for all changes to take effect.

Re-running the `curl` command is safe: it reuses an existing `~/dotfiles`
checkout instead of cloning again (it does not `git pull`; update it yourself).

The repo is cloned over HTTPS because a fresh machine has no SSH key yet. Once
your key is added to GitHub, switch the remote so you can push:

```bash
git -C ~/dotfiles remote set-url origin git@github.com:CharlieStras/dotfiles.git
```

## What `bootstrap.sh` Does

1. Installs **Xcode Command Line Tools** (if missing) — on first run the script exits after the GUI installer launches; re-run it once that finishes.
2. **Clones** this repo into `~/dotfiles` when executed via `curl` (skipped if it is already there).
3. Installs **Homebrew** and runs `brew bundle` against the `Brewfile`.
4. Builds **NeoVim** (`nightly` by default, see `NVIM_REF`) from source in `~/Projects/neovim` and installs it into `~/.local` — no `sudo` needed.
5. Installs **Oh My Zsh** (unattended mode, keeping any existing `~/.zshrc`).
6. Symlinks the files in `config/` into `$HOME` and writes local `~/.zshrc` / `~/.gitconfig` files that load `config/.zshrc` / `config/.gitconfig`, via `scripts/symlink.sh`.
7. Installs **NVM**, then installs the latest LTS **Node.js**, sets it as the default, and installs global Node.js editor tools.
8. Installs **SDKMAN**, then installs **Tencent Kona JDK 8**, **Maven**, and **sbt** via `sdk`.

   The NVM and SDKMAN installers append their loaders to the local `~/.zshrc`,
   which is why config sync runs before them. The script warns if either
   loader is missing afterwards.
9. Prompts before applying **macOS system preferences** via `scripts/macos-defaults.sh`.

## Repository Layout

```
dotfiles/
├── bootstrap.sh            # Entry point — run this first
├── Brewfile                # Declarative list of brews/casks/taps
├── config/                 # Files linked into $HOME (.zshrc, .gitconfig, .config/nvim, .config/git/ignore)
└── scripts/
    ├── install-node-tools.sh # Installs global TypeScript/Neovim tooling via npm
    ├── symlink.sh          # Links files from config/ into $HOME, backing up existing ones
    └── macos-defaults.sh   # macOS `defaults write` tweaks (Dock, etc.)
```

## Customization

### Add a package

Edit `Brewfile` and re-run `brew bundle` (or `bash bootstrap.sh`):

```ruby
brew "ripgrep"
cask "visual-studio-code"
```

Node.js and NVM are intentionally not listed in the `Brewfile`. NVM is pinned
in `bootstrap.sh`, while `nvm install --lts` installs the latest LTS Node.js
and assigns the `lts/*` release line to the `default` alias.

The bootstrap also runs `scripts/install-node-tools.sh`, which installs the
latest versions of `@vtsls/language-server`, `typescript`,
`vscode-langservers-extracted`, `@fsouza/prettierd`, and `prettier` globally.
Projects should still pin TypeScript, ESLint, and Prettier in their own
`devDependencies` so project-specific versions and configuration take priority.

### Add a config file

1. Drop the file into `config/` (e.g. `config/.tmux.conf`).
2. Add its name to the `FILES` array in `scripts/symlink.sh`:
   ```bash
   FILES=(
     ".config/git/ignore"
     ".tmux.conf"
   )
   ```
3. Re-run `bash bootstrap.sh` or `bash scripts/symlink.sh`.

Missing parent directories (e.g. `~/.config/git`) are created automatically.
Existing non-symlink files at the destination are moved to `<file>.bak` before being replaced, so you won't lose local changes.

### Machine-local settings

Keep machine-specific settings and secrets out of the repo:

- **Zsh**: put them in `~/.zshrc` below the `source` line, or in
  `~/.zshrc.local`, which `config/.zshrc` sources last if it exists. Installers
  that append to `~/.zshrc` now write to that local file, not into the repo.
  This includes the NVM and SDKMAN loaders: `config/.zshrc` does not load
  them, so if `~/.zshrc` is ever regenerated, re-add them (the bootstrap
  prints a warning when they are missing):

  ```zsh
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  ```
- **Git**: put them in `~/.gitconfig` itself (e.g. a work `user.email` or a
  managed `core.hooksPath`). That file only `[include]`s `config/.gitconfig`,
  so `git config --global` and tools that call it write there, not into the repo.

If a regular `~/.zshrc` or `~/.gitconfig` already existed, it is moved to
`*.bak`; copy any settings you still need back into the new local file.

### Tweak macOS defaults

Edit `scripts/macos-defaults.sh` and run it directly:

```bash
bash scripts/macos-defaults.sh
```

## Re-running

The bootstrap script is safe to re-run — it will:

- Skip Xcode CLT / Homebrew / Oh My Zsh if already installed.
- Let `brew bundle` reconcile any new entries in the `Brewfile`. If some entries fail (e.g. a cask download), the remaining steps still run and the script reminds you at the end to check with `brew bundle check --verbose`.
- Skip the NeoVim build if `~/.local/bin/nvim` exists; run `NVIM_UPDATE=1 bash bootstrap.sh` to rebuild from `NVIM_REF`.
- Keep NVM at the pinned version, update the `default` alias to the latest LTS Node.js, and update global Node.js editor tools.
- Skip SDKMAN installation if it is already installed; skip Java/Maven/sbt if already installed via `sdk`. `sdk install` runs without prompts, so a newly installed version becomes the default.
- Skip symlinks that already point to the correct target, and leave `~/.zshrc` / `~/.gitconfig` alone if they already load the repo copies.

## License

MIT
