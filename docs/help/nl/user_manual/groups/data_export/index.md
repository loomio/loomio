---
title: Data exporteren
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 988679ffd3d29834
  export-data: '024783a0614721d2'
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: bfcf93fc43193170
  export-data: 93ec9baf95165d82
  export-group-data-as-csv: 07e338a3d413dd14
  export-group-data-as-html: 656b6abe52be3b33
  export-group-data-as-json: 70a59487d4d1c46d
  print-thread-to-pdf: 3e994260cf4d6997
  import-your-group-data-on-another-loomio-server: 9ef403b930d1e1a3
title_source: 29049648f87b87f5
title_generated: 1acdc4eed6fbed0f
---

<!-- translation-section: introduction -->

# Groepsdata back-uppen of exporteren

Met de functie voor het exporteren van groepsdata kun je:

- Ledengegevens downloaden om het lidmaatschap van de groep te controleren.
- Threads, reacties en peilingen van je groep archiveren of analyseren.
- Het resultaat van peilingen openen in een spreadsheet of script.
- [Een thread of peiling afdrukken of opslaan als PDF voor je archief.](#print-thread-to-pdf)
- Je groep, inclusief de gebruikers, threads, peilingen en bestanden, verplaatsen naar een andere Loomio-server.

Je kunt deze functie gebruiken om van de hostingdienst van Loomio over te stappen naar een [server die je zelf host](https://github.com/loomio/loomio). Als je een eigen server draait en wilt overstappen naar de beheerde hosting van Loomio in de VS, de EU of Australië, [neem dan contact met ons op](/contact).

[Neem contact met ons op](/contact) als je een groep wilt verplaatsen van loomio.com naar een regionale dienst (loomio.eu voor Europa of loomio.nz voor Australië en Nieuw-Zeeland).

<!-- translation-section: export-data -->

## Data exporteren

Alleen een admin van de groep kan groepsdata exporteren. Open **Instellingen** op de groepspagina en selecteer **Groepsdata exporteren**.

![Actie Groepsdata exporteren op de instellingenpagina van Oatmilk Cooperative](group_export_group_data.png)

Loomio bereidt de export op de achtergrond voor en stuurt je een downloadlink per e-mail zodra de export klaar is. De link blijft één week actief.

<!-- translation-section: export-group-data-as-csv -->

### Groepsdata exporteren als CSV

Gebruik CSV om groepsdata, waaronder ledengegevens en activiteit, te bekijken in een spreadsheet zoals Microsoft Excel of Google Sheets.

<!-- translation-section: export-group-data-as-html -->

### Groepsdata exporteren als HTML

Gebruik HTML om een leesbare kopie van de discussies en peilingen van je groep op te slaan voor archivering.

<!-- translation-section: export-group-data-as-json -->

### Groepsdata exporteren als JSON

Gebruik JSON om je groepsdata te verplaatsen naar een Loomio-server die je zelf host.

De JSON-export bevat:

- De groep, de leden en de lidmaatschapsverzoeken
- Threads, reacties, emoji-reacties, labels, sjablonen, meldingen en bijbehorende records uit de opgenomen groepen
- Peilingen, opties, stemmen en conclusies; een anonieme peiling wordt pas opgenomen nadat deze is gesloten
- Subgroepen waar je lid van bent
- Open subgroepen, gesloten subgroepen en subgroepen die zichtbaar zijn voor de hoofdgroep wanneer je als admin van de hoofdgroep die hoofdgroep exporteert, ook als je geen lid bent van die subgroepen
- Verwijzingen naar bestanden en afbeeldingen die aan de opgenomen inhoud zijn toegevoegd

De JSON-export bevat geen:

- Geheime subgroepen waar je geen lid van bent, inclusief hun ledengegevens en inhoud
- Subgroepen die wachten op verwijdering
- Anonieme peilingen die nog niet zijn gesloten
- Directe threads en peilingen die niet bij de groep horen

<!-- translation-section: print-thread-to-pdf -->

## Thread afdrukken als PDF

Om één thread voor je archief op te slaan, open je het actiemenu van de thread en selecteer je **Afdrukken**. Loomio maakt een HTML-pagina met de reacties, peilingen, stemmen, conclusies en opmaak van de thread. Gebruik de afdrukfunctie van je browser om de pagina af te drukken of als PDF op te slaan, of kopieer de inhoud naar een ander document.

![Actie Afdrukken voor de discussie over statiegeldflessen](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Je groepsdata importeren op een andere Loomio-server

Deze sectie is bedoeld voor admins die een eigen Loomio-server draaien. Zie de [Loomio-repository](https://github.com/loomio/loomio) voor installatie-instructies.

1. Kopieer het `.json`-bestand naar de map `import` van de container:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Open de Rails-console in de actieve container:

```sh
docker exec -ti loomio-app rails console
```

3. Voer de importservice uit:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
