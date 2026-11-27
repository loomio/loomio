---
title: Adatok exportálása
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
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
  introduction: 0ef47ce6fec748b5
  export-data: 5d8d83c6c45b3d1c
  export-group-data-as-csv: 22b142a5e977fb3f
  export-group-data-as-html: 6f960159abc4ffdf
  export-group-data-as-json: 8580585467a34b22
  print-thread-to-pdf: 60eff96097bbe7e7
  import-your-group-data-on-another-loomio-server: 80e5fcd8e05ed2d0
title_source: 29049648f87b87f5
title_generated: 5469a70f111d4c58
---

<!-- translation-section: introduction -->

# Csoportadatok biztonsági mentése vagy exportálása

A csoportadatok exportálásával a következőket teheted:

- Letöltheted a tagok adatait a csoport tagságának ellenőrzéséhez.
- Archiválhatod vagy elemezheted a csoportod szálait, hozzászólásait és szavazásait.
- Megnyithatod a szavazások eredményeit táblázatkezelőben vagy szkriptben.
- [Kinyomtathatsz vagy PDF-ként menthetsz egy szálat vagy szavazást a nyilvántartásodhoz.](#print-thread-to-pdf)
- Átköltöztetheted a csoportodat a felhasználóival, szálaival, szavazásaival és fájljaival együtt egy másik Loomio-szerverre.

Ezzel a funkcióval a Loomio tárhelyszolgáltatásáról [saját üzemeltetésű szerverre](https://github.com/loomio/loomio) költözhetsz. Ha saját szervert üzemeltetsz, és a Loomio felügyelt tárhelyszolgáltatására szeretnél költözni az USA-ban, az EU-ban vagy Ausztráliában, [lépj kapcsolatba velünk](/contact).

[Lépj kapcsolatba velünk](/contact), ha egy csoportot a loomio.com-ról valamelyik regionális szolgáltatásra szeretnél áthelyezni: Európában a loomio.eu-ra, Ausztráliában és Új-Zélandon pedig a loomio.nz-re.

<!-- translation-section: export-data -->

## Adatok exportálása

Csak a csoport adminja exportálhatja a csoport adatait. Nyisd meg a **Beállítások** oldalt a csoport oldalán, és válaszd ki a **Csoport adatok letöltése** lehetőséget.

![Csoport adatok letöltése művelet az Oatmilk Cooperative beállítási oldalán](group_export_group_data.png)

A Loomio a háttérben elkészíti az exportot, és amikor elkészült, e-mailben elküldi neked a letöltési linket. A link egy hétig érhető el.

<!-- translation-section: export-group-data-as-csv -->

### Csoportadatok exportálása CSV-ként

Használd a CSV-formátumot a csoport adatainak, köztük a tagok adatainak és tevékenységének áttekintéséhez egy táblázatkezelőben, például Microsoft Excelben vagy Google Táblázatokban.

<!-- translation-section: export-group-data-as-html -->

### Csoportadatok exportálása HTML-ként

Használd a HTML-formátumot a csoportod beszélgetéseinek és szavazásainak olvasható másolatként való mentéséhez, archiválás céljából.

<!-- translation-section: export-group-data-as-json -->

### Csoportadatok exportálása JSON-ként

Használd a JSON-formátumot a csoportod adatainak áthelyezéséhez egy saját üzemeltetésű Loomio-szerverre.

A JSON-export a következőket tartalmazza:

- A csoportot, a tagjait és a tagsági kérelmeket
- Az exportban szereplő csoportok szálait, hozzászólásait, reakcióit, címkéit, sablonjait, értesítéseit és kapcsolódó rekordjait
- A szavazásokat, lehetőségeket, szavazatokat és következtetéseket; a névtelen szavazások csak a lezárásuk után kerülnek bele
- Azokat az alcsoportokat, amelyeknek tagja vagy
- A nyílt, zárt és a szülőcsoport számára látható alcsoportokat, ha a szülőcsoportjukat annak adminjaként exportálod, akkor is, ha nem vagy tagja ezeknek azalcsoportoknak
- Az exportban szereplő tartalomhoz csatolt fájlokra és képekre mutató hivatkozásokat

A JSON-export nem tartalmazza a következőket:

- Azokat a titkos alcsoportokat, amelyeknek nem vagy tagja, beleértve a tagságukat és a tartalmukat
- A törlésre váró alcsoportokat
- A még le nem zárt névtelen szavazásokat
- A csoporthoz nem tartozó közvetlen szálakat és szavazásokat

<!-- translation-section: print-thread-to-pdf -->

## Szál nyomtatása PDF-be

Ha meg szeretnél őrizni egy szálat, nyisd meg a műveleti menüjét, és válaszd ki a **Nyomtatás** lehetőséget. A Loomio létrehoz egy HTML-oldalt a szál hozzászólásaival, szavazásaival, szavazataival, következtetéseivel és formázásával. A böngésződ nyomtatási eszközével nyomtasd ki vagy mentsd PDF-ként, vagy másold át a tartalmát egy másik dokumentumba.

![Nyomtatás művelet a visszaváltható palackokról szóló beszélgetésnél](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Csoportadatok importálása egy másik Loomio-szerverre

Ez a szakasz a saját Loomio-szervert üzemeltető adminisztrátoroknak szól. A beállítási útmutatót a [Loomio kódtárában](https://github.com/loomio/loomio) találod.

1. Másold a `.json` fájlt a konténer `import` mappájába:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Nyisd meg a Rails-konzolt a futó konténerben:

```sh
docker exec -ti loomio-app rails console
```

3. Futtasd az importálási szolgáltatást:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
