---
title: Matrix
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 114ab8c916ca5fba
generated:
  introduction: d4495bd410c4c842
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Intégration Matrix

Loomio peut envoyer des notifications dans un salon Matrix lors de la création de discussions, de sondages, de commentaires, de votes et de conclusions. Vous devez être administrateur du groupe pour ajouter une intégration de chat.

Contrairement aux autres intégrations de chat de Loomio, Matrix n’utilise pas de webhook. Loomio se connecte avec un compte utilisateur Matrix qui agit comme un bot et publie des messages mis en forme dans votre salon.

Ce guide utilise le client Element.

---

1. Créez un compte utilisateur Matrix pour Loomio, connectez-vous à ce compte dans Element et invitez-le dans le salon Matrix où vous souhaitez recevoir les notifications. Gardez cette session ouverte — vous déconnecter invalide le jeton d’accès.

2. Dans votre groupe Loomio, ouvrez le menu du groupe, sélectionnez **Intégrations de chat** et ajoutez une intégration de chat **Matrice**.

   ![Menu du bot Matrix de Loomio](loomio-add-matrix-bot.png)

   ![Formulaire du bot Matrix de Loomio](loomio-matrix-bot-form.png)

3. Dans Element, ouvrez le menu du compte du bot et sélectionnez **Tous les paramètres**.

   ![Menu des paramètres Matrix](matrix-settings-menu.png)

4. Ouvrez **Aide et à propos** et faites défiler la page jusqu’à la section **Avancé**.

   ![Paramètres Matrix](matrix-settings.png)

5. Copiez le **Jeton d’accès** et collez-le dans le formulaire Loomio.

   ![Jeton d’accès Matrix](matrix-access-token.png)

6. Ouvrez le menu **Paramètres** du salon et accédez à **Avancé**.

   ![Paramètres du salon Matrix](matrix-room-settings.png)

7. Copiez l’**Identifiant interne du salon**, collez-le dans le formulaire Loomio et enregistrez l’intégration.

   ![Identifiant du salon Matrix](matrix-room-id.png)
