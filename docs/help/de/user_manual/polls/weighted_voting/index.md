---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: 1cc0b5130642217b
  results: a0eeeda5a9e70a97
generated:
  introduction: 8f8bb18a1084d4d6
  set-members-vote-weights: 2ea15e71f22a830b
  use-weighted-voting-in-a-poll: cb191088ab53c50d
  results: 8cc78a19849f89ef
title: Gewichtete Abstimmung
title_source: 0b971991dfcacbab
title_generated: b8d6b85d250e6095
source_revision: ad60e7728a4b8d578ec70fa26577556ee051c09d
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
needs_review:
  set-members-vote-weights: use "Stimme" instead of "Abstimmung" for "vote"
  introduction: use "Stimme" instead of "Abstimmung" for "vote"
---

<!-- translation-section: introduction -->

# Gewichtete Abstimmung

Bei einer gewichteten Abstimmung zählen manche Stimmen mehr als andere. Jede abstimmende Person hat ein Stimmgewicht. Zum Beispiel:

- Eine Wohngemeinschaft gibt jeder Wohneinheit eine Stimme. Ein Mitglied, das drei Wohneinheiten vertritt, hat ein Stimmgewicht von `3`.
- Eine Arbeitergenossenschaft gewährt Stimmrechte nach einer festgelegten Dauer der Mitgliedschaft. Neuere Mitglieder erhalten ein Stimmgewicht von `0`, sodass sie zur Diskussion beitragen und den Ablauf der Abstimmung kennenlernen können, ohne dass ihre Stimmen das Ergebnis beeinflussen.
- Ein Unternehmen gibt Anteilseignenden Stimmen entsprechend ihrem Eigentumsanteil. Wer 12,5 % der Anteile besitzt, hat ein Stimmgewicht von `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Stimmgewichte der Mitglieder festlegen

Ein Admin der Gruppe kann die Seite **Mitglieder** der Gruppe öffnen und **Stimmgewichte bearbeiten** auswählen. Gib die Stimmgewichte ein und wähle **Stimmengewichte speichern**. Stimmgewichte können `0` oder höher sein und bis zu drei Nachkommastellen haben. Suche nach Namen oder E-Mail-Adresse, um eine Person zu finden. Um jedem Mitglied dasselbe Stimmgewicht zu geben, wähle **Alle Stimmgewichte festlegen**.

![Stimmgewichte der Gruppenmitglieder](member-weights.png)

Das Stimmgewicht eines Mitglieds wird in jede Abstimmung übernommen, zu der das Mitglied hinzugefügt wird. Eine spätere Änderung wirkt sich nicht auf Abstimmungen aus, die dieses Stimmgewicht bereits übernommen haben.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Gewichtete Abstimmung in einer Abstimmung verwenden

Öffne **Weitere Einstellungen** im Abstimmungsformular und wähle **Gewichtete Abstimmung verwenden**. Du kannst die gewichtete Abstimmung auch nach Beginn der Stimmabgabe ein- oder ausschalten. Wenn du sie ausschaltest, werden alle Stimmgewichte in der Abstimmung auf `1` gesetzt. Alle Stimmgewichte, die du für diese Abstimmung geändert hast, gehen dabei verloren.

Wenn deine Gruppe für einen etablierten Ablauf gewichtete Abstimmungen verwendet, wähle **Gewichtete Abstimmung verwenden** in einer [Abstimmungsvorlage](/en/user_manual/polls/poll_templates). Abstimmungen, die mit dieser Vorlage gestartet werden, verwenden gewichtete Abstimmung.

![Die Einstellung Gewichtete Abstimmung verwenden in einer Abstimmung](poll-setting.png)

Gewichtete Abstimmung funktioniert mit diesen Abstimmungstypen: [Vorschlag](/en/user_manual/polls/proposals), [Auswählen](/en/user_manual/polls/choose), [Bewerten](/en/user_manual/polls/score), [Verteilen](/en/user_manual/polls/allocate) und [Ordnen](/en/user_manual/polls/rank).

Du kannst gewichtete Abstimmung und [anonyme Stimmabgabe](/en/user_manual/polls/anonymous_voting) nicht in derselben Abstimmung verwenden.

Um das Stimmgewicht einer abstimmenden Person zu ändern, wähle **Abstimmende verwalten** und anschließend das Stimmgewicht neben ihrem Namen. Um die Stimmgewichte aller Abstimmenden zu ändern, wähle **Alle Stimmgewichte festlegen**. Du kannst das Stimmgewicht jedes Mitglieds aus der Gruppe übernehmen oder allen denselben Wert geben. Abstimmende, die keine Gruppenmitglieder sind, erhalten ein Stimmgewicht von `1`.

![Die Schaltfläche Abstimmende verwalten in einer Abstimmung](poll-manage-voters.png)

![Abstimmende mit individuellen Stimmgewichten in einer Abstimmung](poll-voter-weights.png)

<!-- translation-section: results -->

## Ergebnis

Das Ergebnis zeigt die ungewichteten und die gewichteten Summen nebeneinander:

- Abstimmungen der Typen Vorschlag und Auswählen zeigen **Abstimmungsbeiträge** und **Gewichtete Stimmen**.
- Abstimmungen der Typen Bewerten, Verteilen und Ordnen zeigen **Punkte** und **Gewichtete Punkte**.

Das Diagramm zeigt das gewichtete Ergebnis. Wähle eine Spaltenüberschrift, um stattdessen die Werte dieser Spalte im Diagramm anzuzeigen. Wer die Stimmen sehen kann, kann auch das Stimmgewicht jeder abstimmenden Person sehen.

Bei Abstimmungen der Typen Vorschlag und Auswählen zeigt **Nicht abgestimmt** unter **Abstimmungsbeiträge** die Anzahl der Personen, die noch nicht abgestimmt haben, und unter **Gewichtete Stimmen** deren gesamtes Stimmgewicht. Diese Spalten und **% des Stimmgewichts der Stimmberechtigten** berücksichtigen im Diagramm auch diejenigen, die noch nicht abgestimmt haben. Bei **% des abgegebenen Stimmgewichts** bleibt **Nicht abgestimmt** leer und wird im Diagramm nicht berücksichtigt.

Stimmgewichte gelten auch für das [Quorum](/en/user_manual/polls/quorum) und die [Anforderungen an den Stimmenanteil](/en/user_manual/polls/vote_share_requirements).

Im folgenden Beispiel stimmt Jamie mit dem Stimmgewicht `2` für **Zustimmung**. Drei Personen stimmen mit den Stimmgewichten `1`, `0` und `0` für **Widerspruch**. Zwei Personen mit den Stimmgewichten `2` und `1` haben noch nicht abgestimmt.

Auf Zustimmung entfällt eine der vier abgegebenen Stimmen, aber zwei Drittel des abgegebenen Stimmgewichts. Die Hälfte des stimmberechtigten Stimmgewichts hat sich beteiligt, daher wurde das Quorum von 60 Prozent nicht erreicht.

![Das Ergebnis eines Vorschlags mit Stimmen und gewichteten Stimmen](weighted-proposal-result.png)
