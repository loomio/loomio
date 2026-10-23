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
  introduction: 03a5fa855b4516fb
  example-scenario: 61056903a5078f68
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Een quorum is het minimale percentage stemgerechtigde kiezers dat moet deelnemen om een peiling geldig te laten zijn. Gebruik het wanneer jouw besluitvormingsproces een bepaald niveau van deelname vereist.

Bij [gewogen stemmen](/en/user_manual/polls/weighted_voting) wordt het quorum berekend op basis van stemgewichten. Jamie heeft bijvoorbeeld stemgewicht `2`, Samira stemgewicht `1` en Alex stemgewicht `1`. Als alleen Jamie stemt, heeft de helft van het stemgerechtigde stemgewicht deelgenomen. Als Samira ook stemt, bereikt de deelname 75 procent en is een quorum van 60 procent behaald.

Open bij het aanmaken van een peiling **Meer instellingen**. Voer het vereiste percentage in bij **Quorum**. Laat het veld leeg als er geen quorum vereist is.

![De quoruminstelling met een deelnamequorum van 60 procent](./quorum-section.png)

Je kunt ook een quorum instellen in een [peilingssjabloon](/en/user_manual/polls/poll_templates/), zodat peilingen die met dat sjabloon worden aangemaakt dit standaard gebruiken.

<!-- translation-section: example-scenario -->

## Voorbeeldscenario

Oatmilk Cooperative bespreekt een proef van zes weken met retourflessen. De discussie is op het punt gekomen waarop de coöperatie het budget voor de proef moet goedkeuren.

Jamie selecteert **Start een stemming**, kiest het voorstelsjabloon **Consent** en vult de titel, details, opties, duur en instellingen voor kiezers in.

![De titel, details, opties, duur en instellingen voor kiezers van het voorstel](proposal-options.png)

Jamie beperkt het stemmen tot de vijf mensen die verantwoordelijk zijn voor het budget van de proef.

De coöperatie vereist 60 procent deelname voor belangrijke besluiten. Daarom voert Jamie **60** in bij **Quorum** en start het voorstel.

Voordat iemand stemt, geeft het resultatenpaneel aan dat het quorum nog niet is bereikt.

![Geen stemmen uitgebracht en het quorum van 60 procent nog niet bereikt](pie-chart-0.png)

Jamie is het eens en Samira is het oneens. De grafiek wordt bijgewerkt, maar twee van de vijf stemgerechtigde kiezers betekent slechts 40 procent deelname. Het quorum is dus nog niet bereikt.

![Twee van de vijf stemmen uitgebracht en het quorum nog niet bereikt](pie-chart-40.png)

Daarna is Alex het eens. Drie van de vijf stemgerechtigde kiezers hebben deelgenomen, waarmee het quorum van 60 procent is bereikt. Bij de vereiste staat nu een groen vinkje. Jamie kan de peiling vroegtijdig sluiten of wachten op de overige kiezers.

![Drie van de vijf stemmen uitgebracht en het quorum van 60 procent bereikt](pie-chart-60.png)
