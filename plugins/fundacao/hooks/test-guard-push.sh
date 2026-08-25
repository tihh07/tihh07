#!/usr/bin/env bash
# test-guard-push.sh — suíte de comportamento do guard-push.sh.
#
# Por que existe: um guardrail sem prova de que bloqueia é uma afirmação, não um
# controle. Até 2026-08-20 a suíte deste hook rodava só na máquina de quem o
# escreveu, e a documentação citava "11 casos" num lugar e "13" em outro — dois
# números para uma prova que ninguém podia repetir. Agora ela é versionada e roda
# em qualquer lugar que tenha bash e git.
#
# Uso:  bash plugins/fundacao/hooks/test-guard-push.sh
# Saída: uma linha por caso; exit 0 se todos passarem, 1 na primeira divergência
#        contada ao final (a suíte roda inteira antes de falhar).
#
# O que ela NÃO cobre: se o harness de fato chama o hook (isso é configuração de
# `.claude/settings.json`, não do script), o comportamento do git de verdade
# (nada é empurrado aqui), e push feito por API/MCP em vez do comando `git`.

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/guard-push.sh"
[ -x "$HOOK" ] || { echo "guard-push.sh não encontrado ou sem permissão de execução: $HOOK" >&2; exit 1; }

PASS=0
FAIL=0

# ---------------------------------------------------------------------------
# REPOSITÓRIO NEUTRO — por que a suíte não pode rodar onde foi chamada
# ---------------------------------------------------------------------------
# Quando o refspec sai vazio, o hook cai no fallback da branch atual. Rodando a
# suíte de dentro deste repositório, essa branch é `claude/*` — e o fallback
# LIBERA. Resultado: qualquer defeito que faça o refspec sumir vira um teste
# verde, porque o fallback resgata o caso pelo motivo errado.
#
# Não é hipótese. Em 2026-08-21 a correção de redirecionamento deixava tokens
# vazios no fim, `tail -1` devolvia string vazia, e os quatro casos de
# redirecionamento passavam **só** porque o checkout local estava numa branch
# `claude/*`. No runner do GitHub, onde o checkout de `pull_request` deixa o HEAD
# destacado, os mesmos quatro falharam. A suíte dizia 42/42 e não provava nada
# sobre eles.
#
# Por isso todo caso roda dentro de um repositório descartável cuja branch atual
# é `main`: se o refspec sumir, o fallback **bloqueia**, e o teste falha como
# deve. Os dois casos de fallback lá no fim continuam montando o próprio cenário,
# explicitamente, que é a única forma honesta de testá-lo.
#
# Falha fechada: sem repositório neutro a suíte não roda. Rodar no diretório
# ambiente reintroduz exatamente o falso verde descrito acima, e um resultado que
# depende de onde foi invocado não é resultado.
NEUTRO=$(mktemp -d 2>/dev/null) || NEUTRO=""
if [ -z "$NEUTRO" ] || ! git -C "$NEUTRO" init -q 2>/dev/null; then
  echo "FALHA: não foi possível criar o repositório neutro (mktemp/git init)." >&2
  echo "       A suíte não roda no diretório ambiente: o fallback da branch" >&2
  echo "       atual mascararia defeito de extração de refspec." >&2
  exit 1
fi
git -C "$NEUTRO" -c user.email=t@e -c user.name=t commit -q --allow-empty -m init 2>/dev/null
git -C "$NEUTRO" branch -M main 2>/dev/null
trap 'rm -rf "$NEUTRO"' EXIT

# Constrói {"tool_input":{"command":"..."}} escapando \ e " — sem depender de jq
# nem de python, que é justamente o que o hook precisa tolerar.
json_para() {
  # Escapa barra invertida, aspas e — o que faltava — quebra de linha: newline
  # literal dentro de string JSON é JSON inválido, e o hook a recusaria por falha
  # fechada, fazendo um caso legítimo parecer um bloqueio.
  printf '{"tool_input":{"command":"%s"}}' \
    "$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')"
}

