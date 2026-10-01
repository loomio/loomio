---
title: Quorum
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 78fc35b9cdd45101
  example-scenario: 6d47392b6c0de75e
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Een quorum is het minimale percentage stemgerechtigde kiezers dat moet deelnemen om een peiling geldig te laten zijn. Gebruik het wanneer jouw besluitvormingsproces een bepaald niveau van deelname vereist.

Open bij het aanmaken van een peiling **Meer instellingen** en voer het vereiste percentage in bij **Deelnamequorum**. Laat het veld leeg als er geen quorum vereist is.

![De quoruminstelling met een deelnamequorum van 60 procent](./quorum-section.png)

Je kunt ook een quorum instellen in een [peilingssjabloon](/en/user_manual/polls/poll_templates/), zodat peilingen die met dat sjabloon worden aangemaakt dit standaard gebruiken.

<!-- translation-section: example-scenario -->

## Voorbeeldscenario

Oatmilk Cooperative bespreekt een proef van zes weken met retourflessen. De discussie is op het punt gekomen waarop de coöperatie het budget voor de proef moet goedkeuren.

Jamie selecteert **Start een stemming**, kiest het voorstelsjabloon **Consent** en vult de titel, details, opties, duur en instellingen voor kiezers in.

![De titel, details, opties, duur en instellingen voor kiezers van het voorstel](proposal-options.png)

Jamie beperkt het stemmen tot de vijf mensen die verantwoordelijk zijn voor het budget van de proef.

De coöperatie vereist 60 procent deelname voor belangrijke besluiten. Daarom voert Jamie **60** in het veld voor het deelnamequorum in en start het voorstel.

Voordat iemand stemt, geeft het resultatenpaneel aan dat het quorum nog niet is bereikt.

![Geen stemmen uitgebracht en het quorum van 60 procent nog niet bereikt](pie-chart-0.png)

Jamie is het eens en Samira is het oneens. De grafiek wordt bijgewerkt, maar twee van de vijf stemgerechtigde kiezers betekent slechts 40 procent deelname. Het quorum is dus nog niet bereikt.

![Twee van de vijf stemmen uitgebracht en het quorum nog niet bereikt](pie-chart-40.png)

Daarna is Alex het eens. Drie van de vijf stemgerechtigde kiezers hebben deelgenomen, waarmee het quorum van 60 procent is bereikt. Bij de vereiste staat nu een groen vinkje. Jamie kan de peiling vroegtijdig sluiten of wachten op de overige kiezers.

![Drie van de vijf stemmen uitgebracht en het quorum van 60 procent bereikt](pie-chart-60.png)
