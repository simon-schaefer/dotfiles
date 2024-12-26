#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
    cat "$SCRIPT_DIR/terminal/linux.preferences" | dconf load /org/gnome/terminal/legacy/profiles:/

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
echo "[ZSH setup]"
if [ ! -d "$HOME/.oh-my-zsh/" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    rm "$HOME/.zshrc"
    echo "# Setup zsh basic config" >> "$HOME/.zshrc"
    echo "source $HOME/.config/zshrc_basic_config.sh" >> "$HOME/.zshrc"
else
    echo "... already setup. Skipping."
fi
ln -sf "$SCRIPT_DIR/zshrc_basic_config.sh" "$HOME/.config/zshrc_basic_config.sh"

# Miniconda setup.
echo "[Miniconda setup]"
CONDA_DIR="$HOME/.miniconda3"
if [ ! -f "$CONDA_DIR/bin/activate" ]; then
    mkdir -p "$CONDA_DIR"
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$CONDA_DIR/miniconda.sh"
    sh "$CONDA_DIR/miniconda.sh" -b -u -p "$CONDA_DIR"
    rm "$CONDA_DIR/miniconda.sh"
else
    echo "... already setup. Skipping."
fi

# Linking several more configs.
echo "[Linking some more configs]"
ln -sf "$SCRIPT_DIR/nvim" "$HOME/.config/nvim" 
ln -sf "$SCRIPT_DIR/zellij" "$HOME/.config/zellij"

echo "[All setup 🎢]"
