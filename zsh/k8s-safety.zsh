# ==============================================================================
# 🛡️ KUBERNETES SAFETY CONFIG — asume TODO cluster como producción
# ==============================================================================
# Filosofía: cualquier kubectl write op requiere confirmación o kprod-write.
# No hay distinción dev/staging/prod — todo es prod. Para saltarse la
# protección puntualmente: `kubectl-force <args>` (alias de `command kubectl`).
# Para habilitar escritura temporal (5 min): `kprod-write`.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. PROMPT — todos los clusters son producción
# ------------------------------------------------------------------------------

export KUBE_PS1_ENABLED=on
export KUBE_PS1_SYMBOL_ENABLE=true
export KUBE_PS1_SYMBOL_DEFAULT="🔥 "

export KUBE_PS1_CTX_COLOR="red"
export KUBE_PS1_NS_COLOR="cyan"


# ------------------------------------------------------------------------------
# 2. ALIASES SEGUROS - Confirmación antes de destrucción
# ------------------------------------------------------------------------------

alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias klf='kubectl logs -f'

alias kctx='kubectl config get-contexts && echo "\n🎯 Usar: kubectl config use-context <nombre>"'
alias kns='kubectl get namespaces'


# ------------------------------------------------------------------------------
# 3. COMANDOS DESTRUCTIVOS - Requieren confirmación
# ------------------------------------------------------------------------------

# Delete con confirmación
kdel() {
  local ctx=$(kubectl config current-context)
  echo "🔥 CONTEXTO ACTUAL: $ctx"
  echo "❓ Recurso a borrar: $@"
  echo -n "¿Continuar? (yes/NO): "
  read confirm
  if [[ "$confirm" == "yes" ]]; then
    kubectl delete "$@"
  else
    echo "❌ Cancelado"
  fi
}

# Delete ALL pods - Triple confirmación (todo es producción)
kdel-all-pods() {
  local ctx=$(kubectl config current-context)
  local ns=${1:-default}

  echo "🔥🔥🔥 MODO PELIGRO: BORRAR TODOS LOS PODS 🔥🔥🔥"
  echo "Contexto: $ctx"
  echo "Namespace: $ns"
  echo ""
  echo "Esto borrará TODOS los pods en el namespace."
  echo -n "Escribe el nombre del namespace para confirmar: "
  read confirm_ns

  if [[ "$confirm_ns" != "$ns" ]]; then
    echo "❌ Cancelado - namespace no coincide"
    return 1
  fi

  echo -n "Escribe 'DELETE ALL PODS' para confirmar: "
  read confirm_text

  if [[ "$confirm_text" == "DELETE ALL PODS" ]]; then
    echo "💀 Borrando todos los pods..."
    kubectl delete pods --all -n "$ns"
  else
    echo "❌ Cancelado"
  fi
}

# Delete namespace - ULTRA confirmación
kdel-ns() {
  local ns=$1
  local ctx=$(kubectl config current-context)

  if [[ -z "$ns" ]]; then
    echo "❌ Uso: kdel-ns <namespace>"
    return 1
  fi

  echo "💀💀💀 BORRAR NAMESPACE 💀💀💀"
  echo "Contexto: $ctx"
  echo "Namespace: $ns"
  echo ""

  # Mostrar recursos que se borrarán
  echo "📋 Recursos que se borrarán:"
  kubectl get all -n "$ns" 2>/dev/null | head -20
  echo ""

  echo -n "Escribe el nombre COMPLETO del namespace '$ns' para confirmar: "
  read confirm_ns

  if [[ "$confirm_ns" != "$ns" ]]; then
    echo "❌ Cancelado"
    return 1
  fi

  echo -n "Última confirmación - escribe 'DELETE NAMESPACE': "
  read confirm_final

  if [[ "$confirm_final" == "DELETE NAMESPACE" ]]; then
    echo "💀 Borrando namespace $ns..."
    kubectl delete namespace "$ns"
  else
    echo "❌ Cancelado"
  fi
}


# ------------------------------------------------------------------------------
# 4. WRITE MODE — habilita escritura temporal (5 min) en cualquier cluster
# ------------------------------------------------------------------------------

