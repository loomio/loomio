---
title: Anoniem stemmen
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: 1e3cef0a3dc2c06b
  how-anonymous-voting-protects-voters: 5f12d500b3bc5efb
  while-voting-is-open: ec10a63a6903ede3
  votes-cannot-be-changed: fedb7749fb86a478
  why-anonymous-votes-do-not-have-reasons: 6ad6dbb701fdda59
  results-and-exports: baf5df60155d2a78
  participation-verification: a0c5335effa4b797
  reminders: 1210b2f710608c53
  what-coordinators-and-administrators-can-see: 4ef2b68c8c133099
  limits-of-anonymous-voting: 972d01e13508c204
  questions: 81dbe0d658bb53fe
  can-a-coordinator-see-how-i-voted: be5f18d5f24ea98b
  can-i-see-my-vote-after-submitting-it: 633009bb612bf4d1
  can-i-change-or-withdraw-my-vote: 7f140497b67a55ef
  will-i-receive-an-email-confirming-my-vote: f4eec68f623b6648
  does-a-public-poll-reveal-more-information: 794c52537bcfd296
  is-anonymous-voting-suitable-for-every-election: 0b719cf43e85d53e
title_source: 1bc4567506ad4d51
title_generated: a092c185ab7f2e64
---

<!-- translation-section: introduction -->

# Anoniem stemmen

Anoniem stemmen, ook wel blind stemmen genoemd, houdt de registratie van wie heeft gestemd gescheiden van de stemmen zelf. Nadat de peiling is gesloten, kan iedereen die het resultaat kan zien ook zien wie heeft deelgenomen. Niemand die Loomio gebruikt kan een ingediende stem koppelen aan de persoon die deze heeft ingediend.

Deze pagina legt uit welke bescherming anoniem stemmen biedt, welke informatie wordt bewaard en wat de grenzen van deze garantie zijn.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Hoe anoniem stemmen kiezers beschermt

Een anonieme peiling bewaart twee afzonderlijke verzamelingen gegevens:

| Deelnamegegevens | Ingediende stemmen |
| --- | --- |
| Wie mag stemmen | De geselecteerde opties of scores |
| Wie is uitgenodigd en door wie | De peiling waartoe de stem behoort |
| Of elke stemgerechtigde persoon heeft gestemd | Geen naam of gebruikersaccount |
| Geen geselecteerde opties of scores | Geen koppeling met deelnamegegevens |

Er is geen gedeelde identificatiecode die deze gegevens met elkaar verbindt. Ingediende stemmen bevatten ook geen werkelijk tijdstip van indiening, uitnodigingsgegevens, geschreven redenen, bijlagen of andere metadata die kunnen helpen om een kiezer te identificeren.

Deze scheiding wordt afgedwongen wanneer de stem wordt opgeslagen. Ze hangt niet alleen af van het verbergen van namen in de interface.

<!-- translation-section: while-voting-is-open -->

## Terwijl stemmen mogelijk is

Het resultaat blijft voor iedereen verborgen totdat de peiling sluit. Dit geldt ook voor peilingcoördinatoren, groepsadmins en instantieadmins die de applicatie gebruiken.

Wanneer iemand stemt:

- wordt de ingediende stem opgeslagen zonder naam of deelnamegegevens;
- worden de deelnamegegevens gemarkeerd om aan te geven dat die persoon heeft gestemd;
- wordt er geen stemgebeurtenis, melding, e-mail, reactie of activiteit aangemaakt;
- wordt er na het indienen geen kopie van de gemaakte keuzes teruggegeven; en
- bevestigt de interface alleen dat de stem is geregistreerd.

De deelnamegegevens bevatten geen precies tijdstip waarop de persoon heeft gestemd. Ingediende stemmen worden niet op het tijdstip van indiening gesorteerd.

<!-- translation-section: votes-cannot-be-changed -->

## Stemmen kunnen niet worden gewijzigd

