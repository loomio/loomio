---
title: Data exporteren
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 455665f1a9869ad5
  export-data: 64c65578f2a86825
  export-group-data-as-csv: 5afb79256cbf73df
  export-group-data-as-html: e46608e827cc909a
  export-group-data-as-json: fdd65b390af1016a
  print-thread-to-pdf: efbf543b049e2262
  import-your-group-data-on-another-loomio-server: b0aba0cea3de9078
title_source: 29049648f87b87f5
title_generated: 1acdc4eed6fbed0f
---

<!-- translation-section: introduction -->

# Groepsdata back-uppen of exporteren

Met de functie voor het exporteren van groepsdata kun je:

- Een bestand met ledengegevens downloaden om het lidmaatschap van de groep te controleren.
- Inhoud van je groep downloaden, waaronder de tekst van threads en peilingen, voor archivering of analyse.
- Het resultaat van peilingen openen in een spreadsheet of scripttaal.
- [Een thread of peiling afdrukken of opslaan als PDF voor archivering.](#print-thread-to-pdf)
- Je groep, inclusief alle gebruikers, threads, peilingen en bestanden, verplaatsen naar een andere Loomio-server.

Als je ooit van door Loomio beheerde servers wilt overstappen [naar je eigen server](https://github.com/loomio/loomio), kun je deze functie gebruiken.

Als je een eigen Loomio-server draait en daarmee wilt stoppen, biedt Loomio beheerde hosting in de VS, de EU en Australië. Als je je groep naar een van deze servers wilt verplaatsen, [neem dan contact met ons op](/contact).

[Neem contact met ons op](/contact) als je je Loomio-groep wilt verplaatsen van de wereldwijde hostingdienst van Loomio op loomio.com naar een van onze regionale diensten: loomio.eu voor Europa of loomio.nz voor Australië en Nieuw-Zeeland.

<!-- translation-section: export-data -->

## Data exporteren

Open het groepsmenu door op de drie puntjes te klikken en selecteer **Groepsdata exporteren**.

![Actie Groepsdata exporteren in het menu van Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Groepsdata exporteren als CSV

*Om met de groepsdata te werken in een spreadsheet, zoals MS Excel of Google Sheets.*

Loomio maakt het CSV-bestand op de achtergrond en stuurt je een downloadlink per e-mail zodra het klaar is. De link is één week beschikbaar.

<!-- translation-section: export-group-data-as-html -->

### Groepsdata exporteren als HTML

*Om de data op te slaan voor archivering.*

Loomio maakt het HTML-bestand op de achtergrond en stuurt je een downloadlink per e-mail zodra het klaar is. De link is één week beschikbaar.

<!-- translation-section: export-group-data-as-json -->

### Groepsdata exporteren als JSON

*Om je groepsdata te verplaatsen naar een Loomio-installatie die je zelf host.*

Je moet admin van de groep zijn om deze te exporteren. De JSON-export bevat:

- De groep, de leden en de lidmaatschapsverzoeken
- Threads, reacties, emoji-reacties, labels, sjablonen, meldingen en bijbehorende records uit de opgenomen groepen
- Peilingen, opties, stemmen en conclusies; een anonieme peiling wordt pas opgenomen nadat deze is gesloten
- Subgroepen waar je lid van bent
- Open en gesloten subgroepen wanneer je als admin van de hoofdgroep die hoofdgroep exporteert, ook als je geen lid bent van die subgroepen
- Verwijzingen naar bestanden en afbeeldingen die aan de opgenomen inhoud zijn toegevoegd

De JSON-export bevat geen:

- Geheime subgroepen waar je geen lid van bent, inclusief hun ledengegevens en inhoud
- Subgroepen die wachten op verwijdering
- Anonieme peilingen die nog niet zijn gesloten
- Directe threads en peilingen die niet bij de groep horen

Je ontvangt binnenkort een e-mail met een link om het JSON-bestand te downloaden.

<!-- translation-section: print-thread-to-pdf -->

## Thread afdrukken als pdf

Je kunt een kopie van een thread nodig hebben om deze in een apart bestandsarchief op te slaan.

Met **Afdrukken** blijven alle reacties, peilingen, stemmen en conclusies behouden, samen met de opmaak van de thread.

Klik in de thread op het menu met de drie puntjes (⋯) en kies **Afdrukken**. Loomio maakt een HTML-pagina die je vervolgens met de afdrukfunctie van je browser kunt afdrukken of "opslaan als pdf".

Je kunt de pagina kopiëren en in een documenteditor, bestand of dataopslag plakken.

![Actie Afdrukken voor de discussie over statiegeldflessen](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Je groepsdata importeren op een andere Loomio-server

Ga voor instructies om je eigen Loomio-server op te zetten naar: https://github.com/loomio/loomio

Als je je eigen Loomio-installatie host en je geëxporteerde data wilt importeren:

Kopieer het .json-bestand naar de map `import` van de containerinstantie:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Open de actieve Rails-console:

`docker exec -ti loomio-app rails console`

Roep de service aan:

`GroupExportService.import('/import/your-group-data.json')`
