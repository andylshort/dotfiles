# Global Instructions

Loaded in every project (stowed to `~/.claude/CLAUDE.md`, and linked into the `claude-box` sandbox user's `~/.claude` by `work/install.sh`). Work-specific rules live in `work/claude/CLAUDE.md`.

## Links in Output

Write references in replies as Markdown links so they're clickable in the terminal (Ghostty, via tmux):

- Commit hashes: link to the commit in the repo's web UI, found from `git remote get-url origin`, e.g. `https://github.com/<owner>/<repo>/commit/<hash>`. If the commit isn't pushed yet, leave it as plain `code`.
- File paths: `[path:line](file:///absolute/path)`, keeping `path:line` as the link text.
- URLs: as Markdown links or bare, never inside backticks.