Elke stemgerechtigde persoon kan één keer stemmen. Een ingediende anonieme stem kan niet worden bekeken, gewijzigd, ingetrokken of vervangen, ook niet door een coördinator of admin.

Om iemand een stem te laten ophalen of vervangen, zou een blijvende koppeling tussen die persoon en de stem nodig zijn. Anoniem stemmen maakt die koppeling bewust niet aan.

Controleer jouw keuzes zorgvuldig voordat je ze indient.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Waarom anonieme stemmen geen redenen hebben

Nieuwe anonieme stemmen kunnen geen geschreven reden of bijlage bevatten. Redenen kunnen namen, persoonlijke gegevens, schrijfpatronen, vermeldingen of andere informatie bevatten die de kiezer identificeert. Ze zouden individuele stemmen ook gemakkelijker te onderscheiden maken van het samengevoegde resultaat.

Deelnemers kunnen de peiling nog steeds bespreken in de bijbehorende thread als discussie daar mogelijk is. Die reacties zijn gewone bijdragen aan de discussie met de naam van de auteur en zijn niet gekoppeld aan een anonieme stem.

<!-- translation-section: results-and-exports -->

## Resultaat en exports

Nadat de peiling is gesloten, wordt het resultaat berekend uit de losgekoppelde stemmen en weergegeven als totalen en andere samengevoegde resultaten die het peilingtype ondersteunt.

De applicatie publiceert geen identificatiecodes van stemmen, volgorde van indiening of tijdstippen van indiening. Peilingexports bevatten samengevoegde resultaten in plaats van een rij voor elke anonieme stem. Een gesloten STV-verkiezing kan wel in BLT-formaat worden geëxporteerd. Een BLT-export bevat de rangschikkingen van kandidaten die nodig zijn om de verkiezing opnieuw te tellen. Stembiljetten met dezelfde rangschikking worden gegroepeerd, zonder de identiteit van kiezers of metadata van stembiljetten.

Een anonieme peiling kan na het sluiten niet worden heropend.

<!-- translation-section: participation-verification -->

## Wie heeft deelgenomen

Nadat een anonieme peiling is gesloten, kan iedereen die het resultaat kan zien ook zien wie heeft deelgenomen. Niemand kan dit zien zolang stemmen mogelijk is.

Selecteer **Bekijk stemmen** om de lijst te zien. Deze toont altijd wie mocht stemmen. De lijst toont alleen of elke persoon heeft gestemd als genoeg mensen hebben gestemd. Daarvoor moet het quorum van de peiling zijn bereikt, als er een quorum is ingesteld. Anders moet minstens de helft van de stemgerechtigde kiezers hebben gestemd. Er zijn altijd minstens drie stemmen nodig. De lijst toont nooit hoe iemand heeft gestemd of wanneer.

Groepsleden en de kiezers van de peiling zien ook wanneer elke persoon lid werd van de groep en wie die persoon heeft uitgenodigd. Groepsadmins zien ook e-mailadressen om mensen met dezelfde naam te kunnen onderscheiden.

Omdat iedereen die het resultaat kan zien ook kan zien wie heeft gestemd, kan een eenzijdig resultaat onthullen hoe mensen hebben gestemd. Als bijvoorbeeld elke stem Eens is, was iedereen die heeft gestemd het eens.

Coördinatoren kunnen stemgerechtigde personen toevoegen zolang stemmen mogelijk is, ook nadat anderen hebben gestemd. Bestaande kiezers kunnen niet uit een anonieme peiling worden verwijderd.

<!-- translation-section: reminders -->

## Herinneringen

Bij een anonieme peiling die minstens 24 uur duurt, ontvangen stemgerechtigde personen die nog niet hebben gestemd één automatische herinnering tijdens de laatste 24 uur.

