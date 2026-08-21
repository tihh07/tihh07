# Ficha — fachada-publica

> Preenchida em 2026-08-21 a partir da auditoria integral de 2026-08-20 e da
> reverificação do dia seguinte. É a única ficha que uma sessão pode escrever
> sozinha: o departamento é este repositório, então não há fronteira a atravessar.

| Campo | Valor |
|---|---|
| **Departamento** | Fachada pública e control-plane sanitizado |
| **Missão** | Publicar o perfil e o desenho do ecossistema, e distribuir o control-plane que os demais instalam |
| **Nível de exposição** | N2 — público, rigor máximo |
| **Estado** | auditado |
| **Última auditoria** | 2026-08-20, reverificada em 2026-08-21 |
| **Adendo local** | dispensado — não há sinal de território fora do git |
| **Sensibilidade** | **baixa** — documentação e configuração genéricas; nenhum dado de terceiro, nenhum número real de negócio |

## Fonte de verdade

| Informação | Onde é canônica |
|---|---|
| Checklist de sanitização, runbook de incidente, kill-switch, R1 | [`SECURITY.md`](../../SECURITY.md) — o blueprint aponta para cá, não repete |
| Desenho do ecossistema, matriz de riscos, roadmap | [`docs/orchestration-blueprint.md`](../orchestration-blueprint.md) — autoridade de projeto |
| Estado do que falta, com evidência e executor | [`docs/pendencias.md`](../pendencias.md) |
| Doutrina operacional, índice, convenções | [`AGENTS.md`](../../AGENTS.md) — `CLAUDE.md` é ponteiro |
| Executores, hook e telemetria | `plugins/fundacao/` — o blueprint publica versão ilustrativa e diz para não instalá-la |
| Desenho das rotinas e da config de repo | [`docs/control-plane.md`](../control-plane.md) |
| Escolha de modelo por rodada | [`.claude/prompts/auditoria-integral.md`](../../.claude/prompts/auditoria-integral.md) |

## Pendência principal

**H1-bis — o gate humano de `main` é doutrina, não controle.** 👤 humano.

O ruleset exige PR e **zero aprovação**, então qualquer identidade com escrita
pode abrir e mesclar sozinha. A regra "nenhum agente mescla" vale porque está nos
prompts, não porque a plataforma recusa. Destravar exige um segundo revisor — a
mesma pré-condição que trava **H2**.

## Depende de / é esperado por

**Espera:** o bloco de handoff sanitizado de cada um dos outros departamentos.
Sem eles o índice fica em *em voo* e o orquestrador não responde "o que existe".

**Fornece:** o plugin-fundação (executores, hook de push com suíte, telemetria,
backup), o padrão de handoff, e os três prompts de auditoria.

## Risco de dessincronizar

| Onde volta | O que previne |
|---|---|
| Número escrito no texto (contagem de casos, de runs, de repositórios) | não escrever o número — já envelheceu duas vezes aqui, calado |
| Workflow que promete mais do que verifica | cabeçalho declarando o que **não** cobre, exigido antes de todo PR |
| Guardrail alterado sem prova | `test-guard-push.sh`, que roda em qualquer máquina com bash e git |
| Documento afirmando configuração que ninguém leu | regra do backlog: nenhuma sessão de nuvem escreve "fechado" em item de configuração |

## Limites desta ficha

- **Secret scanning e push protection não foram verificados** — a API os nega por
  allowlist de proxy, e o campo não veio na resposta do repositório. Só a interface
  responde. Proteção de branch e ruleset, esses sim, foram lidos em 2026-08-21.
- **Disco local não observado.** Nenhuma sessão de nuvem enxerga commit não
  enviado, stash ou arquivo fora do git. Não houve sinal de que exista algo lá,
  mas ausência de sinal não é verificação.
- **O plugin distribuído nunca foi exercitado** fora deste repositório (**L3**):
  ele é instalado aqui e em nenhum outro lugar.
