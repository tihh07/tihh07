# Medir onde os minutos de Actions estão indo

`medir-actions.sh` devolve **minutos faturáveis por workflow e por repositório**,
ordenados. Somente leitura — não altera nada, em lugar nenhum.

## Por que ele existe

O item **C1** do backlog abriu com a cota a 90% e passou o dia inteiro com o
culpado errado, duas vezes seguidas:

1. Acusou um workflow "distribuído pelo plugin". Um `find` mostrou que o plugin
   nem o distribuía.
2. Acusou cron diário. A medição parcial apontou custo por **commit** — mecanismo
   oposto, que inverte a recomendação inteira: contra custo por commit, podar
   cron resolve pouco.

O padrão dos dois é idêntico e vale nomear: **mecanismo plausível afirmado sem
medir.** Este script existe para encerrar a categoria. Ele não opina sobre causa
— entrega números e deixa a conclusão para quem lê.

**Não aplique otimização de CI antes de rodar isto.** É o que o C1 manda, e é a
lição que ele custou duas vezes no mesmo dia.

## Onde rodar, e a resposta para "estou no celular"

Bash, curl e python3. Um **Codespace do GitHub** serve, e é o caminho para quem
só tem o telefone: é um Linux de verdade, aberto no navegador, com o
`GITHUB_TOKEN` já injetado — normalmente **não é preciso criar token nenhum**
para esta leitura.

```
bash medir-actions.sh                    # todos os privados
bash medir-actions.sh --todos            # inclui públicos
bash medir-actions.sh --repo a --repo b  # só nesses
```

Se faltar permissão em algum repositório, ele **diz qual e segue** — um
repositório inacessível não derruba o lote, e o total ao final avisa que aquele
ficou de fora.

## Como ler a saída

**Os sistemas operacionais aparecem separados, de propósito.** Windows e macOS
custam mais por minuto que Ubuntu, e somá-los esconde exatamente o que encarece:
um workflow curto em macOS pode pesar mais que um longo em Ubuntu.

**Se o total lido for muito menor que a cota que a conta mostra em
*Settings → Billing*, a diferença é o achado** — está em repositório que o script
não leu, e é isso que se reporta, em vez de assumir que a medição fechou.

**Zero minutos em repositório público é o resultado correto**, não uma falha:
Actions é gratuito em público, então a API devolve `billable` vazio. Verificado
neste repositório — três workflows encontrados, três respostas `200`, zero
minutos.
