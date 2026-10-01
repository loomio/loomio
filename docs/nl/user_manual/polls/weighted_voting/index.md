---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 19aa0750d192b94b
  set-members-vote-weights: 36139b6a5f25024c
  use-weighted-voting-in-a-poll: f5d73b198ba1c246
  results: 66e85ec0de2cf047
title: Gewogen stemmen
title_source: 0b971991dfcacbab
title_generated: ae4290c895e6ff10
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Gewogen stemmen

Met gewogen stemmen tellen sommige stemmen zwaarder mee dan andere. Elke kiezer heeft een stemgewicht. Bijvoorbeeld:

- Een woongemeenschap geeft elke woning één stem. Een lid dat drie woningen vertegenwoordigt, heeft een stemgewicht van `3`.
- Het bestuur van een coöperatie neemt het besluit, maar medewerkers nemen deel aan het gesprek. Bestuursleden hebben een stemgewicht van `1`. Medewerkers hebben een stemgewicht van `0`, zodat hun stemmen worden vastgelegd maar het resultaat niet veranderen.
- Een bedrijf geeft aandeelhouders stemmen op basis van hun aandelenbelang. Iemand die 12,5% van de aandelen bezit, heeft een stemgewicht van `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Stemgewichten van leden instellen

Een admin van de groep kan de pagina **Leden** van de groep openen en **Stemgewichten bewerken** selecteren. Voer stemgewichten in en selecteer **Stemgewichten opslaan**. Stemgewichten kunnen `0` of hoger zijn, met maximaal drie decimalen. Zoek op naam of e-mailadres om iemand te vinden. Selecteer **Alle stemgewichten instellen** om elk lid hetzelfde stemgewicht te geven.

![Stemgewichten van groepsleden](member-weights.png)

Het stemgewicht van een lid wordt gekopieerd naar elke peiling waaraan dat lid wordt toegevoegd. Als je het later wijzigt, verandert dat niets aan peilingen waarin het stemgewicht al is overgenomen.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Gewogen stemmen gebruiken in een peiling

Selecteer **Gewogen stemmen gebruiken** in de geavanceerde instellingen van de peiling. Je kunt dit in- of uitschakelen nadat het stemmen is begonnen. Als je het uitschakelt, wordt elk stemgewicht in de peiling ingesteld op `1` en gaan alle stemgewichten die je voor die peiling hebt gewijzigd verloren.

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

De grafiek toont het gewogen resultaat. Selecteer een kolomkop om in plaats daarvan die kolom in de grafiek weer te geven. Bij het aantal stemgerechtigde kiezers en het quorum tellen personen, niet stemgewichten. Iedereen die de stemmen kan zien, kan het stemgewicht van elke kiezer zien.

![Het resultaat van een voorstel met stemmen en gewogen stemmen](weighted-proposal-result.png)
