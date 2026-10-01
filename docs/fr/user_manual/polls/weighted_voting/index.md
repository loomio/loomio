---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: d2d111dca36797a5
  set-members-vote-weights: b527fd7b23d21d37
  use-weighted-voting-in-a-poll: 98b9f1bd9424c581
  results: 7c605f1de22aa454
title: Vote pondéré
title_source: 0b971991dfcacbab
title_generated: 2f371212e65b0c61
source_revision: 3a315412c646d254c8426be5c436a4e593f6011f
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Vote pondéré

Le vote pondéré permet à certains votes de compter davantage que d’autres. Chaque électeur a un poids de vote. Par exemple :

- Une communauté d’habitat attribue une voix à chaque propriété. Un membre qui représente trois propriétés a un poids de vote de `3`.
- Le conseil d’administration d’une coopérative prend la décision, mais le personnel opérationnel participe à la discussion. Les membres du conseil ont un poids de vote de `1`. Le personnel opérationnel a un poids de vote de `0` : ses votes sont donc enregistrés, mais ne modifient pas le résultat.
- Une entreprise attribue des voix aux actionnaires en fonction de leur participation au capital. Une personne qui détient 12,5 % des actions a un poids de vote de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Définir les poids de vote des membres

Un administrateur du groupe peut ouvrir la page **Membres** du groupe et sélectionner **Modifier les pondérations des votes**. Saisissez les poids de vote et sélectionnez **Sauvegarder les poids des votes**. Les poids de vote peuvent être égaux ou supérieurs à `0`, avec jusqu’à trois décimales. Recherchez une personne par son nom ou son adresse e-mail. Pour attribuer le même poids de vote à chaque membre, sélectionnez **Définir tous les poids de vote**.

![Poids de vote des membres du groupe](member-weights.png)

Le poids de vote d’un membre est copié dans chaque sondage auquel ce membre est ajouté. Une modification ultérieure de ce poids ne modifie pas les sondages dans lesquels il a déjà été copié.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Utiliser le vote pondéré dans un sondage

Sélectionnez **Utiliser le vote pondéré** dans les paramètres avancés du sondage. Vous pouvez activer ou désactiver cette option après l’ouverture du vote. Sa désactivation fixe tous les poids de vote du sondage à `1`, et tous les poids de vote que vous avez modifiés pour ce sondage sont perdus.

Si votre groupe utilise le vote pondéré dans le cadre d’un processus établi, sélectionnez **Utiliser le vote pondéré** dans un [modèle de sondage](/en/user_manual/polls/poll_templates). Les sondages lancés à partir de ce modèle utilisent le vote pondéré.

![Le paramètre Utiliser le vote pondéré dans un sondage](poll-setting.png)

Le vote pondéré fonctionne avec les types de sondage suivants : [Proposition](/en/user_manual/polls/proposals), [Choisir](/en/user_manual/polls/choose), [Score](/en/user_manual/polls/score), [Allouer](/en/user_manual/polls/allocate) et [Rang](/en/user_manual/polls/rank).

Vous ne pouvez pas utiliser le vote pondéré et le [vote anonyme](/en/user_manual/polls/anonymous_voting) dans un même sondage.

Pour modifier le poids de vote d’un électeur, sélectionnez **Gérer les électeurs**, puis sélectionnez le poids de vote à côté de son nom. Pour modifier les poids de vote de tous les électeurs, sélectionnez **Définir tous les poids de vote**. Vous pouvez reprendre le poids de vote de chaque membre défini dans le groupe, ou attribuer la même valeur à tout le monde. Les électeurs qui ne sont pas membres du groupe reçoivent un poids de vote de `1`.

![Le bouton Gérer les électeurs dans un sondage](poll-manage-voters.png)

![Les électeurs d’un sondage avec leurs poids de vote individuels](poll-voter-weights.png)

<!-- translation-section: results -->

## Résultats

Les résultats affichent les totaux non pondérés et les totaux pondérés côte à côte :

- Les sondages de type Proposition et Choisir affichent **Votes** et **Votes pondérés**.
- Les sondages de type Score, Allouer et Rang affichent **Points** et **Points pondérés**.

Le graphique affiche le résultat pondéré. Sélectionnez un en-tête de colonne pour afficher les données de cette colonne dans le graphique. Le nombre d’électeurs ayant le droit de voter et le quorum sont calculés en nombre de personnes, sans tenir compte des poids de vote. Toute personne qui peut voir les votes peut voir le poids de vote de chaque électeur.

![Le résultat d’une proposition avec les votes et les votes pondérés](weighted-proposal-result.png)
