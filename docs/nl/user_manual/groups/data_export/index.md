---
title: Data exporteren
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 7b2351bb0cea105e
  export-data: bcda9e7eedd7c27c
  export-group-data-as-csv: 06e0c9dbddcae09c
  export-group-data-as-html: bb4f67eb29b9cdd0
  export-group-data-as-json: '0935e5aa1252b15e'
  print-thread-to-pdf: 99e200a369a6359b
  import-your-group-data-on-another-loomio-server: 402c568ef6da3a6a
title_source: 29049648f87b87f5
title_generated: 1acdc4eed6fbed0f
---

<!-- translation-section: introduction -->

# Groepsgegevens bewaren of exporteren

Met de functie voor het exporteren van groepsgegevens kun je:

- Een bestand met ledengegevens downloaden om het groepslidmaatschap te controleren.
- De inhoud van je groep downloaden, waaronder de tekst van discussies en peilingen, voor archivering of analyse.
- Peilingresultaten openen in een spreadsheet of programmeertaal.
- [Een discussie of peiling afdrukken of als pdf opslaan voor archivering.](#print-thread-to-pdf)
- Je groep, inclusief alle gebruikers, discussies, peilingen en bestanden, verplaatsen naar een andere Loomio-server.

Als je van een door Loomio beheerde server [naar je eigen server](https://github.com/loomio/loomio) wilt verhuizen, kun je deze functie gebruiken.

Als je je eigen Loomio-server niet meer wilt beheren, kun je gebruikmaken van Loomio-hosting in de VS, de EU of Australië. Wil je je groep naar een van deze servers verplaatsen? [Neem contact met ons op](/contact).

[Neem contact met ons op](/contact) als je je Loomio-groep wilt verplaatsen van Loomio's wereldwijde hostingdienst op loomio.com naar een van onze regionale diensten: loomio.eu voor Europa of loomio.nz voor Australië en Nieuw-Zeeland.

<!-- translation-section: export-data -->

## Gegevens exporteren

Open het groepsmenu via de drie puntjes en kies **Groepsdata exporteren**.

![De optie Groepsdata exporteren in het menu van Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Groepsgegevens exporteren als CSV

*Als je met de groepsgegevens wilt werken in een spreadsheet, zoals MS Excel of Google Sheets.*

Loomio maakt het CSV-bestand op de achtergrond klaar en mailt je een downloadlink zodra het bestand gereed is. De link blijft een week beschikbaar.

<!-- translation-section: export-group-data-as-html -->

### Groepsgegevens exporteren als HTML

*Als je de gegevens wilt bewaren in een archief.*

Loomio maakt het HTML-bestand op de achtergrond klaar en mailt je een downloadlink zodra het bestand gereed is. De link blijft een week beschikbaar.

<!-- translation-section: export-group-data-as-json -->

### Groepsgegevens exporteren als JSON

*Als je je groepsgegevens wilt verplaatsen naar een zelfgehoste Loomio-server.*

Je moet admin van de groep zijn om deze te exporteren. De JSON-export bevat:

- De groep, haar leden en verzoeken om lid te worden
- Discussies, reacties, emoji-reacties, labels, sjablonen, meldingen en bijbehorende gegevens van de opgenomen groepen
- Peilingen, opties, stemmen en conclusies; een anonieme peiling wordt pas opgenomen nadat deze is gesloten
- Subgroepen waarvan je lid bent
- Open en gesloten subgroepen als je hun hoofdgroep exporteert als admin van die hoofdgroep, ook als je geen lid bent van die subgroepen
- Verwijzingen naar bestanden en afbeeldingen die aan de opgenomen inhoud zijn toegevoegd

De JSON-export bevat niet:

- Geheime subgroepen waarvan je geen lid bent, inclusief hun leden en inhoud
- Subgroepen die wachten op verwijdering
- Anonieme peilingen die nog niet zijn gesloten
- Directe discussies en peilingen die niet bij de groep horen

Je ontvangt binnenkort een e-mail met een link om het JSON-bestand te downloaden.

<!-- translation-section: print-thread-to-pdf -->

## Discussie afdrukken als pdf

Je kunt een kopie van een discussie opslaan in een apart bestandsarchief.

Met **Afdrukken** blijven alle reacties, peilingen, stemmen en conclusies behouden, samen met de opmaak van de discussie.

Klik in het discussiemenu op de drie puntjes (⋯) en kies **Afdrukken**. Loomio maakt een HTML-pagina die je met de afdrukfunctie van je browser kunt afdrukken of als pdf kunt opslaan.

Je kunt de pagina kopiëren en in een documenteditor, bestand of gegevensarchief plakken.

![De optie Afdrukken voor de discussie over herbruikbare flessen](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Je groepsgegevens importeren op een andere Loomio-server

Instructies voor het opzetten van je eigen Loomio-server vind je op: https://github.com/loomio/loomio

Als je zelf een Loomio-server host en je geëxporteerde gegevens wilt importeren:

Kopieer het .json-bestand naar de map `import` van de container:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Open de Rails-console van de actieve server:

`docker exec -ti loomio-app rails console`

Roep de service aan:

`GroupExportService.import('/import/your-group-data.json')`
