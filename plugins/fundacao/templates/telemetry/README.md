# Telemetria do departamento

Template. Copie para `telemetry/` no repositório do departamento quando a
primeira rotina entrar em produção.

O regime de assinatura **não** oferece custo em dólares por run nem API de uso
programática. Este pipeline usa só o que existe de verdade — e declara o que não
tem em vez de estimar.

## `runs.jsonl` — uma linha por execução

Toda rotina termina anexando uma linha. Sem exceção, inclusive quando falha.

```json
{"ts":"2026-08-01T09:00:00Z","routine_id":"rotina-semanal-fundacao","session_id":"<CLAUDE_CODE_REMOTE_SESSION_ID>","repo":"<nome-do-repo>","model":"fable","prompt_version":"a1b2c3d","outcome":"success","duration_s":540,"pr_url":null,"files_changed":3,"tokens":null}
```

| Campo | Regra |
|---|---|
| `session_id` | De `CLAUDE_CODE_REMOTE_SESSION_ID`. É a chave que liga run ↔ commit ↔ PR ↔ telemetria. |
| `prompt_version` | Hash do `SKILL.md` que a rotina executou. Sem ele não há como saber qual versão produziu o resultado. |
| `outcome` | `success` \| `partial` \| `fail`, auto-avaliado **contra o critério escrito no prompt**. |
| `tokens` | `null` em regime de assinatura. Preencher só quando houver medição real. |

**`outcome` é o campo que estraga a telemetria inteira se for preenchido por
educação.** Status verde da run não é tarefa cumprida — é literal na
documentação oficial. Uma rotina que terminou sem erro mas não produziu o
entregável definido é `partial`, e registrar `success` ali envenena toda métrica
construída em cima.

## `usage-snapshots.csv` — o único número real

Uma vez por semana, snapshot manual do consumo da conta. Leva ~2 minutos e é a
única medida confiável enquanto o regime for assinatura.

```csv
data,plano,consumo_pct,runs_no_periodo,observacao
2026-08-01,max,42,4,
```

## O que não medir

**"% de PRs aceitos sem alteração" está deliberadamente ausente.** A métrica
induz revisão-carimbo, e revisão-carimbo anula o gate humano que sustenta a
matriz de riscos inteira. Uma métrica que corrompe o controle que ela deveria
observar é pior que métrica nenhuma.
