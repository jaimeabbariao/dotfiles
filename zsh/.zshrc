export ZSH="$HOME/.oh-my-zsh"

plugins=(git z zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# ~/.zshrc

export PATH="$HOME/.cargo/bin:$PATH"


eval "$(mise activate zsh)"

export PATH="$HOME/.local/bin:$PATH"
