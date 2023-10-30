# cron's dotfiles

## Setup
```sh
cd ~
git clone git@github.com:cronree-91/dotfiles.git
bin/setup.sh
```

## Requirements
- setup
```
sudo pacman -Syyu
sudo pacman -S openssl-1.1
LANG=C xdg-user-dirs-gtk-update
sudo pacman -S git base-devel
git config --global user.email "64413934+cronree-91@users.noreply.github.com"
git config --global user.name "cronree-91"
```
- yay
```
git clone https://aur.archlinux.org/yay-bin.git yay-bin
cd yay-bin
makepkg -si --noconfirm
cd ..
rm -rf yay-bin
```
- fish
```
sudo pacman -S fish
chsh -s /usr/bin/fish
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fisher update
```
- Something
```
sudo pacman -S fzf bat ripgrep vim neovim go lazygit rustup cloudflared net-tools tcpdump iftop python python-pip
set -U fish_user_paths $HOME/go/bin $fish_user_paths
go install github.com/x-motemen/ghq@latest
sudo pacman -S jdk8-openjdk jdk11-openjdk jdk-openjdk maven
nvm install v18.12.0
rustup default stable
rustup component add rls rust-analysis rust-src
set -U fish_user_paths $HOME/.local/bin $fish_user_paths

## Japanese
```
sudo pacman -S ibus-mozc ibus-qt
```

## GUI
```
sudo yay -S ibus-mozc discord_arch_electron jetbrains-toolbox
sudo pacman -S code vivaldi guake steam
```

- Install M+ Fonts
https://github.com/coz-m/MPLUS_FONTS

- GNOME Themes
