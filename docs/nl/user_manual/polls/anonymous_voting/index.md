---
title: Anoniem stemmen
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  introduction: 232715d57d2044e5
  how-anonymous-voting-protects-voters: 60cd107f87065dfc
  while-voting-is-open: 912e81e9d4fc38e3
  votes-cannot-be-changed: f87ac38716b4a8e2
  why-anonymous-votes-do-not-have-reasons: 6c9145d94cd97d3a
  results-and-exports: ef850b14ed16f042
  participation-verification: f16fa21721f604c8
  reminders: 0ebd2d0d76c585ab
  what-coordinators-and-administrators-can-see: 4e3c8b3e07ba25bd
  limits-of-anonymous-voting: 047eb3444ea73120
  questions: 81dbe0d658bb53fe
  can-a-coordinator-see-how-i-voted: 1573386757e11a03
  can-i-see-my-vote-after-submitting-it: d672b04cfc41b190
  can-i-change-or-withdraw-my-vote: 62fb31b77f10656e
  will-i-receive-an-email-confirming-my-vote: e996a33aa6b192f3
  does-a-public-poll-reveal-more-information: ed0a12fc3ae75184
  is-anonymous-voting-suitable-for-every-election: 41b55efb80255d79
title_source: 1bc4567506ad4d51
title_generated: a092c185ab7f2e64
---

<!-- translation-section: introduction -->

# Anoniem stemmen

Bij anoniem stemmen, ook wel blind stemmen genoemd, worden de gegevens over wie heeft gestemd gescheiden van de stemmen zelf. Nadat de peiling is gesloten, kan iedereen die de resultaten kan zien ook zien wie heeft deelgenomen. Niemand die Loomio gebruikt, kan een uitgebrachte stem koppelen aan de persoon die deze heeft uitgebracht.

Deze pagina legt uit hoe anoniem stemmen kiezers beschermt, welke gegevens bewaard blijven en waar de grenzen van die bescherming liggen.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Hoe anoniem stemmen kiezers beschermt

Een anonieme peiling bewaart twee afzonderlijke soorten gegevens:

| Deelnamegegevens | Uitgebrachte stemmen |
| --- | --- |
| Wie mag stemmen | De gekozen opties of scores |
| Wie is uitgenodigd en door wie | Bij welke peiling de stem hoort |
| Of elke stemgerechtigde heeft gestemd | Geen naam of gebruikersaccount |
| Geen gekozen opties of scores | Geen koppeling met deelnamegegevens |

Deze gegevens hebben geen gedeelde identificatiecode waarmee ze aan elkaar kunnen worden gekoppeld. Bij uitgebrachte stemmen worden ook het exacte tijdstip van indiening, uitnodigingsgegevens, schriftelijke toelichtingen, bijlagen en andere gegevens weggelaten die een kiezer kunnen identificeren.

Deze scheiding wordt afgedwongen wanneer de stem wordt opgeslagen. Ze berust dus niet alleen op het verbergen van namen in de interface.

<!-- translation-section: while-voting-is-open -->

## Zolang de stemming open is

De resultaten blijven voor iedereen verborgen totdat de peiling sluit. Dat geldt ook voor coördinatoren van de peiling, groepsbeheerders en instantie-​​beheerders die de applicatie gebruiken.

Wanneer iemand stemt:

- wordt de uitgebrachte stem opgeslagen zonder naam of koppeling met deelnamegegevens;
- wordt in de deelnamegegevens vastgelegd dat die persoon heeft gestemd;
- wordt er geen stemgebeurtenis, melding, e-mail, reactie of activiteit aangemaakt;
- krijgt die persoon na het indienen geen kopie van de gemaakte keuzes terug; en
- bevestigt de interface alleen dat de stem is vastgelegd.

In de deelnamegegevens staat niet precies wanneer iemand heeft gestemd. Uitgebrachte stemmen worden niet op tijdstip van indiening gesorteerd.

<!-- translation-section: votes-cannot-be-changed -->

