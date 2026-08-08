# Pendências do orquestrador — backlog executável

> Checkup de 2026-08-02, atualizado em 2026-08-08 **depois do merge do PR #8**.
> Escopo: repositório público `tihh07/tihh07` e as rotinas agendadas que o
> tocam. Nenhum repositório privado foi lido (**R1**).
>
> Nesta atualização, cada item de configuração foi reconsultado na API do GitHub
> e o estado abaixo é o que ela devolveu — não o que a rodada anterior supunha.
> Onde a consulta não foi possível, o item diz isso em vez de afirmar.
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

Em **2026-08-03 às 10:20 UTC** a rotina de control-plane foi editada, e disparou
às 11:18. A edição acrescentou duas frentes de verificação (doutrina e cobertura
de CI) e uma seção declarando o que a rotina não alcança — todas boas adições.
**Não tocou no escopo nem nos conectores**: P0 e P1 seguem abertos, e a rotina
rodou pela segunda semana consecutiva com o público e três privados juntos.

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

## 1. Entregue ☁️

Três lotes: os dois primeiros no PR #7, o terceiro no PR #8. Detalhe de cada
mudança está no corpo do PR e no log — aqui fica só o que fechou, para o backlog
não virar changelog.

**2026-08-02 — coerência e Fase 1**

| # | Item | Como fechou |
|---|---|---|
| N1 | `README.md` não linkava o blueprint | link na seção "AI Operating System" |
| N2 | Sem `LICENSE`, apesar de o blueprint declarar CC BY 4.0 + MIT | `LICENSE` nos dois regimes |
| N3 | `AGENTS.md` listava achado já resolvido em `0242c04` | movido para o backlog |
| N4 | Topologia de branches nomeava branches apagadas | reescrita sem lista nominal |
| N5 | Convenção de commit em inglês não seguida | regra reafirmada, exceção nomeada |
| N7 | `reports/publicacao/` não existia | criado com formato e regra de não reproduzir o dado |

**Auditoria dividida.** O prompt abria com *"rodar em cada sessão local"* — e era
essa frase, não um limite técnico, que mantinha quatro departamentos em *não
verificado*. Os passos 1, 2, 4, 5 e 6 do check reverso rodam na nuvem; só o
Passo 0 e os stashes do Passo 3 precisam de disco. Virou
[`auditoria-fonte-de-verdade.md`](../.claude/prompts/auditoria-fonte-de-verdade.md)
(nuvem, trava R1, entregáveis A–H) mais
[`auditoria-adendo-local.md`](../.claude/prompts/auditoria-adendo-local.md)
(condicional ao entregável H).

**Plugin-fundação** ([`plugins/fundacao/`](../plugins/fundacao/)) — oito
executores, hook de guardrail e esqueleto de telemetria. Fica no repo público
porque o blueprint exige que o plugin só contenha template genérico: um plugin
público satisfaz isso por construção. Os agentes ficam em `plugins/`, não em
`.claude/agents/`, para não mudar o comportamento de toda sessão deste repo sem
pedido.

O `guard-push.sh` corrige um buraco do snippet ilustrativo do Apêndice A, que
libera o push sempre que a string `claude/` aparece em qualquer ponto do comando
— `echo claude/ && git push origin main` passaria. Validado em 11 casos.

**Watchdog** ([`.github/workflows/watchdog.yml`](../.github/workflows/watchdog.yml))
— diário, sem modelo, sem chave de API, sem Action de terceiro. O alerta é a
falha do job, que o GitHub já notifica por e-mail. Único controle deste
repositório que funciona sem configuração humana pendente.

**2026-08-03 — doutrina e redundância**

| # | Item | Como fechou |
|---|---|---|
| N8 | Frontmatter (`setor`/`nivel`/`emite_pratica`/`nunca_sai`) fiscalizado pela rotina e documentado em lugar nenhum | seção nova no `AGENTS.md` |
| N9 | Nenhum workflow declarava o que **não** cobre — regra que a própria rotina passou a exigir | cabeçalho nos dois, incluindo o "zero runs" do PR Watch |
| N10 | Skill `governanca-n2` não checava doutrina nem cobertura de CI | passos 5 e 6, mais "o que esta rotina não alcança" |
| N11 | `templates/watchdog.yml` era cópia quase idêntica do workflow ativo | template removido; o ativo virou portável, com os quatro checks pulando sozinhos |
| N12 | Achados duplicados entre `AGENTS.md` e este arquivo | `AGENTS.md` passa a apontar para cá |

