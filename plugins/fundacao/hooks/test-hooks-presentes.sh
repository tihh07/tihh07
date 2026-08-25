#!/usr/bin/env bash
# test-hooks-presentes.sh — suíte de comportamento do hooks-presentes.sh.
#
# Por que existe: o relator existe porque ausência silenciosa é indistinguível
# de aprovação. Um relator que cale por defeito próprio comete exatamente o
# defeito que denuncia — e isso não é hipótese: a primeira versão do parse
# devolveu SILÊNCIO num cenário montado para produzir achado, porque casava
# "type": "command" em vez da chave "command". O caso de regressão abaixo é
# aquele defeito, congelado.
#
# Uso:  bash plugins/fundacao/hooks/test-hooks-presentes.sh
# Saída: uma linha por caso; exit 0 se todos passarem, 1 na primeira divergência
#        contada ao final (a suíte roda inteira antes de falhar).
#
# O que ela NÃO cobre: se o harness de fato chama o hook no SessionStart (isso é
# configuração de .claude/settings.json, não do script), e o caso que o próprio
# relator declara não alcançar — projeto removido no meio da sessão, quando não
# há mais settings.json para declarar hook nenhum.

set -uo pipefail

REL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/hooks-presentes.sh"
[ -x "$REL" ] || { echo "hooks-presentes.sh não encontrado ou sem permissão de execução: $REL" >&2; exit 1; }

PASS=0
FAIL=0
PULADOS=0

# Cada caso monta seu próprio projeto descartável. Nada roda contra o diretório
# ambiente: aqui o settings.json real existe e os hooks dele estão presentes,
# então TODO caso de ausência passaria por acidente — o mesmo falso verde que a
# suíte do guard-push aprendeu a evitar em 2026-08-21, pela mesma razão.
BASE=$(mktemp -d 2>/dev/null) || BASE=""
if [ -z "$BASE" ]; then
  echo "FALHA: não foi possível criar o diretório de trabalho (mktemp)." >&2
  echo "       A suíte não roda no diretório ambiente: lá os hooks existem e" >&2
  echo "       todo caso de ausência passaria sem provar nada." >&2
  exit 1
fi
trap 'rm -rf "$BASE"' EXIT
N=0

# monta <json do settings>  ->  escreve a raiz do projeto criado em $R
#
# Escreve num GLOBAL em vez de ecoar, e não é estilo: `R=$(monta ...)` roda a
# função num subshell, o `N=$((N + 1))` de dentro não sobe para o pai, e toda a
# suíte passa a compartilhar UM único diretório. Medido: os casos vazavam estado
# uns para os outros e seis deles reprovaram — ou passaram — pelo motivo errado.
# Suíte cujos casos não são independentes não mede o que diz medir.
monta() {
  N=$((N + 1))
  R="$BASE/p$N"
  mkdir -p "$R/.claude" "$R/plugins/fundacao/hooks"
  printf '%s' "$1" > "$R/.claude/settings.json"
}

presente() {
  # Shebang, e nao arquivo vazio. Medido em 2026-08-25, Git-for-Windows: o
  # MSYS deriva o bit de execucao do CONTEUDO — `chmod +x` num arquivo vazio
  # nao acende nada, e `[ -x ]` segue falso. A primeira versao desta suite
  # usava `: >` e reprovou tres casos por isso, acusando o relator de um
  # defeito que era da fixture: arquivo vazio nao e um hook.
  printf '#!/usr/bin/env bash\nexit 0\n' > "$1/plugins/fundacao/hooks/guard-push.sh"
  chmod +x "$1/plugins/fundacao/hooks/guard-push.sh"
}

# caso <esperado: achou|calou> <descrição> <raiz do projeto>
#
# Duas asserções por caso, não uma. A segunda é o invariante que separa este
# script do guard-push: **o relator nunca bloqueia**. Um relator que saísse com
# 2 viraria um bloqueador de escopo global no dia em que alguém o instalasse em
# ~/.claude — que é justamente a instalação que o desenho dele permite e a do
# guard-push não.
caso() {
  local esperado="$1" desc="$2" raiz="$3" saida rc obtido
  saida=$(CLAUDE_PROJECT_DIR="$raiz" bash "$REL" 2>&1); rc=$?
  obtido="calou"
  case "$saida" in *"HOOK DECLARADO SEM ARQUIVO"*) obtido="achou" ;; esac

  if [ "$obtido" != "$esperado" ]; then
    FAIL=$((FAIL + 1))
    printf '  FALHA %s\n        esperado=%s, obtido=%s\n        saida: %s\n' \
      "$desc" "$esperado" "$obtido" "${saida:-<vazia>}"
    return
  fi
  if [ "$rc" -ne 0 ]; then
    FAIL=$((FAIL + 1))
    printf '  FALHA %s\n        relator saiu com %s; relator NUNCA bloqueia (exige 0)\n' \
      "$desc" "$rc"
    return
  fi
  PASS=$((PASS + 1))
  printf '  ok    %s\n' "$desc"
}

HOOK='{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"$CLAUDE_PROJECT_DIR/plugins/fundacao/hooks/guard-push.sh"}]}]}}'

echo "hooks-presentes — comportamento"
echo

# --- o par que é a razão de ser do script ---------------------------------
monta "$HOOK"; presente "$R"
caso calou "declarado e presente: cala" "$R"

monta "$HOOK"
caso achou "declarado e AUSENTE: reporta" "$R"

