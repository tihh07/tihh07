---
setor: marca-pessoal
nivel: N2
emite_pratica: sim
nunca_sai: caminho local, nome de cliente, token, URL interna
---

# AGENTS.md — tihh07/tihh07, Repositório Orquestrador

Doutrina operacional deste repositório, **agente-neutra**: vale para Claude Code,
Codex ou qualquer harness. O `CLAUDE.md` na raiz é ponteiro para cá — se
divergirem, este arquivo vence.

⚠️ **Este é o único repositório público do ecossistema.** Nível **N2** por
definição. Tudo aqui é lido por terceiros, inclusive fora do `README.md`.

Este repositório tem duas funções que não devem se misturar:

1. **Perfil público** — o `README.md` é renderizado no perfil do GitHub. Tudo
   nele é público e deve permanecer sanitizado: sem nomes de clientes, sem
   dados internos, sem caminhos locais.
2. **Orquestrador** — o restante do repositório é o ponto de convergência dos
   projetos em aberto: onde eles estão, qual o estado de cada um, e onde mora a
   fonte de verdade de cada informação que se repete entre eles.

## O que o orquestrador deve responder a qualquer momento

- **O que existe?** — quais projetos, onde vivem, em que estado estão.
- **Onde está a verdade?** — para cada informação duplicada entre projetos
  (versão, escopo, status, roadmap, config, credencial referenciada), qual é o
  local canônico.
- **O que está pendente?** — lacunas, trabalho não publicado, documentação que
  descreve uma realidade antiga.

Este arquivo responde à primeira; o ciclo de auditoria resolve a segunda; a
terceira vive em [`docs/pendencias.md`](docs/pendencias.md). O **desenho** do
ecossistema — departamentos, executores, governança, riscos R1–R11, roadmap —
vive no [blueprint](docs/orchestration-blueprint.md), que é a autoridade de
projeto; este aqui é operacional, e divergindo é este que se corrige.

Duas regras do blueprint valem em toda sessão neste repo:

- **R1** — nenhuma sessão mistura repositórios privados com este, que é público.
  Auditorias rodam escopadas em um projeto por vez, e só o resumo sanitizado
  chega aqui.
- **Gate humano** — nada é mesclado em `main` por agente, e todo commit no repo
  público passa por revisão.

## Frontmatter de identificação

Todo `AGENTS.md` do ecossistema abre com um bloco YAML declarando a que o
repositório pertence e o que pode sair dele. A rotina semanal de control-plane
fiscaliza esses campos, então não são decorativos:

| Campo | O que declara |
|---|---|
| `setor` | A que setor do ecossistema o repositório pertence. Valor deste repo: `marca-pessoal`. |
| `nivel` | Classificação de exposição. `N2` = público, rigor máximo de sanitização. |
| `emite_pratica` | Se o repositório publica prática reutilizável por outros, ou só consome. |
| `nunca_sai` | O que nunca pode aparecer em arquivo versionado, mesmo fora do `README.md`. |

A lista canônica de setores vive fora daqui, barrada pela mesma decisão humana
que barra os treze nomes do índice abaixo. Este arquivo declara o próprio setor
e não afirma o conjunto.

## Índice de projetos

O índice rastreia o **estado** de cada projeto. Quais projetos existem e qual a
missão de cada um é o [blueprint](docs/orchestration-blueprint.md) (seção 3) que
define; cada linha aqui vem do bloco de handoff que a auditoria devolve.

O ecossistema tem **18 repositórios**: 17 privados e este, o único público.

| Repositório | Departamento | Estado | Última auditoria |
|---|---|---|---|
| `AI-Operating-System` (privado) | Fundação / Arquitetura | auditoria despachada | em voo |
| `ia-fonte-de-conhecimento` (privado) | Segundo Cérebro | auditoria despachada | em voo |
| `gtm-ciclo-do-pedido` (privado) | Inteligência Comercial & Mercado | auditoria despachada | em voo |
| `bena-agencia` (privado) | Operação de Cliente / Agência | auditoria despachada | em voo |
| *13 repositórios privados* | não declarado | auditoria despachada | em voo |
| `tihh07/tihh07` (público) | Fachada Pública / Marketing | **auditado** — documentação, workflows e templates; sem código de aplicação | 2026-08-20 |

> **Treze linhas viraram uma.** Vários desses nomes de repositório são nomes de
> organização, e publicá-los aciona os itens 1 e 7 do checklist do
> [`SECURITY.md`](SECURITY.md). Um índice que esconde treze dos dezoito descreve
> um recorte; um que os publica sem decisão humana vaza. Contar sem nomear é a
> única das três opções que não mente nem expõe — e **um dos quatro já nomeados
> cai na mesma decisão**.
>
> **"Em voo" não é "verificado".** Em 2026-08-20 foram despachadas 17 sessões de
> nuvem, uma por repositório privado, cada uma escopada no seu. A coluna vira
> data quando o handoff chegar: despachar não é auditar.

Achados que não cabem na tabela vivem em
[`docs/pendencias.md`](docs/pendencias.md), com evidência, executor e critério de
verificação — repetir aqui só cria duas listas para divergirem.

Ao adicionar um projeto, crie a linha com todas as células em *não verificado* e
só substitua o que a auditoria confirmar.

## Ciclo de auditoria

Uma sessão de nuvem por projeto (**R1**: nunca dois), um dos três prompts de
[`.claude/prompts/`](.claude/prompts/), relatório gravado **na origem**, e o
bloco de handoff sanitizado trazido **por uma pessoa**.

