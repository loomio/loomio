---
title: Discussiesjablonen
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: 2308140934edbe9d
  how-templates-are-used: 67913b701f6f755a
  choose-who-is-notified-by-default: c3a8abecfdaa9063
  template-settings: 2fb5f27c2b978fa2
  example-bottle-trial-review: 8e3bc96941e704de
  create-a-template: 5c92f4175b4c2089
  manage-the-template-list: e11ea0b9d293553c
  share-templates-between-groups: 79de0bd17cea03f4
  let-members-create-templates: 5edbd8179cfa1172
  templates-for-non-members: e2e38a3d7fdf3d17
  related: 49540d851863497b
title_source: 5ac608aa42806d13
title_generated: c34ea3b3df5b6c70
---

<!-- translation-section: introduction -->

# Discussiesjablonen

Discussiesjablonen helpen jouw groep om discussies telkens op dezelfde manier te starten. Een sjabloon kan een titel, context, labels en instructies bevatten voor degene die de discussie start. Het bepaalt ook standaardinstellingen, zoals of de hele groep een melding krijgt en welke peilingen worden voorgesteld.

Elke nieuwe discussie in een groep begint met een sjabloon. Wanneer iemand **Start discussie** selecteert, toont Loomio de sjablonen van de groep. Ook **Lege sjabloon** is een sjabloon, dus jouw groep kan daarvan eveneens de standaardinstellingen aanpassen.

Sjablonen zijn geschikt voor processen die jouw groep herhaalt, zoals projectevaluaties, adviesprocessen, vergadervoorbereiding, financieringsbesluiten of het goedkeuren van documenten. Degene die de discussie start, kan alles nog aanpassen voordat de discussie begint.

<!-- translation-section: how-templates-are-used -->

## Hoe sjablonen worden gebruikt

1. Een lid selecteert **Start discussie** op de groepspagina.
2. Loomio toont de zichtbare sjablonen van de groep. Elk sjabloon toont de titel en ondertitel.
3. Het lid selecteert een sjabloon. Loomio opent het formulier voor een nieuwe discussie, ingevuld op basis van het sjabloon.
4. De sjabloonhulp verschijnt bovenaan het formulier als toelichting.
5. Het lid past de titel, context, labels en uitnodigingslijst aan en selecteert vervolgens **Start discussie**.

![](list.png)

Een wijziging aan een sjabloon heeft alleen invloed op discussies die na de wijziging worden gestart. Discussies die al met dat sjabloon zijn gestart, behouden hun inhoud en instellingen.

<!-- translation-section: choose-who-is-notified-by-default -->

## Kies wie standaard een melding krijgt

De instelling **Uitnodigen** bepaalt wie het formulier voor een nieuwe discussie standaard uitnodigt. Er zijn twee opties:

- **Iedereen in de groep**: de groep staat in het veld **Uitnodigen** van het discussieformulier en elk lid krijgt een melding wanneer de discussie begint.
- **Geen**: het veld **Uitnodigen** is aanvankelijk leeg. Niemand krijgt een melding, tenzij de auteur mensen toevoegt.

De ingebouwde sjablonen van Loomio, waaronder **Lege sjabloon**, gebruiken **Iedereen in de groep**. Als jouw groep niet wil dat alle leden bij elke nieuwe discussie een melding krijgen, pas dan de sjablonen aan die jouw groep gebruikt en stel **Uitnodigen** in op **Geen**.

![](use.png)

De auteur kan de uitnodigingslijst altijd aanpassen voordat de discussie begint. De auteur kan de groep verwijderen zodat niemand een melding krijgt, of in plaats daarvan specifieke mensen toevoegen. Deze instelling heeft alleen invloed op meldingen. Groepsleden kunnen de discussie nog steeds in de groep vinden en lezen, ongeacht welke optie je kiest.

De groep wordt alleen aan de uitnodigingslijst toegevoegd als de auteur de hele groep op de hoogte mag stellen. Admins mogen dit altijd. Leden mogen dit wanneer **Leden kunnen iedereen in de groep op de hoogte stellen** is ingeschakeld bij de toestemmingen van de groep.

<!-- translation-section: template-settings -->

## Sjablooninstellingen

Groepsadmins kunnen een sjabloon bewerken via het actiemenu naast het sjabloon in de sjablonenlijst. Het formulier heeft deze instellingen:

![](form.png)