# Función para entrar en "write mode"
kprod-write() {
  local ctx=$(kubectl config current-context 2>/dev/null)
  echo "⚠️  WRITE MODE ACTIVADO ⚠️"
  echo "Contexto: $ctx"
  echo "Timeout: 5 minutos"
  export KPROD_WRITE_MODE=1

  # Auto-disable después de 5 minutos
  (sleep 300 && unset KPROD_WRITE_MODE && echo "\n🔒 Write mode expirado") &
}

# Wrapper de kubectl — bloquea write commands a menos que KPROD_WRITE_MODE esté activo
kubectl() {
  local write_cmds="delete|create|apply|edit|patch|replace|scale|rollout"

  if [[ "$1" =~ ^($write_cmds)$ ]] && [[ -z "$KPROD_WRITE_MODE" ]]; then
    echo "🔒 Modo solo-lectura (todos los clusters son producción)"
    echo "Para habilitar escritura temporal (5 min): kprod-write"
    echo "O usar: kubectl-force $@"
    return 1
  fi

  command kubectl "$@"
}

# Bypass directo cuando REALMENTE lo necesitas
alias kubectl-force='command kubectl'


# ------------------------------------------------------------------------------
# 5. UTILIDADES RÁPIDAS
# ------------------------------------------------------------------------------

# Switch rápido al cluster local (ajusta el context si renombraste)
klocal() {
  kubectl config use-context dulce@kv00217-cluster
  echo "💻 Cluster local activo"
}

# Ver TODOS los contextos con colores
kctx-list() {
  local current=$(kubectl config current-context 2>/dev/null)
  echo "📋 Contextos disponibles:\n"
  kubectl config get-contexts | while read line; do
    if [[ "$line" == *"$current"* ]]; then
      echo "➜  \033[1;32m$line\033[0m"  # Verde para actual
    else
      echo "   \033[1;31m$line\033[0m"  # Rojo para todos los demás (todo es prod)
    fi
  done
}

# Exec seguro con confirmación de pod
kexec() {
  local pod=$1
  shift
  local ns=$(kubectl get pod "$pod" -o jsonpath='{.metadata.namespace}' 2>/dev/null)
  local ctx=$(kubectl config current-context)

  echo "🔌 Exec en pod"
  echo "Contexto: $ctx"
  echo "Pod: $pod"
  echo "Namespace: ${ns:-default}"
  echo "Comando: $@"
  echo -n "Confirmar? (y/N): "
  read confirm

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    kubectl exec -it "$pod" -- "$@"
  else
    echo "❌ Cancelado"
  fi
}


# ------------------------------------------------------------------------------
# 6. LOGS INTELIGENTES
# ------------------------------------------------------------------------------

# Logs con tail automático
klogs() {
  local pod=$1
  local lines=${2:-100}
  kubectl logs "$pod" --tail="$lines" -f
}

# Logs de todos los pods de un deployment
klogs-deploy() {
  local deploy=$1
  kubectl logs -l "app=$deploy" --tail=50 -f --max-log-requests=10
}


# ------------------------------------------------------------------------------
# 7. DEBUGGING RÁPIDO
# ------------------------------------------------------------------------------

# Describe con less
kdesc() {
  kubectl describe "$@" | less
}

# Get con output yaml pretty
kget-yaml() {
  kubectl get "$@" -o yaml | bat -l yaml 2>/dev/null || kubectl get "$@" -o yaml
}

# Port-forward con cleanup
kpf() {
  local resource=$1
  local port=$2
  echo "🔌 Port forwarding: localhost:$port -> $resource"
  echo "Ctrl+C para terminar"
  kubectl port-forward "$resource" "$port"
}


# ------------------------------------------------------------------------------
# 8. HEALTH CHECKS
# ------------------------------------------------------------------------------

# Ver pods con problemas
kbad() {
  echo "💀 Pods con problemas:\n"
  kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded
}

# Ver eventos recientes
kevents() {
  kubectl get events --sort-by='.lastTimestamp' | tail -20
}

# Top pods ordenado
ktop() {
  kubectl top pods --all-namespaces | sort -k3 -rn | head -20
}