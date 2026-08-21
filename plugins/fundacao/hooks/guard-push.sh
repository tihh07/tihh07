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

# Corpo de heredoc é DADO, não comando. Uma mensagem de commit escrita via
# `<<EOF` pode citar comandos de exemplo, e um script gerado por heredoc pode
# conter linhas inteiras deles; nada disso é executado pelo shell que estamos
# inspecionando. Sem descartar esses corpos, o hook nega trabalho legítimo — foi
# o que aconteceu em 2026-08-20, quando uma mensagem de commit que mencionava o
# próprio guardrail passou a bloquear o commit que a carregava.
sem_heredoc() {
  awk '
    # Dentro de um corpo de heredoc: só procura o marcador de fim.
    dentro {
      linha = $0
      sub(/^[ \t]+/, "", linha)
      if (linha == marca) { dentro = 0 }
      next
    }
    {
      print
      # Abre um heredoc? Guarda o marcador, com ou sem aspas, com ou sem <<-.
      if (match($0, /<<-?[ \t]*("[^"]+"|'"'"'[^'"'"']+'"'"'|[A-Za-z_][A-Za-z0-9_]*)/)) {
        marca = substr($0, RSTART, RLENGTH)
        sub(/^<<-?[ \t]*/, "", marca)
        gsub(/["'"'"']/, "", marca)
        dentro = 1
      }
    }
  '
}

CMD=$(printf '%s' "$CMD" | sem_heredoc)

# Um comando pode encadear vários segmentos (`a && b`, `a; b`, `a | b`). Cada um
# é avaliado por si: o que interessa é se ALGUM deles é um `git push`, e as
# travas se aplicam ao segmento que é, não à string inteira.
#
# Varrer a string inteira era o desenho anterior, e ele negava trabalho legítimo:
# um `git commit` cuja mensagem mencionasse a palavra "push" — dentro de um
# heredoc, longe de qualquer comando — casava com o padrão e era bloqueado.
# Guardrail que nega demais é indistinguível de guardrail quebrado, e convida à
# desinstalação; está escrito no cabeçalho deste arquivo e vale para ele mesmo.

deny() {
  echo "guard-push: $1" >&2
  echo "Sessões de agente só empurram para branches claude/*. Merge e main são gate humano." >&2
  exit 2
}

# Verdadeiro quando o segmento é um `git push`: depois de `git`, só podem vir
# opções globais antes do subcomando. Assim `git -c k=v commit` não é push, e
# `git --no-pager push` é.
e_um_push() {
  local -a w
  read -r -a w <<< "$1"
  local i=0
  [ "${w[0]:-}" = "git" ] || return 1
  i=1
  while [ $i -lt ${#w[@]} ]; do
    case "${w[$i]}" in
      # Opções globais que consomem o argumento seguinte.
      -C|-c|--git-dir|--work-tree|--namespace|--exec-path) i=$((i + 2)) ;;
      -*) i=$((i + 1)) ;;
      *) break ;;
    esac
  done
  [ "${w[$i]:-}" = "push" ]
}

# Redirecionamento é sintaxe do shell, não destino de push. `git push -u origin
# claude/x 2>&1` termina com um token `2>` depois que o segmentador quebra no
# `&`, e a extração de refspec abaixo — que pega a última palavra que não é flag
# — lia esse `2>` como o destino e negava o envio. Foi o que aconteceu em
# 2026-08-21, num push para uma branch claude/* perfeitamente legítima.
#
# A limpeza vale SÓ para descobrir o refspec. As travas de força, deleção,
# branch protegida e repositório inteiro já rodaram sobre o segmento inteiro,
# antes daqui: nada que esta função apague escapa delas. E ela só remove
# sintaxe de redirecionamento, que nunca é um ref válido — na pior hipótese o
# refspec some e o hook cai no fallback da branch atual, que é o caminho mais
# restritivo, não o mais frouxo.
sem_redirecao() {
  printf '%s' "$1" | sed -E 's/[0-9]*(>>|>|<)[[:space:]]*(&[0-9-]+)?[^[:space:]]*/ /g'
}

