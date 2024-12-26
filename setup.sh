#!/bin/bash

# Install basic tools depending on operating system.
echo "[Installation]"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "... detected Linux. Using apt for installation."
    sudo apt install git
    sudo apt install cmake
    sudo apt install zsh
    sudo apt install bat  # cat with syntax
    sudo apt install zellij  # tmux in better
    sudo apt-get install ripgrep  # NVIM telescope dependency

elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "... detected macOS. Using brew for installation."
    brew install zsh --quiet
    brew install cmake --quiet
    brew install bat --quiet
    brew install zellij --quiet 
    brew install ripgrep --quiet

else
    echo "Unsupported operating system. Aborting."
    exit 1
fi

# NeoVim config.
ln -s "$PWD/nvim" "$HOME/.config/nvim" 

# Zellij config.
ln -s "$PWD/zellij" "$HOME/.config/zellij"

