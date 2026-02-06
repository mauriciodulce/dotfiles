# ==============================================================================
# 🛡️ KUBERNETES SAFETY CONFIG - Mauricio "Chuck Norris" Dulce
# ==============================================================================
# Previene cagadas pero mantiene el poder
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CONTEXT AWARENESS - Siempre saber dónde estás
# ------------------------------------------------------------------------------

# Mostrar contexto actual en prompt (Spaceship ya lo hace pero reforzamos)
export KUBE_PS1_ENABLED=on
export KUBE_PS1_SYMBOL_ENABLE=true
export KUBE_PS1_SYMBOL_DEFAULT="☸️ "

# Colores por ambiente
export KUBE_PS1_CTX_COLOR="green"
export KUBE_PS1_NS_COLOR="cyan"

# Override para producción = ROJO
kubectx_prod_warning() {
  local ctx=$(kubectl config current-context 2>/dev/null)
  if [[ "$ctx" == *"amc-cluster"* ]] || [[ "$ctx" == *"production"* ]]; then
    export KUBE_PS1_CTX_COLOR="red"
    export KUBE_PS1_SYMBOL_DEFAULT="🔥 "
  else
    export KUBE_PS1_CTX_COLOR="green"
    export KUBE_PS1_SYMBOL_DEFAULT="☸️ "
  fi
}

# Hook en cada comando
precmd_functions+=(kubectx_prod_warning)

# ------------------------------------------------------------------------------
# 2. ALIASES SEGUROS - Confirmación antes de destrucción
# ------------------------------------------------------------------------------

# Alias básicos (sin cambios)
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Context switching SEGURO
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

# Delete ALL pods - Modo Chuck Norris con triple confirmación
kdel-all-pods() {
  local ctx=$(kubectl config current-context)
  local ns=${1:-default}
  
  echo "🔥🔥🔥 CHUCK NORRIS MODE ACTIVADO 🔥🔥🔥"
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
# 4. PRODUCCIÓN = MODO READONLY por defecto
# ------------------------------------------------------------------------------

# Función para entrar en "production write mode"
kprod-write() {
  local ctx=$(kubectl config current-context)
  echo "⚠️  PRODUCTION WRITE MODE ACTIVADO ⚠️"
  echo "Contexto: $ctx"
  echo "Timeout: 5 minutos"
  export KPROD_WRITE_MODE=1
  
  # Auto-disable después de 5 minutos
  (sleep 300 && unset KPROD_WRITE_MODE && echo "\n🔒 Production write mode expirado") &
}

# Wrapper para comandos write en producción
kubectl() {
  local ctx=$(command kubectl config current-context 2>/dev/null)
  local is_prod=0
  
  # Detectar si es producción
  if [[ "$ctx" == *"amc-cluster"* ]] || [[ "$ctx" == *"production"* ]]; then
    is_prod=1
  fi
  
  # Lista de comandos que modifican
  local write_cmds="delete|create|apply|edit|patch|replace|scale|rollout"
  
  # Si es comando write en producción y no está en write mode
  if [[ $is_prod -eq 1 ]] && [[ "$1" =~ ^($write_cmds)$ ]] && [[ -z "$KPROD_WRITE_MODE" ]]; then
    echo "🔒 PRODUCCIÓN: Modo solo-lectura"
    echo "Para habilitar escritura: kprod-write"
    echo "O usar: kubectl-force $@"
    return 1
  fi
  
  # Ejecutar comando normal
  command kubectl "$@"
}

# Bypass para cuando REALMENTE necesitas
alias kubectl-force='command kubectl'

# ------------------------------------------------------------------------------
# 5. UTILIDADES RÁPIDAS
# ------------------------------------------------------------------------------

# Switch rápido a producción
kprod() {
  kubectl config use-context amc@amc-cluster
  echo "🔥 PRODUCCIÓN ACTIVA - Modo solo lectura"
}

# Switch rápido a local
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
    elif [[ "$line" == *"amc"* ]] || [[ "$line" == *"production"* ]]; then
      echo "   \033[1;31m$line\033[0m"  # Rojo para prod
    else
      echo "   $line"
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

