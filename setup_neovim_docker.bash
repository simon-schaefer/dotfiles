#!/bin/bash
# Inspired by https://github.com/thomaspttn/nvim-docker/blob/main/install.sh

INSTALL_DIR="/root/"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Update XDG_CONFIG_HOME
export XDG_CONFIG_HOME="${INSTALL_DIR}.config"
export XDG_DATA_HOME="${INSTALL_DIR}.local/share"
export XDG_STATE_HOME="${INSTALL_DIR}.local/state"
export TERM="xterm-256color"
export DISPLAY=":0"

cd "$INSTALL_DIR"
if [ ! -d "$INSTALL_DIR/.config/" ]; then
    mkdir -p "$INSTALL_DIR/.config"
fi
ln -sf "$SCRIPT_DIR/nvim" "${INSTALL_DIR}.config/nvim"
sudo apt-get update

# CLANG
sudo apt-get install -y clang
# sudo ln -s -f .clangd ~/.clangd

# NPM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$INSTALL_DIR.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install 16.15.1

# NEOVIM
wget https://github.com/neovim/neovim/releases/download/v0.10.3/nvim-linux64.tar.gz
tar xzvf nvim-linux64.tar.gz
sudo ln -s "${INSTALL_DIR}nvim-linux64/bin/nvim" /usr/local/bin/nvim
