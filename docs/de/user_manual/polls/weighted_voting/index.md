---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: '01828c7e5f7e3c52'
  set-members-vote-weights: 0f118215483bc1b9
  use-weighted-voting-in-a-poll: 4e7dfbd23d459de9
  results: 68af76bec325743d
title: Gewichtete Abstimmung
title_source: 0b971991dfcacbab
title_generated: b8d6b85d250e6095
source_revision: 71554be8e61a76613b0707b8262302c22299a5d0
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Gewichtete Abstimmung

Bei einer gewichteten Abstimmung zählen manche Stimmen mehr als andere. Jeder Wähler hat ein Stimmgewicht. Zum Beispiel:

- Eine Wohngemeinschaft vergibt eine Stimme pro Immobilie. Ein Mitglied, das drei Immobilien vertritt, hat ein Stimmgewicht von `3`.
- Der Vorstand einer Genossenschaft trifft die Entscheidung, aber die Mitarbeitenden des operativen Betriebs beteiligen sich am Gespräch. Vorstandsmitglieder haben ein Stimmgewicht von `1`. Mitarbeitende des operativen Betriebs haben ein Stimmgewicht von `0`, sodass ihre Stimmen erfasst werden, aber das Ergebnis nicht verändern.
- Ein Unternehmen vergibt Stimmen an Aktionäre entsprechend ihrem Anteil am Unternehmen. Wer 12,5 % der Aktien besitzt, hat ein Stimmgewicht von `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Stimmgewichte der Mitglieder festlegen

Ein Gruppenadministrator kann die Seite **Mitglieder** der Gruppe öffnen und **Stimmengewichtung bearbeiten** wählen. Gib die Stimmgewichte ein und wähle **Stimmengewichte speichern**. Stimmgewichte können `0` oder größer sein und bis zu drei Nachkommastellen haben. Suche nach Namen oder E-Mail-Adresse, um jemanden zu finden. Um allen Mitgliedern dasselbe Stimmgewicht zu geben, wähle **Alle Stimmgewichte festlegen**.

![Stimmgewichte der Gruppenmitglieder](member-weights.png)

Das Stimmgewicht eines Mitglieds wird in jede Umfrage übernommen, zu der es hinzugefügt wird. Eine spätere Änderung wirkt sich nicht auf Umfragen aus, die das Stimmgewicht bereits übernommen haben.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Gewichtete Abstimmung in einer Umfrage verwenden

Wähle **Gewichtete Abstimmung verwenden** in den erweiterten Einstellungen der Umfrage. Du kannst die Funktion nach Beginn der Abstimmung ein- oder ausschalten. Wenn du sie ausschaltest, wird jedes Stimmgewicht in der Umfrage auf `1` gesetzt. Alle Stimmgewichte, die du für diese Umfrage geändert hast, gehen verloren.

Wenn deine Gruppe die gewichtete Abstimmung für ein festgelegtes Verfahren verwendet, wähle **Gewichtete Abstimmung verwenden** in einer [Umfragevorlage](/en/user_manual/polls/poll_templates). Umfragen, die mit dieser Vorlage gestartet werden, verwenden die gewichtete Abstimmung.

![Die Einstellung „Gewichtete Abstimmung verwenden“ in einer Umfrage](poll-setting.png)

Die gewichtete Abstimmung funktioniert mit diesen Umfragetypen: [Vorschlag](/en/user_manual/polls/proposals), [Wählen](/en/user_manual/polls/choose), [Punktzahl](/en/user_manual/polls/score), [Zuweisen](/en/user_manual/polls/allocate) und [Rang](/en/user_manual/polls/rank).

Du kannst die gewichtete Abstimmung und die [anonyme Abstimmung](/en/user_manual/polls/anonymous_voting) nicht in derselben Umfrage verwenden.

Um das Stimmgewicht eines einzelnen Wählers zu ändern, wähle **Wähler verwalten** und dann das Stimmgewicht neben dem Namen. Um die Stimmgewichte aller Wähler zu ändern, wähle **Alle Stimmgewichte festlegen**. Du kannst das Stimmgewicht jedes Mitglieds aus der Gruppe übernehmen oder allen denselben Wert geben. Wähler, die keine Gruppenmitglieder sind, erhalten ein Stimmgewicht von `1`.

![Die Schaltfläche „Wähler verwalten“ in einer Umfrage](poll-manage-voters.png)

![Wähler in einer Umfrage mit individuellen Stimmgewichten](poll-voter-weights.png)

<!-- translation-section: results -->

## Ergebnisse

Die Ergebnisse zeigen die ungewichteten und die gewichteten Gesamtwerte nebeneinander:

- Umfragen der Typen Vorschlag und Wählen zeigen **Abstimmungsbeiträge** und **Gewichtete Stimmen**.
- Umfragen der Typen Punktzahl, Zuweisen und Rang zeigen **Punkte** und **Gewichtete Punkte**.

Das Diagramm zeigt das gewichtete Ergebnis. Wähle eine Spaltenüberschrift, um stattdessen diese Spalte im Diagramm anzuzeigen. Bei den Wahlberechtigten und beim Quorum werden Personen gezählt, keine Stimmgewichte. Wer die Stimmen sehen kann, kann auch das Stimmgewicht jedes Wählers sehen.

![Das Ergebnis eines Vorschlags mit Abstimmungsbeiträgen und gewichteten Stimmen](weighted-proposal-result.png)
