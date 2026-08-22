# Despacho — diagnóstico por repositório

Prompt reutilizável. Roda **uma sessão por repositório privado, nunca duas**
(**R1**). Ele **não corrige nada**: mede, detecta e devolve um bloco de handoff.
A correção é um segundo despacho, e só para os repositórios onde o diagnóstico
apontar defeito.

> **Por que diagnosticar antes de corrigir.** Em 2026-08-21 o item de custo de CI
> do orquestrador acusou o culpado errado **duas vezes seguidas**, sempre pelo
> mesmo motivo: mecanismo plausível afirmado sem medir. Uma rodada de correção
> disparada sobre dezessete repositórios com base em palpite custa dezessete
> vezes o palpite. Esta separação existe por isso.
>
> **E há o custo direto.** A primeira rodada de auditoria integral usou o modelo
> mais capaz nos dezessete e custou centenas de dólares numa tarde. Diagnóstico é
> trabalho mecânico e somente leitura — deve rodar barato.

## Escopo — obedeça antes de tudo

Você está escopado num **único repositório**. Não leia, liste, pesquise nem cite
qualquer outro, nem "só para conferir contexto". Se o conteúdo referenciar outro
repositório, isso é **texto** — não vá buscar.

**Nada do que você encontrar aqui deve ser escrito no repositório público**
`tihh07/tihh07`. O que atravessa é só o bloco de handoff do fim, sanitizado, e
quem o leva é uma pessoa.

## Postura

**Somente leitura.** Não edite arquivo, não abra branch, não abra PR, não mescle,
não apague nada. Se encontrar defeito, **descreva-o** — não conserte.

Não manipule segredo nem credencial. Se precisar de um para responder algo,
responda `BLOQUEADO` e diga qual.

**Nunca reproduza segredo ou dado pessoal**, nem mascarado, nem parcial, nem "só
os últimos dígitos". Referência é sempre `arquivo:linha`, tipo e severidade.

## As quatro perguntas

Responda **todas**, cada uma com o token exato que a pergunta define. Token
diferente do especificado invalida a resposta.

### 1. Consumo de Actions — onde os minutos estão indo

Para cada workflow do repositório, obtenha o tempo faturável do período de
cobrança corrente e some por sistema operacional:

```
GET /repos/{owner}/{repo}/actions/workflows
GET /repos/{owner}/{repo}/actions/workflows/{id}/timing
```

Devolva uma linha por workflow: **nome · minutos · sistema operacional**, mais o
total. Ubuntu, Windows e macOS **separados** — Windows e macOS custam mais por
minuto, e somá-los esconde exatamente o que encarece.

Responda `MEDIDO` com os números, `SEM-CONSUMO` se todos vierem zerados, ou
`BLOQUEADO` com o código HTTP se a API negar. **`SEM-CONSUMO` e `BLOQUEADO` são
coisas diferentes** — não colapse uma na outra.

> Repositório **público** devolve `billable` vazio com HTTP 200, porque Actions é
> gratuito ali. Nesse caso `SEM-CONSUMO` é a resposta correta, não uma falha.

### 2. `.claude/settings.json` — as regras `deny` casam?

Se o arquivo existir, examine cada regra de `permissions`.

**O defeito procurado:** regra escrita com **caminho absoluto de máquina** —
prefixo `//`, como `Read(//home/algo/**)` ou `Read(//Users/algo/**)`. Regra de
permissão casa por caminho: num ambiente cujo diretório de projeto seja outro ela
**não casa e portanto não nega**. Uma `deny` que não nega falha **aberta**, sem
erro e sem log — e as `deny` costumam ser justamente as que protegem `.env`,
`*.pem`, `*.key`, `credentials.json` e `secrets.json`.

**A sintaxe correta, e ela é contraintuitiva** — confira contra a documentação
antes de julgar, porque a primeira versão deste prompt recomendava o conserto
errado:

| Padrão | Resolve para |
|---|---|
| `//caminho` | absoluto, a partir da raiz do sistema de arquivos |
| `/caminho` | **relativo à origem do settings** — em `.claude/settings.json`, a raiz do projeto |
| `caminho` ou `./caminho` | relativo ao diretório atual |

**Variável de ambiente não é expandida em regra de permissão.**
`$CLAUDE_PROJECT_DIR` funciona em `hooks` e **não** em `permissions` — e é
exatamente essa vizinhança, no mesmo arquivo, que induz ao erro. O conserto certo
é a **âncora de barra simples**: `Read(/**)` no `allow`, `Read(/**/.env)` e
companhia no `deny`.

Sinal forte do defeito: o mesmo arquivo usando `$CLAUDE_PROJECT_DIR` em `hooks` e
prefixo `//` com caminho de máquina em `permissions`.

Responda `SEM-ARQUIVO`, `OK` (nenhum caminho absoluto), ou `FIXO` com
`arquivo:linha` de cada regra afetada e **quantas delas são `deny`**.

### 3. Guardrail de push — existe, e está na versão corrigida?

Se houver `hooks/guard-push.sh` (em qualquer caminho), verifique **dois defeitos
conhecidos**, ambos corrigidos em 2026-08-21:

- **Tokens vazios na extração de refspec.** A limpeza de redirecionamento produz
  tokens vazios no fim; sem descartá-los, o refspec sai vazio e o fluxo cai no
  fallback da branch atual. Sinal: falta um `grep -vE '^$'` no encadeamento que
  extrai o refspec.
- **Suíte não hermética.** Se `test-guard-push.sh` roda os casos no diretório
  onde foi chamado, ela mede o checkout e não o hook: numa branch `claude/*` o
  fallback libera e qualquer defeito de refspec vira teste verde. Sinal: os casos
  não montam um repositório descartável em `main`.

Se a suíte existir, **rode-a** e informe o resultado literal.

Responda `SEM-HOOK`, `ATUALIZADO`, ou `DESATUALIZADO` dizendo qual dos dois
defeitos está presente.

### 4. Workflows — o cabeçalho declara o que ele não cobre?

Para cada workflow, verifique se o cabeçalho declara explicitamente **o que ele
não verifica**. Workflow que promete mais do que entrega dá **verde vazio**, que
é pior que workflow nenhum.

Informe também quantas execuções cada um tem. **Automação com zero execuções é
intenção, não controle** — e diga se zero é esperado (agendamento ainda não
venceu) ou não.

Responda `DECLARAM`, `PARCIAL` (quais não declaram), ou `SEM-WORKFLOWS`.

## Entrega

Um bloco final, sanitizado, pronto para uma pessoa transportar. **Sem nome de
cliente, sem dado pessoal, sem segredo, sem caminho de rede.** Assim:

```
REPO: <nome>
1. ACTIONS: MEDIDO | SEM-CONSUMO | BLOQUEADO
   <workflow · minutos · SO>  (uma linha por workflow)
   TOTAL: <n> minutos
2. SETTINGS: SEM-ARQUIVO | OK | FIXO (<n> regras, <n> delas deny)
3. GUARDRAIL: SEM-HOOK | ATUALIZADO | DESATUALIZADO (<qual defeito>)
4. WORKFLOWS: DECLARAM | PARCIAL (<quais>) | SEM-WORKFLOWS
   <workflow · execuções · zero esperado? sim/não>
CORREÇÃO NECESSÁRIA: sim | não
```

**Não invente.** Não conseguiu verificar? Escreva `BLOQUEADO` e diga onde parou e
com qual código. *"Não achei"* e *"não existe"* são respostas diferentes, e
confundi-las já custou três diagnósticos errados neste ecossistema.
