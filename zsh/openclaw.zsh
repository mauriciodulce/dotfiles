# ------------------------------------------------------------------------------
# OpenClaw VPS (openclaw-vps in ~/.ssh/config → 94.237.80.177)
# All commands run as the unprivileged `openclaw` service user (no sudo),
# reached via `manager` (sudo -u openclaw), with PATH/XDG_RUNTIME_DIR set.
# ------------------------------------------------------------------------------

oc-help() {
    local BOLD="\033[1m"
    local DIM="\033[2m"
    local CYAN="\033[36m"
    local YELLOW="\033[33m"
    local GREEN="\033[32m"
    local RESET="\033[0m"

    echo ""
    echo -e "${BOLD}${CYAN}  ╔═══════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}  ║         OpenClaw VPS — Alias Guide        ║${RESET}"
    echo -e "${BOLD}${CYAN}  ╚═══════════════════════════════════════════╝${RESET}"
    echo -e "  ${DIM}VPS: 94.237.80.177  •  SSH: openclaw-vps  •  Model: MiniMax-M3${RESET}"
    echo ""

    echo -e "  ${YELLOW}${BOLD}GATEWAY${RESET}"
    echo -e "  ${GREEN}oc-gw-status${RESET}        Estado del servicio systemd del gateway"
    echo -e "  ${GREEN}oc-restart${RESET}          Reinicia el gateway"
    echo -e "  ${GREEN}oc-logs${RESET}             Tail en vivo de logs del gateway (Ctrl+C para salir)"
    echo -e "  ${GREEN}oc-tunnel${RESET}           Expone la Control UI en ${CYAN}http://localhost:18789${RESET}"
    echo ""

    echo -e "  ${YELLOW}${BOLD}ESTADO Y SALUD${RESET}"
    echo -e "  ${GREEN}oc-status${RESET}           Gateway + canales + sesiones recientes"
    echo -e "  ${GREEN}oc-doctor${RESET}           Health check del gateway y canales"
    echo -e "  ${GREEN}oc-doctor-fix${RESET}       Igual que doctor pero aplica los fixes"
    echo ""

    echo -e "  ${YELLOW}${BOLD}SESIONES${RESET}"
    echo -e "  ${GREEN}oc-kill${RESET}             Sin arg: lista sesiones pegadas (running)"
    echo -e "  ${GREEN}oc-kill <key>${RESET}       Aborta la sesión con esa key"
    echo ""

    echo -e "  ${YELLOW}${BOLD}SETUP Y ACCESO${RESET}"
    echo -e "  ${GREEN}oc-onboard${RESET}          Guided setup (credenciales, modelo, canales)"
    echo -e "  ${GREEN}oc-shell${RESET}            Shell interactiva como usuario openclaw en el VPS"
    echo ""

    echo -e "  ${YELLOW}${BOLD}GENÉRICO${RESET}"
    echo -e "  ${GREEN}ocw <comando>${RESET}       Corre cualquier comando openclaw en el VPS"
    echo -e "  ${DIM}  Ej: ocw sessions list  •  ocw models status  •  ocw cron list${RESET}"
    echo ""
}

_oc_run() {
    ssh -t openclaw-vps "sudo -u openclaw -H bash -c 'cd ~; export XDG_RUNTIME_DIR=/run/user/1001; export PATH=\$HOME/.npm-global/bin:\$HOME/.homebrew/bin:\$PATH; export NODE_COMPILE_CACHE=/var/tmp/openclaw-compile-cache; export OPENCLAW_NO_RESPAWN=1; $*'"
}

# Generic passthrough: ocw sessions --active 60
# (named ocw, not oc — `oc` is already your opencode alias)
ocw() {
    _oc_run "openclaw $*"
}

oc-onboard() {
    _oc_run "openclaw onboard"
}

oc-doctor() {
    _oc_run "openclaw doctor"
}

oc-doctor-fix() {
    _oc_run "openclaw doctor --fix"
}

oc-status() {
    _oc_run "openclaw status"
}

# Interactive shell as the openclaw user, PATH already set
oc-shell() {
    _oc_run "bash"
}

# Gateway systemd service (runs as manager, doesn't need the openclaw shell)
oc-restart() {
    ssh openclaw-vps "sudo -u openclaw XDG_RUNTIME_DIR=/run/user/1001 systemctl --user restart openclaw-gateway.service"
}

oc-gw-status() {
    ssh openclaw-vps "sudo -u openclaw XDG_RUNTIME_DIR=/run/user/1001 systemctl --user status openclaw-gateway.service --no-pager"
}

oc-logs() {
    ssh openclaw-vps "sudo journalctl _SYSTEMD_USER_UNIT=openclaw-gateway.service -f"
}

# Tunnel the Control UI to http://localhost:18789 (Ctrl+C to close)
oc-tunnel() {
    ssh -N -L 18789:localhost:18789 openclaw-vps
}

# Kill a stuck session: oc-kill <sessionKey>
# Find keys with: oc-kill  (lists running sessions)
oc-kill() {
    local key="$1"
    if [[ -z "$key" ]]; then
        printf "Running sessions (copy the key to abort):\n\n"
        ssh openclaw-vps "sudo -u openclaw bash -c 'export XDG_RUNTIME_DIR=/run/user/1001; export PATH=\$HOME/.npm-global/bin:\$HOME/.homebrew/bin:\$PATH; openclaw sessions list --json'" 2>/dev/null \
            | python3 -c "
import json, sys
data = sys.stdin.read()
sessions = json.loads(data)['sessions']
running = [s for s in sessions if s.get('status') == 'running']
if not running:
    print('  (none — no stuck sessions)')
else:
    for s in running:
        print('  ' + s['key'])
"
        printf "\nUsage: oc-kill <sessionKey>\n"
        return 1
    fi
    ssh openclaw-vps "sudo -u openclaw bash -s" << EOF
export XDG_RUNTIME_DIR=/run/user/1001
export PATH=\$HOME/.npm-global/bin:\$HOME/.homebrew/bin:\$PATH
export NODE_COMPILE_CACHE=/var/tmp/openclaw-compile-cache
openclaw gateway call chat.abort --params '{"sessionKey":"$key"}'
EOF
}
