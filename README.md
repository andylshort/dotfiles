# Andy's Dotfiles

Might try to generalise, compartmentalise, etc. Who knows?

## Install

Run `install.sh` (or `sync-dotfiles-to HOST...` for remotes). It links the configs into `$HOME` (with GNU Stow if installed, otherwise itself; existing files are kept as `*.bak`) and sets up optional extras, but never downloads binaries: install tools from the system's packages (see `required-packages.txt`). Everything works without the optional ones, so the same setup runs on any machine:

- zsh and bash have built-in prompts (no starship); zsh plugins, fzf and atuin load only if present
- Neovim < 0.12, or no Neovim, falls back to the plugin-free `~/.vimrc`

`bash/.bashrc` and `vim/.vimrc` also work as single files on their own: `scp bash/.bashrc vim/.vimrc HOST:`.

## Files You Can to Provide

These are automatically loaded by the configuration files of the associated programs to tailor the experience to you and your environment (work or personal):

- `~/.bashrc.{personal,work,local}`
- `~/.gitconfig.{personal,work}`
- `~/.config/nvim-overrides/{personal,work}.lua`
- `~/.tmux.conf.{personal,work}`
- `~/.zshrc.{personal,work,local}`

## Claude Skills

- General-purpose: `claude/.claude/skills/<name>/SKILL.md`, stowed into `~/.claude/skills`
- Work-specific: `work/claude/skills/<name>/SKILL.md`, linked in by `work/install.sh`

Both are also linked into the `claude-box` sandbox user's `~/.claude/skills`, read-only.

## TODO
- [x] Integrate `fzf` into install and workflow
- [x] Exclude certain files from certain machines/workflows (e.g. between computers, personal/work)
- [x] Integrate OSC52 support into tmux, then [vim](https://github.com/ojroques/vim-oscyank)

