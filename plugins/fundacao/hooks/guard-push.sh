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
# Lê o comando com um extrator em bash puro e, quando ele não tem certeza, com
# jq ou com o módulo json do Python — ambos stdlib do ambiente, nenhum pacote a
# instalar. Numa máquina Windows sem jq a versão de 2026-08-19 bloqueava TODO
# push, inclusive os claude/* que deve liberar: guardrail que nega tudo é
# indistinguível de guardrail quebrado, e convida a desinstalação. Falha fechada
# continua valendo — entrada que não tem a forma de um envelope JSON bloqueia, e
# entrada que nenhum dos leitores decifra bloqueia.
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
#
# ---------------------------------------------------------------------------
# CUSTO — por que quase nada aqui cria processo
# ---------------------------------------------------------------------------
# Este hook é PreToolUse em `Bash`: roda em TODA chamada de terminal da sessão,
# inclusive `ls`. O custo dele não é do push, é de tudo.
#
# Medido em 2026-08-25, numa máquina Windows (MINGW64, bash 5.3), mediana de
# repetições — criar um processo ali custa de 0,5 a 1,3 s, e a versão anterior
# criava cinco no caminho que nem é push:
#
#     estágio                          processo    mediana
#     INPUT=$(cat)                     cat           948 ms
#     leia_comando                     python3      3994 ms
#     sem_heredoc                      awk          1000 ms
#     segmentador                      sed          1251 ms
#     trim por segmento                sed          1163 ms
#
# O `python3` dominava porque `jq` não existe na máquina e o `python3` do PATH é
# o stub de app-execution-alias da Microsoft Store. Total medido do hook: ~5,3 s
# para `ls -la` e ~8,4 s para um push legítimo. A suíte de casos, que roda o hook
# uma vez por caso, deixou de terminar em dez minutos — e suíte que não termina
# na máquina de quem mantém o repositório é indistinguível de suíte que não roda.
#
# Nada disso era lógica lenta: era criação de processo. Então o caminho inteiro
# passou a usar expansão de parâmetro, `case` e `[[ =~ ]]`, que são builtins.
# Sobraram dois processos POSSÍVEIS, os dois fora do caminho comum: o
# `git rev-parse` do fallback de branch (só em push sem refspec) e o leitor
# externo de JSON (só quando o extrator puro defere).
#
# A regra para quem editar isto: **não reintroduza pipe para `sed`, `grep`,
# `awk` ou `tr`**. Num Windows com antivírus varrendo cada processo, cada um
# custa perto de um segundo, cobrado de toda chamada de terminal da sessão.

set -uo pipefail

# Globbing desligado no arquivo inteiro. A tokenização usa `w=( $seg )`, que é
# divisão de palavras sem processo e sem arquivo temporário — mas sem `-f` um
# `*` no comando inspecionado viraria a lista de arquivos do diretório corrente,
# e o hook passaria a decidir sobre um comando que ninguém escreveu.
set -f

deny() {
  echo "guard-push: $1" >&2
  echo "Sessões de agente só empurram para branches claude/*. Push direto em main é bloqueado; merge é por PR." >&2
  exit 2
}

# `read` builtin no lugar de `$(cat)`: mesma leitura, um processo a menos. O
# `-d ''` lê até o fim da entrada e devolve 1 no EOF mesmo tendo lido tudo.
INPUT=""
IFS= read -r -d '' INPUT || true
INPUT="${INPUT#"${INPUT%%[![:space:]]*}"}"
INPUT="${INPUT%"${INPUT##*[![:space:]]}"}"

# Falha fechada, sem processo: o hook recebe um objeto JSON. O que não tem essa
# forma não é decifrável por nenhum dos leitores abaixo, e o bloqueio que a
# versão anterior só descobria depois de gastar um `python3` é decidido aqui.
case "$INPUT" in
  '{'*'}') ;;
  *) deny "entrada ilegível; bloqueando por precaução." ;;
esac

