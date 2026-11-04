---
title: Vereisten voor het stemmenaandeel
source_revision: ad60e7728a4b8d578ec70fa26577556ee051c09d
source_file: docs/help/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 2cf6ad55d557c189
  different-vote-share-requirements: 0e81fb881e5c113e
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: f5482ba462535d6e
  eligible-voters-and-votes-cast: 7bed4a8cf19aad93
  different-vote-share-requirements: 0a7142705df6dee0
  detailed-example: 0fb7101cb612e110
title_source: a654891ca817844e
title_generated: 5730833b95912bf9
---

<!-- translation-section: introduction -->

# Vereisten voor het stemmenaandeel

Stel een vereist stemmenaandeel in voor een optie wanneer een voorstel een bepaald percentage steun moet krijgen, of onder een bepaald percentage tegenstemmen moet blijven, om te worden aangenomen.

Vereisten voor het stemmenaandeel kunnen worden gecombineerd met een [quorum](/en/user_manual/polls/quorum/) om zowel voldoende deelname als een bepaalde verdeling van stemmen te vereisen.

Selecteer in het voorstelformulier het bewerkingspictogram naast een optie.

![Het bewerkingspictogram naast de optie Eens](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Kiesgerechtigde kiezers en uitgebrachte stemmen

Het percentage kan worden gebaseerd op **Uitgebrachte stemmen** of **Kiesgerechtigde kiezers**.

![Kiezen of een vereist stemmenaandeel wordt gebaseerd op uitgebrachte stemmen of kiesgerechtigde kiezers](./eligible-vs-cast.png)

**Kiesgerechtigde kiezers** zijn alle mensen die over het voorstel mogen stemmen. **Uitgebrachte stemmen** zijn alleen de stemmen die zijn ingediend.

Bij een vereiste van 75 procent instemming onder kiesgerechtigde kiezers kan het voorstel alleen worden aangenomen als minstens 75 procent van alle kiesgerechtigde kiezers op die optie stemt.

Bij een vereiste van 60 procent instemming onder uitgebrachte stemmen kan het voorstel worden aangenomen als 60 procent van de ingediende stemmen de optie steunt, ongeacht de totale opkomst. Voeg een quorum toe als jouw besluitvormingsproces ook een minimale deelname vereist.

Bij [gewogen stemmen](/en/user_manual/polls/weighted_voting) wordt voor beide berekeningsgrondslagen het stemgewicht gebruikt. **Uitgebracht stemgewicht** vergelijkt het gewogen totaal van de optie met al het uitgebrachte stemgewicht. **Stemgerechtigd stemgewicht** vergelijkt het stemgewicht van de kiezers die de optie kiezen met het stemgewicht van alle kiesgerechtigde kiezers, inclusief mensen die niet hebben gestemd. Eén persoon met 70 van de 100 eenheden kiesgerechtigd stemgewicht kan bijvoorbeeld voldoen aan een vereiste van 60 procent instemming op basis van kiesgerechtigd stemgewicht.

<!-- translation-section: different-vote-share-requirements -->

## Verschillende vereisten voor het stemmenaandeel

Een voorstel kan vereisten hebben voor meer dan één optie. Bijvoorbeeld:

- Minstens 75 procent van de kiesgerechtigde kiezers moet het eens zijn
- Onthoudingen mogen niet meer dan 30 procent van de uitgebrachte stemmen vormen
- Veto's mogen niet meer dan 0 procent van de uitgebrachte stemmen vormen

Een optie instellen op **Niet meer dan 0%** is gebruikelijk. Dit betekent dat het voorstel niet kan worden aangenomen als iemand die optie kiest. Gebruik deze instelling voor **Veto**, zodat één veto het voorstel tegenhoudt.

Bij gewogen stemmen overschrijdt alleen een veto met een positief stemgewicht een vereiste van 0 procent. Een veto met stemgewicht `0` voegt geen stemgewicht toe aan het resultaat.

Je kunt ook vereisten toevoegen aan een [peilingssjabloon](/en/user_manual/polls/poll_templates/), zodat nieuwe voorstellen die met het sjabloon worden gemaakt deze standaard gebruiken.

<!-- translation-section: detailed-example -->

## Uitgewerkt voorbeeld

Oatmilk Cooperative besluit of de coöperatie een proef van zes weken met herbruikbare retourflessen zal uitvoeren. Vijf mensen mogen stemmen.

Het besluitvormingsproces van de coöperatie vereist dat minstens 75 procent van de kiesgerechtigde kiezers het eens is. Jamie bewerkt de optie **Eens** van het voorstel, schakelt het vereiste stemmenaandeel in en stelt dit in op **Minstens 75% van de kiesgerechtigde kiezers**.

![De optie Eens waarvoor minstens 75 procent van de kiesgerechtigde kiezers vereist is](./agree-vote-option.png)

Jamie stelt ook een quorum van 60 procent in. Jamie en Samira stemmen op Eens. Alle ingediende stemmen steunen het voorstel, maar vertegenwoordigen slechts 40 procent van de kiesgerechtigde kiezers. Aan geen van beide vereisten is dus voldaan.

![Twee van de vijf mensen hebben op Eens gestemd en aan geen van beide vereisten is voldaan](./first-vote-breakdown.png)

Daarna stemmen Alex en Morgan op Eens, terwijl Taylor op Oneens stemt. Alle vijf mensen hebben gestemd, waardoor het quorum is bereikt, en vier van de vijf kiesgerechtigde kiezers zijn het eens. De instemming van 80 procent ligt boven het vereiste stemmenaandeel van 75 procent, dus bij beide vereisten verschijnt een groen vinkje.

![Alle vijf mensen hebben gestemd en aan beide vereisten is voldaan](./final-vote-breakdown.png)
