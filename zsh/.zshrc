export ZSH="$HOME/.oh-my-zsh"

plugins=(git z zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

alias cls="clear"
alias lg="lazygit"
alias e="nvim"
alias res="tmux a -t"
alias yz="yazi"
alias zsh-conf='nvim ~/.zshrc'
alias zsh-rel='source ~/.zshrc'

# git rebase after merge
rebase_sync () {
  # $1 is the current branch
  # $2 is the branch we just squashed and merged (which should also be the parent of $1)
  merge_base_commit=$(git merge-base $1 $2)
  git rebase --onto $(git_main_branch) $merge_base_commit $1
}

theme() {
  command python3 "${${(%):-%x}:A:h:h}/scripts/theme.py" "$@"
}

# Machine-specific config and secrets; never commit these.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

eval "$(mise activate zsh)"
eval "$(starship init zsh)"