# caso <esperado 0|2> <descrição> <comando> [diretório]
#
# O diretório é opcional e quase nunca se passa: por omissão todo caso roda no
# repositório neutro (branch `main`), nunca no diretório ambiente — ver o bloco
# NEUTRO acima para o porquê. Passa-se explicitamente só quando o cenário É a
# branch de onde o comando parte, que é o caso do fallback e o do `-C`.
caso() {
  local esperado="$1" desc="$2" cmd="$3" onde="${4:-$NEUTRO}" obtido
  obtido=0
  ( cd "$onde" && json_para "$cmd" | "$HOOK" >/dev/null 2>&1 ) || obtido=$?
  if [ "$obtido" -eq "$esperado" ]; then
    PASS=$((PASS + 1))
    printf '  ok    %s\n' "$desc"
  else
    FAIL=$((FAIL + 1))
    printf '  FALHA %s\n        esperado exit=%s, obtido exit=%s\n        comando: %s\n' \
      "$desc" "$esperado" "$obtido" "$cmd"
  fi
}

echo "guard-push — bloqueia (exit 2)"
caso 2 "push para main"                      'git push origin main'
caso 2 "push para master"                    'git push origin master'
caso 2 "HEAD:main"                           'git push origin HEAD:main'
caso 2 "refspec completo para main"          'git push origin HEAD:refs/heads/main'
caso 2 "main com --force"                    'git push origin main --force'
caso 2 "espaçamento múltiplo"                'git   push   origin   main'
caso 2 "git -C . push"                       'git -C . push origin main'
caso 2 "main depois de um claude/* legítimo" 'git push origin claude/x && git push origin main'
caso 2 "string claude/ como isca"            'echo claude/ && git push origin main'
caso 2 "force push, mesmo em claude/*"       'git push --force origin claude/x'
caso 2 "--force-with-lease"                  'git push --force-with-lease origin claude/x'
caso 2 "-f abreviado"                        'git push -f origin claude/x'
caso 2 "--delete"                            'git push --delete origin claude/x'
caso 2 "-d abreviado"                        'git push -d origin claude/x'
caso 2 "deleção por refspec vazio"           'git push origin :claude/x'
# Os três seguintes passavam (exit 0) antes de 2026-08-20: sem refspec, caíam no
# fallback de "branch atual", que numa sessão de agente é claude/*. Cada um
# alcança main ou apaga refs remotas sem nunca escrever a palavra.
caso 2 "--all empurra todas as branches"     'git push --all origin'
caso 2 "--mirror espelha o repositório"      'git push --mirror origin'
caso 2 "--prune apaga refs remotas"          'git push --prune origin claude/x'

# Falha fechada: entrada que o hook não consegue ler precisa bloquear, não
# liberar. Não passa pelo helper porque o helper produz JSON válido por
# construção — o objetivo aqui é justamente entregar lixo.
printf 'isto nao e json' | "$HOOK" >/dev/null 2>&1
if [ $? -eq 2 ]; then
  PASS=$((PASS + 1)); echo "  ok    entrada ilegível (falha fechada)"
else
  FAIL=$((FAIL + 1)); echo "  FALHA entrada ilegível — esperado exit=2"
fi

echo
echo "guard-push — libera (exit 0)"
caso 0 "claude/* explícito"                  'git push origin claude/x'
caso 0 "-u origin claude/*"                  'git push -u origin claude/x'
caso 0 "HEAD:claude/*"                       'git push origin HEAD:claude/x'
caso 0 "--tags com claude/*"                 'git push --tags origin claude/x'
caso 0 "main local para claude/* remoto"     'git push origin main:claude/x'
caso 0 "não é push: ls"                      'ls -la'
caso 0 "não é push: git status"              'git status'
caso 0 "não é push: comando que cita push"   'echo "não faça git pushes"'

# Regressões de 2026-08-20. A detecção varria a string inteira do comando, então
# qualquer prosa que contivesse "git ... push" bloqueava: a mensagem de um commit
# sobre o próprio guardrail, um heredoc que gerasse um script, um exemplo em
# documentação. Guardrail que nega demais convida à desinstalação.
caso 0 "commit cuja mensagem cita push"       'git commit -m "wire the push hook"'

