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
  echo "Sessões de agente só empurram para branches claude/*. Push direto em main é bloqueado; merge é por PR." >&2
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

# Opções que CONSOMEM o token seguinte — o valor delas nunca é um refspec.
# A distinção não é acadêmica: um filtro que só descarta o que começa com `-`
# deixa o VALOR no meio dos tokens, e a extração de refspec — última palavra que
# não é flag — passa a lê-lo como destino. Foi o falso positivo medido em
# 2026-08-25: `git -C "$LIB" push` era negado com "destino '"$LIB"' fora de
# claude/*", num push para uma branch `claude/*` legítima e pelo caminho que a
# rotina de fechamento de sessão prescreve. Guardrail que nega o fluxo que ele
# existe para permitir gasta a confiança que faz alguém mantê-lo instalado.
#
# Duas metades: opções globais do git, antes do subcomando (as mesmas de
# `e_um_push`), e as de `git push` que levam valor separado. A forma
# `--opcao=valor` não precisa entrar — é um único token, que o filtro de `-` já
# descarta.
consome_proximo() {
  case "$1" in
    -C|-c|--git-dir|--work-tree|--namespace|--exec-path) return 0 ;;
    --repo|-o|--push-option|--exec|--receive-pack) return 0 ;;
    *) return 1 ;;
  esac
}

# Percorre os tokens do segmento e escreve dois globais: REF, o refspec (última
# palavra que não seja opção, valor de opção, remoto conhecido ou o próprio
# git/push), e DIR_C, o argumento de `-C` quando houver. Um laço, e não o
# pipeline de `grep` anterior: filtro linha a linha não tem como olhar para o
# token ANTERIOR, e é exatamente disso que se trata aqui.
#
# Newline vira espaço antes de tokenizar: um push quebrado com `\` no fim da
# linha chega aqui em mais de uma linha, e `read -a` só leria a primeira.
#
# A divisão em palavras também descarta os tokens vazios que `sem_redirecao`
# deixa para trás — era o que o `grep -vE '^$'` do pipeline anterior fazia à mão,
# e esquecê-lo custou os quatro casos vermelhos de 2026-08-21. Quem trocar este
# laço por um pipeline outra vez precisa reintroduzir as duas coisas: o descarte
# do vazio e a leitura do token anterior.
extrai_ref() {
  local -a w
  read -r -a w <<< "$(sem_redirecao "$1" | tr '\n' ' ')"
  REF=""
  DIR_C=""
  local i=0
  while [ $i -lt ${#w[@]} ]; do
    if consome_proximo "${w[$i]}"; then
      if [ "${w[$i]}" = "-C" ]; then
        DIR_C="${w[$((i + 1))]:-}"
        # Aspas literais podem ter vindo junto no texto do comando; o shell as
        # comeria, este hook lê o texto cru.
        DIR_C="${DIR_C%[\"\']}"
        DIR_C="${DIR_C#[\"\']}"
      fi
      i=$((i + 2))
      continue
    fi
    case "${w[$i]}" in
      -*|git|push|origin|upstream) ;;
      *) REF="${w[$i]}" ;;
    esac
    i=$((i + 1))
  done
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

  extrai_ref "$SEG"

  # Push sem refspec empurra a branch atual — mas com `-C <dir>` a branch que
  # importa é a **do diretório**, não a de onde o comando foi digitado. Perguntar
  # à errada erra nas duas direções: nega a biblioteca parada em `claude/*`
  # porque a sessão está noutro lugar, e libera a vizinha parada em `main` porque
  # a sessão está em `claude/*`. A segunda é a perigosa.
  #
  # Quando o caminho não é legível daqui — `-C "$LIB"`, com a variável que só o
  # shell do agente sabe expandir, que é a forma prescrita pelo fechamento de
  # sessão — não há como saber, e vale a branch atual. O hook **não** expande
  # nada: `eval` sobre string vinda da ferramenta seria executar comando alheio
  # dentro do guardrail. Fica o limite, declarado: nesse caso o hook decide pela
  # sessão, não pelo destino. É a mesma classe de lacuna que o cabeçalho já
  # assume ao dizer que push por API ou MCP passa ao largo.
  if [ -z "$REF" ]; then
    local ALVO=""
    [ -n "$DIR_C" ] && [ -d "$DIR_C" ] \
      && ALVO=$(git -C "$DIR_C" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    [ -z "$ALVO" ] && ALVO=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    REF="$ALVO"
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
