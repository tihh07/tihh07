# Pendências do orquestrador — backlog executável

> Checkup de 2026-08-02 (domingo). Escopo: repositório público `tihh07/tihh07`
> e as rotinas agendadas que o tocam. Nenhum repositório privado foi lido
> (regra **R1**).
>
> Este arquivo responde à terceira pergunta do [`AGENTS.md`](../AGENTS.md) —
> *o que está pendente?* — num formato em que cada item é **auto-contido**:
> tem evidência, ação e critério de verificação, para que uma sessão na nuvem
> execute sem depender de contexto de nenhuma sessão local.

## Como ler

Cada item tem um **executor**, e é isso que determina se a nuvem resolve sozinha:

| Executor | Significado |
|---|---|
| ☁️ **Nuvem** | Uma sessão remota resolve inteira: edita, commita em `claude/*`, abre PR. |
| 👤 **Humano** | Exige clique na UI do GitHub ou do Claude. Nenhum agente tem essa permissão — e não deve ter. |
| 🏠 **Local** | Depende de rodar a auditoria na sessão local do projeto de origem (R1 proíbe fazer daqui). |

Severidade: **alta** = risco ativo ou controle ausente · **média** = divergência
entre documentação e realidade · **baixa** = cosmético ou preventivo.

---

## 0. Rotinas em aberto

Duas rotinas semanais estão **ativas** e disparam toda segunda-feira. Ambas
rodaram pela última vez em 2026-07-27 e voltam a rodar em 2026-08-03.

| Rotina | Cron (UTC) | Escopo | Estado |
|---|---|---|---|
| Governança semanal — repo público (N2) | `0 12 * * 1` | só `tihh07/tihh07` | ✅ conforme com R1 |
| Governança Semanal — IA Control Pane | `0 11 * * 1` | o público **+ 3 privados** | ❌ viola R1 |

### P0 — A rotina de control-plane mistura repositórios privados com o público
**Severidade: alta · Executor: 👤 Humano**

A rotina "IA Control Pane" tem no escopo, na mesma execução, o repositório
público e três repositórios privados. O
[blueprint](orchestration-blueprint.md) proíbe isso em dois lugares
independentes: a regra **R1** da matriz de riscos (seção 8) e a linha
"Repos no escopo" do template de rotina (seção 6) — *"nunca privados + público
na mesma rotina"*. É o canal exato pelo qual conteúdo privado atravessa para o
lado público.

A rotina do repo público, criada depois, já nasceu correta e inclusive declara
no próprio prompt que ignora os outros repositórios do ambiente. A de
control-plane é anterior e não recebeu esse tratamento.

**Ação:** remover `tihh07/tihh07` das fontes da rotina de control-plane — a
cobertura do repo público já está garantida pela rotina N2, que roda uma hora
depois. Alternativa equivalente: manter os privados e deixar o público
exclusivamente com a rotina N2.

**Verificação:** nenhuma rotina lista repositório público e privado
simultaneamente.

**Prazo real:** a próxima execução é 2026-08-03 11:00 UTC. Depois disso, a
violação se repete por mais uma semana.

### P1 — A rotina de control-plane carrega quatro conectores
**Severidade: alta · Executor: 👤 Humano**

Estão anexados Gmail, Google Calendar, Google Drive e Superhuman Docs. O
blueprint exige **zero conectores por rotina** (template da seção 6; mitigação
de **R4**, *excessive agency*), adicionando só o estritamente necessário. Uma
varredura de segredos e PII em repositório não precisa de acesso a e-mail,
agenda e drive — e conectores vêm ligados por padrão, então isso é herança da
criação, não decisão.

**Ação:** remover os quatro conectores da rotina.

**Verificação:** a rotina executa e produz o mesmo relatório sem eles.

### P2 — Os prompts das rotinas vivem só na UI, não no git
**Severidade: média · Executor: ☁️ Nuvem (redação) + 👤 Humano (troca do prompt)**

O blueprint define o padrão **prompt-ponteiro → skill versionada** (seção 6)
justamente contra drift: o prompt na UI deveria ser uma linha apontando para
uma skill commitada, e todo o conteúdo real ficaria em
`.claude/skills/<nome>/SKILL.md`, revisável por PR e com hash registrado por
run. Hoje as duas rotinas carregam o prompt inteiro na UI — não versionado, não
revisável, não auditável, e perdido se a rotina for recriada.

Um sintoma já visível: o prompt da rotina N2 invoca *"a regra dura do
`SECURITY.md` do ecossistema"*, e **não existe `SECURITY.md` neste
repositório**. O prompt referencia um artefato que a sessão não consegue abrir.

**Ação (nuvem):** criar `.claude/skills/governanca-n2/SKILL.md` com o conteúdo
atual do prompt N2, corrigindo a referência pendente, e abrir PR.
**Ação (humano):** depois do merge, trocar o prompt da rotina pelo ponteiro.

