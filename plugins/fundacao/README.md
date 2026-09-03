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
| `hooks/test-guard-push.sh` | A suíte que prova o guardrail — rode-a depois de qualquer edição nele |
| `hooks/hooks-presentes.sh` | Relator `SessionStart` — anuncia hook declarado cujo arquivo não existe |
| `hooks/test-hooks-presentes.sh` | A suíte do relator, pela mesma razão |
| `templates/telemetry/` | Esqueleto de `runs.jsonl` e do snapshot semanal |
| `templates/backup/` | Workflow de backup do repositório para o Google Drive, e como instalá-lo |

O **watchdog** não tem cópia aqui de propósito. O arquivo ativo em
[`.github/workflows/watchdog.yml`](../../.github/workflows/watchdog.yml) já é
portável: os quatro checks pulam sozinhos quando não se aplicam ao repositório,
então copiá-lo basta, sem ajuste. Manter uma segunda cópia "template" só criaria
duas versões para divergirem — que é exatamente o defeito que este ecossistema
existe para detectar.

O **backup**, ao contrário, tem template *e* instalação, e a diferença é
deliberada: o arquivo ativo aqui carrega um bloco de análise de risco que só vale
para um repositório **público** — o bundle não revela nada que já não esteja
publicado. Copiar essa conclusão para um repositório privado seria copiar a parte
errada. Por isso as duas cópias existem, e por isso ambas declaram, no cabeçalho,
que divergem só no cabeçalho e que **o template é o lado que vale**.

## Instalação num departamento

1. Declarar o marketplace e o plugin no `.claude/settings.json` do repositório.
2. Instalar o hook — o `guard-push.sh` precisa estar referenciado nos `hooks`
   do `settings.json` para agir. Copiar o arquivo sem registrar o hook não
   protege nada.

   **E registrar o hook sem copiar o arquivo protege menos ainda, porque não
   avisa.** Medido em 2026-08-25: hook declarado cujo arquivo não existe sai com
   127, e o contrato de `PreToolUse` só bloqueia em 2 — a sessão segue com
   poderes plenos de git, em silêncio. É por isso que o `hooks-presentes.sh`
   existe e por isso ele entra junto, em `SessionStart`: aqui o caminho é
   `$CLAUDE_PROJECT_DIR`, num departamento pode ser `${CLAUDE_PLUGIN_ROOT}`, e
   errar entre os dois é exatamente o modo de falha que a distribuição produz.

   O `hooks-presentes.sh` **reporta e nunca bloqueia**, de propósito. Ele pode,
   por isso, ser instalado também em `~/.claude` — nível de usuário, caminho
   fora de qualquer worktree — sem impor política a repositório nenhum. O
   `guard-push.sh` **não pode**: ele não tem noção de escopo, e lá negaria
   `git push origin main` em toda a máquina.
3. Copiar `.github/workflows/watchdog.yml` do repositório público para
   `.github/workflows/` do departamento. Sem ajustes.
4. Copiar `templates/telemetry/` para `telemetry/` quando a primeira rotina
   entrar em produção.
5. Copiar `templates/backup/backup-drive.yml` para `.github/workflows/` e seguir
   o [README do template](templates/backup/README.md) — a credencial é humana, e
   até ela existir o workflow falha de propósito, em vez de pular calado.

**Instalar é decisão de quem responde pelo departamento.** Desde 2026-08-24 um
agente pode alterar `.claude/**` com teste, evidência e validação no PR — mas
escolher que um departamento passe a rodar este plugin não é edição de arquivo,
e continua sendo do dono.

## Estado

**Não exercitado, num sentido específico.** Os agentes foram escritos a partir
da especificação e nenhum foi executado em trabalho real; o watchdog só roda
ativado no repositório público. O hook **já foi exercitado** — instalado neste
repositório (`D5`) via `PreToolUse`, ele bloqueou e liberou pushes reais em
25/08 (evidência em `docs/pendencias.md`, item **L3**) — mas isso é dogfooding,
não distribuição: este é o único terreno onde o plugin nunca precisou viajar
para outro repositório. Falta instalá-lo num departamento que **não** seja o de
origem. Versão 0.1.0 significa isso: agentes não exercitados e hook exercitado
só na origem.

Antes de replicar em escala, rodar no departamento-piloto e corrigir o que a
realidade contradisser — inclusive esta afirmação.