# Regressão de 2026-08-21. O segmentador quebra em `&`, então `2>&1` vira o token
# `2>`, e a extração de refspec — última palavra que não é flag — o lia como
# destino: um push legítimo para claude/* era negado com "destino '2>' fora de
# claude/*". Guardrail que nega o caminho que ele existe para permitir gasta a
# confiança que faz alguém mantê-lo instalado.
caso 0 "redirecionamento 2>&1 no fim"         'git push -u origin claude/x 2>&1 | tail -3'
caso 0 "saída para arquivo"                   'git push origin claude/x > /tmp/log'
caso 0 "stderr para arquivo, colado"          'git push origin claude/x 2>/tmp/err'
caso 0 "descarte de saída"                    'git push -u origin claude/x >/dev/null 2>&1'

# E a limpeza não pode virar rota de fuga: o alvo proibido continua proibido
# quando cercado de redirecionamento.
caso 2 "main com redirecionamento"            'git push origin main 2>&1 | tail -3'
caso 2 "main com saída descartada"            'git push origin main >/dev/null'
caso 2 "force em claude/* com redirect"       'git push --force origin claude/x 2>&1'
caso 0 "opção global antes de um não-push"    'git -c user.name=t commit -m "push guardrail"'
caso 0 "corpo de heredoc não é comando"       'cat <<EOF
git push origin main
EOF'
caso 0 "segmento liberado seguido de prosa"   'git push origin claude/x && echo main'
# E o simétrico: opção global não pode esconder um push de verdade.
caso 2 "--no-pager não esconde o push"        'git --no-pager push origin main'
caso 2 "opção global com valor antes do push" 'git -c core.pager=cat push origin main'

# O caso do fallback só é honesto num repositório onde a branch atual NÃO é
# claude/*: é lá que "push sem refspec" precisa bloquear. Monta um repo
# descartável para não depender de onde a suíte foi chamada.
echo
echo "guard-push — push sem refspec depende da branch atual"
TMP=$(mktemp -d 2>/dev/null) || TMP=""
if [ -n "$TMP" ] && git -C "$TMP" init -q 2>/dev/null; then
  # Precisa de um commit: numa branch ainda não-nascida o `git rev-parse` do hook
  # falha, o refspec sai vazio e o bloqueio acontece pelo motivo errado — o teste
  # ficaria verde sem provar nada.
  git -C "$TMP" -c user.email=t@e -c user.name=t commit -q --allow-empty -m init 2>/dev/null
  git -C "$TMP" branch -M main 2>/dev/null
  (cd "$TMP" && json_para 'git push' | "$HOOK" >/dev/null 2>&1)
  if [ $? -eq 2 ]; then
    PASS=$((PASS + 1)); echo "  ok    'git push' na branch main"
  else
    FAIL=$((FAIL + 1)); echo "  FALHA 'git push' na branch main — esperado exit=2"
  fi
  git -C "$TMP" checkout -q -b claude/x 2>/dev/null
  (cd "$TMP" && json_para 'git push' | "$HOOK" >/dev/null 2>&1)
  if [ $? -eq 0 ]; then
    PASS=$((PASS + 1)); echo "  ok    'git push' na branch claude/x"
  else
    FAIL=$((FAIL + 1)); echo "  FALHA 'git push' na branch claude/x — esperado exit=0"
  fi
  rm -rf "$TMP"
else
  echo "  pulado: não foi possível criar repositório temporário"
fi

