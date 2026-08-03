# Relatórios de conformidade de publicação (N2)

Saída da rotina semanal de governança do repositório público. Um arquivo por
semana com achado, nomeado `AAAA-SS.md` (ano e semana ISO): `2026-31.md`.

Este diretório existe versionado de propósito. A rotina foi escrita para gravar
aqui, e um caminho de saída que só nasce na primeira gravação transforma o
primeiro achado real no primeiro teste do mecanismo — que é exatamente quando
não se quer descobrir que ele não funciona.

## Quando um arquivo é criado

**Só quando há achado.** Semana limpa não gera arquivo: a rotina responde em
poucas linhas e encerra. Registrar "está tudo certo" toda semana enche o
diretório de ruído e treina o revisor a não ler.

O fluxo com achado é: gravar o relatório aqui → commitar em
`claude/relatorio-publico-AAAA-SS` → abrir PR. **Nunca merge** — a leitura do
achado é a decisão humana que a rotina existe para provocar.

## Formato

```markdown
# Conformidade de publicação — semana AAAA-SS

Período: AAAA-MM-DD a AAAA-MM-DD
Commits no período: <n>  ·  Arquivos novos ou alterados: <n>
Outros repositórios disponíveis no ambiente e ignorados: <lista>

## Checklist N2

| # | Item | Status | Evidência | Severidade |
|---|---|---|---|---|
| 1 | Nomes | ✅/⚠️/❌ | arquivo:linha | — |
...

## Achados

### <título curto>
Severidade · arquivo:linha · o que fazer · como verificar que resolveu

## Ações priorizadas
```

Os oito itens do checklist estão em [`SECURITY.md`](../../SECURITY.md) e a skill
que a rotina executa em
[`.claude/skills/governanca-n2/SKILL.md`](../../.claude/skills/governanca-n2/SKILL.md).

## Regra inegociável de conteúdo

**Nenhum relatório aqui reproduz o dado que motivou o achado.** Este diretório é
público. Um relatório que transcreve o segredo encontrado publica o segredo uma
segunda vez, agora com destaque e contexto.

Referência a segredo ou dado pessoal é sempre `arquivo:linha` + severidade.
Nunca o valor, nem parcialmente, nem mascarado — máscara é um convite a
desmascarar.
