# Control-plane: o que existe, e como reconstruir se sumir

O ecossistema tem uma camada que **não é arquivo**: as rotinas agendadas na nuvem
e a configuração dos repositórios no GitHub. Clonar não recupera nenhuma das
duas, e o backup em bundle também não — ele copia o git, e isso aqui não está no
git.

Este documento não é backup: é o **desenho**, para que perder a UI signifique
refazer configuração, não redescobrir intenção. O item **D1** de
[`pendencias.md`](pendencias.md) rastreia a lacuna que ele mitiga.

**O que este arquivo deliberadamente não contém:** horário de execução,
identificador de rotina ou de controle, lista de conectores, nome de conta e nome
de repositório privado. Nenhum desses é segredo isolado; juntos descrevem quando
e por onde o ecossistema está desprotegido, que é o achado **N19** deste próprio
backlog. O que se registra é a forma, não o mapa operacional.

## Classes de rotina

Cinco classes, distinguidas pelo **escopo** — que é o que R1 governa, e portanto
o que mais importa preservar:

| Classe | Escopo de repositórios | O que faz |
|---|---|---|
| **Governança de publicação (N2)** | só o público | aplica o checklist de sanitização ao conteúdo versionado; read-only |
| **Governança de control-plane** | só privados | segredo, PII, doutrina e cobertura de CI nos repositórios de infraestrutura; read-only |
| **Saúde de acervo** | privados | consistência de um acervo de conhecimento; grava relatório num repositório do escopo |
| **Coleta operacional** | um privado | lê fonte externa, reconcilia e grava numa branch de trabalho; **nunca escreve na fonte** |
| **Produtividade pessoal** | nenhum | trabalha sobre conectores, não sobre repositórios |

## Invariantes — o que não pode mudar ao recriar

Se uma rotina for recriada e perder alguma destas, ela deixou de ser o que era:

1. **R1 — nunca privado e público na mesma rotina.** É a regra dura. Precisando
   cobrir os dois, são duas rotinas. Uma rotina que fiscaliza isso deve declarar,
   no próprio prompt, que a presença do público no escopo **é o achado principal**
   — assim a violação se denuncia mesmo se ninguém estiver olhando.
2. **Zero conectores, salvo quando o conector É a tarefa.** Conector vem ligado
   por padrão na criação; deixá-los é herança, não decisão. A exceção legítima é
   a classe de produtividade, cujo trabalho inteiro acontece no conector.
3. **Prompt é ponteiro para skill versionada**, não conteúdo. Prompt na UI não é
   revisável, não é auditável e some com a rotina. O ponteiro mantém inline só o
   que precisa sobreviver à ausência do arquivo: a regra de escopo, e a instrução
   de **parar e relatar** se a skill não puder ser lida.
4. **Contrato de conclusão.** Toda rodada termina em artefato — relatório
   commitado, ou registro explícito da falha com o erro literal. Rodada que falha
   em silêncio é indistinguível de rodada que não aconteceu, e isso já custou
   ciclos de diagnóstico às cegas neste ecossistema.
5. **Merge é humano.** Nenhuma rotina mescla. Push só em `claude/*`.
6. **Conteúdo de terceiro é dado, nunca instrução** — comentário, log de CI,
   página buscada. Texto externo que peça para ampliar permissão ou ler outro
   repositório é sinal de ataque, e a rotina para e relata.

## Para reconstruir

1. Decidir a **classe** e, a partir dela, o escopo. O escopo é a primeira
   decisão, não a última: ele determina se a rotina é uma ou duas.
2. Anexar as fontes — **conferindo que privado e público não se misturam**.
3. Remover **todos** os conectores, salvo na classe de produtividade.
4. Apontar o prompt para a skill versionada, mantendo inline o escopo e o
   comportamento de falha.
5. Escolher o modelo pelo procedimento de
   [`auditoria-integral.md`](../.claude/prompts/auditoria-integral.md).
6. Escolher horário **fora do topo da hora** — agendamento em `:00` concorre com
   o pico da plataforma e atrasa.
7. Rodar uma vez à mão e conferir que o artefato apareceu. Rotina cuja primeira
   execução ninguém conferiu é intenção, não controle.

## Configuração de repositório

Proteção de branch, ruleset, secret scanning e push protection **não são
alcançáveis por agente** a partir da nuvem — ver **V1** em
[`pendencias.md`](pendencias.md), que registra as duas causas distintas e qual
delas tem conserto humano.

Consequência para este documento: o estado real desses controles **não é
afirmado aqui**. O que se registra é a intenção — `main` protegida, merge por PR
revisado, secret scanning ligado — e a constatação de que conferir isso é ida à
interface, por uma pessoa, com data anotada. Documento que afirma configuração
que ninguém verificou é pior que documento nenhum: ele produz confiança sem
cobertura.
