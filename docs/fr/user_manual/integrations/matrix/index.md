---
title: Matrix
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 80595a38c50e83cb
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Intégration Matrix

Loomio peut envoyer des notifications dans vos salons Matrix lors de nouvelles discussions, propositions, commentaires, votes et conclusions.

Matrix accepte certains éléments HTML dans les salons de discussion, que Loomio utilise pour présenter ses notifications.

L’intégration Matrix fonctionne différemment des autres intégrations de chat de Loomio : elle utilise un robot dédié plutôt qu’un webhook.

Vous devez créer un compte Matrix que le robot utilisera pour se connecter.

Une fois le compte créé, connectez-vous avec ce compte pour obtenir les informations suivantes.

Ce guide utilise Element.

---

Dans votre groupe Loomio, ajoutez une intégration de chat Matrix
![menu du robot Matrix dans Loomio](loomio-add-matrix-bot.png)

Remplissez ce formulaire
![formulaire du robot Matrix dans Loomio](loomio-matrix-bot-form.png)

Pour trouver votre jeton d’accès, ouvrez ce menu
![menu des paramètres Matrix](matrix-settings-menu.png)

Voici la page des paramètres
![paramètres Matrix](matrix-settings.png)

Voici le jeton d’accès
![jeton d’accès Matrix](matrix-access-token.png)

Vous avez maintenant besoin de l’identifiant du salon
![paramètres du salon Matrix](matrix-room-settings.png)

Voici l’identifiant du salon
![identifiant du salon Matrix](matrix-room-id.png)
