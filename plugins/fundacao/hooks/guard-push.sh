#!/usr/bin/env bash
# guard-push.sh — hook PreToolUse (matcher: Bash). Exit 2 bloqueia a ação.
#
# Impede que uma sessão de agente empurre trabalho para fora de claude/*, force
# push, ou apague branch remota. É a versão executável do guardrail descrito no
# Apêndice A do blueprint de orquestração.
#
# Instalação, no .claude/settings.json do departamento:
#   {
#     "hooks": {
#       "PreToolUse": [{
#         "matcher": "Bash",
#         "hooks": [{ "type": "command",
#                     "command": "${CLAUDE_PLUGIN_ROOT}/hooks/guard-push.sh" }]
#       }]
#     }
#   }
#
# Requer jq. Falha fechada: se não conseguir interpretar a entrada, bloqueia.

set -uo pipefail

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  echo "guard-push: jq não encontrado; bloqueando por precaução." >&2
  exit 2
fi

CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || {
  echo "guard-push: entrada ilegível; bloqueando por precaução." >&2
  exit 2
}

# Só interessa comando de push.
printf '%s' "$CMD" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+([^;&|]*[[:space:]])?push([[:space:]]|$)' || exit 0

deny() {
  echo "guard-push: $1" >&2
  echo "Sessões de agente só empurram para branches claude/*. Merge e main são gate humano." >&2
  exit 2
}

# Force push destrói histórico remoto — nunca, nem em claude/*.
printf '%s' "$CMD" | grep -qE '(--force([^-]|$)|--force-with-lease|[[:space:]]-f([[:space:]]|$))' \
  && deny "force push bloqueado."

# Deleção de branch remota.
printf '%s' "$CMD" | grep -qE '(--delete|[[:space:]]-d([[:space:]]|$)|[[:space:]]:[A-Za-z0-9._/-]+)' \
  && deny "deleção de branch remota bloqueada."

# Alvos explicitamente proibidos, mesmo que "claude" apareça em outro ponto do comando.
printf '%s' "$CMD" | grep -qE '[[:space:]](main|master|develop)([[:space:]]|$)|:(main|master|develop)([[:space:]]|$)' \
  && deny "push direto para branch protegida bloqueado."

# Extrai o refspec: última palavra que não seja flag, remoto conhecido ou o próprio git/push.
REF=$(printf '%s' "$CMD" \
  | tr ' ' '\n' \
  | grep -vE '^(git|push|origin|upstream|-u|--set-upstream|--tags|--quiet|-q|--verbose|-v)$' \
  | grep -vE '^-' \
  | tail -1)

# Push sem refspec empurra a branch atual — precisa que ela seja claude/*.
if [ -z "$REF" ]; then
  REF=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  [ -z "$REF" ] && deny "não foi possível determinar a branch de destino."
fi

# Aceita claude/x e origem:destino onde o destino é claude/x.
DEST="${REF##*:}"
case "$DEST" in
  claude/*) exit 0 ;;
  *) deny "destino '$DEST' fora de claude/*." ;;
esac
