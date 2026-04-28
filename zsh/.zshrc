export ZSH="$HOME/.oh-my-zsh"

plugins=(git z)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

alias lg="lazygit"
alias e="nvim"
alias kami="claude --dangerously-skip-permissions"

eval "$(mise activate zsh)"
eval "$(starship init zsh)"
