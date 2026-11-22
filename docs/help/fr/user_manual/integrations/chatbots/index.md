---
title: Intégrations de chat
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: d671b54fe6ae3cd1
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: 8b6de082f26f8c36
  what-it-looks-like-in-chat: e8e6aaebca84d7b9
  generate-a-webhook-url: c86f13133ad182a2
  set-up-a-chat-integration: ca4c549b055eb858
  invite-to-poll: 6daba8e5bf340965
  automatic-notifications: de1d1467c2bf5f8f
title_source: 0eca19d30c6d7d3c
title_generated: 2de768eea2917047
---

<!-- translation-section: introduction -->

# Intégrations de chat

Loomio peut envoyer des notifications à votre salon de chat.

Les outils de chat et Loomio se complètent bien. Utilisez le chat pour les échanges rapides et les informations à communiquer sans attendre. Déplacez les sujets importants vers Loomio lorsque les personnes ont besoin de temps pour participer, lorsqu’une décision doit être prise ou lorsque le groupe a besoin de conserver une trace des échanges.

Loomio prend en charge Slack, Discord, Microsoft Teams, Matrix et Mattermost.

Vous pouvez envoyer manuellement des notifications à votre salon de chat chaque fois que vous invitez des personnes à rejoindre un fil ou à participer à un sondage. Vous pouvez aussi configurer des notifications automatiques pour des événements précis, par exemple lorsqu’une personne lance une discussion.

<!-- translation-section: what-it-looks-like-in-chat -->

## Aperçu dans le chat

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Connecter votre service de chat

Suivez le guide correspondant à votre service de chat pour obtenir une URL de webhook (ou, pour Matrix, un jeton d’accès de bot et un identifiant de salon) :

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Vous pouvez aussi connecter d’autres services qui acceptent les webhooks entrants au format HTML ou Markdown, comme Zapier ou Rocket.Chat. Choisissez l’intégration de chat **Ce qui compte le plus** dans Loomio et saisissez votre URL de webhook personnalisée.

<!-- translation-section: set-up-a-chat-integration -->

## Configurer une intégration de chat

Vous devez être administrateur du groupe pour ajouter ou modifier des intégrations de chat.

1. Après avoir configuré votre service de chat (voir ci-dessus), ouvrez le menu du groupe dans Loomio et sélectionnez **Intégrations de chat**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Ajoutez une nouvelle intégration de chat pour votre service, saisissez un nom (par exemple « Discord #general ») et collez l’URL de webhook.

   ![](loomio-chatbot-form.png)

3. Sélectionnez les événements pour lesquels vous souhaitez envoyer automatiquement des notifications, ou laissez-les désélectionnés si vous souhaitez uniquement envoyer des notifications manuellement, puis enregistrez. Vous pouvez modifier ces paramètres à tout moment.

<!-- translation-section: invite-to-poll -->

### Envoyer une notification manuellement

Pour informer votre salon de chat d’un sondage ou d’une discussion, ouvrez l’élément concerné et sélectionnez **Inviter** (ou une autre action de notification comme **Partager la conclusion**, **Rappel pour voter** ou **Sondage modifié**). Sélectionnez votre intégration de chat dans la liste des destinataires et envoyez la notification.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notifications automatiques

Pour envoyer une notification chaque fois qu’un événement précis se produit, modifiez l’intégration de chat et sélectionnez cet événement.

![](chatbot_enable_automatic_notifications.png)
