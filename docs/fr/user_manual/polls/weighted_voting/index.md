---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 587c38fe91f7144a
  set-members-vote-weights: d9c73feec2ef38bc
  use-weighted-voting-in-a-poll: a0ddcdb3920b5154
  results: 379d4043c20d1060
title: Vote pondéré
title_source: 0b971991dfcacbab
title_generated: 2f371212e65b0c61
source_revision: 3f73d4a156d9ffd3137ff085cc6ab58fbc4de46b
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-06'
---

<!-- translation-section: introduction -->

# Vote pondéré

Le vote pondéré permet à certains votes de compter davantage que d’autres. Chaque électeur a un poids du vote. Par exemple :

- Une communauté résidentielle attribue un vote à chaque propriété. Un membre qui représente trois propriétés a un poids du vote de `3`.
- Une coopérative de travailleurs accorde le droit de vote après une période définie d’adhésion. Les membres plus récents reçoivent un poids du vote de `0`, ce qui leur permet de contribuer à la discussion et de découvrir le processus de vote sans que leurs votes influencent le résultat.
- Une entreprise attribue des votes aux actionnaires selon leur participation au capital. Une personne qui détient 12,5 % des actions a un poids du vote de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Définir les poids des votes des membres

Un administrateur du groupe peut ouvrir la page **Membres** du groupe et sélectionner **Modifier les pondérations des votes**. Saisissez les poids des votes et sélectionnez **Sauvegarder les poids des votes**. Les poids des votes peuvent être égaux ou supérieurs à `0`, avec jusqu’à trois décimales. Recherchez une personne par son nom ou son adresse e-mail. Pour attribuer le même poids du vote à chaque membre, sélectionnez **Définir tous les poids de vote**.

![Poids des votes des membres du groupe](member-weights.png)

Le poids du vote d’un membre est copié dans chaque sondage auquel ce membre est ajouté. Le modifier par la suite ne change pas les sondages dans lesquels il a déjà été copié.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Utiliser le vote pondéré dans un sondage

Sélectionnez **Utiliser le vote pondéré** dans les paramètres avancés du sondage. Vous pouvez activer ou désactiver cette option après l’ouverture du vote. La désactiver fixe tous les poids des votes du sondage à `1`, et les poids des votes que vous avez modifiés pour ce sondage sont perdus.

Si votre groupe utilise le vote pondéré dans le cadre d’un processus établi, sélectionnez **Utiliser le vote pondéré** dans un [modèle de sondage](/en/user_manual/polls/poll_templates). Les sondages créés à partir de ce modèle utilisent le vote pondéré.

![Le paramètre Utiliser le vote pondéré dans un sondage](poll-setting.png)

Le vote pondéré fonctionne avec les types de sondages suivants : [Proposition](/en/user_manual/polls/proposals), [Choisir](/en/user_manual/polls/choose), [Noter](/en/user_manual/polls/score), [Répartir](/en/user_manual/polls/allocate) et [Classer](/en/user_manual/polls/rank).

Vous ne pouvez pas utiliser le vote pondéré et le [vote anonyme](/en/user_manual/polls/anonymous_voting) dans le même sondage.

Pour modifier le poids du vote d’un électeur, sélectionnez **Gérer les électeurs**, puis sélectionnez le poids du vote à côté de son nom. Pour modifier celui de tous les électeurs, sélectionnez **Définir tous les poids de vote**. Vous pouvez copier le poids du vote de chaque membre depuis le groupe ou attribuer la même valeur à tout le monde. Les électeurs qui ne sont pas membres du groupe reçoivent un poids du vote de `1`.

![Le bouton Gérer les électeurs dans un sondage](poll-manage-voters.png)

![Électeurs d’un sondage avec des poids des votes individuels](poll-voter-weights.png)

<!-- translation-section: results -->

## Résultats

Les résultats affichent côte à côte les totaux non pondérés et les totaux pondérés :

- Les sondages Proposition et Choisir affichent **Votes** et **Votes pondérés**.
- Les sondages Noter, Répartir et Classer affichent **Points** et **Points pondérés**.

Le graphique affiche le résultat pondéré. Sélectionnez l’en-tête d’une colonne pour afficher les données de cette colonne dans le graphique. Le nombre d’électeurs pouvant voter et le quorum sont calculés à partir du nombre de personnes, et non des poids des votes. Toute personne qui peut voir les votes peut voir le poids du vote de chaque électeur.

![Résultat d’une proposition avec les votes et les votes pondérés](weighted-proposal-result.png)
