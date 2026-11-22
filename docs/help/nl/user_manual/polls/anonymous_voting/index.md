---
title: Anoniem stemmen
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: abf0e5bc4894efeb
  how-anonymous-voting-protects-voters: da88cb1f0dff4836
  while-voting-is-open: 7a99bc1a77852698
  votes-cannot-be-changed: 103c65b001448bca
  why-anonymous-votes-do-not-have-reasons: 06aaae08f7750ba3
  results-and-exports: f9d8880aec3794da
  participation-verification: 0fa269306e839fa7
  reminders: 34717b18d320ebb6
  what-coordinators-and-administrators-can-see: fcf15decc17ad31f
  limits-of-anonymous-voting: 6cb2569de703f312
  questions: 81dbe0d658bb53fe
  can-a-coordinator-see-how-i-voted: 66fb8e7327d4f7fa
  can-i-see-my-vote-after-submitting-it: c453d2642b9142a7
  can-i-change-or-withdraw-my-vote: 8856a52d0328c623
  will-i-receive-an-email-confirming-my-vote: 0aaf520c61cb6a2b
  does-a-public-poll-reveal-more-information: 794c52537bcfd296
  is-anonymous-voting-suitable-for-every-election: b47883034c9da409
title_source: 1bc4567506ad4d51
title_generated: a092c185ab7f2e64
---

<!-- translation-section: introduction -->

# Anoniem stemmen

Anoniem stemmen, ook wel blind stemmen genoemd, houdt de registratie van wie heeft gestemd gescheiden van de stemmen zelf. Nadat de peiling is gesloten, kan iedereen die het resultaat kan zien ook zien wie heeft deelgenomen, maar niemand die Loomio gebruikt kan een stem koppelen aan de persoon die deze heeft uitgebracht.

Deze pagina legt uit hoe anoniem stemmen werkt, welke informatie wordt bewaard en wat de grenzen van deze bescherming zijn.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Hoe anoniem stemmen kiezers beschermt

Een anonieme peiling bewaart twee afzonderlijke verzamelingen gegevens:

| Deelnamegegevens | Ingediende stemmen |
| --- | --- |
| Wie mag stemmen | De geselecteerde opties of scores |
| Wie is uitgenodigd en door wie | De peiling waartoe de stem behoort |
| Of elke stemgerechtigde persoon heeft gestemd | Geen naam of gebruikersaccount |
| Geen geselecteerde opties of scores | Geen koppeling met deelnamegegevens |

Er is geen gedeelde identificatiecode die deze gegevens met elkaar verbindt. Ingediende stemmen bevatten ook geen tijdstippen van indiening, uitnodigingsgegevens, stemredenen, bijlagen of andere metadata die een kiezer zouden kunnen identificeren.

Deze scheiding vindt plaats wanneer de stem wordt opgeslagen en berust niet op alleen het verbergen van namen in de interface.

<!-- translation-section: while-voting-is-open -->

## Terwijl stemmen mogelijk is

Het resultaat blijft voor iedereen verborgen totdat de peiling sluit, ook voor threadadmins, groepsadmins en instantieadmins.

Wanneer iemand stemt:

- wordt de stem opgeslagen zonder naam of deelnamegegevens;
- worden de deelnamegegevens gemarkeerd om aan te geven dat die persoon heeft gestemd;
- wordt er geen stemgebeurtenis, melding, e-mail, reactie of activiteit aangemaakt;
- wordt er na het indienen geen kopie van de gemaakte keuzes teruggegeven; en
- bevestigt het scherm alleen dat de stem is geregistreerd.

De deelnamegegevens bevatten niet het exacte tijdstip waarop iemand heeft gestemd en ingediende stemmen worden niet op het tijdstip van indiening gesorteerd.

<!-- translation-section: votes-cannot-be-changed -->

## Stemmen kunnen niet worden gewijzigd

Elke stemgerechtigde persoon kan één keer stemmen. Een ingediende anonieme stem kan niet worden bekeken, gewijzigd, ingetrokken of vervangen, ook niet door een admin.

Om iemand een stem te laten ophalen of vervangen, zou een koppeling tussen die persoon en de stem nodig zijn. Anoniem stemmen vermijdt die koppeling bewust.

Controleer jouw keuzes zorgvuldig voordat je ze indient.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Waarom anonieme stemmen geen redenen hebben

Anonieme stemmen kunnen geen stemreden of bijlage bevatten. Redenen kunnen namen, persoonlijke gegevens, schrijfpatronen of vermeldingen bevatten die de kiezer identificeren en kunnen het gemakkelijker maken om individuele stemmen in het resultaat te herkennen.

Deelnemers kunnen de peiling nog steeds bespreken in de bijbehorende thread. Die reacties zijn gewone bijdragen met de naam van de auteur en zijn niet gekoppeld aan een anonieme stem.

<!-- translation-section: results-and-exports -->

## Resultaat en exports

Nadat de peiling is gesloten, berekent Loomio het resultaat uit de losgekoppelde stemmen en toont het de totalen voor dat peilingtype.

Loomio publiceert geen identificatiecodes van stemmen, volgorde van indiening of tijdstippen van indiening. Peilingexports bevatten alleen samengevoegde resultaten in plaats van een rij voor elke stem. De enige uitzondering is een gesloten STV-verkiezing, die voor een hertelling in BLT-formaat kan worden geëxporteerd. Een BLT-export bevat de rangschikkingen van kandidaten (gegroepeerd wanneer meerdere stembiljetten overeenkomen), zonder de identiteit van kiezers of metadata van stembiljetten.

