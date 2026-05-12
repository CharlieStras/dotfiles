# Commit Convention

All commits in this repository **MUST** follow the
[Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
specification.

## Format

```
<type>(<scope>)!?: <description>

[optional body]

[optional footer(s)]
```

## Allowed types

| Type       | Meaning                                              |
| ---------- | ---------------------------------------------------- |
| `feat`     | new feature (→ SemVer MINOR)                         |
| `fix`      | bug fix (→ SemVer PATCH)                             |
| `docs`     | documentation only                                   |
| `style`    | formatting, no logic change                          |
| `refactor` | code refactor, no feature/fix                        |
| `perf`     | performance improvement                              |
| `test`     | tests only                                           |
| `build`    | build system or dependency changes (e.g. `build(deps):`) |
| `ci`       | CI/CD configuration                                  |
| `chore`    | other maintenance tasks                              |
| `revert`   | revert a previous commit                             |

## Scope (optional)

Use the affected area in kebab-case. For this dotfiles repo typical scopes are:

- directory/topic names: `config/zsh`, `config/nvim`, `scripts`, `brewfile`, `bootstrap`
- tool names: `git`, `tmux`, `vim`, `homebrew`
- `readme`, `gitignore` for meta changes

Examples:

- `feat(config/zsh): add fzf key bindings`
- `fix(scripts/symlink): handle paths with spaces`
- `chore(brewfile): bump mise to latest`

## Breaking changes

Breaking changes MUST be indicated in **one** of these ways:

1. Append `!` before the colon — e.g. `feat(bootstrap)!: require macOS 14+`
2. Add an uppercase footer — `BREAKING CHANGE: <description>`
   (the synonym `BREAKING-CHANGE` is also accepted; both must be UPPERCASE)

## Rules

- Subject line ≤ 100 chars, imperative mood, no trailing period.
- Body (optional) separated from subject by one blank line; free-form paragraphs.
- Footers (optional) separated from body by one blank line; use the git trailer
  format, e.g. `Refs: #123`, `Reviewed-by: Alice`, `BREAKING CHANGE: ...`.
- If a commit covers multiple concerns, split it into multiple commits.

## Examples

```
feat(config/nvim): add lazy.nvim bootstrap

chore(brewfile): add ripgrep and fd

docs(readme): document idempotent re-run behaviour

fix(scripts/symlink): skip broken source files instead of aborting

build(deps): bump oh-my-zsh submodule to 2024.07

feat(bootstrap)!: drop Intel-mac homebrew prefix detection

BREAKING CHANGE: bootstrap.sh now assumes /opt/homebrew and will exit
on Intel machines. Use the `legacy-intel` branch for older hardware.
```

## Local validation (recommended)

A pure-shell `commit-msg` hook can be placed under `.githooks/commit-msg`
to reject non-conforming messages locally. Enable it once per clone:

```bash
git config core.hooksPath .githooks
```

Reference implementation (Conventional Commits 1.0.0 validator):

```bash
#!/usr/bin/env bash
# .githooks/commit-msg
set -e

COMMIT_MSG_FILE="$1"

first_line=$(head -n1 "$COMMIT_MSG_FILE")
case "$first_line" in
  "Merge "*|"Revert "*|"fixup! "*|"squash! "*|"amend! "*)
    exit 0
    ;;
esac

subject=$(grep -v '^#' "$COMMIT_MSG_FILE" | sed '/./,$!d' | head -n1)
[ -z "$subject" ] && exit 0

types='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'
pattern="^(${types})(\([a-z0-9._/-]+\))?!?: .+"

if ! [[ "$subject" =~ $pattern ]]; then
  echo "❌  Commit rejected: subject does not follow Conventional Commits 1.0.0"
  echo "   Subject:  $subject"
  echo "   Required: <type>(<scope>)!?: <description>"
  echo "   Types:    ${types//|/, }"
  exit 1
fi

if [ ${#subject} -gt 100 ]; then
  echo "⚠️   Commit subject is ${#subject} chars (> 100). Consider shortening."
fi

exit 0
```

Make it executable:

```bash
chmod +x .githooks/commit-msg
```