**2026-08-08 — poda (PR #8, mesclado em `1a55679`)**

| # | Item | Como fechou |
|---|---|---|
| N13 | `/auditoria-poda` era invocada e não existia — nem na UI, nem versionada | [`.claude/skills/auditoria-poda/SKILL.md`](../.claude/skills/auditoria-poda/SKILL.md), no padrão prompt-ponteiro |
| N14 | Blueprint dizia "nenhuma rotina em produção ainda", com três rodando | status corrigido |
| N15 | Backlog pedia merge do #7 e primeira run do watchdog, ambos já feitos | itens retirados |
| N16 | Topologia de branches do `AGENTS.md` voltou a envelhecer no merge seguinte | reescrita sem contagem nominal |
| N17 | Exemplo de telemetria em duas cópias sem canônico | template em `plugins/fundacao/templates/telemetry/` declarado canônico |
| N18 | `CODEOWNERS` não cobria `/plugins/` nem `/.claude-plugin/` (R5) | linhas adicionadas — valem quando H1 valer |

### O que segue aberto neste bloco

**N6 — o PR Watch acordou pela primeira vez, e o filtro de autor o barrou.**
Até 2026-08-08 o histórico tinha zero runs. Os comentários de review no PR #8
dispararam cinco eventos naquele dia, e a API mostra o desfecho de cada um:

```
Claude PR Watch | 2026-08-08T18:24:33Z | pull_request_review_comment | completed/skipped
Claude PR Watch | 2026-08-08T18:24:33Z | pull_request_review_comment | completed/cancelled
Claude PR Watch | 2026-08-08T18:24:33Z | pull_request_review_comment | completed/cancelled
Claude PR Watch | 2026-08-08T18:24:33Z | pull_request_review_comment | completed/skipped
Claude PR Watch | 2026-08-08T18:24:33Z | pull_request_review    | completed/skipped
```

O job do run mais recente reporta `claude | skipped | steps=0`: nenhum passo
chegou a existir, então o `Checkout` e a action nunca rodaram e a chave de API
nunca foi consultada. A condição `if` da linha 52 barrou tudo — os comentários
não continham `@claude`. É a **primeira evidência de campo de R9/R2**: os
eventos chegaram, e o gate de autor + menção segurou. Esse controle deixou de
ser suposição.

O que segue aberto é a outra metade: **nenhuma execução real** aconteceu, e ela
continua bloqueada por **H3**. Run que pula não exercita a action, o modelo, as
permissões nem o prompt.

**Correção junto:** o cabeçalho do workflow afirmava *"NÃO EXECUTOU NENHUMA VEZ.
Zero runs no histórico"*, o que passou a ser falso no mesmo dia em que foi
escrito. Reescrito para distinguir *acordar* de *executar* — é o tipo de frase
com data de validade que a categoria "realidade antiga" da auditoria de poda
existe para pegar.

**Verificação, quando destravar:** um `workflow_dispatch` manual conclui com
`success` e o job mostra passos executados — não `skipped`.

---
## 2. Exige o humano 👤

Nenhum agente executa estes itens, e essa é a intenção — são exatamente os
controles que sustentam o gate humano. A nuvem só consegue **reportar que estão
abertos**, o que este arquivo faz.

### H1 — `main` não tem proteção nem ruleset
**Severidade: alta · ABERTO — reverificado em 2026-08-08**

Duas consultas independentes, ambas depois do merge do PR #8:
`GET /repos/tihh07/tihh07/branches/main` devolve `protected: false`, e
`GET /repos/tihh07/tihh07/rulesets` devolve `[]`. Nada impede push direto, force
push ou merge sem revisão. O gate humano do blueprint (seção 8) hoje é
convenção, não controle — e o merge do próprio #8 é a prova: nada no
repositório o teria impedido de entrar sem revisão.

**Ação:** ruleset em `main` com PR obrigatório, e bloqueio de deleção e de
force push.

> **Sobre "Require review from Code Owners" (H2):** com um único dono, exigir
> aprovação de code owner bloqueia os PRs do próprio dono, porque o GitHub não
> aceita autoaprovação. Enquanto não houver um segundo revisor, o ruleset
> entrega o essencial de H1 — PR obrigatório, sem force push, sem deleção — e o
> H2 permanece parcialmente aberto por escolha declarada, não por esquecimento.

### H2 — `CODEOWNERS` é inerte
**Severidade: alta**

`.github/CODEOWNERS` cobre `/.claude/`, `/.github/`, `/docs/` e `/README.md` — a
mitigação de **R5**. O próprio arquivo avisa nas linhas 6-8 que não bloqueia
nada sem "Require review from Code Owners" ativo. Mesmo clique de H1.

> Com o plugin adicionado, `CODEOWNERS` cobre também `/plugins/` e
> `/.claude-plugin/` — control-plane distribuível, exatamente o que R5 protege.
> ☁️ Linhas adicionadas em 2026-08-08; como todo o arquivo, só passam a valer
> com H1.

### H3 — `ANTHROPIC_API_KEY` ausente
**Severidade: média · ABERTO — reverificado em 2026-08-08**

`GET /repos/tihh07/tihh07/actions/secrets` devolve `total_count: 0` — nenhum
secret de Actions existe no repositório. Bloqueia a metade executável de N6.

**Ação:** `gh secret set ANTHROPIC_API_KEY` **no terminal do dono**. O valor não
passa por sessão de agente nem por chat: quem cria o segredo é quem o digita.

### H4 — Secret scanning e push protection desligados
**Severidade: alta · ABERTO — reverificado em 2026-08-08**

`GET /repos/tihh07/tihh07` devolve, em `security_and_analysis`, `disabled` nos
cinco campos: `secret_scanning`, `secret_scanning_push_protection`,
`secret_scanning_non_provider_patterns`, `secret_scanning_validity_checks` e
`dependabot_security_updates`.

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

### H6 — Branch residual do PR #7 no remoto
**Severidade: média · ✅ FECHADO em 2026-08-08**

A branch `claude/session-status-pendencias-842ocg` foi apagada no remoto junto
com o merge do PR #8. O `git fetch --prune` registrou as duas deleções:

```
- [deleted]  (none) -> origin/claude/auditoria-poda-cjh5ba
- [deleted]  (none) -> origin/claude/session-status-pendencias-842ocg
```

**Verificação cumprida:** `git branch -r` devolve apenas `origin/HEAD` e
`origin/main`. Nenhuma branch órfã restou, e o check "branches `claude/*` sem
PR aberto" do watchdog não tem mais motivo para falhar a partir de 08-11 — o
alerta previsto foi evitado antes de existir.

Fica o registro do padrão, que é o que interessa reter: o item nasceu porque a
branch do PR #7 sobreviveu ao merge. Apagar no ato do merge (`--delete-branch`,
ou o botão "Delete branch" na página do PR) é o que impede a categoria 4 da
auditoria de poda de reaparecer todo ciclo.

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

