#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Install basic tools depending on operating system.
echo "[Installation]"
if command -v apt &> /dev/null; then    
    echo "... detected apt. You are most likely running Linux Ubuntu."
    sudo apt install git -y 
    sudo apt install cmake -y  # required for nvim installations
    sudo apt install npm -y  # required for nvim installations
    sudo apt install clang -y  # required for nvim installations
    sudo apt install zsh  -y 
    sudo apt install bat  -y  # cat with syntax
    sudo apt install tmux  -y  # tmux in better
    sudo apt-get install fzf  -y  # Quick file search
    sudo apt-get install ripgrep -y  # Quick word search in files
    sudo apt-get install ffmpeg -y  # Video processing
    sudo apt-get install feh -y  # Better image visualization.

    # Setup gnome terminal preferences.
    cat "$SCRIPT_DIR/terminal/linux.preferences" | dconf load /org/gnome/terminal/legacy/profiles:/

elif command -v dnf &> /dev/null; then
    echo "... detected dnf. You are most likely running Linux Fedora."
    sudo yum install git -y
    sudo yum install cmake -y 
    sudo yum install npm -y  
    sudo yum install zsh -y
    sudo yum install bat -y 
    sudo dnf install tmux -y 
    sudo yum install fzf -y 
    sudo yum install ripgrep -y 
    sudo dnf install ffmpeg -y
    sudo yum install feh -y

    # Setup gnome terminal preferences.
    cat "$SCRIPT_DIR/terminal/linux.preferences" | dconf load /org/gnome/terminal/legacy/profiles:/

elif command -v brew &> /dev/null; then
    echo "... detected brew. You are most likely running MacOS."
    brew install zsh --quiet
    brew install cmake --quiet
    brew install npm --quiet
    brew install clang --quiet
    brew install bat --quiet
    brew install tmux --quiet 
    brew install fzf --quiet
    brew install ripgrep --quiet
    brew install ffmpeg --quiet
    brew install feh --quiet

else
    echo "Unsupported package management system. Aborting"
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
CONDA_DIR="$HOME/.miniconda"
if [ ! -f "$CONDA_DIR/bin/activate" ]; then
    mkdir -p "$CONDA_DIR"
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$CONDA_DIR/miniconda.sh"
    sh "$CONDA_DIR/miniconda.sh" -b -u -p "$CONDA_DIR"
    rm "$CONDA_DIR/miniconda.sh"
else
    echo "... already setup. Skipping."
fi

# tmux setup.
echo "[tmux setup]"
if [ ! -d "$HOME/.tmux/plugins/tpm/" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
ln -sf "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# Linking several more configs.
echo "[Linking some more configs]"
if [ ! -d "$HOME/.config/" ]; then
    mkdir -p "$HOME/.config"
fi
ln -sf "$SCRIPT_DIR/nvim" "$HOME/.config/nvim" 

echo "[All setup 🎢]"
