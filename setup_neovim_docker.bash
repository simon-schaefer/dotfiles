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
if [ ! -d "$HOME/.config/" ]; then
    mkdir -p "$HOME/.config"
fi
ln -sf "$SCRIPT_DIR/nvim" "${INSTALL_DIR}.config/nvim"  # root user
ln -sf "$SCRIPT_DIR/nvim" "${HOME}/.config/nvim"  # non-root user
sudo apt-get update

# Install some more dependencies
sudo apt-get install -y curl git ripgrep
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
sudo apt install -y nodejs

# NEOVIM
wget https://github.com/neovim/neovim-releases/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
tar xzvf nvim-linux-x86_64.tar.gz
sudo ln -s "${INSTALL_DIR}nvim-linux-x86_64/bin/nvim" /usr/local/bin/nvim
