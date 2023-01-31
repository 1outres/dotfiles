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
sudo pacman-mirrors --fasttrack
sudo pacman -Syy
sudo pacman -Syu
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
fisher install jethrokuan/z
fisher install 0rax/fish-bd
fisher install jethrokuan/fzf
fisher install oh-my-fish/theme-bobthefish
```
- fzf
```
sudo pacman -S fzf
```
- bat
```
sudo pacman -S bat
```
- ripgrep
```
sudo pacman -S ripgrep
```
- neovim
```
sudo pacman -S vim neovim
```
- go
```
sudo pacman -S go
set -U fish_user_paths $HOME/go/bin $fish_user_paths
```
- ghq
```
go install github.com/x-motemen/ghq@latest
```
- lazygit
```
sudo pacman -S lazygit
```
- xsel
```
sudo pacman -S xsel
```
- Java
```
sudo pacman -S jdk8-openjdk jdk11-openjdk jdk-openjdk
```
- Maven
```
sudo pacman -S maven
```
- Node.js
```
sudo yay -S nvm
fisher install jorgebucaran/fish-nvm
nvm install v18.12.0
```
- teleport
```
sudo yay -S teleport
```
- rust
```
sudo pacman -S rustup
rustup default stable
rustup component add rls rust-analysis rust-src
```
- cloudflared
```
sudo pacman -S cloudflared
```
- network
```
sudo pacman -S net-tools tcpdump iftop
```
- python
```
sudo pacman -S python python-pip
pip3 install pipx
set -U fish_user_paths $HOME/.local/bin $fish_user_paths
```

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