### L2 — O índice publicado tem o formato errado, não só linhas faltando
**Severidade: alta · Executor: 👤 Humano (decisão) depois ☁️ Nuvem**

A edição da rotina de control-plane em 2026-08-03 revelou uma realidade
operacional que este repositório não descreve:

| O que a rotina fiscaliza | O que este repositório publica |
|---|---|
| ~18 repositórios no ecossistema | 5 departamentos |
| 6 setores, declarados no frontmatter `setor:` | 5 departamentos com outros nomes |
| `/checkup` manual, bundle de backup, clone local | não documentado |

O orquestrador existe para responder *"o que existe?"*, e a resposta publicada
descreve um recorte de 5 num universo de ~18, organizado por uma taxonomia que
já não é a que está em uso. Não é o índice incompleto — é o eixo do índice que
está errado.

Isso também resolve o antigo item "Focus não existe no mapa": **Focus é um dos
setores**, e o prompt de auditoria já o citava porque quem escreveu o prompt
sabia disso. O mapa é que não sabia.

**Ação (humana, primeiro):** decidir se os nomes de setor podem ser publicados.
Alguns parecem nomes de organização, o que aciona os itens 1 (nomes) e 7
(titularidade) do checklist do [`SECURITY.md`](../SECURITY.md). Publicar a
taxonomia sem essa decisão é exatamente o tipo de vazamento que a rotina N2
procura.

**Ação (nuvem, depois):** reeixar o índice para setor × repositórios, marcar os
que estão fora de qualquer rotina, e reconciliar o organograma da seção 3 do
blueprint com a taxonomia real.

**Verificação:** o número de repositórios declarados no índice bate com o número
que existe, e cada um tem setor.

### L4 — ~14 repositórios estão fora de qualquer rotina
**Severidade: média · Executor: 👤 Humano**

A própria rotina de control-plane declara que o ecossistema tem ~18
repositórios e que ela vê 4. Os demais não são cobertos por nenhuma varredura
de segredos, PII ou doutrina — e ampliar a cobertura exige anexar fontes na
configuração da rotina, que é clique humano.

Vale decidir antes se a resposta é uma rotina com mais fontes ou várias rotinas
menores: uma rotina única com 18 repositórios anexados aumenta o raio de
qualquer erro dela, e reencontra o problema de P0 numa escala maior.

### L3 — Executores e hook seguem não exercitados
**Severidade: média · Executor: ☁️ Nuvem + 👤 Humano**

**Parcialmente fechado pela realidade (2026-08-08):** com o merge do PR #7 em
2026-08-03, o watchdog entrou em produção e executou por agendamento cinco dias
seguidos (2026-08-04 a 2026-08-08), todos verdes. "Confirmar que o job executa"
deixou de ser pendência.

O resto continua aberto: os oito executores foram escritos a partir da
especificação e nenhum rodou em trabalho real; o hook não foi instalado em
nenhum departamento; o plugin está em 0.1.0 e o
[README dele](../plugins/fundacao/README.md) declara isso.

