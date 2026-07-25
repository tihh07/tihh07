# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# tihh07/tihh07 — Repositório Orquestrador

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

O conteúdo difere de forma relevante entre as branches — verifique em qual você
está antes de afirmar que um arquivo existe.

- **`main`** — só `README.md`. É o que o perfil público mostra.
- **`claude/ci-pr-watch`** — `README.md` + `.github/workflows/claude-pr-watch.yml`
  (rascunho do workflow de vigilância de PRs). Este workflow **não existe em
  nenhuma outra branch**.
- **`claude/repo-orchestration-agent-bjjsff`** — camada de orquestração:
  este arquivo e `.claude/prompts/`.

Nenhuma das branches `claude/*` foi mesclada em `main`.

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
