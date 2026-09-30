---
title: Datenexport
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
  introduction: ff3722e71aeafb2d
  export-data: 8969c3418e304214
  export-group-data-as-csv: c13383ae938c0ee2
  export-group-data-as-html: f07ba9400a75b6d5
  export-group-data-as-json: e32329d1a40cb630
  print-thread-to-pdf: 599cce57b4d6e2ed
  import-your-group-data-on-another-loomio-server: ee63aeab085c28cc
title_source: 29049648f87b87f5
title_generated: 9b85380b6981cdc8
---

<!-- translation-section: introduction -->

# Gruppendaten sichern oder exportieren

Mit der Funktion zum Exportieren von Gruppendaten kannst du:

- Eine Datei mit Mitgliederdaten herunterladen, um die Mitgliedschaft in deiner Gruppe zu prüfen.
- Die Inhalte deiner Gruppe einschließlich der Texte von Diskussionen und Abstimmungen zur Archivierung oder Analyse herunterladen.
- Abstimmungsergebnisse in einem Tabellenprogramm oder einer Skriptsprache öffnen.
- [Eine Diskussion oder Abstimmung zur Archivierung drucken oder als PDF speichern.](#print-thread-to-pdf)
- Deine Gruppe einschließlich aller Benutzer, Diskussionen, Abstimmungen und Dateien auf einen anderen Loomio-Server übertragen.

Wenn du von einem von Loomio betriebenen Server [auf einen eigenen Server](https://github.com/loomio/loomio) wechseln möchtest, kannst du diese Funktion nutzen.

Wenn du deinen eigenen Loomio-Server nicht länger betreiben möchtest, bietet Loomio Hosting in den USA, der EU und Australien an. Möchtest du deine Gruppe auf einen dieser Server übertragen, [kontaktiere uns](/contact).

[Kontaktiere uns](/contact), wenn du deine Loomio-Gruppe vom globalen Hostingdienst auf loomio.com auf einen unserer regionalen Dienste übertragen möchtest: loomio.eu für Europa oder loomio.nz für Australien und Neuseeland.

<!-- translation-section: export-data -->

## Daten exportieren

Öffne das Gruppenmenü über die drei Punkte und wähle **Gruppendaten exportieren**.

![Aktion „Gruppendaten exportieren“ im Menü der Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Gruppendaten als CSV exportieren

*Wenn du die Gruppendaten in einem Tabellenprogramm wie MS Excel oder Google Sheets bearbeiten möchtest.*

Loomio erstellt die CSV-Datei im Hintergrund und sendet dir per E-Mail einen Downloadlink, sobald sie bereit ist. Der Link ist eine Woche lang verfügbar.

<!-- translation-section: export-group-data-as-html -->

### Gruppendaten als HTML exportieren

*Wenn du die Daten archivieren möchtest.*

Loomio erstellt die HTML-Datei im Hintergrund und sendet dir per E-Mail einen Downloadlink, sobald sie bereit ist. Der Link ist eine Woche lang verfügbar.

<!-- translation-section: export-group-data-as-json -->

### Gruppendaten als JSON exportieren

*Wenn du deine Gruppendaten auf eine selbst gehostete Loomio-Instanz übertragen möchtest.*

Du musst Administrator der Gruppe sein, um sie zu exportieren. Der JSON-Export enthält:

- Die Gruppe, ihre Mitglieder und Mitgliedschaftsanfragen
- Diskussionen, Kommentare, Reaktionen, Schlagwörter, Vorlagen, Benachrichtigungen und zugehörige Datensätze aus den enthaltenen Gruppen
- Abstimmungen, Optionen, Stimmen und Fazits; eine anonyme Abstimmung ist erst nach ihrem Abschluss enthalten
- Untergruppen, denen du angehörst
- Offene und geschlossene Untergruppen, wenn du ihre übergeordnete Gruppe als deren Administrator exportierst, auch wenn du diesen Untergruppen nicht angehörst
- Verweise auf Dateien und Bilder, die an die enthaltenen Inhalte angehängt sind

Der JSON-Export enthält nicht:

- Geheime Untergruppen, denen du nicht angehörst, einschließlich ihrer Mitgliedschaften und Inhalte
- Untergruppen, die zur Löschung vorgemerkt sind
- Anonyme Abstimmungen, die noch nicht abgeschlossen sind
- Direkte Diskussionen und Abstimmungen, die nicht zur Gruppe gehören

Du erhältst in Kürze eine E-Mail mit einem Link zum Herunterladen der JSON-Datei.

<!-- translation-section: print-thread-to-pdf -->

## Diskussion als PDF drucken

Du kannst eine Kopie einer Diskussion erstellen, um sie in einem separaten Dateiarchiv aufzubewahren.

Mit **Drucken** bleiben alle Kommentare, Abstimmungen, Stimmen und Fazits sowie die Formatierung der Diskussion erhalten.

Klicke im Diskussionsmenü auf die drei Punkte (⋯) und wähle **Drucken**. Loomio erstellt eine HTML-Seite, die du mit der Druckfunktion deines Browsers drucken oder als PDF speichern kannst.

Du kannst die Seite kopieren und in einen Dokumenteneditor, eine Datei oder ein Datenarchiv einfügen.

![Aktion „Drucken“ für die Diskussion über Mehrwegflaschen](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Gruppendaten auf einem anderen Loomio-Server importieren

Eine Anleitung zum Einrichten deines eigenen Loomio-Servers findest du unter: https://github.com/loomio/loomio

Wenn du deine eigene Loomio-Instanz betreibst und deine exportierten Daten importieren möchtest:

Kopiere die .json-Datei in den Ordner `import` der Container-Instanz:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Öffne die Rails-Konsole der laufenden Instanz:

`docker exec -ti loomio-app rails console`

Rufe den Dienst auf:

`GroupExportService.import('/import/your-group-data.json')`
