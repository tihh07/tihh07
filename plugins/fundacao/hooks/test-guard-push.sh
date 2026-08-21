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

# Constrói {"tool_input":{"command":"..."}} escapando \ e " — sem depender de jq
# nem de python, que é justamente o que o hook precisa tolerar.
json_para() {
  # Escapa barra invertida, aspas e — o que faltava — quebra de linha: newline
  # literal dentro de string JSON é JSON inválido, e o hook a recusaria por falha
  # fechada, fazendo um caso legítimo parecer um bloqueio.
  printf '{"tool_input":{"command":"%s"}}' \
    "$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')"
}

# caso <esperado 0|2> <descrição> <comando>
caso() {
  local esperado="$1" desc="$2" cmd="$3" obtido
  json_para "$cmd" | "$HOOK" >/dev/null 2>&1
  obtido=$?
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

echo
echo "$PASS passaram, $FAIL falharam"
[ "$FAIL" -eq 0 ]