## Stemmen kunnen niet worden gewijzigd

Elke stemgerechtigde kan één keer stemmen. Een uitgebrachte anonieme stem kan niet worden bekeken, gewijzigd, ingetrokken of vervangen, ook niet door een coördinator of beheerder.

Om iemand diens stem te laten terugvinden of vervangen, zou een blijvende koppeling tussen de persoon en de stem nodig zijn. Bij anoniem stemmen wordt die koppeling bewust niet gemaakt.

Controleer je keuzes zorgvuldig voordat je ze indient.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Waarom anonieme stemmen geen toelichting hebben

Bij nieuwe anonieme stemmen kun je geen schriftelijke toelichting of bijlage toevoegen. Een toelichting kan namen, persoonlijke gegevens, schrijfstijl, vermeldingen of andere informatie bevatten die de kiezer herkenbaar maakt. Daardoor zouden afzonderlijke stemmen ook gemakkelijker te onderscheiden zijn van het gezamenlijke resultaat.

Deelnemers kunnen de peiling nog steeds bespreken in de bijbehorende thread, als discussie daar mogelijk is. Die reacties zijn gewone bijdragen aan de discussie waarbij de naam van de schrijver zichtbaar is. Ze zijn niet aan een anonieme stem gekoppeld.

<!-- translation-section: results-and-exports -->

## Resultaten en exports

Na sluiting van de peiling worden de resultaten berekend uit de losstaande stemmen. Ze verschijnen als totalen en andere gezamenlijke resultaten die het type peiling ondersteunt.

De applicatie publiceert geen identificatiecodes van stemmen, volgorde van indiening of tijdstippen van indiening. Exports van peilingen bevatten gezamenlijke resultaten, geen afzonderlijke regel voor elke anonieme stem. Een gesloten STV-verkiezing kan wel in BLT-formaat worden geëxporteerd. Een BLT-export bevat de rangschikking van kandidaten die nodig is om de verkiezing opnieuw te tellen. Stembiljetten met dezelfde rangschikking worden gegroepeerd. De export bevat geen identiteit van kiezers of andere gegevens over de stembiljetten.

Een anonieme peiling kan na sluiting niet opnieuw worden geopend.

<!-- translation-section: participation-verification -->

## Wie heeft deelgenomen

Nadat een anonieme peiling is gesloten, kan iedereen die de resultaten kan zien ook zien wie heeft deelgenomen. Zolang de stemming open is, kan niemand dit zien.

Selecteer **Bekijk stemmen** om de lijst te bekijken. Daarin staat altijd wie mocht stemmen. Alleen als genoeg mensen hebben gestemd, staat er ook of elke persoon heeft gestemd. Daarvoor moet het quorum van de peiling zijn bereikt als er een quorum is ingesteld. Anders moet minstens de helft van de stemgerechtigden hebben gestemd. In beide gevallen zijn minstens drie stemmen nodig. De lijst laat nooit zien hoe iemand heeft gestemd of wanneer.

Groepsleden en de kiezers van de peiling zien ook wanneer elke persoon lid van de groep werd en wie die persoon heeft uitgenodigd. Groepsbeheerders zien ook e-mailadressen, om mensen met dezelfde naam van elkaar te onderscheiden.

Omdat iedereen die de resultaten kan zien ook kan zien wie heeft gestemd, kan een eenzijdige uitslag onthullen hoe mensen hebben gestemd. Als bijvoorbeeld elke stem Eens is, was iedereen die heeft gestemd het ermee eens.

Coördinatoren kunnen stemgerechtigden toevoegen zolang de stemming open is, ook nadat anderen hebben gestemd. Mensen die al hebben gestemd, kunnen niet uit een anonieme peiling worden verwijderd.

<!-- translation-section: reminders -->

## Herinneringen

Bij een anonieme peiling met een stemperiode van minstens 24 uur krijgen stemgerechtigden die nog niet hebben gestemd één automatische herinnering in de laatste 24 uur.

