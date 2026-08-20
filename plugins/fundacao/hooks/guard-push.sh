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
# Lê o comando com jq ou, na falta dele, com o módulo json do Python — ambos
# stdlib do ambiente, nenhum pacote a instalar. Numa máquina Windows sem jq a
# versão anterior bloqueava TODO push, inclusive os claude/* que deve liberar:
# guardrail que nega tudo é indistinguível de guardrail quebrado, e convida a
# desinstalação. Falha fechada continua valendo — sem nenhum dos dois leitores,
# ou com entrada ilegível, bloqueia.
#
# O que ele NÃO faz: não valida o conteúdo do que se empurra, não substitui a
# proteção de branch no servidor (um agente sem este hook continua alcançando
# `main` se o ruleset permitir), e não cobre push por ferramenta que não seja o
# comando `git` — API, MCP ou biblioteca passam ao largo. É defesa em
# profundidade, não a única camada.
#
# Comportamento verificado por `test-guard-push.sh`, ao lado. Rode-o depois de
# qualquer edição: a suíte existe porque um guardrail sem prova de que bloqueia
# é uma afirmação, não um controle.

set -uo pipefail

INPUT=$(cat)

leia_comando() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null && return 0
    return 1
  fi
  for PY in python3 python py; do
    command -v "$PY" >/dev/null 2>&1 || continue
    printf '%s' "$INPUT" | "$PY" -c 'import json,sys
try:
    print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))
except Exception:
    sys.exit(1)' 2>/dev/null && return 0
    return 1
  done
  echo "guard-push: nem jq nem python encontrados; bloqueando por precaução." >&2
  return 2
}

CMD=$(leia_comando) || {
  [ $? -eq 2 ] || echo "guard-push: entrada ilegível; bloqueando por precaução." >&2
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

# Modos que empurram o repositório inteiro, sem refspec nenhum. Sem esta trava
# eles caem no fallback de "branch atual" logo abaixo, que numa sessão de agente
# é claude/* — e passam. Mas `--all` empurra TODAS as branches locais, `main`
# inclusive, `--mirror` espelha o repositório (o que apaga refs remotas que não
# existam mais no local) e `--prune` apaga remotas diretamente. Os três fazem
# exatamente o que as travas acima proíbem, por um caminho que elas não olham.
printf '%s' "$CMD" | grep -qE '(--all|--mirror|--prune)([[:space:]]|$)' \
  && deny "push de repositório inteiro (--all/--mirror/--prune) bloqueado."

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
