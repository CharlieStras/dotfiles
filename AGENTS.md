# Repository Guidelines

## Project Overview
Personal macOS dotfiles repository. A single `bootstrap.sh` installs Xcode
Command Line Tools, Homebrew, Oh My Zsh, runs `brew bundle` against the
`Brewfile`, sets up the stable Rust toolchain via `rustup`, builds NeoVim
from source, links files in `config/` into `$HOME` via `scripts/symlink.sh`,
installs NVM with LTS Node.js and SDKMAN with
Tencent Kona JDK 8, Maven, and sbt, and optionally applies macOS defaults via
`scripts/macos-defaults.sh`.

`symlink.sh` symlinks everything except `.zshrc` and `.gitconfig`: those are
local files that `source` / `[include]` the repo copies, so installer appends
and `git config --global` writes (work email, managed `core.hooksPath`, ...)
never land in the repo.

NVM and SDKMAN loaders are written to the local `~/.zshrc` by their own
installers, not kept in `config/.zshrc`. Keep config sync **before** the
NVM/SDKMAN steps in `bootstrap.sh`, or their loaders end up in a file that
`symlink.sh` then moves to `*.bak`.

## Project Structure
```
dotfiles/
├── bootstrap.sh            # Entry point
├── Brewfile                # Declarative brew/cask/tap list
├── config/                 # Files linked into $HOME (incl. .config/git/ignore)
├── scripts/
│   ├── symlink.sh          # Links config/ into $HOME, *.bak on conflict;
│   │                       #   writes ~/.zshrc, ~/.gitconfig that load the repo
│   └── macos-defaults.sh   # macOS `defaults write` tweaks
├── .githooks/
│   └── commit-msg          # Conventional Commits validator (enable per clone)
├── COMMIT_CONVENTION.md    # Full commit message spec
├── README.md
└── AGENTS.md               # This file
```

## Coding Style
- **Shell scripts**: `bash`, 2-space indentation, `set -e` (and `set -u` where
  safe), prefer `[[ ... ]]` over `[ ... ]`, quote all variable expansions.
- **Filenames**: kebab-case for scripts, leading-dot for dotfiles in `config/`.
- **Idempotency**: every installation/symlink step MUST be safe to re-run.
- **No secrets**: never commit API tokens, SSH keys, or machine-specific
  credentials. Put machine-local overrides outside the repo: `~/.zshrc` or
  `~/.zshrc.local` for zsh, `~/.gitconfig` itself for git. Never hardcode
  `/Users/<name>` paths in `config/`; use `$HOME`.

## Commit & Pull Request Guidelines

**All commits MUST follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).**
See [`COMMIT_CONVENTION.md`](./COMMIT_CONVENTION.md) for the full specification,
allowed types, scopes, breaking-change syntax, and examples.

Quick reference:

```
<type>(<scope>)!?: <description>

[optional body]

[optional footer(s)]
```

- Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
  `build`, `ci`, `chore`, `revert`.
- Typical scopes for this repo: `config/zsh`, `config/nvim`, `scripts`,
  `brewfile`, `bootstrap`, `git`, `readme`.
- Subject ≤ 100 chars, imperative mood, no trailing period.
- Split unrelated changes into separate commits.

### Enable the local commit-msg hook (one-time per clone)
```bash
git config core.hooksPath .githooks
```
After this, non-conforming commit messages are rejected locally.

## Security & Configuration Tips
- Review `Brewfile` diffs before merging — casks can auto-install apps with
  elevated privileges on first launch.
- `scripts/macos-defaults.sh` changes user-level system behaviour; read it
  before running.
- `scripts/symlink.sh` backs up existing non-symlink targets as `*.bak` — do
  not commit those backups (already covered by `.gitignore`).
