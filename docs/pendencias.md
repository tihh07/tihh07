# Pendências do orquestrador — backlog executável

> Checkup de 2026-08-02. Escopo: repositório público `tihh07/tihh07` e as
> rotinas agendadas que o tocam. Nenhum repositório privado foi lido (**R1**).
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
| 🏠 **Local** | Depende de acesso ao disco da máquina do projeto. Só o que a nuvem comprovadamente não alcança. |

Severidade: **alta** = risco ativo ou controle ausente · **média** = divergência
entre documentação e realidade · **baixa** = cosmético ou preventivo.

---

## 0. Rotinas em aberto

Duas rotinas semanais estão **ativas** e disparam toda segunda-feira.

| Rotina | Cron (UTC) | Escopo | Estado |
|---|---|---|---|
| Governança semanal — repo público (N2) | `0 12 * * 1` | só `tihh07/tihh07` | ✅ conforme com R1 |
| Governança Semanal — IA Control Pane | `0 11 * * 1` | o público **+ 3 privados** | ❌ viola R1 |

### P0 — A rotina de control-plane mistura repositórios privados com o público
**Severidade: alta · Executor: 👤 Humano · ABERTO**

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
depois.

**Verificação:** nenhuma rotina lista repositório público e privado
simultaneamente.

### P1 — A rotina de control-plane carrega quatro conectores
**Severidade: alta · Executor: 👤 Humano · ABERTO**

Estão anexados Gmail, Google Calendar, Google Drive e Superhuman Docs. O
blueprint exige **zero conectores por rotina** (template da seção 6; mitigação
de **R4**, *excessive agency*). Uma varredura de segredos e PII em repositório
não precisa de acesso a e-mail, agenda e drive — e conectores vêm ligados por
padrão, então isso é herança da criação, não decisão.

**Ação:** remover os quatro conectores da rotina.

**Verificação:** a rotina executa e produz o mesmo relatório sem eles.

### P2 — Prompt de rotina fora do git
**Severidade: média · Executor: ☁️ Nuvem ✅ / 👤 Humano ABERTO**

**Feito:** a rotina N2 agora tem conteúdo versionado em
[`.claude/skills/governanca-n2/SKILL.md`](../.claude/skills/governanca-n2/SKILL.md),
com a referência pendente ao `SECURITY.md` resolvida — o arquivo passou a
existir. A skill inclui dois passos que o prompt original não tinha: conferir se
alguma rotina regrediu de governança, e conferir se este backlog descreve a
realidade.

**Falta (humano):** trocar o prompt na UI da rotina pelo ponteiro —
*"Execute a skill `/governanca-n2` conforme
`.claude/skills/governanca-n2/SKILL.md`"*. Enquanto não for trocado, a versão
que roda continua sendo a da UI, e as duas vão divergir.

**Verificação:** o prompt da UI cabe em duas linhas.

> A rotina de control-plane continua com o prompt inteiro na UI. Versioná-la
> exige decidir onde a skill mora, já que o escopo dela é multi-repo — e essa
> decisão depende antes de P0.

---

## 1. Entregue neste checkup ☁️

### Correções de coerência

| # | Item | Estado |
|---|---|---|
| N1 | `README.md` não linkava o blueprint | ✅ link acrescentado na seção "AI Operating System" |
| N2 | Sem `LICENSE`, apesar de o blueprint declarar CC BY 4.0 + MIT | ✅ `LICENSE` criado nos dois regimes |
| N3 | `AGENTS.md` listava o `.gitignore` como achado aberto, já resolvido em `0242c04` | ✅ movido para histórico |
| N4 | Topologia de branches descrevia branches já apagadas | ✅ reescrita sem lista nominal — a lista envelhecia a cada merge |
| N5 | Convenção de commit em inglês não seguida | ✅ regra reafirmada em `AGENTS.md`, com a exceção nomeada |
| N7 | `reports/publicacao/` não existia | ✅ criado com formato e a regra de não reproduzir o dado |

### Auditoria dividida em nuvem + adendo local

O prompt de auditoria abria com *"rodar em cada sessão local"* — e isso, não a
nuvem, era o que mantinha quatro departamentos em *não verificado*.

Passei os seis passos contra o que uma sessão remota alcança: **os passos 1, 2,
4, 5 e 6 são integralmente executáveis na nuvem.** Só dependem de disco o Passo 0
(pastas irmãs, clones antigos, planilhas fora do repo, virtualenvs) e, do Passo 3,
commits não enviados e stashes.

