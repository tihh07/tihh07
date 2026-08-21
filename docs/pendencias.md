# Pendências do orquestrador — backlog executável

> Checkup de 2026-08-02, reverificado em **2026-08-20**. Escopo: repositório
> público `tihh07/tihh07` e as rotinas agendadas que o tocam. Nenhum repositório
> privado foi lido (**R1**) — as referências a eles aqui são texto.
>
> Cada item foi reconsultado nesta data. O que a consulta devolveu está escrito
> como fato; o que a consulta **não alcançou** está escrito como não verificado,
> com o motivo. Esta rodada mudou a natureza do arquivo num ponto: descobriu-se
> que uma classe inteira de itens não é reverificável a partir da nuvem, e isso
> ganhou [seção própria](#o-que-a-nuvem-não-alcança--e-por-quê).

## Placar em 2026-08-20

**Fechados nesta rodada**

| Item | O que a reverificação encontrou |
|---|---|
| **P0** — rotina de control-plane misturava público e privados | ✅ corrigido pelo humano na UI em **2026-08-10**. O escopo da rotina hoje tem **apenas repositórios privados**; o público saiu das fontes. O prompt passou a declarar que o repositório público nunca deve entrar no escopo e que, se aparecer, esse é o achado principal do relatório. A violação de **R1** acabou. |
| **P1** — rotina carregava conectores | ✅ corrigido junto. A rotina não tem **nenhum** conector anexado, que é o que o blueprint exige (mitigação de **R4**). |
| **N19** — este arquivo era um mapa de fraquezas | ✅ corrigido nesta reescrita — ver o lote de 2026-08-20 em [Entregue](#1-entregue-️). |

**Reclassificados — não são o que o arquivo dizia que eram**

| Item | Antes | Agora |
|---|---|---|
| **H1** — proteção de `main` | "fechado, ruleset ativo, bypass nunca" | 🔴 **verificado em 2026-08-21, e é mais fraco do que se afirmava.** O ruleset existe, está ativo e não tem bypass — isso era verdade. Mas ele exige **PR sem exigir aprovação nenhuma**, e não exige revisão de code owner. Ver **H1-bis**. |
| **H4** — secret scanning e push protection | "fechado, ambos `enabled`" | 🟡 **não verificável pela nuvem**. O que se provou hoje é que o GitHub Advanced Security está **desligado** — o que é um flag distinto do secret scanning gratuito de repositório público. Push protection não foi verificado por via nenhuma. |
| **L1** — quatro departamentos nunca auditados | "bloqueado por R1" | 🟢 **em voo**. Em 2026-08-20 foram despachadas **17 sessões de nuvem, uma por repositório privado**, cada uma escopada num único repositório. O que falta deixou de ser a auditoria e passou a ser o **transporte** do handoff. |
| **L4** — ~14 repositórios fora de rotina | "~18 no ecossistema, 4 cobertos" | 🔴 **cobertura recorrente**, não cobertura pontual. São **18 repositórios** (17 privados + o público); a rodada de hoje dá cobertura pontual a todos, e a maioria segue fora de qualquer rotina agendada. |
| **P2** — prompt de rotina fora do git | "falta a rotina N2" | 🟡 a reverificação mostrou que **as duas** rotinas tinham o prompt inteiro na UI, não uma. A N2 foi convertida em ponteiro no mesmo dia; a de control-plane segue. |

**Abertos**

| Item | Estado | Por quê |
|---|---|---|
| **V1** — configuração não é reverificável pela nuvem | ❌ aberto | política de egresso, não falta de credencial — [seção abaixo](#o-que-a-nuvem-não-alcança--e-por-quê) |
| **P2** — prompt de rotina só na UI | 🟡 metade | N2 fechada em 2026-08-20; control-plane depende de decidir onde a skill mora |
| **H1-bis** — `main` exige PR, mas zero aprovação | ❌ **aberto, severidade alta** | descoberto ao reconectar a autorização |
| **H4** — secret scanning e push protection | 🟡 parcial | campo ausente na resposta da API; só a UI responde |
| **H2** — `CODEOWNERS` exigível | 🟡 parcial | trava em ter um único dono, não em ação |
| **H3** — segredo de Actions para o PR Watch | ❌ aberto | proibido a agente por regra de conduta, não por ferramenta |
| **H5 · L2 · L4** | ❌ aberto | decisão humana |
| **L1** — consolidação dos handoffs | 🟢 em voo | 17 fichas gravadas na origem em 2026-08-21; 3 relatórios não localizados barram 3 linhas do índice |
| **L3** — executores e hook não exercitados | ❌ aberto | depende do retorno de L1 |
| **N6** — PR Watch nunca executou de verdade | ❌ aberto | bloqueado por **H3** |

Os abertos **não são resíduo de esforço**: cada um está preso a um limite
declarado — política de rede, permissão de ferramenta, regra de conduta ou
decisão humana. A distinção importa porque backlog que mistura "falta fazer" com
"não pode ser feito assim" treina o leitor a ignorar os dois.

O que esta rodada acrescenta é uma terceira categoria, que o arquivo até hoje não
tinha: **"foi dado como fechado e não era verificável"**. H1 e H4 estavam
marcados como fechados com base numa consulta que hoje não se repete. Não há
indício de que os controles tenham sido desligados — há a constatação de que
ninguém, daqui, pode afirmar que estão ligados.

## O que a nuvem não alcança — e por quê

Esta seção existe porque metade do backlog dependia da frase *"uma sessão futura
reverifica"*, e essa sessão futura não consegue.

Verificado em 2026-08-20, a partir de uma sessão de nuvem:

- O binário `gh` **não existe** neste ambiente (`command -v gh` devolve vazio).
  Todo comando do apêndice antigo era inexecutável aqui.
- Os caminhos de configuração de repositório da API do GitHub devolvem **HTTP
  403, mesmo com token válido** (o mesmo token responde `200` em identidade).
  **Mas não pela mesma causa** — e a rodada de 2026-08-20 tratou as duas como
  uma só, o que era impreciso:

  | Caminho | Mensagem literal | Causa | Tem conserto? |
  |---|---|---|---|
  | dados do repositório, rulesets, proteção de branch | *"GitHub access is not enabled for this session. An org admin must connect the Claude GitHub App"* | autorização do GitHub App | **sim, humano** |
  | alertas de secret scanning, segredos de Actions | *"Access to this GitHub API path is not permitted through this proxy"* | allowlist do proxy | não |

  A primeira linha muda de estado se a autorização do GitHub for reconectada —
  e aí **H1 volta a ser verificável**. A segunda não muda. Escopo de token não é
  o problema em nenhuma das duas: pedir permissão maior não destrava nada e só
  amplia agência à toa.
- Nenhuma ferramenta MCP disponível expõe ruleset ou proteção de branch.
- A ferramenta de secret scanning recusa com *"Repository does not have GitHub
  Advanced Security enabled"* — o que prova o estado do GHAS e nada além dele.

**Consequência:** ruleset, proteção de branch, secret scanning, push protection e
existência de segredo de Actions não são alcançáveis por agente algum a partir da
nuvem. Não é uma limitação desta sessão nem uma regra de conduta que se possa
argumentar: é a rede.

Todo item que dependia de reverificação por sessão de nuvem precisa de um
substituto. Há dois realistas, e eles não são excludentes:

1. **Conferência humana na UI** — cinco minutos, responde tudo, não escala e
   depende de alguém lembrar.
2. **Um workflow do Actions** rodando dentro do próprio repositório, com o token
   nativo da execução, que **não passa pelo proxy**. Publicaria o estado da
   configuração como saída de job, e a partir daí a nuvem lê o que sempre pôde
   ler: o resultado de um workflow. É o item **V1**.

Enquanto nenhum dos dois existir, a regra deste arquivo passa a ser: **nenhuma
sessão de nuvem escreve "fechado" em item de configuração**. Escreve, no máximo,
"não verificável daqui, conferir na UI".

## Retomada — por onde a próxima sessão começa

Escrito no fim de 2026-08-20 para que a sessão seguinte não precise reconstruir
contexto nenhum.

**1. Não tente reverificar configuração. Você não consegue.** Leia a seção acima
antes de gastar uma hora descobrindo o 403 de novo. Se o estado de `main`, do
secret scanning ou dos segredos importar para a sua tarefa, o caminho é pedir a
conferência ao humano ou implementar **V1** — não insistir na API.

**2. O que mudou desde a rodada anterior, e é bom:** P0 e P1 fecharam. A rotina
de control-plane foi corrigida na UI em 2026-08-10 e hoje não toca o repositório
público nem carrega conectores. O item de risco alto com prazo imposto de fora,
que dominou três semanas deste backlog, não existe mais.

**3. O estado do repositório está limpo, verificado hoje:** uma única branch
remota (`main`), zero resíduo — todas as `claude/*` foram apagadas no merge.
Zero PRs abertos; os dez PRs existentes (#1–#10) estão todos mesclados. O item
"um PR pode estar esperando merge", que abria a retomada anterior, saiu por ter
sido cumprido.

**4. Há 17 auditorias em voo, e o gargalo é o transporte.** Cada sessão grava o
relatório no repositório que auditou e abre PR draft lá. **Nenhuma escreve
aqui** — R1 continua valendo, e é por isso que o bloco de handoff sanitizado
precisa ser trazido por um humano. Enquanto não for, o índice do `AGENTS.md`
continua em *não verificado* apesar de o trabalho já ter sido feito.

**5. O resto do backlog não mudou de natureza.** H3 é proibido a agente por
conduta; H5, L2 e L4 são decisão humana; L3 depende de o handoff de L1 chegar.
Nenhum deles é trabalho parado por falta de execução.

### Achados que pertencem a outros repositórios

Registrados aqui porque a segunda pergunta do [`AGENTS.md`](../AGENTS.md) é
*onde está a verdade* e a terceira é *o que está pendente* — mas o trabalho é do
repositório de origem, não deste.

- **Um repositório privado acumulava nove branches `claude/*` sem PR aberto**
  (verificado em 2026-08-08, **não reverificado desde então** — R1 impede
  daqui). É o padrão do H6 multiplicado: se o watchdog for instalado lá, falha
  todo dia até a poda. A auditoria em voo desse repositório deve pegá-lo.
- **A rotina de fechamento de sessão (configuração global, fora deste repo)
  monta o arquivo de hashes com um glob que não casa quando o projeto não tem
  zip de insumos.** O comando sai com erro e grava o arquivo pela metade — foi
  contornado à mão. Reincide em todo projeto sem insumos zipados.
- **A mesma rotina afirma uma convenção de nome de arquivo que o diretório
  contradiz** — a proporção real é de maioria, não de convenção única.
  Categoria "realidade antiga".

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

**Sobre o que este arquivo publica.** Ele vive num repositório público N2. Por
isso registra *qual* controle existe, *onde* se confere e *o que* falta — e não
publica horário de disparo de rotina, identificador de controle, lista de
conectores nem comando pronto de desativação. Onde um controle tiver rota de
saída, o arquivo diz que ela existe e onde encontrá-la. O motivo está em **N19**.

---

## 0. Rotinas em aberto

Duas rotinas semanais de governança estão **ativas**: uma escopada só neste
repositório público (N2) e uma de control-plane, escopada só em repositórios
privados. Nenhuma das duas mistura os dois lados — foi essa mistura que P0
descreveu e que foi corrigida.

### P0 — A rotina de control-plane misturava privados com o público
**Severidade: alta · Executor: 👤 Humano · ✅ FECHADO em 2026-08-10**

A rotina tinha, na mesma execução, o repositório público e repositórios
privados. O [blueprint](orchestration-blueprint.md) proíbe isso em dois lugares
independentes: a regra **R1** da matriz de riscos (seção 8) e a linha "Repos no
escopo" do template de rotina (seção 6) — *"nunca privados + público na mesma
rotina"*. Era o canal exato pelo qual conteúdo privado atravessaria para o lado
público.

**Como fechou:** o humano editou a rotina na UI em **2026-08-10** — exatamente o
caminho que este item previa, e o único que existia. Hoje o escopo tem apenas
repositórios privados. Além da correção do escopo, o prompt passou a declarar
explicitamente que o repositório público nunca deve entrar no escopo e que, se
aparecer, isso é o achado principal do relatório. A correção não só removeu a
violação: deixou um detector para a reincidência.

**Verificação cumprida:** nenhuma rotina lista repositório público e privado
simultaneamente.

> Fica o registro do que este item custou para provar. Três canais de agente
> foram testados em 2026-08-08 e nenhum alcançava a configuração das rotinas da
> nuvem — o que é o desenho pedido pelo blueprint, não um defeito. O "👤 Humano"
> deixou de ser doutrina e passou a ser o que a ferramenta impõe. O custo foi a
> latência: o item ficou aberto por três disparos semanais até o clique
> acontecer. Quando o executor é humano, a pendência anda na velocidade de quem
> lembra dela — e é por isso que este arquivo existe.

### P1 — A rotina de control-plane carregava conectores
**Severidade: alta · Executor: 👤 Humano · ✅ FECHADO em 2026-08-10**

A rotina vinha com conectores de produtividade anexados por herança da criação —
acesso que uma varredura de segredos e PII em repositório não usa para nada. O
blueprint exige **zero conectores por rotina** (template da seção 6; mitigação de
**R4**, *excessive agency*).

**Como fechou:** na mesma edição de P0. A rotina hoje não tem nenhum conector
anexado.

**Verificação cumprida:** a rotina executa e produz o mesmo relatório sem eles —
o que confirma que os conectores nunca foram necessários, só estavam ligados.

### P2 — Prompt de rotina fora do git
**Severidade: média · Executor: ☁️ Nuvem ✅ (N2) / 👤 Humano ABERTO (control-plane)**

**Feito, e versionado:** a rotina N2 tem conteúdo em
[`.claude/skills/governanca-n2/SKILL.md`](../.claude/skills/governanca-n2/SKILL.md),
com dois passos que o prompt original não tinha — conferir se alguma rotina
regrediu de governança e conferir se este backlog descreve a realidade.

**O que a reverificação de hoje mostrou, e é pior do que o arquivo afirmava:**
**as duas** rotinas de governança continuam com o prompt inteiro na UI. A skill
versionada existe e **não é o que roda**. O padrão prompt-ponteiro do
[`AGENTS.md`](../AGENTS.md) está documentado e aplicado em zero rotinas.

Isso não é cosmético. Prompt na UI não é revisável, não é auditável, não entra em
PR e desaparece se a rotina for recriada. Enquanto durar, a versão que executa e
a versão que este repositório publica podem divergir sem que nada acuse.

**Fechado para a rotina N2, em 2026-08-20.** O prompt na UI foi trocado pelo
ponteiro para a skill versionada. Duas escolhas de desenho vale registrar, porque
o critério ingênuo — *"o prompt cabe em duas linhas"* — teria produzido um
controle pior:

- **A regra de escopo (R1) ficou inline**, repetida no prompt além de constar da
  skill. Um ponteiro puro faz a regra dura depender de o arquivo ser legível; a
  regra precisa valer inclusive quando ele não for.
- **O prompt manda parar e relatar se a skill não puder ser lida**, com o caminho
  tentado e o erro literal, em vez de improvisar de memória. Sem isso, uma rodada
  que perdesse o critério devolveria "sem achados" — e rodada cega relatada como
  limpa é pior do que rodada que não aconteceu.

O prompt não cabe em duas linhas, e **é para não caber**. O critério de
verificação abaixo foi corrigido: o que importa não é o tamanho, é que nenhum
critério operacional viva só na UI.

**Aberto para a rotina de control-plane (👤).** Falta decidir onde a skill mora, e
a resposta ficou mais clara com P0 fechado: ela **não pode** morar no repositório
público, porque a rotina teria de lê-lo e voltaria a violar R1 — o defeito que
acabou de ser corrigido. O candidato natural é o repositório privado de
configuração do harness, que já hospeda skills executadas por outra rotina e
não está no escopo desta.

**Verificação:** o prompt de cada rotina não contém critério operacional que não
esteja versionado — só escopo, ponteiro e o que fazer se o ponteiro falhar.

---

## 1. Entregue ☁️

Quatro lotes. Detalhe de cada mudança está no corpo do PR e no log — aqui fica só
o que fechou, para o backlog não virar changelog.

**2026-08-02 — coerência e Fase 1**

| # | Item | Como fechou |
|---|---|---|
| N1 | `README.md` não linkava o blueprint | link na seção "AI Operating System" |
| N2 | Sem `LICENSE`, apesar de o blueprint declarar CC BY 4.0 + MIT | `LICENSE` nos dois regimes |
| N3 | `AGENTS.md` listava achado já resolvido | movido para o backlog |
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
(condicional ao entregável H). É essa divisão que tornou possível o lote de
2026-08-20.

**Plugin-fundação** ([`plugins/fundacao/`](../plugins/fundacao/)) — oito
executores, hook de guardrail e esqueleto de telemetria. Fica no repo público
porque o blueprint exige que o plugin só contenha template genérico: um plugin
público satisfaz isso por construção. Os agentes ficam em `plugins/`, não em
`.claude/agents/`, para não mudar o comportamento de toda sessão deste repo sem
pedido.

O `guard-push.sh` corrige um buraco do snippet ilustrativo do Apêndice A, que
libera o push sempre que a string `claude/` aparece em qualquer ponto do comando.
Validado em 11 casos.

**Watchdog** ([`.github/workflows/watchdog.yml`](../.github/workflows/watchdog.yml))
— diário, sem modelo, sem chave de API, sem Action de terceiro. O alerta é a
falha do job, que o GitHub já notifica por e-mail. Único controle deste
repositório que funciona sem configuração humana pendente.

**2026-08-03 — doutrina e redundância**

| # | Item | Como fechou |
|---|---|---|
| N8 | Frontmatter (`setor`/`nivel`/`emite_pratica`/`nunca_sai`) fiscalizado pela rotina e documentado em lugar nenhum | seção nova no `AGENTS.md` |
| N9 | Nenhum workflow declarava o que **não** cobre | cabeçalho nos dois |
| N10 | Skill `governanca-n2` não checava doutrina nem cobertura de CI | passos 5 e 6, mais "o que esta rotina não alcança" |
| N11 | `templates/watchdog.yml` era cópia quase idêntica do workflow ativo | template removido; o ativo virou portável |
| N12 | Achados duplicados entre `AGENTS.md` e este arquivo | `AGENTS.md` passa a apontar para cá |

**2026-08-08 — poda (PR #8)**

| # | Item | Como fechou |
|---|---|---|
| N13 | `/auditoria-poda` era invocada e não existia | [`.claude/skills/auditoria-poda/SKILL.md`](../.claude/skills/auditoria-poda/SKILL.md), no padrão prompt-ponteiro |
| N14 | Blueprint dizia "nenhuma rotina em produção ainda", com três rodando | status corrigido |
| N15 | Backlog pedia merge do #7 e primeira run do watchdog, ambos já feitos | itens retirados |
| N16 | Topologia de branches do `AGENTS.md` voltou a envelhecer no merge seguinte | reescrita sem contagem nominal |
| N17 | Exemplo de telemetria em duas cópias sem canônico | template em `plugins/fundacao/templates/telemetry/` declarado canônico |
| N18 | `CODEOWNERS` não cobria `/plugins/` nem `/.claude-plugin/` (R5) | linhas adicionadas |

**2026-08-20 — reverificação e sanitização**

| # | Item | Como fechou |
|---|---|---|
| N19 | **Este arquivo era um mapa operacional de fraquezas, publicado em repositório N2** | reescrito: item, severidade, evidência e ação permanecem; horário de disparo das rotinas, identificador de controle, lista de conectores e comando pronto de desativação saíram |
| N20 | Placar afirmava H1 e H4 fechados com base em consulta que não se repete | reclassificados para "não verificável daqui", com o motivo declarado |
| N21 | Backlog inteiro apoiado em "uma sessão futura reverifica", que não acontece | seção "O que a nuvem não alcança" + item **V1** com substituto proposto |
| N22 | Apêndice de verificação usava um binário inexistente no ambiente de nuvem | reescrito com o que funciona, e com o que só a UI responde |

**N19 merece o registro, porque é o tipo de achado que este arquivo existe para
pegar e quase não pegou em si mesmo.** Nenhum dos dados publicados era segredo
isoladamente: horário de disparo, conectores anexados, identificador do controle
de branch com o comando pronto de remoção, confirmação de que não havia segredo
de Actions, e a janela em que ajustar já não adiantava. Juntos, num repositório
público, formavam um roteiro com hora marcada — exatamente o que o item 5 do
checklist do [`SECURITY.md`](../SECURITY.md) (estrutura interna) existe para
barrar. O checklist foi aplicado a todo o repositório e não a este arquivo,
porque ele é *saída* da auditoria e ninguém audita o próprio relatório.

A correção não foi apagar informação: foi separar **o que um leitor precisa para
agir** de **o que um atacante precisa para agir**. Item, severidade, evidência,
ação e critério de verificação continuam todos aqui. O que saiu foi o que só
serve a quem quer contornar o controle — e onde a rota de saída de um controle
importa, o arquivo diz que ela existe e em que tela encontrá-la, sem publicar o
comando.

### O que segue aberto neste bloco

**N6 — o PR Watch acorda, é barrado pelo gate, e nunca executou de verdade.**

Verificado na API em 2026-08-20: o workflow acumula **22 execuções e nenhuma
real** — 12 `skipped` e 10 `cancelled`, **zero sucesso e zero falha**. A última
foi em **2026-08-09**, e desde então ele não acordou.

O job mais recente reporta `steps=0`: nenhum passo chegou a existir, então o
checkout e a action nunca rodaram e a chave de API nunca foi consultada. A
condição de guarda barrou tudo — os comentários não continham a menção exigida.
É a **evidência de campo de R9/R2**: os eventos chegaram e o gate de autor +
menção segurou, 22 vezes. Esse controle deixou de ser suposição.

O que segue aberto é a outra metade: **nenhuma execução real** aconteceu, e ela
continua bloqueada por **H3**. Run que pula não exercita a action, o modelo, as
permissões nem o prompt.

**Correção pendente em outro arquivo (não editado nesta sessão):** o cabeçalho de
`.github/workflows/claude-pr-watch.yml` afirma "cinco runs" e descreve apenas
2026-08-08. São 22 execuções, em pelo menos dois dias distintos — subconta por
fator ~4. É o mesmo defeito de "realidade antiga" que o cabeçalho anterior tinha
e que já foi corrigido uma vez; a lição é que contagem escrita à mão em cabeçalho
volta a envelhecer no dia seguinte, e o texto deveria descrever o *comportamento*
("acorda e é barrado pelo gate; nunca executou de verdade") em vez de um número.

**Verificação, quando destravar:** um disparo manual conclui com `success` e o
job mostra passos executados — não `skipped`.

---

## 2. Exige o humano 👤

Nenhum agente executa estes itens, e essa é a intenção — são exatamente os
controles que sustentam o gate humano. A nuvem só consegue **reportar que estão
abertos**, o que este arquivo faz. Desde 2026-08-20, em vários deles a nuvem nem
isso consegue: ver **V1**.

### H1 — Proteção de `main`
**Severidade: alta · 🟡 PARCIALMENTE VERIFICÁVEL · Executor: 👤 Humano**

Um controle de proteção de `main` foi criado em 2026-08-08 e, na ocasião, a API
confirmou regras de bloqueio de deleção, de force push e de exigência de PR, sem
bypass para ninguém — inclusive o dono.

**O que se pode afirmar hoje, 2026-08-20:** a API devolve `main` como protegida.
Isso prova que existe **alguma** proteção. Não diz qual regra, não diz o
enforcement, não diz quem tem bypass. Os endpoints que responderiam a isso estão
bloqueados pelo proxy de saída (**V1**).

**Não há indício de regressão.** Há a constatação de que a frase "H1 está
fechado" deixou de ser verificável por quem escreve este arquivo, e por isso ela
não vai continuar escrita como se fosse.

**Ação (👤):** conferir na UI, em *Settings → Rules*, que o controle segue ativo,
com enforcement ativo e sem bypass concedido. Cinco minutos.

**Verificação:** um push direto para `main` é recusado, e um PR é exigido.

> O controle **tem rota de saída** — ele pode ser removido na mesma tela em que é
> conferido. Fica registrado que ela existe, e onde, porque controle sem rota de
> saída conhecida é controle que alguém desliga às pressas, do jeito errado, no
> dia em que ele atrapalhar. O comando não é publicado: num repositório público,
> comando pronto de desativação é conveniência para quem não deveria tê-la.

### H2 — `CODEOWNERS` é inerte
**Severidade: alta → média · 🟡 PARCIAL — bloqueado por ter um único dono**

`.github/CODEOWNERS` cobre `/.claude/`, `/.github/`, `/docs/`, `/README.md` e,
desde 2026-08-08, `/plugins/` e `/.claude-plugin/` — control-plane distribuível,
exatamente o que **R5** protege.

Com a proteção de `main` de pé, o arquivo deixou de ser inerte pela metade: as
mudanças passam por um lugar onde a revisão *pode* acontecer. O que falta é a
exigência de que ela aconteça — a revisão por code owner não está exigida.

**E não é esquecimento: é aritmética.** O GitHub não aceita autoaprovação. Com um
único dono e code-owner review exigido, todo PR do dono ficaria travado sem
ninguém que possa destravá-lo — o controle viraria bloqueio total, e o primeiro
reflexo seria desligá-lo. Mesmo padrão do L3.1: controle que nega tudo não
sobrevive à primeira semana.

**Ação (👤), quando houver um segundo revisor:** ativar a exigência de revisão de
code owner na mesma regra de proteção de `main`. É uma opção, não um projeto.

**Verificação:** um PR que toca `/plugins/` fica bloqueado até o code owner
aprovar.

### H3 — Segredo de Actions para o PR Watch
**Severidade: média · ABERTO por regra, não por esquecimento**

O PR Watch precisa de uma chave de API em segredo de Actions para que sua metade
executável (**N6**) saia do papel.

**Estado hoje: não verificado.** O endpoint que lista segredos de Actions está
entre os bloqueados pelo proxy (**V1**), então esta sessão não pode nem confirmar
nem negar que o segredo exista.

**Ação (👤):** criar o segredo **no terminal ou na UI do dono**.

**Este item nunca será fechado por agente, e não é limitação de ferramenta.**
Manipular chave de API é proibido por regra de conduta, independentemente de quem
peça ou de como o pedido seja formulado: o valor não passa por sessão de agente
nem por chat. Quem cria o segredo é quem o digita. Registrado assim para que uma
sessão futura não trate isso como pendência a executar.

### H4 — Secret scanning e push protection
**Severidade: alta · 🟡 NÃO VERIFICÁVEL PELA NUVEM · Executor: 👤 Humano**

Em 2026-08-08 este item foi marcado como fechado com base numa leitura da API.
Hoje essa leitura não se repete, e o que se conseguiu apurar é **mais estreito do
que o item supunha**:

- A ferramenta de secret scanning disponível recusou com *"Repository does not
  have GitHub Advanced Security enabled"*. Isso prova que o **GHAS está
  desligado**.
- GHAS é um flag **distinto** do secret scanning gratuito de repositório público.
  A recusa acima não diz nada sobre esse segundo flag, que só se lê pelo endpoint
  bloqueado.
- **Push protection não foi verificado por via nenhuma.**

Num repositório público N2, push protection é a única barreira que age **antes**
de o segredo virar público. Depois do push, conteúdo público é comprometido, não
corrigível — é o que o runbook do [`SECURITY.md`](../SECURITY.md) diz. Saber se
essa barreira existe não é detalhe de inventário.

**Ação (👤):** conferir na UI, em *Settings → Advanced Security*, o estado de
secret scanning e de push protection, e registrar aqui a data da conferência.

**Verificação:** um push contendo um segredo de padrão conhecido é recusado.

> Fica o registro do erro de método, porque ele vale mais que o dado: um item foi
> dado como fechado por uma consulta que ninguém garantiu ser repetível. O
> critério novo está na seção "O que a nuvem não alcança" — item de configuração
> não fecha por leitura de agente.

### H5 — Pré-condições jurídicas não verificadas
**Severidade: alta · Executor: 👤 Humano · ABERTO**

O blueprint põe como **regra dura** antes da Fase 2 que repositórios lidos por
rotinas não contenham dado pessoal bruto nem confidencial de terceiros, e antes
da Fase 1 o opt-out de treinamento confirmado com evidência datada.

Duas rotinas semanais estão em produção, e a de control-plane lê repositórios que
o próprio blueprint marca como os que tocam dados comerciais sensíveis e
potencialmente pessoais (seção 5.1). **A rodada de auditorias de 2026-08-20
amplia isso de quatro para dezessete repositórios lidos por agente num único
dia** — o que não muda a natureza do item, mas multiplica o custo de ele estar
aberto.

Daqui não há como verificar se as condições foram cumpridas — podem ter sido,
offline. Se não foram, a Fase 2 está rodando à frente do gate que ela mesma
declarou inegociável.

**Ação:** confirmar opt-out com evidência datada; verificar titularidade dos
dados de cada repositório no escopo das rotinas.

**Verificação:** existe evidência datada do opt-out, e cada repositório no escopo
de rotina tem titularidade declarada.

### H6 — Branch residual do PR #7 no remoto
**Severidade: média · ✅ FECHADO em 2026-08-08 · reconfirmado em 2026-08-20**

A branch sobrevivente ao merge do PR #7 foi apagada, e o padrão se manteve: em
2026-08-20, `git branch -r` devolve apenas `origin/HEAD` e `origin/main`.
**Dez PRs foram mesclados e nenhuma branch de trabalho sobrou.** O check
"branches `claude/*` sem PR aberto" do watchdog nunca teve motivo para falhar.

Fica o registro do padrão, que é o que interessa reter: apagar no ato do merge é
o que impede a categoria 4 da auditoria de poda de reaparecer todo ciclo. Doze
dias e três merges depois, continua valendo.

> H1, H2 e H4 são entrega prevista da **Fase 1**, e o que esta rodada mostrou é
> que o problema deles mudou de "não existem" para "não se sabe daqui". H5 é a
> versão da inversão original em que o custo de errar não é técnico — e é o único
> dos quatro que não melhorou em doze dias.

---

## 3. Ainda em aberto ☁️ / 🏠

### A1 — O orquestrador está no prédio errado
**Severidade: alta · Executor: 👤 Humano (decisão de arquitetura) · PROPOSTA**

Levantado pelo dono em 2026-08-21: *e se quem orquestra fosse o repositório
privado de fundação, em vez deste?*

**A primeira linha do `AGENTS.md` deste repositório já diz o problema** — que ele
tem *"duas funções que não devem se misturar"*: perfil público e orquestrador. A
rodada de 2026-08-20/21 mostrou que a frase é mais forte do que parecia. As duas
funções não apenas não se misturam: **uma delas está no prédio errado.**

#### O que a rodada provou

Tudo que travou nesta auditoria travou pelo mesmo motivo — o orquestrador mora
num repositório N2:

| O que o orquestrador precisa | O que acontece aqui |
|---|---|
| Nomear os 18 repositórios | 13 não podem ser nomeados (itens 1 e 7 do checklist) |
| Guardar a ficha de cada departamento | não podem atravessar; ficam na origem |
| Versionar o mapa setor → repositório | não pode ser publicado |
| Versionar o mapa setor → destino de backup | não pode ser publicado |
| Consolidar pendência de projeto privado | precisa de transporte humano, uma a uma |

Nenhum desses limites é acidente ou excesso de zelo: são **R1 funcionando como
projetado**. O problema não é a regra — é que o orquestrador foi posto do lado
errado dela e passa a vida contornando a própria fronteira.

#### O que muda de lado

**Vai para o repositório privado de fundação:** o índice com nomes reais, as
fichas de handoff, os dois mapas (setor → repositório, setor → destino), e os
itens de backlog que tratam de projeto privado.

**Fica aqui, porque é o que este repositório faz bem:** o blueprint — que é
documento publicado, sanitizado e feito para ser lido por terceiros —, o perfil,
o `SECURITY.md` como doutrina pública, o marketplace e o plugin distribuível, e
os prompts genéricos de auditoria.

#### R1 não some — muda de posição, e afrouxa

Com o orquestrador do lado privado, ele pode ler outros repositórios privados
sem violar nada: **R1 proíbe misturar privado com o público, não privado com
privado.** O gargalo de hoje evapora.

O que **não** evapora é o corolário registrado em **L4**: *sessão não deveria
montar repositórios cujos dados pertencem a donos diferentes.* Orquestrador
privado montado junto com repositório de empregador continua sendo a mesma classe
de risco, em escala menor. A fronteira deixa de ser dura e passa a ser de
julgamento — o que é mais confortável e menos seguro, e vale saber disso ao
decidir.

E a fronteira pública continua existindo: o que for publicado aqui segue passando
pelo checklist inteiro. A diferença é que **o orquestrador deixa de ser a coisa
que precisa atravessar**.

#### O custo, para a decisão ser honesta

Mover não é grátis. O `AGENTS.md` e o blueprint descrevem este repositório como
orquestrador em vários lugares; a rotina de governança N2 pressupõe isso; e o
índice publicado — que hoje conta 18 sem nomear — some do lado público, o que
significa que **o perfil deixa de responder "o que existe"**. Se essa resposta
pública tiver valor de vitrine, ela precisa ser reescrita como recorte
deliberado, não como índice.

**Ação (👤):** decidir. Se for mover, a ordem que evita ficar com dois
orquestradores meio-prontos é: (1) criar o índice real no repositório de fundação
a partir das fichas que já estão nas origens; (2) reescrever aqui o que descreve
este repositório como orquestrador; (3) reapontar a rotina de governança; (4) só
então apagar o índice daqui.

**Verificação:** uma pessoa consegue responder *o que existe, onde está a
verdade, o que está pendente* abrindo **um** repositório — e esse repositório não
precisa esconder metade da resposta.

---

### D1 — O que ainda depende de uma máquina ligada
**Severidade: alta · Executor: ☁️ Nuvem (workflow, feito) + 👤 Humano (credencial) · PARCIAL**

Objetivo declarado pelo dono em 2026-08-20: **nada do ecossistema pode depender
de a máquina local estar ligada.** GitHub como fonte de verdade, uma segunda
cópia independente, e nenhum arquivo cuja existência dependa de alguém abrir o
notebook.

O que já satisfaz isso: **todo conteúdo versionado.** Qualquer máquina clona e
continua; as sessões de nuvem provaram isso em 18 repositórios hoje.

O que **não** satisfaz, em ordem de gravidade:

1. **A configuração das rotinas** — cron, escopo de repositórios, conectores,
   modelo. Vive só na UI da nuvem. Não é arquivo, então clonar não recupera, e
   **é o único ponto do ecossistema que nenhum backup alcança.** Se as rotinas
   forem recriadas ou perdidas, o que se perde não é o texto (P2 versionou a
   skill) — é o agendamento e o escopo. Não há hoje nem um registro versionado
   *descrevendo* essa configuração, que seria o mínimo.
2. **A configuração dos repositórios no GitHub** — ruleset, proteção de branch,
   secret scanning. Não é refém de máquina local, mas também não é versionada
   nem reverificável da nuvem (**V1**). Some junto com a conta.
3. **A cópia de segurança em bundle** — hoje produzida na máquina do dono e
   guardada no OneDrive. **É exatamente a dependência que o objetivo quer
   eliminar:** o backup só existe nos dias em que a máquina ligou, e ninguém é
   avisado quando ela não liga. Backup que depende de lembrança não é backup, é
   intenção.

**Destino decidido em 2026-08-20: Google Drive, não OneDrive.** A comparação não
foi de preferência, foi de modo de falha:

| | OneDrive pessoal | OneDrive corporativo | **Google Drive** |
|---|---|---|---|
| Autenticação sem humano | ❌ só delegada; refresh token expira e pede consentimento | ✅ aplicativo do Entra ID | ✅ service account |
| Falha quando o token vence | silenciosa | — | — |
| Já autorizado nesta conta | não verificado | não verificado | ✅ sim |

O que elimina o OneDrive pessoal não é ser pior de usar: é que **a falha dele é
silenciosa**. O backup para de rodar quando o consentimento vence, e ninguém
descobre até precisar restaurar. Um backup que falha calado é pior que backup
nenhum, porque produz confiança sem cobertura.

**Por conector, não. Por GitHub Actions, sim — e a razão é R1.** A conta tem um
conector do Google Drive autorizado, e seria mais rápido anexá-lo a uma rotina de
backup. Mas conector se anexa a **rotina**, e uma rotina que faça backup de vários
repositórios teria privados e o público no mesmo escopo: é exatamente a violação
que **P0** acabou de fechar, reaberta por outra porta e em escala maior.

Um workflow do Actions vive **dentro de um repositório e só enxerga aquele
repositório**. Não é só uma alternativa aceitável — é **R1-seguro por
construção**, sem depender de ninguém lembrar da regra. Preferir o controle que
não pode ser violado ao controle que exige disciplina é o padrão do ecossistema.

**Ação (☁️): o workflow, um por repositório.** Template em
`plugins/fundacao/templates/backup/`, instalado em `.github/workflows/`.
Propriedades não negociáveis:

- **`fetch-depth: 0`** no checkout. Bundle feito de clone raso não contém o
  histórico e é backup só na aparência — o mesmo defeito de clone raso que já
  tornou cego um check do watchdog aqui.
- **`git bundle verify` antes de enviar.** Substituir uma cópia boa por uma
  corrompida é pior que não ter feito backup.
- **Falha ruidosa se o secret não existir** — nada de pular em silêncio.
  Instalar o workflow é ato deliberado; backup que você acha que roda e não roda
  é pior que um X vermelho.
- **Resumo de execução a cada rodada**, para que "rodou e deu certo" seja
  distinguível de "rodou e não fez nada".

**Ação (👤): sete passos, e nenhum deles é alcançável por agente.** O workflow já
está escrito e verificado; o que falta é credencial, que agente não cria:

1. Habilitar a **Google Drive API** no projeto do Google Cloud.
2. Criar a **service account** (sem papel IAM) e gerar a chave JSON.
3. **Compartilhar a pasta do Drive com o e-mail da service account, como Editor.**
   É o passo cuja falha é opaca: sem ele o envio volta como se a pasta não
   existisse, e a mensagem não diz que o problema é permissão.
4. Gravar os secrets do repositório com a chave e o id da pasta. Enquanto não
   existirem, **o job falha de propósito** — nunca pula em silêncio.
5. Rodar uma vez à mão e conferir o resumo de execução e o arquivo na pasta.
6. **Testar a restauração** a partir do bundle e anotar a data. Backup sem
   restauração testada é intenção, não controle. O caminho foi provado neste
   repositório: bundle criado, verificado e clonado de volta com o histórico
   completo — falta provar no destino real.
7. Conferir que a notificação de falha de workflow agendado chega ao dono. O
   alarme deste controle é essa notificação; se ela não chega, o controle é mudo.

**Ainda em aberto, e sem dono:** a conferência contra a desabilitação de 60 dias
não pode morar no repositório que ela protege. A evidência que não depende dele é
a **data do bundle mais recente no Drive** — quem olha isso, e com que
periodicidade, ainda não está decidido.

**Destino por setor, decidido em 2026-08-20.** Não há um destino só, e não
deveria haver: **o dado vai para o locatário de quem é dono dele.** Repositório
de empregador ou cliente vai para a nuvem corporativa daquela organização;
repositório próprio vai para conta pessoal. Backup é cópia, e copiar material de
terceiro para conta pessoal aciona o item 7 do checklist (titularidade) do mesmo
jeito que publicá-lo.

O **mapa setor → conta de destino não é versionado**, aqui nem em lugar nenhum
público: ele nomeia organizações e endereços de pessoas (itens 1, 3 e 5). O
desenho já dispensa versioná-lo — **o destino é um secret do repositório**, então
o workflow é idêntico em todos e nenhum deles sabe para onde os outros enviam.
Uma pasta por setor com os projetos dentro sai de graça: repositórios do mesmo
setor compartilham o identificador de pasta no secret, sem tocar no workflow.

**Lacuna declarada, e é a que trava a parte mais sensível:** o workflow existente
fala **só Google Drive**. Destino em **OneDrive/SharePoint corporativo** — o certo
para repositório de empregador — exige outro caminho de autenticação (aplicativo
no Entra ID, `client_credentials`, Microsoft Graph). Bundle, verificação e
contrato de falha são idênticos; muda quem emite o token e quem recebe o arquivo.
Até essa variante existir, **repositório de empregador fica sem backup
automatizado** — o que é melhor do que apontá-lo para um destino pessoal só
porque esse já funciona.

Duas notas de viabilidade, para não voltarem à mesa: **Yahoo não serve** — não
expõe armazenamento com API utilizável para isso. E conta Google pessoal esbarra
na cota da service account, tratada no README do template.

**Resolvido em 2026-08-21 para o setor de negócio próprio.** Confirmado pelo dono
que aquele setor é empresa dele, não cliente: o item 7 (titularidade) está
satisfeito e o destino em conta própria é legítimo. **O caminho do Google Drive
já cobre esse setor** — é só executar os sete passos acima.

Com isso, a variante **OneDrive/Entra ID deixa de ser caminho crítico**: ela passa
a ser necessária só para o setor de empregador, que é um, não três. Continua sendo
lacuna real — aquele setor segue sem backup automatizado —, mas não bloqueia o
resto.

> **Uma distinção que vale fixar, porque ela reaparece:** ser dono resolve
> *titularidade*, não *sensibilidade*. Um repositório de negócio próprio que
> contém dado de cliente, paciente ou usuário continua com titulares que são
> outras pessoas — o item 3 do checklist não se mexe, a ficha de handoff continua
> marcando `sensibilidade: alta`, e a auditoria continua no modelo mais capaz.
>
> Consequência prática para o backup, enquanto o negócio se digitaliza: à medida
> que ele ganhar conta corporativa própria, o destino deveria migrar para lá.
> Cópia de dado de terceiro numa conta **pessoal** é uma exposição diferente da
> mesma cópia numa conta **da empresa** — e a diferença só aparece no dia em que
> entra sócio, funcionário ou auditoria. Não é urgente; é barato agora e caro
> depois.

**Armadilha declarada, que o próprio GitHub cria:** workflow agendado é
**desabilitado automaticamente após 60 dias sem atividade no repositório**. Para
um backup, esse é o modo de falha silenciosa que ele existe para evitar — e ele
morde justamente os repositórios parados, que são os que mais dependem do
backup. A conferência de que o agendamento continua vivo não pode morar dentro do
repositório que ele protege.

**Feito em 2026-08-21:** [`control-plane.md`](control-plane.md) descreve as cinco
classes de rotina pelo **escopo** — que é o que R1 governa —, os seis invariantes
que uma rotina recriada não pode perder, e o procedimento de reconstrução. Sem
cron, sem identificador, sem conector e sem nome de repositório: registra a
forma, não o mapa operacional (**N19**).

Isso **não fecha D1**, e a diferença importa: o documento mitiga a perda de
*conhecimento*, não a perda de *configuração*. Se a UI sumir, ainda é preciso
recriar tudo à mão — só que agora sabendo o quê e por quê, em vez de redescobrir.
Backup executável da camada de rotinas continua não existindo, e não há via de
agente que o crie.

**Verificação:** desligar a máquina local por uma semana não muda nada
observável — o backup continua datado do dia, e nenhuma pergunta sobre o
ecossistema fica sem resposta. E, uma vez por trimestre, **restaurar de verdade a
partir de um bundle**: backup sem restauração testada é intenção, não controle.

> **A pergunta certa não é "onde estão os arquivos".** Os arquivos já estão
> seguros: estão no git, em dezoito repositórios, e qualquer máquina os recupera.
> O que está refém não é disco — é **configuração que não é arquivo**. Um plano de
> durabilidade que só resolve o backup de arquivos resolve a parte que já estava
> resolvida.

---

### H1-bis — O gate humano de `main` é doutrina, não controle
**Severidade: alta · Executor: 👤 Humano · ABERTO**

Em 2026-08-21 o dono reconectou a autorização do GitHub, e os caminhos que
respondiam 403 por essa causa passaram a responder. Pela primeira vez foi
possível **ler** o ruleset em vez de inferir dele.

O que se confirmou, e estava certo: o ruleset existe, o enforcement está ativo,
não há nenhum ator com bypass, e `main` está protegida contra deleção e contra
histórico reescrito.

**O que ninguém tinha verificado:** a regra de pull request está configurada para
exigir PR **sem exigir aprovação alguma**, e sem exigir revisão de code owner.
Traduzindo: qualquer identidade com acesso de escrita — inclusive uma sessão de
agente — pode abrir um PR e mesclá-lo sozinha, sem que pessoa nenhuma olhe. O
ruleset barra empurrar direto em `main`; não barra passar por `main` via PR
próprio.

Isso reclassifica o controle mais importante do ecossistema. *"Nada é mesclado em
`main` por agente"* era descrito como gate. **É doutrina** — vale porque está
escrito nos prompts e porque os agentes obedecem, não porque a plataforma impede.
Doutrina é um controle real, e este vinha sendo respeitado; mas um controle que
depende de todo agente lembrar a regra falha de um jeito diferente de um que
recusa a operação.

Isso também explica **H2** sem mistério: o `CODEOWNERS` é inerte porque a regra
não pede revisão de code owner. Não é só a opção "Require review from Code
Owners" que falta — é a contagem de aprovações em zero.

**Ação (👤):** decidir entre duas posturas, e as duas são defensáveis:

1. **Exigir aprovação.** Fecha o buraco, e trava: com um único dono, ninguém
   aprova o próprio PR. Vira gargalo real, não teórico.
2. **Assumir a doutrina como o controle**, declarando-a como tal em vez de
   chamá-la de gate. Honesto, e não bloqueia — mas exige que todo prompt de
   agente continue carregando a regra, para sempre.

A escolha depende de haver um segundo revisor, que é a mesma pré-condição que já
trava **H2**. Enquanto não houver, a opção 2 é a única executável — e o mínimo é
o texto parar de chamar de gate o que é doutrina.

**Verificação:** o texto do ecossistema descreve o controle pelo que ele faz. Se
a opção 1 for adotada, a contagem de aprovações deixa de ser zero.

> Vale registrar como o achado apareceu, porque é o argumento a favor de
> reconectar autorização em vez de conviver com o 403: **este item ficou seis
> meses descrito como fechado sem nunca ter sido lido.** Não por descuido — a via
> de leitura não existia, e "ruleset ativo" era o máximo que dava para afirmar. O
> custo de um controle não verificável não é o risco de ele estar desligado; é
> que ninguém descobre que ele protege menos do que se pensa.

---

### V1 — A configuração do repositório não é reverificável pela nuvem
**Severidade: alta · Executor: ☁️ Nuvem (implementa) + 👤 Humano (confere hoje) · ABERTO**

**Evidência (2026-08-20):** `gh` não existe no ambiente de nuvem; o proxy de
saída devolve **403** para os caminhos de configuração de repositório da API do
GitHub, com token que responde `200` em endpoint de identidade; nenhuma
ferramenta MCP expõe ruleset ou proteção de branch. Detalhe na
[seção dedicada](#o-que-a-nuvem-não-alcança--e-por-quê).

**Por que é severidade alta:** não é um item de conforto. Ele é a razão pela qual
H1, H3 e H4 — três controles de segurança de um repositório público — estão hoje
em "não se sabe". Um controle que ninguém consegue observar tende ao mesmo
resultado prático de um controle que não existe, com a diferença de que o
primeiro produz falsa tranquilidade.

**Ação (☁️):** adicionar ao repositório um workflow do Actions que leia a
configuração usando o token nativo da execução — que roda dentro do GitHub e
**não passa pelo proxy de saída** — e publique o resultado como saída do job. A
partir daí, qualquer sessão de nuvem lê o que sempre pôde ler: o resultado de um
workflow.

**Limite declarado, não verificado:** não foi confirmado se o token nativo tem
escopo suficiente para ler regra de proteção e estado de secret scanning. Pode
ser que parte da leitura exija permissão que o token da execução não recebe. **O
teste é a própria primeira execução do workflow** — e se ele não conseguir, o
resultado é útil do mesmo jeito: passa a estar provado que só a UI responde, e
esse fato fica registrado em vez de ser redescoberto a cada rodada.

**Ação (👤), enquanto V1 não existe:** conferir H1 e H4 na UI e datar a
conferência aqui.

**Verificação:** uma sessão de nuvem consegue afirmar o estado da proteção de
`main` e do secret scanning citando a saída de um job, sem depender de memória
nem deste arquivo.

> Esta sessão **não** implementou o workflow: `.github/` estava sendo editado por
> outra sessão em paralelo e escrever lá agora produziria conflito. O item fica
> registrado com a ação inteira descrita, que é o que permite executá-lo depois
> sem reconstruir o raciocínio.

### L1 — Auditoria dos departamentos: 17 sessões em voo
**Severidade: média · Executor: ☁️ Nuvem (feito) + 👤 Humano (transporte) · EM VOO**

O índice do `AGENTS.md` tem quatro linhas em *não verificado*, e o item nasceu
descrevendo "quatro departamentos nunca auditados". **Isso mudou hoje.**

**O que aconteceu em 2026-08-20:** foram despachadas **17 sessões de nuvem, uma
por repositório privado**, cada uma escopada num único repositório — **R1
preservado: nenhuma sessão mistura repositórios**. Cada uma roda a auditoria
integral, aplica as correções de classe A e B, grava o relatório dentro do
próprio repositório auditado e abre PR draft lá.

**Nenhuma delas escreve aqui.** O bloco de handoff sanitizado fica no repositório
de origem, e o transporte para este arquivo é humano. Isso não é limitação
acidental: é R1 funcionando. Uma sessão que auditasse um privado e escrevesse no
público seria o defeito que P0 apontou, na forma de agente.

**O que ainda falta, e é o gargalo real:**

1. **Transporte (👤)** — trazer o entregável G sanitizado de cada repositório.
2. **Consolidação (☁️)** — transformar cada G numa linha do índice do
   `AGENTS.md`, com a data na coluna "Última auditoria", substituindo apenas as
   células que a auditoria confirmou.

**Verificação:** o índice do `AGENTS.md` não tem mais nenhuma linha inteiramente
em *não verificado*, e cada célula preenchida tem data de auditoria.

> O item deixa de ser "bloqueado por R1" e passa a ser "aguardando retorno". Vale
> reter por quê: o bloqueio nunca foi a auditoria, era a *forma* de rodá-la. A
> divisão do prompt em nuvem + adendo local (lote de 2026-08-02) e o paralelismo
> de uma sessão por repositório resolveram um item que passou semanas descrito
> como impossível. Nem todo item marcado como bloqueado está bloqueado pelo que
> sua descrição diz.

**Rodada de fichas — 2026-08-21.** Despachadas 17 sessões novas, uma por
repositório privado, cada uma com a única tarefa de gravar
`docs/handoff/<setor>.md` **na origem**, a partir do relatório que a auditoria
deixou lá. Todas as 17 concluíram e abriram PR draft no próprio repositório. O
transporte para cá deixou de ser "trazer o conteúdo" e passou a ser "ler a ficha
e copiar duas células": estado e data. O que atravessa a fronteira encolheu, e
com ele a superfície de vazamento.

Duas coisas apareceram nessa rodada e não cabem no item como estava escrito:

1. **Três fichas relataram que o relatório de auditoria não existe onde
   deveria** — os repositórios cujos setores são de *agência*, *análise de
   conversas* e *dossiê pessoal*. A sessão de ficha procurou
   `docs/auditoria/2026-08-20-integral.md` e não achou. As três auditorias
   correspondentes terminaram em 2026-08-20 declarando trabalho concluído. Ou o
   relatório ficou numa branch que a sessão de ficha não consultou, ou a
   auditoria relatou uma entrega que não gravou. **Enquanto isso não for
   resolvido, esses três não podem virar linha datada no índice** — datar sem
   relatório é exatamente o "em voo virou verificado" que o `AGENTS.md` avisa
   para não fazer.

2. **O slug de setor não é único por repositório.** Dois repositórios gravaram
   ficha sob o mesmo `setor:`. Isso não causa colisão de arquivo — cada ficha
   vive na sua origem — mas quebra a premissa de que uma linha do índice mapeia
   um setor. O índice precisa de chave composta (setor + repositório) ou o
   frontmatter precisa de um campo que distinga os dois. Decisão de desenho,
   não de urgência.

**Verificação adicional:** nenhum dos três repositórios acima aparece com data
no índice enquanto o relatório não for localizado ou refeito.

### L2 — O índice publicado tem o eixo errado, não só linhas faltando
**Severidade: alta · Executor: 👤 Humano (decisão) depois ☁️ Nuvem · ABERTO**

| O que a operação real tem | O que este repositório publica |
|---|---|
| **18 repositórios** (17 privados + o público) | 5 departamentos |
| 6 setores, declarados no frontmatter `setor:` | 5 departamentos com outros nomes |
| Checkup manual, bundle de backup, clone local | não documentado |

O orquestrador existe para responder *"o que existe?"*, e a resposta publicada
descreve um recorte de 5 num universo de 18, organizado por uma taxonomia que já
não é a que está em uso. Não é o índice incompleto — é o eixo do índice que está
errado.

O número **18 está confirmado** pela rodada de hoje: 17 sessões, uma por
repositório privado, mais este. O que antes era "~18" declarado pela rotina virou
contagem.

**Ação (👤, primeiro):** decidir se os nomes de setor podem ser publicados.
Alguns parecem nomes de organização, o que aciona os itens 1 (nomes) e 7
(titularidade) do checklist do [`SECURITY.md`](../SECURITY.md). Publicar a
taxonomia sem essa decisão é exatamente o tipo de vazamento que a rotina N2
procura — e o `AGENTS.md` já declara que a lista canônica de setores não entra
aqui enquanto essa decisão não for tomada.

**Ação (☁️, depois):** reeixar o índice para setor × repositórios, marcar os que
estão fora de qualquer rotina, e reconciliar o organograma da seção 3 do
blueprint com a taxonomia real. Os handoffs de **L1** são o insumo natural disso,
o que torna a decisão humana de L2 o gargalo dos dois itens.

**Verificação:** o número de repositórios declarados no índice bate com o número
que existe, e cada um tem setor.

### L3 — Executores e hook seguem não exercitados
**Severidade: média · Executor: ☁️ Nuvem + 👤 Humano · ABERTO**

**Parcialmente fechado pela realidade, e reconfirmado hoje:** o watchdog acumula
**17 execuções, todas com sucesso**, uma por dia desde 2026-08-04, a última em
**2026-08-20** — **nenhum dia perdido em dezessete**. "Confirmar que o job
executa" deixou de ser pendência há duas semanas, e o controle mais barato do
repositório é o único com histórico impecável.

O resto continua aberto: os oito executores foram escritos a partir da
especificação e nenhum rodou em trabalho real; o hook não foi instalado em nenhum
departamento; o plugin está em 0.1.0 e o
[README dele](../plugins/fundacao/README.md) declara isso.

É a mesma armadilha que o `oficial-governanca` existe para detectar: artefato
escrito não é controle aplicado.

**Ação:** instalar o plugin no piloto e corrigir o que a realidade contradisser.
**Destrava com L1:** os relatórios das 17 auditorias dizem, pela primeira vez, em
que terreno o plugin seria instalado. Instalar antes de ler o handoff é escrever
controle sobre terreno não verificado.

**Verificação:** o hook está instalado em pelo menos um departamento e bloqueou
ou liberou um push real, registrado.

#### L3.1 — O `guard-push` dependia de `jq`, ausente na máquina local
**Severidade: média · ✅ FECHADO em 2026-08-08 · Executor: ☁️ Nuvem**

Primeira execução do hook fora de teste sintético, na máquina do dono: `jq` não
existia, o hook declarou falha fechada e bloqueou o push — o comportamento
prometido, executado corretamente. O problema era a consequência: instalado
assim, bloqueava *todo* push, inclusive os que deveria liberar. Guardrail que
nega tudo é indistinguível de guardrail quebrado, e o primeiro reflexo de quem é
bloqueado é desinstalá-lo.

**Como fechou — sem instalar nada.** A primeira ação óbvia era instalar `jq` em
cada máquina; foi tentada e barrada (instalação de sistema não é feita por
agente). A correção melhor era outra: **remover a dependência dura**. O hook lê o
comando com `jq` *ou*, na falta dele, com o módulo `json` do Python — stdlib dos
dois lados, nada a instalar. Sem nenhum dos dois leitores, ou com entrada
malformada, continua falhando fechada.

Trocar "instale `jq` nas N máquinas do ecossistema" por "funciona onde já há `jq`
ou Python" também elimina um pré-requisito que teria de ser repetido em cada
departamento — e que seria esquecido em pelo menos um. Com 18 repositórios
confirmados, esse "pelo menos um" deixou de ser hipótese retórica.

**Verificação cumprida:** a suíte de 13 casos roda **sem shim algum**, com `jq`
ausente e o Python real no `PATH` — e passa inteira. Cobre os oito bloqueios, a
entrada malformada e as quatro liberações.

> Um caso da suíte reprovou na primeira passada e o defeito era do teste, não do
> hook: comando vazio é JSON válido, e comando vazio não é push — liberar está
> certo. O caso foi reescrito para mandar JSON quebrado de verdade. Fica
> registrado porque um teste que afirma a coisa errada é pior que teste nenhum:
> ele reprova o código correto e, invertido, aprova o errado.

### L4 — Cobertura recorrente: a maioria dos 18 segue fora de rotina
**Severidade: média · Executor: 👤 Humano (escolher) depois ☁️ Nuvem (executar) · PROPOSTA PRONTA**

O ecossistema tem **18 repositórios** (17 privados + o público). A rodada de
2026-08-20 deu **cobertura pontual a todos** — primeira vez que isso acontece, e
não é o que este item pede. Auditoria pontual mede o passado; **rotina agendada é
o que cobre o futuro**. Segredo, PII ou divergência de doutrina introduzidos
amanhã hoje não são vistos por ninguém até alguém lembrar de olhar.

#### As três formas, e o que decide entre elas

| | Desenho | Rotinas | Raio de um erro | Custo por rodada |
|---|---|---|---|---|
| **A** | uma rotina, todos os privados como fontes | 2 (privados + público) | **todos de uma vez** | uma sessão enorme |
| **B** | uma rotina por repositório | 18 | um repositório | 18 sessões pequenas |
| **C** | **uma rotina por setor** | ~6 | um setor | uma sessão média por setor |

Quatro restrições decidem, e três delas já estão estabelecidas neste repositório:

1. **R1 é inegociável** — privado e público nunca na mesma rotina. Isso já
   elimina qualquer desenho com uma rotina só, e é por isso que a coluna
   "rotinas" nunca é 1.
2. **O corolário de R1, que ainda não estava escrito:** *sessão não deveria
   montar repositórios cujos dados pertencem a donos diferentes.* R1 trata do
   caso extremo — privado × público —, mas a mesma lógica vale um degrau abaixo.
   Uma sessão com repositório de empregador, de negócio próprio e pessoal
   montados juntos não viola regra nenhuma e mesmo assim é a mesma classe de
   risco, em escala menor. **O desenho A falha nesse teste; o C passa por
   construção.**
3. **Cota de execuções.** O blueprint registra que Routines é research preview
   com teto diário de execuções por conta. O desenho B com todas disparando na
   segunda encosta nesse teto; qualquer desenho precisa **espalhar os disparos
   pela semana**, o que também evita que uma mudança ruim de prompt atinja tudo
   no mesmo dia.
4. **Raio de erro.** **P0 levou três semanas para ser corrigido** com um punhado
   de repositórios no escopo. O desenho A reencontra esse problema com 17.

**Recomendação: C, por setor.** O argumento decisivo não é o custo nem o número
de rotinas — é que **a fronteira de isolamento passa a ser a mesma que já governa
a titularidade do dado**. É o mesmo corte que decide o destino do backup (**D1**)
e o mesmo que o índice do `AGENTS.md` usa. Uma fronteira que serve a três
propósitos é mantida; uma que serve só a um é esquecida.

#### O que a rotina recorrente faz — e não faz

**Não é a auditoria integral.** Rodar as oito frentes toda semana em 18
repositórios é caro e desnecessário: a maior parte não muda. A rotina recorrente é
a passada leve — *o que mudou desde a última vez, e isso introduziu segredo, PII
ou divergência de doutrina?* — no degrau de modelo abaixo do topo, conforme o
procedimento de [`auditoria-integral.md`](../.claude/prompts/auditoria-integral.md).

A auditoria integral fica **sob demanda**: repositório novo, mudança estrutural,
ou achado que peça varredura completa.

**Ação (👤):** escolher entre A, B e C — e, escolhendo C, confirmar o corte por
setor, que é a mesma informação que **L2** já espera.

**Ação (☁️, depois):** criar as rotinas conforme
[`control-plane.md`](control-plane.md), com disparos espalhados pela semana, e
rodar cada uma uma vez à mão antes de confiar no agendamento. Rotina cuja
primeira execução ninguém conferiu é intenção, não controle.

**Verificação:** todo repositório do ecossistema aparece no escopo de exatamente
uma rotina recorrente, e nenhuma rotina mistura setores.

## Plano de execução — semana de 2026-08-17 a 2026-08-23

**Este plano tem validade de uma semana e envelhece de propósito.** Se a data
acima não for a da semana corrente, ele descreve um passado: reconstrua-o pela
regra da subseção seguinte em vez de seguir as datas. Plano datado que ninguém
reescreve é a categoria "realidade antiga" aplicada ao próprio backlog.

O plano anterior (semana de 2026-08-10) venceu há dez dias e foi descartado, não
copiado. Ele deu certo no que importava: P0 e P1, que eram sua linha com hora
marcada, fecharam no dia previsto.

### A regra que gera o plano, quando as datas vencerem

Em ordem, e o primeiro critério que se aplica decide:

1. **O que tem prazo imposto de fora** vem primeiro, sempre.
2. **O que destrava outros itens** vem em seguida — decisão humana que libera
   trabalho de nuvem vale mais que o trabalho de nuvem em si, porque a decisão é
   o gargalo e a execução não.
3. **O barato com consequência cara** antes do caro com consequência barata.
4. **O que só depende de sessão de nuvem** por último: não bloqueia nada e pode
   ser paralelizado, uma sessão por repositório (R1).

### O que a regra produz nesta semana

**Critério 1 — prazo de fora.** P0/P1 saíram, e com eles a única linha com hora
marcada que este backlog teve. O que ocupa o lugar é o **retorno dos 17
handoffs**: as sessões terminam sozinhas e os relatórios ficam parados em PR
draft no repositório de origem. O prazo não é de calendário, é de contexto — cada
dia que passa encarece reconstruir o que cada relatório quis dizer.

**Critério 2 — o que destrava.** A decisão de **L2** (nomes de setor podem ser
publicados?) destrava a consolidação de L1 *e* o reeixo do índice. A conferência
humana de **H1/H4** destrava a possibilidade de qualquer sessão voltar a afirmar
o estado dos controles.

**Critério 3 — barato com consequência cara.** **P2** é troca de texto em duas
telas e evita divergência silenciosa entre o que roda e o que está publicado. A
conferência de H1/H4 na UI custa cinco minutos e responde por três itens.

**Critério 4 — só nuvem.** **V1** (workflow de leitura de configuração) e a
consolidação do índice, que depende do transporte.

### A semana

Hoje é **quinta-feira, 2026-08-20**.

| Quando | O quê | Executor | Tempo |
|---|---|---|---|
| **Hoje (qui)** | Recolher os handoffs das auditorias que já retornaram; guardar o entregável G sanitizado de cada uma | 👤 | 30 min |
| **Hoje (qui)** | **H1 + H4** — conferir na UI e datar a conferência neste arquivo | 👤 | 5 min |
| ~~Sex~~ | ~~**P2** — trocar o prompt das rotinas pelo ponteiro~~ | ☁️ | **feito em 2026-08-20 para a N2**; a de control-plane espera a decisão de onde a skill mora |
| **Sex** | **L2** — decidir se os nomes de setor podem ser publicados | 👤 | 20 min |
| **Sáb/dom** | Recolher os handoffs restantes | 👤 | conforme retorno |
| **Antes de seg** | **V1** — escrever o workflow de leitura de configuração (depende de `.github/` estar livre) | ☁️ | 1 sessão |
| **Seg** | Conferir as duas execuções semanais — em especial se a de control-plane continua sem o público no escopo | ☁️ ou 👤 | 5 min |
| **Seg** | **L1** — consolidar os G no índice do `AGENTS.md`, com data | ☁️ | 1 sessão |

**Nenhum dia desta semana tem hora marcada**, e é a primeira vez que isso é
verdade neste arquivo — a hora marcada era P0. A segunda-feira segue sendo o dia
de conferir as rotinas, mas agora para confirmar que continuam corretas, não para
correr atrás de uma janela.

### Fora da semana, sem data

- **H3** — poucos minutos no terminal do dono, e destrava N6. Só entra num dia
  quando o PR Watch importar; até lá ele é decoração declarada, não pendência
  urgente. Note que hoje nem o estado dele é observável daqui (**V1**).
- **H2** — quando existir um segundo revisor. Não antes: ver a aritmética no item.
- **H5** — não tem data porque não tem dono declarado, e é o item de severidade
  alta mais antigo em aberto. Dezessete repositórios foram lidos por agente hoje;
  se as pré-condições não estiverem cumpridas, o custo disso não é técnico.
- **L3** — depende de os handoffs de L1 chegarem.
- **L4** — depende de L2, porque a topologia de rotinas segue a taxonomia.

### O que saiu da lista

O passo "mesclar o que está em voo" saiu por não ter mais objeto: zero PRs
abertos, dez mesclados, nenhuma branch residual. O bloco P0/P1, que ocupou a
linha de topo por três semanas, saiu por ter sido feito na UI em 2026-08-10.

**Três vezes seguidas o topo da lista saiu por ter sido cumprido** — o merge do
PR #7 e o watchdog, depois o bloco de configuração, agora P0/P1. É o sinal de que
a lista está viva; quando um item sair por ter sido esquecido, o sintoma será
este parágrafo parar de mudar.

O que **não** saiu, e merece nota: H5 está aberto desde 2026-08-02 sem uma única
linha de progresso. Item que nunca entra na semana não é item de baixa
prioridade — é item sem dono.

---

## Recomendações a outros arquivos

Esta sessão editou **apenas este arquivo**. O que segue exige mudança em arquivos
que outras sessões estavam editando em paralelo, e fica registrado aqui em vez de
ser feito à força:

- **`.github/workflows/claude-pr-watch.yml`** — o cabeçalho afirma "cinco runs" e
  descreve apenas 2026-08-08. O real é 22 execuções, 12 `skipped` e 10
  `cancelled`, zero sucesso e zero falha, a última em 2026-08-09. Trocar a
  contagem por uma descrição de comportamento, que não envelhece.
- **`AGENTS.md`** — o índice de projetos ganha as linhas dos repositórios
  privados quando os handoffs de L1 forem transportados; até lá, as células
  continuam em *não verificado*, que é o comportamento correto.
- **`SECURITY.md`** — vale acrescentar ao checklist a lição de **N19**: o
  checklist se aplica também aos relatórios e backlogs produzidos pela própria
  governança, que hoje são o único tipo de arquivo que ninguém audita.
- **`.github/`** — o workflow de **V1** ainda não existe. A ação está descrita
  por inteiro no item.

---

## Apêndice — o que dá para verificar, e de onde

O apêndice anterior publicava um comando que **não roda no ambiente de nuvem** e
um comando pronto de desativação de controle, num repositório público. Os dois
saíram. O que fica é o mapa honesto de onde cada coisa se verifica.

### Da nuvem, por qualquer sessão

Funciona, e é o que uma sessão deve usar antes de afirmar qualquer coisa:

| O que | Como |
|---|---|
| Branches remotas e resíduo de merge | `git branch -r`, depois de um fetch que remova as referências mortas |
| PRs abertos e mesclados | ferramenta MCP de pull requests, ou a página de PRs |
| Histórico de execução dos workflows | ferramenta MCP de Actions — devolve status, conclusão e data de cada run |
| Se `main` está protegida (só isso) | campo `protected` na listagem de branches |
| Conteúdo versionado, skills, prompts, workflows | leitura direta dos arquivos |

### Só da UI, hoje

Nenhuma sessão de nuvem alcança o que segue — ver
[a seção sobre isso](#o-que-a-nuvem-não-alcança--e-por-quê). O caminho é a
interface do GitHub, e o resultado deve ser **datado neste arquivo** por quem
conferiu:

| O que | Onde |
|---|---|
| Qual regra protege `main`, com que enforcement e com que bypass | *Settings → Rules* |
| Secret scanning (repositório público) e push protection | *Settings → Advanced Security* |
| Existência de segredo de Actions | *Settings → Secrets and variables → Actions* |
| Escopo, conectores e prompt das rotinas agendadas | UI de rotinas do Claude |

Cada um desses controles pode ser desligado na mesma tela em que é conferido.
Isso fica dito porque controle sem rota de saída conhecida é controle que alguém
desliga às pressas, do jeito errado, no dia em que ele atrapalhar. O comando não
é publicado: num repositório público, comando pronto de desativação de controle é
conveniência para quem não deveria tê-la — foi essa a correção de **N19**.

### O que ainda não se sabe verificar

- Se o token nativo de uma execução do Actions consegue ler regra de proteção e
  estado de secret scanning. **Não verificado.** O teste é a primeira execução do
  workflow de **V1**.
- O estado do secret scanning gratuito de repositório público. **Não
  verificado** — o único endpoint que responde está bloqueado, e a recusa da
  ferramenta de GHAS não serve como resposta.
