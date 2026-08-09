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

Este arquivo é a resposta à primeira pergunta. A segunda se resolve pelo ciclo de
auditoria descrito abaixo. A terceira vive em
[`docs/pendencias.md`](docs/pendencias.md) — backlog do checkup mais recente,
com cada item escrito para ser executado por uma sessão na nuvem sem depender de
contexto de sessão local.

O **desenho** do ecossistema — departamentos, executores, governança, matriz de
riscos R1–R11, roadmap — vive em
[`docs/orchestration-blueprint.md`](docs/orchestration-blueprint.md). Esse
documento é a autoridade de projeto; este aqui é operacional. Em caso de
divergência, o blueprint prevalece e este arquivo é que deve ser corrigido.

Duas regras do blueprint valem em toda sessão neste repo:

- **R1** — nenhuma sessão mistura repositórios privados com este, que é público.
  Auditorias rodam escopadas em um projeto por vez, e só o resumo sanitizado
  chega aqui.
- **Gate humano** — nada é mesclado em `main` por agente, e todo commit no repo
  público passa por revisão.

## Frontmatter de identificação

Todo `AGENTS.md` do ecossistema abre com um bloco YAML que declara a que o
repositório pertence e o que pode sair dele. Os campos são fiscalizados pela
rotina semanal de control-plane, então não são decorativos:

| Campo | O que declara |
|---|---|
| `setor` | A que setor do ecossistema o repositório pertence. Valor deste repo: `marca-pessoal`. |
| `nivel` | Classificação de exposição. `N2` = público, rigor máximo de sanitização. |
| `emite_pratica` | Se o repositório publica prática reutilizável por outros, ou só consome. |
| `nunca_sai` | O que nunca pode aparecer em arquivo versionado, mesmo fora do `README.md`. |

A lista canônica de setores vive fora deste repositório e ainda **não** foi
publicada aqui — trazê-la exige a checagem de nomes e titularidade do
[`SECURITY.md`](SECURITY.md), que é decisão humana pendente
([`docs/pendencias.md`](docs/pendencias.md)). Até lá, este arquivo declara o
próprio setor e não afirma o conjunto.

## Índice de projetos

O índice é alimentado pelo entregável **G** do prompt de auditoria — cada
projeto devolve um resumo curto que vira uma linha aqui.

Os departamentos e seus repositórios são definidos pelo
[blueprint de orquestração](docs/orchestration-blueprint.md) (seção 3) — ele é a
fonte de verdade sobre *quais* projetos existem e qual a missão de cada um. A
tabela abaixo rastreia o *estado* de cada um.

| Repositório | Departamento | Estado | Pendência principal | Última auditoria |
|---|---|---|---|---|
| `AI-Operating-System` (privado) | Fundação / Arquitetura | *não verificado* — piloto da Fase 1 | *não verificado* | — |
| `ia-fonte-de-conhecimento` (privado) | Segundo Cérebro | *não verificado* | *não verificado* | — |
| `gtm-ciclo-do-pedido` (privado) | Inteligência Comercial & Mercado | *não verificado* | *não verificado* | — |
| `bena-agencia` (privado) | Operação de Cliente / Agência | *não verificado* | *não verificado* | — |
| `tihh07/tihh07` (público) | Fachada Pública / Marketing | **auditado** — documentação, workflows e templates de plugin; sem código de aplicação | Uma rotina semanal agendada tem repositório privado e o público no mesmo escopo, violando R1; só o humano remove | 2026-08-08 |

> **Só a última linha foi verificada.** As demais existem para declarar o
> conjunto conhecido de projetos, não para afirmar o estado deles. Preencher uma
> célula sem ter rodado a auditoria no projeto correspondente derrota o
> propósito do orquestrador.

Achados que não cabem na tabela — abertos e resolvidos — vivem em
[`docs/pendencias.md`](docs/pendencias.md), com evidência, executor e critério
de verificação. É lá que se olha para saber o que falta; repetir aqui só cria
duas versões da mesma lista para divergirem.

Ao adicionar um projeto, crie a linha com todas as células em *não verificado* e
só substitua o que a auditoria confirmar.

## Ciclo de auditoria

A auditoria é dividida em duas partes, porque só uma fração dela depende de
máquina local:

