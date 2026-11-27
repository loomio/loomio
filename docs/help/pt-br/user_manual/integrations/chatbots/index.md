---
title: Integrações de bate-papo
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: 5a727120f9967d49
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: '09c06423f5f38dfd'
  what-it-looks-like-in-chat: 575645dc67f7d15b
  generate-a-webhook-url: 0f64dcce5e57ea5b
  set-up-a-chat-integration: a937e465f093e164
  invite-to-poll: bb83ed7b8e4ca91a
  automatic-notifications: 97d7ba26ea3ca897
title_source: 0eca19d30c6d7d3c
title_generated: e4e074d5772c2afb
---

<!-- translation-section: introduction -->

# Integrações de bate-papo

O Loomio pode enviar notificações para sua sala de bate-papo.

As ferramentas de bate-papo e o Loomio funcionam bem juntos. Use o bate-papo para conversas rápidas e atualizações oportunas. Leve assuntos importantes para o Loomio quando as pessoas precisarem de tempo para participar, quando for necessário tomar uma decisão ou quando o grupo precisar de um registro duradouro.

O Loomio oferece suporte a Slack, Discord, Microsoft Teams, Matrix e Mattermost.

Você pode enviar notificações manualmente para sua sala de bate-papo sempre que convidar pessoas para uma conversa ou enquete. Você também pode configurar notificações automáticas para eventos específicos, como quando alguém inicia uma discussão.

<!-- translation-section: what-it-looks-like-in-chat -->

## Como aparece no bate-papo

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Conecte seu serviço de bate-papo

Siga o guia do seu serviço de bate-papo para obter uma URL de webhook (ou, no caso do Matrix, um token de acesso do bot e o ID da sala):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Você também pode conectar outros serviços que aceitam webhooks de entrada com formatação HTML ou Markdown, como Zapier ou Rocket.Chat. Escolha a integração de bate-papo **Mais importante** no Loomio e insira sua URL de webhook personalizada.

<!-- translation-section: set-up-a-chat-integration -->

## Configure uma integração de bate-papo

Você precisa ser admin do grupo para adicionar ou editar integrações de bate-papo.

1. Depois de configurar seu serviço de bate-papo (veja acima), abra **Configurações** na página do seu grupo no Loomio e selecione **Integrações de bate-papo**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Adicione uma nova integração de bate-papo para seu serviço, insira um nome (como "Discord #general") e cole a URL de webhook.

   ![](loomio-chatbot-form.png)

3. Selecione os eventos que você deseja enviar automaticamente ou deixe todos desmarcados se quiser enviar notificações apenas manualmente e salve. Você pode alterar essas configurações a qualquer momento.

<!-- translation-section: invite-to-poll -->

### Envie uma notificação manualmente

Para notificar sua sala de bate-papo sobre uma enquete ou discussão, abra o item e selecione **Convidar** (ou outra ação de notificação, como **Compartilhar conclusão**, **Lembrar de votar** ou **Enquete editada**). Selecione sua integração de bate-papo na lista de destinatários e envie a notificação.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notificações automáticas

Para enviar uma notificação sempre que um evento específico ocorrer, edite a integração de bate-papo e selecione esse evento.

![](chatbot_enable_automatic_notifications.png)
