# =============================================================================
# claude.zsh — wrappers de Claude Code
# =============================================================================
# El token se lee desde $MINIMAX_ANTHROPIC_AUTH_TOKEN (definido en
# zsh/secrets.zsh, gitignored).
# =============================================================================

claude-minimax() {
  ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" \
  ANTHROPIC_AUTH_TOKEN="$MINIMAX_ANTHROPIC_AUTH_TOKEN" \
  CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000" \
  ANTHROPIC_MODEL="MiniMax-M3[1m]" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M3[1m]" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M3[1m]" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M3[1m]" \
  claude "$@"
}

qwen () {
  ANTHROPIC_BASE_URL="https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic" \
  ANTHROPIC_AUTH_TOKEN="$QWEN_ANTHROPIC_AUTH_TOKEN" \
  ANTHROPIC_MODEL="qwen3.8-max-preview" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="qwen3.6-flash" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="qwen3.8-max-preview" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="qwen3.8-max-preview" \
  CLAUDE_CODE_SUBAGENT_MODEL="qwen3.7-max" \
  CLAUDE_CODE_MAX_CONTEXT_TOKENS="983616" \
  claude "$@"
}