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
  introduction: d94eb1c9fa09ecee
  example-scenario: 6c0a5dafe254216f
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Een quorum is het minimumpercentage stemgerechtigden dat moet deelnemen om een peiling geldig te maken. Gebruik het als voor een besluit een bepaald niveau van deelname nodig is.

Open bij het maken van een peiling **Meer instellingen** en vul het vereiste percentage in bij **Deelnamequorum**. Laat het veld leeg als er geen quorum nodig is.

![De quoruminstelling met een deelnamequorum van 60 procent](./quorum-section.png)

Je kunt ook een quorum instellen in een [peilingssjabloon](/en/user_manual/polls/poll_templates/). Peilingen die je met dat sjabloon maakt, gebruiken het quorum dan standaard.

<!-- translation-section: example-scenario -->

## Voorbeeld

De Oatmilk-coöperatie bespreekt een proef van zes weken met herbruikbare flessen. De discussie is op het punt gekomen waarop de coöperatie het budget voor de proef moet goedkeuren.

Jamie kiest **Start een stemming**, selecteert het voorstelsjabloon **Toestemming** en vult de titel, details, opties, duur en instellingen voor stemgerechtigden in.

![De titel, details, opties, duur en instellingen voor stemgerechtigden van het voorstel](proposal-options.png)

Jamie beperkt de stemming tot de vijf mensen die verantwoordelijk zijn voor het budget van de proef.

De coöperatie vereist 60 procent deelname bij belangrijke besluiten. Daarom vult Jamie **60** in bij het deelnamequorum en start het voorstel.

Voordat iemand stemt, laat het resultatenpaneel zien dat het quorum nog niet is bereikt.

![Er zijn nog geen stemmen uitgebracht en het quorum van 60 procent is nog niet bereikt](pie-chart-0.png)

Jamie is het eens met het voorstel en Samira is het oneens. De grafiek wordt bijgewerkt, maar twee van de vijf stemgerechtigden betekent slechts 40 procent deelname. Het quorum is dus nog niet bereikt.

![Twee van de vijf stemmen zijn uitgebracht en het quorum is nog niet bereikt](pie-chart-40.png)

Daarna is Alex het ook eens met het voorstel. Drie van de vijf stemgerechtigden hebben nu deelgenomen. Daarmee is het quorum van 60 procent bereikt. Bij de vereiste verschijnt een groen vinkje. Jamie kan de peiling voortijdig sluiten of op de overige stemgerechtigden wachten.

![Drie van de vijf stemmen zijn uitgebracht en het quorum van 60 procent is bereikt](pie-chart-60.png)
