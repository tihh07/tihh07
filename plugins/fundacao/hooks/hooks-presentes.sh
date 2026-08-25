#!/usr/bin/env bash
# hooks-presentes.sh — hook SessionStart. Reporta, no início da sessão, todo
# hook declarado no `settings.json` cujo arquivo NÃO existe.
#
# ---------------------------------------------------------------------------
# POR QUE EXISTE — a assimetria medida em 2026-08-25
# ---------------------------------------------------------------------------
# O `guard-push.sh` falha FECHADA quando a entrada é ilegível, e há caso de
# suíte para isso. Quando o ARQUIVO dele não existe, porém, quem decide é o
# harness — e o harness falha ABERTO. Medido com o mesmo envelope, um
# `git push origin --delete`, nas três situações:
#
#     projeto presente ............................ exit 2    bloqueou
#     projeto removido, caminho ainda apontando ... exit 127   NÃO bloqueou
#     projeto removido, $CLAUDE_PROJECT_DIR vazio . exit 127   NÃO bloqueou
#
# O contrato de `PreToolUse` só bloqueia em 2. 127 é "o hook errou", e errar não
# interrompe nada. Guardrail cuja ausência é silenciosa é indistinguível de
# guardrail que aprovou — a mesma classe de "zero silencioso não é aprovação"
# que este repositório já registra sobre rotina de nuvem que saiu de operação.
#
# ---------------------------------------------------------------------------
# O QUE ELE NÃO ALCANÇA — leia antes de confiar
# ---------------------------------------------------------------------------
# **Ele não detecta o caso que motivou sua escrita.** Quando o diretório do
# projeto é removido no MEIO da sessão, some junto o `.claude/settings.json` que
# declara os hooks — inclusive este. Não há hook que erre: não há declaração.
# `SessionStart` já disparou e não dispara de novo. **Nada local sobrevive ao
# desaparecimento do local**, e um script que prometesse isso estaria mentindo.
#
# O que ele alcança é a outra metade, que é a que viaja: sessão que COMEÇA com
# a declaração presente e o arquivo ausente. É o modo de falha esperado quando o
# plugin-fundação for instalado num departamento que não é o de origem — lá o
# caminho é `${CLAUDE_PLUGIN_ROOT}`, aqui é `$CLAUDE_PROJECT_DIR`, e errar entre
# os dois hoje não produz sinal nenhum.
#
# A cobertura da metade que ele não alcança é do servidor, não daqui: ruleset
# que recuse deleção e força no remoto vale onde nenhum arquivo local vale.
#
# ---------------------------------------------------------------------------
# ELE REPORTA, NUNCA BLOQUEIA — e isso é a decisão de desenho, não preguiça
# ---------------------------------------------------------------------------
# Um relator pode ser instalado em nível de usuário sem custo de política; um
# bloqueador não. O `guard-push.sh` não tem noção nenhuma de escopo — medido:
# a única menção a `CLAUDE_PLUGIN_ROOT` no arquivo inteiro está num comentário.
# Instalado em `~/.claude`, ele negaria `git push origin main`,
# `git push -u origin feature/x` e `git push origin HEAD` em TODO repositório
# da máquina, incluindo os que não adotam esta política. Guardrail que nega o
# fluxo legítimo dos outros é desinstalado, e aí não protege ninguém.
#
# Comportamento verificado por `test-hooks-presentes.sh`, ao lado.

set -uo pipefail
set -f

RAIZ="${CLAUDE_PROJECT_DIR:-$PWD}"

achados=()
naoconferidos=0
declarados=0

