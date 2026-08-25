# Registro simplificado de operações de tratamento — modelo

> **Não é aconselhamento jurídico.** Este é um modelo operacional, escrito para
> que a obrigação que o [blueprint](orchestration-blueprint.md) declarou seja
> cumprível em vez de permanecer como intenção. A adequação ao caso concreto é
> do titular do ecossistema, e vale a pena confirmá-la com quem seja advogado.

Atende ao **item 5 do H5** ([`pendencias.md`](pendencias.md)): *registro
simplificado de operações*, na forma prevista para agentes de tratamento de
pequeno porte pela **Resolução CD/ANPD nº 2/2022**, que dispensa o registro
completo do art. 37 da LGPD e admite forma simplificada.

## O que este arquivo é, e o que ele não é

**É o modelo.** A estrutura, os campos, e o que cada um precisa conter para o
registro servir a alguma coisa.

**Não é o registro.** O registro preenchido nomeia repositórios, categorias de
titulares e volumes de dado — é precisamente o mapa que o **item 3** do
checklist do [`SECURITY.md`](../SECURITY.md) proíbe publicar, e publicá-lo
entregaria de graça o que um atacante teria de descobrir.

**O registro preenchido é N1 e mora no privado de governança.** Aqui fica a
forma, como já faz o [`control-plane.md`](control-plane.md) pela mesma razão e
com as mesmas palavras: *o que se registra é a forma, não o mapa operacional.*

## Uma tabela por operação

Uma operação é **um propósito de tratamento**, não um repositório e não uma
rotina. Duas rotinas que servem ao mesmo propósito sobre os mesmos dados são uma
operação; uma rotina que serve a dois propósitos são duas.

| Campo | O que preencher | Erro comum |
|---|---|---|
| **Operação** | nome curto e estável | usar o nome da ferramenta em vez do propósito |
| **Controlador** | quem decide finalidade e meios; contato | omitir o contato, que é o que torna o registro útil a um titular |
| **Operadores** | terceiros que tratam por conta do controlador — provedor de modelo, hospedagem de repositório, nuvem de execução | esquecer que o provedor de modelo é operador |
| **Finalidade** | para que serve, em uma frase verificável | finalidade tão ampla que nada fica de fora dela |
| **Categorias de titulares** | de quem são os dados | escrever "diversos" |
| **Categorias de dados** | que dados, por tipo — e **se há dado sensível** (art. 5º, II) | tratar dado sensível como se fosse comum |
| **Base legal** | hipótese do art. 7º (ou art. 11, se sensível) | marcar "legítimo interesse" sem o teste de balanceamento escrito |
| **Compartilhamento** | com quem sai, e por quê | não contar a leitura por agente como compartilhamento |
| **Transferência internacional** | país, e o fundamento | omitir, quando é justamente o ponto frágil — ver abaixo |
| **Retenção e eliminação** | por quanto tempo, e o que dispara o descarte | "indefinido", que não é prazo |
| **Medidas de segurança** | as que existem, não as desejadas | listar controle planejado como se estivesse aplicado |
| **Decisão automatizada** | há decisão que afete o titular? (art. 20) | responder "não" sem olhar o que a rotina decide |
| **Última revisão** | data | deixar sem data, que é o defeito que este ecossistema já pagou caro |

## Transferência internacional — preencha este com atenção

O blueprint já registra o ponto e ele não deve ser suavizado no preenchimento:
os **EUA não têm decisão de adequação da ANPD**, e a defesa realista aqui é a
**minimização** — não enviar o que não precisa ser enviado.

Isso tem consequência prática direta: **toda sessão de nuvem despachada a um
repositório clona o conteúdo dele** para um contêiner efêmero fora do país. Essa
cópia é tratamento, e é transferência. Um registro que descreve as rotinas mas
omite a clonagem descreve metade da operação.

Se dado pessoal real se tornar necessário à operação, o blueprint já decidiu o
caminho: **migrar antes para plano comercial/API com DPA**. O registro deve
apontar essa condição, para que ela seja um gatilho e não uma lembrança.

## As cinco classes de rotina, como ponto de partida

O [`control-plane.md`](control-plane.md) já publica as classes, então repeti-las
aqui não acrescenta exposição. Elas são o esqueleto do registro — cada uma vira
ao menos uma linha:

| Classe | Escopo | Observação para o registro |
|---|---|---|
| Governança de publicação (N2) | só o público | read-only; conteúdo já publicado — o caso mais simples |
| Governança de control-plane | só privados | lê infraestrutura; verificar se algum repo do escopo tem dado pessoal |
| Saúde de acervo | privados | grava relatório; o relatório também é tratamento |
| Coleta operacional | um privado | **lê fonte externa** — é aqui que dado de terceiro entra no ecossistema |
| Produtividade pessoal | nenhum repositório | opera sobre conectores; os conectores têm titulares próprios |

**A linha de coleta operacional é a que mais merece cuidado.** Ela é a única que
traz dado de fora para dentro, e portanto a única em que a titularidade pode não
ser do dono do ecossistema — que é exatamente a pergunta do **item 2 do H5**.

## Como manter isto vivo

Registro que não é revisado vira ficção com carimbo. Duas regras bastam:

1. **Rotina nova, ou mudança de escopo de rotina existente, exige revisitar o
   registro no mesmo trabalho.** Não depois.
2. **Cada linha carrega a data da última revisão**, e data velha é convite para
   remedir — a mesma lição que o backlog aprendeu com os bloqueios sem data.

---

*Documento técnico sob CC BY 4.0, conforme [`LICENSE`](../LICENSE). Não constitui
aconselhamento jurídico.*
