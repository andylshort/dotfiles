# Andy's Dotfiles

Might try to generalise, compartmentalise, etc. Who knows?

## Install

Run `install.sh` script.

## Prerequisites

See `required-packages.txt`.

## Files You Can to Provide

These are automatically loaded by the configuration files of the associated programs to tailor the experience to you and your environment (work or personal):

- `~/.bashrc.{personal,work}`
- `~/.gitconfig.{personal,work}`
- `~/.tmux.conf.{personal,work}`
- `~/.zshrc.{personal,work}`

_(You can just use `.local` files instead, but `.work` or `.personal` is a more meaningful name, semantically-speaking.)_

## TODO
- [ ] Automate package installation
- [x] Integrate `fzf` into install and workflow
- [x] Exclude certain files from certain machines/workflows (e.g. between computers, personal/work)
- [x] Integrate OSC52 support into tmux, then [vim](https://github.com/ojroques/vim-oscyank)

