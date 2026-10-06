---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 8f8bb18a1084d4d6
  set-members-vote-weights: 2ea15e71f22a830b
  use-weighted-voting-in-a-poll: 5754dcb5550474ea
  results: 57c653dc053885ca
title: Gewichtete Abstimmung
title_source: 0b971991dfcacbab
title_generated: b8d6b85d250e6095
source_revision: 3f73d4a156d9ffd3137ff085cc6ab58fbc4de46b
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-06'
needs_review:
  set-members-vote-weights: use "Stimme" instead of "Abstimmung" for "vote"
  use-weighted-voting-in-a-poll: use "Stimme" instead of "Abstimmung" for "vote"
  results: use "Bewerten" instead of "Ergebnis" for "Score"
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

Wähle **Gewichtete Abstimmung verwenden** in den erweiterten Einstellungen der Abstimmung. Du kannst diese Einstellung auch nach Beginn der Stimmabgabe ein- oder ausschalten. Wenn du sie ausschaltest, werden alle Stimmgewichte in der Abstimmung auf `1` gesetzt. Alle Stimmgewichte, die du für diese Abstimmung geändert hast, gehen dabei verloren.

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

Das Diagramm zeigt das gewichtete Ergebnis. Wähle eine Spaltenüberschrift, um stattdessen die Werte dieser Spalte im Diagramm anzuzeigen. Bei der Anzahl der Stimmberechtigten und beim Quorum zählen Personen, keine Stimmgewichte. Wer die Stimmen sehen kann, kann auch das Stimmgewicht jeder abstimmenden Person sehen.

![Das Ergebnis eines Vorschlags mit Stimmen und gewichteten Stimmen](weighted-proposal-result.png)
