# Handoff — como o estado de um projeto chega ao orquestrador

O orquestrador precisa responder *"o que existe, onde está a verdade, o que está
pendente"* sem que ninguém abra cada projeto. Só que **R1 proíbe que uma sessão
leia um repositório privado e escreva neste, que é público** — e essa é a regra
que torna todo o resto possível, então não se abre exceção para ela.

O handoff é a resposta a essa tensão. É a única coisa que atravessa a fronteira,
e ela atravessa **carregada por uma pessoa**, nunca por uma sessão.

## O caminho, em quatro passos

1. **A auditoria roda na origem.** Uma sessão de nuvem escopada em um único
   repositório privado ([prompt](../../.claude/prompts/auditoria-integral.md))
   audita, aplica o que está autorizado e grava o relatório **no próprio
   repositório auditado**, em `docs/auditoria/AAAA-MM-DD-integral.md`.
2. **O relatório termina num bloco sanitizado**, sob o título
   `## Handoff — sanitizado`, com no máximo 12 linhas e o checklist do
   [`SECURITY.md`](../../SECURITY.md) já aplicado linha a linha.
3. **Uma pessoa lê o bloco e o traz.** Não há automação neste passo, e a
   ausência dela é o controle: um humano lendo doze linhas é a última chance de
   barrar o que não devia sair. Se isso parecer trabalho demais, o problema é o
   número de auditorias simultâneas, não o gate.
4. **A ficha é criada ou atualizada aqui**, e o índice do
   [`AGENTS.md`](../../AGENTS.md) recebe a linha correspondente.

Nenhuma sessão executa os passos 1 e 4. Quem audita não publica; quem publica
não leu o privado.

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

## Modelo

[`_modelo.md`](_modelo.md) — copie, preencha, apague o que não se aplica. Não
invente célula: *não verificado* é uma resposta legítima e mais valiosa do que
uma suposição plausível.
