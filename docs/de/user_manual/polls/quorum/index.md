---
title: Quorum
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 64f4ef2dc65b89d5
  example-scenario: b3c1e9ccb104a915
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Ein Quorum ist der Mindestanteil der Stimmberechtigten, der teilnehmen muss, damit eine Abstimmung gültig ist. Lege es fest, wenn für Entscheidungen eine bestimmte Beteiligung erforderlich ist.

Öffne beim Erstellen einer Abstimmung **Weitere Einstellungen** und gib unter **Teilnahmequorum** den erforderlichen Prozentsatz ein. Lass das Feld leer, wenn kein Quorum erforderlich ist.

![Die Quorumseinstellung mit einem Teilnahmequorum von 60 Prozent](./quorum-section.png)

Du kannst ein Quorum auch in einer [Abstimmungsvorlage](/en/user_manual/polls/poll_templates/) festlegen. Abstimmungen, die du mit dieser Vorlage erstellst, übernehmen es dann standardmäßig.

<!-- translation-section: example-scenario -->

## Beispiel

Die Hafermilch-Genossenschaft bespricht einen sechswöchigen Test mit Mehrwegflaschen. Nun muss sie das Budget für den Test genehmigen.

Jamie wählt **Jetzt abstimmen** und dann die Vorschlagsvorlage **Zustimmung**. Anschließend füllt Jamie Titel, Details, Optionen, Laufzeit und Einstellungen für die Stimmberechtigten aus.

![Titel, Details, Optionen, Laufzeit und Einstellungen für die Stimmberechtigten des Vorschlags](proposal-options.png)

Jamie beschränkt die Abstimmung auf die fünf Personen, die für das Budget des Tests verantwortlich sind.

Die Genossenschaft verlangt bei wichtigen Entscheidungen eine Beteiligung von 60 Prozent. Deshalb gibt Jamie **60** in das Feld für das Teilnahmequorum ein und startet den Vorschlag.

Bevor jemand abstimmt, zeigt der Ergebnisbereich an, dass das Quorum noch nicht erreicht ist.

![Noch keine Stimmen abgegeben und das Quorum von 60 Prozent noch nicht erreicht](pie-chart-0.png)

Jamie stimmt zu und Samira lehnt ab. Das Diagramm wird aktualisiert. Zwei von fünf Stimmberechtigten entsprechen jedoch nur 40 Prozent Beteiligung. Das Quorum ist weiterhin nicht erreicht.

![Zwei von fünf Stimmen abgegeben und das Quorum noch nicht erreicht](pie-chart-40.png)

Dann stimmt Alex zu. Damit haben drei von fünf Stimmberechtigten teilgenommen und das Quorum von 60 Prozent ist erreicht. Neben der Anforderung erscheint jetzt ein grünes Häkchen. Jamie kann die Abstimmung vorzeitig schließen oder auf die übrigen Stimmen warten.

![Drei von fünf Stimmen abgegeben und das Quorum von 60 Prozent erreicht](pie-chart-60.png)
