---
sections:
  introduction: 566ce8dda668a638
  set-members-vote-weights: 2a3d29ebb9840017
  use-weighted-voting-in-a-poll: feddef738da4567d
  results: ab86e178359702a0
generated:
  introduction: 05c6976a2059a073
  set-members-vote-weights: 9b5065b02a503136
  use-weighted-voting-in-a-poll: 588bfc85678aa7b7
  results: bdc6665f1d799905
title: Vote pondéré
title_source: 0b971991dfcacbab
title_generated: 2f371212e65b0c61
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
---

<!-- translation-section: introduction -->

# Vote pondéré

Le vote pondéré permet à certains votes de compter davantage que d’autres en attribuant un poids du vote à chaque électeur. Par exemple :

- Une communauté résidentielle attribue un vote à chaque propriété. Un membre qui représente trois propriétés a un poids du vote de `3`.
- Une coopérative de travailleurs accorde le droit de vote après une période définie d’adhésion. Les membres plus récents reçoivent un poids du vote de `0`, ce qui leur permet de participer à la discussion et d’essayer de voter sans influencer le résultat.
- Une entreprise attribue des votes aux actionnaires selon leur participation au capital. Une personne qui détient 12,5 % des actions a un poids du vote de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Définir les poids des votes des membres

Un administrateur du groupe peut ouvrir la page **Membres** du groupe et sélectionner **Modifier les pondérations des votes**. Saisissez les poids des votes (`0` ou plus, avec jusqu’à trois décimales) et sélectionnez **Sauvegarder les poids des votes**. Vous pouvez rechercher une personne par son nom ou son adresse e-mail, ou sélectionner **Définir tous les poids de vote** pour attribuer le même poids du vote à chaque membre.

![Poids des votes des membres du groupe](member-weights.png)

Le poids du vote d’un membre est copié dans chaque sondage auquel ce membre est ajouté. Le modifier par la suite n’affecte pas les sondages existants.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Utiliser le vote pondéré dans un sondage

Ouvrez **Plus de paramètres** dans le formulaire du sondage et sélectionnez **Utiliser le vote pondéré**. Vous pouvez activer ou désactiver le vote pondéré après l’ouverture du vote. Le désactiver réinitialise tous les poids des votes du sondage à `1`, et les poids des votes personnalisés pour ce sondage sont perdus.

Si votre groupe utilise le vote pondéré dans le cadre d’un processus régulier, activez **Utiliser le vote pondéré** dans un [modèle de sondage](/en/user_manual/polls/poll_templates). Les sondages créés à partir de ce modèle utiliseront le vote pondéré par défaut.

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

Le graphique affiche le résultat pondéré. Sélectionnez l’en-tête d’une colonne pour afficher les données de cette colonne dans le graphique. Toute personne qui peut voir les votes peut voir le poids du vote de chaque électeur.

Pour les sondages Proposition et Choisir, la ligne **N’a pas voté** affiche le nombre d’électeurs qui n’ont pas encore voté dans la colonne **Votes** et le poids total de leurs votes dans la colonne **Votes pondérés**. Ces colonnes et **% du poids des votes éligibles** incluent les personnes qui n’ont pas voté dans le graphique. **% du poids des votes exprimés** laisse la ligne **N’a pas voté** vide et l’exclut du graphique.

Les poids des votes s’appliquent également au [quorum](/en/user_manual/polls/quorum) et aux [exigences de part des votes](/en/user_manual/polls/vote_share_requirements).

Dans l’exemple ci-dessous, Jamie vote **D’accord** avec un poids du vote de `2`. Trois personnes votent **Désaccord**, avec des poids des votes de `1`, `0` et `0`. Deux personnes, dont les poids des votes sont de `2` et `1`, n’ont pas voté.

L’option Accord recueille un des quatre votes exprimés, mais deux tiers du poids des votes exprimés. La moitié du poids des votes admissibles a participé au vote : le quorum de 60 pour cent n’a donc pas été atteint.

![Résultat d’une proposition avec les votes et les votes pondérés](weighted-proposal-result.png)