# Atalho de custo zero para o caso esmagadoramente mais comum: a sessão chamando
# `ls`, `cat`, `grep`, `git status`. A trava só nega quando algum segmento é um
# `git push`, e `e_um_push` exige o token literal `push` — logo, sem os bytes
# `push` na entrada crua, não há o que decidir.
#
# `\u` é a única forma de o JSON escrever uma letra ASCII sem escrevê-la: se
# aparecer, o atalho se desliga e a leitura completa acontece. O atalho não pode
# afrouxar nada — ele só devolve 0 onde o caminho completo provadamente também
# devolveria 0.
case "$INPUT" in
  *push*|*'\u'*|*'\U'*) ;;
  *) exit 0 ;;
esac

# ---------------------------------------------------------------------------
# LEITURA DE `.tool_input.command`
# ---------------------------------------------------------------------------
# Duas camadas. A primeira é um extrator em bash puro, sem processo nenhum. A
# segunda são jq e python, como antes.
#
# O extrator puro só responde quando tem certeza; em qualquer forma que ele não
# reconheça, defere. **Deferir é sempre seguro e adivinhar não é**: um extrator
# que devolve a string errada faz o hook decidir sobre um comando que não é o
# comando, e essa é a única forma de uma otimização virar buraco na política.
#
# A certeza que importa é uma só: casar `"command"` em POSIÇÃO DE CHAVE, nunca
# dentro do valor de outro campo. Sem isso, um `description` forjado como
#     {"description":"x\"command\": \"echo ok\"","command":"git push origin main"}
# faria o hook inspecionar `echo ok` e liberar o push. A regra que fecha isso é
# exata, não heurística: dentro de uma string JSON toda aspa é obrigatoriamente
# escapada, então a aspa que abre uma CHAVE de verdade é sempre precedida (fora
# brancos) por `{` ou `,`, e a forjada é sempre precedida por `\`.

# Aponta RESTO para o texto logo depois de `"<chave>":`, e só quando a ocorrência
# está em posição de chave. Segue para as ocorrências seguintes se a primeira
# não estiver.
acha_chave() {
  local txt="$1" alvo="\"$2\"" antes depois a d
  RESTO=""
  while :; do
    case "$txt" in *"$alvo"*) ;; *) return 1 ;; esac
    antes="${txt%%"$alvo"*}"
    depois="${txt#*"$alvo"}"
    txt="$depois"
    a="${antes%"${antes##*[![:space:]]}"}"
    case "${a: -1}" in
      '{'|',') ;;
      *) continue ;;
    esac
    d="${depois#"${depois%%[![:space:]]*}"}"
    [ "${d:0:1}" = ":" ] || continue
    d="${d:1}"
    RESTO="${d#"${d%%[![:space:]]*}"}"
    return 0
  done
}

# Lê a string JSON que começa em $1[0] == aspa e escreve VALOR já sem escapes.
# Devolve 1 em tudo que não souber tratar — `\uXXXX`, escape desconhecido,
# string não fechada — para o leitor externo decidir.
#
# `\uXXXX` defere DE PROPÓSITO, mesmo sendo trivial de decodificar com
# `printf -v c "\\u$hex"`: esse `\u` do printf só existe a partir do bash 4.2, e
# este arquivo é distribuído pelo plugin-fundação para máquinas que este
# repositório não escolhe — o bash de fábrica do macOS ainda é 3.2. Lá o escape
# ficaria literal, `git push origin main` não casaria o token `push`, e um
# push para `main` seria LIBERADO. Otimização que depende da versão do
# interpretador para não abrir buraco na política não é otimização; é aposta.
# Deferir custa um processo num caso que o harness não produz.
le_string() {
  local t="$1" bruto="" pedaco barras res="" c
  [ "${t:0:1}" = '"' ] || return 1
  t="${t:1}"
  while :; do
    case "$t" in *'"'*) ;; *) return 1 ;; esac
    pedaco="${t%%'"'*}"
    t="${t#*'"'}"
    # Aspa precedida de um número ÍMPAR de barras está escapada: a string segue.
    barras="${pedaco##*[!\\]}"
    if [ $(( ${#barras} % 2 )) -eq 1 ]; then
      bruto+="$pedaco"'"'
      continue
    fi
    bruto+="$pedaco"
    break
  done
  while :; do
    case "$bruto" in *\\*) ;; *) res+="$bruto"; break ;; esac
    res+="${bruto%%\\*}"
    bruto="${bruto#*\\}"
    c="${bruto:0:1}"
    bruto="${bruto:1}"
    case "$c" in
      '"') res+='"' ;;
      '\') res+='\' ;;
      '/') res+='/' ;;
      n) res+=$'\n' ;;
      t) res+=$'\t' ;;
      r) res+=$'\r' ;;
      b) res+=$'\b' ;;
      f) res+=$'\f' ;;
      *) return 1 ;;
    esac
  done
  VALOR="$res"
  return 0
}

