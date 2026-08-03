# Auditoria de Fonte de Verdade e Sincronia — Check Reverso (nuvem)

> Prompt para rodar numa **sessão na nuvem escopada em UM projeto**, sem
> dependência de máquina local. Copie a partir da linha abaixo.
>
> O que esta auditoria **não** alcança — arquivos fora do git, clones antigos,
> planilhas soltas, stashes — vive no
> [adendo local](auditoria-adendo-local.md), que é curto e roda em minutos na
> máquina do projeto. Rode este primeiro; o adendo só se a Ficha A indicar
> suspeita de território fora do repositório.

---

## Escopo — leia primeiro e obedeça antes de qualquer outra coisa

Esta auditoria analisa **exclusivamente o repositório indicado nesta sessão**.

Se o ambiente tiver outros repositórios anexados ou clonados, **não** os leia,
**não** os liste, **não** os pesquise e **não** os cite. Não abra arquivo fora do
repositório-alvo por nenhum motivo, nem para "conferir contexto". Se algum
conteúdo referenciar outro repositório, trate como texto — não vá buscar.

Motivo: a separação privado × público é a regra dura do ecossistema
(**R1**). Uma sessão que lê os dois é exatamente o canal pelo qual conteúdo
privado vaza para o lado público. Registre no topo do relatório quais outros
repositórios estavam disponíveis no ambiente e foram deliberadamente ignorados.

## Contexto: por que você está recebendo esta tarefa

Existe um repositório orquestrador central (`tihh07/tihh07`) que funciona como
ponto de convergência do meu ecossistema de trabalho: perfil público, automações
de CI, contexto de agentes e o mapa de todos os projetos em aberto.

O objetivo do orquestrador é responder três perguntas a qualquer momento, sem eu
precisar abrir cada projeto:

1. **O que existe?** — quais projetos, onde vivem, em que estado estão.
2. **Onde está a verdade?** — para cada informação que se repete em mais de um
   lugar (versão, escopo, status, roadmap, config, credencial referenciada),
   qual é o local canônico.
3. **O que está pendente ou dessincronizado?** — lacunas, trabalho não
   publicado, documentação que descreve uma realidade antiga.

Você é a sessão de **um** desses projetos. Sua função nesta rodada não é
implementar nada. É produzir um relatório fiel do estado deste projeto, no
formato abaixo, para que ele possa ser consolidado no orquestrador. Escreva o
relatório assumindo que quem vai ler **não conhece este projeto** — não use
atalhos nem referências implícitas.

## Regras

- **Não altere arquivos.** Nenhum commit, nenhuma correção, nem "aproveitando
  que estou aqui". Se encontrar algo quebrado, registre no relatório.
- **Não invente.** Se não conseguiu verificar, escreva "não verificado" e diga o
  que faltou. Uma lacuna declarada vale mais que uma suposição plausível.
- **Distinga fato de hipótese.** Marque explicitamente o que você observou no
  git/na API versus o que você inferiu.
- **Declare o limite do seu alcance.** Você enxerga o que está versionado e o
  que a API do GitHub expõe. Não enxerga o disco da máquina local. Quando uma
  pergunta exigir isso, escreva "requer adendo local" em vez de deduzir.

## Passo 0 — Identificação e território versionado

Antes da auditoria, estabeleça o terreno com o que é observável:

- Nome do projeto, propósito em uma frase, e a decisão ou entrega real que ele
  serve.
- Remoto do git, branch default, data do último commit em cada branch viva.
- **Território adjacente observável:** submódulos declarados, workflows que
  referenciam outros repositórios, caminhos em código ou config que apontem para
  fora da raiz (mesmo que você não possa segui-los), artefatos versionados que
  sugiram origem externa (exports, dumps, `_old/`, `v2/`).
- Sinais de que existe território **não** observável: referências a diretórios
  locais, instruções de setup que citam pastas fora do repo, `.gitignore` com
  entradas que sugerem dados relevantes ao lado do código. Liste cada sinal —
  é isso que o adendo local vai investigar.

## Passos 1–6 — Auditoria de trás pra frente

Parta do que está publicado e retroceda até a origem. Em cada salto, verifique
se existe fonte única e se as pontas batem.

1. **Ponto final (o que o mundo vê)** — identifique o artefato publicado:
   deploy, release, pacote, site, README público, docs, branch default, entrega
   enviada a alguém. Registre versão/commit/data exatos.
2. **Um salto atrás** — o que gerou aquele artefato (CI, workflow, script de
   build, publicação manual)? O artefato publicado corresponde de fato ao último
   commit da branch default? Aponte qualquer defasagem. Verifique também se
   cada workflow **já executou alguma vez** e se depende de secret inexistente —
   automação que nunca rodou não é controle, é decoração.
3. **Mais um salto** — a branch default corresponde ao trabalho real? Liste
   branches abertas com idade e divergência (ahead/behind), PRs pendentes de
   decisão humana, e PRs fechados sem merge cujo trabalho pode ter se perdido.
   Commits locais não enviados e stashes **requerem adendo local**.
4. **Camada de configuração** — mapeie toda informação que aparece em mais de um
   lugar: versão, nome, descrição, URLs, variáveis de ambiente, dependências,
   credenciais referenciadas, comandos de build/teste. Para cada duplicata: onde
   aparece, quais valores divergem, e qual local **deveria** ser a fonte de
   verdade.
5. **Documentação vs. código** — o README/docs descrevem o que o código
   realmente faz hoje? Aponte instruções quebradas, comandos que não existem
   mais, exemplos desatualizados, e **referências a arquivos que não existem no
   repositório**.
6. **Contexto de agente** — existe `CLAUDE.md`, `AGENTS.md`, `.claude/`, hooks,
   skills ou rotinas agendadas apontando para este repo? Refletem o estado atual
   ou uma realidade antiga? Para cada rotina: qual o escopo de repositórios, quais
   conectores carrega, e o prompt está versionado ou só na UI?

## Entregáveis

Produza, nesta ordem:

**A. Ficha do projeto** — nome, propósito, remoto, estado do git, artefato
publicado mais recente, data da última atividade real, e a lista de sinais de
território não observável (do Passo 0).

**B. Tabela de divergências**

| item | onde diverge | valor A vs valor B | fonte de verdade recomendada | severidade |
|---|---|---|---|---|

**C. Oportunidades de fonte única** — onde vale centralizar (versão só no
manifesto, config só num arquivo, docs geradas a partir do código) e qual
manutenção manual isso elimina.

**D. Pendências e lacunas** — o que está inacabado, o que está bloqueado, o que
depende de decisão minha, e o que este projeto **espera receber** de outro
projeto ou do orquestrador. Marque cada item com o executor: ☁️ nuvem,
👤 humano, 🏠 local.

**E. Plano de sincronia** — ações ordenadas do mais crítico ao cosmético, com
esforço estimado.

**F. Riscos de dessincronização futura** — onde a divergência volta se nada for
automatizado, e qual automação (hook, check de CI, script) previne cada caso.

**G. O que o orquestrador precisa saber** — resumo de até 10 linhas, pronto para
ser colado no repositório central, com o essencial: estado, pendência principal,
e a fonte de verdade deste projeto.

**H. Adendo local necessário?** — sim/não, e se sim, quais perguntas específicas
o adendo precisa responder. Se não houve nenhum sinal no Passo 0, diga
explicitamente que a auditoria está completa sem ele.
