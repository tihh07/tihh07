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

O ecossistema tem **18 repositórios**: 17 privados e este, o único público.

| Repositório | Departamento | Estado | Última auditoria |
|---|---|---|---|
| `AI-Operating-System` (privado) | Fundação / Arquitetura | auditoria integral despachada | em voo |
| `ia-fonte-de-conhecimento` (privado) | Segundo Cérebro | auditoria integral despachada | em voo |
| `gtm-ciclo-do-pedido` (privado) | Inteligência Comercial & Mercado | auditoria integral despachada | em voo |
| `bena-agencia` (privado) | Operação de Cliente / Agência | auditoria integral despachada | em voo |
| *13 repositórios privados* | não declarado | auditoria integral despachada | em voo |
| `tihh07/tihh07` (público) | Fachada Pública / Marketing | **auditado** — documentação, workflows e templates de plugin; sem código de aplicação | 2026-08-20 |

> **Por que treze linhas viraram uma.** Não é preguiça de tabela: vários desses
> nomes de repositório são nomes de organização, e publicá-los aqui aciona os
> itens 1 (nomes) e 7 (titularidade) do checklist do
> [`SECURITY.md`](SECURITY.md). O orquestrador precisa responder *"o que
> existe?"* — e a resposta honesta num repositório N2 é a **contagem e o
> estado**, não a lista. Nomear os treze é decisão humana, registrada em
> [`docs/pendencias.md`](docs/pendencias.md); os quatro nomeados acima já
> constavam do blueprint publicado, e **um deles cai na mesma decisão**.
>
> Enquanto a decisão não vier, este arquivo declara o conjunto pelo tamanho. Um
> índice que esconde treze dos dezoito descreve um recorte; um índice que os
> publica sem a decisão vaza. Contar e não nomear é a única das três opções que
> não mente nem expõe.

> **"Em voo" não é "verificado".** Em 2026-08-20 foram despachadas 17 sessões de
> nuvem, uma por repositório privado, cada uma escopada no seu (**R1**: nenhuma
> mistura). Cada uma audita, aplica as correções autorizadas e abre PR draft no
> próprio repositório. Nenhuma delas escreve aqui: o bloco de handoff sanitizado
> fica na origem, e o transporte é humano. A coluna só vira data quando esse
> bloco chegar — despachar não é auditar, e marcar como concluído o que ainda
> está rodando é exatamente o defeito que este índice existe para evitar.

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
| `SECURITY.md` | Canônico do checklist de sanitização, da regra R1, do kill-switch e do runbook de incidente |
| `LICENSE` | Dois regimes: CC BY 4.0 para o texto, MIT para os snippets |
| `.claude/settings.json` | Permissões do projeto e instalação do hook de push |
| `.claude/prompts/` | Prompts reutilizáveis entre projetos |
| `.claude/skills/` | Conteúdo versionado das rotinas (padrão prompt-ponteiro) |
| `.claude-plugin/marketplace.json` | Manifesto do marketplace que distribui o plugin-fundação |
| `plugins/fundacao/` | Templates distribuíveis: executores, hook, suíte do hook, telemetria |
| `.github/workflows/` | PR Watch e watchdog |
| `.github/CODEOWNERS` | Donos por caminho — inerte até "Require review from Code Owners" |
| `.gitignore` | Barra segredo, base de dados e mídia |
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
- **`bash plugins/fundacao/hooks/test-guard-push.sh` passa inteira.** É a única
  verificação executável do repositório: 29 casos que provam que o hook bloqueia
  push para `main`, force push, deleção de branch remota e push de repositório
  inteiro (`--all`/`--mirror`/`--prune`), e libera `claude/*`. Guardrail sem
  suíte é uma afirmação, não um controle — e três desses casos existem porque o
  hook os deixava passar até 2026-08-20.

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
  commit, em inglês. A regra vale inclusive para commit feito à mão: vários
  commits de julho de 2026 a violaram — inclusive títulos de merge, que passam
  despercebidos — e é o tipo de exceção que, repetida, vira a nova convenção por
  omissão. A contagem exata não fica aqui de propósito: número no texto envelhece
  calado, e `git log` responde melhor.
- **Sanitização** — nada de caminho local absoluto, nome de cliente, token ou
  URL interna em arquivo versionado, inclusive fora do `README.md`. O índice
  acima guarda caminhos locais apenas se forem genéricos; caso contrário,
  referencie o projeto pelo nome e mantenha o caminho fora do repo.
