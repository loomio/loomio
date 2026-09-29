---
title: Intégrations de chat
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
  introduction: 806d0c117b781562
  what-it-looks-like-in-chat: 97df69f8165c4f39
  generate-a-webhook-url: 636413b11180df86
  set-up-a-chat-integration: 36cc867c24a1ea27
  invite-to-poll: bd9c165c9cc54c3b
  automatic-notifications: bb5383049d02406a
title_source: 0eca19d30c6d7d3c
title_generated: 2de768eea2917047
---

<!-- translation-section: introduction -->

# Intégrations de chat

Loomio peut envoyer des notifications dans votre salon de discussion.

Les outils de chat et Loomio se complètent. Utilisez le chat pour les échanges rapides et les nouvelles à partager sans attendre. Ouvrez une discussion dans Loomio lorsque les personnes ont besoin de temps pour participer, qu'une décision doit être prise ou que le groupe doit conserver une trace des échanges.

Loomio prend en charge Slack, Discord, Microsoft Teams, Matrix et Mattermost.

Vous pouvez envoyer une notification dans votre salon de discussion à tout moment, comme vous inviteriez des personnes à voter ou à rejoindre une discussion.

Vous pouvez aussi configurer l'envoi automatique de notifications pour certains événements, par exemple lorsqu'une personne ouvre une discussion.

<!-- translation-section: what-it-looks-like-in-chat -->

## Aperçu dans le chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Générer une URL de webhook
Nous avons préparé des guides détaillés pour chaque service pris en charge. Suivez le guide correspondant à votre service pour obtenir l'URL de webhook nécessaire à la configuration de l'intégration de chat dans Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Notre système de webhooks peut aussi fonctionner avec d'autres services qui acceptent les webhooks entrants au format HTML ou Markdown, comme Zapier ou Rocketchat. Sélectionnez le bot Mattermost et indiquez une URL de webhook personnalisée.

<!-- translation-section: set-up-a-chat-integration -->

## Configurer une intégration de chat

Une fois le service de votre choix configuré (voir ci-dessus), vous disposerez d'une URL de webhook. Dans le menu du groupe, ouvrez **Intégrations de chat** et ajoutez une intégration de chat pour votre groupe.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Pour le moment, laissez les cases décochées. Saisissez un nom (par exemple « Discord #general ») et l'URL, puis cliquez sur le bouton **Enregistrer** en bas du formulaire.

![](loomio-chatbot-form.png)

Si vous souhaitez recevoir des notifications automatiques plus tard, retournez dans les paramètres de l'intégration et sélectionnez les événements concernés.

<!-- translation-section: invite-to-poll -->

### Inviter au vote

Voici comment envoyer dans votre salon de discussion une notification invitant les personnes à voter sur une proposition. La procédure est la même pour **Partager la conclusion**, **Inviter à la discussion**, **Rappeler de voter**, **Sondage modifié**, etc.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notifications automatiques
Pour envoyer une notification chaque fois qu'un événement donné se produit, modifiez l'intégration de chat et sélectionnez cet événement.

![](chatbot_enable_automatic_notifications.png)