# Arquivo presente mas sem o bit de execução: o harness devolveria 126, que —
# como 127 — não é 2, e portanto não bloqueia nada. É achado.
#
# O caso PULA no Git-for-Windows, e o pulo é declarado em vez de silencioso.
# Medido em 2026-08-25: o MSYS deriva o bit do CONTEÚDO, então `chmod 644` num
# arquivo com shebang não o torna não-executável — a fixture não se deixa
# construir ali. Afirmar verde sem ter montado o cenário seria a mentira que
# esta suíte existe para não contar; afirmar vermelho culparia o relator por
# uma limitação do sistema de arquivos. No runner Linux da verificação o caso
# roda de verdade, e é lá que ele vale.
monta "$HOOK"; presente "$R"; chmod 644 "$R/plugins/fundacao/hooks/guard-push.sh"
if [ -x "$R/plugins/fundacao/hooks/guard-push.sh" ]; then
  PULADOS=$((PULADOS + 1))
  echo "  pulo  sem permissão de execução: chmod não pega neste sistema de arquivos"
else
  caso achou "presente mas sem permissão de execução: reporta" "$R"
fi

# --- a regressão de posição de chave --------------------------------------
# "type": "command" aparece ANTES da chave "command" em todo hook do formato
# real — inclusive no settings.json deste repositório. Um scanner que case a
# primeira ocorrência sai dessincronizado, lê a palavra command como se fosse o
# caminho, e devolve silêncio. Foi o defeito medido na primeira execução desta
# suíte, e o caso acima já o cobre; este fixa a ordem INVERTIDA, para que nada
# no parse passe a depender de type vir primeiro.
monta '{"hooks":{"PreToolUse":[{"hooks":[{"command":"$CLAUDE_PROJECT_DIR/plugins/fundacao/hooks/guard-push.sh","type":"command"}]}]}}'
caso achou "chave antes de type também é lida" "$R"

# A palavra command dentro do VALOR de outro campo não pode virar achado nem
# encobrir um. Aqui o hook existe: quem quer que o parse leia é o caminho certo.
monta '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","description":"roda o command principal","command":"$CLAUDE_PROJECT_DIR/plugins/fundacao/hooks/guard-push.sh"}]}]}}'
presente "$R"
caso calou "palavra command no valor de outro campo não desalinha o parse" "$R"

# --- o que o relator se recusa a afirmar ----------------------------------
# Comando que não é caminho não é arquivo, e inventar achado sobre ele seria a
# outra metade do mesmo pecado: alarme falso gasta a confiança tão rápido
# quanto silêncio falso.
monta '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"node -e \"require(1)\""}]}]}}'
caso calou "comando que não tem forma de caminho: não inventa achado" "$R"

monta '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"$VARIAVEL_DESCONHECIDA/x.sh"}]}]}}'
caso calou "variável que o relator não resolve: não inventa achado" "$R"

# Projeto sem settings.json nenhum não é defeito — é projeto que não declara
# hook. Reportar aqui seria ruído em toda sessão de todo repositório.
monta '{}'; rm "$R/.claude/settings.json"
caso calou "sem settings.json: cala" "$R"

monta '{"permissions":{"allow":["Bash(ls:*)"]}}'
caso calou "settings.json sem hooks: cala" "$R"

# --- cobertura de arquivo e de resolução ----------------------------------
monta '{}'; printf '%s' "$HOOK" > "$R/.claude/settings.local.json"
caso achou "settings.local.json também é conferido" "$R"

monta '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"${CLAUDE_PROJECT_DIR}/plugins/fundacao/hooks/guard-push.sh"}]}]}}'
caso achou "a forma com chaves resolve igual à forma sem" "$R"

# Dois hooks, um presente e um ausente: o presente não pode encobrir o ausente.
monta '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"$CLAUDE_PROJECT_DIR/plugins/fundacao/hooks/guard-push.sh"},{"type":"command","command":"$CLAUDE_PROJECT_DIR/plugins/fundacao/hooks/sumido.sh"}]}]}}'
presente "$R"
caso achou "hook presente não encobre o ausente ao lado" "$R"

# O comando com argumentos: o que se confere é o primeiro token, não a linha.
ARG='{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"$CLAUDE_PROJECT_DIR/plugins/fundacao/hooks/guard-push.sh --modo estrito"}]}]}}'
monta "$ARG"
caso achou "comando com argumentos: confere o caminho, não a linha" "$R"

monta "$ARG"; presente "$R"
caso calou "mesmo comando com o arquivo presente: cala" "$R"

# --- o próprio repositório -------------------------------------------------
# Não é caso sintético: é a configuração real deste repositório, conferida com
# a raiz real. Se um dia alguém mover o hook e esquecer o settings.json, é aqui
# que a suíte reprova — antes do PR, não depois da sessão sem guarda.
RAIZ_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
if [ -f "$RAIZ_REAL/.claude/settings.json" ]; then
  caso calou "a configuração REAL deste repositório está íntegra" "$RAIZ_REAL"
else
  PULADOS=$((PULADOS + 1))
  echo "  pulo  configuração real não encontrada em $RAIZ_REAL"
fi

echo
if [ "$PULADOS" -gt 0 ]; then
  echo "$PASS passaram, $FAIL falharam, $PULADOS pulados (cenário não construível aqui)"
else
  echo "$PASS passaram, $FAIL falharam"
fi
[ "$FAIL" -eq 0 ]
