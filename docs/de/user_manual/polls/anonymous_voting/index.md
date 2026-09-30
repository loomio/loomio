---
title: Anonyme Abstimmung
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: d5c276b2785919c3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: cdaa1f5c3ca1e179
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 51460c8a6b663aba
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 3dd2c9e6d06debda
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 2ba76a1748304f96
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: 1b61b341df58b306
  how-anonymous-voting-protects-voters: 3982f2b244bd8f11
  while-voting-is-open: ba9d5fe3e4ac73d8
  votes-cannot-be-changed: c6e0dedb7acbf2e5
  why-anonymous-votes-do-not-have-reasons: af81c1e94b465d72
  results-and-exports: 5b3b41a24a7d1df1
  participation-verification: b516b0711e1dd2be
  reminders: eaa577057aa96ded
  what-coordinators-and-administrators-can-see: 5e1ea15f5509ac51
  limits-of-anonymous-voting: a3cd1a8a998e7473
  questions: 35697f4e2def282c
  can-a-coordinator-see-how-i-voted: 198c61eebc15e798
  can-i-see-my-vote-after-submitting-it: 8c327fd6f94af062
  can-i-change-or-withdraw-my-vote: 1bfe0504f8599cc8
  will-i-receive-an-email-confirming-my-vote: 502be1ed4d07e516
  does-a-public-poll-reveal-more-information: 904ac4b75b279c2d
  is-anonymous-voting-suitable-for-every-election: 4cdf000893c2e805
title_source: 1bc4567506ad4d51
title_generated: 911f939f43e472e8
---

<!-- translation-section: introduction -->

# Anonyme Abstimmung

Bei einer anonymen Abstimmung, auch geheime Abstimmung genannt, werden die Angaben darüber, wer abgestimmt hat, getrennt von den abgegebenen Stimmen gespeichert. Koordinatoren der Abstimmung können sehen, wer stimmberechtigt war. Sobald mindestens drei Personen abgestimmt haben, können sie auch die Teilnahme überprüfen. Wer die Anwendung nutzt, kann eine abgegebene Stimme keiner Person zuordnen.

Diese Seite erklärt, wie die anonyme Abstimmung die Abstimmenden schützt, welche Informationen gespeichert bleiben und wo die Grenzen dieses Schutzes liegen.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Wie die anonyme Abstimmung Abstimmende schützt

Bei einer anonymen Abstimmung werden zwei Arten von Einträgen getrennt gespeichert:

| Teilnahmeinformationen | Abgegebene Stimmen |
| --- | --- |
| Wer stimmberechtigt ist | Die gewählten Optionen oder vergebenen Punktzahlen |
| Wer eingeladen wurde und von wem | Zu welcher Abstimmung die Stimme gehört |
| Ob eine stimmberechtigte Person abgestimmt hat | Kein Name und kein Benutzerkonto |
| Keine gewählten Optionen oder Punktzahlen | Keine Verbindung zu einem Teilnahme­eintrag |

Es gibt keine gemeinsame Kennung, die diese Einträge verbindet. Abgegebene Stimmen enthalten auch keinen genauen Abgabezeitpunkt, keine Angaben zur Einladung, keine schriftlichen Begründungen, keine Anhänge und keine anderen Metadaten, die Rückschlüsse auf die abstimmende Person zulassen könnten.

Die Trennung erfolgt bereits beim Speichern der Stimme. Sie beruht nicht allein darauf, dass Namen in der Oberfläche ausgeblendet werden.

<!-- translation-section: while-voting-is-open -->

## Solange die Abstimmung offen ist

Die Ergebnisse bleiben bis zum Ende der Abstimmung für alle verborgen. Das gilt auch für Koordinatoren der Abstimmung, Gruppenadmins und Instanzadmins, die die Anwendung nutzen.

Wenn jemand abstimmt:

- wird die abgegebene Stimme ohne Namen oder Verbindung zum Teilnahme­eintrag gespeichert;
- wird im Teilnahme­eintrag vermerkt, dass die Person abgestimmt hat;
- werden weder ein Abstimmungsereignis noch eine Benachrichtigung, E-Mail, ein Kommentar oder ein Aktivitätseintrag erstellt;
- wird nach der Abgabe keine Kopie der gewählten Optionen zurückgegeben; und
- bestätigt die Oberfläche nur, dass die Stimme erfasst wurde.