- [`.claude/prompts/auditoria-fonte-de-verdade.md`](.claude/prompts/auditoria-fonte-de-verdade.md)
  — **roda na nuvem**, escopado em um repositório. Cobre os seis passos do check
  reverso e os entregáveis A–H. É a maior parte do trabalho.
- [`.claude/prompts/auditoria-adendo-local.md`](.claude/prompts/auditoria-adendo-local.md)
  — **roda na máquina do projeto**, em minutos. Só o que a nuvem
  comprovadamente não alcança: arquivos fora do git, clones antigos, planilhas
  soltas, stashes, segredos em repouso.

O ciclo:

1. Abrir uma sessão na nuvem escopada em **um** projeto (R1: nunca dois).
2. Colar o prompt de auditoria de nuvem (a partir da linha indicada no arquivo).
3. A sessão devolve o relatório A–H, sem alterar nada.
4. Se o entregável H pedir, rodar o adendo local no projeto e anexar o bloco.
5. O entregável G vira/atualiza a linha do projeto no índice acima, com a data
   na coluna "Última auditoria".
6. Divergências de severidade alta viram trabalho no projeto de origem, não
   aqui.

O passo 4 é condicional de propósito. Auditoria que exige sessão local por
padrão não acontece — e quatro departamentos passaram semanas em *não
verificado* exatamente por isso.

## Onde as coisas moram

| Caminho | O que é |
|---|---|
| `README.md` | Perfil público renderizado pelo GitHub |
| `AGENTS.md` | Esta doutrina operacional; `CLAUDE.md` é ponteiro para cá |
| `docs/orchestration-blueprint.md` | Autoridade de projeto — vence em caso de divergência |
| `docs/pendencias.md` | Backlog: o que falta, com executor e critério de verificação |
| `SECURITY.md` | Política de segurança, regra R1 e runbook de incidente |
| `.claude/prompts/` | Prompts reutilizáveis entre projetos |
| `.claude/skills/` | Conteúdo versionado das rotinas (padrão prompt-ponteiro) |
| `plugins/fundacao/` | Templates distribuíveis: executores, hook, telemetria |
| `.github/workflows/` | PR Watch e watchdog |
| `reports/publicacao/` | Saída semanal da rotina N2, quando há achado |

## Build, testes e lint

Não há gerenciador de pacotes, suíte de testes, linter nem etapa de build, e não
se deve introduzir um sem que isso seja o pedido explícito. O repositório é
Markdown, YAML e um único shell script.

A verificação equivalente aqui, antes de qualquer PR:

- o `README.md` renderiza corretamente no perfil do GitHub;
- os workflows em `.github/workflows/` têm YAML válido, e cada um declara no
  cabeçalho o que **não** cobre — workflow que promete mais do que verifica dá
  verde vazio;
- os manifestos `.claude-plugin/*.json` são JSON válido;
- `bash -n plugins/fundacao/hooks/guard-push.sh` passa, e o hook continua
  bloqueando push para `main`, force push e deleção de branch remota, e
  liberando `claude/*`.

## Topologia de branches

**`main` é a única branch permanente**, e o que ela contém é o que o perfil
público mostra. Branches de trabalho são efêmeras: saem de `main`, voltam por PR
e são apagadas no merge — por isso esta seção não lista branches nominalmente.
Uma lista dessas envelhece no primeiro merge e passa a descrever uma realidade
que não existe mais.

Para saber o que está vivo agora, `git branch -r` responde melhor que qualquer
documento. As branches que já cumpriram esse ciclo foram removidas no merge dos
seus PRs; o histórico delas está no log, não aqui — mantê-las contadas neste
arquivo repetiria o defeito que esta seção existe para evitar.

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
  commit, em inglês. A regra vale inclusive para commit feito à mão: dois
  commits de julho de 2026 a violaram, e é o tipo de exceção que, repetida,
  vira a nova convenção por omissão.
- **Sanitização** — nada de caminho local absoluto, nome de cliente, token ou
  URL interna em arquivo versionado, inclusive fora do `README.md`. O índice
  acima guarda caminhos locais apenas se forem genéricos; caso contrário,
  referencie o projeto pelo nome e mantenha o caminho fora do repo.