# Lê `"command": "<valor>"` de um settings.json e confere o primeiro token do
# valor quando ele tem forma de caminho.
#
# O parse é mais simples que o do `guard-push.sh` de propósito: lá a entrada vem
# da ferramenta e um adversário pode forjá-la, aqui a entrada é a config do
# próprio repositório e o risco é caminho errado, não envelope forjado.
confere() {
  local arquivo="$1" texto resto valor tok alvo d
  [ -f "$arquivo" ] || return 0
  IFS= read -r -d '' texto < "$arquivo" || true

  resto="$texto"
  while :; do
    case "$resto" in *'"command"'*) ;; *) break ;; esac
    resto="${resto#*'"command"'}"

    # `"command"` em POSIÇÃO DE CHAVE, nunca como valor.
    #
    # Sem esta linha o próprio `.claude/settings.json` deste repositório derruba
    # o parse: cada hook declara `"type": "command"` ANTES de
    # `"command": "<caminho>"`, o scanner casa a ocorrência errada, sai
    # dessincronizado e lê a palavra `command` como se fosse o caminho. O
    # resultado, na primeira execução desta suíte, foi **nenhum achado num
    # cenário montado justamente para produzir um** — que é o modo de falha que
    # este script existe para acabar, cometido pelo próprio script.
    #
    # É a mesma classe que o `guard-push.sh` fecha no envelope da ferramenta.
    # Lá o adversário é um `description` forjado e a regra precisa ser exata;
    # aqui basta o discriminante barato: depois de uma chave vem `:`.
    d="${resto#"${resto%%[![:space:]]*}"}"
    [ "${d:0:1}" = ":" ] || continue

    resto="${d#*'"'}"
    valor="${resto%%'"'*}"
    resto="${resto#*'"'}"
    declarados=$((declarados + 1))

    tok="${valor%%[[:space:]]*}"

    # Só se pronuncia sobre o que tem forma de caminho. `node -e "..."`,
    # `python -c`, one-liner de shell: nada disso é um arquivo, e afirmar sobre
    # eles seria inventar. O que não se confere é CONTADO, não omitido — um
    # relator que engole o que não entendeu repete o defeito que ele denuncia.
    case "$tok" in
      */*) ;;
      *) naoconferidos=$((naoconferidos + 1)); continue ;;
    esac

    alvo="$tok"
    alvo="${alvo//\$\{CLAUDE_PROJECT_DIR\}/$RAIZ}"
    alvo="${alvo//\$CLAUDE_PROJECT_DIR/$RAIZ}"
    alvo="${alvo//\$\{CLAUDE_PLUGIN_ROOT\}/${CLAUDE_PLUGIN_ROOT:-$RAIZ}}"
    alvo="${alvo//\$CLAUDE_PLUGIN_ROOT/${CLAUDE_PLUGIN_ROOT:-$RAIZ}}"
    alvo="${alvo//\$\{HOME\}/${HOME:-}}"
    alvo="${alvo//\$HOME/${HOME:-}}"

    # Variável que este script não conhece: não dá para resolver, e chutar
    # produziria alarme falso ou silêncio falso. Conta como não conferido.
    case "$alvo" in
      *'$'*) naoconferidos=$((naoconferidos + 1)); continue ;;
    esac

    [ -x "$alvo" ] && continue
    if [ -f "$alvo" ]; then
      achados+=("sem permissao de execucao: $tok")
    else
      achados+=("arquivo nao existe: $tok")
    fi
  done
}

confere "$RAIZ/.claude/settings.json"
confere "$RAIZ/.claude/settings.local.json"

if [ "${#achados[@]}" -gt 0 ]; then
  echo "HOOK DECLARADO SEM ARQUIVO"
  echo
  for a in "${achados[@]}"; do
    echo "  $a"
  done
  echo
  echo "  O harness nao bloqueia por isso: hook que nao executa sai com 127, e"
  echo "  so o exit 2 bloqueia. A sessao segue com poderes plenos de git e nada"
  echo "  mais e anunciado. Restaure o arquivo ou remova a declaracao."
  [ "$naoconferidos" -gt 0 ] && \
    echo "  ($declarados declarados; $naoconferidos sem forma de caminho, nao conferidos)"
  exit 0
fi

# Silêncio aqui é afirmação, não ausência de resposta: os hooks com forma de
# caminho foram conferidos e existem. O que não foi conferido só fica calado
# porque a linha seria ruído em toda sessão; `HOOKS_PRESENTES_VERBOSO=1` a traz.
if [ "$naoconferidos" -gt 0 ] && [ -n "${HOOKS_PRESENTES_VERBOSO:-}" ]; then
  echo "hooks-presentes: $declarados declarados, $naoconferidos sem forma de caminho (nao conferidos)."
fi
exit 0
