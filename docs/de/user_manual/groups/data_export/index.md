---
title: Datenexport
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: 933dab9d3f96317c
  export-data: 68a7606c04134e40
  export-group-data-as-csv: c063220f6c01635d
  export-group-data-as-html: 2019ed78af84f3d2
  export-group-data-as-json: 0f573b5127e8cb51
  print-thread-to-pdf: 377dc595af2ca88b
  import-your-group-data-on-another-loomio-server: 5f0f3a5148b8494e
title_source: 29049648f87b87f5
title_generated: 9b85380b6981cdc8
needs_review:
  export-group-data-as-json: use "Stimme" instead of "Abstimmung" for "vote"
---

<!-- translation-section: introduction -->

# Gruppendaten sichern oder exportieren

Mit der Funktion zum Exportieren von Gruppendaten kannst du:

- Eine Datei mit Mitgliederdaten herunterladen, um die Gruppenmitgliedschaften zu überprüfen.
- Inhalte deiner Gruppe einschließlich der Texte von Threads und Abstimmungen zur Archivierung oder Analyse herunterladen.
- Ergebnisse von Abstimmungen in einer Tabellenkalkulation oder Skriptsprache öffnen.
- [Threads oder Abstimmungen zur Archivierung drucken oder als PDF speichern.](#print-thread-to-pdf)
- Deine Gruppe einschließlich aller Nutzenden, Threads, Abstimmungen und Dateien auf einen anderen Loomio-Server übertragen.

Wenn du von einem durch Loomio betriebenen Server [auf deinen eigenen](https://github.com/loomio/loomio) wechseln möchtest, kannst du diese Funktion nutzen.

Wenn du deinen eigenen Loomio-Server betreibst und das nicht mehr möchtest, bietet Loomio Hosting in den USA, der EU und Australien an. Wenn du deine Gruppe auf einen dieser Server übertragen möchtest, [kontaktiere uns](/contact).

[Kontaktiere uns](/contact), wenn du deine Loomio-Gruppe vom weltweit angebotenen Hosting auf loomio.com auf einen unserer regionalen Dienste übertragen möchtest: loomio.eu für Europa oder loomio.nz für Australien und Neuseeland.

<!-- translation-section: export-data -->

## Daten exportieren

Öffne das Dropdown-Menü der Gruppe, indem du auf die drei Punkte klickst, und wähle **Gruppendaten exportieren**.

![Aktion „Gruppendaten exportieren“ im Menü der Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Gruppendaten als CSV exportieren

*Wenn du mit den Gruppendaten in einer Tabellenkalkulation wie MS Excel oder Google Sheets arbeiten möchtest.*

Loomio erstellt die CSV-Datei im Hintergrund und sendet dir einen Download-Link per E-Mail, sobald sie fertig ist. Der Link ist eine Woche lang verfügbar.

<!-- translation-section: export-group-data-as-html -->

### Gruppendaten als HTML exportieren

*Wenn du die Daten zur Archivierung speichern möchtest.*

Loomio erstellt die HTML-Datei im Hintergrund und sendet dir einen Download-Link per E-Mail, sobald sie fertig ist. Der Link ist eine Woche lang verfügbar.

<!-- translation-section: export-group-data-as-json -->

### Gruppendaten als JSON exportieren

*Wenn du deine Gruppendaten auf eine selbst gehostete Loomio-Instanz übertragen möchtest.*

Du musst Admin der Gruppe sein, um sie zu exportieren. Der JSON-Export enthält:

- Die Gruppe, ihre Mitglieder und Beitrittsanfragen
- Threads, Kommentare, Reaktionen, Schlagwörter, Vorlagen, Benachrichtigungen und zugehörige Datensätze aus den enthaltenen Gruppen
- Abstimmungen, Optionen, Stimmen und Fazits; eine anonyme Abstimmung wird erst nach ihrer Beendigung aufgenommen
- Untergruppen, denen du angehörst
- Offene und geschlossene Untergruppen, wenn du als Admin ihrer Hauptgruppe die Hauptgruppe exportierst, auch wenn du diesen Untergruppen nicht angehörst
- Verweise auf Dateien und Bilder, die an die enthaltenen Inhalte angehängt sind

Der JSON-Export enthält nicht:

- Geheime Untergruppen, denen du nicht angehörst, einschließlich ihrer Mitgliedschaften und Inhalte
- Untergruppen, deren Löschung aussteht
- Anonyme Abstimmungen, die noch nicht beendet sind
- Direkte Threads und Abstimmungen, die nicht zur Gruppe gehören

Du erhältst in Kürze eine E-Mail mit einem Link zum Herunterladen der JSON-Datei.

<!-- translation-section: print-thread-to-pdf -->

## Thread als PDF drucken

Vielleicht möchtest du eine Kopie eines Threads in einem separaten Dateiarchiv speichern.

Beim **Drucken** eines Threads bleiben alle Kommentare, Abstimmungen, Stimmen und Fazits sowie die Formatierung des Threads erhalten.

Klicke im Thread auf das Drei-Punkte-Menü (⋯) und wähle **Drucken**. Loomio erstellt eine HTML-Seite, die du anschließend mit der Druckfunktion deines Browsers drucken oder „als PDF speichern“ kannst.

Du kannst die Seite kopieren und in einen Dokumenteditor, eine Datei oder ein Datenarchiv einfügen.

![Aktion „Drucken“ für die Diskussion über Mehrwegflaschen](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Deine Gruppendaten auf einem anderen Loomio-Server importieren

Eine Anleitung zum Einrichten deines eigenen Loomio-Servers findest du unter: https://github.com/loomio/loomio

Wenn du deine eigene Loomio-Instanz betreibst und deine exportierten Daten importieren möchtest:

Kopiere die .json-Datei in den Ordner `import` der Container-Instanz:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Öffne die laufende Rails-Konsole:

`docker exec -ti loomio-app rails console`

Rufe den Dienst auf:

`GroupExportService.import('/import/your-group-data.json')`
