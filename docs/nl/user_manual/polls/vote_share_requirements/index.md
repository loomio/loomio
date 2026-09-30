---
title: Vereisten voor het stemmenaandeel
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: c97281f29d615dea
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: 0d25794ec996d42c
  detailed-example: dc765c43a22a28a1
generated:
  introduction: eaa706cb1343ba28
  eligible-voters-and-votes-cast: 70ba096ec89f74dc
  different-vote-share-requirements: f494a967d874a6c7
  detailed-example: a0e6a59761e2e667
title_source: a654891ca817844e
title_generated: 5730833b95912bf9
---

<!-- translation-section: introduction -->

# Vereisten voor het stemmenaandeel

Stel voor een optie een vereiste voor het stemmenaandeel in als een voorstel alleen mag worden aangenomen bij een bepaald percentage steun, of als het percentage tegenstemmen onder een bepaalde grens moet blijven.

Je kunt vereisten voor het stemmenaandeel combineren met een [quorum](/en/user_manual/polls/quorum/). Zo vereis je zowel voldoende deelname als een bepaalde verdeling van de stemmen.

Selecteer bij het maken van een voorstel het bewerkingspictogram naast een optie.

![Het bewerkingspictogram naast de optie Toestemming](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Kiesgerechtigde kiezers en uitgebrachte stemmen

Je kunt het percentage baseren op **Uitgebrachte stemmen** of **Kiesgerechtigde kiezers**.

![Kiezen of een vereiste voor het stemmenaandeel wordt gebaseerd op uitgebrachte stemmen of kiesgerechtigde kiezers](./eligible-vs-cast.png)

**Kiesgerechtigde kiezers** zijn alle mensen die over het voorstel mogen stemmen. **Uitgebrachte stemmen** zijn alleen de stemmen die zijn ingediend.

Bij een vereiste van 75 procent instemming van kiesgerechtigde kiezers wordt de optie alleen aangenomen als minstens 75 procent van alle kiesgerechtigde kiezers ervoor stemt.

Bij een vereiste van 60 procent instemming van de uitgebrachte stemmen kan de optie worden aangenomen als 60 procent van de ingediende stemmen ervoor is, ongeacht de opkomst. Voeg een quorum toe als jouw proces ook een minimumdeelname vereist.

<!-- translation-section: different-vote-share-requirements -->

## Verschillende vereisten voor het stemmenaandeel

Een voorstel kan voor meerdere opties een vereiste hebben. Bijvoorbeeld:

- Eens moet minstens 75 procent van de kiesgerechtigde kiezers krijgen
- Onthouden mag niet meer dan 30 procent van de uitgebrachte stemmen krijgen
- Blokkeer mag niet meer dan 0 procent van de uitgebrachte stemmen krijgen

Je kunt ook vereisten toevoegen aan een [peilingssjabloon](/en/user_manual/polls/poll_templates/). Nieuwe voorstellen die je met het sjabloon maakt, gebruiken die vereisten dan standaard.

<!-- translation-section: detailed-example -->

## Uitgebreid voorbeeld

Oatmilk Cooperative beslist of het budget voor een proef van zes weken met herbruikbare flessen wordt goedgekeurd. Vijf mensen zijn kiesgerechtigd.

Jamie gebruikt het voorstelsjabloon **Toestemming**, bewerkt de optie Toestemming en schakelt de vereiste voor het stemmenaandeel in.

Het proces van de coöperatie vereist steun van minstens 75 procent van de kiesgerechtigde kiezers. Jamie stelt de vereiste in op **Ten minste 75% van Kiesgerechtigde kiezers**.

![De optie Toestemming vereist steun van minstens 75 procent van de kiesgerechtigde kiezers](./consent-vote-option.png)

Jamie stelt ook een quorum van 60 procent in. Jamie en Samira stemmen voor. Alle uitgebrachte stemmen steunen het voorstel, maar ze vertegenwoordigen slechts 40 procent van de kiesgerechtigde kiezers. Geen van beide vereisten is dus bereikt.

![Twee van de vijf mensen hebben voor gestemd en geen van beide vereisten is bereikt](./first-vote-breakdown.png)

Daarna stemmen Alex en Morgan voor, terwijl Taylor tegenstemt. Alle vijf mensen hebben gestemd, dus het quorum is bereikt. Vier van de vijf kiesgerechtigde kiezers stemmen voor. Die 80 procent is meer dan de vereiste 75 procent. Bij beide vereisten staat daarom een groen vinkje.

![Alle vijf mensen hebben gestemd en beide vereisten zijn bereikt](./final-vote-breakdown.png)