**Verificação:** o prompt da UI cabe em duas linhas e o conteúdo está no git.

---

## 1. Executável 100% pela sessão na nuvem ☁️

Estes itens não dependem de nenhuma sessão local, de nenhum repositório privado
e de nenhuma decisão que ainda não esteja escrita. Cada um é um PR pequeno,
independente dos demais.

### N1 — O `README.md` não dá porta de entrada para o blueprint
**Severidade: média**

O `README.md` é o que o GitHub renderiza no perfil. Ele não linka
`docs/orchestration-blueprint.md` — o artefato público mais substancial do
repositório fica inalcançável para quem chega pelo perfil. Achado aberto desde
a auditoria de 2026-07-27 (`AGENTS.md:83`).

**Ação:** acrescentar o link na seção "AI Operating System" (`README.md:17-21`),
que já fala do repositório privado e do case em preparação — é onde o leitor
está buscando exatamente isso.

**Verificação:** o link aparece no `README.md` e resolve no GitHub.

### N2 — Falta `LICENSE` no repositório
**Severidade: média**

O blueprint declara no cabeçalho (`docs/orchestration-blueprint.md:5`) texto sob
CC BY 4.0 e snippets sob MIT, mas a raiz não tem nenhum arquivo de licença. Sem
ele o GitHub não exibe licença nenhuma, e o padrão legal de um repositório
público sem `LICENSE` é *todos os direitos reservados* — o oposto do que o
documento afirma.

**Ação:** criar `LICENSE` refletindo a declaração já feita no blueprint, sem
inventar termos novos.

**Verificação:** o GitHub passa a exibir a licença no cabeçalho do repositório.

### N3 — `AGENTS.md` lista como pendente um achado já resolvido
**Severidade: média**

`AGENTS.md:86` ainda registra *"Nenhum `.gitignore` versionado"* como achado
aberto. O `.gitignore` foi criado no commit `0242c04` — o **mesmo commit** que
adicionou o texto do achado. A doutrina operacional descreve uma realidade que
já não existe, que é precisamente o defeito que o orquestrador deveria detectar
nos outros projetos.

**Ação:** remover o bullet e, se valer registro histórico, mover para uma linha
de "resolvido em `0242c04`".

**Verificação:** nenhum achado listado como aberto tem correção já mesclada.

### N4 — A topologia de branches descreve branches que não existem mais
**Severidade: média**

`AGENTS.md:115-127` descreve `claude/ci-pr-watch` e
`claude/repo-orchestration-agent-bjjsff` como parte da topologia. No remoto
existe **apenas `main`** — as duas foram apagadas após o merge. A seção também
não menciona `claude/agents-md-canonico`, terceira branch de trabalho, mesclada
pelo PR #6.

**Ação:** reescrever a seção afirmando o estado atual (`main` é a única branch
viva; branches de trabalho são efêmeras e apagadas após merge) e mover o
histórico de PRs para uma frase, não para uma lista de branches vivas.

**Verificação:** `git branch -r` bate com o que a seção afirma.

### N5 — A convenção de idioma de commit não está sendo seguida
**Severidade: baixa**

`AGENTS.md` fixa: documentação em português, **mensagens de commit em inglês**.
Os dois commits mais recentes de `main` (`85a84ca`, `0242c04`) estão em
português. Ou a convenção vale e os próximos commits a seguem, ou ela não
descreve a prática e deve mudar.

**Ação:** decidir uma das duas e deixar o `AGENTS.md` coerente com a prática.
Como é uma escolha de preferência, não de correção, a nuvem propõe e o humano
confirma no PR.

**Verificação:** os commits seguintes ao merge seguem o que o arquivo diz.

### N6 — O workflow PR Watch nunca executou
**Severidade: média**

`.github/workflows/claude-pr-watch.yml` está ativo há duas semanas e o
histórico de execuções do Actions está **vazio** (zero runs). O workflow depende
de `secrets.ANTHROPIC_API_KEY` (linha 57), e a auditoria de 2026-07-27 registrou
que esse secret não existe. Não há evidência de que o workflow funcione: ele
nunca foi exercido nem em sucesso nem em falha.

**Ação (nuvem):** nada a corrigir no YAML — ele está bem escrito, com filtro de
autor (R9), permissões mínimas e concurrency.
**Ação (humano):** ver H3 abaixo. Enquanto o secret não existir, a decisão
honesta é registrar o workflow como *não validado* em vez de tratá-lo como
controle ativo.

**Verificação:** um `workflow_dispatch` manual conclui com sucesso — é o teste
mais barato, e só ele tira o workflow do estado "não verificado".

### N7 — A saída em `reports/` que as rotinas prometem nunca foi exercida
**Severidade: baixa**