Im Teilnahme­eintrag wird kein genauer Zeitpunkt der Stimmabgabe gespeichert. Abgegebene Stimmen werden nicht nach dem Zeitpunkt ihrer Abgabe sortiert.

<!-- translation-section: votes-cannot-be-changed -->

## Stimmen können nicht geändert werden

Jede stimmberechtigte Person kann einmal abstimmen. Eine abgegebene anonyme Stimme kann nicht eingesehen, geändert, zurückgezogen oder ersetzt werden. Das gilt auch für Koordinatoren und Admins.

Damit jemand die eigene Stimme abrufen oder ersetzen könnte, müsste eine dauerhafte Verbindung zwischen der Person und ihrer Stimme bestehen. Bei einer anonymen Abstimmung wird diese Verbindung bewusst nicht hergestellt.

Prüfe deine Auswahl sorgfältig, bevor du sie abgibst.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Warum anonyme Stimmen keine Begründungen enthalten

Neue anonyme Stimmen können weder eine schriftliche Begründung noch einen Anhang enthalten. Begründungen können Namen, persönliche Angaben, einen wiedererkennbaren Schreibstil, Erwähnungen oder andere Hinweise auf die abstimmende Person enthalten. Sie könnten einzelne Stimmen außerdem leichter vom Gesamtergebnis unterscheidbar machen.

Wo eine Diskussion verfügbar ist, können die Teilnehmenden die Abstimmung weiterhin im zugehörigen Thread besprechen. Diese Kommentare sind gewöhnliche, namentlich zugeordnete Diskussionsbeiträge und gehören nicht zu einer anonymen Stimme.

<!-- translation-section: results-and-exports -->

## Ergebnisse und Exporte

Nach dem Ende der Abstimmung werden die Ergebnisse aus den getrennt gespeicherten Stimmen berechnet. Angezeigt werden die Gesamtzahlen und weitere zusammengefasste Ergebnisse, die der Abstimmungstyp unterstützt.

Die Anwendung veröffentlicht weder Stimmenkennungen noch die Reihenfolge oder Zeitpunkte der Stimmabgabe. Exporte enthalten zusammengefasste Ergebnisse statt einer Zeile pro anonymer Stimme. Eine abgeschlossene STV-Wahl kann jedoch im BLT-Format exportiert werden. Ein BLT-Export enthält die Rangfolgen der Kandidierenden, die für eine erneute Auszählung nötig sind. Stimmen mit gleicher Rangfolge werden zusammengefasst. Identitäten der Abstimmenden und Metadaten zu einzelnen Stimmzetteln sind nicht enthalten.

Eine anonyme Abstimmung kann nach ihrem Ende nicht wieder geöffnet werden.

<!-- translation-section: participation-verification -->

## Überprüfung der Teilnahme

Koordinatoren der Abstimmung können die namentlich zugeordneten Teilnahme­einträge einsehen. Daraus geht immer hervor, wer stimmberechtigt war. Sobald mindestens drei Personen abgestimmt haben, ist auch zu sehen, ob die einzelnen Personen abgestimmt haben. Wie jemand abgestimmt hat, ist nie zu sehen. Endet die Abstimmung mit weniger als drei Stimmen, bleibt der Teilnahmestatus verborgen.

Andere Teilnehmende können diese namentlich zugeordneten Teilnahmeinformationen nicht einsehen. Der Zugriff auf die Abstimmungsergebnisse gewährt keinen Zugriff auf die Teilnahme­einträge.

Koordinatoren können weitere stimmberechtigte Personen hinzufügen, solange die Abstimmung offen ist, auch nachdem andere Personen abgestimmt haben. Personen, die bereits abgestimmt haben, können aus einer anonymen Abstimmung nicht entfernt werden.

<!-- translation-section: reminders -->

## Erinnerungen

Bei einer anonymen Abstimmung mit einer Laufzeit von mindestens 24 Stunden erhalten stimmberechtigte Personen, die noch nicht abgestimmt haben, in den letzten 24 Stunden eine automatische Erinnerung.

Wer eine Erinnerung erhält, wird ausschließlich anhand der Teilnahme­einträge bestimmt. Dafür werden keine abgegebenen Stimmen geprüft oder mit Teilnahme­einträgen verknüpft. Ändert sich die Frist, verwendet die stündliche Prüfung die aktuelle Frist. Für die Abstimmung wird kein gesonderter Erinnerungstermin gespeichert.

