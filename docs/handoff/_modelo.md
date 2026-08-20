# Ficha — <slug do departamento>

> Copie este arquivo para `docs/handoff/<slug>.md`. Slug do **departamento**,
> nunca nome do repositório — ver [README](README.md).
>
> Preencha só o que a auditoria verificou. *Não verificado* é resposta legítima;
> célula preenchida por suposição derrota o propósito do índice.

| Campo | Valor |
|---|---|
| **Departamento** | <o que este projeto é, em três a seis palavras> |
| **Missão** | <a decisão ou entrega real que ele serve, em uma frase> |
| **Nível de exposição** | <N1 privado · N2 público> |
| **Estado** | <auditado · em voo · não verificado> |
| **Última auditoria** | <AAAA-MM-DD, ou "—" se nunca> |
| **Adendo local** | <necessário · dispensado · não avaliado> |

## Fonte de verdade

O que este departamento é canônico para responder, e onde. Uma linha por
informação — é isto que impede a mesma coisa de ser mantida em dois lugares e
divergir.

| Informação | Onde é canônica |
|---|---|
| <ex.: versão do pacote> | <ex.: o manifesto, não o README> |

## Pendência principal

Uma só, a que mais custa se ficar parada. Diga **quem destrava**: ☁️ nuvem ·
👤 humano · 🏠 local. Pendência sem executor não anda.

## Depende de / é esperado por

O que este departamento aguarda de outro ou do orquestrador, e o que outro
aguarda dele. Referencie por **departamento**, nunca por repositório.

## Risco de dessincronizar

Onde a divergência volta se nada for automatizado, e qual hook, check ou script
previne cada caso. Sem isto, a próxima auditoria reencontra o mesmo achado e o
registra como novo.

## Limites desta ficha

O que a auditoria **não** alcançou, e por quê. Configuração de repositório no
GitHub, disco local, commit não enviado e stash são os candidatos habituais.
Lacuna declarada vale mais que suposição plausível — e uma ficha que não declara
limite nenhum está afirmando cobertura total, o que quase nunca é verdade.
