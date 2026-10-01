---
title: Exigences de répartition des votes
source_revision: 3a315412c646d254c8426be5c436a4e593f6011f
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: 4ee9c41cca2afb8b
  eligible-voters-and-votes-cast: 1d21e9803c64d6ff
  different-vote-share-requirements: 2da9c73753295eb3
  detailed-example: a8ed6f80a050d41c
title_source: a654891ca817844e
title_generated: '4123971380273484'
---

<!-- translation-section: introduction -->

# Exigences de répartition des votes

Définissez une exigence de répartition des votes pour une option lorsqu’une proposition doit obtenir un certain pourcentage de soutien, ou rester sous un certain pourcentage d’opposition, pour être adoptée.

Vous pouvez associer une exigence de répartition des votes à un [quorum](/en/user_manual/polls/quorum/) pour imposer à la fois une participation suffisante et une répartition précise des votes.

Dans le formulaire de proposition, sélectionnez l’icône de modification à côté d’une option.

![L’icône de modification à côté de l’option D’accord](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Électeurs éligibles et votes exprimés

Le pourcentage peut être calculé à partir des **Votes exprimés** ou des **Électeurs éligibles**.

![Choix entre les votes exprimés et les électeurs éligibles pour calculer l’exigence de répartition des votes](./eligible-vs-cast.png)

Les **Électeurs éligibles** sont toutes les personnes qui peuvent voter sur la proposition. Les **Votes exprimés** sont uniquement les votes soumis.

Une exigence de soutien de 75 % des électeurs éligibles ne peut être satisfaite que si au moins 75 % de ces personnes votent pour l’option.

Une exigence de soutien de 60 % des votes exprimés peut être satisfaite si 60 % des votes soumis soutiennent l’option, quel que soit le taux de participation. Ajoutez un quorum si votre processus exige aussi une participation minimale.

<!-- translation-section: different-vote-share-requirements -->

## Différentes exigences de répartition des votes

Une proposition peut comporter des exigences pour plusieurs options. Par exemple :

- L’accord doit atteindre au moins 75 % des électeurs éligibles
- L’abstention ne doit pas dépasser 30 % des votes exprimés
- L’opposition ne doit pas dépasser 0 % des votes exprimés

Définir une option sur **Pas plus de 0 %** est une pratique courante. Cela signifie que la proposition ne peut pas être adoptée si une personne choisit cette option. Appliquez cette exigence à l’option **Contre** pour qu’un seul vote pour cette option bloque la proposition.

Vous pouvez aussi ajouter des exigences à un [modèle de sondage](/en/user_manual/polls/poll_templates/). Elles s’appliqueront par défaut aux nouvelles propositions créées à partir de ce modèle.

<!-- translation-section: detailed-example -->

## Exemple détaillé

La coopérative Oatmilk doit décider si elle lance un essai de bouteilles consignées de six semaines. Cinq personnes peuvent voter.

Le processus de la coopérative exige l’accord d’au moins 75 % des électeurs éligibles. Jamie modifie l’option **D’accord** de la proposition, active son exigence de répartition des votes et la définit sur **Au moins 75 % des Électeurs éligibles**.

![L’option D’accord exigeant le soutien d’au moins 75 % des électeurs éligibles](./agree-vote-option.png)

Jamie fixe aussi un quorum de 60 %. Jamie et Samira votent pour la proposition. Tous les votes soumis la soutiennent, mais ils ne représentent que 40 % des électeurs éligibles. Aucune des deux exigences n’est donc satisfaite.

![Deux personnes sur cinq ont voté pour la proposition et aucune exigence n’est satisfaite](./first-vote-breakdown.png)

Alex et Morgan votent ensuite pour la proposition, tandis que Taylor vote contre. Les cinq personnes ont voté : le quorum est atteint et quatre des cinq électeurs éligibles soutiennent la proposition. Ce soutien de 80 % dépasse l’exigence de 75 %, et une coche verte apparaît pour chacune des deux exigences.

![Les cinq personnes ont voté et les deux exigences sont satisfaites](./final-vote-breakdown.png)