O prompt da rotina N2 manda gravar achados em
`reports/publicacao/AAAA-SS.md`, commitar em `claude/relatorio-publico-AAAA-SS`
e abrir PR. A execução de 2026-07-27 encontrou três achados reais — e o
diretório `reports/` não existe, nenhuma branch foi criada e nenhum PR foi
aberto. Os achados chegaram ao `AGENTS.md` por edição manual dois dias depois.

Ou seja: o caminho automatizado de saída nunca foi provado, e a única razão de
os achados não terem se perdido foi intervenção manual.

**Ação:** ao versionar a skill (P2), incluir a criação de `reports/publicacao/`
com um `README.md` explicando o formato, para que a primeira gravação real não
seja também o primeiro teste do caminho.

**Verificação:** a próxima execução com achado produz PR sem intervenção.

---

## 2. Exige o humano 👤

Nenhum agente pode executar estes itens, e essa é a intenção — são exatamente os
controles que sustentam o gate humano. A nuvem só consegue **reportar que estão
abertos**, o que este arquivo faz.

### H1 — `main` não tem proteção nem ruleset
**Severidade: alta**

A API confirma `"protected": false`. Não há nada impedindo push direto, force
push ou merge sem revisão. O gate humano do blueprint (seção 8) hoje é
convenção, não controle.

**Ação:** ativar ruleset em `main` com PR obrigatório e "Require review from Code
Owners".

### H2 — `CODEOWNERS` é inerte
**Severidade: alta**

`.github/CODEOWNERS` existe e cobre `/.claude/`, `/.github/`, `/docs/` e
`/README.md` — a mitigação de **R5**. O próprio arquivo avisa nas linhas 6-8 que
não bloqueia nada sem "Require review from Code Owners" ativo. Resolve junto com
H1; são o mesmo clique.

### H3 — `ANTHROPIC_API_KEY` ausente
**Severidade: média**

Bloqueia N6. Enquanto não existir, o PR Watch é decoração.

### H4 — Secret scanning e push protection desligados
**Severidade: alta**

Num repositório público N2, push protection é a única barreira que age **antes**
do segredo virar público. Depois do push, conteúdo público deve ser tratado como
comprometido, não como corrigível — é o que o runbook da própria rotina N2 diz.

> H1, H2 e H4 são entrega prevista da **Fase 1** do roadmap, ainda 🔜. Não são
> surpresa; são dívida declarada. O que muda com este checkup é que as rotinas
> **já estão em produção** enquanto os controles que deveriam contê-las não
> estão. A ordem do roadmap está invertida na prática.

---

## 3. Depende de sessão local 🏠

### L1 — Quatro dos cinco departamentos nunca foram auditados
**Severidade: média**

O índice do `AGENTS.md` tem quatro linhas inteiras em *não verificado*. Só
`tihh07/tihh07` foi auditado. O ciclo previsto é: abrir sessão local no projeto,
rodar [`.claude/prompts/auditoria-fonte-de-verdade.md`](../.claude/prompts/auditoria-fonte-de-verdade.md),
e trazer só o entregável **G** sanitizado para cá.

Isso **não pode** ser feito por esta sessão: R1 proíbe misturar privado e
público na mesma sessão.

**Ação:** rodar a auditoria em um projeto por vez e trazer o resumo. O piloto da
Fase 1 é a Fundação — é a primeira linha a preencher.

### L2 — O projeto Focus não existe no mapa do orquestrador
**Severidade: média**

O prompt de auditoria cita *"(GTM, Focus, etc.)"* na linha 3, mas **Focus não
aparece em lugar nenhum** do blueprint nem do índice de projetos. O organograma
da seção 3 declara cinco departamentos e Focus não é um deles.

O orquestrador não sabe que esse projeto existe — e sua primeira pergunta é
justamente *"o que existe?"*.

**Ação:** decidir se Focus é departamento novo, subprojeto de um existente ou
trabalho fora do ecossistema. Se for departamento, criar a linha no índice com
todas as células em *não verificado* e acrescentá-lo ao organograma do
blueprint.

---

## Ordem sugerida

1. **P0 e P1** — antes de segunda-feira 11:00 UTC. São os únicos itens com prazo
   imposto por terceiro: a rotina dispara sozinha.
2. **H1, H2, H4** — um único bloco de configuração; destrava o gate humano e
   fecha R3, R5 e R6.
3. **N1 a N5** — um PR de nuvem, coerência de documentação, sem dependências.
4. **P2, N6, N7, H3** — validação das automações; depende de H3 para o workflow.
5. **L1 e L2** — projeto a projeto, no ritmo das sessões locais.

Os itens do bloco ☁️ não dependem de nenhum dos outros e podem ser executados
por uma sessão remota a qualquer momento, inclusive antes das decisões humanas.
