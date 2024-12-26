#!/bin/bash

# Install basic tools depending on operating system.
echo "[Installation]"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "... detected Linux. Using apt for installation."
    sudo apt install git
    sudo apt install cmake  # required for nvim installations
    sudo apt install npm  # required for nvim installations
    sudo apt install zsh
    sudo apt install bat  # cat with syntax
    sudo apt install zellij  # tmux in better
    sudo apt-get install fzf  # Quick file search
    sudo apt-get install ripgrep  # Quick word search in files

    # Setup gnome terminal preferences.
    cat "$PWD/terminal/linux.preferences" | dconf load /org/gnome/terminal/legacy/profiles:/

elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "... detected macOS. Using brew for installation."
    brew install zsh --quiet
    brew install cmake --quiet
    brew install npm --quiet
    brew install bat --quiet
    brew install zellij --quiet 
    brew install fzf --quiet
    brew install ripgrep --quiet

else
    echo "Unsupported operating system. Aborting."
    exit 1
fi

# ZSH setup.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ln -s "$PWD/zshrc_basic_config.sh" "$HOME/.config/zshrc_basic_config.sh"

rm "$HOME/.zshrc"
echo "# Setup zsh basic config" >> "$HOME/.zshrc"
echo "source $HOME/.config/zshrc_basic_config.sh" >> "$HOME/.zshrc"

# NeoVim config.
ln -s "$PWD/nvim" "$HOME/.config/nvim" 

# Zellij config.
ln -s "$PWD/zellij" "$HOME/.config/zellij"

