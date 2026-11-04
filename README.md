# Andy's Dotfiles

Might try to generalise, compartmentalise, etc. Who knows?

## Install

Run `install.sh` script.

## Prerequisites

See `required-packages.txt`.

## Machines Without the Full Setup

`bash/.bashrc` and `vim/.vimrc` are single, plugin-free files that work on their own, using whatever the machine has. Copy just those: `scp bash/.bashrc vim/.vimrc HOST:`.

On hosts where you use `sudo`, run `ghostty-terminfo HOST` once so root can use Ghostty's terminfo.

## Files You Can to Provide

These are automatically loaded by the configuration files of the associated programs to tailor the experience to you and your environment (work or personal):

- `~/.bashrc.{personal,work,local}`
- `~/.gitconfig.{personal,work}`
- `~/.config/nvim-overrides/{personal,work}.lua`
- `~/.tmux.conf.{personal,work}`
- `~/.zshrc.{personal,work}`

_(You can just use `.local` files instead, but `.work` or `.personal` is a more meaningful name, semantically-speaking.)_

## Claude Skills

- General-purpose: `claude/.claude/skills/<name>/SKILL.md`, stowed into `~/.claude/skills`
- Work-specific: `work/claude/skills/<name>/SKILL.md`, linked in by `work/install.sh`

Both are also linked into the `claude-box` sandbox user's `~/.claude/skills`, read-only.

## TODO
- [ ] Automate package installation
- [x] Integrate `fzf` into install and workflow
- [x] Exclude certain files from certain machines/workflows (e.g. between computers, personal/work)
- [x] Integrate OSC52 support into tmux, then [vim](https://github.com/ojroques/vim-oscyank)