É a mesma armadilha que o `oficial-governanca` existe para detectar: artefato
escrito não é controle aplicado. Vale para o que acabou de ser escrito.

**Ação:** instalar o plugin no piloto e corrigir o que a realidade contradisser.

#### L3.1 — O `guard-push` depende de `jq`, ausente na máquina local
**Severidade: média · Executor: 👤 Humano (instalar) · ABERTO — achado em 2026-08-08**

Primeira execução do hook fora de teste sintético, na máquina Windows do dono:

```
guard-push: jq não encontrado; bloqueando por precaução.  exit=2
```

`command -v jq` não devolve nada, e não há binário em `/usr/bin` nem em
`/mingw64/bin` do Git Bash. O hook declara na linha 19 que **falha fechada**, e
falhou exatamente como prometido — o comportamento está certo. O problema é a
consequência: instalado assim, ele bloqueia *todo* push, inclusive os
`claude/*` que deveria liberar. Um guardrail que nega tudo é indistinguível de
um guardrail quebrado, e o primeiro reflexo de quem for bloqueado é desinstalar
o hook.

A lógica em si está íntegra. Com um `jq` mínimo no `PATH`, os doze casos passam:
bloqueia push para `main` e `master`, o bypass `echo claude/ && git push origin
main`, force push e `--force-with-lease` mesmo em `claude/*`, deleção por
`--delete` e por refspec `:branch`, e destino fora de `claude/*`; libera
`claude/*`, `-u`, `HEAD:claude/*` e comando que não é push.

**Ação:** instalar `jq` antes de habilitar o hook em qualquer departamento
(`winget install jqlang.jq`, ou o pacote do Git Bash). Vale como pré-requisito
declarado do plugin, não como defeito dele.

**Verificação:** `command -v jq` devolve um caminho, e o hook passa a liberar
`git push origin claude/<algo>` em vez de bloquear por precaução.

---

## Ordem sugerida

1. **P0 e P1** — os únicos itens com prazo imposto por terceiro: a rotina
   dispara sozinha toda segunda, e já foram duas semanas em violação. A próxima
   é **2026-08-10**, dois dias depois desta atualização.
2. **H1, H2, H4** — um único bloco de configuração; destrava o gate humano e
   fecha R3, R5 e R6. As linhas de `/plugins/` e `/.claude-plugin/` no
   `CODEOWNERS` já existem e passam a valer junto. Comandos prontos no
   apêndice abaixo.
3. **L2** — a decisão de sanitização da taxonomia; sem ela o índice continua
   descrevendo um ecossistema que não existe mais.
4. **H5** — verificação barata, consequência cara.
5. **L1 e L4** — cobertura: auditar os quatro conhecidos, decidir o que fazer
   com os ~14 restantes.
6. **P2 (metade humana), H3, N6, L3** — validação das automações.

O antigo passo 2 — merge do PR #7 e primeira execução do watchdog — foi cumprido
em 2026-08-03/04 e saiu da lista (ver L3).

Os itens ☁️ não dependem dos demais e podem ser executados a qualquer momento,
inclusive antes das decisões humanas.

---

## Apêndice — comandos do bloco H1/H4

Ficam registrados aqui porque a doutrina exige que o clique seja humano, não que
o humano redija o comando. Rodam no terminal do dono, com `gh` autenticado.

**H1 — ruleset em `main`:** PR obrigatório, sem force push, sem deleção.

```bash
gh api repos/tihh07/tihh07/rulesets -X POST --input - <<'EOF'
{"name":"protect-main","target":"branch","enforcement":"active","conditions":{"ref_name":{"include":["~DEFAULT_BRANCH"],"exclude":[]}},"rules":[{"type":"deletion"},{"type":"non_fast_forward"},{"type":"pull_request","parameters":{"required_approving_review_count":0,"dismiss_stale_reviews_on_push":false,"require_code_owner_review":false,"require_last_push_approval":false,"required_review_thread_resolution":false,"allowed_merge_methods":["merge","squash"]}}]}
EOF
```

`required_approving_review_count: 0` e `require_code_owner_review: false` são
deliberados enquanto houver um único dono — ver a nota em H1. Com um segundo
revisor, subir os dois é uma edição de uma linha cada.

**H4 — secret scanning e push protection:**

```bash
gh api -X PATCH repos/tihh07/tihh07 --input - <<'EOF'
{"security_and_analysis":{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}}
EOF
```

**Verificação dos dois, em um comando:**

```bash
gh api repos/tihh07/tihh07/rulesets --jq 'length'; gh api repos/tihh07/tihh07 --jq '.security_and_analysis'
```

Fecha quando o primeiro devolve `1` e os dois campos de `secret_scanning`
aparecem como `enabled`.
