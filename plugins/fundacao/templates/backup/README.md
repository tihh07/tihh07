# Backup do repositório para o Google Drive

Template de workflow que gera um `git bundle` do repositório inteiro, verifica o
bundle e o envia para uma pasta do Google Drive, **semanalmente e sem depender
de nenhuma máquina local estar ligada**.

Substitui o backup manual (bundle gerado no desktop e copiado para a nuvem), que
existe só nos dias em que alguém liga a máquina e não avisa ninguém quando não
liga.

| Arquivo | O que é |
|---|---|
| `backup-drive.yml` | O workflow. Copie para `.github/workflows/` do departamento. |
| este README | Instalação, armadilhas e limites. |

## Por que workflow, e não conector do Google Drive

Um conector se anexa a uma **rotina**. Uma rotina que fizesse backup de vários
repositórios teria repositório privado e repositório público no mesmo escopo —
violação direta de **R1**, a regra dura do ecossistema.

Um workflow do GitHub Actions vive **dentro de um repositório e só enxerga
aquele repositório**. É R1-seguro por construção, e não por disciplina de quem
configurou. Por isso o caminho é este, mesmo com o conector já autorizado.

## Por que service account, e não OAuth de usuário

Fluxo OAuth de consumidor depende de refresh token que expira e de consentimento
humano periódico para renovar — exatamente o tipo de manutenção que um backup
esquecido não recebe. Service account do Google Cloud não tem essa etapa: a
chave vale até ser revogada.

O que ainda pode quebrar, e falha ruidosamente: chave revogada/apagada, Drive API
desabilitada no projeto, pasta descompartilhada, cota de armazenamento estourada.

## Instalação num departamento

1. **Crie (ou reaproveite) um projeto no Google Cloud** e habilite nele a
   **Google Drive API** (`APIs e serviços` → `Ativar APIs` → "Google Drive API").
   Sem esse passo o token é emitido e toda chamada volta erro de API desabilitada.

2. **Crie a service account**: `IAM e administrador` → `Contas de serviço` →
   `Criar conta de serviço`. Ela **não precisa de nenhum papel (role) IAM no
   projeto** — o acesso ao Drive não vem do IAM, vem do compartilhamento da
   pasta no passo 4. Anote o e-mail dela, no formato
   `nome@projeto.iam.gserviceaccount.com`.

3. **Gere a chave JSON**: aba `Chaves` → `Adicionar chave` → `Criar nova chave` →
   `JSON`. O arquivo baixa uma vez e não é recuperável depois. Ele é a
   credencial inteira: quem tem esse arquivo escreve no seu Drive.

4. **Compartilhe a pasta de destino do Drive com o e-mail da service account**,
   como **Editor**. Este é o passo que quase todo mundo esquece, e a falha dele
   é opaca: o token é emitido normalmente e o upload volta `404` ou erro de
   permissão como se a pasta não existisse. Ela não existe — para a service
   account, que é uma conta separada da sua e não enxerga nada do seu Drive por
   padrão.

5. **Pegue o ID da pasta**: abra a pasta no Drive e copie o trecho final da URL,
   depois de `/folders/`.

6. **Crie os dois secrets** no repositório (`Settings` → `Secrets and variables`
   → `Actions` → `New repository secret`):

   | Secret | Conteúdo |
   |---|---|
   | `GDRIVE_SA_KEY` | O arquivo JSON da chave, **inteiro e sem editar** (cole o conteúdo completo). |
   | `GDRIVE_FOLDER_ID` | O ID da pasta do passo 5. |

7. **Copie `backup-drive.yml` para `.github/workflows/`** do departamento e
   abra o PR. Nenhum ajuste é necessário: o nome do arquivo de backup deriva de
   `GITHUB_REPOSITORY` em tempo de execução.

8. **Rode uma vez à mão** (`Actions` → `Backup para o Google Drive` → `Run
   workflow`) e confira o resumo da execução: data, tamanho do bundle, contagem
   de refs e resultado do envio. Depois abra a pasta do Drive e veja o arquivo
   lá. Instalar não é funcionar.

9. **Teste a restauração** (veja a última seção). Enquanto não tiver feito isso,
   você tem um arquivo no Drive, não um backup.

## Duas coisas que costumam morder

### 1. Service account tem cota de armazenamento própria

Numa conta Google **pessoal** (Gmail, sem Workspace), um arquivo criado por uma
service account dentro de uma pasta compartilhada **pertence à service account**,
não a você. E service account tem cota de armazenamento própria — pequena, e não
ampliável comprando espaço na sua conta. Quando ela estoura, o upload passa a
falhar com erro de cota, e o backup para.

O sintoma engana: a pasta é sua, tem espaço de sobra, e mesmo assim o envio
falha.

Contornos, em ordem de robustez:

- **Shared Drive (drive compartilhado)** — a propriedade do arquivo é do drive,
  não de quem criou, e a cota é a do drive. É a solução limpa, e está disponível
  **apenas em Google Workspace**. Adicione a service account como membro
  (`Colaborador de conteúdo` ou superior) do drive compartilhado e use o ID dele
  como pasta de destino. O workflow já envia `supportsAllDrives=true`.
- **Transferir a propriedade** dos arquivos criados para a sua conta,
  periodicamente. Funciona, mas é trabalho manual recorrente — e tem um efeito
  colateral: sob o escopo `drive.file` que o workflow usa, a service account
  **deixa de enxergar** o arquivo cuja propriedade saiu dela. Consequência
  prática: numa re-execução no mesmo dia, ela não encontra o arquivo anterior e
  cria um novo em vez de atualizar. Não corrompe nada — duplica.
