---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: 1cc0b5130642217b
  results: a0eeeda5a9e70a97
generated:
  introduction: e68797adab665ded
  set-members-vote-weights: 36139b6a5f25024c
  use-weighted-voting-in-a-poll: 97a799ad2be1188a
  results: af0e91cca184546d
title: Gewogen stemmen
title_source: 0b971991dfcacbab
title_generated: ae4290c895e6ff10
source_revision: ad60e7728a4b8d578ec70fa26577556ee051c09d
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
---

<!-- translation-section: introduction -->

# Gewogen stemmen

Met gewogen stemmen tellen sommige stemmen zwaarder mee dan andere. Elke kiezer heeft een stemgewicht. Bijvoorbeeld:

- Een woongemeenschap geeft elke woning één stem. Een lid dat drie woningen vertegenwoordigt, heeft een stemgewicht van `3`.
- Een werknemerscoöperatie kent stemrecht toe na een vaste periode van lidmaatschap. Nieuwere leden krijgen een stemgewicht van `0`, zodat ze kunnen bijdragen aan de discussie en het stemproces kunnen ervaren zonder dat hun stemmen het resultaat beïnvloeden.
- Een bedrijf geeft aandeelhouders stemmen op basis van hun aandelenbelang. Iemand die 12,5% van de aandelen bezit, heeft een stemgewicht van `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Stemgewichten van leden instellen

Een admin van de groep kan de pagina **Leden** van de groep openen en **Stemgewichten bewerken** selecteren. Voer stemgewichten in en selecteer **Stemgewichten opslaan**. Stemgewichten kunnen `0` of hoger zijn, met maximaal drie decimalen. Zoek op naam of e-mailadres om iemand te vinden. Selecteer **Alle stemgewichten instellen** om elk lid hetzelfde stemgewicht te geven.

![Stemgewichten van groepsleden](member-weights.png)

Het stemgewicht van een lid wordt gekopieerd naar elke peiling waaraan dat lid wordt toegevoegd. Als je het later wijzigt, verandert dat niets aan peilingen waarin het stemgewicht al is overgenomen.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Gewogen stemmen gebruiken in een peiling

Open **Meer instellingen** in het peilingformulier en selecteer **Gewogen stemmen gebruiken**. Je kunt gewogen stemmen in- of uitschakelen nadat het stemmen is begonnen. Als je het uitschakelt, wordt elk stemgewicht in de peiling ingesteld op `1` en gaan alle stemgewichten die je voor die peiling hebt gewijzigd verloren.

Als jouw groep gewogen stemmen gebruikt voor een vast proces, selecteer dan **Gewogen stemmen gebruiken** in een [peilingsjabloon](/en/user_manual/polls/poll_templates). Peilingen die vanuit dat sjabloon worden gestart, gebruiken gewogen stemmen.

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

De grafiek toont het gewogen resultaat. Selecteer een kolomkop om in plaats daarvan die kolom in de grafiek weer te geven. Iedereen die de stemmen kan zien, kan het stemgewicht van elke kiezer zien.

Bij peilingen van de typen Voorstel en Kiezen toont **Niet gestemd** het aantal kiezers dat nog niet heeft gestemd onder **Stemmen** en hun totale stemgewicht onder **Gewogen stemmen**. Deze kolommen en **% van het stemgerechtigde stemgewicht** nemen degenen die niet hebben gestemd mee in de grafiek. Bij **% van het uitgebrachte stemgewicht** blijft **Niet gestemd** leeg en wordt het niet meegenomen in de grafiek.

Stemgewichten gelden ook voor het [quorum](/en/user_manual/polls/quorum) en de [vereisten voor het stemmenaandeel](/en/user_manual/polls/vote_share_requirements).

In het onderstaande voorbeeld stemt Jamie **Eens** met een stemgewicht van `2`. Drie mensen stemmen **Oneens**, met stemgewichten van `1`, `0` en `0`. Twee mensen, met stemgewichten van `2` en `1`, hebben niet gestemd.

Eens heeft één van de vier uitgebrachte stemmen, maar twee derde van het uitgebrachte stemgewicht. De helft van het stemgerechtigde stemgewicht heeft deelgenomen, dus het quorum van 60 procent is niet bereikt.

![Het resultaat van een voorstel met stemmen en gewogen stemmen](weighted-proposal-result.png)
