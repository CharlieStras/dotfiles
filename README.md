# dotfiles

Personal macOS setup — bootstraps a fresh machine with Homebrew packages, shell/Git configs, and sensible system defaults, all via a single command.

## Features

- **One-command bootstrap**: installs Xcode CLT, Homebrew, Oh My Zsh, and everything in the `Brewfile`.
- **Declarative package management** via `Brewfile` (`brew bundle`).
- **Safe symlinking** of config files into `$HOME` — existing regular files are backed up as `*.bak` before being replaced.
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
./bootstrap.sh
```

After the script finishes, restart your terminal for all changes to take effect.

## What `bootstrap.sh` Does

1. Installs **Xcode Command Line Tools** (if missing) — on first run the script exits after the GUI installer launches; re-run it once that finishes.
2. **Clones** this repo into `~/dotfiles` when executed via `curl`.
3. Installs **Homebrew** and runs `brew bundle` against the `Brewfile`.
4. Builds and installs **NeoVim** from source into `~/Projects/neovim`.
5. Installs **Oh My Zsh** (unattended mode).
6. Installs **SDKMAN**, then installs **Tencent Kona JDK 8** and **Maven** via `sdk`.
7. Symlinks the files in `config/` into `$HOME` via `scripts/symlink.sh`.
8. Prompts before applying **macOS system preferences** via `scripts/macos-defaults.sh`.

## Repository Layout

```
dotfiles/
├── bootstrap.sh            # Entry point — run this first
├── Brewfile                # Declarative list of brews/casks/taps
├── config/                 # Files symlinked into $HOME (e.g. .zshrc, .gitconfig)
└── scripts/
    ├── symlink.sh          # Links files from config/ into $HOME, backing up existing ones
    └── macos-defaults.sh   # macOS `defaults write` tweaks (Dock, etc.)
```

## Customization

### Add a package

Edit `Brewfile` and re-run `brew bundle` (or `./bootstrap.sh`):

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
     ".gitconfig"
     ".tmux.conf"
   )
   ```
3. Re-run `./bootstrap.sh` or `bash scripts/symlink.sh`.

Existing non-symlink files at the destination are moved to `<file>.bak` before being replaced, so you won't lose local changes.

### Tweak macOS defaults

Edit `scripts/macos-defaults.sh` and run it directly:

```bash
bash scripts/macos-defaults.sh
```

## Re-running

The bootstrap script is safe to re-run — it will:

- Skip Xcode CLT / Homebrew / Oh My Zsh if already installed.
- Let `brew bundle` reconcile any new entries in the `Brewfile`.
- Skip the NeoVim build if `~/Projects/neovim` already exists.
- Skip SDKMAN installation if `~/.sdkman` already exists; skip Java/Maven if already installed via `sdk`.
- Skip symlinks that already point to the correct target.

## License

MIT
