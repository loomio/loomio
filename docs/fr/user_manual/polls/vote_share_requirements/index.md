---
title: Exigences de répartition des votes
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: 96509c1428154ac7
  eligible-voters-and-votes-cast: 430a152312bcfc94
  different-vote-share-requirements: 96b04d1fc90f32e5
  detailed-example: dc9c34c7ef7ab485
title_source: a654891ca817844e
title_generated: '4123971380273484'
---

<!-- translation-section: introduction -->

# Exigences de répartition des votes

Définissez une exigence de répartition des votes pour une option lorsqu’une proposition doit recueillir un pourcentage précis de soutien, ou rester en dessous d’un pourcentage précis d’opposition, pour être adoptée.

Les exigences de répartition des votes peuvent être combinées avec un [quorum](/en/user_manual/polls/quorum/) pour exiger à la fois une participation suffisante et une répartition précise des votes.

Dans le formulaire de proposition, cliquez sur l’icône de modification à côté d’une option.

![L’icône de modification à côté de l’option Accord](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Électeurs éligibles et votes exprimés

Le pourcentage peut être calculé à partir des **Votes exprimés** ou des **Électeurs éligibles**.

![Choix entre les votes exprimés et les électeurs éligibles comme base de calcul d’une exigence de répartition des votes](./eligible-vs-cast.png)

**Électeurs éligibles** désigne toutes les personnes qui peuvent voter sur la proposition. **Votes exprimés** désigne uniquement les votes qui ont été soumis.

Une exigence de 75 pour cent d’accord parmi les électeurs éligibles ne peut être satisfaite que si au moins 75 pour cent de l’ensemble des électeurs éligibles votent pour cette option.

Une exigence de 60 pour cent d’accord parmi les votes exprimés peut être satisfaite lorsque 60 pour cent des votes soumis soutiennent l’option, quel que soit le taux de participation global. Ajoutez un quorum si votre processus exige également un niveau minimum de participation.

<!-- translation-section: different-vote-share-requirements -->

## Différentes exigences de répartition des votes

Une proposition peut comporter des exigences pour plusieurs options. Par exemple :

- L’accord doit représenter au moins 75 pour cent des électeurs éligibles
- L’abstention doit représenter au maximum 30 pour cent des votes exprimés
- Le blocage doit représenter au maximum 0 pour cent des votes exprimés

Définir une option sur **Au maximum 0 %** est une pratique courante. Cela signifie que la proposition ne peut pas être adoptée si une personne choisit cette option. Appliquez ce réglage à **Blocage** pour qu’un seul blocage empêche l’adoption de la proposition.

Vous pouvez également ajouter des exigences à un [modèle de sondage](/en/user_manual/polls/poll_templates/) pour que les nouvelles propositions créées à partir de ce modèle les utilisent par défaut.

<!-- translation-section: detailed-example -->

## Exemple détaillé

La coopérative Oatmilk doit décider si elle souhaite mener un essai de bouteilles consignées pendant six semaines. Cinq personnes sont éligibles au vote.

Le processus de la coopérative exige qu’au moins 75 pour cent des électeurs éligibles expriment leur accord. Jamie modifie l’option **D’accord** de la proposition, active son exigence de répartition des votes et la définit sur **Au moins 75 % des Électeurs éligibles**.

![L’option Accord exigeant l’accord d’au moins 75 pour cent des électeurs éligibles](./agree-vote-option.png)

Jamie définit également un quorum de 60 pour cent. Jamie et Samira votent Accord. Tous les votes soumis soutiennent la proposition, mais ils ne représentent que 40 pour cent des électeurs éligibles. Aucune des deux exigences n’est donc satisfaite.

![Deux personnes sur cinq ont voté Accord et aucune des deux exigences n’est satisfaite](./first-vote-breakdown.png)

Alex et Morgan votent ensuite Accord, tandis que Taylor vote Désaccord. Les cinq personnes ont voté, ce qui permet d’atteindre le quorum, et quatre électeurs éligibles sur cinq ont exprimé leur accord. Le taux d’accord de 80 pour cent dépasse l’exigence de répartition des votes de 75 pour cent. Les deux exigences affichent donc des coches vertes.

![Les cinq personnes ont voté et les deux exigences sont satisfaites](./final-vote-breakdown.png)
