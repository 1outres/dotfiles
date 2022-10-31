#!/usr/bin/env bash
set -ue

git clone git@github.com:cronree-91/dotfiles.git ~/dotfiles
cd ~/dotfiles

if [ -e /etc/arch-release ]; then
bin/arch.sh
done

bin/deploy.sh