- **Sjabloontitel**: de korte naam die in de sjablonenlijst wordt getoond.
- **Sjabloon ondertitel**: één regel die uitlegt wanneer je het sjabloon gebruikt.
- **Sjabloonhulp**: instructies bovenaan het formulier voor een nieuwe discussie. Gebruik deze om het proces uit te leggen en naar informatiebronnen te linken. Deze instructies maken geen deel uit van de discussie.
- **Groep**: of het sjabloon een discussie in de groep of een directe discussie start. Een directe discussie is alleen zichtbaar voor de mensen die ervoor zijn uitgenodigd.
- **Standaardtitel**: een titel die voor elke nieuwe discussie wordt ingevuld. De auteur kan deze aanpassen.
- **Voorbeeldtitel**: een voorbeeld dat in een leeg titelveld wordt getoond. Gebruik dit wanneer een standaardtitel niet bij elke discussie zou passen.
- **Labels**: labels die aan elke nieuwe discussie worden toegevoegd. De auteur kan ze verwijderen.
- **Beschrijving**: de begintekst van de discussie. Gebruik koppen, vragen of links om richting te geven aan wat mensen schrijven.
- **Uitnodigen**: of iedereen in de groep standaard wordt uitgenodigd. Zie [Kies wie standaard een melding krijgt](#choose-who-is-notified-by-default).
- **Peilingsjablonen**: peilingen die voor dit proces worden voorgesteld. Ze staan op het formulier voor een nieuwe discussie. Ze verschijnen ook als eerste wanneer iemand een peiling in de discussie start. Ze starten niet automatisch.
- **Gelijktijdige peilingen toestaan**: of er meer dan één peiling tegelijk open kan staan in de discussie.
- **Maximale lengte van reacties**: een optionele maximale lengte voor reacties.

Gebruik alleen een standaardtitel als die steeds blijft kloppen. Schrijf anders een voorbeeldtitel die de auteur aanspoort om de specifieke evaluatie, periode, het document of het besluit te benoemen.

<!-- translation-section: example-bottle-trial-review -->

## Voorbeeld: evaluatie van een proef met retourflessen

Oatmilk Cooperative evalueert na elke cyclus de proef met retourflessen. Het sjabloon heet "Evaluatie retourflessenproef" en heeft een standaardtitel. Het voegt het label "Retourflessenproef" toe. De context vraagt leden om het wekelijkse verslag te lezen en te kijken naar retourpercentages, wasregistraties, feedback van cafés en transportkosten. Het stelt een gevoelscheck voor, gevolgd door consent.

Dit werkt als sjabloon omdat het doel en de gegevens waarop de evaluatie is gebaseerd elke cyclus hetzelfde blijven. Alleen de waarnemingen en besluiten veranderen.

<!-- translation-section: create-a-template -->

## Maak een sjabloon

Groepsadmins kunnen **Nieuwe sjabloon** selecteren in de sjablonenlijst. Kies een voorbeeld uit de galerij van Loomio of begin met een lege sjabloon, pas het aan en sla het op.

Je kunt de galerij doorzoeken of filteren. Een voorbeeld wordt pas aan jouw groep toegevoegd wanneer je het opslaat.

<!-- translation-section: manage-the-template-list -->

## Beheer de sjablonenlijst

Wanneer een groep wordt aangemaakt, voegt Loomio een reeks sjablonen toe die passen bij het soort groep. Aanvankelijk zijn alleen **Lege sjabloon** en **Praktijkbespreking** zichtbaar. De andere sjablonen zijn verborgen en admins kunnen ze zichtbaar maken.

Groepsadmins kunnen het actiemenu naast een sjabloon gebruiken om:

- de inhoud en instellingen te bewerken;
- het te verbergen in de sjablonenlijst;
- het zichtbaar te maken vanuit **Verborgen sjablonen**;
- de volgorde van zichtbare sjablonen te wijzigen;
- het te exporteren als JSON-bestand; of
- het te verwijderen.

Als je een sjabloon verbergt, blijft het bewaard voor later gebruik. Als je een sjabloon verwijdert, worden discussies die ermee zijn gestart niet verwijderd.

<!-- translation-section: share-templates-between-groups -->

## Deel sjablonen tussen groepen

Selecteer **Exporteer JSON** in het actiemenu van een sjabloon om het als bestand te downloaden. Selecteer **Nieuwe sjabloon** en vervolgens **Importeer json** om het in een andere groep te gebruiken. Het formulier opent met de geïmporteerde inhoud, zodat je die kunt controleren voordat je opslaat.

Links naar aangepaste peilingsjablonen worden niet in het bestand opgenomen. Exporteer en importeer die peilingsjablonen afzonderlijk.

<!-- translation-section: let-members-create-templates -->

## Laat leden sjablonen maken

Standaard kunnen alleen groepsadmins sjablonen maken en bewerken. Een admin kan **Leden kunnen sjablonen maken.** inschakelen onder **Groepsinstellingen** → **Toestemmingen**.

Wanneer dit is ingeschakeld, kunnen leden discussie- en peilingsjablonen maken en hun eigen sjablonen bewerken. Admins kunnen elk sjabloon in de groep bewerken. Het sjabloon van een lid verschijnt in de sjablonenlijst van de groep zodra het is opgeslagen. Maak daarom afspraken over naamgeving en controle voordat je deze toestemming inschakelt.

<!-- translation-section: templates-for-non-members -->

## Sjablonen voor niet-leden

Als **Niet-leden kunnen discussies starten** is ingeschakeld, kiezen mensen buiten de groep uit dezelfde sjablonenlijst. Hun discussieformulier nodigt de groep nooit standaard uit. Zie [Verzamel privé-inzendingen](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Gerelateerd

- [Peilingsjablonen](/en/user_manual/polls/poll_templates)
