# dotfiles

Personal macOS setup — bootstraps a fresh machine with Homebrew packages, shell/Git configs, and sensible system defaults, all via a single command.

## Features

- **One-command bootstrap**: installs Xcode CLT, Homebrew, Oh My Zsh, and everything in the `Brewfile`.
- **Declarative package management** via `Brewfile` (`brew bundle`).
- **Safe linking** of config files into `$HOME` — existing regular files are backed up as `*.bak` before being replaced.
- **Machine-local settings stay local**: `~/.gitconfig` includes the repo copy instead of being a symlink, so `git config --global` never writes into the repo.
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
5. Installs **Oh My Zsh** (unattended mode).
6. Installs **SDKMAN**, then installs **Tencent Kona JDK 8** and **Maven** via `sdk`.
7. Symlinks the files in `config/` into `$HOME` and writes a local `~/.gitconfig` that includes `config/.gitconfig`, via `scripts/symlink.sh`.
8. Prompts before applying **macOS system preferences** via `scripts/macos-defaults.sh`.

## Repository Layout

```
dotfiles/
├── bootstrap.sh            # Entry point — run this first
├── Brewfile                # Declarative list of brews/casks/taps
├── config/                 # Files linked into $HOME (.zshrc, .gitconfig, .config/nvim, .config/git/ignore)
└── scripts/
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

### Add a config file

1. Drop the file into `config/` (e.g. `config/.tmux.conf`).
2. Add its name to the `FILES` array in `scripts/symlink.sh`:
   ```bash
   FILES=(
     ".zshrc"
     ".config/git/ignore"
     ".tmux.conf"
   )
   ```
3. Re-run `bash bootstrap.sh` or `bash scripts/symlink.sh`.

Missing parent directories (e.g. `~/.config/git`) are created automatically.
Existing non-symlink files at the destination are moved to `<file>.bak` before being replaced, so you won't lose local changes.

### Machine-local settings

Keep machine-specific settings and secrets out of the repo:

- **Zsh**: put them in `~/.zshrc.local`, which `.zshrc` sources last if it exists.
- **Git**: put them in `~/.gitconfig` itself (e.g. a work `user.email` or a
  managed `core.hooksPath`). That file only `[include]`s `config/.gitconfig`,
  so `git config --global` and tools that call it write there, not into the repo.
  If a regular `~/.gitconfig` already existed, it is moved to `~/.gitconfig.bak`;
  copy any settings you still need back into the new `~/.gitconfig`.

`~/.zshrc` is still a symlink, so installers that append to it modify
`config/.zshrc`. After installing a new tool, check `git diff` and move such
lines to `~/.zshrc.local`.

### Tweak macOS defaults

Edit `scripts/macos-defaults.sh` and run it directly:

```bash
bash scripts/macos-defaults.sh
```

## Re-running

The bootstrap script is safe to re-run — it will:

- Skip Xcode CLT / Homebrew / Oh My Zsh if already installed.
- Let `brew bundle` reconcile any new entries in the `Brewfile`.
- Skip the NeoVim build if `~/.local/bin/nvim` exists; run `NVIM_UPDATE=1 bash bootstrap.sh` to rebuild from `NVIM_REF`.
- Skip SDKMAN installation if `~/.sdkman` already exists; skip Java/Maven if already installed via `sdk`.
- Skip symlinks that already point to the correct target, and leave `~/.gitconfig` alone if it already includes the repo copy.

## License

MIT
