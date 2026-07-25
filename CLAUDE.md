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

## Índice de projetos

O índice é alimentado pelo entregável **G** do prompt de auditoria — cada
projeto devolve um resumo curto que vira uma linha aqui.

| Projeto | Raiz local | Remoto | Estado | Fonte de verdade | Pendência principal | Última auditoria |
|---|---|---|---|---|---|---|
| GTM | *não verificado* | *não verificado* | *não verificado* | *não verificado* | *não verificado* | — |
| Focus | *não verificado* | *não verificado* | *não verificado* | *não verificado* | *não verificado* | — |
| PromptOps OS | *não verificado* | *não verificado* | público em `promptops-os-brasil.tiagosouza.chatgpt.site` | *não verificado* | case público sanitizado em preparação | — |
| AI Operating System | *não verificado* | privado | repositório operacional privado | *não verificado* | *não verificado* | — |
| tihh07/tihh07 | este repo | `tihh07/tihh07` | ativo | este arquivo | índice não preenchido | — |

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

## Convenções deste repositório

- **Branches** — trabalho de agente vai para `claude/<escopo>`; `main` é a
  branch default e o que ela contém é o que o perfil público mostra.
- **`.claude/prompts/`** — prompts reutilizáveis, versionados. Um prompt só
  entra aqui quando for rodar em mais de um projeto; caso contrário vive no
  projeto que o usa.
- **`.github/workflows/`** — automações. `claude-pr-watch.yml` está em rascunho.
- **Sanitização** — nada de caminho local absoluto, nome de cliente, token ou
  URL interna em arquivo versionado, inclusive fora do `README.md`. O índice
  acima guarda caminhos locais apenas se forem genéricos; caso contrário,
  referencie o projeto pelo nome e mantenha o caminho fora do repo.
