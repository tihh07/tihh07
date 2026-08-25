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
- **Merge por agente, com prova** — desde 2026-08-24, por autorização do dono,
  sessão de agente executa operação de GitHub aqui, **merge incluído**, sob uma
  condição que não é formalidade: teste, evidência e validação registrados no PR.
  A trava não mudou — agente **não** empurra direto para `main`, o `guard-push.sh`
  bloqueia, e tudo entra por PR com o check obrigatório verde. O controle passou a
  ser a plataforma mais o registro, não a atenção do revisor: é o que **H1-bis**
  tornou possível ao fixar `verificar` como obrigatório e sem ator de bypass.

## Frontmatter de identificação

Todo `AGENTS.md` do ecossistema abre com um bloco YAML declarando a que o
repositório pertence e o que pode sair dele — `setor`, `nivel`, `emite_pratica`,
`nunca_sai`. Os campos e o que cada um significa vivem no
[blueprint](docs/orchestration-blueprint.md#frontmatter-de-identificação), que é
a autoridade de projeto; descrevem o ecossistema, não este repositório. O valor
deste repo está no topo do arquivo.

## Índice de projetos

O índice rastreia o **estado** de cada projeto. Quais projetos existem e qual a
missão de cada um é o [blueprint](docs/orchestration-blueprint.md) (seção 3) que
define; cada linha aqui vem do bloco de handoff que a auditoria devolve.

O ecossistema tem **18 repositórios**: 17 privados e este, o único público.

| Repo | Departamento | Estado do ciclo | Última auditoria |
|---|---|---|---|
| `P01` | D1 | fechado | 2026-08-20 |
| `P02` | D2 | fechado — relato tardio, após três diagnósticos errados | 2026-08-20 |
| `P03` | D3 | fechado | 2026-08-20 |
| `P04` | D4 | fechado | 2026-08-20 |
| `P05` | não verificado | fechado | 2026-08-20 |
| `P06` | não verificado | fechado | 2026-08-20 |
| `P07` | não verificado | fechado | 2026-08-20 |
| `P08` | não verificado | fechado | 2026-08-20 |
| `P09` | não verificado | fechado | 2026-08-20 |
| `P10` | não verificado | fechado | 2026-08-20 |
| `P11` | não verificado | fechado | 2026-08-20 |
| `P12` | não verificado | fechado | 2026-08-20 |
| `P13` | não verificado | fechado | 2026-08-20 |
| `P14` | não verificado | fechado | 2026-08-20 |
| `P15` | não verificado | fechado | 2026-08-20 |
| `P16` | não verificado | em aberto — CI vermelha por dado que só uma pessoa coleta | 2026-08-20 |
| `P17` | não verificado | em aberto — ficha em correção | 2026-08-20 |
| `tihh07/tihh07` (público) | D5 | auditado — documentação, workflows e templates | 2026-08-20 |

> **Por que apelido, e não nome.** Publicar os nomes reais entregaria identidade de
> terceiro — empregador, cliente, conselho — e aciona os itens 1 e 7 do checklist do
> [`SECURITY.md`](SECURITY.md), onde a regra vive. Publicar só alguns seria pior:
> **esconder seletivamente aponta para o que está escondido**, e a omissão vira o
> índice. O mapeamento apelido → repositório mora fora daqui, num privado.
>
> O apelido é **estável**: uma vez atribuído, nunca é reciclado nem renumerado, senão
> duas leituras do mesmo índice descrevem repositórios diferentes.
>
> **A coluna de departamento passou a seguir a mesma regra em 2026-08-24.** Ela
> publicava quatro nomes reais e treze *"não declarado"* — a forma exata que este
> bloco rejeita, com a omissão virando o índice. Agora todo departamento é apelido
> (`D1`–`D5`, estáveis pela mesma razão), e célula que este repositório não conhece
> diz **"não verificado"**: ignorância declarada, não recusa de publicar. Os treze
> só se preenchem com o transporte do handoff (**L1**) — **R1** impede abrir o
> privado para descobrir.
>
> **"Auditado" não é "fechado".** As 17 auditorias de 2026-08-20 entregaram — a coluna
> de data é delas. Relatório que fica em PR não mesclado, porém, é indistinguível de
> relatório inexistente para qualquer sessão futura: por isso a coluna de estado diz
> onde o trabalho **está**, não que ele foi feito. Nenhuma célula aqui registra achado
> de conteúdo — dado sensível por repositório é justamente o que um índice público não
> pode mapear.
>
> **E "fechado" aqui é sempre relato.** Cada célula vem de uma sessão escopada naquele
> repositório ou da confirmação do dono. **R1** impede que este repositório reverifique
> qualquer uma — não há como. Ler a coluna como estado conferido é o erro que ela
> convida e que este parágrafo existe para impedir.

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
| `docs/registro-operacoes.md` | **Modelo** do registro de operações (Res. CD/ANPD 2/2022); o preenchido é N1 e mora no privado |
| `SECURITY.md` | Canônico do checklist de sanitização, da regra R1, do kill-switch e do runbook de incidente |
| `.claude/settings.json` | Permissões do projeto e instalação do hook de push |
| `.claude/prompts/` | Prompts reutilizáveis entre projetos |
| `.claude/skills/` | Conteúdo versionado das rotinas (padrão prompt-ponteiro) |
| `.claude-plugin/marketplace.json` | Manifesto do marketplace que distribui o plugin-fundação |
| `plugins/fundacao/` | Templates distribuíveis: executores, hook e sua suíte, telemetria, backup |
| `.github/workflows/` | Verificação (a cada PR, check obrigatório), watchdog semanal e backup |
| `.github/CODEOWNERS` | Donos por caminho — inerte até "Require review from Code Owners" |
| `.gitignore` · `LICENSE` | Barra segredo e dado; CC BY 4.0 no texto, MIT nos snippets |
| `reports/publicacao/` | Saída semanal da rotina N2, quando há achado |

## Build, testes e lint

Não há gerenciador de pacotes, linter nem etapa de build, e não se deve
introduzir um sem que isso seja o pedido explícito. O repositório é Markdown,
YAML, três manifestos JSON e dois shell scripts — um guardrail e a suíte que o
verifica.

**Desde 2026-08-21 essa verificação roda sozinha** em
`.github/workflows/verificacao.yml`, a cada PR para `main`. Rodá-la à mão antes
de abrir o PR continua sendo o certo — o workflow é rede, não substituto, e
descobrir a falha depois do push custa um ciclo. O que ele checa é exatamente a
lista abaixo, menos a primeira linha, que nenhuma máquina confere.

O workflow **não** verifica sanitização N2, link quebrado nem coerência de
doutrina, e o cabeçalho dele diz isso. Verde ali significa que os checks
mecânicos passaram, não que o PR é publicável.

A verificação, antes de qualquer PR:

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
  **A suíte roda num repositório descartável, nunca no diretório ambiente** — a
  branch atual daqui é `claude/*`, e o fallback do hook libera nela, o que já
  transformou um defeito real em teste verde. Se ela recusar rodar por não
  conseguir montar esse repositório, é falha fechada e proposital.

## Topologia de branches

**`main` é a única branch permanente**, e o que ela contém é o que o perfil
público mostra. Branches de trabalho saem dela, voltam por PR revisado e somem no
merge — não são listadas aqui porque `git branch -r` responde melhor e não
envelhece.

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
  os dois ocupam o mesmo orçamento, e o limite de 200 linhas que o blueprint fixa
  vale **para a soma**. Seção nova exige poda de outra: crescer sem podar empurra
  doutrina para fora do contexto de toda sessão, calado.
  **Em 2026-08-21 a soma passou de 200**, e fica dito em vez de escondido: o
  índice virou uma linha por repositório (dezoito, contra seis), que era o preço
  de parar de agregar treze estados numa célula. Foram podadas em troca a seção
  de frontmatter, que descrevia o ecossistema e foi para o blueprint, e a
  topologia de branches. O excedente se resolve em **A1**: com a doutrina de
  ecossistema no privado, o que sobra aqui é fachada pública e cabe folgado.
  Enquanto isso, o número real vale mais que o número redondo — o pecado da
  regra é o crescimento **calado**, não o crescimento. Em 2026-08-24 cresceu
  três vezes, e as três ficam ditas: **dez linhas** na nota de apelido e na
  coluna de departamento que deixou de vazar nome, e **mais cinco** na regra de
  merge por agente, mais **quatro** desta correção: a soma foi de 232 a 251.
  A primeira das três se declarou como "sete linhas" — era o tamanho da nota,
  não o do arquivo — e a segunda não se declarou. Errar a conta e omitir a
  conta produzem o mesmo resultado que esta regra existe para impedir.
  Em 2026-08-25 cresceu **oito linhas**: uma no índice de arquivos, para o
  modelo de registro de operações que o **H5.5** exigia, e sete nesta própria
  declaração. A soma foi de 251 a 259. Declarar custa mais linhas que a mudança
  declarada, e é assim mesmo: o barato seria não contar. *(Duas versões desta
  nota erraram a conta antes desta — declarar cresce o arquivo que a declaração
  mede. A regra que faltava: **escreva a nota, rode `wc -l`, e só então fixe o
  número** — o previsto está errado por construção, o medido converge.)*
- **Sanitização** — nada de caminho local absoluto, nome de cliente, token ou
  URL interna em arquivo versionado, inclusive fora do `README.md`. O índice
  acima guarda caminhos locais apenas se forem genéricos; caso contrário,
  referencie o projeto pelo nome e mantenha o caminho fora do repo.