- [`auditoria-fonte-de-verdade.md`](../.claude/prompts/auditoria-fonte-de-verdade.md)
  — versão de nuvem, com trava de escopo R1 no topo, entregáveis A–H, e a
  obrigação de declarar o próprio limite de alcance em vez de deduzir.
- [`auditoria-adendo-local.md`](../.claude/prompts/auditoria-adendo-local.md)
  — minutos na máquina do projeto, **condicional** ao entregável H.

### Plugin-fundação

[`plugins/fundacao/`](../plugins/fundacao/) — os oito executores da seção 5 do
blueprint, o hook de guardrail do Apêndice A, e os templates de telemetria e
watchdog. Distribuído por [`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json).

Hospedado no repositório público de propósito: o blueprint exige que o plugin
contenha **apenas templates genéricos** e nunca derive de memória de repo
privado. Um plugin público satisfaz isso por construção — não há nada privado
ali para vazar, e qualquer conteúdo derivado de repo privado apareceria na
revisão do PR.

Os agentes ficam em `plugins/`, **não** em `.claude/agents/`. A diferença
importa: em `.claude/`, seriam carregados automaticamente por toda sessão neste
repositório, mudando o comportamento do repo sem que ninguém tenha pedido.
Alterar `.claude/**` é gate humano.

**O `guard-push.sh` corrige uma falha da versão ilustrativa do blueprint.** O
snippet do Apêndice A libera o push se a string `claude/` aparecer em qualquer
ponto do comando — `echo claude/ && git push origin main` passaria. A versão
executável extrai o refspec de destino, e bloqueia também force push e deleção
de branch remota, que o snippet não cobria. Validado em 11 casos, incluindo
esse.

### Watchdog ativo

[`.github/workflows/watchdog.yml`](../.github/workflows/watchdog.yml) — diário,
sem modelo, sem chave de API, sem Action de terceiro. Detecta PR `claude/*`
parado há mais de 7 dias, branch `claude/*` sem PR aberto, e rotina morta via
`telemetry/runs.jsonl` (pula silenciosamente quando o arquivo não existe, que é
o caso aqui). O alerta é a falha do job — o GitHub notifica o dono por e-mail.

É o **único controle deste repositório que funciona hoje sem nenhuma
configuração humana pendente**, e por isso o primeiro a valer a pena. O
blueprint o classifica como item obrigatório da Fase 1 e deliberadamente fora do
ecossistema Claude — não compartilha modo de falha com aquilo que vigia.

### O que segue aberto neste bloco

**N6 — o PR Watch nunca executou.** `.github/workflows/claude-pr-watch.yml`
está ativo há duas semanas com zero runs no histórico do Actions. Depende de
`secrets.ANTHROPIC_API_KEY` (linha 57), que não existe. Não há nada a corrigir
no YAML — ele está bem escrito, com filtro de autor (R9), permissões mínimas e
concurrency. Bloqueado por **H3**.

**Verificação, quando destravar:** um `workflow_dispatch` manual conclui com
sucesso. É o teste mais barato, e só ele tira o workflow de "não verificado".

---

## 2. Exige o humano 👤

Nenhum agente executa estes itens, e essa é a intenção — são exatamente os
controles que sustentam o gate humano. A nuvem só consegue **reportar que estão
abertos**, o que este arquivo faz.

### H1 — `main` não tem proteção nem ruleset
**Severidade: alta**

A API confirma `"protected": false`. Nada impede push direto, force push ou
merge sem revisão. O gate humano do blueprint (seção 8) hoje é convenção, não
controle.

**Ação:** ruleset em `main` com PR obrigatório e "Require review from Code
Owners".

### H2 — `CODEOWNERS` é inerte
**Severidade: alta**

`.github/CODEOWNERS` cobre `/.claude/`, `/.github/`, `/docs/` e `/README.md` — a
mitigação de **R5**. O próprio arquivo avisa nas linhas 6-8 que não bloqueia
nada sem "Require review from Code Owners" ativo. Mesmo clique de H1.

> Com o plugin adicionado, `CODEOWNERS` deveria cobrir também `/plugins/` e
> `/.claude-plugin/` — é control-plane distribuível, exatamente o que R5
> protege. ☁️ A nuvem pode propor a linha; ela só passa a valer com H1.

### H3 — `ANTHROPIC_API_KEY` ausente
**Severidade: média**

Bloqueia N6. Enquanto não existir, o PR Watch é decoração.

### H4 — Secret scanning e push protection desligados
**Severidade: alta**

Num repositório público N2, push protection é a única barreira que age **antes**
de o segredo virar público. Depois do push, conteúdo público é comprometido, não
corrigível — é o que o runbook do [`SECURITY.md`](../SECURITY.md) diz.

### H5 — Pré-condições jurídicas não verificadas
**Severidade: alta**

O blueprint põe como **regra dura** antes da Fase 2 que repositórios lidos por
rotinas não contenham dado pessoal bruto nem confidencial de terceiros, e antes
da Fase 1 o opt-out de treinamento confirmado com evidência datada.

Duas rotinas semanais já estão em produção, e uma delas lê o repositório que o
próprio blueprint marca como o que toca dados comerciais sensíveis e
potencialmente pessoais (seção 5.1).

Daqui não há como verificar se as condições foram cumpridas — podem ter sido,
offline. Se não foram, a Fase 2 está rodando à frente do gate que ela mesma
declarou inegociável.

**Ação:** confirmar opt-out com evidência datada; verificar titularidade dos
dados de cada repositório no escopo das rotinas.

> H1, H2 e H4 são entrega prevista da **Fase 1**, ainda 🔜. Não são surpresa;
> são dívida declarada. O que este checkup evidencia é a **ordem invertida**: as
> automações já estão em produção enquanto os controles que deveriam contê-las
> não estão. H5 é a versão dessa inversão em que o custo de errar não é técnico.

---

## 3. Ainda em aberto ☁️ / 🏠

### L1 — Quatro departamentos nunca foram auditados
**Severidade: média · Executor: ☁️ Nuvem (uma sessão por repo)**

O índice do `AGENTS.md` tem quatro linhas em *não verificado*. Com o prompt
dividido, isso **deixou de depender de sessão local**: cada auditoria é uma
sessão na nuvem escopada em um repositório, e o adendo local só entra se o
entregável H pedir.

**Ação:** rodar a auditoria de nuvem em um projeto por vez, começando pela
Fundação — é o piloto da Fase 1. Trazer só o entregável G, sanitizado.

**Restrição:** uma sessão por repositório. Esta sessão não pode fazer nenhuma
delas — R1 vale para ela também.

### L2 — O projeto Focus não existe no mapa
**Severidade: média · Executor: 👤 Humano (decisão) depois ☁️ Nuvem**

O prompt de auditoria citava *"(GTM, Focus, etc.)"*, mas Focus não aparece no
blueprint nem no índice. O organograma da seção 3 declara cinco departamentos e
Focus não é um deles. O orquestrador não sabe que esse projeto existe — e sua
primeira pergunta é justamente *"o que existe?"*.

**Ação:** decidir se é departamento novo, subprojeto de um existente ou trabalho
fora do ecossistema. Se for departamento, criar a linha no índice com todas as
células em *não verificado* e acrescentá-lo ao organograma.

### L3 — Nada do que foi entregue hoje foi exercitado
**Severidade: média · Executor: ☁️ Nuvem + 👤 Humano**

Os oito executores foram escritos a partir da especificação e nenhum rodou em
trabalho real. O hook não foi instalado em nenhum departamento. O watchdog só
executa depois do primeiro agendamento. O plugin está em 0.1.0 e o
[README dele](../plugins/fundacao/README.md) declara isso.

É a mesma armadilha que o `oficial-governanca` existe para detectar: artefato
escrito não é controle aplicado. Vale para o que acabou de ser escrito.

**Ação:** rodar o watchdog via `workflow_dispatch` para confirmar que o job
executa; instalar o plugin no piloto e corrigir o que a realidade contradisser.

---

## Ordem sugerida

1. **P0 e P1** — os únicos itens com prazo imposto por terceiro: a rotina
   dispara sozinha, toda segunda.
2. **H1, H2, H4** — um único bloco de configuração; destrava o gate humano e
   fecha R3, R5 e R6. Aproveitar para incluir `/plugins/` no `CODEOWNERS`.
3. **H5** — verificação barata, consequência cara.
4. **L1** — quatro auditorias de nuvem, uma sessão cada, agora sem depender de
   máquina local.
5. **P2 (metade humana), H3, N6, L2, L3** — validação das automações e decisões
   de mapa.

Os itens ☁️ não dependem dos demais e podem ser executados a qualquer momento,
inclusive antes das decisões humanas.
