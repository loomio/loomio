---
title: Adatok exportálása
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
  introduction: f1698c80b1be0a4d
  export-data: c43983a7f192e20a
  export-group-data-as-csv: e6d247a9de86d244
  export-group-data-as-html: 8633b6e8ae580869
  export-group-data-as-json: 87d929e967db8070
  print-thread-to-pdf: 969dcf98961a7212
  import-your-group-data-on-another-loomio-server: 3d3e7708eddab6a6
title_source: 29049648f87b87f5
title_generated: 5469a70f111d4c58
---

<!-- translation-section: introduction -->

# Csoportadatok biztonsági mentése vagy exportálása

A csoportadatok exportálásával a következőket teheted:

- Letölthetsz egy, a tagok adatait tartalmazó fájlt a csoport tagságának ellenőrzéséhez.
- Letöltheted a csoportod tartalmát, beleértve a szálak és szavazások szövegét, archiváláshoz vagy elemzéshez.
- Megnyithatod a szavazások eredményeit táblázatkezelőben vagy szkriptnyelv segítségével.
- [Kinyomtathatod vagy PDF-ként mentheted a szálakat és szavazásokat archiváláshoz.](#print-thread-to-pdf)
- Átköltöztetheted a csoportodat az összes felhasználóval, szállal, szavazással és fájllal együtt egy másik Loomio-szerverre.

Ha a Loomio által üzemeltetett szerverekről [saját szerverre](https://github.com/loomio/loomio) szeretnél költözni, használhatod ezt a funkciót.

Ha saját Loomio-szervert üzemeltetsz, de már nem szeretnéd folytatni, a Loomio felügyelt tárhelyszolgáltatást kínál az USA-ban, az EU-ban és Ausztráliában. Ha ezek egyikére szeretnéd átköltöztetni a csoportodat, [lépj kapcsolatba velünk](/contact).

[Lépj kapcsolatba velünk](/contact), ha a Loomio-csoportodat a loomio.com globális tárhelyszolgáltatásáról valamelyik regionális szolgáltatásunkra szeretnéd áthelyezni: Európában a loomio.eu-ra, Ausztráliában és Új-Zélandon pedig a loomio.nz-re.

<!-- translation-section: export-data -->

## Adatok exportálása

Kattints a három pontra a csoport legördülő menüjének megnyitásához, és válaszd ki a **Csoport adatok letöltése** lehetőséget.

![Csoport adatok letöltése művelet az Oatmilk Cooperative menüjében](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Csoportadatok exportálása CSV-ként

*Ha táblázatkezelőben, például MS Excelben vagy Google Táblázatokban szeretnél dolgozni a csoport adataival.*

A Loomio a háttérben elkészíti a CSV-fájlt, és amikor elkészült, e-mailben elküldi neked a letöltési linket. A link egy hétig érhető el.

<!-- translation-section: export-group-data-as-html -->

### Csoportadatok exportálása HTML-ként

*Ha archiváláshoz szeretnéd menteni az adatokat.*

A Loomio a háttérben elkészíti a HTML-fájlt, és amikor elkészült, e-mailben elküldi neked a letöltési linket. A link egy hétig érhető el.

<!-- translation-section: export-group-data-as-json -->

### Csoportadatok exportálása JSON-ként

*Ha saját üzemeltetésű Loomio-példányra szeretnéd áthelyezni a csoportod adatait.*

Az exportáláshoz a csoport adminjának kell lenned. A JSON-export a következőket tartalmazza:

- A csoportot, a tagjait és a tagsági kérelmeket
- Az exportban szereplő csoportok szálait, hozzászólásait, reakcióit, címkéit, sablonjait, értesítéseit és kapcsolódó rekordjait
- A szavazásokat, lehetőségeket, szavazatokat és következtetéseket; a névtelen szavazások csak a lezárásuk után kerülnek bele
- Azokat az alcsoportokat, amelyeknek tagja vagy
- A nyílt és zárt alcsoportokat, ha a szülőcsoportjukat annak adminjaként exportálod, akkor is, ha nem vagy tagja ezeknek az alcsoportoknak
- Az exportban szereplő tartalomhoz csatolt fájlokra és képekre mutató hivatkozásokat

A JSON-export nem tartalmazza a következőket:

- Azokat a titkos alcsoportokat, amelyeknek nem vagy tagja, beleértve a tagságukat és a tartalmukat
- A törlésre váró alcsoportokat
- A még le nem zárt névtelen szavazásokat
- A csoporthoz nem tartozó közvetlen szálakat és szavazásokat

Hamarosan e-mailt kapsz a JSON-fájl letöltési linkjével.

<!-- translation-section: print-thread-to-pdf -->

## Szál nyomtatása PDF-be

Előfordulhat, hogy szükséged van egy szál másolatára, amelyet külön fájlarchívumban tárolhatsz.

A szál **Nyomtatás** funkciója megőrzi az összes hozzászólást, szavazást, szavazatot és következtetést, valamint a szál formázását.

A szál menüjében kattints a hárompontos menüre (⋯), és válaszd ki a **Nyomtatás** lehetőséget. A Loomio létrehoz egy HTML-oldalt, amelyet a böngésződ nyomtatási eszközével kinyomtathatsz vagy „PDF-ként menthetsz”.

Az oldalt kimásolhatod, majd beillesztheted egy dokumentumszerkesztőbe, fájlba vagy adattárba.

![Nyomtatás művelet a visszaváltható palackokról szóló beszélgetésnél](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Csoportadatok importálása egy másik Loomio-szerverre

A saját Loomio-szerver beállításához itt találsz útmutatót: https://github.com/loomio/loomio

Ha saját Loomio-példányt üzemeltetsz, és szeretnéd importálni az exportált adataidat:

Másold a .json fájlt a konténerpéldány `import` mappájába:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Nyisd meg a futó Rails-konzolt:

`docker exec -ti loomio-app rails console`

Hívd meg a szolgáltatást:

`GroupExportService.import('/import/your-group-data.json')`