Een anonieme peiling kan na het sluiten niet worden heropend.

<!-- translation-section: participation-verification -->

## Wie heeft deelgenomen

Nadat een anonieme peiling is gesloten, kan iedereen die het resultaat kan zien ook zien wie heeft deelgenomen. Niemand kan dit zien zolang stemmen mogelijk is.

Selecteer **Bekijk stemmen** om de lijst te zien. Deze toont altijd wie mocht stemmen en toont nooit hoe of wanneer iemand heeft gestemd. Of elke persoon heeft gestemd, wordt alleen getoond als genoeg mensen hebben deelgenomen: minstens het quorum van de peiling (als dat is ingesteld), anders minstens de helft van de stemgerechtigde kiezers, en altijd minstens drie stemmen.

Groepsleden en de kiezers van de peiling zien ook wanneer elke persoon lid werd van de groep en wie die persoon heeft uitgenodigd. Groepsadmins zien ook e-mailadressen om mensen met dezelfde naam te kunnen onderscheiden.

Omdat iedereen die het resultaat kan zien ook kan zien wie heeft gestemd, kan een eenzijdig resultaat onthullen hoe mensen hebben gestemd. Als bijvoorbeeld elke stem Eens is, was iedereen die heeft gestemd het eens.

Admins kunnen stemgerechtigde kiezers toevoegen zolang stemmen mogelijk is, ook nadat anderen hebben gestemd. Bestaande kiezers kunnen niet uit een anonieme peiling worden verwijderd.

<!-- translation-section: reminders -->

## Herinneringen

Bij een anonieme peiling die minstens 24 uur duurt, ontvangen stemgerechtigde personen die nog niet hebben gestemd één automatische herinnering tijdens de laatste 24 uur.

Loomio selecteert de ontvangers uitsluitend op basis van de deelnamegegevens, zonder ingediende stemmen te controleren.

Peilingen waarbij de periode om te stemmen korter is dan 24 uur, versturen deze automatische herinnering niet.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Wat admins kunnen zien

Via de applicatie kan een threadadmin, groepsadmin of instantieadmin mogelijk het volgende zien:

- de peiling en de stemgerechtigde kiezers;
- of elke stemgerechtigde persoon heeft gestemd (als de rol van de admin toegang toestaat en genoeg mensen hebben gestemd); en
- het samengevoegde resultaat nadat de peiling is gesloten.

Via de applicatie kunnen zij niet zien:

- welke keuzes bij een persoon horen;
- individuele stemmen of stempatronen;
- wanneer een stem is ingediend; of
- een stemreden, bijlage, gebeurtenis of melding die aan een stem is gekoppeld.

<!-- translation-section: limits-of-anonymous-voting -->

## Grenzen van anoniem stemmen

Anoniem stemmen voorkomt dat Loomio-gebruikers een stem aan een kiezer kunnen koppelen. Het biedt geen cryptografische bescherming tegen een serveroperator die de database, back-ups, serverlogs, het procesgeheugen, netwerkverkeer of aangepaste code kan inspecteren.

Het resultaat zelf kan ook aanwijzingen geven. Een kleine groep, een unanieme stemuitslag, een unieke combinatie van keuzes of reacties die buiten de peiling worden gedeeld, kunnen het gemakkelijker maken om iemands stem af te leiden.

Houd rekening met de grootte van de groep en de gevoeligheid van het besluit voordat je vertrouwt op anoniem stemmen op applicatieniveau.

<!-- translation-section: questions -->

## Vragen

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Kan iemand zien hoe ik heb gestemd?

Nee. Niemand die Loomio gebruikt kan je aan jouw stem koppelen. Zodra genoeg mensen hebben gestemd, kan iedereen die het resultaat kan zien ook zien of je hebt deelgenomen. Voordat die drempel is bereikt, blijft zelfs verborgen of je hebt gestemd.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Kan ik mijn stem bekijken nadat ik die heb ingediend?

Nee. Loomio bevestigt dat jouw stem is geregistreerd en verwijdert jouw keuzes van het scherm. Loomio kan jouw stem niet ophalen zonder de koppeling te maken die anoniem stemmen vermijdt.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Kan ik mijn stem wijzigen of intrekken?

Nee. Omdat er geen koppeling is tussen jou en jouw stem, kan Loomio niet bepalen welke stem gewijzigd of verwijderd moet worden.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Ontvang ik een e-mail ter bevestiging van mijn stem?

Nee. Als je stemt, verschijnt alleen een bevestiging op het scherm en wordt je deelnameregistratie bijgewerkt. Er wordt geen e-mail verstuurd en er wordt geen melding of activiteit aangemaakt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Geeft een openbare peiling meer informatie prijs?

Nadat een openbare peiling is gesloten, kan iedereen het resultaat bekijken en zien wie heeft deelgenomen. Individuele stemmen en gegevens over lidmaatschap en uitnodigingen zijn niet zichtbaar.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Is anoniem stemmen geschikt voor elke verkiezing?

Nee. Het houdt kiezers en stemmen binnen de applicatie gescheiden. Voor verkiezingen die bescherming tegen serverbeheerders of onafhankelijke cryptografische verificatie vereisen, is een systeem nodig dat voor die eisen is ontworpen.
