---
title: Matrix
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: f41624088de401eb
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Intégration Matrix

Loomio peut envoyer des notifications dans vos canaux Matrix lors de la création de discussions, de propositions, de commentaires, de votes et de conclusions.

Matrix autorise certaines balises HTML dans les salons de discussion, et Loomio utilise cette possibilité.

Notre intégration Matrix diffère légèrement de nos autres intégrations de messagerie : elle n’utilise pas de webhook. Nous avons développé un client de bot spécifique pour cette intégration.

Vous devez créer un compte Matrix avec lequel le bot pourra se connecter.

Une fois ce compte créé, connectez-vous avec ce compte pour obtenir les informations suivantes.

Nous utilisons Element dans ce guide.

---

Depuis votre groupe Loomio, ajoutez une intégration de messagerie Matrix
![Menu du bot Matrix de Loomio](loomio-add-matrix-bot.png)

Voici le formulaire à remplir
![Formulaire du bot Matrix de Loomio](loomio-matrix-bot-form.png)

Voici où commencer pour trouver votre jeton d’accès
![Menu des paramètres Matrix](matrix-settings-menu.png)

Voici la page des paramètres
![Paramètres Matrix](matrix-settings.png)

Voici le jeton d’accès
![Jeton d’accès Matrix](matrix-access-token.png)

Vous avez maintenant besoin de l’identifiant du salon
![Paramètres du salon Matrix](matrix-room-settings.png)

Le voici.
![Identifiant du salon Matrix](matrix-room-id.png)
