# Handoff — como o estado de um projeto chega ao orquestrador

O orquestrador precisa responder *"o que existe, onde está a verdade, o que está
pendente"* sem que ninguém abra cada projeto. Só que **R1 proíbe que uma sessão
leia um repositório privado e escreva neste, que é público** — e essa é a regra
que torna todo o resto possível, então não se abre exceção para ela.

O handoff é a resposta a essa tensão. É a única coisa que atravessa a fronteira,
e ela atravessa **carregada por uma pessoa**, nunca por uma sessão.

## Onde a ficha mora: na origem

**Cada projeto escreve a própria ficha, no próprio repositório**, em
`docs/handoff/<setor>.md`. O slug vem do campo `setor:` do frontmatter do
`AGENTS.md` daquele projeto — então não existe mapa central para manter, nem para
vazar.

Isso corrige um erro de desenho da primeira versão deste documento, que mandava a
ficha inteira atravessar para o repositório público. Ela não precisa: o
orquestrador não consome o **conteúdo** da ficha, consome o **estado**.

| A pergunta que o orquestrador responde | O que precisa atravessar |
|---|---|
| *O que existe?* | contagem, setor, estado — nenhum deles é conteúdo privado |
| *Onde está a verdade?* | para departamento privado, um **ponteiro** para a ficha na origem |
| *O que está pendente?* | a manchete, **uma linha** — e só quando houver motivo para ela ser pública |

Estado e data são **metadado de orquestração**: quem despachou sabe o que
despachou e quando, sem ler repositório nenhum. Atravessam sem gate.

## O que ainda precisa de uma pessoa, e por quê

Só um caso, e ele virou exceção em vez de regra: **publicar aqui a pendência de
um departamento privado**. Aquela linha saiu de dentro de um repositório privado,
e o repositório público é indexável, clonável e espelhável.

O humano não está aí por mecânica — a mecânica é copiar e colar. Está aí porque
**a sanitização foi feita por um agente, e a conferência de que ela funcionou não
pode ser feita pelo mesmo tipo de coisa que a fez**, na única fronteira onde o
erro é irreversível.

Isso também explica por que não vale automatizar o transporte por um caminho
indireto — bloco gravado numa pasta compartilhada e lido por uma sessão de escopo
público, por exemplo. Nenhuma sessão montaria os dois repositórios, então a letra
de R1 estaria satisfeita; mas conteúdo privado chegaria ao público sem ninguém
olhar, que é exatamente o que a regra existe para impedir. **Um controle
contornado por um caminho que a regra não previu continua contornado.**

## A ficha não leva o nome do repositório

Cada ficha se chama pelo **slug do departamento** — `fundacao.md`,
`segundo-cerebro.md` —, não pelo nome do repositório de origem.

O motivo é o mesmo que reduziu treze linhas do índice a uma: vários nomes de
repositório do ecossistema são nomes de organização, e publicá-los aciona os
itens 1 (nomes) e 7 (titularidade) do checklist. Um slug de departamento é uma
categoria funcional — descreve o que aquilo faz, não de quem é.

**O mapa slug → repositório vive fora deste repositório.** Quem precisa dele já
tem acesso aos dois lados; quem não tem, não deveria conseguir reconstruí-lo
lendo o perfil público. Não versione esse mapa aqui, nem em nota de rodapé, nem
como exemplo.

Os quatro departamentos que o blueprint já nomeia continuam nomeados — o dado já
está publicado e recolher não desfaz. Um deles cai na mesma decisão humana que
os treze; até ela vir, não se acrescenta o quinto.

## Antes de colar, releia contra o checklist

O bloco chega sanitizado pela origem. Isso não dispensa a conferência aqui, por
uma razão específica: **quem sanitiza conhece o contexto, e quem conhece o
contexto não vê o que ele entrega.** O item que mais escapa não é o segredo — é
o exemplo didático que ainda carrega estrutura reconhecível de um caso real, ou
a métrica "arredondada" que ainda diz o tamanho do negócio.

Passe as doze linhas pelos oito itens do [`SECURITY.md`](../../SECURITY.md). Se
uma linha não passar, **não a reescreva para caber — remova-a** e registre no
lugar: *"omitido: aciona o item N do checklist"*. Linha reescrita para passar
costuma ser a mesma informação com outra roupa, e sanitização deixa rastro.

## O que uma ficha nunca contém

Nem porque ficaria mais útil, nem porque "está tudo privado mesmo":

- nome de cliente, empregador, paciente ou pessoa física sem consentimento;
- número real de negócio — faturamento, margem, volume, resultado;
- caminho de rede, hostname, nome de sistema interno, id de conta;
- horário de execução de rotina, conector anexado, identificador de controle ou
  comando que desliga um controle. Nenhum desses é segredo isolado; juntos,
  descrevem quando e por onde o ecossistema está desprotegido.

Esse último item é aprendizado próprio: até 2026-08-20 o backlog público reunia
exatamente essa combinação, e nenhuma linha dele parecia problema sozinha.

## Ficha ausente é informação

Departamento sem ficha significa **auditoria nunca concluída** — e é assim que
deve ser lido. Não crie ficha "provisória" com células em branco para a tabela
ficar completa: o índice existe para dizer o que se sabe, e uma linha vazia
mente melhor do que a ausência dela.

O mesmo vale para auditoria despachada e ainda em curso: enquanto o bloco não
chegar, o estado é *em voo*, não *auditado*. Despachar não é auditar.

**Mas confira a ref antes de declarar ausência.** A auditoria grava o relatório
na branch de auditoria, e o PR dela normalmente ainda não foi mesclado quando a
ficha é escrita — então o relatório **não está na branch default**. Quem procura
só na default conclui que a auditoria não entregou, e escreve isso na ficha.
Aconteceu com três repositórios em 2026-08-21. Antes de registrar relatório
ausente, procure na branch da auditoria:

```
git show origin/claude/auditoria-integral-<data>:docs/auditoria/<data>-integral.md
```

Ausência só é informação depois que as duas refs foram consultadas. Antes disso
é ruído — e ruído que vira linha de backlog custa mais caro do que o comando
acima.

## Modelo

[`_modelo.md`](_modelo.md) — copie, preencha, apague o que não se aplica. Não
invente célula: *não verificado* é uma resposta legítima e mais valiosa do que
uma suposição plausível.
