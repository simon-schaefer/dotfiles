# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Conda setup.
launch-conda() {
    __conda_setup="$("$HOME/.miniconda/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/.miniconda/etc/profile.d/conda.sh" ]; then
            . "$HOME/.miniconda/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/.miniconda/bin:$PATH"
        fi
    fi
    unset __conda_setup
}