- **Aceitar a cota e podar** — apagar bundles antigos antes de estourar. Junta-se
  bem com a retenção descrita abaixo, e continua sendo trabalho humano.

Em conta pessoal, a recomendação honesta é: monitore o tamanho da pasta desde a
primeira semana, porque o limite chega sem aviso.

### 2. Retenção: sobrescrever ou versionar por data

O template **versiona por data**: o arquivo se chama
`<owner>-<repo>-AAAA-MM-DD.bundle`. Se já existir um arquivo com esse mesmo nome
(re-execução no mesmo dia), ele é atualizado no lugar; datas diferentes viram
arquivos diferentes.

- **Versionar** (o que o template faz) preserva a janela de recuperação: um
  estrago percebido só depois de N dias ainda tem um bundle anterior ao estrago.
  Custo: a pasta **cresce sem limite** — cerca de 52 arquivos por ano, cada um
  do tamanho do repositório inteiro. Nada no workflow apaga bundle velho.
- **Sobrescrever** um arquivo fixo não cresce, e perde exatamente essa janela: o
  backup bom é substituído pelo backup do estado já estragado, e não há
  segunda chance.

**Como trocar para arquivo único:** no step `Gerar e verificar o bundle`, troque

```bash
NOME_ARQUIVO="${SLUG}-${DATA}.bundle"
```

por

```bash
NOME_ARQUIVO="${SLUG}.bundle"
```

O resto do workflow já faz "atualiza se existir, cria se não existir" — nenhuma
outra mudança é necessária. Se fizer isso, **registre a escolha no cabeçalho do
seu arquivo**: a próxima pessoa precisa saber que não há histórico.

Se preferir versionar **com poda**, a poda tem que ser um segundo mecanismo
(rotina, script, ou humano com lembrete). Este workflow não apaga nada, de
propósito: um job de backup com permissão de deletar arquivos no destino é um
job que pode apagar o backup.

## A armadilha dos 60 dias

O GitHub **desabilita automaticamente workflows agendados após 60 dias sem
atividade no repositório**. Para um backup, esse é o pior modo de falha possível:
o cron simplesmente para, nenhum job falha (não há job), nenhum e-mail chega, e a
última cópia envelhece calada — exatamente a situação que este workflow existe
para eliminar.

**`workflow_dispatch` não resolve.** O botão manual permite rodar; não impede a
desabilitação nem avisa que ela aconteceu.

Nenhuma verificação dentro do repositório resolve, tampouco: se o agendamento
está desabilitado, não há execução para reclamar. A conferência tem que vir de
fora:

- a **data do bundle mais recente na pasta do Drive** é a evidência que não
  depende deste repositório estar vivo — se ela envelheceu, o backup morreu;
- um lembrete de calendário ou uma rotina em outro sistema comparando essa data
  com hoje;
- commit real no repositório dentro da janela reinicia o contador — mas
  repositório de arquivo morto não recebe commit, e é justamente ele quem mais
  precisa do backup.

## O que este backup NÃO protege

Dito antes que alguém confie demais:

- **Exclusão acidental replicada.** Se o estrago entrou no histórico, o backup
  do dia seguinte é o backup do estrago. O que protege é a janela de retenção —
  e ela é só a quantidade de bundles antigos que você guardou.
- **Comprometimento da conta Google.** Quem entra na conta apaga a pasta. O
  backup e a conta que o guarda compartilham modo de falha; uma segunda cópia
  em outro provedor é o que quebra essa correlação.
- **Comprometimento da chave da service account.** Quem tem o JSON escreve na
  pasta. Ele não dá acesso ao resto do seu Drive (escopo `drive.file`, e a SA só
  enxerga o que ela mesma criou), mas dá acesso aos backups.
- **O que não é git.** Issues, pull requests, reviews, wiki, releases e binários,
  secrets, variáveis, rulesets, configuração do repositório, histórico de
  Actions: nada disso está no bundle. Objetos **Git LFS** também não — o bundle
  leva os ponteiros, não os blobs.
- **Confidencialidade.** O bundle vai em claro. Em repositório privado, isso
  move parte da superfície de risco para o Drive e para a chave. Decida isso
  conscientemente, por repositório — não copie a conclusão de um repositório
  público para um privado.

## Restauração — e por que ela não é opcional

**Backup sem restauração testada é intenção, não controle.** O `git bundle
verify` que o workflow roda prova que o arquivo não está corrompido; não prova
que você consegue voltar a trabalhar a partir dele.

Baixe o bundle da pasta do Drive e:

```bash
git clone <arquivo>.bundle <destino>
cd <destino>
git log --oneline | head      # o histórico está aqui?
git branch -a                 # as branches estão aqui?
```

O clone abre na branch que estava em HEAD quando o bundle foi criado (nas
execuções agendadas, a branch default do repositório). As demais refs vêm junto
como remote-tracking (`git branch -a`), e para publicar de volta basta apontar o
`origin` para o novo remoto e empurrar.

Faça esse teste **na instalação** e depois em intervalo fixo — trimestral é um
piso razoável. Anote a data do último teste em algum lugar que alguém leia; um
teste de restauração que ninguém sabe quando ocorreu vale o mesmo que nenhum.