extrai_command_puro() {
  local dentro
  acha_chave "$INPUT" tool_input || return 1
  dentro="$RESTO"
  [ "${dentro:0:1}" = "{" ] || return 1
  acha_chave "$dentro" command || return 1
  le_string "$RESTO" || return 1
  CMD="$VALOR"
  return 0
}

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

CMD=""
if ! extrai_command_puro; then
  CMD=$(leia_comando) || {
    [ $? -eq 2 ] || echo "guard-push: entrada ilegível; bloqueando por precaução." >&2
    exit 2
  }
fi

# Mesmo atalho de antes, agora sobre o comando já decifrado — cobre o caso em
# que os bytes `push` estavam noutro campo do envelope, ou vieram escapados.
case "$CMD" in *push*) ;; *) exit 0 ;; esac

# Corpo de heredoc é DADO, não comando. Uma mensagem de commit escrita via
# `<<EOF` pode citar comandos de exemplo, e um script gerado por heredoc pode
# conter linhas inteiras deles; nada disso é executado pelo shell que estamos
# inspecionando. Sem descartar esses corpos, o hook nega trabalho legítimo — foi
# o que aconteceu em 2026-08-20, quando uma mensagem de commit que mencionava o
# próprio guardrail passou a bloquear o commit que a carregava.
#
# Era um `awk`; virou laço de bash pelo motivo do cabeçalho. A máquina de estados
# é a mesma: fora do corpo, copia a linha e procura a abertura; dentro, só
# procura o marcador de fim, comparado sem o recuo que `<<-` permite.
sem_heredoc() {
  local resto="$1" linha marca="" dentro=0 out="" l
  local aspa=\" apos=\'
  local re="<<-?[[:blank:]]*(${aspa}[^${aspa}]+${aspa}|${apos}[^${apos}]+${apos}|[A-Za-z_][A-Za-z0-9_]*)"
  while [ -n "$resto" ]; do
    linha="${resto%%$'\n'*}"
    if [ "$linha" = "$resto" ]; then resto=""; else resto="${resto#*$'\n'}"; fi
    if [ "$dentro" -eq 1 ]; then
      l="${linha#"${linha%%[![:space:]]*}"}"
      [ "$l" = "$marca" ] && dentro=0
      continue
    fi
    out+="$linha"$'\n'
    if [[ $linha =~ $re ]]; then
      marca="${BASH_REMATCH[1]}"
      marca="${marca//\"/}"
      marca="${marca//\'/}"
      dentro=1
    fi
  done
  SEM_HD="${out%$'\n'}"
}

sem_heredoc "$CMD"
CMD="$SEM_HD"

# Um comando pode encadear vários segmentos (`a && b`, `a; b`, `a | b`). Cada um
# é avaliado por si: o que interessa é se ALGUM deles é um `git push`, e as
# travas se aplicam ao segmento que é, não à string inteira.
#
# Varrer a string inteira era o desenho anterior, e ele negava trabalho legítimo:
# um `git commit` cuja mensagem mencionasse a palavra "push" — dentro de um
# heredoc, longe de qualquer comando — casava com o padrão e era bloqueado.
# Guardrail que nega demais é indistinguível de guardrail quebrado, e convida à
# desinstalação; está escrito no cabeçalho deste arquivo e vale para ele mesmo.

