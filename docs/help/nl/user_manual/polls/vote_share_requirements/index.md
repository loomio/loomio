---
title: Vereisten voor het stemmenaandeel
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: cbaf41b11886d669
  eligible-voters-and-votes-cast: 1eace7b24593e671
  different-vote-share-requirements: 0707fe507dfba2b9
  detailed-example: bd9380153211ad27
generated:
  introduction: 2a70cc3cf9b26b50
  eligible-voters-and-votes-cast: 83acd1aa2098540d
  different-vote-share-requirements: 0b6f77b7ad289995
  detailed-example: 0fb7101cb612e110
title_source: a654891ca817844e
title_generated: 5730833b95912bf9
---

<!-- translation-section: introduction -->

# Vereisten voor het stemmenaandeel

Stel een vereist stemmenaandeel in voor een optie wanneer een voorstel een minimaal percentage steun moet krijgen, of onder een maximaal percentage tegenstemmen moet blijven, om te worden aangenomen.

Je kunt vereisten voor het stemmenaandeel combineren met een [quorum](/en/user_manual/polls/quorum/) om zowel voldoende deelname als een bepaalde verdeling van stemmen te vereisen.

Selecteer in het voorstelformulier het bewerkingspictogram naast een optie.

![Het bewerkingspictogram naast de optie Eens](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Kiesgerechtigde kiezers en uitgebrachte stemmen

Het percentage kan worden gebaseerd op **Uitgebrachte stemmen** of **Kiesgerechtigde kiezers**.

![Kiezen of een vereist stemmenaandeel wordt gebaseerd op uitgebrachte stemmen of kiesgerechtigde kiezers](./eligible-vs-cast.png)

**Kiesgerechtigde kiezers** zijn alle mensen die over het voorstel mogen stemmen. **Uitgebrachte stemmen** zijn alleen de stemmen die zijn ingediend.

Bij een vereiste van 75 procent instemming onder kiesgerechtigde kiezers kan het voorstel alleen worden aangenomen als minstens 75 procent van alle kiesgerechtigde kiezers op die optie stemt.

Bij een vereiste van 60 procent instemming onder uitgebrachte stemmen kan het voorstel worden aangenomen als 60 procent van de ingediende stemmen de optie steunt, ongeacht de totale opkomst. Voeg een quorum toe als jouw besluitvormingsproces ook een minimale deelname vereist.

Bij [gewogen stemmen](/en/user_manual/polls/weighted_voting) wordt voor beide berekeningsgrondslagen het stemgewicht gebruikt. **Uitgebracht stemgewicht** vergelijkt het gewogen totaal van de optie met al het uitgebrachte stemgewicht. **Stemgerechtigd stemgewicht** vergelijkt het gewogen totaal van de optie met het stemgewicht van alle kiesgerechtigde kiezers, inclusief mensen die nog niet hebben gestemd. Eén kiezer met 70 van de 100 eenheden stemgerechtigd stemgewicht kan bijvoorbeeld voldoen aan een vereiste van 60 procent instemming op basis van stemgerechtigd stemgewicht.

<!-- translation-section: different-vote-share-requirements -->

## Verschillende vereisten voor het stemmenaandeel

Een voorstel kan vereisten hebben voor meer dan één optie. Bijvoorbeeld:

- Minstens 75 procent van de kiesgerechtigde kiezers moet het eens zijn.
- Onthoudingen mogen niet meer dan 30 procent van de uitgebrachte stemmen vormen.
- Veto's mogen niet meer dan 0 procent van de uitgebrachte stemmen vormen.

Een optie instellen op **Niet meer dan 0%** is gebruikelijk. Dit betekent dat het voorstel niet kan worden aangenomen als iemand die optie kiest. Gebruik deze instelling voor **Veto**, zodat één veto het voorstel tegenhoudt.

Bij gewogen stemmen overschrijdt alleen een veto met een positief stemgewicht een vereiste van 0 procent. Een veto met stemgewicht `0` voegt geen stemgewicht toe aan het resultaat.

Je kunt ook vereisten toevoegen aan een [peilingssjabloon](/en/user_manual/polls/poll_templates/), zodat nieuwe voorstellen die met dat sjabloon worden gemaakt deze standaard gebruiken.

<!-- translation-section: detailed-example -->

## Uitgewerkt voorbeeld

Oatmilk Cooperative besluit of de coöperatie een proef van zes weken met herbruikbare retourflessen zal uitvoeren. Vijf mensen mogen stemmen.

Het besluitvormingsproces van de coöperatie vereist dat minstens 75 procent van de kiesgerechtigde kiezers het eens is. Jamie bewerkt de optie **Eens** van het voorstel, schakelt het vereiste stemmenaandeel in en stelt dit in op **Minstens 75% van de kiesgerechtigde kiezers**.

![De optie Eens waarvoor minstens 75 procent van de kiesgerechtigde kiezers vereist is](./agree-vote-option.png)

Jamie stelt ook een quorum van 60 procent in. Jamie en Samira stemmen op Eens. Alle ingediende stemmen steunen het voorstel, maar vertegenwoordigen slechts 40 procent van de kiesgerechtigde kiezers. Aan geen van beide vereisten is dus voldaan.

![Twee van de vijf mensen hebben op Eens gestemd en aan geen van beide vereisten is voldaan](./first-vote-breakdown.png)

Daarna stemmen Alex en Morgan op Eens, terwijl Taylor op Oneens stemt. Alle vijf mensen hebben gestemd, waardoor het quorum is bereikt, en vier van de vijf kiesgerechtigde kiezers zijn het eens. De instemming van 80 procent ligt boven het vereiste stemmenaandeel van 75 procent, dus bij beide vereisten verschijnt een groen vinkje.

![Alle vijf mensen hebben gestemd en aan beide vereisten is voldaan](./final-vote-breakdown.png)
