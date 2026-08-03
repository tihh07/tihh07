# Adendo local da auditoria — o que só o disco responde

> Complemento da [auditoria de nuvem](auditoria-fonte-de-verdade.md). Rode
> **depois** dela, na máquina onde o projeto vive, e **só** se o entregável H
> daquele relatório pediu. Copie a partir da linha abaixo.
>
> Tempo esperado: minutos. Isto não é uma segunda auditoria — é a fração que a
> nuvem comprovadamente não alcança.

---

## Por que este adendo existe

A auditoria de nuvem enxerga tudo que está versionado e tudo que a API do GitHub
expõe — o que cobre a maior parte do trabalho. Ela não enxerga o sistema de
arquivos da sua máquina. Estas perguntas ficaram de fora por impossibilidade
técnica, não por escolha.

Se você está lendo isto sem ter rodado a auditoria de nuvem antes, pare e rode
aquela primeiro. Este adendo sozinho não produz um retrato do projeto.

## Regras

- **Não altere nada.** Nem `git add`, nem limpeza de arquivo órfão, nem
  `stash drop`. Achou lixo? Registre. Apagar é decisão separada.
- **Não abra outro repositório.** A regra R1 vale aqui igual: uma sessão, um
  projeto.
- **Não leia conteúdo de dado sensível.** Para planilhas, exports e dumps,
  registre existência, caminho, tamanho e data — nunca o conteúdo. Se precisar
  caracterizar, use nome de coluna, jamais linha de dados.

## O que verificar

### 1. Território fora da raiz

- Pastas irmãs com nome parecido, clones antigos, `_old/`, `backup/`, `v2/`.
- Worktrees git (`git worktree list`) e submódulos efetivamente populados.
- Dados de negócio fora do repo: planilhas, exports, downloads, bases locais.
- Ambientes virtuais e diretórios de dependência não versionados.
- Caminhos absolutos referenciados em código ou config que apontem para fora da
  raiz — e se o destino existe de fato.

Para cada achado: caminho, o que contém, data de modificação, e se é fonte de
verdade de alguma coisa ou resíduo.

### 2. Trabalho não publicado

- `git status` — arquivos não versionados e modificações não commitadas.
- Commits locais à frente do remoto, em qualquer branch.
- `git stash list` — quantos, de quando, e se algum parece carregar trabalho
  real em vez de rascunho.
- Branches locais que não existem no remoto.

Aqui a pergunta que importa não é "quanto há", é: **algo disto seria perdido se
esta máquina sumisse hoje?**

### 3. Segredos em repouso

- `.env` e variantes presentes no diretório (não versionados, mas existentes).
- Credenciais em arquivos de config local, histórico de shell do projeto,
  ou notebooks com saída salva.

Registre apenas `arquivo:linha` e a severidade. **Nunca transcreva o valor.**

## Entregável

Um bloco curto, para anexar ao relatório de nuvem:

**H1. Território adicional** — tabela: caminho · conteúdo · última modificação ·
é fonte de verdade? · ação recomendada.

**H2. Trabalho em risco** — o que existe só nesta máquina, e o que se perde se
ela sumir. Ordenado por valor do trabalho, não por volume.

**H3. Segredos em repouso** — `arquivo:linha` e severidade, sem valores.

**H4. Correção ao relatório de nuvem** — algum achado da auditoria de nuvem
muda de conclusão à luz do que você viu no disco? Se sim, qual e por quê. Se a
nuvem acertou em tudo, diga isso — é informação sobre a qualidade do próprio
processo.
