---
title: Anonyme Abstimmung
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: e64e1170824224fc
  how-anonymous-voting-protects-voters: 35b08d64454f1a98
  while-voting-is-open: c0e81d6103dc0619
  votes-cannot-be-changed: bdc6a2381af7a784
  why-anonymous-votes-do-not-have-reasons: 88915d03a526c74e
  results-and-exports: 6177b414e4f65245
  participation-verification: c40bb1fa8582fb28
  reminders: 229b2f29a527df20
  what-coordinators-and-administrators-can-see: f081886e3d48c939
  limits-of-anonymous-voting: 865440939c18a07f
  questions: 35697f4e2def282c
  can-a-coordinator-see-how-i-voted: b7b2a0f33163d87c
  can-i-see-my-vote-after-submitting-it: 9399d73b5edcfc15
  can-i-change-or-withdraw-my-vote: 2f38f2c3ddbb59c4
  will-i-receive-an-email-confirming-my-vote: d3cd105fbdda90b9
  does-a-public-poll-reveal-more-information: a7d6779921949378
  is-anonymous-voting-suitable-for-every-election: 3309e7e507488eff
title_source: 1bc4567506ad4d51
title_generated: 911f939f43e472e8
---

<!-- translation-section: introduction -->

# Anonyme Abstimmung

Anonymes Abstimmen, auch als blindes Abstimmen bekannt, trennt die Aufzeichnung darüber, wer abgestimmt hat, von den Stimmen selbst. Nachdem die Abstimmung beendet wurde, können alle, die das Ergebnis sehen können, auch sehen, wer teilgenommen hat. Niemand kann über Loomio eine Stimme mit der Person verknüpfen, die sie abgegeben hat.

Diese Seite erklärt, wie anonymes Abstimmen funktioniert, welche Informationen gespeichert bleiben und welche Grenzen dieser Schutz hat.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Wie anonymes Abstimmen die Abstimmenden schützt

Eine anonyme Abstimmung speichert zwei getrennte Arten von Datensätzen:

| Teilnahmedatensätze | Abgegebene Stimmen |
| --- | --- |
| Wer stimmberechtigt ist | Die ausgewählten Optionen oder Bewertungen |
| Wer eingeladen wurde und von wem | Die Abstimmung, zu der die Stimme gehört |
| Ob jede stimmberechtigte Person abgestimmt hat | Kein Name und kein Benutzerkonto |
| Keine ausgewählten Optionen oder Bewertungen | Keine Verknüpfung mit einem Teilnahmedatensatz |

Keine gemeinsame Kennung verbindet diese Datensätze. Bei abgegebenen Stimmen werden außerdem die Zeitpunkte der Stimmabgabe, Einladungsdetails, Begründungen, Anhänge und andere Metadaten weggelassen, die eine abstimmende Person identifizieren könnten.

Diese Trennung erfolgt beim Speichern der Stimme. Sie beruht nicht allein darauf, Namen in der Benutzeroberfläche auszublenden.

<!-- translation-section: while-voting-is-open -->

## Solange die Abstimmung offen ist

Das Ergebnis bleibt für alle verborgen, bis die Abstimmung beendet wird. Das gilt auch für Thread-Admins, Gruppenadmins und Instanzadmins.

Wenn eine Person abstimmt:

- wird ihre Stimme ohne ihren Namen oder ihren Teilnahmedatensatz gespeichert;
- wird ihr Teilnahmedatensatz so markiert, dass er zeigt, dass sie abgestimmt hat;
- werden kein Ereignis zur Stimmabgabe, keine Benachrichtigung, keine E-Mail, kein Kommentar und kein Aktivitätseintrag erstellt;
- wird nach der Stimmabgabe keine Kopie ihrer Auswahl zurückgegeben; und
- bestätigt die Benutzeroberfläche nur, dass ihre Stimme erfasst wurde.

Der Teilnahmedatensatz speichert keinen genauen Zeitpunkt der Stimmabgabe, und abgegebene Stimmen werden nicht nach dem Zeitpunkt der Stimmabgabe sortiert.

<!-- translation-section: votes-cannot-be-changed -->

## Stimmen können nicht geändert werden

