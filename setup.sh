#!/bin/bash

# Install basic tools depending on operating system.
echo "[Installation]"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "... detected Linux. Using apt for installation."
    sudo apt install git
    sudo apt install cmake
    sudo apt install zsh
    sudo apt install bat  # cat with syntax
    sudo apt-get install ripgrep  # NVIM telescope dependency

elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "... detected macOS. Using brew for installation."
    brew install zsh --quiet
    brew install cmake --quiet
    brew install bat --quiet
    brew install ripgrep --quiet

else
    echo "Unsupported operating system. Aborting."
    exit 1
fi

# NeoVim config.
ln -s "$PWD/nvim" "$HOME/.config/nvim" 

# Copy zshrc file to the home directory.
echo "[ZSH Setup]"
if [ -e "$HOME/.zshrc" ]; then
    echo "... .zshrc already exists in the home directory."
else
    ln -s "$PWD/.zshrc" "$HOME/.zshrc"
    echo "... .zshrc symlink created successfully."
fi