Wie de herinnering ontvangt, wordt uitsluitend bepaald op basis van de deelnamegegevens. Daarbij worden ingediende stemmen niet bekeken en wordt er geen koppeling mee gemaakt. Als de sluitingsdatum verandert, gebruikt de controle die elk uur plaatsvindt de huidige sluitingsdatum, zonder een afzonderlijk geplande herinnering voor de peiling bij te houden.

Peilingen waarbij de totale periode om te stemmen korter is dan 24 uur, versturen deze automatische herinnering niet.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Wat coördinatoren en admins kunnen zien

Via de applicatie kan een peilingcoördinator, groepsadmin of instantieadmin mogelijk het volgende zien:

- de peiling en de stemgerechtigde kiezers;
- of elke stemgerechtigde persoon heeft gestemd, als hun rol toegang toestaat en genoeg mensen hebben gestemd; en
- het samengevoegde resultaat nadat de peiling is gesloten.

Via de functies van de applicatie kunnen zij niet zien:

- welke keuzes bij een persoon horen;
- individuele stemmen of stempatronen;
- wanneer een bepaalde stem is ingediend; of
- een reden, bijlage, gebeurtenis of melding die bij een ingediende stem hoort.

<!-- translation-section: limits-of-anonymous-voting -->

## Grenzen van anoniem stemmen

Deze bescherming voorkomt dat gebruikers van de applicatie een ingediende stem aan de kiezer kunnen koppelen. Ze biedt geen cryptografische bescherming tegen een systeemoperator die de database, back-ups, serverlogs, het procesgeheugen, netwerkverkeer of een aangepaste versie van de applicatie kan inspecteren.

Het resultaat zelf kan ook informatie onthullen. Een klein aantal stemgerechtigden, een unaniem resultaat, een herkenbare combinatie van keuzes of informatie die buiten de peiling wordt gedeeld, kan het gemakkelijker maken om iemands keuzes af te leiden. Kiezers kunnen er ook voor kiezen om in de discussie bekend te maken wie ze zijn en hoe ze hebben gestemd, los van hun ingediende stem.

Houd rekening met het aantal stemgerechtigden en de gevoeligheid van het besluit wanneer je bepaalt of anoniem stemmen op applicatieniveau geschikt is.

<!-- translation-section: questions -->

## Vragen

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Kan iemand zien hoe ik heb gestemd?

Nee. Zodra genoeg mensen hebben gestemd, kunnen mensen die het resultaat kunnen zien ook zien of je hebt gestemd. Niemand kan je via de applicatie koppelen aan een ingediende stem. Tot die tijd blijft verborgen of je hebt gestemd.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Kan ik mijn stem bekijken nadat ik die heb ingediend?

Nee. De applicatie bevestigt dat je stem is vastgelegd en verwijdert daarna je keuzes uit de steminterface. De applicatie kan je stem niet ophalen zonder de koppeling te maken die anoniem stemmen juist moet voorkomen.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Kan ik mijn stem wijzigen of intrekken?

Nee. Er is geen koppeling waarmee de applicatie kan bepalen welke ingediende stem gewijzigd of verwijderd moet worden.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Ontvang ik een e-mail ter bevestiging van mijn stem?

Nee. Als je stemt, verschijnt alleen een bevestiging op het scherm en wordt je deelnameregistratie bijgewerkt. Er wordt geen bevestigingsmail verstuurd en er wordt geen melding of activiteit aangemaakt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Geeft een openbare peiling meer informatie prijs?

Nadat een openbare peiling is gesloten, kan iedereen het resultaat bekijken en zien wie heeft deelgenomen. Individuele stemmen en gegevens over lidmaatschap en uitnodigingen zijn niet zichtbaar.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Is anoniem stemmen geschikt voor elke verkiezing?

Nee. Het houdt identiteiten en stemmen binnen de applicatie gescheiden. Voor besluiten die bescherming tegen systeembeheerders vereisen of voor onafhankelijk verifieerbare cryptografische verkiezingen is een systeem nodig dat voor die eisen is ontworpen.