Voor de herinnering worden alleen de deelnamegegevens gebruikt. Uitgebrachte stemmen worden niet bekeken of eraan gekoppeld. Als de deadline verandert, gebruikt de controle die elk uur plaatsvindt de actuele deadline. Er wordt geen afzonderlijke herinnering voor de peiling ingepland.

Bij peilingen met een totale stemperiode van minder dan 24 uur wordt deze automatische herinnering niet verstuurd.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Wat coördinatoren en beheerders kunnen zien

Een coördinator van de peiling, groepsbeheerder of instantiebeheerder kan via de applicatie mogelijk het volgende zien:

- de peiling en de mensen die mogen stemmen;
- of elke stemgerechtigde heeft gestemd, als diens rol toegang geeft tot die informatie en genoeg mensen hebben gestemd; en
- de gezamenlijke resultaten nadat de peiling is gesloten.

Via de functies van de applicatie kunnen zij niet zien:

- welke keuzes bij een persoon horen;
- afzonderlijke stemmen of stempatronen;
- wanneer een bepaalde stem is uitgebracht; of
- een toelichting, bijlage, gebeurtenis of melding die bij een uitgebrachte stem hoort.

<!-- translation-section: limits-of-anonymous-voting -->

## Grenzen van anoniem stemmen

Deze bescherming voorkomt dat gebruikers van de applicatie een uitgebrachte stem aan een kiezer koppelen. Ze biedt geen cryptografische bescherming tegen een beheerder die de database, back-ups, serverlogboeken, het procesgeheugen, netwerkverkeer of een aangepaste versie van de applicatie kan onderzoeken.

Ook het resultaat zelf kan informatie prijsgeven. Bij een klein aantal stemgerechtigden, een unanieme uitslag, een opvallende combinatie van keuzes of informatie die buiten de peiling wordt gedeeld, kunnen de keuzes van een persoon gemakkelijker worden afgeleid. Kiezers kunnen er ook voor kiezen om buiten hun uitgebrachte stem, in de discussie, bekend te maken hoe ze hebben gestemd.

Houd rekening met het aantal kiesgerechtigden en de gevoeligheid van de beslissing wanneer je bepaalt of anoniem stemmen binnen de applicatie geschikt is.

<!-- translation-section: questions -->

## Vragen

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Kan iemand zien wat ik heb gestemd?

Nee. Zodra genoeg mensen hebben gestemd, kunnen mensen die de resultaten kunnen zien ook zien of je hebt gestemd. Niemand kan je via de applicatie koppelen aan een uitgebrachte stem. Tot die tijd blijft verborgen of je hebt gestemd.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Kan ik mijn stem bekijken nadat ik die heb uitgebracht?

Nee. De applicatie bevestigt dat je stem is vastgelegd en verwijdert daarna jouw keuzes uit de steminterface. De applicatie kan jouw stem niet terughalen zonder de koppeling te maken die anoniem stemmen juist voorkomt.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Kan ik mijn stem wijzigen of intrekken?

Nee. Er is geen koppeling waarmee de applicatie kan bepalen welke uitgebrachte stem moet worden gewijzigd of verwijderd.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Krijg ik een e-mail ter bevestiging van mijn stem?

Nee. Je krijgt alleen een bevestiging op het scherm en je deelnamegegevens worden bijgewerkt. Er wordt geen bevestigingsmail verstuurd en er wordt geen melding of activiteitsgebeurtenis aangemaakt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Geeft een openbare peiling meer informatie prijs?

Nadat een openbare peiling is gesloten, kan iedereen de resultaten zien en zien wie heeft deelgenomen. Ze kunnen geen afzonderlijke stemmen of gegevens over lidmaatschap en uitnodigingen zien.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Is anoniem stemmen geschikt voor elke verkiezing?

Nee. Binnen de applicatie blijven de identiteit van stemmers en hun stemmen gescheiden. Als een beslissing bescherming tegen systeembeheerders of een onafhankelijk controleerbare cryptografische verkiezing vereist, is een systeem nodig dat daarvoor is ontworpen.
