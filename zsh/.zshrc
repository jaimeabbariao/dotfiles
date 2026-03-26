export ZSH="$HOME/.oh-my-zsh"

plugins=(git z zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

eval "$(mise activate zsh)"
eval "$(starship init zsh)"
