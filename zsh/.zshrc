export ZSH="$HOME/.oh-my-zsh"

plugins=(git z zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Testing
hello-world () {
  msg="hello, $1"
  echo $msg
}

# git rebase after merge
rebase_sync () {
  # $1 is the current branch
  # $2 is the branch we just squashed and merged (which should also be the parent of $1)
  merge_base_commit=$(git merge-base $1 $2)
  git rebase --onto $(git_main_branch) $merge_base_commit $1
}

alias cls="clear"
alias lg="lazygit"
alias figma="cd ~/figma/figma"
alias fcode="cd ~/figma/figma && code figma.code-workspace"
alias fcur="cd ~/figma/figma && cursor figma.code-workspace"
alias zsh-conf='nvim ~/.zshrc'
alias zsh-rel='source ~/.zshrc'

export EDITOR="nvim"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig:/usr/local/opt/openssl@3/lib/pkgconfig:$PKG_CONFIG_PATH"
eval "$(rbenv init -)"
export RACK_ENV=development
export PATH="$HOME/.cargo/bin:$PATH"
export AWS_CONFIG_FILE="$HOME/figma/figma/config/aws/sso_config"
export PATH="$HOME/go/bin:$PATH"

#compdef gt
###-begin-gt-completions-###
#
# yargs command completion script
#
# Installation: gt completion >> ~/.zshrc
#    or gt completion >> ~/.zprofile on OSX.
#
_gt_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt
###-end-gt-completions-###


export PYENV_ROOT="$HOME/.pyenv"
# DATABOX - Snowflake environment variables
export DATABOX_SNOWFLAKE_USER="jabbariao"
export DATABOX_SNOWFLAKE_ACCOUNT="YTA50202"
export DATABOX_SNOWFLAKE_ROLE="SNOWFLAKE DEVELOPMENT"
export DATABOX_SNOWFLAKE_DATABASE="DBT_ANALYTICS"
export DATABOX_SNOWFLAKE_WAREHOUSE="DEVELOPMENT"
# DATABOX - DBT environment variables
export DATABOX_DBT_SCHEMA="dbt_jabbariao"
export DBT_PROFILES_DIR="/Users/jabbariao/.dbt/databox"
export DBT_PROFILE="default"
export DBT_DEFER="true"
export DBT_STATE="/Users/jabbariao/.dbt/databox/prod_artifacts"
# DATABOX - aliases
alias databox="cd /Users/jabbariao/figma/dbt_analytics && source databox/bin/activate && databox_init"

# pnpm
export PNPM_HOME="/Users/jabbariao/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/jabbariao/.bun/_bun" ] && source "/Users/jabbariao/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export ZELLIJ_AUTO_START="true"
export ZELLIJ_AUTO_EXIT="true"

eval "$(zellij setup --generate-auto-start zsh)"
