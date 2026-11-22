---
title: Quorum
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 885a154beca10592
  example-scenario: 2c4be2012a2bcba4
generated:
  introduction: d323aabb628907e8
  example-scenario: e7296afa45ad4d70
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Un quorum est le pourcentage minimum d’électeurs habilités à voter qui doivent participer pour qu’un sondage soit valide. Utilisez-le lorsque votre processus de décision exige un niveau minimum de participation.

Avec le [vote pondéré](/en/user_manual/polls/weighted_voting), le quorum tient compte du poids des votes. Par exemple, Jamie a un poids du vote de `2`, Samira de `1` et Alex de `1`. Si seul Jamie vote, la moitié du poids total des votes des électeurs habilités à voter est représentée. Si Samira vote également, la participation atteint 75 %, ce qui satisfait un quorum de 60 %.

Lors de la création d’un sondage, ouvrez **Plus de paramètres** et saisissez le pourcentage requis dans **Quorum**. Laissez le champ vide si aucun quorum n’est requis.

![Le paramètre Quorum avec un quorum de participation de 60 %](./quorum-section.png)

Vous pouvez également définir un quorum dans un [modèle de sondage](/en/user_manual/polls/poll_templates/) afin que les sondages créés à partir de ce modèle l’utilisent par défaut.

Si un sondage est clôturé sans atteindre le quorum, Loomio indique que le quorum n’a pas été atteint. Le sondage n’est pas automatiquement prolongé ni annulé. Un administrateur du fil peut rouvrir le sondage (si cela est autorisé) ou partager une conclusion expliquant la suite.

<!-- translation-section: example-scenario -->

## Exemple de scénario

La coopérative Oatmilk discute d’un essai de bouteilles consignées pendant six semaines et doit approuver le budget de l’essai.

Jamie sélectionne **Lancer un vote**, choisit un modèle de proposition et renseigne le titre, les détails, les options, la durée et les paramètres des électeurs.

![Le titre, les détails, les options, la durée et les paramètres des électeurs de la proposition](proposal-options.png)

Jamie limite le vote aux cinq personnes responsables du budget de l’essai. Comme la coopérative exige une participation de 60 % pour les décisions importantes, Jamie saisit **60** dans **Quorum** et lance la proposition.

Avant que quiconque ne vote, le panneau des résultats indique que le quorum n’a pas été atteint.

![Aucun vote exprimé et quorum de 60 % pas encore atteint](pie-chart-0.png)

Jamie vote Accord et Samira vote Désaccord. Le graphique se met à jour, mais la participation de deux électeurs sur les cinq habilités à voter ne représente que 40 %. Le quorum n’est donc toujours pas atteint.

![Deux votes exprimés sur cinq et quorum pas encore atteint](pie-chart-40.png)

Alex vote ensuite Accord. Trois des cinq électeurs habilités à voter ont participé, atteignant ainsi le quorum de 60 %. Une coche verte indique désormais que l’exigence est satisfaite. Jamie peut clôturer le sondage avant la date prévue ou attendre les électeurs restants.

![Trois votes exprimés sur cinq et quorum de 60 % atteint](pie-chart-60.png)
