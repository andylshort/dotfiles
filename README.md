# Andy's Dotfiles

Might try to generalise, compartmentalise, etc. Who knows?

## Install

Run `install.sh` script.

## Prerequisites

See `required-packages.txt`.

## Files You Need to Provide

- `~/.bashrc.personal` or `~/.bashrc.work`
- `~/.gitconfig.personal` or `~/.gitconfig.work`
- `.env-type`: Defines the role of the computer you're on with accepted values being `work` or `personal`

_(You can just use `.local` files instead, but `.work` or `.personal` is a more meaningful name, semantically-speaking.)_

## TODO
- [ ] Automate package installation
- [ ] Integrate `fzf` into install and workflow
- [ ] Exclude certain files from certain machines/workflows (e.g. between computers, personal/work)
- [ ] Integrate OSC52 support into tmux, then [vim](https://github.com/ojroques/vim-oscyank)

