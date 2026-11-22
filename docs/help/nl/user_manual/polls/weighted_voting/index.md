---
sections:
  introduction: 566ce8dda668a638
  set-members-vote-weights: 2a3d29ebb9840017
  use-weighted-voting-in-a-poll: feddef738da4567d
  results: ab86e178359702a0
generated:
  introduction: 293d7f7aee47e6d3
  set-members-vote-weights: 9320a72bba146ed6
  use-weighted-voting-in-a-poll: 9d8dcf8fd9ed0cb8
  results: 75cd3af21d028357
title: Gewogen stemmen
title_source: 0b971991dfcacbab
title_generated: ae4290c895e6ff10
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
---

<!-- translation-section: introduction -->

# Gewogen stemmen

Met gewogen stemmen tellen sommige stemmen zwaarder mee dan andere doordat elke kiezer een stemgewicht krijgt. Bijvoorbeeld:

- Een woongemeenschap geeft elke woning één stem. Een lid dat drie woningen vertegenwoordigt, heeft een stemgewicht van `3`.
- Een werknemerscoöperatie kent stemrecht toe na een vaste periode van lidmaatschap. Nieuwere leden krijgen een stemgewicht van `0`, zodat ze kunnen deelnemen aan de discussie en het stemmen kunnen uitproberen zonder het resultaat te beïnvloeden.
- Een bedrijf geeft aandeelhouders stemmen op basis van hun aandelenbelang. Iemand die 12,5% van de aandelen bezit, heeft een stemgewicht van `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Stemgewichten van leden instellen

Een admin van de groep kan de pagina **Leden** van de groep openen en **Stemgewichten bewerken** selecteren. Voer stemgewichten in (`0` of hoger, met maximaal drie decimalen) en selecteer **Stemgewichten opslaan**. Je kunt op naam of e-mailadres zoeken om iemand te vinden, of **Alle stemgewichten instellen** selecteren om elk lid hetzelfde stemgewicht te geven.

![Stemgewichten van groepsleden](member-weights.png)

Het stemgewicht van een lid wordt gekopieerd naar elke peiling waaraan dat lid wordt toegevoegd. Als je het later wijzigt, heeft dat geen invloed op bestaande peilingen.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Gewogen stemmen gebruiken in een peiling

Open **Meer instellingen** in het peilingformulier en selecteer **Gewogen stemmen gebruiken**. Je kunt gewogen stemmen in- of uitschakelen nadat het stemmen is begonnen. Als je het uitschakelt, wordt elk stemgewicht in de peiling teruggezet op `1` en gaan alle aangepaste stemgewichten voor die peiling verloren.

Als jouw groep gewogen stemmen gebruikt voor een vast proces, schakel dan **Gewogen stemmen gebruiken** in een [peilingsjabloon](/en/user_manual/polls/poll_templates) in. Peilingen die vanuit dat sjabloon worden gestart, gebruiken standaard gewogen stemmen.

![De instelling Gewogen stemmen gebruiken in een peiling](poll-setting.png)

Gewogen stemmen werkt met deze peilingtypen: [Voorstel](/en/user_manual/polls/proposals), [Kiezen](/en/user_manual/polls/choose), [Beoordelen](/en/user_manual/polls/score), [Verdelen](/en/user_manual/polls/allocate) en [Rangschikken](/en/user_manual/polls/rank).

Je kunt gewogen stemmen en [anoniem stemmen](/en/user_manual/polls/anonymous_voting) niet in dezelfde peiling gebruiken.

Selecteer **Kiezers beheren** en selecteer vervolgens het stemgewicht naast de naam van een kiezer om dat stemgewicht te wijzigen. Selecteer **Alle stemgewichten instellen** om de stemgewichten van iedereen te wijzigen. Je kunt het stemgewicht van elk lid uit de groep kopiëren of iedereen dezelfde waarde geven. Kiezers die geen lid van de groep zijn, krijgen een stemgewicht van `1`.

![De knop Kiezers beheren bij een peiling](poll-manage-voters.png)

![Kiezers in een peiling met individuele stemgewichten](poll-voter-weights.png)

<!-- translation-section: results -->

## Resultaten

De resultaten tonen de ongewogen en gewogen totalen naast elkaar:

- Peilingen van de typen Voorstel en Kiezen tonen **Stemmen** en **Gewogen stemmen**.
- Peilingen van de typen Beoordelen, Verdelen en Rangschikken tonen **Punten** en **Gewogen punten**.

De grafiek toont het gewogen resultaat. Selecteer een kolomkop om die kolom in de grafiek weer te geven. Iedereen die de stemmen kan zien, kan het stemgewicht van elke kiezer zien.

Bij peilingen van de typen Voorstel en Kiezen toont **Niet gestemd** het aantal kiezers dat nog niet heeft gestemd onder **Stemmen** en hun totale stemgewicht onder **Gewogen stemmen**. Deze kolommen en **% van het stemgerechtigde stemgewicht** nemen mensen die nog niet hebben gestemd mee in de grafiek. Bij **% van het uitgebrachte stemgewicht** blijft **Niet gestemd** leeg en wordt het niet meegenomen in de grafiek.

Stemgewichten gelden ook voor het [quorum](/en/user_manual/polls/quorum) en de [vereisten voor het stemmenaandeel](/en/user_manual/polls/vote_share_requirements).

In het onderstaande voorbeeld stemt Jamie **Eens** met een stemgewicht van `2`. Drie mensen stemmen **Oneens**, met stemgewichten van `1`, `0` en `0`. Twee mensen, met stemgewichten van `2` en `1`, hebben nog niet gestemd.

Eens heeft één van de vier uitgebrachte stemmen, maar twee derde van het uitgebrachte stemgewicht. De helft van het stemgerechtigde stemgewicht heeft deelgenomen, dus het quorum van 60 procent is niet bereikt.

![Het resultaat van een voorstel met stemmen en gewogen stemmen](weighted-proposal-result.png)
