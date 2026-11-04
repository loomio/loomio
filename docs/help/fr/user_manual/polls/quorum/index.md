---
title: Quorum
source_revision: ad60e7728a4b8d578ec70fa26577556ee051c09d
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: dbfdebe6e23060db
  example-scenario: d247e0866095c321
generated:
  introduction: '0499fe59b4b6e641'
  example-scenario: 185ee1c540ea0187
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Un quorum est le pourcentage minimum d’électeurs habilités à voter qui doivent participer pour qu’un sondage soit valide. Utilisez-le lorsque votre processus de gouvernance exige un niveau de participation particulier.

Avec le [vote pondéré](/en/user_manual/polls/weighted_voting), le quorum tient compte du poids des votes. Par exemple, Jamie a un poids du vote de `2`, Samira de `1` et Alex de `1`. Si seul Jamie vote, la moitié du poids total des votes des électeurs habilités à voter est représentée. Si Samira vote également, la participation atteint 75 %, ce qui satisfait un quorum de 60 %.

Lors de la création d’un sondage, ouvrez **Plus de paramètres**. Saisissez le pourcentage requis dans **Quorum**. Laissez le champ vide si aucun quorum n’est requis.

![Le paramètre Quorum avec un quorum de participation de 60 %](./quorum-section.png)

Vous pouvez également définir un quorum dans un [modèle de sondage](/en/user_manual/polls/poll_templates/) afin que les sondages créés à partir de ce modèle l’utilisent par défaut.

<!-- translation-section: example-scenario -->

## Exemple de scénario

La coopérative Oatmilk discute d’un essai de bouteilles consignées pendant six semaines. La discussion a atteint le stade où la coopérative doit approuver le budget de l’essai.

Jamie sélectionne **Lancer un vote**, choisit le modèle de proposition **Consentement** et renseigne le titre, les détails, les options, la durée et les paramètres des électeurs.

![Le titre, les détails, les options, la durée et les paramètres des électeurs de la proposition](proposal-options.png)

Jamie limite le vote aux cinq personnes responsables du budget de l’essai.

La coopérative exige une participation de 60 % pour les décisions importantes. Jamie saisit donc **60** dans **Quorum** et lance la proposition.

Avant que quiconque ne vote, le panneau des résultats indique que le quorum n’a pas été atteint.

![Aucun vote exprimé et quorum de 60 % pas encore atteint](pie-chart-0.png)

Jamie vote Accord et Samira vote Désaccord. Le graphique se met à jour, mais la participation de deux électeurs sur les cinq habilités à voter ne représente que 40 %. Le quorum n’est donc toujours pas atteint.

![Deux votes exprimés sur cinq et quorum pas encore atteint](pie-chart-40.png)

Alex vote ensuite Accord. Trois des cinq électeurs habilités à voter ont participé, atteignant ainsi le quorum de 60 %. Une coche verte indique désormais que l’exigence est satisfaite. Jamie peut clôturer le sondage avant la date prévue ou attendre les électeurs restants.

![Trois votes exprimés sur cinq et quorum de 60 % atteint](pie-chart-60.png)