# ---------------------------------------------------------------------------
# `-C <dir>` — a branch que importa é a DO DIRETÓRIO
# ---------------------------------------------------------------------------
# Defeito medido em 2026-08-25: a extração de refspec descartava o que começa com
# `-`, mas não o ARGUMENTO das opções que levam valor. Em `git -C "$LIB" push` o
# `-C` sumia e o caminho ficava sendo a última palavra não-flag, isto é, o
# "destino" — e o hook negava um push para `claude/*` legítimo, pelo caminho que
# o passo 4a do fechamento de sessão prescreve.
#
# A suíte passava 42/42 e nunca tinha exercitado `git -C`. Suíte verde sobre um
# caminho que o hook erra: correção sem caso novo não fecha nada.
echo
echo "guard-push — \`-C <dir>\`: a branch que importa é a do diretório"
LIB_C=$(mktemp -d 2>/dev/null) || LIB_C=""
LIB_M=$(mktemp -d 2>/dev/null) || LIB_M=""
SESSAO=$(mktemp -d 2>/dev/null) || SESSAO=""
if [ -n "$LIB_C" ] && [ -n "$LIB_M" ] && [ -n "$SESSAO" ] \
   && git -C "$LIB_C" init -q 2>/dev/null \
   && git -C "$LIB_M" init -q 2>/dev/null \
   && git -C "$SESSAO" init -q 2>/dev/null; then
  for D in "$LIB_C" "$LIB_M" "$SESSAO"; do
    git -C "$D" -c user.email=t@e -c user.name=t commit -q --allow-empty -m init 2>/dev/null
  done
  # Três cenários: uma biblioteca parada em claude/*, uma parada em main, e a
  # sessão de onde o comando parte, também em claude/*.
  git -C "$LIB_C" branch -M claude/lib 2>/dev/null
  git -C "$LIB_M" branch -M main 2>/dev/null
  git -C "$SESSAO" branch -M claude/sessao 2>/dev/null

  # O caso medido, na forma que dá para resolver: diretório legível, branch
  # claude/*, sessão em `main`. Sem a correção o caminho vira o "destino".
  caso 0 "git -C <dir em claude/*> push"        "git -C $LIB_C push"
  caso 0 "git -C <dir> push origin claude/*"    "git -C $LIB_C push origin claude/x"
  caso 2 "git -C <dir> push origin main"        "git -C $LIB_M push origin main"
  caso 2 "git -C <dir> com --force"             "git -C $LIB_C push --force origin claude/x"

  # E o simétrico, que é o lado perigoso: a sessão estar em claude/* não pode
  # liberar o repositório vizinho parado em `main`. Antes da correção este caso
  # bloqueava pelo motivo errado — o caminho lido como destino; agora bloqueia
  # porque a branch do diretório é `main`.
  caso 2 "git -C <dir em main> push, de claude/*" "git -C $LIB_M push" "$SESSAO"

  # `-C "$LIB"`: a variável só o shell do agente expande, e o hook lê o texto
  # cru — não há como saber a branch do destino. Vale a branch da sessão, que é
  # o que o hook já fazia. Limite declarado, testado nas duas direções.
  caso 0 "-C não expansível, sessão em claude/*"  'git -C "$LIB" push' "$SESSAO"
  caso 2 "-C não expansível, sessão em main"      'git -C "$LIB" push'

  rm -rf "$LIB_C" "$LIB_M" "$SESSAO"
else
  echo "  pulado: não foi possível criar os repositórios temporários"
  rm -rf "$LIB_C" "$LIB_M" "$SESSAO"
fi

# As outras opções que levam valor separado têm o mesmo defeito e a mesma
# correção. Rodam a partir de um checkout claude/* porque é lá que a diferença
# aparece: com o valor lido como destino o hook nega; descartado o valor, o
# refspec some e o fallback decide — e decide certo.
VALOR=$(mktemp -d 2>/dev/null) || VALOR=""
if [ -n "$VALOR" ] && git -C "$VALOR" init -q 2>/dev/null; then
  git -C "$VALOR" -c user.email=t@e -c user.name=t commit -q --allow-empty -m init 2>/dev/null
  git -C "$VALOR" branch -M claude/sessao 2>/dev/null
  caso 0 "-o <opção> não é destino"             'git push -o ci.variable=1' "$VALOR"
  caso 0 "--push-option <opção> não é destino"  'git push --push-option ci.variable=1' "$VALOR"
  caso 0 "--repo <repositório> não é destino"   'git push --repo git@host:x/y.git' "$VALOR"
  caso 0 "--receive-pack <caminho> não é destino" 'git push --receive-pack /usr/bin/git-receive-pack' "$VALOR"
  # E nenhuma delas vira rota de fuga: o alvo proibido continua proibido.
  caso 2 "-o não esconde main"                  'git push -o ci.variable=1 origin main' "$VALOR"
  caso 2 "--repo não esconde main"              'git push --repo git@host:x/y.git origin main' "$VALOR"
  rm -rf "$VALOR"
else
  echo "  pulado: não foi possível criar repositório temporário"
fi

echo
echo "$PASS passaram, $FAIL falharam"
[ "$FAIL" -eq 0 ]
