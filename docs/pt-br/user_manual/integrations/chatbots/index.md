---
title: Integrações de bate-papo
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: 9695d75ad7999740
  what-it-looks-like-in-chat: c624361ec3361c06
  generate-a-webhook-url: 8ce2a82f8384a6e7
  set-up-a-chat-integration: 54bab1d42773b974
  invite-to-poll: 9ae4989d4a383917
  automatic-notifications: 827098992b79b238
title_source: 0eca19d30c6d7d3c
title_generated: e4e074d5772c2afb
---

<!-- translation-section: introduction -->

# Integrações de bate-papo

O Loomio pode enviar notificações para sua sala de bate-papo.

As ferramentas de bate-papo e o Loomio funcionam bem juntos. Use o bate-papo para conversas rápidas e atualizações oportunas. Leve os assuntos importantes para o Loomio quando as pessoas precisarem de tempo para participar, quando for necessário tomar uma decisão ou quando o grupo precisar de um registro permanente.

O Loomio oferece suporte ao Slack, Discord, Microsoft Teams, Matrix e Mattermost.

Você pode enviar notificações para sua sala de bate-papo quando quiser, assim como convida pessoas para votar ou participar de uma discussão.

Você também pode configurar notificações automáticas para eventos específicos, como o início de uma discussão.

<!-- translation-section: what-it-looks-like-in-chat -->

## Como aparece no bate-papo
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Gere uma URL de webhook
Preparamos instruções passo a passo para cada serviço compatível. Siga as instruções do seu serviço para obter a URL de webhook necessária para adicionar a integração de bate-papo no Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

O sistema de webhooks também pode funcionar com outros serviços que aceitam webhooks de entrada formatados em HTML ou Markdown, como Zapier ou Rocketchat. Selecione o bot do Mattermost e use uma URL de webhook personalizada.

<!-- translation-section: set-up-a-chat-integration -->

## Configure uma integração de bate-papo

Depois de configurar o serviço escolhido (veja acima), você terá uma URL de webhook. Abra **Integrações de bate-papo** no menu do grupo e adicione uma nova integração de bate-papo ao grupo.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Por enquanto, deixe as caixas de seleção desmarcadas. Digite um nome (como "Discord #general") e a URL. Depois, selecione o botão para salvar no fim do formulário.

![](loomio-chatbot-form.png)

Se você quiser receber notificações automáticas mais tarde, volte às configurações da integração e selecione os eventos desejados.

<!-- translation-section: invite-to-poll -->

### Convide para votar

Para convidar as pessoas da sua sala de bate-papo a votar em uma proposta, envie uma notificação. O processo é o mesmo para Compartilhar conclusão, Convidar para uma discussão, Lembrar de votar, Enquete editada e outros eventos.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notificações automáticas
Para enviar uma notificação sempre que ocorrer um evento específico, edite a integração de bate-papo e selecione esse evento.

![](chatbot_enable_automatic_notifications.png)
