# =============================================================================
# .zshrc — Bootstrap (Mauricio Dulce dotfiles)
# =============================================================================
# Solo configuración del shell. Aliases y funciones viven en zsh/*.zsh,
# sourceados al final de este archivo.
# =============================================================================

export DOTFILES="$HOME/.dotfiles"
export ZSH="$HOME/.oh-my-zsh"

# -----------------------------------------------------------------------------
# OMZ theme + plugins
# -----------------------------------------------------------------------------

# Spaceship se instala via Homebrew, no como tema OMZ — se carga manualmente.
# ZSH_THEME vacío le dice a OMZ que no gestione el tema.
ZSH_THEME=""


# -----------------------------------------------------------------------------
# Zsh Config
# -----------------------------------------------------------------------------

CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="dd/mm/yyyy"
ZSH_DISABLE_COMPFIX="true"
ZSH_CUSTOM=$DOTFILES/zsh
plugins=(git zsh-syntax-highlighting zsh-completions terraform)

source $ZSH/oh-my-zsh.sh

# Spaceship prompt (instalado via: brew install spaceship)
[[ -f "/opt/homebrew/opt/spaceship/spaceship.zsh" ]] && source "/opt/homebrew/opt/spaceship/spaceship.zsh"

# -----------------------------------------------------------------------------
# System paths
# -----------------------------------------------------------------------------

export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH=/usr/local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"

# -----------------------------------------------------------------------------
# Node Version Manager (NVM) — lazy load para startup rápido
# Se inicializa solo cuando se usa nvm, node, npm, npx o aliases n/ni/nci/nd
# -----------------------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"

# Carga lazy: define placeholders que se reemplazan al primer uso
_nvm_load() {
  unset -f nvm node npm npx n ni nci nd 2>/dev/null
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

nvm()  { _nvm_load && nvm "$@"; }
node() { _nvm_load && node "$@"; }
npm()  { _nvm_load && npm "$@"; }
npx() { _nvm_load && npx "$@"; }


# -----------------------------------------------------------------------------
# Zoxide (smarter cd command)
# https://github.com/ajeetdsouza/zoxide
# -----------------------------------------------------------------------------

eval "$(zoxide init zsh)"


# -----------------------------------------------------------------------------
# pyenv
# -----------------------------------------------------------------------------

eval "$(pyenv init -)"


# -----------------------------------------------------------------------------
# Zsh autocomplete
# (consolidado aquí al final, después de todos los fpath additions)
# -----------------------------------------------------------------------------

fpath+=$DOTFILES/zsh/completions
[[ -d "$HOME/.docker/completions" ]] && fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit && compinit


# -----------------------------------------------------------------------------
# 1Password CLI
# -----------------------------------------------------------------------------

[[ -f "$HOME/.op/plugins.sh" ]] && source "$HOME/.op/plugins.sh"


# -----------------------------------------------------------------------------
# Secrets & tokens (gitignored — ver ~/.dotfiles/zsh/secrets.zsh)
# -----------------------------------------------------------------------------

[[ -f $DOTFILES/zsh/secrets.zsh ]] && source $DOTFILES/zsh/secrets.zsh


# -----------------------------------------------------------------------------
# Aliases & funciones (zsh/*.zsh, excepto k8s-safety que va aparte)
# Orden de carga respeta dependencias: statamic usa ci, a, osslink, init.
# -----------------------------------------------------------------------------

for f in \
  $DOTFILES/zsh/system.zsh \
  $DOTFILES/zsh/git.zsh \
  $DOTFILES/zsh/npm.zsh \
  $DOTFILES/zsh/php.zsh \
  $DOTFILES/zsh/laravel.zsh \
  $DOTFILES/zsh/open-source.zsh \
  $DOTFILES/zsh/statamic.zsh \
  $DOTFILES/zsh/opencode.zsh \
  $DOTFILES/zsh/claude.zsh
do
  [[ -f "$f" ]] && source "$f"
done


# -----------------------------------------------------------------------------
# Kubernetes safety (wrapper de kubectl con confirmaciones)
# -----------------------------------------------------------------------------

source $DOTFILES/zsh/k8s-safety.zsh


# -----------------------------------------------------------------------------
# Herd PHP paths (auto-inyectados por Herd installer — NO mover de aquí,
# Herd los reescribe en esta posición al actualizar)
# -----------------------------------------------------------------------------

export HERD_PHP_84_INI_SCAN_DIR="/Users/mauricio/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP binary.
export PATH="/Users/mauricio/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/mauricio/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/mauricio/Library/Application Support/Herd/config/php/85/"