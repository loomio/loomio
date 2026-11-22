---
title: Receber envios privados
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 4ec7d13335b07a50
  enable-private-submissions: dd5106b8411a85ba
  set-up-a-private-submission-process: cb0361b8044af3e3
  make-a-submission: c04bd9ef30f8db97
  review-submissions: 267be9e3c705c196
generated:
  introduction: '059c8cfb4c8f15ea'
  enable-private-submissions: 98894661f186bd99
  set-up-a-private-submission-process: 1e231cfdaeb7d3df
  make-a-submission: 6e97e3b1db472abc
  review-submissions: e0dca33100b4c96d
title_source: e82ab76916d594f4
title_generated: 88dd08426aa0fb1d
---

<!-- translation-section: introduction -->

# Receber envios privados

Use um grupo fechado para receber envios privados de pessoas de fora do grupo. Cada envio se torna uma discussão separada onde a pessoa que fez o envio e a equipe de avaliação podem trocar informações, fazer perguntas e registrar uma decisão. Quem faz um envio não pode ver outras discussões privadas ou envios no grupo.

Isso funciona bem para indicações quando os detalhes dos candidatos ou a lista de pessoas indicadas devem permanecer privados durante a seleção. Uma pessoa pode indicar a si mesma ou outra pessoa para uma eleição ou para uma função em um comitê ou conselho, enquanto a comissão de seleção avalia cada indicação em sua própria conversa.

Outros usos comuns incluem:

- Reclamações, relatos sobre proteção de pessoas vulneráveis, preocupações com segurança e relatos de incidentes
- Recursos e pedidos de reconsideração de uma decisão sobre um caso individual
- Pedidos de mediação, resolução de conflitos ou apoio pessoal
- Solicitações com informações pessoais, financeiras ou sobre critérios de elegibilidade, como pedidos de auxílio financeiro ou bolsas de estudo
- Propostas sigilosas ou respostas a licitações que devem permanecer privadas durante a avaliação

Neste processo, os envios são privados entre as pessoas que os fazem, mas não são anônimos. Quem faz um envio precisa de uma conta de usuário, e todos os membros do grupo fechado podem ver todos os envios. Verifique quem faz parte do grupo antes de usá-lo para informações sensíveis.

<!-- translation-section: enable-private-submissions -->

## Ativar envios privados

Você deve ser admin do grupo ou subgrupo onde deseja receber envios.

1. Abra o grupo.
2. Selecione **Configurações** (ou **Mais**, depois **Editar configurações do grupo**).
3. Abra **Permissões**.
4. Ative **Quem não é membro pode iniciar discussões.**
5. Salve as configurações do grupo.

![A aba Permissões nas configurações do grupo, com Quem não é membro pode iniciar discussões em destaque](non_members_can_start_discussions.png)

Esta opção aparece apenas em grupos do tipo **Aberto** e **Fechado**, e não em grupos do tipo **Secreto**. Se você não conseguir vê-la, abra **Privacidade** nas configurações do grupo, defina **Privacidade do grupo** como **Fechado** (recomendado para envios privados) ou **Aberto** e volte para **Permissões**.

Ativar esta permissão não torna públicas as discussões do grupo. Quem não é membro pode iniciar uma discussão e acessar essa conversa como convidado, mas não pode ver outras discussões privadas no grupo.

<!-- translation-section: set-up-a-private-submission-process -->

## Configurar um processo de envios privados

1. Crie um subgrupo específico para os envios e defina sua privacidade como **Fechado**. Um subgrupo mantém os envios separados dos outros trabalhos do grupo principal.
2. Adicione a equipe de avaliação ou a comissão de seleção como membros do subgrupo. Todos os membros do subgrupo podem ver todos os envios, então adicione apenas pessoas que precisam de acesso.
3. Crie um ou mais [modelos de discussão](/en/user_manual/discussions/templates) no subgrupo com as perguntas e os detalhes que as pessoas devem fornecer ao fazer um envio.
4. Defina a participação como **Somente por convite** se as pessoas que fazem envios não devem solicitar participação no subgrupo.
5. [Ative os envios privados](#enable-private-submissions) nas permissões do subgrupo.
6. Teste o processo com uma conta que não seja membro do subgrupo.
7. Compartilhe a página do subgrupo com as pessoas que farão envios. Elas precisam entrar em uma conta de usuário antes de fazer um envio.

<!-- translation-section: make-a-submission -->

## Fazer um envio

A pessoa que faz o envio abre o subgrupo e seleciona **Iniciar discussão**. O Loomio mostra os modelos de discussão do subgrupo. A pessoa escolhe o modelo adequado, responde às perguntas e inicia a discussão.

A discussão pertence ao subgrupo, e o Loomio adiciona a pessoa que fez o envio como convidada nessa conversa, sem torná-la membro do subgrupo. Ela pode participar de sua própria conversa com a equipe de avaliação, mas não pode ver outras discussões privadas ou envios no subgrupo.

<!-- translation-section: review-submissions -->

## Avaliar envios

Os membros do subgrupo podem ver todas as conversas de envio no subgrupo. Eles podem fazer perguntas complementares e usar comentários, enquetes ou outras ferramentas para concluir a avaliação.

Se outra pessoa precisar contribuir, um membro do subgrupo com permissão pode convidá-la para essa conversa. Por exemplo, depois que alguém envia uma indicação, a comissão pode convidar a pessoa indicada para a conversa. A pessoa convidada entra como convidada sem obter acesso a outras discussões privadas no subgrupo.

Quando o período de envios terminar, desative **Quem não é membro pode iniciar discussões.** As conversas de envio existentes e o acesso dos convidados permanecem inalterados.
