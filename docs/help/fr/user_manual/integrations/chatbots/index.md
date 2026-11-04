---
title: Intégrations de chat
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
  introduction: 752018083fd07b3c
  what-it-looks-like-in-chat: 97df69f8165c4f39
  generate-a-webhook-url: 469021be7cf52cca
  set-up-a-chat-integration: 3b9bbadc96845110
  invite-to-poll: d0bbb6eb12b7f3c3
  automatic-notifications: 2ecaa74eab422faf
title_source: 0eca19d30c6d7d3c
title_generated: 2de768eea2917047
---

<!-- translation-section: introduction -->

# Intégrations de chat

Loomio peut envoyer des notifications à votre salon de chat.

Les outils de chat et Loomio se complètent bien. Utilisez le chat pour les échanges rapides et les informations à communiquer sans attendre. Déplacez les sujets importants vers Loomio lorsque les personnes ont besoin de temps pour participer, lorsqu’une décision doit être prise ou lorsque le groupe aura besoin de conserver une trace des échanges.

Loomio prend en charge Slack, Discord, Microsoft Teams, Matrix et Mattermost.

Vous pouvez envoyer des notifications à votre salon de chat à tout moment, de la même manière que vous inviteriez des personnes à voter ou à rejoindre un fil.

Vous pouvez aussi configurer les notifications pour qu’elles soient envoyées chaque fois qu’un événement précis se produit, par exemple lorsqu’une personne crée un fil.

<!-- translation-section: what-it-looks-like-in-chat -->

## Aperçu dans le chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Générer une URL de webhook
Nous avons préparé des guides étape par étape pour chaque service pris en charge. Suivez le guide correspondant à votre service pour obtenir l’URL de webhook nécessaire à l’ajout de l’intégration de chat dans Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Notre système de webhooks peut également fonctionner avec d’autres systèmes qui prennent en charge les webhooks entrants au format HTML ou Markdown, comme Zapier ou Rocketchat.

Sélectionnez simplement le bot Mattermost et utilisez une URL de webhook personnalisée.

<!-- translation-section: set-up-a-chat-integration -->

## Configurer une intégration de chat

Après avoir configuré le service de votre choix (voir ci-dessus), vous disposerez d’une URL de webhook.

Ouvrez **Intégrations de chat** dans le menu du groupe et ajoutez une nouvelle intégration de chat pour votre groupe.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Vous n’aurez probablement pas besoin de cocher les cases pour le moment. Saisissez simplement le nom (par exemple « Discord #general ») et l’URL, puis cliquez sur le bouton Enregistrer en bas du formulaire.

![](loomio-chatbot-form.png)

Si vous souhaitez par la suite que l’intégration reçoive des notifications automatiques, revenez dans ses paramètres et sélectionnez les événements concernés.

<!-- translation-section: invite-to-poll -->

### Inviter à un sondage

Voici comment envoyer une notification à votre salon de chat pour inviter les personnes à voter sur une proposition.

La procédure est la même pour Partager la conclusion, Inviter à un fil, Rappeler de voter, Sondage modifié, etc.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notifications automatiques
Pour envoyer une notification chaque fois qu’un événement précis se produit, modifiez l’intégration de chat et sélectionnez cet événement.

![](chatbot_enable_automatic_notifications.png)
