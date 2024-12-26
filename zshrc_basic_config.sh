# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Conda setup.
launch-conda() {
    __conda_setup="$('/Users/sischaef/.miniconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/Users/sischaef/.miniconda/etc/profile.d/conda.sh" ]; then
            . "/Users/sischaef/.miniconda/etc/profile.d/conda.sh"
        else
            export PATH="/Users/sischaef/.miniconda/bin:$PATH"
        fi
    fi
    unset __conda_setup
}

