---
title: Receber envios privados
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 1d263d407af586d9
  enable-private-submissions: 3520fbea1fb1267f
  set-up-a-private-submission-process: e9e30dd30ab9d468
  make-a-submission: ac6611a046f0bf9f
  review-submissions: 7014e6ac14301129
generated:
  introduction: 64c4ce609aee99af
  enable-private-submissions: '091a606c58231d9a'
  set-up-a-private-submission-process: ec588d8aff228ac4
  make-a-submission: 1832d5ddd4ea0c64
  review-submissions: 757987cbdbfc92fe
title_source: e82ab76916d594f4
title_generated: 88dd08426aa0fb1d
---

<!-- translation-section: introduction -->

# Receber envios privados

Use um grupo fechado para receber envios privados de pessoas que não são membros do grupo. Cada envio se torna uma discussão separada que a pessoa que fez o envio e a equipe de avaliação do grupo podem usar para trocar informações, fazer perguntas e registrar uma decisão. Quem faz um envio não pode ver outras discussões privadas ou envios no grupo.

Indicações são um exemplo de uso quando os detalhes dos candidatos ou a lista de pessoas indicadas devem permanecer privados durante a seleção. Uma pessoa pode indicar a si mesma ou outra pessoa para uma eleição, nomeação, comitê, conselho ou função de representação, enquanto uma comissão de seleção avalia cada indicação em sua própria discussão.

Outras finalidades em que os envios devem permanecer privados incluem:

- Reclamações, relatos sobre proteção de pessoas vulneráveis, preocupações com segurança e relatos de incidentes
- Recursos e pedidos de reconsideração de uma decisão sobre um caso individual
- Pedidos de mediação, resolução de conflitos ou apoio pessoal
- Solicitações que contenham informações pessoais, financeiras ou sobre critérios de elegibilidade, como pedidos de auxílio financeiro ou bolsas de estudo
- Propostas sigilosas ou respostas a licitações que devem permanecer privadas durante a avaliação

Neste processo, os envios são privados entre as pessoas que os fazem, mas não são anônimos. Quem faz um envio precisa de uma conta de usuário, e todos os membros do grupo fechado podem ver os envios. Considere quem faz parte do grupo de avaliação antes de usá-lo para informações sensíveis.

<!-- translation-section: enable-private-submissions -->

## Ativar envios privados

Você deve ser admin do grupo ou subgrupo onde deseja receber envios.

1. Abra o grupo.
2. Selecione **Configurações** (ou **Mais** e depois **Editar configurações do grupo**).
3. Abra **Permissões**.
4. Ative **Quem não é membro pode iniciar discussões.**
5. Salve as configurações do grupo.

![A aba Permissões nas configurações do grupo, com Quem não é membro pode iniciar discussões em destaque](non_members_can_start_discussions.png)

Esta opção está disponível apenas para grupos **Aberto** e **Fechado**. Ela fica oculta para grupos **Secreto**. Se você não conseguir vê-la, abra **Privacidade** nas configurações do grupo e altere **Privacidade do grupo** para **Fechado** (recomendado para envios privados) ou **Aberto**. Depois, volte para **Permissões**.

Ativar esta permissão não torna públicas as discussões do grupo. Quem não é membro pode iniciar uma nova discussão e acessá-la como convidado, mas não pode ver as outras discussões privadas do grupo.

<!-- translation-section: set-up-a-private-submission-process -->

## Configurar um processo de envios privados

1. Crie um subgrupo específico para o processo de envio e defina sua privacidade como **Fechado**. Um subgrupo mantém os envios separados dos outros trabalhos do grupo principal.
2. Adicione a comissão de seleção ou outras pessoas responsáveis por avaliar os envios como membros do subgrupo. Todos os membros do subgrupo podem ver todos os envios, então adicione apenas pessoas que devem ter esse acesso.
3. Crie um [modelo de discussão](/en/user_manual/discussions/templates) no subgrupo. Inclua as perguntas e informações que as pessoas devem fornecer ao fazer um envio. Você pode criar diferentes modelos de discussão para diferentes tipos de envio.
4. Se as pessoas que fazem envios não devem solicitar participação no subgrupo, defina a participação como **Somente por convite**.
5. [Ative os envios privados](#enable-private-submissions) nas permissões do subgrupo.
6. Teste o processo com uma conta que não seja membro do subgrupo.
7. Compartilhe a página do subgrupo com as pessoas que poderão fazer envios. Elas precisam entrar em sua conta de usuário antes de fazer um envio.

<!-- translation-section: make-a-submission -->

## Fazer um envio

A pessoa que faz o envio abre o subgrupo e seleciona **Iniciar discussão**. O Loomio mostra os modelos de discussão disponíveis no subgrupo. A pessoa seleciona o modelo de discussão adequado, responde às perguntas e inicia a discussão.

A discussão pertence ao subgrupo, mas a pessoa que fez o envio não se torna membro dele. O Loomio a adiciona como convidado à conversa de discussão correspondente ao seu envio, permitindo que ela veja e participe da discussão com a comissão ou equipe de avaliação. Ela não pode ver outras discussões privadas ou envios no subgrupo.

<!-- translation-section: review-submissions -->

## Avaliar envios

Os membros do subgrupo podem ver todas as discussões de envio no subgrupo. Eles podem fazer perguntas complementares e usar comentários, enquetes ou outras ferramentas de discussão para concluir sua avaliação.

Se outra pessoa precisar fornecer informações, um membro do subgrupo com permissão pode convidá-la para a discussão do envio. Por exemplo, quando alguém envia uma indicação, o subgrupo pode convidar a pessoa indicada para a conversa se sua participação for necessária. A pessoa convidada entra como convidado sem obter acesso às outras discussões privadas do subgrupo.

Cada pessoa que faz um envio pode ver seu próprio envio, mas não pode ver as outras discussões privadas ou envios do subgrupo. Desative **Quem não é membro pode iniciar discussões.** quando o período de envios terminar. As discussões existentes e o acesso dos convidados permanecem inalterados.
