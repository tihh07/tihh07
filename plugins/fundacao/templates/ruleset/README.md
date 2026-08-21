# Ruleset de proteção da branch default

`protect-default.json` é a configuração que o **H7** pede em cada repositório
privado: exigir PR, bloquear deleção da branch default e bloquear histórico
reescrito, **sem nenhum ator de bypass**.

Ele existe como arquivo por um motivo específico: **nenhum agente consegue
aplicá-lo.** A escrita de configuração de repositório é barrada por duas paredes
independentes, medidas em 2026-08-21 e documentadas em
[`docs/pendencias.md`](../../../../docs/pendencias.md) (itens **H1-bis** e **H7**).
Então o que um agente pode entregar é isto: a configuração exata, revisável em
diff, para uma pessoa aplicar.

## Aplicar

Na tela *Settings → Rules → Rulesets → New ruleset*, se houver a opção de
**importar um ruleset**, cole este arquivo. Caso contrário, reproduza os campos
à mão — são quatro.

**Confira antes de salvar que a lista de bypass ficou vazia.** Um ator de bypass
transforma o controle em sugestão, e é o campo que mais fácil se preenche sem
querer, porque a tela oferece adicionar.

## As três decisões embutidas, e por quê

**`required_approving_review_count: 0`.** Parece o campo errado e é o certo. O
GitHub não aceita autoaprovação; com um único colaborador, exigir uma aprovação
tranca o dono fora do próprio repositório — sem ninguém que possa destravar,
porque não há ator de bypass. Aprovação só entra quando existir um segundo
revisor de verdade.

**`require_code_owner_review: false`.** Mesma aritmética. Um `CODEOWNERS` só
passa a valer quando houver quem revise, e ligá-lo antes disso produz o mesmo
bloqueio total.

**Nenhuma regra de status check.** De propósito: o nome do check varia por
repositório, e **exigir um check que não existe bloqueia todo merge, para
sempre**. Adicione a regra depois, em cada repositório, apontando para um check
que já tenha reportado verde ao menos uma vez. É a mesma armadilha que o
cabeçalho de `.github/workflows/verificacao.yml` descreve sobre filtro de
`paths`.

## O que este ruleset NÃO faz

Ele impede empurrar direto na branch default. **Não impede** que uma identidade
com acesso de escrita abra um PR e o mescle sozinha — isso é o **H1-bis**, e com
um só colaborador não tem solução por aprovação, só por check obrigatório.

Também não substitui push protection: nada aqui age *antes* de um segredo ou
dado pessoal entrar no PR.
