---
title: Datenexport
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 988679ffd3d29834
  export-data: 9c2fb6ec7c75bcb6
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: a30576c8c19a7177
  export-data: 803ee9683efa0354
  export-group-data-as-csv: f3704a06f78e6221
  export-group-data-as-html: fc4870f6356bc7bb
  export-group-data-as-json: f4ba9713456f39f7
  print-thread-to-pdf: de3b58f0483d8e80
  import-your-group-data-on-another-loomio-server: 547a74152f154708
title_source: 29049648f87b87f5
title_generated: 9b85380b6981cdc8
---

<!-- translation-section: introduction -->

# Gruppendaten sichern oder exportieren

Mit dem Export von Gruppendaten kannst du:

- Mitgliederdaten herunterladen, um die Gruppenmitgliedschaften zu überprüfen.
- Threads, Kommentare und Abstimmungen deiner Gruppe archivieren oder analysieren.
- Ergebnisse von Abstimmungen in einer Tabellenkalkulation oder einem Skript öffnen.
- [Threads oder Abstimmungen für deine Unterlagen drucken oder als PDF speichern.](#print-thread-to-pdf)
- Deine Gruppe einschließlich ihrer Nutzenden, Threads, Abstimmungen und Dateien auf einen anderen Loomio-Server übertragen.

Du kannst diese Funktion nutzen, um von Loomios Hosting auf einen [selbst gehosteten Server](https://github.com/loomio/loomio) zu wechseln. Wenn du deinen eigenen Server betreibst und zu Loomios Hosting in den USA, der EU oder Australien wechseln möchtest, [kontaktiere uns](/contact).

[Kontaktiere uns](/contact), wenn du eine Gruppe von loomio.com auf einen regionalen Dienst übertragen möchtest (loomio.eu für Europa oder loomio.nz für Australien und Neuseeland).

<!-- translation-section: export-data -->

## Daten exportieren

Nur ein Gruppenadmin kann Gruppendaten exportieren. Öffne das Aktionsmenü der Gruppe und wähle **Gruppendaten exportieren**.

![Aktion „Gruppendaten exportieren“ im Menü der Oatmilk Cooperative](group_export_group_data.png)

Loomio bereitet den Export im Hintergrund vor und sendet dir einen Download-Link per E-Mail, sobald er fertig ist. Der Link ist eine Woche lang gültig.

<!-- translation-section: export-group-data-as-csv -->

### Gruppendaten als CSV exportieren

Verwende CSV, um Gruppendaten einschließlich Mitgliederdetails und Aktivitäten in einer Tabellenkalkulation wie Microsoft Excel oder Google Sheets zu prüfen.

<!-- translation-section: export-group-data-as-html -->

### Gruppendaten als HTML exportieren

Verwende HTML, um eine lesbare Kopie der Diskussionen und Abstimmungen deiner Gruppe zur Archivierung zu speichern.

<!-- translation-section: export-group-data-as-json -->

### Gruppendaten als JSON exportieren

Verwende JSON, um deine Gruppendaten auf einen selbst gehosteten Loomio-Server zu übertragen.

Der JSON-Export enthält:

- Die Gruppe, ihre Mitglieder und Beitrittsanfragen
- Threads, Kommentare, Reaktionen, Schlagwörter, Vorlagen, Benachrichtigungen und zugehörige Datensätze aus den enthaltenen Gruppen
- Abstimmungen, Optionen, Stimmen und Fazits; eine anonyme Abstimmung wird erst nach ihrer Beendigung aufgenommen
- Untergruppen, denen du angehörst
- Offene, geschlossene und für die Hauptgruppe sichtbare Untergruppen, wenn du als Admin ihrer Hauptgruppe die Hauptgruppe exportierst, auch wenn du diesen Untergruppen nicht angehörst
- Verweise auf Dateien und Bilder, die an die enthaltenen Inhalte angehängt sind

Der JSON-Export enthält nicht:

- Geheime Untergruppen, denen du nicht angehörst, einschließlich ihrer Mitgliedschaften und Inhalte
- Untergruppen, deren Löschung aussteht
- Anonyme Abstimmungen, die noch nicht beendet sind
- Direkte Threads und Abstimmungen, die nicht zur Gruppe gehören

<!-- translation-section: print-thread-to-pdf -->

## Thread als PDF drucken

Um einen einzelnen Thread für deine Unterlagen zu speichern, öffne sein Aktionsmenü und wähle **Drucken**. Loomio erstellt eine HTML-Seite mit den Kommentaren, Abstimmungen, Stimmen, Fazits und der Formatierung des Threads. Verwende die Druckfunktion deines Browsers, um die Seite zu drucken oder als PDF zu speichern, oder kopiere den Inhalt in ein anderes Dokument.

![Aktion „Drucken“ für die Diskussion über Mehrwegflaschen](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Deine Gruppendaten auf einem anderen Loomio-Server importieren

Dieser Abschnitt richtet sich an Admins, die einen selbst gehosteten Loomio-Server betreiben. Eine Anleitung zur Einrichtung findest du im [Loomio-Repository](https://github.com/loomio/loomio).

1. Kopiere die `.json`-Datei in den Ordner `import` des Containers:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Öffne die Rails-Konsole im laufenden Container:

```sh
docker exec -ti loomio-app rails console
```

3. Rufe den Importdienst auf:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
