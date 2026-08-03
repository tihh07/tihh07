# Plugin-fundação

Templates genéricos de executores, guardrails e telemetria para os
departamentos do ecossistema. Implementa a seção 5 e o Apêndice A do
[blueprint de orquestração](../../docs/orchestration-blueprint.md).

## Por que ele vive no repositório público

Não é concessão — é a garantia mais forte disponível.

O blueprint impõe uma regra anti-vazamento: o plugin contém **apenas templates
genéricos**, e a memória (`agent-memory`) dos repositórios privados **nunca** é
fonte dele. Um plugin hospedado no repositório público satisfaz essa regra por
construção: não há nada privado ali para vazar, e qualquer conteúdo derivado de
repositório privado seria imediatamente visível na revisão do PR.

O conteúdo daqui é derivado exclusivamente do blueprint, que já é público.

## Conteúdo

| Caminho | O que é |
|---|---|
| `agents/` | Os oito executores: orquestrador + 7 papéis especializados |
| `hooks/guard-push.sh` | Guardrail `PreToolUse` — push só em `claude/*`, sem force, sem deleção |
| `templates/telemetry/` | Esqueleto de `runs.jsonl` e do snapshot semanal |

O **watchdog** não tem cópia aqui de propósito. O arquivo ativo em
[`.github/workflows/watchdog.yml`](../../.github/workflows/watchdog.yml) já é
portável: os quatro checks pulam sozinhos quando não se aplicam ao repositório,
então copiá-lo basta, sem ajuste. Manter uma segunda cópia "template" só criaria
duas versões para divergirem — que é exatamente o defeito que este ecossistema
existe para detectar.

## Instalação num departamento

1. Declarar o marketplace e o plugin no `.claude/settings.json` do repositório.
2. Instalar o hook — o `guard-push.sh` precisa estar referenciado nos `hooks`
   do `settings.json` para agir. Copiar o arquivo sem registrar o hook não
   protege nada.
3. Copiar `.github/workflows/watchdog.yml` do repositório público para
   `.github/workflows/` do departamento. Sem ajustes.
4. Copiar `templates/telemetry/` para `telemetry/` quando a primeira rotina
   entrar em produção.

**Alterar `.claude/**` é gate humano.** Nenhum agente executa esta instalação
sozinho.

## Estado

**Não exercitado.** Os agentes foram escritos a partir da especificação e
nenhum foi executado em trabalho real; o hook não foi testado num departamento;
o watchdog só roda ativado no repositório público. Versão 0.1.0 significa
exatamente isso.

Antes de replicar em escala, rodar no departamento-piloto e corrigir o que a
realidade contradisser — inclusive esta afirmação.
