# cron's dotfiles

## Setup
```sh
cd ~
git clone git@github.com:cronree-91/dotfiles.git
bin/setup.sh
```

## Requirements
- fish
```
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fisher install jethrokuan/z
fisher install 0rax/fish-bd
fisher add jethrokuan/fzf
```
- fzf
```
sudo pacman -S fzf
```
- neovim
```
sudo pacman -S neovim
```