# =============================================================================
# opencode.zsh — integraciones con OpenCode
# =============================================================================
# `oc` usa 1Password CLI para inyectar secrets al runtime de OpenCode.
# =============================================================================

alias oc='op run --env-file ~/.config/opencode/.env -- opencode'