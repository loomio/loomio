---
title: Receber envios privados
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 1d263d407af586d9
  enable-private-submissions: 3520fbea1fb1267f
  set-up-a-private-submission-process: e9e30dd30ab9d468
  make-a-submission: ac6611a046f0bf9f
  review-submissions: 7014e6ac14301129
generated:
  introduction: 79cb6dcf9ab7f427
  enable-private-submissions: 5a9b83761a98d28a
  set-up-a-private-submission-process: 5ad426a2163c49b9
  make-a-submission: a3665e14cc59fbe3
  review-submissions: 0bb79de44f0e64c2
title_source: e82ab76916d594f4
title_generated: 88dd08426aa0fb1d
---

<!-- translation-section: introduction -->

# Receber envios privados

Use um grupo Fechado para receber envios privados de pessoas que não são membros do grupo. Cada envio se torna uma discussão separada, na qual a pessoa que enviou e a equipe responsável pela análise podem trocar informações, fazer perguntas e registrar uma decisão. Quem envia não pode ver outras discussões privadas nem outros envios no grupo.

Indicações são um exemplo de uso quando os dados das pessoas candidatas ou a lista de pessoas indicadas precisam permanecer privados durante a seleção. Uma pessoa pode indicar a si mesma ou outra pessoa para uma eleição, nomeação, comissão, conselho ou função de representação. Uma comissão de seleção analisa cada indicação em uma discussão própria.

Outros casos em que os envios não devem ser públicos incluem:

- Reclamações, relatos de situações de risco, preocupações com a segurança e relatórios de incidentes
- Recursos e pedidos de reconsideração de uma decisão sobre um caso individual
- Pedidos de mediação, resolução de conflitos ou apoio pessoal
- Inscrições com informações pessoais, financeiras ou sobre critérios de elegibilidade, como pedidos de auxílio financeiro ou bolsas de estudo
- Propostas em envelope fechado ou respostas a licitações que precisam permanecer privadas durante a avaliação

Esse processo mantém os envios privados entre as pessoas que os fazem, mas não é anônimo. Cada pessoa precisa de uma conta de usuário, e todos os membros do grupo Fechado podem ver os envios. Antes de usar o grupo para informações confidenciais, considere quem faz parte da equipe responsável pela análise.

<!-- translation-section: enable-private-submissions -->

## Habilitar envios privados

Você precisa ser administrador do grupo ou subgrupo em que deseja receber os envios.

1. Abra o grupo.
2. Selecione **Configurações** (ou **Mais** e depois **Editar configurações do grupo**).
3. Abra **Permissões**.
4. Habilite **Quem não é membro pode iniciar discussões.**
5. Salve as configurações do grupo.

![A aba Permissões nas configurações do grupo, com Quem não é membro pode iniciar discussões. em destaque](non_members_can_start_discussions.png)

Esta opção está disponível apenas para grupos **Aberto** e **Encerrado**. Ela fica oculta para grupos **Secreto**. Se você não a encontrar, abra **Privacidade** nas configurações do grupo e altere **Privacidade do grupo** para **Encerrado** (recomendado para contribuições privadas) ou **Aberto**. Depois, volte a **Permissões**.

Habilitar essa permissão não torna públicas as discussões do grupo. Quem não é membro pode iniciar uma discussão e acessá-la como convidado, mas não pode ver as outras discussões privadas do grupo.

<!-- translation-section: set-up-a-private-submission-process -->

## Configurar um processo de envios privados

1. Crie um subgrupo dedicado ao processo de envio e defina sua privacidade como **Fechado**. Assim, os envios ficam separados das outras atividades do grupo principal.
2. Adicione ao subgrupo os membros da comissão de seleção ou outras pessoas responsáveis por analisar os envios. Todos os membros do subgrupo podem ver todos os envios. Adicione apenas quem deve ter esse acesso.
3. Crie um [modelo de discussão](/en/user_manual/discussions/templates) no subgrupo. Inclua as perguntas e informações que as pessoas devem fornecer. Você pode criar modelos de discussão diferentes para cada tipo de envio.
4. Se as pessoas que enviam não devem solicitar participação no subgrupo, defina a participação como **Somente por convite**.
5. [Habilite os envios privados](#enable-private-submissions) nas permissões do subgrupo.
6. Teste o processo com uma conta que não pertença ao subgrupo.
7. Compartilhe a página do subgrupo com as pessoas que poderão enviar informações. Elas precisam entrar na conta de usuário antes de fazer um envio.

<!-- translation-section: make-a-submission -->

## Fazer um envio

A pessoa abre o subgrupo e seleciona **Iniciar discussão**. O Loomio mostra os modelos de discussão disponíveis no subgrupo. A pessoa escolhe o modelo adequado, responde às perguntas e inicia a discussão.

A discussão pertence ao subgrupo, mas a pessoa que fez o envio não se torna membro dele. O Loomio a adiciona como convidada da discussão. Assim, ela pode ver a discussão e participar dela com a comissão ou a equipe responsável pela análise. Ela não pode ver outras discussões privadas nem outros envios no subgrupo.

<!-- translation-section: review-submissions -->

## Analisar os envios

Os membros do subgrupo podem ver todas as discussões iniciadas por envios. Eles podem fazer perguntas adicionais e usar comentários, enquetes ou outras ferramentas da discussão para concluir a análise.

Se outra pessoa precisar fornecer informações, um membro do subgrupo com permissão pode convidá-la para a discussão do envio. Por exemplo, quando alguém indica outra pessoa, o subgrupo pode convidar a pessoa indicada para a discussão caso sua participação seja necessária. Ela entra como convidada, sem acesso às outras discussões privadas do subgrupo.

Cada pessoa pode ver o próprio envio, mas não pode ver outras discussões privadas nem outros envios do subgrupo. Desabilite **Quem não é membro pode iniciar discussões.** quando o prazo para envios terminar. As discussões existentes e o acesso de convidados permanecem iguais.