Jede stimmberechtigte Person kann einmal abstimmen. Eine abgegebene anonyme Stimme kann nicht eingesehen, geändert, zurückgezogen oder ersetzt werden, auch nicht durch einen Admin.

Damit eine Person ihre Stimme abrufen oder ersetzen könnte, müsste eine Verknüpfung zwischen dieser Person und ihrer Stimme bestehen. Bei anonymen Abstimmungen wird diese Verknüpfung bewusst vermieden.

Prüfe deine Auswahl sorgfältig, bevor du deine Stimme abgibst.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Warum anonyme Stimmen keine Begründungen haben

Anonyme Stimmen können keine Begründung und keinen Anhang enthalten. Begründungen können Namen, persönliche Angaben, typische Schreibweisen oder Erwähnungen enthalten, die die abstimmende Person identifizieren. Sie könnten es außerdem erleichtern, einzelne Stimmen im Ergebnis zu erkennen.

Teilnehmende können weiterhin im Thread über die Abstimmung diskutieren. Diese Kommentare sind gewöhnliche Beiträge mit Namen und werden nicht mit einer anonymen Stimme verknüpft.

<!-- translation-section: results-and-exports -->

## Ergebnis und Exporte

Nachdem die Abstimmung beendet wurde, berechnet Loomio das Ergebnis aus den getrennt gespeicherten Stimmen und zeigt die Summen für den jeweiligen Abstimmungstyp an.

Loomio veröffentlicht keine Stimmenkennungen, keine Reihenfolge der Stimmabgabe und keine Zeitpunkte der Stimmabgabe. Exporte von Abstimmungen enthalten nur zusammengefasste Ergebnisse statt einer Zeile für jede Stimme. Die einzige Ausnahme ist eine beendete STV-Wahl, die für eine erneute Auszählung im BLT-Format exportiert werden kann. Ein BLT-Export listet die Rangfolgen der Kandidierenden auf, wobei übereinstimmende Stimmzettel zusammengefasst werden. Identitäten der Abstimmenden und Metadaten der Stimmzettel sind nicht enthalten.

Eine anonyme Abstimmung kann nach ihrem Ende nicht wieder geöffnet werden.

<!-- translation-section: participation-verification -->

## Wer teilgenommen hat

Nachdem eine anonyme Abstimmung beendet wurde, können alle, die ihr Ergebnis sehen können, auch sehen, wer teilgenommen hat. Solange die Abstimmung offen ist, kann dies niemand sehen.

Wähle **Stimmen ansehen**, um die Liste zu sehen. Sie zeigt immer, wer stimmberechtigt war, und nie, wie oder wann jemand abgestimmt hat. Ob die einzelnen Personen abgestimmt haben, zeigt sie nur, wenn genügend Personen teilgenommen haben: Das Quorum der Abstimmung muss erreicht sein, falls eines festgelegt wurde. Andernfalls muss mindestens die Hälfte der Stimmberechtigten abgestimmt haben. In jedem Fall sind mindestens drei Stimmen erforderlich.

Mitglieder der Gruppe und die Abstimmenden sehen außerdem, wann die einzelnen Personen der Gruppe beigetreten sind und wer sie eingeladen hat. Gruppenadmins sehen auch die E-Mail-Adressen, um Personen mit demselben Namen unterscheiden zu können.

Da alle, die das Ergebnis sehen können, auch sehen können, wer abgestimmt hat, kann ein einseitiges Ergebnis erkennen lassen, wie Personen abgestimmt haben. Wenn beispielsweise jede Stimme auf Zustimmung lautet, haben alle Personen, die abgestimmt haben, zugestimmt.

Admins können stimmberechtigte Personen hinzufügen, solange die Abstimmung offen ist, auch nachdem andere Personen bereits abgestimmt haben. Bereits hinzugefügte Abstimmende können nicht aus einer anonymen Abstimmung entfernt werden.

<!-- translation-section: reminders -->

## Erinnerungen

Bei einer anonymen Abstimmung, die mindestens 24 Stunden dauert, erhalten stimmberechtigte Personen, die noch nicht abgestimmt haben, innerhalb der letzten 24 Stunden eine automatische Erinnerung.

