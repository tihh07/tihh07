# Auditoria de Fonte de Verdade e Sincronia — Check Reverso

> Prompt para rodar em cada sessão local dos projetos em aberto (GTM, Focus, etc.).
> Copie a partir da linha abaixo.

---

## Contexto: por que você está recebendo esta tarefa

Existe um repositório orquestrador central (`tihh07/tihh07`) que funciona como
ponto de convergência do meu ecossistema de trabalho: perfil público, automações
de CI, contexto de agentes e, daqui pra frente, o mapa de todos os projetos em
aberto.

O objetivo do orquestrador é responder três perguntas a qualquer momento, sem eu
precisar abrir cada projeto:

1. **O que existe?** — quais projetos, onde vivem, em que estado estão.
2. **Onde está a verdade?** — para cada informação que se repete em mais de um
   lugar (versão, escopo, status, roadmap, config, credencial referenciada),
   qual é o local canônico.
3. **O que está pendente ou dessincronizado?** — lacunas, trabalho não
   publicado, documentação que descreve uma realidade antiga.

Você é a sessão local de **um** desses projetos. Sua função nesta rodada não é
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
  disco/no git versus o que você inferiu.

## Passo 0 — Identificação e território

Antes da auditoria, estabeleça o terreno:

- Nome do projeto, propósito em uma frase, e a decisão ou entrega real que ele
  serve.
- Caminho absoluto do diretório raiz.
- **Existem outros diretórios relacionados a este projeto?** Procure por: pastas
  irmãs com nome parecido, submódulos, worktrees git, clones antigos, pastas de
  backup/`_old`/`v2`, dados fora do repo (planilhas, exports, downloads),
  ambientes virtuais, e qualquer caminho referenciado em código ou config que
  aponte para fora da raiz. Liste cada um com caminho e o que contém.
- Este projeto é versionado em git? Tem remoto? Qual?

## Passos 1–6 — Auditoria de trás pra frente

Parta do que está publicado e retroceda até a origem. Em cada salto, verifique
se existe fonte única e se as pontas batem.

1. **Ponto final (o que o mundo vê)** — identifique o artefato publicado:
   deploy, release, pacote, site, README público, docs, branch default, entrega
   enviada a alguém. Registre versão/commit/data exatos.
2. **Um salto atrás** — o que gerou aquele artefato (CI, workflow, script de
   build, publicação manual)? O artefato publicado corresponde de fato ao último
   commit da branch default? Aponte qualquer defasagem.
3. **Mais um salto** — a branch default corresponde ao trabalho real? Liste
   branches abertas, PRs pendentes, commits locais não enviados, stashes e
   arquivos não versionados que sejam relevantes.
4. **Camada de configuração** — mapeie toda informação que aparece em mais de um
   lugar: versão, nome, descrição, URLs, variáveis de ambiente, dependências,
   credenciais referenciadas, comandos de build/teste. Para cada duplicata: onde
   aparece, quais valores divergem, e qual local **deveria** ser a fonte de
   verdade.
5. **Documentação vs. código** — o README/docs descrevem o que o código
   realmente faz hoje? Aponte instruções quebradas, comandos que não existem
   mais, exemplos desatualizados.
6. **Contexto de agente** — existe `CLAUDE.md`, `.claude/`, `AGENTS.md`, hooks
   ou skills? Refletem o estado atual ou uma realidade antiga?

## Entregáveis

Produza, nesta ordem:

**A. Ficha do projeto** — nome, propósito, raiz, diretórios relacionados,
estado do git, artefato publicado mais recente, data da última atividade real.

**B. Tabela de divergências**

| item | onde diverge | valor A vs valor B | fonte de verdade recomendada | severidade |
|---|---|---|---|---|

**C. Oportunidades de fonte única** — onde vale centralizar (versão só no
manifesto, config só num arquivo, docs geradas a partir do código) e qual
manutenção manual isso elimina.

**D. Pendências e lacunas** — o que está inacabado, o que está bloqueado, o que
depende de decisão minha, e o que este projeto **espera receber** de outro
projeto ou do orquestrador.

**E. Plano de sincronia** — ações ordenadas do mais crítico ao cosmético, com
esforço estimado.

**F. Riscos de dessincronização futura** — onde a divergência volta se nada for
automatizado, e qual automação (hook, check de CI, script) previne cada caso.

**G. O que o orquestrador precisa saber** — resumo de até 10 linhas, pronto para
ser colado no repositório central, com o essencial: estado, pendência principal,
e a fonte de verdade deste projeto.