O processo inteiro — qual prompt escolher, o que a ficha contém e o que ela
nunca contém — vive em [`docs/handoff/`](docs/handoff/README.md), junto do
modelo. Não é duplicado aqui: ciclo e handoff são o mesmo processo, e mantê-lo
em dois lugares é a divergência que este repositório existe para evitar.

## Onde as coisas moram

| Caminho | O que é |
|---|---|
| `README.md` | Perfil público renderizado pelo GitHub |
| `AGENTS.md` | Esta doutrina operacional; `CLAUDE.md` é ponteiro para cá |
| `docs/orchestration-blueprint.md` | Autoridade de projeto — vence em caso de divergência |
| `docs/pendencias.md` | Backlog: o que falta, com executor e critério de verificação |
| `docs/handoff/` | Padrão e fichas de handoff — o que atravessa privado × público |
| `docs/control-plane.md` | Desenho das rotinas e da config de repo — como reconstruir se a UI sumir |
| `SECURITY.md` | Canônico do checklist de sanitização, da regra R1, do kill-switch e do runbook de incidente |
| `.claude/settings.json` | Permissões do projeto e instalação do hook de push |
| `.claude/prompts/` | Prompts reutilizáveis entre projetos |
| `.claude/skills/` | Conteúdo versionado das rotinas (padrão prompt-ponteiro) |
| `.claude-plugin/marketplace.json` | Manifesto do marketplace que distribui o plugin-fundação |
| `plugins/fundacao/` | Templates distribuíveis: executores, hook e sua suíte, telemetria, backup |
| `.github/workflows/` | PR Watch, watchdog e backup para o Drive |
| `.github/CODEOWNERS` | Donos por caminho — inerte até "Require review from Code Owners" |
| `.gitignore` · `LICENSE` | Barra segredo e dado; CC BY 4.0 no texto, MIT nos snippets |
| `reports/publicacao/` | Saída semanal da rotina N2, quando há achado |

## Build, testes e lint

Não há gerenciador de pacotes, linter nem etapa de build, e não se deve
introduzir um sem que isso seja o pedido explícito. O repositório é Markdown,
YAML, três manifestos JSON e dois shell scripts — um guardrail e a suíte que o
verifica.

A verificação equivalente aqui, antes de qualquer PR:

- o `README.md` renderiza corretamente no perfil do GitHub;
- os workflows em `.github/workflows/` têm YAML válido, e cada um declara no
  cabeçalho o que **não** cobre — workflow que promete mais do que verifica dá
  verde vazio;
- todo `**/.claude-plugin/*.json` e `.claude/settings.json` são JSON válido
  (o glob antigo, `.claude-plugin/*.json`, deixava o manifesto do plugin de
  fora do procedimento);
- **`bash plugins/fundacao/hooks/test-guard-push.sh` passa inteira**, e os blocos
  `run:` dos workflows passam em `bash -n`. A suíte é a única verificação
  executável do repositório: prova que o hook bloqueia push para `main`, force
  push, deleção remota e push de repositório inteiro, e libera `claude/*`.
  Guardrail sem suíte é afirmação, não controle. A contagem de casos não fica
  aqui: já envelheceu uma vez neste arquivo, calada, entre duas correções.

## Topologia de branches

**`main` é a única branch permanente**, e o que ela contém é o que o perfil
público mostra. Branches de trabalho saem de `main`, voltam por PR e são apagadas
no merge — por isso esta seção não as lista: uma lista dessas envelhece no
primeiro merge. `git branch -r` responde melhor que qualquer documento.

O gate humano vale para todas: nada entra em `main` sem PR revisado.

## Convenções deste repositório

- **Branches** — trabalho de agente vai para `claude/<escopo>`; `main` é a
  branch default e o que ela contém é o que o perfil público mostra.
- **`.claude/prompts/`** — prompts reutilizáveis, versionados. Um prompt só
  entra aqui quando for rodar em mais de um projeto; caso contrário vive no
  projeto que o usa.
- **Prompt de rotina nunca mora só na UI** — o conteúdo real vai para
  `.claude/skills/<nome>/SKILL.md` e o prompt da rotina vira um ponteiro. Prompt
  na UI não é revisável, não é auditável e se perde se a rotina for recriada.
- **Idioma** — a documentação operacional é escrita em português; mensagens de
  commit, em inglês. A regra vale inclusive para commit feito à mão: vários
  commits de julho de 2026 a violaram — inclusive títulos de merge, que passam
  despercebidos — e é o tipo de exceção que, repetida, vira a nova convenção por
  omissão. A contagem exata não fica aqui de propósito: número no texto envelhece
  calado, e `git log` responde melhor.
- **Orçamento de contexto** — `CLAUDE.md` importa este arquivo na linha 1, então
  os dois ocupam o mesmo orçamento e o limite de 200 linhas que o blueprint fixa
  para a identidade de um departamento vale na prática **para a soma**. Seção
  nova exige poda de outra: crescer sem podar empurra doutrina para fora do
  contexto de toda sessão, calado.
- **Sanitização** — nada de caminho local absoluto, nome de cliente, token ou
  URL interna em arquivo versionado, inclusive fora do `README.md`. O índice
  acima guarda caminhos locais apenas se forem genéricos; caso contrário,
  referencie o projeto pelo nome e mantenha o caminho fora do repo.
