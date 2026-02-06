export DOTFILES="$HOME/.dotfiles"
export ZSH="$HOME/.oh-my-zsh"

# ------------------------------------------------------------------------------
# Zsh Theme
# ------------------------------------------------------------------------------

source "/opt/homebrew/opt/spaceship/spaceship.zsh"


# ------------------------------------------------------------------------------
# Zsh Config
# ------------------------------------------------------------------------------

ZSH_THEME="robbyrussell"
CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="dd/mm/yyyy"
ZSH_DISABLE_COMPFIX="true"
ZSH_CUSTOM=$DOTFILES/zsh
plugins=(git zsh-syntax-highlighting zsh-completions terraform)

source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# Zsh autocomplete
# ------------------------------------------------------------------------------

fpath+=$DOTFILES/zsh/completions
autoload -Uz compinit && compinit

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------

export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH=$PATH:/usr/local/mysql/bin/
export PATH=/usr/local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"




# ------------------------------------------------------------------------------
# Node Version Manager (NVM)
# ------------------------------------------------------------------------------

  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
# ------------------------------------------------------------------------------
# Zoxide (smarter cd command)
# https://github.com/ajeetdsouza/zoxide
# ------------------------------------------------------------------------------

eval "$(zoxide init zsh)" 

export PATH="$HOME/.spin/bin:$PATH"


source ~/.config/op/plugins.sh
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/mauricio/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP binary.
export PATH="/Users/mauricio/Library/Application Support/Herd/bin/":$PATH
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export JIRA_API_TOKEN=""
autoload -U compinit; compinit


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/mauricio/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/mauricio/Library/Application Support/Herd/config/php/82/"

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"




# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/mauricio/Library/Application Support/Herd/config/php/85/"

# ------------------------------------------------------------------------------
# Kubernetes Safety Config
# ------------------------------------------------------------------------------

source $DOTFILES/zsh/k8s-safety.zsh
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/mauricio/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
