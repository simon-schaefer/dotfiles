# oh-my-zsh setup.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="Eastwood"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# User configuration.
export LANG=en_US.UTF-8

# fzf - fuzzy finder.
source <(fzf --zsh)

# neovim.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Aliases.
alias launch-conda="source $HOME/.miniconda3/bin/activate"