Bei Abstimmungen mit einer gesamten Abstimmungsdauer von weniger als 24 Stunden wird keine solche automatische Erinnerung versendet.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Was Koordinatoren und Admins sehen können

Über die Anwendung können Koordinatoren der Abstimmung, Gruppenadmins oder Instanzadmins je nach Zugriffsrecht Folgendes sehen:

- die Abstimmung und die stimmberechtigten Personen;
- ob eine stimmberechtigte Person abgestimmt hat, sofern ihre Rolle den Zugriff erlaubt und mindestens drei Personen abgestimmt haben; und
- die zusammengefassten Ergebnisse nach dem Ende der Abstimmung.

Mit Funktionen der Anwendung können sie Folgendes nicht sehen:

- welche Auswahl zu einer bestimmten Person gehört;
- einzelne Stimmen oder Abstimmungsmuster;
- wann eine bestimmte Stimme abgegeben wurde; oder
- eine Begründung, einen Anhang, ein Ereignis oder eine Benachrichtigung zu einer abgegebenen Stimme.

<!-- translation-section: limits-of-anonymous-voting -->

## Grenzen der anonymen Abstimmung

Dieser Schutz verhindert, dass Nutzer der Anwendung eine abgegebene Stimme der abstimmenden Person zuordnen. Er bietet keinen kryptografischen Schutz vor Betreibern, die die Datenbank, Sicherungskopien, Serverprotokolle, den Prozessspeicher, den Netzwerkverkehr oder eine veränderte Version der Anwendung untersuchen können.

Auch das Ergebnis selbst kann Informationen preisgeben. Bei wenigen Stimmberechtigten, einem einstimmigen Ergebnis, einer auffälligen Kombination gewählter Optionen oder Informationen, die außerhalb der Abstimmung geteilt wurden, lassen sich die Entscheidungen einer Person möglicherweise leichter erschließen. Abstimmende können sich auch selbst in einer Diskussion außerhalb ihrer abgegebenen Stimme zu erkennen geben.

Berücksichtige die Zahl der Wahlberechtigten und die Sensibilität der Entscheidung, wenn du prüfst, ob eine anonyme Abstimmung auf Anwendungsebene geeignet ist.

<!-- translation-section: questions -->

## Fragen

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Kann ein Koordinator sehen, wie ich abgestimmt habe?

Nein. Sobald mindestens drei Personen abgestimmt haben, kann ein Koordinator sehen, ob du abgestimmt hast. Über die Anwendung kann er deine Stimme aber keiner abgegebenen Stimme zuordnen. Bei weniger als drei Stimmen bleibt verborgen, ob du abgestimmt hast.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Kann ich meine Stimme nach der Abgabe sehen?

Nein. Die Anwendung bestätigt, dass deine Stimme erfasst wurde, und entfernt deine Auswahl dann aus der Abstimmungsansicht. Sie kann deine Stimme nicht wieder abrufen, ohne die Verbindung herzustellen, die bei einer anonymen Abstimmung vermieden werden soll.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Kann ich meine Stimme ändern oder zurückziehen?

Nein. Es gibt keine Verbindung, über die die Anwendung erkennen könnte, welche abgegebene Stimme sie ändern oder entfernen müsste.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Bekomme ich eine Bestätigung meiner Stimme per E-Mail?

Nein. Nach der Stimmabgabe erscheint nur eine Bestätigung auf dem Bildschirm, und dein Teilnahmevermerk wird aktualisiert. Es wird keine Bestätigungs-E-Mail versendet und keine Benachrichtigung oder Aktivität erstellt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Gibt eine öffentliche Abstimmung mehr Informationen preis?

Bei öffentlichem Zugriff können andere Personen möglicherweise die Abstimmung und nach ihrem Ende die zusammengefassten Ergebnisse sehen. Die Teilnahmevermerke mit Namen und die einzelnen anonymen Stimmen bleiben verborgen.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Eignet sich die anonyme Abstimmung für jede Wahl?

Nein. Sie trennt Identitäten und Stimmen innerhalb der Anwendung. Wenn eine Entscheidung Schutz vor den Betreibern des Systems oder eine unabhängig überprüfbare kryptografische Wahl erfordert, brauchst du ein System, das dafür ausgelegt ist.
