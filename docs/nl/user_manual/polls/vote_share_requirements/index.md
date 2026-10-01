---
title: Vereisten voor het stemmenaandeel
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  introduction: ec00bae078180031
  eligible-voters-and-votes-cast: 70ba096ec89f74dc
  different-vote-share-requirements: e82801deca3b0912
  detailed-example: f72e996e8f273792
title_source: a654891ca817844e
title_generated: 5730833b95912bf9
---

<!-- translation-section: introduction -->

# Vereisten voor het stemmenaandeel

Stel voor een optie een vereiste voor het stemmenaandeel in als een voorstel alleen mag worden aangenomen bij een bepaald percentage steun, of als het percentage tegenstemmen onder een bepaalde grens moet blijven.

Je kunt vereisten voor het stemmenaandeel combineren met een [quorum](/en/user_manual/polls/quorum/). Zo vereis je zowel voldoende deelname als een bepaalde verdeling van de stemmen.

Selecteer in het voorstelformulier het bewerkingspictogram naast een optie.

![Het bewerkingspictogram naast de optie Eens](edit-highlight-on-option.png)

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

Een optie instellen op **Niet meer dan 0%** is gebruikelijk. Dit betekent dat het voorstel niet kan worden aangenomen als iemand die optie kiest. Gebruik deze instelling bij **Blokkeer**, zodat één blokkerende stem het voorstel tegenhoudt.

Je kunt ook vereisten toevoegen aan een [peilingssjabloon](/en/user_manual/polls/poll_templates/). Nieuwe voorstellen die je met het sjabloon maakt, gebruiken die vereisten dan standaard.

<!-- translation-section: detailed-example -->

## Uitgebreid voorbeeld

Oatmilk Cooperative beslist of er een proef van zes weken met herbruikbare flessen komt. Vijf mensen zijn kiesgerechtigd.

Het proces van de coöperatie vereist dat minstens 75 procent van de kiesgerechtigde kiezers voor stemt. Jamie bewerkt de optie **Eens** van het voorstel, schakelt de vereiste voor het stemmenaandeel in en stelt deze in op **Ten minste 75% van Kiesgerechtigde kiezers**.

![De optie Eens vereist steun van minstens 75 procent van de kiesgerechtigde kiezers](./agree-vote-option.png)

Jamie stelt ook een quorum van 60 procent in. Jamie en Samira stemmen voor. Alle uitgebrachte stemmen steunen het voorstel, maar ze vertegenwoordigen slechts 40 procent van de kiesgerechtigde kiezers. Geen van beide vereisten is dus bereikt.

![Twee van de vijf mensen hebben voor gestemd en geen van beide vereisten is bereikt](./first-vote-breakdown.png)

Daarna stemmen Alex en Morgan voor, terwijl Taylor tegenstemt. Alle vijf mensen hebben gestemd, dus het quorum is bereikt. Vier van de vijf kiesgerechtigde kiezers stemmen voor. Die 80 procent is meer dan de vereiste 75 procent. Bij beide vereisten staat daarom een groen vinkje.

![Alle vijf mensen hebben gestemd en beide vereisten zijn bereikt](./final-vote-breakdown.png)
