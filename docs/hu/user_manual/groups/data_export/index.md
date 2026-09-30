---
title: Adatok exportálása
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
  introduction: 706489a611c0fe5e
  export-data: 490a4b3b0124a80b
  export-group-data-as-csv: af6324b795e8cf39
  export-group-data-as-html: bf9ed4f3c88f6ba9
  export-group-data-as-json: e403fee8454e306a
  print-thread-to-pdf: df257e531d451963
  import-your-group-data-on-another-loomio-server: 891a93a8714cb864
title_source: 29049648f87b87f5
title_generated: 5469a70f111d4c58
---

<!-- translation-section: introduction -->

# Csoportadatok biztonsági mentése vagy exportálása

A csoportadatok exportálásával:

- Letöltheted a tagok adatait tartalmazó fájlt a csoporttagság ellenőrzéséhez.
- Letöltheted a csoport tartalmát, köztük a témák és szavazások szövegét archiváláshoz vagy elemzéshez.
- Megnyithatod a szavazások eredményeit táblázatkezelőben vagy programozási nyelvvel.
- [Kinyomtathatod vagy PDF-ként mentheted a témákat és szavazásokat archiváláshoz.](#print-thread-to-pdf)
- Átköltöztetheted a csoportodat, az összes felhasználóval, témával, szavazással és fájllal együtt, egy másik Loomio-szerverre.

Ezt a funkciót akkor is használhatod, ha a Loomio által üzemeltetett szerverekről [saját szerverre](https://github.com/loomio/loomio) szeretnél költözni.

Ha saját Loomio-szervert üzemeltetsz, de inkább a Loomio tárhelyszolgáltatását használnád, az USA-ban, az EU-ban és Ausztráliában működő szerverek közül választhatsz. Ha valamelyikre át szeretnéd költöztetni a csoportodat, [lépj kapcsolatba velünk](/contact).

[Lépj kapcsolatba velünk](/contact), ha a csoportodat a Loomio globális, loomio.com címen elérhető szolgáltatásából valamelyik regionális szolgáltatásunkba szeretnéd átköltöztetni: Európában a loomio.eu, Ausztráliában és Új-Zélandon a loomio.nz érhető el.

<!-- translation-section: export-data -->

## Adatok exportálása

A három pontra kattintva nyisd meg a csoport legördülő menüjét, majd válaszd a **Csoport adatok letöltése** lehetőséget.

![A Csoport adatok letöltése művelet az Oatmilk Cooperative menüjében](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Csoportadatok exportálása CSV-ként

*Ha táblázatkezelőben, például az MS Excelben vagy a Google Táblázatokban szeretnél dolgozni a csoport adataival.*

A Loomio a háttérben elkészíti a CSV-fájlt, majd e-mailben küld egy letöltési hivatkozást. A hivatkozás egy hétig érhető el.

<!-- translation-section: export-group-data-as-html -->

### Csoportadatok exportálása HTML-ként

*Ha archiváláshoz szeretnéd menteni az adatokat.*

A Loomio a háttérben elkészíti a HTML-fájlt, majd e-mailben küld egy letöltési hivatkozást. A hivatkozás egy hétig érhető el.

<!-- translation-section: export-group-data-as-json -->

### Csoportadatok exportálása JSON-ként

*Ha a csoport adatait egy saját üzemeltetésű Loomio-példányra szeretnéd átköltöztetni.*

A csoport exportálásához csoportadminisztrátornak kell lenned. A JSON-export a következőket tartalmazza:

- A csoportot, a tagjait és a csatlakozási kérelmeket
- Az exportált csoportok témáit, hozzászólásait, reakcióit, címkéit, sablonjait, értesítéseit és kapcsolódó adatait
- A szavazásokat, válaszlehetőségeket, leadott szavazatokat és következtetéseket; névtelen szavazás csak a lezárása után kerül bele
- Azokat az alcsoportokat, amelyeknek tagja vagy
- A nyitott és lezárt alcsoportokat, ha a szülőcsoport adminisztrátoraként exportálod a szülőcsoportot, akkor is, ha nem vagy tagja ezeknek az alcsoportoknak
- Az exportált tartalomhoz csatolt fájlokra és képekre mutató hivatkozásokat

A JSON-export nem tartalmazza:

- Azokat a titkos alcsoportokat, amelyeknek nem vagy tagja, valamint ezek tagságát és tartalmát
- A törlésre váró alcsoportokat
- A még le nem zárt névtelen szavazásokat
- A csoporthoz nem tartozó közvetlen témákat és szavazásokat

Hamarosan e-mailt kapsz a JSON-fájl letöltési hivatkozásával.

<!-- translation-section: print-thread-to-pdf -->

## Téma nyomtatása PDF-be

Ha egy témát külön fájlarchívumban szeretnél tárolni, készíthetsz róla másolatot.

A téma **Nyomtatás** funkcióval készített változata megőrzi az összes hozzászólást, szavazást, leadott szavazatot és következtetést, valamint a téma formázását.

A téma menüjében kattints a három pontra (⋯), majd válaszd a **Nyomtatás** lehetőséget. A Loomio létrehoz egy HTML-oldalt, amelyet a böngésződ nyomtatási funkciójával kinyomtathatsz vagy „PDF-ként menthetsz”.

Az oldalt kimásolhatod, majd beillesztheted egy dokumentumszerkesztőbe, fájlba vagy adattárba.

![Nyomtatás művelet a visszaváltható palackokról szóló beszélgetésnél](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Csoportadatok importálása egy másik Loomio-szerverre

A saját Loomio-szerver beállításához itt találsz útmutatót: https://github.com/loomio/loomio

Ha saját Loomio-példányt üzemeltetsz, és importálni szeretnéd az exportált adatokat:

Másold a .json fájlt a konténerpéldány `import` mappájába:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Nyisd meg a futó Rails-konzolt:

`docker exec -ti loomio-app rails console`

Hívd meg a szolgáltatást:

`GroupExportService.import('/import/your-group-data.json')`
