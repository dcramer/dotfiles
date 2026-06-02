# Agent Instructions

## Commands

| Task | Command |
|------|---------|
| Install dotfiles | `make install` |
| Install macOS lock app | `make install-macos-lock-screen` |
| Check Git signing setup | `make check-git-signing` |
| Verify Git signing | `make verify-git-signing` |

## External References

| Need | File |
|------|------|
| Setup overview | `README.rst` |
| Git and signing notes | `docs/github.md` |

## Key Conventions

- Commit directly to `main` in this repository unless the user explicitly requests a branch.
- Keep installer behavior in `Makefile`; prefer `make install` for end-to-end setup.
- Keep user-facing helper scripts in `bin/` so `install-bin` links them into `~/.bin`.

## Commit Attribution

AI commits MUST include:

```text
Co-Authored-By: Codex <codex@openai.com>
```
