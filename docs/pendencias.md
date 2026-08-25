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

## Placar — rodada de 2026-08-20, atualizado em 2026-08-21

**Fechados nesta rodada**

| Item | O que a reverificação encontrou |
|---|---|
| **P0** — rotina de control-plane misturava público e privados | ✅ corrigido pelo humano na UI em **2026-08-10**. O escopo da rotina hoje tem **apenas repositórios privados**; o público saiu das fontes. O prompt passou a declarar que o repositório público nunca deve entrar no escopo e que, se aparecer, esse é o achado principal do relatório. A violação de **R1** acabou. |
| **P1** — rotina carregava conectores | ✅ corrigido junto. A rotina não tem **nenhum** conector anexado, que é o que o blueprint exige (mitigação de **R4**). |
| **N19** — este arquivo era um mapa de fraquezas | ✅ corrigido nesta reescrita — ver o lote de 2026-08-20 em [Entregue](#1-entregue-️). |

**Reclassificados — não são o que o arquivo dizia que eram**

| Item | Antes | Agora |
|---|---|---|
| **H1** — proteção de `main` | "fechado, ruleset ativo, bypass nunca" | ✅ **lido inteiro em 2026-08-21, e confere.** Enforcement ativo, zero bypass, deleção e force push bloqueados. Mas exige **PR sem exigir aprovação nenhuma** — isso não é regressão, é a configuração original, e virou **H1-bis**. |
| **H4** — secret scanning e push protection | "fechado, ambos `enabled`" | 🟡 **não verificável pela nuvem**. O que se provou hoje é que o GitHub Advanced Security está **desligado** — o que é um flag distinto do secret scanning gratuito de repositório público. Push protection não foi verificado por via nenhuma. |
| **L1** — quatro departamentos nunca auditados | "bloqueado por R1" | 🟢 **em voo**. Em 2026-08-20 foram despachadas **17 sessões de nuvem, uma por repositório privado**, cada uma escopada num único repositório. O que falta deixou de ser a auditoria e passou a ser o **transporte** do handoff. |
| **L4** — ~14 repositórios fora de rotina | "~18 no ecossistema, 4 cobertos" | 🔴 **cobertura recorrente**, não cobertura pontual. São **18 repositórios** (17 privados + o público); a rodada de hoje dá cobertura pontual a todos, e a maioria segue fora de qualquer rotina agendada. |
| **P2** — prompt de rotina fora do git | "falta a rotina N2" | 🟡 a reverificação mostrou que **as duas** rotinas tinham o prompt inteiro na UI, não uma. A N2 foi convertida em ponteiro no mesmo dia; a de control-plane segue. |

**Abertos**

| Item | Estado | Por quê |
|---|---|---|
| **S1** — dado pessoal versionado em repositórios privados | 🟡 **risco aceito** | verificado: 1 dos 3 limpo, 2 confirmados. Dono decidiu manter, privado, sob acesso dele (2026-08-21), e **reconfirmou no fim do dia**. Reabre se algum deixar de ser privado, ganhar colaborador ou surgir titular externo — e muda de natureza se os 14 PRs de remoção forem mesclados |
| **C1** — minutos de Actions a 90% | 🟢 **explicado em 24/08: não havia contradição** | teto foi a 3.000. A medição rodou e é válida — o denominador é 16, não zero. Ela media **minuto faturável** ($0, coberto por desconto) e o alerta media **consumo de franquia** (2.837,3 de 3.000 em 24/08) — duas grandezas, nenhuma contradição. Restam **162,7 min** e a franquia vira em **7 dias**; com $0 e *stop usage*, o Actions **para na conta** quando acabar. Repositório público não consome franquia: o consumo é dos privados. **Não é este repo** e **não é o plugin**. Orçamento adicional **decidido e gravado em 24/08: $0 com *stop usage*, conferido na tela**. Fecha quando a composição da cota for lida em Settings → Billing |
| **S2** — R1 cobre conteúdo, não inventário | ✅ **fechado em 25/08: risco aceito** | metadados de sessão entregam a **lista** dos privados a uma sessão do público, e em 24/08 mais três canais fizeram o mesmo — a medição do C1, a listagem de sessões e o rateio de faturamento. Aceito por desenho: é a conta do dono olhando os repositórios do dono, sem dado de terceiro. O mapeamento apelido → repo segue protegido, e o `SECURITY.md` declara que R1 cobre conteúdo e não inventário. **Sobra uma regra:** ferramenta que possa imprimir dado de privado numa sessão pública redige de fonte autoritativa e **verifica** antes de imprimir — falha fechada |
| **V1** — configuração não é reverificável pela nuvem | 🟡 **encolheu duas vezes; severidade cai de alta para média** | 21/08: dados do repo e **rulesets agora leem (200)**. 24/08: o `POST /rulesets` rodou com sucesso em 15 privados por outra sessão — o 403 de escrita é **allowlist do proxy desta frente**, não da conta. Seguem fora: secret scanning, segredos de Actions, colaboradores e `/branches/*/protection` (escopo do app, não proxy). **Não sustenta mais H1, H3 e H4**, que fecharam sem ele — [seção abaixo](#o-que-a-nuvem-não-alcança--e-por-quê) |
| **P2** — prompt de rotina só na UI | 🟡 metade | N2 fechada em 2026-08-20; control-plane depende de decidir onde a skill mora |
| **H1-bis** — `main` exige PR, mas zero aprovação | ✅ **fechado em 2026-08-21** | `verificar` exigido no `protect-main`, fixado no app do Actions, sem bypass. PR quebrado não entra mais — é plataforma, não boa vontade. O merge sem revisor segue doutrina |
| **H4** — secret scanning e push protection | ✅ **fechado** | ambos **ativos**, conferidos na UI em 2026-08-21 com evidência visual. GHAS é flag distinto e segue desligado — não era ele que importava |
| **H2** — `CODEOWNERS` exigível | 🟡 parcial | trava em ter um único dono, não em plano nem em ação. Nos privados o recurso passou a existir com o Pro (2026-08-21) — mas comprar a ferramenta não cria o segundo revisor |
| **H7** — branches principais dos privados desprotegidas | 🟢 **aplicado em 24/08 por API, mas não é gate de merge** | 17 de 18 com ruleset `deletion` + `non_fast_forward` na default, enforcement ativo, bypass vazio — **16 têm só essas duas**: impedem apagar e dar force push, **não exigem PR nem check e não impedem push direto**. Só este repo público tem gate de merge. Não foi clique humano: foi `POST /rulesets` em lote, de outra sessão. Fica aberta a **lacuna de rastreamento** entre "protegido contra destruição" e "com gate" |
| **H3 · N6** — PR Watch | ✅ **fechado por remoção** | 22 disparos, **zero execuções** — nunca alcançou a action. Removido em 2026-08-21 a pedido do dono. Deixá-lo parado era cobertura aparente |
| **H5** — pré-condições jurídicas | ❌ aberto, **decomposto em 25/08 em cinco linhas** | aberto desde 2026-08-02 sem dono porque era **um rótulo para cinco obrigações** de custos incomparáveis — a mais barata (um print datado, **H5.1**) represada atrás da mais cara (comunicação escrita a clientes, **H5.4**). Agora cada uma fecha sozinha. **H5.5** tem modelo escrito ([`registro-operacoes.md`](registro-operacoes.md)); o preenchido é N1 e mora no privado. **H5.3 colide com S1:** a aceitação de risco de lá cobria a *posse* do dado, não a *leitura por rotina* — e as 17 sessões de 20/08 clonaram os privados. Destrava com uma frase: os dois repos do S1 estão dentro ou fora do escopo das rotinas? |
| **L2** — o índice publicado tem o eixo errado | 🟡 **os nomes fecharam em 24/08, o eixo não** | a metade que agravava o item **fechou**: a coluna de departamento virou `D1`–`D5` com treze *"não verificado"*, e o `grep` de conferência pegou os cinco nomes reais que sobravam no blueprint. Conferido em 25/08 no `AGENTS.md` — a única ocorrência de *"não declarado"* que resta descreve o estado passado, dentro da nota. **Segue aberto o que dá nome ao item:** o índice publica um recorte por repositório, não setor × repositórios. Depende dos handoffs de **L1** |
| **L4** — cobertura recorrente | 🟡 **decidido** | desenho C (uma rotina por setor). Criar a rotina é na UI: daqui herdaria o ambiente público e repetiria o defeito do P0 |
| **A1** — orquestrador no prédio errado | 🟡 **decidido, plano escrito** | vai para o departamento de Fundação; visibilidade deste repo **não muda**. Ordem: criar no privado, conferir, só então podar aqui. Executa uma sessão escopada no privado — daqui violaria R1 |
| **L1** — consolidação dos handoffs | 🟡 quase fechado | fim de 2026-08-21: **15 relatados fechados, 2 em aberto** (`P16`, `P17`). "Relatado" porque R1 impede reverificar daqui — ver o item. As duas retenções são dado humano e correção na origem, nenhuma é falha de auditoria |
| **L3** — executores e hook não exercitados | 🟡 **o hook foi exercitado em 25/08; a distribuição não** | o item afirmava que o hook *"não foi instalado em nenhum departamento"* — **era falso**: está instalado neste repo (`D5`) via `PreToolUse`, e em 25/08 **bloqueou** (`force push bloqueado`) e **liberou** (`* [new branch] claude/reconciliar-l2-v1`) pushes reais, com saída literal. Mas o critério não distinguia o departamento de **origem** do de **destino**, e cumpri-lo aqui é dogfooding. Seguem abertos: instalar num piloto que não seja este, e os **oito executores, nenhum rodado em trabalho real** — os dois dependem de **L1** |
| **L6.1** — o guardrail lia o argumento de `-C` como destino | ✅ **fechado em 2026-08-25, no mesmo trabalho** | falso positivo medido: `git -C "$LIB" push` era negado com *"destino '"$LIB"' fora de claude/*"* — o fluxo que o fechamento de sessão prescreve. A suíte dizia **42/42** e nunca tinha exercitado `git -C`. Corrigido o parsing (não a política) e a suíte foi a **55 casos** — [item abaixo](#l61--o-guardrail-lia-o-argumento-de--c-como-destino) |
| **L7** — nomes dos privados no índice público | ✅ **fechado** | apelidos `P01`–`P17` em 2026-08-21; regra no `SECURITY.md`; varredura confirma nenhum nome real em arquivo versionado |

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
reverifica"*, e essa sessão futura não conseguia. **Remedida em 2026-08-21, e o
mapa mudou:** parte do que esta seção declarava inalcançável passou a responder.

**A medição de 2026-08-21, endpoint a endpoint, com token válido:**

| Caminho | Código | Mensagem literal | Causa |
|---|---|---|---|
| dados do repositório | **200** | — | **abriu** desde 20/08 |
| `/rulesets` (leitura) | **200** | — | **abriu** desde 20/08 |
| `/rulesets` (escrita) | 403 **aqui** | *"Write access to this GitHub API path is not permitted through this proxy"* | allowlist do proxy **desta frente** — em 24/08 outra sessão fez `POST` no mesmo caminho, com sucesso, em 15 privados. O 403 é do ambiente, não da conta |
| `/branches/*/protection` | 403 | *"Resource not accessible by integration"* | escopo do app, **não** o proxy |
| `/secret-scanning/alerts` · `/collaborators` | 403 | *"Access to this GitHub API path is not permitted through this proxy"* | allowlist do proxy |
| `/actions/secrets` · `/actions/permissions` | 403 | *"Access to this GitHub Actions path is not permitted through this proxy"* | allowlist do proxy |

**O que isso derruba.** Em 20/08 os dois primeiros caminhos devolviam *"GitHub
access is not enabled for this session"* — autorização do GitHub App —, e a
seção registrava que **H1** só voltaria a ser verificável se alguém reconectasse
essa autorização. Alguém reconectou, ou ela se resolveu sozinha; ninguém
percebeu, porque **ninguém tentou de novo**. O item ficou marcado como
inalcançável por um dia inteiro depois de deixar de ser.

> A lição não é sobre o GitHub. Um bloqueio medido uma vez virou propriedade
> permanente do arquivo, e a frase que o registrava — *"é a rede"* — era enfática
> demais para convidar nova medição. **Bloqueio tem data de validade, e este
> arquivo não escrevia nenhuma.** Toda linha de "não dá" daqui em diante carrega
> a data em que foi medida, e essa data é o convite para remedir.

**O que continua fora de alcance, agora com a distinção certa:** toda **escrita**
de configuração, e as leituras de secret scanning, segredos de Actions,
colaboradores e proteção de branch clássica. A escrita é o corte mais importante,
e ele é limpo: **a nuvem lê configuração, e não a aplica.** Aplicar continua sendo
clique humano.

- O binário `gh` **não existe** neste ambiente (`command -v gh` devolve vazio).
- Nenhuma ferramenta MCP disponível expõe ruleset ou proteção de branch — nem
  leitura nem escrita. O que abriu foi a API REST, não o MCP.
- **E o MCP também empobrece o que a REST devolve** — instância medida em
  25/08: o objeto de repositório do MCP descarta as sete flags de merge
  (`delete_branch_on_merge`, `allow_*`, `squash_merge_commit_*`), enquanto
  `GET /repos/tihh07/tihh07` devolve **200** com todas elas, **sem token** —
  repositório público. Ausência de campo na ferramenta não é ausência de acesso,
  e uma sessão já tratou uma pela outra (ver **H6**).
- A ferramenta de secret scanning recusa com *"Repository does not have GitHub
  Advanced Security enabled"* — o que prova o estado do GHAS e nada além dele.

**A regra do arquivo muda de forma, e fica mais exigente, não menos:**

- Item de configuração cuja **leitura** responde hoje pode ser verificado por
  sessão de nuvem, e deve ser — com a data e o código HTTP no registro. **H1
  entra nessa classe** e foi verificado em 21/08.
- Item cuja leitura **não** responde continua valendo a regra antiga: nenhuma
  sessão de nuvem escreve "fechado"; escreve "não verificável daqui em <data>,
  conferir na UI".
- **Nenhuma sessão de nuvem aplica configuração**, e isso não é limite de rede —
  a rede só confirma. É o gate.

O substituto continua desejável para o que não responde: **V1**, um workflow do
Actions rodando dentro do repositório com o token nativo da execução, que não
passa pelo proxy. Ele encolheu de escopo — não precisa mais cobrir ruleset — e
por isso ficou mais barato.

## Retomada — por onde a próxima sessão começa

Reescrita no fechamento de **2026-08-23**. A versão anterior era de 21/08; o que
ela dava como aberto fechou, e três coisas mudaram de natureza.

**1. O repositório está limpo, e isto foi conferido, não suposto.** Zero PRs
abertos, `main` protegida com as quatro regras (`deletion`, `non_fast_forward`,
`pull_request`, `required_status_checks`), nada não commitado. **Um resíduo:** a
branch `claude/status-c1-medicao`, **provada mesclada** (zero linhas de diferença
contra `main`), continua no remoto. Apagá-la é um clique humano — ver o item 4.

> **Corrigido em 2026-08-25: o resíduo não existe mais, e não foi clique humano
> que o tirou.** O remoto tem hoje **uma única branch, `main`** — conferido por
> `list_branches`. A `claude/status-c1-medicao` sumiu em algum momento entre 23 e
> 25/08; **quem a apagou e quando não se estabelece daqui**, e fica dito em vez de
> inventado. O que se mediu foi o caso novo: a branch deste ciclo foi criada,
> mesclada e **desapareceu sozinha**, sem nenhuma deleção emitida — ver **H6**.

**2. Quatro itens fecharam entre 21 e 23/08**, e nenhum deve ser recomendado de
novo: **H1** (ruleset lido inteiro), **H1-bis** (`verificar` obrigatório, fixado
no app do Actions), **H4** (secret scanning ativo), **L7** (apelidos aplicados).
Fecharam também o item 5 do checklist N2 — as nove regras de permissão passaram
para a âncora de raiz de projeto — e o item 2, emendado para separar número de
terceiro de custo de infraestrutura própria.

**3. Não recomende `$CLAUDE_PROJECT_DIR` em regra de permissão.** Variável de
ambiente **não é expandida** ali; só vale em `hooks`. A âncora certa é `/` — barra
simples, que resolve para a raiz do projeto. Este erro já foi cometido e corrigido
antes de escalar para dezessete repositórios; a sintaxe está no relatório
`reports/publicacao/2026-34.md`.

**4. Duas paredes limitam o agente, e elas não são a mesma coisa que a doutrina.**
O `SECURITY.md` autoriza agente a apagar branch já mesclada — **o mediador da
plataforma não deixa**, e devolve 403 mesmo com a prova feita. O mesmo vale para
qualquer escrita de configuração de repositório. **O ambiente desta frente é mais
restritivo que a regra escrita**, e onde os dois divergem quem vence é o ambiente.

> **Corrigido em 2026-08-24.** Este parágrafo dizia *"a plataforma"* e terminava
> em *"não procure rota alternativa"*. As duas coisas se provaram falsas no mesmo
> dia: outra sessão criou **15 rulesets por `POST`** nos privados, num lote de dez
> minutos. O bloqueio é do **ambiente desta sessão**, não da plataforma nem da
> conta — e a rota alternativa existia. A pergunta certa, quando uma escrita for
> barrada aqui, não é *"como libero o proxy"*; é **"de qual sessão isso passa"**.
> Registrar e devolver ao humano continua certo como piso; parar de procurar, não.
> Ver **H7**.

> **Emendado em 2026-08-25 — a parede segue de pé, a consequência que ela citava
> não.** O item 1 apontava para cá para explicar por que uma branch mesclada
> ficava esperando clique humano. Esse efeito **não se reproduz**: a plataforma
> apaga a branch de trabalho no ato do merge, e o resíduo não se acumula mais.
>
> A parede em si **não foi reverificada hoje**, e a distinção importa: não houve
> tentativa de deleção por API — esta sessão não tem ferramenta para isso — e
> `git push --delete` é barrado pelo próprio `guard-push`, que é o
> comportamento desejado, não um obstáculo a contornar. Então o que caiu foi a
> **necessidade** de apagar, não a demonstração de que o agente consegue.

**5. O que sobra é quase todo humano**, e nenhum destrava insistindo daqui —
**mas o H7 saiu desta lista em 24/08, e a razão importa: ele não foi destravado
por humano, foi executado por outra sessão, cujo ambiente escreve onde o desta
aqui é barrado.** · **C1** (não é mais "medir": a
medição rodou em 24/08 de uma sessão local, com `gh auth token`, e enumerou os
privados sem PAT novo — o que sobra é **decidir o orçamento** e explicar o zero)
· **S2** (enquadrar o alcance de R1) · **L2**
(a coluna de departamento — **decidida e aplicada em 24/08**; o que resta são as
treze células que dependem do transporte de L1) ·
**P16** · **H5**.

**6. O despacho por sessão voltou a funcionar em 23/08**, depois de sete falhas
seguidas de `create_session` ao longo do fim de semana. O piloto de três foi
disparado — um repositório por sessão, somente leitura, com os quatro tokens de
resposta do prompt em `.claude/prompts/despacho-diagnostico.md`. **Leia os três
retornos antes de despachar correção**, e despache só onde o diagnóstico apontar.

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

**Cuidado com um choque de prefixo, notado em 2026-08-21.** `P0`, `P1` e `P2` são
**itens deste backlog**; `P01`–`P17` são **apelidos de repositório** no índice do
`AGENTS.md`. Um zero à esquerda separa as duas famílias, e isso é frágil demais
para durar. Enquanto não houver renomeação — que custaria reescrever histórico de
texto em vários arquivos —, vale a leitura: **dois dígitos é repositório, um
dígito é item.** Apelido nunca é reciclado, então a colisão não piora; ela
também não some sozinha.

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

**Nada.** O único item que ficava aqui era o **N6**, e ele fechou em 2026-08-21
— por remoção, não por conserto.

**O que o N6 dizia:** o PR Watch acordava, era barrado pela condição de guarda e
nunca executava de verdade. Verificado na API em 2026-08-20: **22 execuções e
nenhuma real** — 12 `skipped`, 10 `cancelled`, zero sucesso e zero falha, a
última em 2026-08-09. O job mais recente reportava `steps=0`: nenhum passo chegou
a existir, então o checkout e a action nunca rodaram e a chave de API nunca foi
consultada.

O mesmo fato lido nas duas direções, e as duas continuam verdadeiras:

- **É evidência de campo de R9/R2.** Os eventos chegaram e o gate de autor +
  menção segurou, 22 vezes. Esse controle deixou de ser suposição.
- **E era cobertura aparente.** Workflow que nunca executa não exercita a action,
  o modelo, as permissões nem o prompt — mas aparece na aba *Actions* como se
  cobrisse alguma coisa. O dono optou por removê-lo em vez de destravar o segredo
  (**H3**), e a remoção é o registro honesto: nada se perdeu, porque nada rodava.

> A lição que sobra é do cabeçalho, não do workflow. Ele afirmava "cinco runs" e
> descrevia um único dia, quando eram 22 execuções em pelo menos dois dias —
> subconta por fator ~4, e era a segunda vez que aquele mesmo cabeçalho
> envelhecia. **Contagem escrita à mão em cabeçalho volta a envelhecer no dia
> seguinte.** É por isso que o número de casos da suíte do guardrail hoje não é
> registrado em lugar nenhum além da saída do próprio script.

---

## 2. Exige o humano 👤

Nenhum agente executa estes itens, e essa é a intenção — são exatamente os
controles que sustentam o gate humano. A nuvem só consegue **reportar que estão
abertos**, o que este arquivo faz. Desde 2026-08-20, em vários deles a nuvem nem
isso consegue: ver **V1**.

### S1 — Dado pessoal versionado: verificado, e o risco foi aceito pelo dono
**Severidade: a mais alta deste arquivo · 🟡 RISCO ACEITO em 2026-08-21 · Executor: 👤 Humano**

Três varreduras somente-leitura decidiram uma contradição entre duas sessões:
**um repositório limpo do que se alegou, dois com dado real de pessoa
identificável** — num deles em volume que a alegação original não sugeria.

**A decisão do dono, em 2026-08-21:** não apagar. Os repositórios seguem
**privados**, o acesso é dele, e os agentes que operam neles operam em nome dele.
O risco fica **aceito e registrado**, que é o desfecho que a ordem de remediação
deste item pedia — avaliar antes de apagar — resolvido no primeiro passo.

**O que essa decisão resolve, e o que ela não resolve.** Ela resolve o que estava
travado: nada é apagado, nenhum histórico é reescrito, nenhum clone quebra. Ela
**não** transforma dado de terceiro em dado próprio. Se parte do dado pertence a
pessoas que não são o dono do repositório, a obrigação eventual de notificá-las
não depende do repositório ser privado — ela depende de haver titular e de haver
exposição. Isso fica dito uma vez, aqui, porque é o tipo de coisa que ninguém
lembra de reabrir: **manter privado contém a exposição, não extingue o dever.**

**O controle que a decisão torna necessário.** "Privado com meu acesso" só
descreve a realidade enquanto o acesso for de fato restrito, e há uma via que não
é óbvia: **toda sessão de nuvem despachada para um desses repositórios clona o
conteúdo** para um contêiner efêmero. Neste ciclo isso aconteceu várias vezes por
repositório. Aceitar o risco implica, portanto:

- não anexar esses repositórios como fonte de sessão sem necessidade — em
  particular, nunca numa sessão multi-repositório, que multiplica cópias sem
  ganho;
- preferir varredura escopada a fechamento genérico quando o alvo é um deles;
- revisar periodicamente quem tem acesso, porque a premissa "só eu" é a única
  coisa que sustenta a aceitação.

**Verificação deste item:** a aceitação está registrada com data. Ele reabre se
qualquer um dos três repositórios deixar de ser privado, se um colaborador for
adicionado, ou se surgir titular externo identificável no dado.

**Quarta condição, acrescentada no fim de 2026-08-21 sem mexer na decisão.** No
mesmo dia, uma sessão escopada nos privados produziu **14 PRs de remoção de dado
pessoal, em 12 repositórios**, a pedido do dono. Confirmado com ele: **a decisão
de manter vale, e é a que este item registra.** Os PRs ficaram abertos.

Isso cria um estado que o item precisa vigiar, e é por isso que vira condição de
reabertura em vez de nota de rodapé: **se aqueles PRs entrarem, este registro
passa a descrever uma realidade que acabou** — dirá "o dado fica" sobre
repositórios de onde o dado saiu. Não é hipótese remota; é trabalho pronto,
esperando um merge, e merge de PR aberto é a coisa mais fácil de acontecer sem
ninguém avisar o backlog.

**R1 impede esta sessão de verificar aquele estado**, então a condição é escrita
para quem tiver acesso: se os PRs de remoção forem mesclados, este item não
reabre — ele **fecha por outro caminho**, e o texto tem de dizer que o dado saiu,
não que foi mantido.

> A decisão não é a que eu recomendaria por padrão, e é legítima: o dono é quem
> pode aceitar risco sobre o próprio dado. O que este arquivo pode fazer é
> garantir que a aceitação seja **explícita e datada** em vez de virar omissão —
> risco aceito sem registro reaparece como surpresa, e aí já não há decisão, só
> consequência.

### S2 — R1 protege o conteúdo dos privados, não a lista deles
**Severidade: média · ✅ FECHADO EM 2026-08-25 — risco aceito, e sobra uma regra de contenção · Descoberto em 2026-08-21, quatro ocorrências em 24 horas**

**Como apareceu.** Esta sessão — a do repositório **público** — consultou o
estado de uma sessão de nuvem para saber se um trabalho tinha terminado. A
resposta trouxe, junto, **a lista completa dos repositórios no escopo daquela
sessão**: dezessete nomes reais de repositório privado, entregues a uma sessão
que **R1** existe para manter do lado de fora.

Nenhuma regra foi quebrada. Nenhum repositório privado foi clonado, aberto ou
lido. **R1 continua íntegro no que ele protege** — e o que ele protege é
conteúdo.

**O que o achado diz, e é desconfortável:** as ferramentas de *metadados de
sessão* atravessam a fronteira que as de repositório respeitam. Qualquer sessão
deste ambiente, inclusive esta, consegue **enumerar os repositórios** da conta
sem tocar em nenhum. A barreira é de leitura de arquivo, não de nomes.

**Por que isso importa aqui em particular.** Ontem este repositório trocou
dezessete nomes reais por apelidos e escreveu, no `SECURITY.md`, que o
mapeamento *"vive num repositório privado"*. A metade cara desse controle segue
de pé: **qual apelido corresponde a qual repositório** continua fora daqui. A
metade barata não: **a lista de que repositórios existem** é obtenível por
qualquer sessão da conta, sem clonar nada.

Vale dizer sem eufemismo o que isso faz com o controle: L7 impede a
**publicação** dos nomes — e essa era e continua sendo a exposição que importa,
porque publicação alcança terceiros. O que ele não faz, e nunca fez, é impedir
que uma sessão da própria conta os veja.

**Segunda ocorrência, em 2026-08-24, e ela move o item.** A primeira veio de
metadados de sessão — um canal que ninguém escolheu. A segunda veio de trabalho
deliberado desta frente: a medição do **C1**, disparada daqui, enumerou os
repositórios privados pela própria API do GitHub. Isso por si só já era o que o
item descreve. O que ele **não** previa é o que aconteceu em seguida: a
ferramenta tinha um sanitizador, o sanitizador **falhou aberto**, e quinze nomes
reais foram impressos no transcript de uma sessão escopada no repositório
público.

O defeito era de construção, não de descuido: a redação procurava o **formato da
saída** para achar o que redigir. Quando toda leitura falhou, o formato não
apareceu, o sanitizador não encontrou nada para redigir — e deixou passar tudo.
Redação que depende do sucesso da operação que ela protege é redação que só
funciona quando não é necessária.

Isso não muda o enquadramento — muda o que a decisão precisa cobrir. Não basta
responder *"a conta do dono pode se enumerar?"*; é preciso responder também **o
que vale quando a contenção de que dependemos falha**. Nada aqui chegou a
arquivo versionado, então **L7** e a sanitização N2 seguem íntegros. Mas o
transcript não é apagável, e a exposição, embora interna, é maior que a que este
item registrava.

**O que NÃO fazer.** Não há remediação de agente aqui, e tentar uma seria pior
que o problema: deixar de consultar o estado das sessões de nuvem trocaria uma
exposição interna por relatos não verificados — que é exatamente o defeito que
custou três diagnósticos errados em **L1**. E abster-se de uma leitura que a
plataforma oferece não a torna indisponível para a próxima sessão.

#### ✅ DECIDIDO em 2026-08-25 — leitura 1, exposição de inventário aceita por desenho

Decidido pela sessão, sob autorização explícita do dono para assumir portões que
dependeriam dele. **Reversível a qualquer momento**, e a razão de fechar em vez de
esperar é que o item acumulou **quatro ocorrências em 24 horas** — metadados de
sessão, a medição do C1, a listagem de sessões e o rateio de faturamento — e um
item que descreve o cotidiano da operação sem decidir nada só ensina a ignorá-lo.

**Por que a leitura 1.** A exposição é da conta do dono para a conta do dono. O
inventário não contém dado de terceiro: são nomes de repositório dele. A leitura 2
— separar contas ou ambientes entre a frente pública e as privadas — remove uma
exposição interna ao custo de duplicar credencial, rotina e superfície de erro, e
esse custo é desproporcional ao que ela remove. É o mesmo raciocínio que fechou o
**S1**.

**O que o `SECURITY.md` já faz, e continua valendo:** o texto de R1 declara, em
vez de deixar implícito, que a regra protege **conteúdo** e não **inventário**, e
que o mapeamento apelido → repositório — a metade que importa — segue fora daqui.
Um controle que se sabe estreito é utilizável; um que se supõe amplo, não.

#### E a quarta ocorrência acrescentou uma exigência que a decisão não dispensa

Aceitar a exposição de inventário **não** aceita que a contenção falhe em silêncio.
Do que aconteceu em 24/08 sai uma regra operacional, e ela não é sobre topologia:

> **Toda ferramenta que possa imprimir dado de repositório privado numa sessão
> escopada no público redige a partir de uma fonte autoritativa e verifica que
> nenhum nome sobreviveu antes de imprimir. Falha fechada.**

O sanitizador que falhou procurava o **formato da saída** para saber o que redigir;
quando toda leitura falhou, não havia formato, não havia o que redigir, e passou
tudo. Redação que depende do sucesso da operação que ela protege só funciona quando
não é necessária. A ferramenta já foi reescrita assim, e as varreduras de
sanitização desde então rodam contra a lista autoritativa da conta — nenhuma contra
o formato do texto.

**Ação (👤): decidir o enquadramento, não construir controle** — *feito acima; o
que segue é o registro das duas leituras que se ofereceram.* A diferença não é
retórica:

1. **Aceitável por desenho** — é a conta do próprio dono olhando os próprios
   repositórios, e nenhum terceiro entra nisso. Então o item fecha como risco
   aceito, com a data, e **R1 passa a declarar explicitamente que cobre conteúdo
   e não inventário** — hoje ele não diz nem uma coisa nem outra, e é a omissão
   que faz o controle parecer mais amplo do que é.
2. **Não aceitável** — e aí o que muda não é a regra, é a topologia: sessões da
   frente pública precisariam de uma conta ou ambiente separado dos privados.
   Isso é caro, e a decisão é de quem paga.

**Recomendo a primeira**, e a razão é a mesma que governa **S1**: a exposição é
para a própria conta do dono, o inventário não contém dado de terceiro, e o custo
da segunda é desproporcional ao que ela remove. Mas registro em vez de assumir —
a diferença entre um controle que cobre menos do que se pensava e um controle
que cobre exatamente o que se declarou é toda a diferença, e só se sabe qual é
depois de alguém dizer.

**Verificação:** o `SECURITY.md` declara, no texto de R1, que a regra cobre
conteúdo de repositório e **não** inventário de repositórios — ou a topologia
mudou. Qualquer uma fecha; o estado atual, em que a regra é silenciosa sobre o
ponto, não.

### H1 — Proteção de `main`: lida inteira, e ela é o que se dizia
**Severidade: alta · ✅ VERIFICADO em 2026-08-21 · Verificado por: ☁️ Nuvem, via API**

Este item passou 24 horas marcado como *"parcialmente verificável"* porque a
leitura do ruleset devolvia 403. Em 2026-08-21 o mesmo endpoint devolveu **200**,
e o controle foi lido por inteiro em vez de inferido.

**O que a leitura devolveu**, e é o registro que faltava:

| Propriedade | Estado |
|---|---|
| Enforcement | **ativo** |
| Alvo | a branch default |
| Atores com bypass | **nenhum** — inclusive o dono |
| Deleção da branch | **bloqueada** |
| Histórico reescrito (force push) | **bloqueado** |
| Pull request | **exigido** — e com **zero aprovações**, que é o **H1-bis** |

**Nada regrediu, e é a primeira vez que isso pode ser dito com evidência.** O que
foi criado em 2026-08-08 está de pé, do jeito que foi descrito. O item fecha
aqui; o que ele deixou em aberto — a contagem de aprovações em zero — não é
regressão, é a configuração original, e vive em **H1-bis**.

**A nota de método vale mais que o resultado.** O item não estava bloqueado; ele
estava **medido uma vez e nunca remedido**. O 403 de 20/08 virou propriedade
permanente do arquivo porque a frase que o registrava era enfática o bastante
para desencorajar a segunda tentativa. Custou uma requisição descobrir. Ver a
[seção sobre o que a nuvem alcança](#o-que-a-nuvem-não-alcança--e-por-quê), que
por causa disso passou a datar cada bloqueio.

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

**Nota de 2026-08-21, e ela vale para os privados, não para cá.** *Code owners*
em repositório privado exigia plano pago, e o Pro foi assinado. O impedimento
neste repositório continua sendo o outro — um único dono, aritmética, não plano.
Nos dezessete privados, o recurso passou a existir; usá-lo lá esbarra na mesma
aritmética enquanto o dono for o único revisor. **Comprar a ferramenta não cria
o segundo revisor.**

### H7 — As branches principais dos privados seguem desprotegidas
**Severidade: alta · 🟢 APLICADO EM MASSA POR API EM 2026-08-24 — MAS O QUE FOI APLICADO NÃO É GATE DE MERGE · Executor: ✅ script no privado de governança**

Registrado como item próprio em 2026-08-21, depois de aparecer duas vezes dentro
de outros: como achado de auditoria em **L1** e como argumento de compra em
**C1**.

**O que se sabe:** pelo menos uma branch principal de repositório privado está
sem proteção nenhuma. Quantas das dezessete estão, esta sessão **não pode
verificar** — R1 — e o número não deve ser adivinhado.

**O que mudou:** a causa registrada era limite de plano, e deixou de ser. Com o
Pro ativo, proteção de branch existe em repositório privado. O item saiu de
"decidir se vale pagar, ou aceitar o risco por escrito" e virou configuração.

---

## 2026-08-24 — aplicado, e o registro abaixo envelheceu em três pontos

**Origem:** medição de leitura feita por uma sessão escopada no privado de
governança, trazida pelo dono. **Não reverificada daqui** — R1 impede, e vale a
regra da casa: *"fechado aqui é sempre relato"*.

**O que existe hoje, medido por `gh api` em 18 repositórios:**

| | |
|---|---|
| Com ruleset `deletion` + `non_fast_forward` na default | **17 de 18** |
| Destes, com **também** `pull_request` | **1** |
| Destes, com **também** `required_status_checks` | **1** (o mesmo) |
| Com branch protection **clássica** na default | **0 de 18** |
| Sem ruleset algum | 1 (repositório em modo somente-leitura) |

Alvo `~DEFAULT_BRANCH`, enforcement `active`, `bypass_actors` **vazio**.

> **"Protegido" aqui quer dizer protegido contra destruição, não gate de merge.**
> Dezesseis dos dezessete rulesets têm **exatamente duas regras**: impedem apagar
> a branch e impedem force push. **Não exigem PR, não exigem review, não exigem
> status check, e não impedem push direto na default.** O único repositório com
> gate de merge real é este, o público, cujo ruleset `protect-main` também carrega
> `pull_request` e `required_status_checks`.

**A omissão das duas regras é deliberada e documentada** no privado, por dois
deadlocks que este arquivo já conhece: status check obrigatório que nunca roda
trava o merge para sempre, e *"Require approvals: 1"* em repositório de
colaborador único deixa todo PR inmergível, porque ninguém aprova o próprio PR.
É a mesma razão pela qual `required_approving_review_count` é **0** aqui.

**Três coisas escritas acima envelheceram, e ficam corrigidas em vez de apagadas:**

**1. "Falta configurar, é clique humano na UI, um repositório por vez" — falso.**
Foi aplicado por `POST repos/<owner>/<repo>/rulesets`, de um script versionado no
privado de governança. Os `created_at` mostram um lote de **15 em 10min08s**,
entre 14:31:14Z e 14:41:22Z — laço de script, não mão humana.

**2. "Vale para qualquer superfície da Claude — todos chegam ao GitHub pelo mesmo
mediador" — falso, e era a afirmação mais cara do item.** Ela mandava a próxima
sessão *não procurar rota alternativa*. A rota existia: **outra sessão escreveu**.
O bloqueio de escrita em `/rulesets` é do **ambiente desta frente**, não da
plataforma nem da conta. A lição do item inverte-se: quando uma escrita for
barrada aqui, a pergunta certa não é *"como libero o proxy"* — é **"de qual
sessão isso passa"**.

**3. O 403 *"Upgrade to GitHub Pro"* não reproduz mais.** Hoje
`branches/<default>/protection` devolve **404 "Branch not protected"** nos 18,
inclusive nos privados. O endpoint lê; o que ele reporta é ausência de proteção
clássica.

**Duas armadilhas de verificação, que valem mais que o resultado:**

- **`.protected` da branch não responde a pergunta.** Ele devolve `true` sempre
  que existe ruleset, e por isso **não distingue** "só deletion + non_fast_forward"
  de "gate de merge completo". Quem checar `.protected` vai concluir que está tudo
  protegido.
- **Script verde não é evidência de ruleset criado.** A falha de criação cai num
  ramo `|| echo` que **não altera o exit code**. Só a releitura de
  `repos/<repo>/rulesets` prova. Nesta rodada nenhum faltou — mas isso foi
  verificado relendo, não confiando no verde.

**O que fica aberto, e é lacuna de rastreamento real:** não há item — nem aqui nem
no privado — acompanhando a **diferença** entre "protegido contra deleção e force
push" e "com gate de merge". A decisão de não exigir PR está tomada e justificada;
o que não existe é o registro de que os dois estados são diferentes e de qual vale
para qual repositório.

**Não medido, e dito para ninguém supor:** push direto na default **não foi
testado** (exigiria escrita), e o stdout da execução real do script não foi
observado — a evidência é o estado resultante mais os `created_at`.

---

**O registro abaixo é de 2026-08-21 e vale como história do que se acreditava.**

**Duas paredes independentes impedem um agente de aplicar isto, e a distinção
importa porque uma delas é um botão que você tem** (e não deve apertar):

| Parede | Evidência de 2026-08-21 | Configurável? |
|---|---|---|
| **1. Mediador da integração** | o `PUT` **nunca chega ao GitHub**: resposta sem `Server: github.com` e sem `X-Github-Request-Id`, corpo *"Write access to this GitHub API path is not permitted through this proxy"*. O token do ambiente tem 14 caracteres e prefixo `prox` — é um marcador, não credencial: a credencial real vive no mediador | **não.** Não há ajuste, e não é a política de egresso da conta — essa está limpa (`recentRelayFailures` vazio) |
| **2. Permissão do GitHub App** | `/branches/*/protection` **chega ao GitHub** e o GitHub recusa: `X-Accepted-Github-Permissions: administration=read`. Ler ruleset pede `metadata=read`, que o app tem; escrever pede `administration=write`, que ele não tem | **sim** — e conceder **não destrava nada**, porque a parede 1 é anterior |

**E há um terceiro fato, medido depois, que torna a pergunta "como liberar isso"
malposta.** Mandei uma requisição para a API do GitHub com um token deliberadamente
inválido, e depois **sem cabeçalho de autorização nenhum**. As duas voltaram
`200`, identificando a conta corretamente.

**A sessão não tem credencial do GitHub.** Ela tem uma **identidade emprestada**:
o mediador injeta a credencial real, seja lá o que a sessão mande — ou não mande.
Não existe token aqui para ampliar, restringir ou vazar. O que decide quem a
sessão é, e o que ela pode escrever, mora inteiramente do outro lado.

Isso reenquadra as duas paredes acima: não é que uma credencial esteja sendo
filtrada. É que **nunca houve uma**. Perguntar como liberar o proxy é perguntar
como usar uma chave que a sessão não tem — e a resposta não é "peça mais
permissão", é que a permissão não é um objeto que exista deste lado.

> Vale para qualquer superfície da Claude, não só esta sessão: outra sessão, um
> agente com navegador, um ambiente diferente — todos chegam ao GitHub pelo mesmo
> mediador, com a mesma identidade emprestada. Um navegador não muda isso; muda
> só de onde a requisição parte. Para um agente agir **como você** nas telas de
> configuração, ele precisaria da sua senha e do seu segundo fator — o que é
> entregar credencial, classe 3 do `SECURITY.md`, e não se faz.

> **Não conceda `Administration` ao app na esperança de destravar isto.** Amplia o
> que agentes alcançam em todos os repositórios e não compra a escrita, porque a
> recusa acontece antes de o GitHub ser consultado. É o pior tipo de troca: custo
> real, benefício zero, e o benefício zero só se descobre depois de conceder.

**O único caminho que de fato contorna** é um workflow do Actions com um PAT em
segredo, rodando dentro do próprio repositório — ele não passa pelo mediador. E
ele se anula: quem consegue adicionar um workflow consegue usar o segredo, então
proteger a branch com uma chave capaz de desprotegê-la, guardada atrás dessa
mesma branch, é circular. O `SECURITY.md` já registra exatamente esse raciocínio
para a credencial de backup.

**O que dá para entregar sem contornar nada:** a configuração pronta e um script
que a aplica em lote, ambos em
[`plugins/fundacao/templates/ruleset/`](../plugins/fundacao/templates/ruleset/README.md).

O script é explicitamente **para o dono rodar, nunca um agente** — e a distinção
não é cerimônia: rodá-lo por agente seria contornar a parede 2 com o token de
outra pessoa, que é a definição de rota alternativa. Ele simula por padrão, exige
`--aplicar` para escrever, descobre os repositórios pela API — em vez de carregar
uma lista de privados dentro de um repositório público — e falha fechada quando
não consegue interpretar uma resposta.

**Duas correções vieram de rodá-lo, não de relê-lo**, e as duas eram do mesmo
tipo — código que parecia certo e nunca tinha sido exercitado:

1. **Ele perguntava se existia um ruleset com o nome dele**, em vez de perguntar
   se a branch já estava protegida. Rodando contra este repositório, que já tinha
   `protect-main`, a simulação anunciou que criaria `protect-default` **em cima**
   — o empilhamento que o README ao lado mandava evitar e que o código não
   implementava. Corrigido para consultar as regras **efetivas** da branch, que é
   a pergunta certa.
2. **Ele presumia `main`.** Repositório antigo ainda é `master`, e proteger a
   branch errada é pior que não proteger: parece feito. Passou a ler a branch
   default de cada repositório.

> A primeira dessas é a mais instrutiva: **o README descrevia o comportamento
> correto e o código fazia outro.** Documentação e implementação divergindo em
> silêncio é o defeito que este repositório inteiro existe para caçar — e ele
> apareceu dentro do arquivo que eu tinha acabado de escrever para caçá-lo.

Dezoito repositórios viram um comando. O gate não se move: continua sendo uma
pessoa, com a credencial dela, decidindo aplicar.

**Ação (👤), um repositório por vez, na UI:** exigir PR antes do merge, proibir
force push e proibir deleção da branch default. **Não exija aprovação** — é a
mesma armadilha que este repositório documenta em **H1-bis**: com um único
colaborador, exigir aprovação tranca o dono fora do próprio repositório, porque
o GitHub não aceita autoaprovação.

**Por que é o item de maior retorno da lista.** O gate humano do ecossistema
inteiro é hoje **doutrina em dezessete repositórios e controle em um** — este,
que é justamente o que menos guarda coisa sensível. H7 inverte essa assimetria, e
não depende de nenhum agente, de nenhuma sessão e de nenhuma medição.

**O que ele *não* resolve:** push protection continua indisponível em privado de
usuário, então nos dois repositórios com dado pessoal confirmado (**S1**) segue
não havendo barreira que aja *antes* de o dado entrar. Proteger a branch impede
merge sem PR; não impede commit com dado dentro do PR.

**Verificação:** em cada privado, a branch default aparece como protegida e uma
tentativa de push direto é recusada pelo servidor — não pelo hook local, que é
outra camada.

### H3 — Segredo de Actions para o PR Watch
**Severidade: média · ABERTO por regra, não por esquecimento**

O PR Watch precisa de uma chave de API em segredo de Actions para que sua metade
executável (**N6**) saia do papel.

**Estado hoje: não verificado.** O endpoint que lista segredos de Actions está
entre os bloqueados pelo proxy (**V1**), então esta sessão não pode nem confirmar
nem negar que o segredo exista.

**Ação (👤):** criar o segredo **no terminal ou na UI do dono** —
*Settings → Secrets and variables → Actions → New repository secret*, com o nome
exato `ANTHROPIC_API_KEY`, que é o que
`.github/workflows/claude-pr-watch.yml` referencia. Nome errado falha em
silêncio: a action recebe string vazia e o job quebra sem dizer por quê.

**A alternativa é igualmente válida, e precisa ser dita:** se o PR Watch não for
usado, **remova o workflow** em vez de deixá-lo parado. Um workflow que dispara
e nunca executa aparece na aba Actions como se fosse cobertura, e o item **N6**
existe exatamente porque ele nunca provou nada. Automação que nunca rodou é
decoração, não controle — e decoração num repositório N2 induz a falsa
segurança de que algo está vigiando o PR.

**Isto não se confunde com o check de verificação.**
`.github/workflows/verificacao.yml` não usa chave nenhuma e roda hoje. O PR
Watch é outra coisa: reativo, dirigido por menção a `@claude`, e é dele que
depende H3 e N6.

**Este item nunca será fechado por agente, e não é limitação de ferramenta.**
Manipular chave de API é proibido por regra de conduta, independentemente de quem
peça ou de como o pedido seja formulado: o valor não passa por sessão de agente
nem por chat. Quem cria o segredo é quem o digita. Registrado assim para que uma
sessão futura não trate isso como pendência a executar.

### C1 — Minutos de Actions a 90% do plano
**Severidade: média · 🟡 MEDIDO EM 2026-08-24, E O RESULTADO NÃO FECHA A CONTA · Executor: 👤 Humano (ler a cota) + 💻 Local (mediu)**

> **A medição finalmente rodou, e o que ela devolve é uma lacuna, não uma causa.**
>
> **16 de 16** repositórios com pelo menos um workflow foram efetivamente
> medidos. Total de minutos faturáveis no período de cobrança corrente: **zero**.
>
> Isso **não é medição vazia** — a distinção é do PR #25 e se provou na primeira
> execução. Fossem 0 de 0, o instrumento estaria mudo; sendo 16 de 16, é leitura.
>
> **As três hipóteses que este item acusou ao longo de 2026-08-21 caem juntas:**
> o workflow distribuído pelo plugin (que um `find` já havia derrubado), o cron
> diário como linha de base, e o custo por merge do ciclo de fechamento. Nenhuma
> aparece na medição. Nenhuma delas precisava ter sido afirmada.
>
> **E abre uma contradição que fica registrada em vez de resolvida à mão:** o
> alerta de 21/08 falava em **1.802 de 2.000 minutos**. A medição de 24/08 não
> encontra nenhum deles. As duas afirmações não se conciliam por raciocínio
> daqui, e as explicações candidatas — ciclo de cobrança que virou na assinatura
> do Pro, gasto fora de `affiliation=owner`, ou consumo que não é Actions
> (Codespaces, storage, LFS) — são **hipóteses, e este item já pagou caro por
> tratar hipótese como causa três vezes**.
>
> **O que fecha:** ler a composição da cota em **Settings → Billing**. Pela API
> exigiria o escopo `user`, que o token local não tem (`gist`, `read:org`,
> `repo`, `workflow`) — ampliar escopo é ação de credencial, humana.
>
> **Por que levou três dias para uma leitura de dois minutos:** o instrumento
> tinha dois defeitos em série, e nenhum dos dois foi encontrado por leitura de
> código — os dois só apareceram ao executar contra a API de verdade. Um `\r`
> do Python no Windows ia parar dentro da URL e derrubava 15 de 16 requisições
> devolvendo um zero que parecia resposta (PR #23); o proxy que intercepta TLS
> matava a primeira chamada e o script culpava o token (PR #24). **O zero de
> hoje só é legível porque a contagem `16 de 16` passou a existir** (PR #25).

Alerta do GitHub em 2026-08-21: **1.802 de 2.000 minutos consumidos**, 90% do
incluído, com reset em 1º de setembro. Restam ~198 minutos para 11 dias.

**Este repositório não é a causa, e a distinção importa.** Actions é **gratuito
em repositório público** — nada que roda aqui entra nessa conta. As execuções do
`verificacao.yml` medidas hoje levaram **4, 7 e 11 segundos**; mesmo se fossem
cobradas, dariam poucos minutos por dia de trabalho intenso. **Não desligue a CI
daqui por causa deste alerta**: ela é grátis, e foi ela que encontrou o defeito
do guardrail que uma suíte dedicada dava como verde.

**A causa está nos privados**, e há duas hipóteses de peso diferente:

1. **O pico de hoje** — o ciclo de fechamento mesclou dezenas de PRs em dezesseis
   repositórios privados, e cada merge dispara CI na default, somada à CI de cada
   PR. Isso explica um salto, mas é evento único e não se repete.
2. **A linha de base, que é a hipótese preocupante** — cron replicado nos
   privados: execução diária, todo dia, cobrada, independentemente de haver
   trabalho. Um pico se absorve; uma linha de base se paga todo mês.

   **Correção de 2026-08-21, no mesmo dia:** afirmei que o culpado era o
   `watchdog.yml`, "template distribuído pelo plugin". **Estava errado, e os
   arquivos deste repositório desmentem.** O plugin distribui **um** workflow, o
   de backup, e ele já era **semanal**. O watchdog existe só aqui, no repositório
   público, onde Actions é gratuito. Então **o que consome minuto nos privados
   não saiu daqui** — é workflow que eles têm por conta própria, e **R1 me impede
   de olhar**. A hipótese continua de pé na forma; perdeu o culpado nomeado.

   Fica o registro do erro, porque ele repete o padrão do dia: **afirmei um
   mecanismo plausível sem abrir o diretório que o confirmaria.** Levou um `find`
   para derrubar.

**Não verificável desta sessão:** **R1** impede a sessão do repositório público
de abrir um privado para contar execuções. A verificação é humana, ou de uma
sessão escopada num privado: aba *Actions*, workflow *Watchdog*, e ver se há uma
execução por dia.

#### 2026-08-24, fim do dia — a contradição não existia, e o instrumento estava certo

Lido na tela de *Billing → Usage*, aba **Actions**, trazido pelo dono:

| | |
|---|---|
| **Billable usage** | **$0** = $17,40 de consumo − $17,40 de desconto |
| **Included usage** | **2.837,3 min usados / 3.000 incluídos** (94,6%) |
| Reset da franquia | **em 7 dias** |

**As duas leituras sempre foram verdadeiras, medindo coisas diferentes.** O
`medir-actions.sh` lê **minuto faturável** — que é zero, porque o desconto cobre a
franquia inteira. O alerta lê **consumo da franquia**. Não havia contradição: havia
duas grandezas com o mesmo nome coloquial, "minutos".

> **O instrumento estava certo; a pergunta é que estava errada.** Três dias foram
> gastos consertando um script que respondia corretamente a uma pergunta que não
> era a que o item fazia. Os defeitos consertados nos PRs #23 e #24 eram reais — mas
> nenhum deles era a causa do zero, e nenhum poderia ter sido, porque o zero **não
> era um defeito**.

**Isso encerra a lacuna que este item carregava**, e derruba as duas hipóteses que
sobravam: não é `affiliation=owner` escondendo repositório de organização, e não é
consumo fora do Actions. É a franquia sendo consumida normalmente, por trabalho que
não gera cobrança.

**E inverte a urgência.** Sobram **162,7 minutos** e a franquia vira em 7 dias. Com
o orçamento em $0 e *stop usage* ligado — a decisão de hoje —, quando a franquia
acabar **o Actions para na conta inteira** até o reset. O custo aceito ao decidir
deixou de ser hipotético: ele tem data.

**O que este repositório contribui para esse consumo: nada.** Actions em
repositório **público** é coberto pelo desconto e **não** consome a franquia — é o
que a própria tela diz, ao listar *"discounts cover Actions usage in public
repositories"*. Os 2.837 minutos são dos privados. Otimizar os workflows daqui não
devolve um minuto sequer; **onde a otimização paga é nos privados**, e o rateio por
repositório está em *View details*, na mesma tela — leitura humana, R1 impede daqui.

#### 2026-08-24, depois — o CSV fecha ao minuto, e a hipótese de cron cai

O relatório oficial de uso da conta (`usageReport`, linha a linha, campo
`quantity`) foi lido por duas sessões em separado — a de governança e esta — e as
duas chegaram ao mesmo lugar. **Reconciliação exata:**

| | |
|---|---|
| Linux, repositórios privados | **2.527 min** |
| Windows, 186 min brutos × 1,667 | **310 min** equivalentes |
| **soma** | **2.837 min** |
| Billing (tela) | 2.837,3 — **diferença 0,0** |

> **E isso mede o que antes era inferência.** Este arquivo afirmou, algumas horas
> antes, que repositório público não consome franquia — lendo o texto do desconto.
> O CSV prova: o público gastou **63 min** de Linux no período, e é exatamente a
> diferença entre os 2.590 min totais de Linux e os 2.527 dos privados. A conta
> só fecha se os 63 ficarem de fora.

**A hipótese de cadência de cron estava errada, e era a primeira da lista de
sondagem.** No 1º colocado a suspeita recaía sobre dois workflows **agendados** —
um de ingestão diária falhando em 8 de 8 execuções, e um de medição a cada 3 horas
com ~77 execuções no mês. Medido:

| Workflow do 1º colocado | Minutos | Disparo |
|---|---|---|
| integração contínua | **672** (59%) | push / PR |
| varredura de segredo | **309** (27%) | push / PR |
| medição horária | 81 (7%) | agendado |
| ingestão diária que falha sempre | **8** (0,7%) | agendado |

> **Cortar cadência de cron economiza ~40 min/mês e deixa 981 intactos.** O gasto
> não é agendado: é disparado por `push` e `pull_request`. A sonda de menor retorno
> era a que estava em primeiro lugar na lista — porque *"cron diário"* é a causa que
> mais parece verdadeira antes de medir, e este item já pagou três vezes por isso.

**A ingestão que falha em 8 de 8 custa 1 minuto por execução**, porque falha
*antes* de instalar as dependências pesadas. Falhar cedo é barato — o defeito dela
é real, mas não é de custo.

**Onde está o retorno, medido e em ordem:**

- **1º colocado, os dois workflows de push/PR: 981 min = 34,6% da franquia inteira,
  num repositório só.** Picos de 178 min num dia e 142 no seguinte. Falta ler os
  arquivos para saber *por quê* — gatilho duplicado, `concurrency` sem
  `cancel-in-progress`, ausência de filtro de `paths`.
- **2º colocado: 471 min**, também todo push/PR.
- **3º colocado: a única poda que não custa nada.** Um workflow roda em **Windows**,
  cujo multiplicador **nesta conta é 1,667** ($0,01 contra $0,006 por minuto) — e
  **não 2×**, como foi dito antes de olhar a tarifa aplicada. Os 186 min brutos
  viram 310. Migrar para Linux, se o job permitir, devolve **~124 min/mês sem perder
  cobertura nenhuma**.

**Erro de método, registrado porque ele reaparece:** estimar minutos dividindo o
`gross_amount` do repositório por $0,006 **superestima**, porque o gross inclui
Codespaces, que não consome minuto de Actions. No 2º colocado deu ~602 contra 471
reais — **22% de erro**. No 3º a fórmula acertou por acidente aritmético: como o
Windows é cobrado a $0,01 e a divisão usou $0,006, o resultado calhou de equivaler
ao minuto já multiplicado. Acerto por coincidência não valida o método.

**Ainda não medido:** o CSV diz **quanto**, não **por quê**. Gatilho duplicado,
`concurrency`, `timeout-minutes` e filtro de branch exigem ler os arquivos de
workflow nos privados — sondagem em curso na sessão de governança, **R1** impede
daqui.

**O que a medição devolveu, em números** — restaurado em 2026-08-24 do texto que
o `b2782fb` removeu ao adotar a versão rival. As duas sessões cederam uma à
outra ao mesmo tempo, e nessa troca esta tabela caiu sem que ninguém a
descartasse:

| | |
|---|---|
| Repositórios privados medidos | **16** |
| Com pelo menos um workflow | **16 de 16** |
| Sem leitura de Actions | **0** |
| Minutos faturáveis no período corrente | **zero** |
| Retries de TLS / falhas residuais | 56 / **0** |

**Por que não rodava, e por que isso importa para confiar no zero.** O
`medir-actions.sh` morria no primeiro `GET /user`: `curl (35) schannel
CRYPT_E_NO_REVOCATION_CHECK`, HTTP 000 — a rede local passa por um proxy que
intercepta TLS e o schannel do curl às vezes não consegue checar a revogação do
certificado. Pior, o script chamava isso de *token inválido* e mandava trocar
uma credencial que estava boa. Corrigido nos PRs **#24** (retry com
`--ssl-no-revoke`, avisando em stderr toda vez) e **#25** (contagem de
repositórios com workflow).

> **Ele falhava fechado, então nunca chegou a produzir um zero mentiroso.** Esta
> é a linha que faz o zero medido valer alguma coisa: sem ela, um leitor futuro
> não tem como distinguir um zero que foi lido de um zero que a ferramenta
> quebrada inventou. Foi a primeira coisa a se perder na troca de versões, e é a
> última que se poderia dispensar.

**Uma ressalva de R1, dita em vez de contornada.** Esta medição foi disparada de
uma sessão escopada no repositório **público**. Nenhum nome de repositório
privado entrou **neste arquivo**: o relatório completo foi para um
arquivo local não versionado e só **contagens** atravessaram.

> **Correção de 2026-08-24, escrita pela sessão que errou.** A frase acima dizia
> originalmente que nenhum nome entrou *"na sessão"*. No arquivo, verdade — e é
> a metade que importa para publicação. **Na sessão, não.** Uma execução anterior
> da mesma ferramenta, noutra sessão também escopada neste repositório público,
> imprimiu **quinze nomes reais de repositório privado** no transcript. O
> sanitizador do script falhou **aberto**: ele redigia procurando o formato da
> saída, e quando toda leitura falhou o formato não apareceu, então não havia o
> que redigir e tudo passou. Nada chegou a arquivo versionado, e o transcript não
> é apagável. A ferramenta foi reescrita para redigir a partir da lista
> autoritativa da API e **verificar** que nenhum nome sobreviveu antes de
> imprimir — mas o registro fica, porque um controle que falha aberto e um
> controle que funciona são indistinguíveis no dia em que dá certo.

Ainda assim, ler
metadados de faturamento dos privados a partir daqui está na fronteira que o
**S2** descreve — R1 cobre conteúdo, e isto é inventário. Não me arrogo o
enquadramento: fica como caso concreto para o S2 decidir, e se a decisão for
"não", o conserto é rodar a medição de uma sessão escopada num privado, não
apagar este registro.

**Ação (👤): ✅ DECIDIDO em 2026-08-24 — orçamento adicional em $0, operar dentro
do limite mensal.** A recomendação era essa, e a razão é o modo de falha: com $0,
a CI dos privados **para** quando os minutos acabarem, e o dono percebe na hora;
sem $0, o aviso vem como fatura, depois. **Entre um controle que avisa falhando e
um que avisa cobrando, o primeiro é melhor** — e este é reversível a qualquer
momento.

O custo dessa escolha é real e foi aceito junto com ela: com o orçamento travado,
um merge em privado pode encontrar CI parada antes da virada do ciclo, e **isso
vai parecer defeito quando for orçamento**. Fica escrito aqui para que a próxima
sessão que topar com uma CI parada em privado consulte este parágrafo antes de
diagnosticar.

**A decisão está tomada, e a aplicação também — confirmada em 2026-08-24 na tela
de *Settings → Billing and plans → Budgets and alerts*, trazida pelo dono:**

| Escopo | Produto | Stop usage | Gasto | Orçamento |
|---|---|---|---|---|
| conta | **Actions** | **Yes** | $0 | **$0** |

Existem cinco orçamentos de conta, todos em $0 com *stop usage* ligado — Actions,
Packages, Codespaces, Git LFS e os SKUs de crédito de IA. **Não havia nada a
criar:** o botão *New budget* teria duplicado um orçamento de Actions que já
existia. Fica escrito porque a pergunta "onde eu gravo isso" tem, aqui, a resposta
menos esperada — já estava gravado.

Não é ação de agente de qualquer forma: pela API exige escopo `user`, que o token
local não carrega — verificado, não suposto (`gh: This API operation needs the
"user" scope`) —, e escrita de configuração de faturamento é do dono por regra,
não por limite técnico.

> **E a decisão não explica o zero.** São dois problemas que este item carrega
> juntos e que não se resolvem um ao outro: *quanto se pode gastar* está decidido;
> *por que a medição não encontra o gasto* continua aberto — 1.802 de 2.000
> reportados em 21/08 contra zero minuto faturável medido em 24/08. Travar o teto
> sobre um consumo que a medição não enxerga não torna o consumo visível. A
> leitura que falta é a da composição da cota, na mesma tela.

**A poda feita em 2026-08-21, aqui, com o custo de cada uma declarado:**

| Mudança | Ganho | O que se perde |
|---|---|---|
| `verificacao.yml`: removido o gatilho `push: [main]` | **metade das execuções** — todo merge rodava a verificação duas vezes, PR e push, no mesmo commit | nada. A segunda execução não trazia informação nova |
| `watchdog.yml`: diário → **semanal** | 7× menos execuções | **latência de detecção sobe para até sete dias.** O watchdog existe para perceber quando a automação para; semanal, ele percebe mais tarde. Aceitável para operador solo, e está escrito no cabeçalho |
| `backup-drive.yml` (template): timeout 30 → **15 min** — **só no template** | corta pela metade o teto do caso patológico, multiplicado por cada privado que instalou o template | nada em operação normal — backup de repositório de documentação leva minutos. **Mas esta linha esteve numa tabela chamada “a poda feita aqui” descrevendo uma poda que aqui não foi feita:** a cópia instalada continua em 30, e a divergência é deliberada — o minuto é cobrado nos privados que instalam o template e grátis neste repositório público. Ficou dois dias sem estar declarada em lugar nenhum, até o `bb876e1` pôr a exceção no cabeçalho dos dois arquivos |

**A armadilha que NÃO foi usada, e está escrita no workflow para ninguém tentar:**
filtro `paths`/`paths-ignore` no check de verificação parece economia e é
armadilha. Um check **obrigatório** que não roda nunca reporta, e um check que
nunca reporta **bloqueia o merge para sempre**. Filtro de caminho e check
obrigatório são incompatíveis.

**O plano Pro: o que ele resolve e o que não resolve.** Verificado na
documentação do GitHub em 2026-08-21, não inferido:

| Recurso | Free | Pro | Vale para este problema? |
|---|---|---|---|
| Minutos em repositório **privado** | 2.000 | **3.000** | **+50%, não é solução.** Teto maior sobre um consumo não medido |
| Actions em repositório **público** | grátis | grátis | *"The use of standard GitHub-hosted runners is free: In public repositories"* — por isso o check deste repo não entra na conta |
| **Branches protegidos** em privado | ❌ | ✅ | **É o argumento de compra.** Fecha o item de branch principal desprotegida, que estava registrado como falta de ferramenta e era limite de plano |
| **Code owners** em privado | ❌ | ✅ | Dá sentido ao **H2** fora do repositório público |
| **Secret scanning / push protection** em privado | ❌ | ❌ | **Não vem no Pro.** Em repositório de usuário exige Enterprise Cloud com Managed Users, ou Enterprise Server com Secret Protection |

**A conclusão, e ela separa duas coisas que se confundem:** o Pro é uma **compra
de governança**, não de capacidade de CI. Proteger dezesseis branches principais
justifica o custo sozinho. Os 3.000 minutos são consequência.

**E o buraco que permanece depois de assinar é justamente o deste ecossistema:**
os repositórios com dado pessoal confirmado são privados, e o Pro **não** coloca
push protection neles. A única barreira que age *antes* do segredo entrar
continua existindo só no repositório público — que é, ironicamente, o único onde
ela é grátis e o único que não guarda esse tipo de dado.

**Assinado em 2026-08-21.** O dono ativou o Pro. O que isso passa a permitir, e
o que continua faltando fazer:

| Passa a existir | O que ainda falta |
|---|---|
| Proteção de branch nos dezessete privados | **ligar**, um a um. Pro dá a ferramenta, não a configuração — virou o **H7** |
| *Code owners* em privado (**H2**) | idem: exige `CODEOWNERS` no repositório e a regra no ruleset |
| Teto de 3.000 minutos | **medir o consumo.** O teto subiu 50% sobre um número que ninguém tinha |
| — | Push protection em privado **continua fora do alcance** — exige Enterprise |

**Ferramenta de medição entregue em 2026-08-21**, em
[`plugins/fundacao/templates/actions/`](../plugins/fundacao/templates/actions/README.md):
minutos faturáveis **por workflow e por repositório**, ordenados, somente
leitura. Ela não opina sobre causa — entrega números.

Existe por causa deste item, e o cabeçalho dela diz isso sem suavizar: o C1
passou o dia com o culpado errado **duas vezes**, e o padrão dos dois erros é
idêntico — *mecanismo plausível afirmado sem medir*. A ferramenta encerra a
categoria.

**E ela roda do celular**, o que era o bloqueio prático: um **Codespace** dá bash,
curl e python3 num Linux de verdade aberto no navegador, com o `GITHUB_TOKEN` já
injetado — para esta leitura normalmente não é preciso criar token nenhum. O
plano Pro, já assinado, inclui 180 core-hours por mês; a medição custa minutos.

Duas coisas na saída merecem leitura atenta, e estão no README: os sistemas
operacionais vêm **separados**, porque Windows e macOS custam mais por minuto e
somá-los esconde o que encarece; e **se o total lido for muito menor que a cota
da conta, a diferença é o achado** — está em repositório que o script não leu.

> Verificado no repositório público antes de entregar: três workflows, três
> respostas `200`, **zero minutos faturáveis**. Zero ali é o resultado *correto* —
> Actions é gratuito em público —, e a distinção está escrita no código para
> ninguém ler zero como defeito.

**A medição começou e não terminou.** Em 2026-08-21 uma sessão escopada num
privado contava consumo por workflow e devolveu uma linha de base da ordem de
**doze minutos por commit**. Isso era **relato parcial**, não medição fechada.

**Em 2026-08-22 ficou pior que parcial: virou órfão.** A sessão mudou de tarefa
sem entregar o veredito, e o número nunca foi confirmado nem desmentido. Ele
continua aqui **como relato**, e é assim que deve ser lido — confundir hipótese
plausível com medição foi exatamente o que produziu o culpado errado dois blocos
acima, no mesmo item, no mesmo dia.

**O que destrava agora não depende de sessão nenhuma.** `medir-actions.sh` está
na `main` e roda num Codespace em minutos, com o `GITHUB_TOKEN` que já vem
injetado. O item deixou de esperar um agente e passou a esperar um comando.

**Se o número se confirmar, ele inverte a recomendação deste item.** Custo por
*commit* é proporcional ao trabalho, não ao calendário — e então podar cron, que
é o que esta seção vinha propondo, resolve pouco. Contra custo por commit valem
outras alavancas: `concurrency` com `cancel-in-progress` (mata a execução
anterior a cada push numa mesma branch), gatilho por `paths` — que **nos
privados** é seguro, porque lá nenhum check é obrigatório, ao contrário daqui —,
`timeout-minutes` apertado e matriz de jobs reduzida. Nada disso deve ser
aplicado antes do relatório: a lição do parágrafo anterior é literalmente essa.

**Verificação:** o consumo de Actions nos privados é **medido** — aba Actions de
um privado, ordenada por consumo — e a decisão sobre o orçamento está registrada
com data, travado ou aceito por escrito. Assinar o Pro **não** fecha este item:
teto maior sobre consumo não medido é adiamento, não conserto.

> O alerta chegou no mesmo dia em que o ciclo de fechamento rodou, e a leitura
> fácil seria "a automação de hoje gastou tudo". Metade disso é verdade. A outra
> metade — o cron diário replicado por template — não apareceria em nenhum
> alerta, porque ela não tem pico: ela só sobe devagar todo mês. **O custo que
> aparece é o do evento; o que dói é o da rotina.**

### H4 — Secret scanning e push protection: verificado e ligado
**Severidade: alta · ✅ FECHADO em 2026-08-21 · Verificado por: 👤 Humano, na UI**

**Os dois estão ativos.** Conferido na UI em *Settings → Advanced Security*, com
evidência visual: tanto **Secret Protection** quanto **Push protection** exibem o
botão **"Disable"** — o que só aparece quando o recurso está ligado. A leitura do
botão importa: um print com "Enable" provaria o contrário, e é o tipo de detalhe
que se lê errado com pressa.

Num repositório público N2, push protection é a única barreira que age **antes**
de o segredo virar público. Depois do push, conteúdo público é comprometido e não
corrigível. Saber que ela existe muda o perfil de risco de todo o repositório.

**O que o item supunha e estava errado.** A sessão de nuvem tinha concluído que o
GHAS estava desligado — e estava certa sobre isso, mas tirou daí a inferência de
que a proteção poderia não existir. **GHAS é um flag distinto do secret scanning
de repositório público**, e a distinção era exatamente o que a sessão não
conseguia ler. O que faltava não era a proteção; era a via de leitura.

**Recomendação lateral, sem urgência:** *Dependency graph* e *Dependabot alerts*
aparecem desligados. Este repositório não tem gerenciador de pacotes, então o
ganho é estreito — mas os workflows usam actions de terceiros com versão fixada
(`actions/checkout@v4`), e é isso que o Dependabot manteria atualizado. Decisão
de conveniência, não de risco.

> Este item passou por três estados em duas semanas: fechado por leitura de API
> não repetível, reaberto como não verificável, e agora fechado com evidência
> visual e data. O padrão que fica: **item de configuração não fecha por leitura
> de agente** — mas também não fica aberto para sempre por isso. Fecha quando um
> humano olha e registra o que viu, que foi o que aconteceu aqui.

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

#### Decomposto em 2026-08-25 — não é um item, são cinco

**O item está aberto desde 2026-08-02 porque o rótulo é único e as obrigações
não.** O portão do blueprint (seção *Condições jurídicas*) impõe **cinco** coisas
distintas, com donos e custos que não se parecem. A mais barata custa um print e
estava represada atrás da mais cara, que é externa e demora semanas. **Item que
só fecha quando cinco coisas fecham nunca mostra progresso, e por isso ninguém o
pega** — 23 dias sem dono declarado é a evidência disso, não uma coincidência.

| # | Obrigação | Fase | Estado | Executor |
|---|---|---|---|---|
| **H5.1** | opt-out de treinamento confirmado, **evidência datada** | 1 | ❌ aberto | 👤 — um print com data |
| **H5.2** | titularidade dos dados de cada repo verificada | 1 | ❌ aberto | 👤, ou chega pelos handoffs de **L1** |
| **H5.3** | repos lidos por rotina **sem dado pessoal bruto** (*regra dura*) | 2 | ❌ **colide com S1** | 👤 — decisão de escopo |
| **H5.4** | ciência dos clientes **por escrito** | 2 | ❌ aberto | 👤 — externo, é o que manterá H5 aberto |
| **H5.5** | registro simplificado de operações (Res. CD/ANPD 2/2022) | 2 | 🟡 **modelo escrito em 25/08** | ☁️ redige · 👤 preenche |

#### H5.3 colide com S1, e a colisão não é hipótese

O **S1** concluiu, com três varreduras somente-leitura, que **dois repositórios
privados contêm dado real de pessoa identificável** — num deles em volume que a
alegação original não sugeria — e o dono **aceitou o risco em 2026-08-21**. A
regra dura da Fase 2 diz que repositório lido por rotina **não** contém dado
pessoal bruto.

O próprio S1 já escrevera a mitigação: *"não anexar esses repositórios como fonte
de sessão sem necessidade"*. Mas em **2026-08-20 foram despachadas 17 sessões,
uma por privado**, e sessão de nuvem **clona o conteúdo** para um contêiner
efêmero. Se aqueles dois estavam no lote — e não há por que supor que não —, a
regra dura já foi atravessada uma vez.

> **A aceitação de risco do S1 cobria a posse do dado, não a leitura por rotina.**
> São coisas diferentes: posse é estado, leitura é operação, e cada leitura por
> agente cria cópia nova, fora do país, num contêiner que ninguém inspeciona
> depois. Este arquivo tratava as duas como uma só, e é isso que a decomposição
> corrige.

**A decisão que destrava H5.3 cabe numa frase:** aqueles dois repositórios estão
**dentro** ou **fora** do escopo das rotinas? Fora → a regra dura volta a valer e
H5.3 fecha por exclusão de escopo. Dentro → exige sanitização **na origem**, que
é trabalho real e não decisão.

#### H5.5 — o modelo existe; o preenchimento é N1

Escrito em 2026-08-25: [`registro-operacoes.md`](registro-operacoes.md), na forma
simplificada que a Res. CD/ANPD 2/2022 admite para agente de pequeno porte.

**O registro preenchido não pode morar aqui**, e a razão é o item 3 do checklist
do [`SECURITY.md`](../SECURITY.md): ele mapeia dado pessoal a sistema, titular e
volume. Publicá-lo entregaria de graça o mapa que um atacante teria de descobrir.
Segue-se o padrão que o [`control-plane.md`](control-plane.md) já fixou — **a
forma é pública, o mapa operacional não** —, e o preenchido vive no privado de
governança.

O modelo já carrega o ponto que mais se omite: **toda sessão de nuvem clona o
repositório** para um contêiner efêmero fora do país. Isso é tratamento e é
transferência internacional, e um registro que descreve as rotinas mas omite a
clonagem descreve metade da operação.

**Ação, agora com dono por linha:** 👤 fecha H5.1 hoje (custo: um print) e decide
H5.3 (custo: uma frase); ☁️ já entregou o modelo de H5.5; H5.2 chega de graça com
**L1** se os handoffs trouxerem titularidade; H5.4 é externo e estreita — só se
aplica onde há cliente cujo dado esteja presente, que é subconjunto, não os 17.

**Verificação, por linha:** H5.1 — existe evidência datada do opt-out. H5.2 —
cada repositório em escopo de rotina tem titularidade declarada. H5.3 — os dois
repositórios do S1 estão declaradamente fora do escopo, ou sanitizados na origem.
H5.4 — existe comunicação escrita, datada, aos clientes afetados. H5.5 — o
registro preenchido existe no privado e cada linha tem data de revisão.

> **H5 fecha quando as cinco fecharem** — mas cada uma fecha sozinha, e é essa a
> diferença que a decomposição compra. Enquanto o item era um só, "fechar H5"
> significava resolver simultaneamente um print e uma comunicação jurídica a
> terceiros, o que garantia que nenhum dos dois acontecesse.

### H6 — Branch residual do PR #7 no remoto
**Severidade: média · ✅ FECHADO em 2026-08-08 · reconfirmado em 2026-08-20**

A branch sobrevivente ao merge do PR #7 foi apagada, e o padrão se manteve: em
2026-08-20, `git branch -r` devolve apenas `origin/HEAD` e `origin/main`.
**Dez PRs foram mesclados e nenhuma branch de trabalho sobrou.** O check
"branches `claude/*` sem PR aberto" do watchdog nunca teve motivo para falhar.

Fica o registro do padrão, que é o que interessa reter: apagar no ato do merge é
o que impede a categoria 4 da auditoria de poda de reaparecer todo ciclo. Doze
dias e três merges depois, continua valendo.

**Reconfirmado em 2026-08-25, e desta vez de dentro do ciclo.** As confirmações
anteriores eram leituras de estado — `git branch -r` num instante em que nenhuma
branch sobrava, o que também é o que se veria se ninguém tivesse aberto PR
nenhum. Aqui o ciclo inteiro foi observado no mesmo dia: a `claude/…` do PR #38
**existia** (o push devolveu `* [new branch]`), o PR foi mesclado por squash em
`45c85c8`, e minutos depois `list_branches` devolve **só `main`**. Nenhuma
deleção foi emitida entre os dois pontos — não havia como: o `guard-push` barra
`push --delete` e a sessão não tem ferramenta de apagar branch. Logo a remoção é
da plataforma, no merge.

**Lido na configuração, ainda em 2026-08-25:** `GET /repos/tihh07/tihh07` →
**HTTP 200**, com `delete_branch_on_merge: true`. A causa deixou de ser inferida
do efeito: a plataforma apaga a branch no merge porque o repositório está
configurado para isso. Junto vieram `allow_squash_merge`, `allow_merge_commit`,
`allow_rebase_merge` (os três `true`) e `allow_auto_merge: false` — que explica
por que auto-merge nunca esteve disponível aqui.

> **A versão anterior deste parágrafo, de horas antes, dizia que o flag "não foi
> lido — o payload que esta frente recebe não o traz", e citava o V1 como
> "mesma classe de limite". Estava errado nas duas metades**, e o erro é o que
> vale reter.
>
> O que não traz o campo é o **payload do MCP**, que normaliza o objeto de
> repositório e descarta as sete flags de merge. Isso não é a fronteira do que se
> alcança daqui: a REST responde, e responde sem autenticação, porque o
> repositório é público. Confundir *"a ferramenta que usei não traz"* com *"não
> se lê daqui"* é exatamente o defeito que a [seção de
> alcance](#o-que-a-nuvem-não-alcança--e-por-quê) já tinha nomeado — ela registra
> **dados do repositório: 200** desde 20/08 e diz, com todas as letras, que *"o
> que abriu foi a API REST, não o MCP"*.
>
> E o V1 é o contrário do que a citação sugeria: ele **encolheu** justamente
> porque dados do repositório passaram a responder. Usá-lo como precedente de
> inalcançabilidade inverte o que ele registra.
>
> A regra do arquivo já cobria este caso e não foi aplicada, uma seção adiante:
> *item de configuração cuja leitura responde hoje deve ser verificado por sessão
> de nuvem, com a data e o código HTTP no registro.* Não bastava a regra existir
> — faltou tentar antes de declarar o limite. **Declarar limite é barato e soa
> rigoroso; medir custa uma chamada.**

> Este item se cruza com o **1** e o **4** da Retomada, que ficaram um ciclo
> descrevendo um resíduo já inexistente. O padrão é o de sempre neste arquivo:
> **duas camadas que envelhecem em velocidades diferentes** — o item detalhado
> estava certo, o resumo no topo não. Foi exatamente o que o L2 e o V1 já tinham
> mostrado em 25/08, e é o terceiro caso da mesma forma em um dia.

> H1, H2 e H4 são entrega prevista da **Fase 1**, e o que esta rodada mostrou é
> que o problema deles mudou de "não existem" para "não se sabe daqui". H5 é a
> versão da inversão original em que o custo de errar não é técnico — e é o único
> dos quatro que não melhorou em doze dias.

---

## 3. Ainda em aberto ☁️ / 🏠

### A1 — O orquestrador está no prédio errado (decidido: muda)

**DECIDIDO em 2026-08-21 — vai para o privado.**

O item registrava que o orquestrador pode estar do lado errado de **R1**: a
doutrina operacional, o backlog e o blueprint descrevem o ecossistema inteiro e
vivem no único repositório **público**.

**Decidido: vai para um repositório privado.** E o destino não é um repositório
novo — é o **departamento `D1`** (`P01` no índice), que o
blueprint já define como "princípios, padrões, o sistema operacional" e como
departamento-piloto. A pergunta do dono — *"já não deveria ser esse cara?"* —
está certa, e vale registrar por quê: o blueprint **já** atribuía essa missão a
ele. O orquestrador morar no público nunca foi um desenho; foi o resto do
ecossistema crescendo em volta do primeiro repositório que existiu.

**O que muda de lado:** `AGENTS.md` (doutrina operacional), `docs/pendencias.md`
(backlog), `docs/orchestration-blueprint.md` (autoridade de projeto),
`docs/handoff/`, `docs/control-plane.md`, e o mapeamento apelido → repositório,
que hoje não tem casa versionada.

**O que fica, e é o ponto:** `README.md` — o perfil público —, `LICENSE`,
`SECURITY.md` na parte que é política de publicação, o plugin-fundação (que é
prática emitida de propósito) e os workflows deste repositório. O que sobra aqui
passa a ser **fachada pública**, que é o que o blueprint sempre disse que este
departamento é.

**O ganho concreto, além da doutrina:** hoje cada linha deste backlog é escrita
sob restrição de sanitização, e várias já foram podadas por isso — o detalhe dos
achados de dado pessoal, os nomes dos repositórios, a lista de setores. No
privado, o backlog volta a poder ser específico, que é o que um backlog precisa
ser para servir.

**Por que não migrei nesta sessão.** A migração escreve num repositório privado, e
**R1 proíbe esta sessão — a pública — de tocar nele**. É trabalho de uma sessão
escopada em `P01`, ou seu, à mão. Migrar daqui seria cometer a violação que o
item existe para apontar.

**Verificação:** `AGENTS.md` deste repositório encolhe para doutrina de fachada
pública; a doutrina de ecossistema tem uma única cópia, no privado; e nenhum
documento aqui afirma ser autoridade sobre o que não é público.

#### "E se eu simplesmente tornar este repositório privado?" — não

Perguntado pelo dono em 2026-08-21, e a resposta merece ficar escrita porque a
pergunta é boa e a resposta é contraintuitiva. Tornar `tihh07/tihh07` privado
resolveria **um** problema que a migração já resolve, e criaria **três** que ela
não cria:

1. **O perfil do GitHub para de existir.** O README de perfil só renderiza a
   partir de um repositório **público** com o nome exato do usuário. Privado, a
   página do perfil fica vazia — e essa é a função primária declarada deste
   repositório, a primeira linha do `AGENTS.md`.
2. **Actions passa a ser cobrado.** Hoje a CI daqui é gratuita porque o
   repositório é público. Privado, cada execução entra na cota — exatamente o
   problema do item **C1**, agravado em vez de resolvido.
3. **A proteção da `main` pode se perder.** Hoje há ruleset ativo, sem ator de
   bypass. Em 2026-08-21 descobriu-se, noutro repositório do ecossistema, que
   **proteção de branch em repositório privado esbarra em limite de plano** — foi
   a causa real de um item que estava registrado como falta de ferramenta.
   Provavelmente o mesmo limite se aplicaria aqui: trocaria-se uma trava que
   funciona por uma que o plano não permite.

**O que a pergunta acerta:** o incômodo é real. Todo este arquivo é escrito sob
restrição de sanitização, e isso já custou os nomes dos repositórios (viraram
apelidos), os números dos achados de dado pessoal, e a lista canônica de setores.
Um backlog que não pode ser específico é menos útil do que deveria.

**Mas a cura não é mudar a visibilidade — é mudar o endereço.** Mover a doutrina
para o privado de Fundação entrega o mesmo ganho, sem perder o perfil, sem passar
a pagar CI e sem arriscar o ruleset. **Visibilidade e localização são eixos
diferentes**, e confundir os dois troca um problema de conteúdo por três de
infraestrutura.

#### O plano de migração — confirmado em 2026-08-21

O dono confirmou: **o repositório continua público**, e a migração é que resolve
o incômodo. Segue o plano executável, para a decisão não virar intenção.

**O que sai daqui**, para o privado de Fundação (`P01`):

| O quê | Por que lá |
|---|---|
| A doutrina de **ecossistema** do `AGENTS.md` — índice de projetos, ciclo de auditoria, R1 | Descreve dezoito repositórios, dos quais dezessete são privados |
| `docs/pendencias.md` | Backlog que hoje é podado por sanitização a cada linha |
| `docs/orchestration-blueprint.md` | Autoridade de projeto sobre o ecossistema inteiro |
| `docs/handoff/` | O padrão descreve o que atravessa a fronteira; o lugar dele é do lado privado |
| `docs/control-plane.md` | Desenho de rotinas que operam privados |
| **O mapeamento `P01`–`P17` → nome real** | Hoje **não tem casa versionada nenhuma**, e é o item que mais precisa de uma |

**O que fica, e não é sobra:** `README.md` (o perfil, que só renderiza em
público), `LICENSE`, o `SECURITY.md` na parte que é **política de publicação
deste repositório** (checklist N2, regra de apelidos, sanitização),
`plugins/fundacao/` — prática emitida de propósito —, os workflows, e o
`.claude/settings.json` com o hook.

**A armadilha que quase ninguém vê antes de cair nela.** Depois da migração,
**uma sessão escopada neste repositório não poderá ler a doutrina que foi para o
privado** — é o mesmo R1, agora apontando para o outro lado. Então o que fica
aqui **não pode ser só fachada**: tem de ser a doutrina **completa para operar
este repositório** — branch, verificação, sanitização, gate de `main` — menos a
visão de ecossistema. Se a poda for feita por "isto é público, isto é privado" em
vez de "isto opera este repo, isto descreve o conjunto", a próxima sessão daqui
fica sem regra e vai improvisar.

**A ordem, e ela é o oposto da intuitiva:**

1. **Criar o conteúdo no privado primeiro**, completo, sem apagar nada aqui.
2. **Verificar lendo** que o privado está íntegro e navegável — links, referências
   cruzadas, o mapeamento.
3. **Só então podar aqui**, trocando o que saiu por ponteiro que **não repete
   conteúdo** — ponteiro que resume é a origem da divergência que este
   repositório existe para evitar.

Apagar antes de conferir arrisca perder o canônico; e há um detalhe que a ordem
não resolve: **retirar daqui não retira do histórico do git.** A migração
interrompe a publicação daqui pra frente, não desfaz a que já houve. Vale para a
doutrina como valeu para o nome de cliente.

**Quem executa:** sessão escopada no `P01`. **Não esta.** Escrever num privado a
partir da sessão pública é a violação de R1 que este item existe para apontar —
e fazê-la em nome de corrigir R1 seria a ironia mais cara do ciclo.

**Verificação:** o `AGENTS.md` daqui descreve apenas este repositório e é
suficiente para operá-lo sozinho; a doutrina de ecossistema tem **uma única**
cópia, no privado; o mapeamento de apelidos está versionado lá; e nenhum
documento público afirma autoridade sobre o que não é público.

**A análise que levou a essa decisão, mantida como registro:**

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

### H1-bis — O gate humano de `main` deixou de ser só doutrina
**Severidade: alta · ✅ FECHADO em 2026-08-21 · Aplicado por: 👤 Humano, na UI · Verificado por: ☁️ Nuvem, via API**

**Fechado no fim do dia em que foi aberto.** O check `verificar` passou a ser
exigido pelo ruleset `protect-main`, e a leitura da API confirma:

| Campo | Valor lido |
|---|---|
| Check exigido | **`verificar`** |
| `integration_id` | **15368** — fixado no app do GitHub Actions |
| `strict_required_status_checks_policy` | **`false`**, como recomendado |
| Aprovações exigidas | 0 — intacto, e é o certo |
| Atores com bypass | **nenhum** |

**O `integration_id` fixado é a metade que quase se perde.** Sem ele, qualquer
app que publicasse um check chamado `verificar` satisfaria a regra — e "qualquer
app" inclui um instalado depois, por outro motivo, sem ninguém ligar uma coisa à
outra. Com ele, só o GitHub Actions deste repositório serve.

**O que isso muda, exatamente.** Um PR com o repositório quebrado **não entra
mais** — a plataforma recusa, não a boa vontade do agente. O que **não** mudou:
uma identidade com acesso de escrita ainda pode abrir um PR e mesclá-lo sozinha.
Isso não tem solução por aprovação enquanto houver um único colaborador, e o
resto continua sendo doutrina — declarada como tal.

**Duas tentativas até pegar, e a primeira "feito" não era.** O relato de conclusão
veio antes de a mudança existir: a API mostrava o ruleset inalterado, com um único
ruleset no repositório e nenhuma regra de check. **A verificação custou uma
requisição e desfez um fechamento falso** — o mesmo padrão que já tinha custado
três diagnósticos errados no **L1**, hoje de manhã, noutro repositório.

> Vale reter a regra que sai daí, porque ela é barata: **relato de configuração
> aplicada é hipótese até a leitura confirmar.** Não é desconfiança de quem
> relata — é que telas longas de formulário salvam parcialmente, e ninguém
> percebe olhando a própria tela.

---

**Registro do estado anterior, para a próxima sessão entender de onde veio:**

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

> **Revogado em 2026-08-24, e o parágrafo acima fica como registro do que se
> sabia.** O dono autorizou sessão de agente a executar operação de GitHub,
> **merge incluído**, com teste, evidência e validação no PR. A frase *"nada é
> mesclado em `main` por agente"* **não vale mais** — quem a ler aqui sem esta
> nota concluiria o contrário, que é o defeito que o **C1** cometeu num
> cabeçalho e custou uma correção nesta mesma data. A regra viva está no
> [`AGENTS.md`](../AGENTS.md); o que este item descobriu continua de pé e ficou
> mais importante, não menos: **a plataforma não exige revisor**, então a prova
> passou a ser a única coisa entre um PR e a `main`.

Isso também explica **H2** sem mistério: o `CODEOWNERS` é inerte porque a regra
não pede revisão de code owner. Não é só a opção "Require review from Code
Owners" que falta — é a contagem de aprovações em zero.

**A pré-condição foi verificada em 2026-08-21, e é dura:** o repositório tem
**um único colaborador**, com papel de admin. O ruleset não tem ator de bypass.
Exigir aprovação, nessas condições, não é rigor — é se trancar fora do próprio
repositório, porque o GitHub não deixa ninguém aprovar o próprio PR. O mesmo
raciocínio que barrou exigir PR na branch principal do dossiê pessoal vale aqui.

**Ação (👤):** três posturas, e a terceira só passou a existir em 2026-08-21:

1. **Exigir aprovação.** Fecha o buraco e trava tudo, pelo motivo acima.
   Descartada enquanto houver um só colaborador.
2. **Assumir a doutrina como o controle**, declarando-a como tal em vez de
   chamá-la de gate. Honesto e não bloqueia — mas exige que todo prompt de
   agente continue carregando a regra, para sempre, e falha em silêncio no dia
   em que um não carregar.
3. **Exigir um check obrigatório.** ⭐ Recomendada. `.github/workflows/verificacao.yml`
   passou a existir e roda a cada PR para `main`. Marcar *"Require status checks
   to pass"* apontando para ele converte parte do gate em trava de plataforma —
   **sem depender de um segundo revisor que não existe**. Não impede um agente
   de mesclar o próprio PR; impede que qualquer PR entre com o repositório
   quebrado, que é o dano concreto que a doutrina sozinha não previne.

**Tentado por API em 2026-08-21, e barrado — o que é informação, não obstáculo.**
A leitura do ruleset passou (200); a **escrita** devolveu 403 com
*"Write access to this GitHub API path is not permitted through this proxy"*. O
corte é limpo e vale registrar como desenho, não como falha: **a nuvem lê
configuração e não a aplica.** Não há rota alternativa a procurar, e procurar uma
seria o comportamento que o guardrail existe para impedir.

**O caminho que foi seguido**, registrado porque ele se repete nos dezessete
privados (**H7**): a tela de *New branch ruleset* é a **errada** — já existia um
`protect-main` ativo sobre a branch default, e criar um segundo empilharia duas
regras sobre o mesmo alvo, com a próxima sessão que lesse *"o ruleset"* lendo o
errado. Editar o que existe:

*Settings → Rules → Rulesets → `protect-main` → Require status checks to pass →
Add checks → `verificar` → Save.*

**"Require branches to be up to date before merging" ficou desmarcado**, de
propósito: marcá-la obriga cada PR a incorporar `main` antes de mesclar, e cada
incorporação redispara a CI. Com um único colaborador é atrito sem ganho, e cada
re-execução custa minuto — o **C1**.

**A ordem importava, e era contraintuitiva:** o workflow tinha de existir e ter
rodado **antes** de ser exigido. Exigir um check que nunca rodou bloqueia todo
merge, inclusive o PR que traria o check. Por isso o workflow veio primeiro e a
marcação depois — e `verificar` já estava verde no head do PR #13 quando foi
exigido.

**As opções 2 e 3 se somam, e a 2 continua valendo:** mesmo com o check
obrigatório, *"nenhum agente mescla em `main`"* segue sendo **doutrina**, e o
texto do ecossistema deve chamá-la assim em vez de "gate".

**Verificação — cumprida:** a leitura da API mostra `required_status_checks` com
`verificar` fixado no app do Actions, `strict` em `false`, aprovações em zero e
nenhum ator de bypass.

> Vale registrar como o achado apareceu, porque é o argumento a favor de
> reconectar autorização em vez de conviver com o 403: **este item ficou seis
> meses descrito como fechado sem nunca ter sido lido.** Não por descuido — a via
> de leitura não existia, e "ruleset ativo" era o máximo que dava para afirmar. O
> custo de um controle não verificável não é o risco de ele estar desligado; é
> que ninguém descobre que ele protege menos do que se pensa.

---

### V1 — A configuração do repositório não é reverificável pela nuvem
**Severidade: média — era alta · 🟡 ENCOLHEU EM 21/08, E DE NOVO EM 24/08 · Executor: ☁️ Nuvem (implementa) + 👤 Humano (confere)**

**Evidência original (2026-08-20), parcialmente superada:** `gh` não existe no
ambiente de nuvem; o proxy de saída devolve **403** para os caminhos de
configuração de repositório da API do GitHub, com token que responde `200` em
endpoint de identidade; nenhuma ferramenta MCP expõe ruleset ou proteção de
branch.

**O que mudou depois, e por que o item encolheu duas vezes:**

| Data | O que passou a responder | Efeito em V1 |
|---|---|---|
| 21/08 | dados do repositório e **`/rulesets` (leitura)** devolvem **200** | o workflow substituto **não precisa mais cobrir ruleset** — que era o caso de uso mais caro |
| 24/08 | `POST /rulesets` executado **com sucesso** em 15 privados, por outra sessão | o 403 de escrita é **allowlist do proxy desta frente**, não limite da conta — o que restringe o escopo do item ao *ambiente*, não à API |

**Fica de fora, e é o que sobrou do item:** secret scanning, segredos de Actions,
colaboradores e `/branches/*/protection` — este último por **escopo do app**,
não pelo proxy, distinção que importa porque escopo não se resolve com workflow.
Detalhe endpoint a endpoint na
[seção dedicada](#o-que-a-nuvem-não-alcança--e-por-quê).

> **Esta seção passou de 20/08 a 25/08 declarando ABERTO um item que encolhera
> duas vezes**, enquanto a linha-resumo já dizia 🟡 *"encolheu"* e a seção de
> alcance já trazia a medição endpoint a endpoint. É o mesmo defeito do **L2**,
> espelhado: lá o resumo atrasou em relação ao detalhe, aqui o detalhe atrasou em
> relação ao resumo. **Nenhuma das duas camadas é a confiável por natureza** — a
> confiável é a que cita medição com data, e era exatamente essa que faltava aqui.

**Por que nasceu severidade alta:** não era um item de conforto. Ele era a razão
pela qual H1, H3 e H4 — três controles de segurança de um repositório público —
estavam em "não se sabe". Um controle que ninguém consegue observar tende ao
mesmo resultado prático de um controle que não existe, com a diferença de que o
primeiro produz falsa tranquilidade.

**Os três saíram do "não se sabe" sem que V1 fosse construído**, e é por isso que
a severidade cai: **H1** fechou em 21/08 com o ruleset lido inteiro pela própria
API que voltou a responder, **H4** fechou conferido na UI em 21/08 com evidência
visual, e **H3** fechou por remoção. O que justificava "alta" era o conjunto de
controles reféns do item; ele se esvaziou. Sobra um item real, mas menor: sem o
workflow, o que **não** responde continua só conferível na UI, um a um, à mão.

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

**Ação (👤), enquanto V1 não existe:** ~~conferir H1 e H4 na UI e datar a
conferência aqui~~ — **feito em 21/08, os dois, com data e evidência.** Não
restou ação humana pendente neste item.

**Verificação:** uma sessão de nuvem consegue afirmar o estado do secret
scanning, dos segredos de Actions e dos colaboradores citando a saída de um job,
sem depender de memória nem deste arquivo. *(A proteção de `main` saiu da
verificação: ela passou a ser lida direto pela API em 21/08, e exigir que o
workflow a cubra seria manter o critério maior que o item.)*

> A sessão de 20/08 **não** implementou o workflow: `.github/` estava sendo
> editado por outra sessão em paralelo e escrever lá produziria conflito. O
> impedimento era daquele dia e **não vale mais** — fica registrado como história,
> não como bloqueio corrente. Um motivo datado que ninguém redata vira motivo
> permanente por inércia, que é o defeito que a seção de alcance já descreveu:
> *"bloqueio tem data de validade"*.

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

1. **Três fichas relataram relatório de auditoria ausente — e estavam erradas.
   Verificado em 2026-08-21.** Uma sessão por repositório, somente leitura, com
   contrato de resposta que separava `AUSENTE` de `INCONCLUSIVO`. Resultado:
   **3 de 3 encontrados**, todos em `docs/auditoria/2026-08-20-integral.md`, na
   branch de auditoria, com o PR draft aberto e não mesclado — exatamente onde a
   hipótese dizia que estariam.

   O achado inverte de sentido. Não é auditoria que não entregou: é **ficha
   lendo a ref errada**. As três auditorias tinham gravado o relatório; a sessão
   de ficha consultou só a branch default, não achou, e escreveu ausência como
   se fosse fato. Corrigido na causa, em `docs/handoff/README.md`: ausência só
   conta como informação depois que a branch de auditoria também foi consultada,
   e o comando está lá.

   **O que sobra como trabalho:** as três fichas carregam a afirmação falsa nos
   respectivos PRs draft. Precisam ser corrigidas na origem antes de qualquer
   uma virar linha do índice — uma ficha que erra sobre a própria auditoria não
   é fonte confiável para as duas células que o orquestrador consome.

   > Custo de descobrir: três sessões pontuais, poucos minutos. Custo de não
   > descobrir: três repositórios marcados como não auditados no índice, e uma
   > rodada inteira de auditoria dada como perdida. **A verificação mais barata
   > deste ciclo desfez o achado mais alarmante dele** — e o que a tornou barata
   > foi exigir que a sessão distinguisse "não achei" de "não existe".

2. **O slug de setor não é único por repositório.** Dois repositórios gravaram
   ficha sob o mesmo `setor:`. Isso não causa colisão de arquivo — cada ficha
   vive na sua origem — mas quebra a premissa de que uma linha do índice mapeia
   um setor. O índice precisa de chave composta (setor + repositório) ou o
   frontmatter precisa de um campo que distinga os dois. Decisão de desenho,
   não de urgência.

**Verificação adicional:** os três repositórios acima só aparecem com data no
índice depois que a ficha de cada um for corrigida na origem — o relatório já
está localizado.

**E o item muda de gargalo.** Passou semanas descrito como bloqueado por R1;
depois virou "aguardando retorno". As duas rodadas mostram que nenhum dos dois
era o gargalo real: **é o merge**. As 34 sessões deixaram cerca de 32 PRs em
draft, e só dois repositórios tiveram algo entrando na branch default. Trabalho
completo que não entra na default é indistinguível de trabalho não feito para
qualquer sessão futura que leia aquele repositório — foi exatamente assim que
três fichas concluíram que a auditoria não existia. O gate humano estava certo
como política; a fila que ele acumulava é que virou o risco — e foi essa fila que
a diretriz de **2026-08-24** atacou, ao deixar o agente mesclar com prova em vez
de estacionar o trabalho num PR à espera de uma pessoa.

> **E o item se provou de novo em 2026-08-21, do lado de dentro.** A ferramenta de
> medição do **C1** foi escrita, testada contra a API e commitada — num PR draft.
> Horas depois o dono abriu um Codespace para rodá-la e recebeu *"não existe no
> diretório"*, porque o Codespace abre na branch default e a ferramenta não estava
> lá. Não foi um contratempo de instalação: foi **este item acontecendo com a
> ferramenta que este backlog pediu**, e desta vez quem tropeçou não foi uma
> sessão de auditoria — foi a pessoa. O que a lição ganha com isso é alcance:
> vale para relatório, ficha, script e qualquer coisa que alguém vá procurar
> depois.

> Terceira vez que este item é redescrito, e o padrão já se repetiu vezes
> demais para ser coincidência: **a barreira declarada quase nunca é a barreira
> real.** Primeiro era R1, e não era. Depois era o transporte, e não era. Vale
> desconfiar de qualquer item deste arquivo cuja descrição de bloqueio nunca foi
> testada.

**Rodada de fechamento — 2026-08-21.** Com o merge autorizado nos privados (o
público segue no gate), foram despachadas sessões de fechamento, uma por
repositório, com a mesma trava em todas: CI vermelha não mescla, conflito se
resolve trazendo a base para dentro — nunca rebase, nunca force push — e **o
merge só conta depois de reler a branch default e confirmar que relatório e
ficha chegaram lá**. Esse último passo existe porque relatar merge sem reler é
exatamente o erro que produziu o falso alarme da manhã.

**Treze repositórios chegaram a estado fechado** — a branch default de cada um
contém o relatório da auditoria. O décimo terceiro fechou depois que o humano
aprovou, na UI, o merge que o classificador de permissão havia barrado: o
bloqueio nunca foi técnico, era o gate funcionando. Nem todos pelo mesmo caminho:
alguns tiveram os PRs mesclados pela própria sessão, outros já tinham sido
mesclados pelo dono antes dela chegar. A distinção importa para não creditar à
automação um trabalho que foi humano.

**Quatro seguem em aberto, e cada um por um motivo diferente** — o que é mais útil do
que um número agregado:

| Causa da retenção | O que ela realmente diz |
|---|---|
| ~~Autorização julgada não humana~~ | **Destravado pelo humano; 3 PRs entraram na branch default e 1 segue aberto.** A recusa continua sendo o achado — ver o comentário abaixo. Nota de método: quem confirmou o merge foi a própria sessão, e **R1 impede esta sessão de reverificar num repositório privado**. O relato vale como relato. |
| ~~Guardrail do próprio repositório~~ | Três tentativas, três diagnósticos — e um quarto capítulo. **A sessão voltou sozinha às 18:12Z relatando merge concluído** (201 arquivos varridos, security gate confirmado). Se procede, o que o guardrail barrava era a escrita **cosmética** no PR, não o merge — e o terceiro diagnóstico, que parecia o certo, também não era. **Não reverificado daqui: R1.** Vale como relato até alguém abrir a branch default. |
| ~~Classificador de permissão~~ | **Destravado pelo humano na UI, e o repositório fechou.** Vale reter que o bloqueio saiu barato: o mesmo repositório teve dado pessoal confirmado horas depois, e o PR teria seguido adiante sem essa trava. O classificador comprou o tempo que a varredura usou. |
| CI vermelha por dado ausente | A CI não está quebrada: ela está **certa**, e reprova porque faltam métricas que só uma pessoa coleta. Verde aqui exigiria burlar o gate. |
| Pergunta aberta ao humano | A sessão parou para perguntar, e a pergunta é de conteúdo, não técnica. |
| ~~Conflito semântico já mesclado~~ | **Resolvido no mesmo dia.** Os dois lados tinham mesclado sem conflito de texto e o resultado se contradizia — o caso em que `git` diz verde e o conteúdo diz vermelho. Fechou com 5 PRs mesclados e CI verde na default. |

**O caso que precisou de três tentativas para ser diagnosticado.** Um dos
repositórios não fechou, e a causa registrada mudou duas vezes antes de ficar
certa:

1. A primeira sessão declarou **clone raso sem ferramenta** — e estava errada
   nas duas metades: o clone se resolve com um comando, e a ferramenta existia.
   Ela concluiu "não tenho" sem tentar chamar.
2. A segunda, redespachada com o comando no enunciado, avançou e travou noutro
   ponto: uma **escrita no GitHub negada por classificador**. Reportou o
   sintoma — um título de PR que continuou errado — e não o que aquilo
   implicava.
3. A terceira, somente leitura, respondeu a pergunta que importava: os
   relatórios **estão nas branches de auditoria e não na branch default**. O
   repositório não fechou, e o título errado era cosmético o tempo todo.

**O que trava é um guardrail do próprio repositório**, que barra escrita de
agente no GitHub. Ele está funcionando como foi desenhado. Uma quarta sessão não
passaria por ele — passaria a tentar rotas alternativas, que é exatamente o
comportamento que o guardrail existe para impedir. **Este item só fecha por
decisão humana**, e não porque falta ferramenta: porque o repositório decidiu que
merge ali não é ato de agente.

> **Duas causas erradas antes da certa, e nenhuma foi mentira.** Cada sessão
> relatou honestamente onde parou; o problema é que "onde parei" e "o que trava"
> não são a mesma pergunta, e uma sessão que só responde a primeira produz um
> diagnóstico que soa completo e não é. O que fechou o caso foi separar as duas:
> a verificação não perguntou *por que você parou*, perguntou *o arquivo está na
> branch default?*.

> **A recusa é o achado, não o obstáculo.** Uma das sessões recebeu autorização
> de merge por um campo de configuração e se recusou a agir sobre ela, por não
> conseguir estabelecer que a autorização era humana. Ela estava certa: um campo
> de configuração legível por agente não é assinatura de ninguém. É o mesmo
> raciocínio que o gate do repositório público impõe, aplicado por uma sessão
> que não tinha como saber que a pessoa havia confirmado noutro canal.
>
> Vale reter o desenho: **a autorização de merge precisa de um caminho que o
> agente consiga distinguir de configuração**, ou toda sessão bem-comportada vai
> travar nela — e as que não travarem serão justamente as que não deveriam ter
> agido.

**Um risco fechou com a resposta errada esperada.** A branch principal de um dos
repositórios continua sem proteção, e a causa não é a que o backlog registrava.
Não é ferramenta sem endpoint: é **limite do plano** — proteção de branch em
repositório privado exige plano pago. Isso muda o item de "tentar de novo por
outra via" para "decidir se vale pagar, ou aceitar o risco por escrito". Nenhuma
das duas é trabalho de agente.

**Fechamento de 2026-08-21, fim do dia — o placar do ciclo.** O dono mesclou o PR
de relatório do `P01` e autorizou apagar as branches já provadas mescladas. Com
isso o ciclo de auditoria fica em **15 repositórios relatados como fechados e 2
em aberto**.

**"Relatado" é a palavra certa, e não é hedge.** Nenhum desses fechamentos foi
reverificado desta sessão, e nenhum pode ser: **R1** impede o repositório público
de abrir um privado. O que existe é o relato de cada sessão escopada, mais a
confirmação do dono por canal direto — que é a única via legítima de atravessar a
fronteira. Escrever "verificado" seria falso; escrever "em aberto" seria descartar
informação boa. A terceira palavra é a honesta, e o índice do `AGENTS.md` usa a
mesma.

**Os dois que restam não são trabalho de agente:**

| Repo | O que trava | Quem destrava |
|---|---|---|
| `P16` | CI vermelha porque faltam duas métricas que só uma pessoa coleta. A CI está **certa** — verde ali exigiria burlar o gate | 👤 coletar os dois números |
| `P17` | Ficha de handoff com afirmação falsa sobre a própria auditoria, em correção na origem | ☁️ corrige na origem, 👤 mescla |

**E o risco de branch principal desprotegida deixou de ser limite de plano.** Com
o Pro assinado em 2026-08-21, proteger as branches principais dos privados passou
de "decidir se vale pagar" para **configuração pendente** — é o **H7**. Vale
notar o que a mudança faz com este arquivo: um item que passou semanas descrito
como bloqueio de ferramenta era, o tempo todo, uma linha de preço. É o mesmo
padrão que **L1** já tinha registrado três vezes — **a barreira declarada quase
nunca é a barreira real** — aparecendo agora numa categoria nova: barreira que
some com um clique de compra.

### L5 — O `.gitignore` dependia do ignore global da máquina
**Severidade: média · Executor: ☁️ Nuvem · FECHADO em 2026-08-21**

`.claude/settings.local.json` guarda concessões de permissão locais. Ele não
estava versionado — mas quem o barrava era `/root/.config/git/ignore`, o ignore
global do ambiente, **não o `.gitignore` deste repositório**. Provado com
`git -c core.excludesFile=/dev/null check-ignore`: sem aquela config, o arquivo
entraria no primeiro `git add`.

Num repositório N2 isso publica estrutura interna (item 5 do checklist), e o
modo de falha é silencioso: nada quebra, nada avisa, o arquivo simplesmente
aparece num clone feito de outra máquina. **Barreira que depende do ambiente de
quem clona não é barreira do repositório** — é sorte de configuração.

Fechado adicionando os dois padrões ao `.gitignore` e reverificando com o ignore
global desativado. Nenhum outro artefato local versionado foi encontrado.

> Achado durante a rotina de verificação de PR, não numa auditoria. Vale a nota:
> **o `.gitignore` foi dado como controle sem nunca ter sido testado isolado do
> ambiente** — o mesmo padrão que já apareceu no hook de push e nas três fichas.
> Controle não exercitado é afirmação.

### L6 — A suíte do guardrail não era hermética, e por isso mentia
**Severidade: alta · Executor: ☁️ Nuvem · FECHADO em 2026-08-21**

O primeiro PR a passar pelo novo check de verificação **falhou** — e o que
falhou foi a suíte do guardrail: **42/42 na máquina local, 38/4 no runner do
GitHub**, nos quatro casos de redirecionamento adicionados naquela manhã.

**Dois defeitos, e o segundo é o que importa.**

1. `sem_redirecao` troca o redirecionamento por um espaço, o que deixa **tokens
   vazios** no fim do segmento. O `tail -1` que extrai o refspec devolvia string
   vazia em vez de `claude/x`, e o fluxo caía no fallback da branch atual.
2. **A suíte rodava no diretório de onde foi chamada.** Nesse repositório a
   branch atual é sempre `claude/*` — e o fallback, nessa branch, **libera**.
   Então o defeito 1 era resgatado pelo motivo errado e o teste ficava verde. No
   runner, o checkout de `pull_request` deixa o HEAD **destacado**: o fallback
   devolve `HEAD`, que não é `claude/*`, e os quatro casos falharam.

O defeito 1 é um bug. O defeito 2 é a razão de ninguém ter visto o bug 1:
**um teste cujo resultado depende de onde foi invocado não é um teste.** Ele
media o checkout, não o hook.

**Corrigido nos dois níveis.** A extração descarta tokens vazios; e todo caso
passou a rodar dentro de um repositório descartável na branch `main`, onde o
fallback **bloqueia** — de modo que qualquer sumiço de refspec derruba o teste em
vez de ser mascarado. Os dois casos que testam o fallback de propósito continuam
montando o próprio cenário, explicitamente. Sem repositório neutro a suíte
**recusa rodar**: rodar no ambiente reintroduz o falso verde.

**Verificação, feita nas duas direções:**

- com o conserto, 42/42 numa branch `claude/*` **e** com HEAD destacado;
- sem o conserto, **38/4 na branch `claude/*`** — a mesma condição em que a suíte
  antiga dizia 42/42. A regressão agora é reproduzível localmente.

> Três achados hoje têm a mesma forma: o `.gitignore` dependia do ignore global
> da máquina, o hook dependia da branch do checkout, e uma ficha dependia de
> qual ref alguém consultou. Em todos, **o controle existia, era afirmado como
> funcionando, e o que o fazia passar era uma propriedade do ambiente, não o
> controle**. O padrão vale mais que os três: *controle que nunca foi exercitado
> fora do seu ambiente de origem é afirmação, não controle.*
>
> Vale também o registro a favor do CI: ele **pagou o próprio custo na primeira
> execução**. O check foi criado para dar a `main` uma trava de plataforma, e
> antes disso já encontrou um defeito real num guardrail de segurança que duas
> revisões humanas e uma suíte dedicada tinham deixado passar.

#### L6.1 — O guardrail lia o argumento de `-C` como destino
**Severidade: média · Executor: ☁️ Nuvem · FECHADO em 2026-08-25, no mesmo trabalho que o achou**

O hook extraía o refspec descartando os tokens que começam com `-`. O filtro não
tem como olhar para o token **anterior**, e há opções que levam valor separado:
descartado o `-C`, o caminho que vem depois dele vira a última palavra não-flag,
isto é, o "destino".

**Falso positivo, com a saída literal:**

```
$ git -C "$LIB" push
guard-push: destino '"$LIB"' fora de claude/*.
```

A branch alvo era `claude/sintese-bundle-datado-obsoleto` — dentro da política. E
não era um comando exótico: `git -C "$LIB" push` é o que o passo 4a do fechamento
de sessão **prescreve** para empurrar a biblioteca a partir da sessão de outro
projeto. O guardrail negava o caminho que existe para permitir, que é a forma de
falha que este hook já tinha cometido duas vezes (heredoc em 20/08,
redirecionamento em 21/08) e que o cabeçalho dele descreve: *guardrail que nega
demais é indistinguível de guardrail quebrado, e convida à desinstalação.*

Com caminho legível a negação era a mesma — logo não era um problema de aspas:

```
$ git -C /tmp/tmp.XXXX push        # o diretório está em claude/lib
guard-push: destino '/tmp/tmp.XXXX' fora de claude/*.
```

**O defeito de segunda ordem é o de sempre, e é o que importa.** A suíte passava
**42/42** e **nunca tinha exercitado `git -C`**. Verde sobre um caminho que o hook
erra — a mesma família do L6 e do L5: *controle nunca exercitado num caminho é
afirmação sobre ele, não prova dele.* Correção sem caso novo não fecharia nada.

**Corrigido em dois pontos, e nenhum deles é a política:**

1. A extração de refspec virou um laço sobre os tokens, que **consome o argumento**
   das opções que levam valor — `-C`, `-c`, `--git-dir`, `--work-tree`,
   `--namespace`, `--exec-path` do git, e `--repo`, `-o`, `--push-option`,
   `--exec`, `--receive-pack` do `push`. As outras quatro foram procuradas junto
   com o `-C`: erravam pelo mesmo motivo e agora têm caso próprio.
2. Com `-C <dir>` e sem refspec, a branch consultada passou a ser a **do
   diretório**, não a de onde o comando partiu. A escolha anterior errava nas duas
   direções, e a segunda é a perigosa: negava a biblioteca parada em `claude/*` e
   **liberava a vizinha parada em `main`** sempre que a sessão estivesse numa
   `claude/*`.

**Um limite fica declarado, não escondido:** quando o caminho não é legível daqui
— `-C "$LIB"`, com a variável que só o shell do agente expande — o hook decide
pela branch da sessão. Ele **não** expande nada: `eval` sobre string vinda da
ferramenta seria executar comando alheio dentro do guardrail. É a mesma classe de
lacuna que o cabeçalho já assume ao dizer que push por API ou MCP passa ao largo.
Há caso para as duas direções desse limite.

**Verificação, nas duas direções (é o critério que o L6 fixou):**

- com o conserto, **55 passaram, 0 falharam**, exit 0;
- a suíte nova contra o hook **antigo**: **49 passaram, 6 falharam** — e as seis
  são exatamente os casos que o parsing antigo erra;
- os **42 casos anteriores passam nos dois**: nada que era bloqueado passou a ser
  liberado. A correção é de parsing, e o placar prova que a política não se moveu.

Treze casos novos: os cinco de `-C` (diretório em `claude/*`, com refspec
explícito, para `main`, com `--force`, e o simétrico do diretório em `main` visto
de uma sessão `claude/*`), os dois do `-C` não expansível e os seis das outras
opções com valor — quatro que precisam liberar e dois provando que elas não viram
rota de fuga para `main`.

### L2 — O índice publicado tem o eixo errado, não só linhas faltando
**Severidade: alta · 🟡 OS NOMES FECHARAM, O EIXO NÃO — 2026-08-24 · Executor: 👤 Humano (decidiu) + ☁️ Nuvem (aplicou)**

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

**Achado de 2026-08-21: a coluna de departamento já tem o problema que a coluna de
nome acabou de resolver.** O índice hoje publica departamento para **quatro** dos
dezessete privados e escreve *"não declarado"* nos outros treze. Essa é
exatamente a forma que **L7** rejeitou uma coluna à esquerda: **esconder
seletivamente aponta para o que está escondido.** Quatro publicados e treze
omitidos não descrevem quatro departamentos conhecidos — descrevem treze
marcados como não-publicáveis, e a omissão vira o índice.

E o estado é pior do que uma decisão ruim: **é uma decisão não tomada, executada
pela metade.** Este item registra que publicar a taxonomia depende de decisão
humana, e quatro nomes saíram antes dela.

**O achado não muda a ação de L2, muda a urgência.** As saídas continuam três:
publicar os dezoito, apelidar todos como se fez com os repositórios, ou retirar a
coluna. Nenhuma é trabalho de agente. O que ele acrescenta é que **"deixar como
está" não é neutro** — é uma quarta opção, e é a única que carrega o defeito.

**Decidido e aplicado em 2026-08-24: apelidar.** Das três saídas, o dono escolheu
a do meio. Os cinco departamentos que o índice nomeava viraram `D1`–`D5`, com a
mesma regra de estabilidade dos apelidos de repositório, e o mapeamento mora
fora daqui. Os treze que este repositório **não conhece** deixaram de dizer *"não
declarado"* e passaram a dizer **"não verificado"** — a palavra que o `AGENTS.md`
já prescreve, e a distinção não é cosmética: *não declarado* afirma algo sobre o
repositório remoto, que esta sessão não tem como afirmar; *não verificado* afirma
algo sobre **esta** sessão, que é o que se sabe.

**O `grep` de conferência achou o que a correção sozinha não teria fechado.**
Trocar a coluna do índice deixou os cinco nomes reais publicados por extenso no
organograma do [blueprint](orchestration-blueprint.md) — diagrama da seção 3 e
tabela logo abaixo —, no título da seção 5.1, no roadmap da Fase 4 e uma vez mais
neste arquivo. **Apelidar uma tabela enquanto a mesma informação está três telas
adiante é a aparência da sanitização, não a sanitização**, e por pouco o PR saiu
afirmando que o vazamento tinha fechado. É o erro que o **C1** cometeu duas
vezes: afirmar sem abrir o que confirmaria.

**Reconciliado no mesmo dia, e por isso o item fecha de verdade.** O organograma
passou a `D1`–`D5` — inclusive os identificadores do mermaid, que também
entregavam os nomes —, a seção 5.1 usa a sigla que o documento já usava, e a
missão de cada departamento continua publicada, porque **é ela o desenho**, e é
para isso que o blueprint existe. O `grep` pelos cinco nomes não devolve mais
nenhuma linha versionada.

**O eixo, esse, não fecha.** O índice continua sendo repositório × estado, e
reeixá-lo para setor × repositórios depende dos handoffs de **L1**; enquanto eles
não chegam, as treze células ficam vazias por ignorância declarada, e **R1**
impede abrir o privado para preenchê-las daqui.

**Verificação:** o número de repositórios declarados no índice bate com o número
que existe; a coluna de departamento não publica nome real nenhum — apelido onde
se sabe, *"não verificado"* onde não se sabe — **e um `grep` pelos cinco nomes
reais não os encontra em arquivo versionado nenhum.** As três passam em
2026-08-24. O que segue aberto é o **eixo**, não os nomes.

> **A linha-resumo ficou um dia atrás desta seção, e isso é um defeito do
> arquivo, não um detalhe de formatação.** Enquanto aqui já se lia *"os nomes
> fecharam"*, a tabela do topo seguia dizendo 🔴 *"aberto, e agravado — publica 4
> de 17 e omite 13"*, descrevendo um estado que a correção de 24/08 tinha
> desfeito. Quem lesse só o resumo — que é como um backlog longo costuma ser lido
> — recomendaria de novo um trabalho já feito. Corrigido em 25/08, contra o
> `AGENTS.md`: `D1`–`D5` presentes, treze *"não verificado"*, e a única ocorrência
> restante de *"não declarado"* é a nota que narra o estado anterior.
>
> Vale para os dois lados: **este arquivo tem duas camadas que envelhecem em
> ritmos diferentes**, e a de cima é a que mais gente lê. Fechar um item sem
> tocar na linha-resumo deixa o backlog afirmando o contrário de si mesmo.

### L3 — Executores e hook seguem não exercitados
**Severidade: média · Executor: ☁️ Nuvem + 👤 Humano · ABERTO**

**Parcialmente fechado pela realidade, e reconfirmado hoje:** o watchdog acumula
**17 execuções, todas com sucesso**, uma por dia desde 2026-08-04, a última em
**2026-08-20** — **nenhum dia perdido em dezessete**. "Confirmar que o job
executa" deixou de ser pendência há duas semanas, e o controle mais barato do
repositório é o único com histórico impecável.

**A frase "o hook não foi instalado em nenhum departamento" era falsa quando foi
escrita, e seguiu no arquivo.** Ele está instalado **aqui**, que o índice lista
como `D5`, via `PreToolUse` em `.claude/settings.json`:

```json
"hooks": { "PreToolUse": [ { "matcher": "Bash", "hooks": [
  { "type": "command",
    "command": "$CLAUDE_PROJECT_DIR/plugins/fundacao/hooks/guard-push.sh" } ] } ] }
```

**E ele exerceu as duas metades do critério, em trabalho real — 2026-08-25:**

| Metade | Evidência literal |
|---|---|
| **liberou** | `* [new branch] claude/reconciliar-l2-v1 -> claude/reconciliar-l2-v1` · `EXIT_PUSH=0` — push real do PR #35 |
| **bloqueou** | `guard-push: force push bloqueado. / Sessões de agente só empurram para branches claude/*.` — hook `PreToolUse` interrompeu a chamada antes do `git` rodar |

O bloqueio foi provocado com `git push --force --dry-run`, escolhido por ser
inócuo se o hook falhasse: dry-run não altera remoto. **Não é a suíte.** A suíte
roda num repositório descartável, propositalmente isolado; isto é o hook
*instalado*, no repositório real, na configuração real. A distinção é a razão de
ser deste item — *artefato escrito não é controle aplicado* —, e ela vale
igualmente para o teste: **suíte verde é artefato, hook que barrou é controle.**

**O critério estava sub-especificado, e por isso "cumprido" diz menos do que
parece.** *"Instalado em pelo menos um departamento"* não distinguia o
departamento **onde o plugin foi escrito** dos departamentos **para onde ele
deveria ser distribuído**. Cumpri-lo aqui é dogfooding — vale, mas é a evidência
mais fraca possível, porque este é o único terreno onde o plugin nunca precisou
viajar. Critério que a própria origem satisfaz não mede distribuição.

**Critério revisado, em duas linhas que não se confundem:**

1. ✅ **O hook funciona instalado** — provado em `D5` com bloqueio e liberação
   reais, datados e com saída literal acima.
2. ❌ **O plugin foi distribuído** — instalado num departamento que **não** é o
   de origem, e lá bloqueou ou liberou um push real.

**O resto continua aberto:** os oito executores foram escritos a partir da
especificação e **nenhum rodou em trabalho real**; o plugin está em 0.1.0 e o
[README dele](../plugins/fundacao/README.md) declara isso.

É a mesma armadilha que o `oficial-governanca` existe para detectar.

**Ação:** instalar o plugin num piloto que não seja este repositório, e corrigir
o que a realidade contradisser.
**Destrava com L1:** os relatórios das 17 auditorias dizem, pela primeira vez, em
que terreno o plugin seria instalado. Instalar antes de ler o handoff é escrever
controle sobre terreno não verificado.

**Verificação:** a linha 2 do critério revisado acima.

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

### L4 — Cobertura recorrente (decidido: desenho C)

**DECIDIDO em 2026-08-21 — desenho C.**

Das três formas propostas, o dono escolheu **C — uma rotina por setor**, ~6
rotinas, cada uma escopada num setor. A recomendação era essa: A é uma sessão
única sobre todos os privados, que contraria o espírito de **R1**; B são 18
rotinas para manter.

**O que já dá para preparar da nuvem:** o conteúdo de cada rotina vive em
`.claude/skills/<nome>/SKILL.md` e o prompt da rotina é um ponteiro para ele —
padrão já fixado por **P2**. Isso é versionável e revisável aqui.

**O que NÃO pode ser criado desta sessão, e a razão não é permissão.** Criar a
rotina exige anexar os repositórios privados do setor como fontes. Uma rotina
criada a partir desta sessão herdaria o ambiente **deste repositório, que é o
público** — e produziria exatamente o defeito que o item **P0** corrigiu: uma
rotina misturando privados com o público. A criação é na UI, com as fontes certas,
uma rotina por vez.

**Verificação:** cada rotina existe, tem escopo de um único setor, nenhum
conector anexado (**R4**), e o prompt é um ponteiro para a skill versionada.

**A análise que levou a essa escolha, mantida como registro:**

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

Hoje é **sexta-feira, 2026-08-21**. O plano foi escrito na quinta, e a sexta
desmontou boa parte dele — não por estar errado, mas porque um dia rendeu mais
que a linha reservada para ele.

| Quando | O quê | Executor | Estado |
|---|---|---|---|
| ~~Qui~~ | ~~Recolher os handoffs das auditorias que já retornaram~~ | 👤 | **feito** — 17 fichas escritas, cada uma na origem |
| ~~Qui~~ | ~~**H1 + H4** — conferir na UI e datar a conferência~~ | 👤 | **feito em 21/08.** H4 fechou com evidência visual; H1 virou **H1-bis** |
| ~~Sex~~ | ~~**P2** — trocar o prompt das rotinas pelo ponteiro~~ | ☁️ | **metade**; a de control-plane espera a decisão de onde a skill mora |
| ~~Sex~~ | ~~**L2** — decidir se os nomes de setor podem ser publicados~~ | 👤 | **não decidido, e agravado** — ver o achado no item |
| ~~Sex~~ | ~~**H1-bis** — marcar `verificar` como obrigatório~~ | 👤 | **feito e verificado na API em 21/08.** Precisou de duas tentativas: a primeira salvou sem o campo |
| **Hoje (sex)** | **C1** — travar o orçamento de $0 do Actions, ou aceitar por escrito — ✅ **fechado em 24/08: $0 com *stop usage*, já gravado e conferido na tela** | 👤 | 5 min |
| **Sáb/dom** | **H7** — proteger a branch default dos privados, um a um | 👤 | destravado hoje pelo Pro |
| **Sáb/dom** | **P16** — coletar as duas métricas que a CI espera | 👤 | fecha o penúltimo repositório do ciclo |
| **Antes de seg** | **V1** — workflow de leitura de configuração | ☁️ | 1 sessão |
| **Seg** | Conferir as execuções semanais — em especial se a de control-plane continua sem o público no escopo | ☁️ ou 👤 | 5 min |
| **Seg** | **A1** — migrar o orquestrador, em sessão escopada no privado | ☁️ | 1 sessão |

**O que sobrou da semana é quase todo fila de cliques.** Das linhas em aberto,
quatro são 👤 e nenhuma leva mais que alguns minutos. Isso não diz que sobrou
pouco: diz que o trabalho de agente alcançou o próprio teto neste ciclo. O que
resta exige **titularidade** — assinar, aceitar risco, configurar conta — e não
capacidade. É a distinção que o `SECURITY.md` chama de classe 3, aparecendo aqui
como cronograma.

### Fora da semana, sem data

- ~~**H3**~~ — saiu em 2026-08-21: o PR Watch foi **removido**, então não há mais
  o que destravar. Vale reter que ele nunca chegou a entrar num dia, e que a
  saída foi por remoção, não por conserto.
- **H2** — quando existir um segundo revisor. Não antes: ver a aritmética no
  item. O Pro resolveu o lado do plano e não mexeu nessa aritmética.
- **H5** — não tem data porque não tem dono declarado, e é o item de severidade
  alta mais antigo em aberto. Dezessete repositórios foram lidos por agente nesta
  semana; se as pré-condições não estiverem cumpridas, o custo disso não é
  técnico.
- **L3** — depende de os handoffs de **L1** chegarem.
- **L4** — depende de **L2**, porque a topologia de rotinas segue a taxonomia. E
  o achado de 21/08 em L2 encareceu essa dependência: a taxonomia não está só
  indecidida, está publicada pela metade.

### O que saiu da lista

O passo "mesclar o que está em voo" saiu por não ter mais objeto — e voltou a
sair pelo mesmo motivo em 21/08, depois de dois PRs entrarem no mesmo dia. O
bloco P0/P1, que ocupou a linha de topo por três semanas, saiu por ter sido feito
na UI em 2026-08-10. **H3** saiu em 21/08 por remoção do workflow que o exigia.

**Quatro vezes seguidas o topo da lista saiu por ter sido cumprido** — o merge do
PR #7 e o watchdog, depois o bloco de configuração, depois P0/P1, agora o retorno
dos handoffs. É o sinal de que a lista está viva; quando um item sair por ter
sido esquecido, o sintoma será este parágrafo parar de mudar.

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
