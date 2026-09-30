---
title: Quorum
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: f2af4136666bd6aa
  example-scenario: b72c91bdbb710ad7
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Le quorum est le pourcentage minimum de personnes habilitées à voter qui doivent participer pour qu’un sondage soit valide. Utilisez-le lorsque votre processus de décision exige un certain niveau de participation.

Lors de la création d’un sondage, ouvrez **Plus de paramètres** et saisissez le pourcentage requis dans **Quorum de participation**. Laissez le champ vide si aucun quorum n’est requis.

![Le paramètre de quorum avec un quorum de participation de 60 %](./quorum-section.png)

Vous pouvez aussi définir un quorum dans un [modèle de sondage](/en/user_manual/polls/poll_templates/). Les sondages créés à partir de ce modèle l’utiliseront par défaut.

<!-- translation-section: example-scenario -->

## Exemple

La coopérative Oatmilk discute d’un essai de six semaines avec des bouteilles consignées. Elle doit maintenant approuver le budget de cet essai.

Jamie sélectionne **Lancer un vote**, choisit le modèle de proposition **Consentement**, puis renseigne le titre, les détails, les options, la durée et les paramètres des personnes autorisées à voter.

![Le titre, les détails, les options, la durée et les paramètres des personnes autorisées à voter pour la proposition](proposal-options.png)

Jamie limite le vote aux cinq personnes responsables du budget de l’essai.

La coopérative exige une participation de 60 % pour les décisions importantes. Jamie saisit donc **60** dans le champ du quorum de participation et lance la proposition.

Avant le premier vote, le panneau des résultats indique que le quorum n’est pas atteint.

![Aucun vote exprimé et le quorum de 60 % pas encore atteint](pie-chart-0.png)

Jamie est d’accord et Samira n’est pas d’accord. Le graphique se met à jour, mais deux personnes sur cinq ne représentent que 40 % de participation. Le quorum n’est donc toujours pas atteint.

![Deux votes sur cinq exprimés et le quorum pas encore atteint](pie-chart-40.png)

Alex vote ensuite pour. Trois des cinq personnes habilitées à voter ont participé : le quorum de 60 % est atteint. Une coche verte indique désormais que cette condition est remplie. Jamie peut fermer le sondage avant son échéance ou attendre les derniers votes.

![Trois votes sur cinq exprimés et le quorum de 60 % atteint](pie-chart-60.png)
