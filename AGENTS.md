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

Este arquivo é a resposta à primeira pergunta. As outras duas se resolvem pelo
ciclo de auditoria descrito abaixo.

O **desenho** do ecossistema — departamentos, executores, governança, matriz de
riscos R1–R11, roadmap — vive em
[`docs/orchestration-blueprint.md`](docs/orchestration-blueprint.md). Esse
documento é a autoridade de projeto; este aqui é operacional. Em caso de
divergência, o blueprint prevalece e este arquivo é que deve ser corrigido.

Duas regras do blueprint valem em toda sessão neste repo:

- **R1** — nenhuma sessão mistura repositórios privados com este, que é público.
  Auditorias rodam na sessão local de cada projeto, e só o resumo sanitizado
  chega aqui.
- **Gate humano** — nada é mesclado em `main` por agente, e todo commit no repo
  público passa por revisão.

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
| `tihh07/tihh07` (público) | Fachada Pública / Marketing | ativo | índice não preenchido | — |

> **Nada nesta tabela foi verificado ainda.** As linhas existem para declarar o
> conjunto conhecido de projetos, não para afirmar o estado deles. Preencher uma
> célula sem ter rodado a auditoria no projeto correspondente derrota o
> propósito do orquestrador.

Ao adicionar um projeto, crie a linha com todas as células em *não verificado* e
só substitua o que a auditoria confirmar.

## Ciclo de auditoria

O prompt canônico está em
[`.claude/prompts/auditoria-fonte-de-verdade.md`](.claude/prompts/auditoria-fonte-de-verdade.md).

1. Abrir uma sessão local no projeto.
2. Colar o prompt (a partir da linha indicada no arquivo).
3. A sessão devolve o relatório com os entregáveis A–G, sem alterar nada.
4. O entregável G vira/atualiza a linha do projeto no índice acima, com a data
   na coluna "Última auditoria".
5. Divergências de severidade alta viram trabalho no projeto de origem, não
   aqui.

## Build, testes e lint

Não há nenhum. Este repositório não contém código executável — só Markdown e
YAML de workflow. Não existe gerenciador de pacotes, suíte de testes, linter ou
etapa de build, e não se deve introduzir um sem que isso seja o pedido
explícito.

A verificação equivalente aqui é: o `README.md` renderiza corretamente no perfil
do GitHub, e os workflows em `.github/workflows/` têm YAML válido.

## Topologia de branches

`main` concentra todo o conteúdo do repositório. As duas branches `claude/*` que
existiam antes já foram mescladas e não carregam mais nada exclusivo:

- **`main`** — `README.md` (perfil público), `CLAUDE.md`, `docs/`,
  `.claude/prompts/` e `.github/workflows/claude-pr-watch.yml`.
- **`claude/ci-pr-watch`** — mesclada em `main` pelo PR #2. Era a única portadora
  do workflow de vigilância de PRs.
- **`claude/repo-orchestration-agent-bjjsff`** — mesclada em `main` pelo PR #3
  (blueprint, este arquivo e `.claude/prompts/`); reaproveitada depois para
  trabalho de orquestração, sempre reiniciada a partir de `main`.

Branches de trabalho futuras continuam saindo de `main` e voltando por PR — o
gate humano da seção acima vale para todas.

## Convenções deste repositório

- **Branches** — trabalho de agente vai para `claude/<escopo>`; `main` é a
  branch default e o que ela contém é o que o perfil público mostra.
- **`.claude/prompts/`** — prompts reutilizáveis, versionados. Um prompt só
  entra aqui quando for rodar em mais de um projeto; caso contrário vive no
  projeto que o usa.
- **Idioma** — a documentação operacional é escrita em português; mensagens de
  commit, em inglês.
- **Sanitização** — nada de caminho local absoluto, nome de cliente, token ou
  URL interna em arquivo versionado, inclusive fora do `README.md`. O índice
  acima guarda caminhos locais apenas se forem genéricos; caso contrário,
  referencie o projeto pelo nome e mantenha o caminho fora do repo.