Loomio bestimmt ausschließlich anhand der Teilnahmedatensätze, wer die Erinnerung erhält, ohne abgegebene Stimmen zu prüfen.

Abstimmungen mit einer Dauer von weniger als 24 Stunden versenden diese automatische Erinnerung nicht.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Was Admins sehen können

Über die Anwendung können Thread-Admins, Gruppenadmins oder Instanzadmins je nach Berechtigung Folgendes sehen:

- die Abstimmung und ihre Stimmberechtigten;
- ob die einzelnen stimmberechtigten Personen abgestimmt haben, sofern ihre Rolle den Zugriff erlaubt und genügend Personen abgestimmt haben; und
- das zusammengefasste Ergebnis, nachdem die Abstimmung beendet wurde.

Mit den Funktionen der Anwendung können sie Folgendes nicht sehen:

- welche Auswahl zu einer Person gehört;
- einzelne Stimmen oder Abstimmungsmuster;
- wann eine Stimme abgegeben wurde; oder
- eine Begründung, einen Anhang, ein Ereignis oder eine Benachrichtigung, die mit einer Stimme verknüpft sind.

<!-- translation-section: limits-of-anonymous-voting -->

## Grenzen des anonymen Abstimmens

Anonymes Abstimmen verhindert, dass Personen, die Loomio nutzen, eine Stimme mit der abstimmenden Person verknüpfen. Es bietet keinen kryptografischen Schutz gegenüber Personen, die den Server betreiben und die Datenbank, Sicherungskopien, Serverprotokolle, den Prozessspeicher, den Netzwerkverkehr oder veränderten Code untersuchen können.

Auch das Ergebnis selbst kann Hinweise liefern. Eine kleine Gruppe, ein einstimmiges Ergebnis, eine einzigartige Kombination ausgewählter Optionen oder Kommentare, die außerhalb der Abstimmung geteilt werden, können Rückschlüsse auf die Stimme einer Person erleichtern.

Berücksichtige die Größe der Gruppe und die Sensibilität der Entscheidung, bevor du dich auf anonymes Abstimmen auf Anwendungsebene verlässt.

<!-- translation-section: questions -->

## Fragen

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Kann jemand sehen, wie ich abgestimmt habe?

Nein. Niemand kann dich über Loomio mit deiner Stimme verknüpfen. Sobald genügend Personen abgestimmt haben, können alle, die das Ergebnis sehen können, auch sehen, ob du teilgenommen hast. Bevor dieser Schwellenwert erreicht ist, bleibt selbst die Information verborgen, ob du abgestimmt hast.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Kann ich meine Stimme nach der Abgabe ansehen?

Nein. Loomio bestätigt, dass deine Stimme erfasst wurde, und entfernt deine Auswahl aus der Benutzeroberfläche. Es kann deine Stimme nicht abrufen, ohne die Verknüpfung herzustellen, die bei anonymen Abstimmungen bewusst vermieden wird.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Kann ich meine Stimme ändern oder zurückziehen?

Nein. Da es keine Verknüpfung zwischen dir und deiner Stimme gibt, kann Loomio nicht erkennen, welche Stimme geändert oder entfernt werden soll.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Erhalte ich eine E-Mail zur Bestätigung meiner Stimme?

Nein. Wenn du abstimmst, erscheint nur eine Bestätigung auf dem Bildschirm und dein Teilnahmedatensatz wird aktualisiert. Es wird keine E-Mail versendet und weder eine Benachrichtigung noch ein Aktivitätseintrag erstellt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Gibt eine öffentliche Abstimmung mehr Informationen preis?

Nachdem eine öffentliche Abstimmung beendet wurde, können alle ihr Ergebnis sehen und erfahren, wer teilgenommen hat. Einzelne Stimmen sowie Angaben zu Mitgliedschaften und Einladungen sind für sie nicht sichtbar.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Eignet sich anonymes Abstimmen für jede Wahl?

Nein. Die Anwendung hält Abstimmende und Stimmen getrennt. Wahlen, die Schutz vor Serverbetreibenden oder eine unabhängige kryptografische Überprüfung erfordern, benötigen ein System, das für diese Anforderungen entwickelt wurde.