# Verdadeiro quando o segmento é um `git push`: depois de `git`, só podem vir
# opções globais antes do subcomando. Assim `git -c k=v commit` não é push, e
# `git --no-pager push` é.
e_um_push() {
  local -a w=( $1 )
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
#
# Era um `sed -E ... /g`; virou laço sobre `[[ =~ ]]`, que aplica a MESMA ERE
# POSIX (leftmost-longest) sem criar processo. O laço repete enquanto houver
# casamento, que é o que o `/g` fazia.
RE_REDIR='[0-9]*(>>|>|<)[[:space:]]*(&[0-9-]+)?[^[:space:]]*'
sem_redirecao() {
  local s="$1" out="" m
  while [[ $s =~ $RE_REDIR ]]; do
    m="${BASH_REMATCH[0]}"
    [ -n "$m" ] || break
    out+="${s%%"$m"*} "
    s="${s#*"$m"}"
  done
  SEM_RED="$out$s"
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
# linha chega aqui em mais de uma linha, e a tokenização só leria a primeira.
#
# A divisão em palavras também descarta os tokens vazios que `sem_redirecao`
# deixa para trás — era o que o `grep -vE '^$'` do pipeline anterior fazia à mão,
# e esquecê-lo custou os quatro casos vermelhos de 2026-08-21. Quem trocar este
# laço por um pipeline outra vez precisa reintroduzir as duas coisas: o descarte
# do vazio e a leitura do token anterior.
extrai_ref() {
  sem_redirecao "$1"
  local -a w=( ${SEM_RED//$'\n'/ } )
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

# As quatro travas eram `printf | grep -qE`; viraram `[[ =~ ]]` com a MESMA ERE
# POSIX. O `$` do bash ancora no fim da string e o do grep ancorava no fim da
# linha — dá no mesmo aqui, porque o segmentador já quebrou em newline e nenhum
# segmento tem uma.
RE_FORCE='(--force([^-]|$)|--force-with-lease|[[:space:]]-f([[:space:]]|$))'
RE_DELETE='(--delete|[[:space:]]-d([[:space:]]|$)|[[:space:]]:[A-Za-z0-9._/-]+)'
RE_PROTEGIDA='[[:space:]](main|master|develop)([[:space:]]|$)|:(main|master|develop)([[:space:]]|$)'
RE_REPO_INTEIRO='(--all|--mirror|--prune)([[:space:]]|$)'

verifica_segmento() {
  local SEG="$1"

  # Force push destrói histórico remoto — nunca, nem em claude/*.
  [[ $SEG =~ $RE_FORCE ]] && deny "force push bloqueado."

  # Deleção de branch remota.
  [[ $SEG =~ $RE_DELETE ]] && deny "deleção de branch remota bloqueada."

  # Alvos proibidos, mesmo que "claude" apareça em outro ponto do segmento.
  [[ $SEG =~ $RE_PROTEGIDA ]] && deny "push direto para branch protegida bloqueado."

  # Modos que empurram o repositório inteiro, sem refspec nenhum. Sem esta trava
  # caem no fallback de "branch atual" abaixo, que numa sessão de agente é
  # claude/* — e passam. Mas `--all` empurra TODAS as branches locais, `main`
  # inclusive, `--mirror` espelha o repositório (apagando refs remotas que não
  # existam mais no local) e `--prune` apaga remotas diretamente. Os três fazem o
  # que as travas acima proíbem, por um caminho que elas não olham.
  [[ $SEG =~ $RE_REPO_INTEIRO ]] && deny "push de repositório inteiro (--all/--mirror/--prune) bloqueado."

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
  #
  # É o único ponto do hook que ainda cria processo no caminho de push, e está
  # aqui porque não há builtin que responda "qual é a branch atual" — nem
  # deveria haver: a resposta é do git, não do shell.
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

# O segmentador era `sed -E 's/(\|\||&&|;|\||&)/\n/g'`. Substituir na ordem
# `||`, `&&`, `;`, `|`, `&` dá o mesmo resultado sem criar processo: quando os
# pares já viraram newline, o que sobra de `|` e `&` é necessariamente simples.
SEGS="${CMD//\|\|/$'\n'}"
SEGS="${SEGS//&&/$'\n'}"
SEGS="${SEGS//;/$'\n'}"
SEGS="${SEGS//|/$'\n'}"
SEGS="${SEGS//&/$'\n'}"

while [ -n "$SEGS" ]; do
  SEG="${SEGS%%$'\n'*}"
  if [ "$SEG" = "$SEGS" ]; then SEGS=""; else SEGS="${SEGS#*$'\n'}"; fi
  SEG="${SEG#"${SEG%%[![:space:]]*}"}"
  SEG="${SEG%"${SEG##*[![:space:]]}"}"
  [ -n "$SEG" ] || continue
  e_um_push "$SEG" && verifica_segmento "$SEG"
done

# Nenhum segmento era um push: nada a decidir.
exit 0
