#!/usr/bin/env bash
# medir-actions.sh — mede onde os minutos de GitHub Actions estão sendo gastos,
# por workflow e por repositório. **Somente leitura: não altera nada.**
#
# ---------------------------------------------------------------------------
# POR QUE ESTE SCRIPT EXISTE
# ---------------------------------------------------------------------------
# O item C1 do backlog abriu com um alerta de cota a 90% e passou o dia inteiro
# com o culpado errado — duas vezes. A primeira acusou um workflow que este
# repositório distribuía; um `find` mostrou que ele nem era distribuído. A
# segunda acusou cron diário; a medição parcial apontou custo por *commit*, que
# é mecanismo oposto.
#
# O padrão dos dois erros é o mesmo: **mecanismo plausível afirmado sem medir.**
# Este script existe para acabar com a categoria. Ele não opina sobre causa —
# devolve minutos por workflow, ordenados, e deixa a conclusão para quem lê.
#
# **Não aplique otimização nenhuma antes de rodar isto.** É literalmente o que o
# C1 manda, e é a lição que ele custou.
#
# ---------------------------------------------------------------------------
# ONDE RODAR
# ---------------------------------------------------------------------------
# Num Codespace, no terminal da sua máquina, ou em qualquer lugar com bash,
# curl e python3. **Não precisa de token especial**: o `GITHUB_TOKEN` que o
# Codespace já injeta costuma bastar para leitura. Se faltar permissão em algum
# repositório, o script diz qual e segue — não falha o lote inteiro.
#
# Detalhe verificado em 2026-08-21, para ninguém ler zero como defeito:
# repositório **público** devolve `billable` vazio com HTTP 200, porque Actions é
# gratuito ali. Conferido neste repositório — três workflows, três respostas 200,
# zero minutos. Zero é resultado, não falha.
#
# Se a sua rede passa por um proxy que intercepta TLS, o curl com schannel pode
# não conseguir checar a revogação do certificado e devolver HTTP 000, sem
# resposta nenhuma. O script repete a chamada uma vez com `--ssl-no-revoke` — que
# desliga só essa checagem, não a validação da cadeia — e avisa em stderr sempre
# que precisa fazer isso.
#
# Uso:
#   bash medir-actions.sh                    # todos os privados
#   bash medir-actions.sh --todos            # inclui públicos
#   bash medir-actions.sh --repo a --repo b  # só nesses
#
# O que a API devolve é o **tempo faturável do período de cobrança corrente**,
# por workflow, somado por sistema operacional. Windows e macOS custam mais que
# Ubuntu por minuto — o script mostra os três separados, porque somá-los
# esconde exatamente o que encarece.

set -uo pipefail

API="https://api.github.com"
INCLUIR_PUBLICOS=0
ALVOS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --todos) INCLUIR_PUBLICOS=1; shift ;;
    --repo)  [ $# -ge 2 ] || { echo "--repo exige um nome de repositório" >&2; exit 2; }
             ALVOS+=("$2"); shift 2 ;;
    -h|--help) sed -n '2,48p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "argumento desconhecido: $1" >&2; exit 2 ;;
  esac
done

TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
[ -n "$TOKEN" ] || {
  echo "Nenhum token encontrado (GH_TOKEN ou GITHUB_TOKEN)." >&2
  echo "Num Codespace ele já vem definido. Fora dele, exporte um com leitura de Actions." >&2
  exit 1
}
command -v curl >/dev/null || { echo "curl não encontrado" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 não encontrado" >&2; exit 1; }

# HTTP 000 significa "nenhuma resposta chegou", e aqui ele tem duas causas que
# se parecem: o proxy que intercepta TLS desta rede, cujo schannel às vezes não
# consegue checar a revogação do certificado (CRYPT_E_NO_REVOCATION_CHECK), e
# URL malformada pelo \r do python no Windows (ver o comentário logo abaixo).
# O retry só resolve a primeira, mas o script não sabe distinguir as duas daqui
# — por isso o aviso fala em "sem resposta", não em "TLS".
#
# `--ssl-no-revoke` desliga SÓ a checagem de revogação; a validação da cadeia
# continua valendo. E o aviso sai em stderr toda vez, de propósito: enfraquecer
# verificação de certificado em silêncio é como isso vira o padrão da casa.
api() {
  local resp
  resp=$(curl -sS -w '\n%{http_code}' \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$API$1")
  if [ "${resp##*$'\n'}" = "000" ]; then
    echo "AVISO: sem resposta HTTP; repetindo uma vez com --ssl-no-revoke." >&2
    resp=$(curl -sS --ssl-no-revoke -w '\n%{http_code}' \
      -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "$API$1")
  fi
  printf '%s' "$resp"
}

# O `tr -d '\r'` que aparece depois de cada python3 daqui em diante não é
# supersticioso. No Windows, o python nativo abre stdout em modo texto e troca
# cada \n por \r\n; o bash então lê nomes com um \r colado no fim, e o \r vai
# parar DENTRO da URL — que a API recusa com "Malformed input to a URL
# function", HTTP 000, em todos os repositórios. Foi o que aconteceu em
# 2026-08-24: a medição inteira do C1 voltou vazia por isso, e o zero foi lido
# como "nenhum minuto faturável" em vez de "nenhuma requisição saiu".
#
# O diagnóstico deste portão separa rede de credencial. Até 2026-08-24 ele
# chamava qualquer falha de "token inválido", e na medição daquele dia mandou
# trocar uma credencial que estava boa: o token era o mesmo que listara os
# repositórios segundos antes, e o que faltava era o retry de TLS acima.
resp=$(api /user)
corpo=${resp%$'\n'*}; codigo=${resp##*$'\n'}
if [ "$codigo" != "200" ]; then
  case "$codigo" in
    000) echo "GET /user não obteve resposta (HTTP 000), nem no retry." >&2
         echo "Isso é rede, não credencial: proxy, DNS ou TLS. O token não foi recusado." >&2 ;;
    401|403) echo "GET /user recusado (HTTP $codigo): token inválido ou sem escopo de leitura." >&2 ;;
    *) echo "GET /user falhou (HTTP $codigo)." >&2 ;;
  esac
  exit 1
