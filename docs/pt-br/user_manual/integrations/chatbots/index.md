---
title: Integrações de bate-papo
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: 006210baba81b0ad
  what-it-looks-like-in-chat: c624361ec3361c06
  generate-a-webhook-url: 3706c186a8b88586
  set-up-a-chat-integration: b39462efff648620
  invite-to-poll: 1e463279274681f7
  automatic-notifications: b5e71472a6695026
title_source: 0eca19d30c6d7d3c
title_generated: e4e074d5772c2afb
---

<!-- translation-section: introduction -->

# Integrações de bate-papo

O Loomio pode enviar notificações para sua sala de bate-papo.

As ferramentas de bate-papo e o Loomio funcionam bem juntos. Use o bate-papo para conversas rápidas e atualizações oportunas. Leve assuntos importantes para o Loomio quando as pessoas precisarem de tempo para participar, quando for necessário tomar uma decisão ou quando o grupo precisar de um registro duradouro.

O Loomio oferece suporte a Slack, Discord, Microsoft Teams, Matrix e Mattermost.

Você pode enviar notificações para sua sala de bate-papo quando quiser, da mesma forma que convidaria pessoas individualmente para votar ou participar de uma conversa.

Você também pode configurar notificações para que sejam enviadas sempre que um evento específico ocorrer, como alguém iniciar uma conversa.

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

Nosso sistema baseado em webhooks também pode ser usado com outros sistemas que aceitam webhooks de entrada com formatação HTML ou Markdown, como Zapier ou Rocketchat.
Basta selecionar o bot do Mattermost e usar uma URL de webhook personalizada.

<!-- translation-section: set-up-a-chat-integration -->

## Configure uma integração de bate-papo

Depois de configurar o serviço escolhido (veja acima), você terá uma URL de webhook.
Abra **Integrações de bate-papo** no menu do grupo e adicione uma nova integração de bate-papo para seu grupo.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Por enquanto, você provavelmente não precisa marcar nenhuma das caixas de seleção. Basta inserir o nome (como "Discord #general") e a URL e clicar no botão de salvar na parte inferior do formulário.

![](loomio-chatbot-form.png)

Se você decidir mais tarde que deseja que a integração receba notificações automáticas, volte às configurações dela e selecione os eventos relevantes.

<!-- translation-section: invite-to-poll -->

### Convide para uma enquete

Veja como enviar uma notificação para sua sala de bate-papo convidando as pessoas a votar em uma proposta.
O processo é o mesmo para Compartilhar conclusão, Convidar para uma conversa, Lembrar de votar, Enquete editada etc.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notificações automáticas
Para enviar uma notificação sempre que um evento específico ocorrer, edite a integração de bate-papo e selecione esse evento.

![](chatbot_enable_automatic_notifications.png)
