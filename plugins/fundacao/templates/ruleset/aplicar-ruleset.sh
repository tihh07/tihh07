#!/usr/bin/env bash
# aplicar-ruleset.sh — aplica protect-default.json na branch default de vários
# repositórios, de uma vez, a partir da SUA máquina e com a SUA credencial.
#
# ---------------------------------------------------------------------------
# ESTE SCRIPT NÃO É PARA AGENTE RODAR. É PARA VOCÊ.
# ---------------------------------------------------------------------------
# A distinção não é cerimônia. Escrita de configuração de repositório é barrada
# para sessões de agente por duas paredes independentes (ver H7 no backlog), e a
# segunda delas — a permissão do GitHub App — existe justamente para que um
# agente não reconfigure repositório. Rodar isto por agente seria contornar o
# controle com o token de outra pessoa, que é a definição de rota alternativa.
#
# Aqui não há contorno: é você, seu token, sua máquina. O script só existe
# porque dezoito repositórios vezes seis cliques é trabalho que ninguém faz duas
# vezes com atenção — e configuração aplicada sem atenção é pior que nenhuma.
#
# ---------------------------------------------------------------------------
# ANTES DE RODAR
# ---------------------------------------------------------------------------
# 1. Crie um PAT fine-grained em Settings → Developer settings → Personal access
#    tokens, com permissão **Administration: Read and write** nos repositórios
#    que quiser proteger. Só isso — nenhuma outra permissão é necessária.
# 2. Exporte-o:  export GH_ADMIN_TOKEN=...
#    Não passe o token como argumento: argumento vaza no histórico do shell e na
#    lista de processos.
# 3. Rode SEM argumentos primeiro. O padrão é simulação: ele lista o que faria e
#    não muda nada. Só `--aplicar` escreve.
# 4. Apague o PAT depois. Ele tem poder de reconfigurar seus repositórios e não
#    tem mais nada para fazer.
#
# Uso:
#   bash aplicar-ruleset.sh                 # simula em todos os repos privados
#   bash aplicar-ruleset.sh --aplicar       # aplica
#   bash aplicar-ruleset.sh --todos         # inclui públicos também
#   bash aplicar-ruleset.sh --repo a --repo b --aplicar   # só nesses

set -uo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELO="$AQUI/protect-default.json"
API="https://api.github.com"
NOME_RULESET="protect-default"

APLICAR=0
INCLUIR_PUBLICOS=0
ALVOS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --aplicar) APLICAR=1; shift ;;
    --todos)   INCLUIR_PUBLICOS=1; shift ;;
    --repo)    [ $# -ge 2 ] || { echo "--repo exige um nome de repositório" >&2; exit 2; }
               ALVOS+=("$2"); shift 2 ;;
    -h|--help) sed -n '2,40p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "argumento desconhecido: $1" >&2; exit 2 ;;
  esac
done