fi
DONO=$(printf '%s' "$corpo" | python3 -c "
import json,sys
print(json.load(sys.stdin).get('login',''))" | tr -d '\r')
[ -n "$DONO" ] || { echo "GET /user devolveu 200 sem campo 'login'." >&2; exit 1; }
echo "Conta: $DONO"

if [ ${#ALVOS[@]} -eq 0 ]; then
  pagina=1
  while :; do
    resp=$(api "/user/repos?per_page=100&page=$pagina&affiliation=owner")
    corpo=${resp%$'\n'*}; codigo=${resp##*$'\n'}
    [ "$codigo" = "200" ] || { echo "falha ao listar repositórios (HTTP $codigo)" >&2; exit 1; }
    nomes=$(printf '%s' "$corpo" | INCLUIR_PUBLICOS="$INCLUIR_PUBLICOS" python3 -c "
import json,sys,os
pub = os.environ.get('INCLUIR_PUBLICOS') == '1'
for r in json.load(sys.stdin):
    if r.get('archived'): continue
    if r.get('private') or pub: print(r['name'])" | tr -d '\r')
    [ -z "$nomes" ] && break
    while IFS= read -r n; do [ -n "$n" ] && ALVOS+=("$n"); done <<< "$nomes"
    pagina=$((pagina + 1))
  done
fi
[ ${#ALVOS[@]} -gt 0 ] || { echo "nenhum repositório encontrado." >&2; exit 1; }

LINHAS=$(mktemp) || { echo "mktemp falhou" >&2; exit 1; }
trap 'rm -f "$LINHAS"' EXIT

echo "Medindo ${#ALVOS[@]} repositório(s). Somente leitura."
echo

SEM_ACESSO=0
SEM_WORKFLOW=0
COM_WORKFLOW=0
for repo in "${ALVOS[@]}"; do
  resp=$(api "/repos/$DONO/$repo/actions/workflows?per_page=100")
  corpo=${resp%$'\n'*}; codigo=${resp##*$'\n'}
  if [ "$codigo" != "200" ]; then
    printf '  %-34s sem leitura de Actions (HTTP %s)\n' "$repo" "$codigo"
    SEM_ACESSO=$((SEM_ACESSO + 1)); continue
  fi
  ids=$(printf '%s' "$corpo" | python3 -c "
import json,sys
for w in json.load(sys.stdin).get('workflows',[]):
    # Workflow desativado ainda carrega o gasto que já fez neste período.
    print('%s\t%s' % (w['id'], w.get('name','(sem nome)')))" | tr -d '\r')
  # Repositório sem workflow nenhum e repositório que rodou e custou zero somem
  # do mesmo jeito na soma, e até 2026-08-24 este `continue` não distinguia os
  # dois. A conta importa: um total zero só é achado se houver repositório com
  # workflow por trás dele. Sem isso, "nenhum minuto faturável" pode significar
  # "nada gastou" ou "não havia o que medir", e foi essa a dúvida que sobrou da
  # medição do C1.
  if [ -z "$ids" ]; then
    SEM_WORKFLOW=$((SEM_WORKFLOW + 1)); continue
  fi
  COM_WORKFLOW=$((COM_WORKFLOW + 1))
  while IFS=$'\t' read -r wid wnome; do
    [ -n "$wid" ] || continue
    r2=$(api "/repos/$DONO/$repo/actions/workflows/$wid/timing")
    c2=${r2%$'\n'*}; k2=${r2##*$'\n'}
    [ "$k2" = "200" ] || continue
    printf '%s' "$c2" | REPO="$repo" WF="$wnome" python3 -c "
import json,sys,os
d=json.load(sys.stdin).get('billable',{}) or {}
for so,v in d.items():
    ms=v.get('total_ms',0) or 0
    if ms: print('%s\t%s\t%s\t%.1f' % (os.environ['REPO'], os.environ['WF'], so, ms/60000.0))" | tr -d '\r' >> "$LINHAS"
  done <<< "$ids"
done

echo
if [ ! -s "$LINHAS" ]; then
  echo "Nenhum minuto faturável no período corrente — em nenhum repositório lido."
  printf 'Repositórios com pelo menos um workflow, efetivamente medidos: %d de %d.\n' \
    "$COM_WORKFLOW" "${#ALVOS[@]}"
  echo "Isso é resultado, não falha: se a cota está alta e nada aparece aqui,"
  echo "o gasto está fora do que esta medição alcança, e é isso que se reporta."
  echo "Mas leia a linha acima antes de concluir: zero minuto medido em zero"
  echo "repositório com workflow não é achado, é medição vazia."
else
  python3 - "$LINHAS" <<'PY'
import sys, collections
por_wf = collections.Counter()
por_repo = collections.Counter()
por_so = collections.Counter()
total = 0.0
for linha in open(sys.argv[1], encoding='utf-8'):
    p = linha.rstrip('\n').split('\t')
    if len(p) != 4: continue
    repo, wf, so, mins = p[0], p[1], p[2], float(p[3])
    por_wf[(repo, wf, so)] += mins
    por_repo[repo] += mins
    por_so[so] += mins
    total += mins

print('MINUTOS FATURÁVEIS NO PERÍODO CORRENTE — por workflow, maiores primeiro')
print()
print('  %-9s %-26s %-24s %s' % ('MINUTOS', 'REPOSITÓRIO', 'WORKFLOW', 'SO'))
for (repo, wf, so), m in por_wf.most_common(30):
    print('  %-9.1f %-26s %-24s %s' % (m, repo[:26], wf[:24], so))
if len(por_wf) > 30:
    print('  ... e mais %d linhas menores, omitidas' % (len(por_wf) - 30))

print()
print('POR REPOSITÓRIO')
for repo, m in por_repo.most_common():
    print('  %-9.1f %s  (%.0f%% do total)' % (m, repo, 100.0 * m / total if total else 0))

print()
print('POR SISTEMA OPERACIONAL — Windows e macOS custam mais por minuto que Ubuntu')
for so, m in por_so.most_common():
    print('  %-9.1f %s' % (m, so))

print()
print('TOTAL LIDO: %.1f minutos' % total)
print()
print('Compare com a cota da conta em Settings → Billing. Se este total for muito')
print('menor, a diferença está em repositório que este script não leu — e essa')
print('diferença é o achado, não um erro do script.')
PY
fi

[ "$SEM_ACESSO" -eq 0 ] || echo "
$SEM_ACESSO repositório(s) sem leitura de Actions — não entraram na soma acima."
[ "$SEM_WORKFLOW" -eq 0 ] || echo "
$SEM_WORKFLOW repositório(s) sem nenhum workflow — não havia o que medir neles."
