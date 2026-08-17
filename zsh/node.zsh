# -----------------------------------------------------------------------------
# Node (nvm) — expone el bin de la versión default en el PATH desde el arranque
# -----------------------------------------------------------------------------
# La carga lazy de nvm (ver .zshrc) solo intercepta nvm/node/npm/npx: hasta que
# uno de esos se invoca, "$NVM_DIR/versions/node/<version>/bin" no está en el
# PATH, así que cualquier otro binario global instalado con npm (openwolf, etc.)
# da "command not found" en una terminal recién abierta. Este archivo resuelve
# la versión default de nvm y agrega su bin al PATH sin cargar nvm completo.

if [[ -f "$NVM_DIR/alias/default" ]]; then
  _nvm_default_alias="$(command cat "$NVM_DIR/alias/default" 2>/dev/null)"
  _nvm_default_bin="$(command ls -d "$NVM_DIR"/versions/node/v${_nvm_default_alias#v}* 2>/dev/null | sort -V | tail -1)/bin"
  [[ -d "$_nvm_default_bin" ]] && export PATH="$_nvm_default_bin:$PATH"
  unset _nvm_default_alias _nvm_default_bin
fi
