export ZSH="$HOME/.oh-my-zsh"

plugins=(git z)

source $ZSH/oh-my-zsh.sh

ccp() {
  scp $1 devcontainer.$2.jabbariao.coder:/home/ubuntu/$1
}

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

alias lg="lazygit"
alias e="nvim"
alias res="tmux a -t"
alias yz="yazi"

eval "$(mise activate zsh)"
eval "$(starship init zsh)"