[ -n "${GH_ADMIN_TOKEN:-}" ] || {
  echo "GH_ADMIN_TOKEN não está definido. Veja o cabeçalho deste arquivo." >&2
  exit 1
}
[ -f "$MODELO" ] || { echo "não encontrei $MODELO" >&2; exit 1; }
command -v curl >/dev/null || { echo "curl não encontrado" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 não encontrado" >&2; exit 1; }

api() {
  # api <metodo> <caminho> [arquivo-de-corpo] -> imprime "CODIGO\ncorpo"
  local metodo="$1" caminho="$2" corpo="${3:-}" args=()
  args=(-sS -w '\n%{http_code}' -X "$metodo"
        -H "Authorization: Bearer $GH_ADMIN_TOKEN"
        -H "Accept: application/vnd.github+json"
        -H "X-GitHub-Api-Version: 2022-11-28")
  [ -n "$corpo" ] && args+=(-H "Content-Type: application/json" --data @"$corpo")
  curl "${args[@]}" "$API$caminho"
}

DONO=$(api GET /user | python3 -c "
import json,sys
linhas=sys.stdin.read().rsplit('\n',1)
print(json.loads(linhas[0]).get('login','') if linhas[1].strip()=='200' else '')")
[ -n "$DONO" ] || { echo "token inválido ou sem acesso: GET /user falhou." >&2; exit 1; }
echo "Conta: $DONO"

# Descobre os repositórios pela API em vez de carregar uma lista no arquivo.
# Lista de repositórios privados versionada num repo público é exatamente o que
# os apelidos P01–P17 existem para evitar (ver SECURITY.md).
if [ ${#ALVOS[@]} -eq 0 ]; then
  pagina=1
  while :; do
    resp=$(api GET "/user/repos?per_page=100&page=$pagina&affiliation=owner")
    corpo=${resp%$'\n'*}; codigo=${resp##*$'\n'}
    [ "$codigo" = "200" ] || { echo "falha ao listar repositórios (HTTP $codigo)" >&2; exit 1; }
    nomes=$(printf '%s' "$corpo" | INCLUIR_PUBLICOS="$INCLUIR_PUBLICOS" python3 -c "
import json,sys,os
incluir_publicos = os.environ.get('INCLUIR_PUBLICOS') == '1'
for r in json.load(sys.stdin):
    if r.get('archived'): continue
    if r.get('private') or incluir_publicos:
        print(r['name'])")
    [ -z "$nomes" ] && break
    while IFS= read -r n; do [ -n "$n" ] && ALVOS+=("$n"); done <<< "$nomes"
    pagina=$((pagina + 1))
  done
fi

[ ${#ALVOS[@]} -gt 0 ] || { echo "nenhum repositório encontrado." >&2; exit 1; }

if [ "$APLICAR" -eq 0 ]; then
  echo
  echo "*** SIMULAÇÃO — nada será alterado. Use --aplicar para valer. ***"
fi
echo
printf '%-42s %s\n' "REPOSITÓRIO" "RESULTADO"

CRIADOS=0; JA_TINHA=0; FALHOU=0
for repo in "${ALVOS[@]}"; do
  # Qual é a branch default? Não presuma "main": vários repositórios antigos
  # ainda são "master", e proteger a branch errada é pior que não proteger —
  # parece feito.
  resp=$(api GET "/repos/$DONO/$repo")
  corpo=${resp%$'\n'*}; codigo=${resp##*$'\n'}
  if [ "$codigo" != "200" ]; then
    printf '%-42s %s\n' "$repo" "ERRO ao ler o repositório (HTTP $codigo)"
    FALHOU=$((FALHOU + 1)); continue
  fi
  BRANCH=$(printf '%s' "$corpo" | python3 -c "
import json,sys
print(json.load(sys.stdin).get('default_branch',''))")
  if [ -z "$BRANCH" ]; then
    printf '%-42s %s\n' "$repo" "ERRO: não consegui determinar a branch default — pulado"
    FALHOU=$((FALHOU + 1)); continue
  fi

  # A branch default já está protegida por ALGUÉM?
  #
  # A primeira versão comparava só o NOME do ruleset, e era o defeito que o
  # README ao lado descrevia sem o código implementar: o repositório público já
  # tinha um `protect-main` protegendo a default, e a simulação anunciou que
  # criaria `protect-default` em cima. Duas regras empilhadas no mesmo alvo.
  #
  # Empilhar não é inofensivo — as regras se somam, ninguém sabe qual nega o
  # quê, e quem ler "o ruleset" depois vai ler um dos dois, possivelmente o mais
  # frouxo.
  #
  # `/rules/branches/<branch>` devolve as regras EFETIVAS naquela branch, venham
  # de onde vierem. É a pergunta certa — "esta branch já está protegida?" — em
  # vez da pergunta cômoda, "existe um ruleset com o meu nome?". Decidir se a
  # proteção existente basta é julgamento humano, não do script.
  BRANCH_URL=$(printf '%s' "$BRANCH" | python3 -c "
import sys,urllib.parse
print(urllib.parse.quote(sys.stdin.read().strip(), safe=''))")
  resp=$(api GET "/repos/$DONO/$repo/rules/branches/$BRANCH_URL")
  corpo=${resp%$'\n'*}; codigo=${resp##*$'\n'}
  if [ "$codigo" != "200" ]; then
    printf '%-42s %s\n' "$repo" "ERRO ao ler regras de '$BRANCH' (HTTP $codigo)"
    FALHOU=$((FALHOU + 1)); continue
  fi
  existe=$(printf '%s' "$corpo" | python3 -c "
import json,sys
regras=json.load(sys.stdin)
if not regras:
    print('nao')
else:
    print(','.join(sorted({str(r.get('ruleset_source') or r.get('ruleset_id')) for r in regras})))")
  if [ -z "$existe" ]; then
    printf '%-42s %s\n' "$repo" "ERRO ao interpretar as regras de '$BRANCH' — pulado"
    FALHOU=$((FALHOU + 1)); continue
  fi
  if [ "$existe" != "nao" ]; then
    printf '%-42s %s\n' "$repo" "'$BRANCH' JÁ protegida (por: $existe) — pulado"
    JA_TINHA=$((JA_TINHA + 1)); continue
  fi

  if [ "$APLICAR" -eq 0 ]; then
    printf '%-42s %s\n' "$repo" "criaria '$NOME_RULESET' sobre '$BRANCH' (hoje desprotegida)"
    CRIADOS=$((CRIADOS + 1)); continue
  fi
  resp=$(api POST "/repos/$DONO/$repo/rulesets" "$MODELO")
  corpo=${resp%$'\n'*}; codigo=${resp##*$'\n'}
  if [ "$codigo" = "201" ]; then
    printf '%-42s %s\n' "$repo" "CRIADO e ativo"
    CRIADOS=$((CRIADOS + 1))
  else
    msg=$(printf '%s' "$corpo" | python3 -c "
import json,sys
try: print(json.load(sys.stdin).get('message','')[:60])
except Exception: print('(sem mensagem)')")
    printf '%-42s %s\n' "$repo" "FALHOU (HTTP $codigo) $msg"
    FALHOU=$((FALHOU + 1))
  fi
done

echo
echo "$CRIADOS a criar/criados · $JA_TINHA já tinham · $FALHOU falharam"
if [ "$APLICAR" -eq 1 ] && [ "$FALHOU" -eq 0 ]; then
  echo
  echo "Confira um deles na UI antes de considerar fechado: a lista de bypass"
  echo "precisa estar VAZIA. É o campo que transforma o controle em sugestão."
  echo "E apague o PAT — ele não tem mais nada para fazer."
fi
[ "$FALHOU" -eq 0 ]
