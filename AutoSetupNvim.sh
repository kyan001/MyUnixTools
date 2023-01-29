#!/usr/bin/env bash
sudo apt update
sudo apt install -y neovim ttf-mscorefonts-installer fontconfig
curl -sLf https://spacevim.org/install.sh | bash
if [ ! -d ~/".config" ]; then
    mkdir ~/".config"
fi
ln -s ~/.nvim ~/.config/nvim