verifica_segmento() {
  local SEG="$1"

  # Force push destrói histórico remoto — nunca, nem em claude/*.
  printf '%s' "$SEG" | grep -qE '(--force([^-]|$)|--force-with-lease|[[:space:]]-f([[:space:]]|$))' \
    && deny "force push bloqueado."

  # Deleção de branch remota.
  printf '%s' "$SEG" | grep -qE '(--delete|[[:space:]]-d([[:space:]]|$)|[[:space:]]:[A-Za-z0-9._/-]+)' \
    && deny "deleção de branch remota bloqueada."

  # Alvos proibidos, mesmo que "claude" apareça em outro ponto do segmento.
  printf '%s' "$SEG" | grep -qE '[[:space:]](main|master|develop)([[:space:]]|$)|:(main|master|develop)([[:space:]]|$)' \
    && deny "push direto para branch protegida bloqueado."

  # Modos que empurram o repositório inteiro, sem refspec nenhum. Sem esta trava
  # caem no fallback de "branch atual" abaixo, que numa sessão de agente é
  # claude/* — e passam. Mas `--all` empurra TODAS as branches locais, `main`
  # inclusive, `--mirror` espelha o repositório (apagando refs remotas que não
  # existam mais no local) e `--prune` apaga remotas diretamente. Os três fazem o
  # que as travas acima proíbem, por um caminho que elas não olham.
  printf '%s' "$SEG" | grep -qE '(--all|--mirror|--prune)([[:space:]]|$)' \
    && deny "push de repositório inteiro (--all/--mirror/--prune) bloqueado."

  # Extrai o refspec: última palavra que não seja flag, remoto conhecido ou o próprio git/push.
  # O `grep -vE '^$'` não é cosmético. `sem_redirecao` troca o redirecionamento
  # por um espaço, então `... claude/x 2>` vira `... claude/x  ` e o `tr` produz
  # tokens vazios no fim. Sem descartá-los, `tail -1` devolve **string vazia** em
  # vez do refspec, o refspec "some", e o fluxo cai no fallback da branch atual
  # logo abaixo — que acerta por acaso quando a suíte roda num checkout `claude/*`
  # e erra em qualquer outro. Foi assim que a correção de 2026-08-21 passou 42/42
  # na máquina local e falhou 4 casos no runner do GitHub, onde o checkout de
  # `pull_request` deixa o HEAD destacado.
  REF=$(sem_redirecao "$SEG" \
    | tr ' ' '\n' \
    | grep -vE '^$' \
    | grep -vE '^(git|push|origin|upstream|-u|--set-upstream|--tags|--quiet|-q|--verbose|-v)$' \
    | grep -vE '^-' \
    | tail -1)

  # Push sem refspec empurra a branch atual — precisa que ela seja claude/*.
  if [ -z "$REF" ]; then
    REF=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    [ -z "$REF" ] && deny "não foi possível determinar a branch de destino."
  fi

  # Aceita claude/x e origem:destino onde o destino é claude/x.
  # `return`, não `exit`: um segmento liberado não encerra a varredura, senão o
  # primeiro envio legítimo faria o hook parar antes de olhar o segundo.
  DEST="${REF##*:}"
  case "$DEST" in
    claude/*) return 0 ;;
    *) deny "destino '$DEST' fora de claude/*." ;;
  esac
}

while IFS= read -r SEG; do
  SEG=$(printf '%s' "$SEG" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  [ -n "$SEG" ] || continue
  e_um_push "$SEG" && verifica_segmento "$SEG"
done <<< "$(printf '%s' "$CMD" | sed -E 's/(\|\||&&|;|\||&)/\n/g')"

# Nenhum segmento era um push: nada a decidir.
exit 0
