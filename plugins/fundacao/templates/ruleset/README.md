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

## Aplicar em muitos de uma vez

`aplicar-ruleset.sh`, ao lado, roda isto em todos os seus repositórios de uma
vez. Leia o cabeçalho dele antes: **é para o dono rodar, nunca um agente**, e a
distinção não é cerimônia — rodá-lo por agente seria contornar, com o token de
outra pessoa, a permissão que existe justamente para que agente não reconfigure
repositório.

Ele **simula por padrão** e só escreve com `--aplicar`.

**Ele nunca toca numa branch default que já esteja protegida** — por qualquer
ruleset, com qualquer nome. A pergunta que ele faz é *"esta branch já está
protegida?"*, não *"existe um ruleset com o meu nome?"*, e a diferença não é
sutil: a segunda versão dele fazia a pergunta cômoda e anunciou que criaria um
`protect-default` em cima do `protect-main` que já protegia este repositório.

Empilhar dois rulesets no mesmo alvo não é inofensivo. As regras se somam,
ninguém sabe qual delas nega o quê, e quem ler *"o ruleset"* depois vai ler um
dos dois — possivelmente o mais frouxo. Decidir se a proteção que já existe basta
é julgamento humano; o script só recusa mexer e diz quem já está lá.

Ele também **não presume que a branch default se chame `main`**. Repositório
antigo ainda é `master`, e proteger a branch errada é pior que não proteger:
parece feito.

## Aplicar um a um, na tela

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
