---
title: Anonyme Abstimmung
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: b8afdb08e55b22ea
  how-anonymous-voting-protects-voters: fae2e30be5c03422
  while-voting-is-open: 6c2d1903d2391db2
  votes-cannot-be-changed: '046646068ce07033'
  why-anonymous-votes-do-not-have-reasons: 515a6c03d7ed3817
  results-and-exports: d5f9aa1ad7e2d0db
  participation-verification: 842efa55f441037e
  reminders: caacb89867a7bb49
  what-coordinators-and-administrators-can-see: e669f6aeaf5165b9
  limits-of-anonymous-voting: b7114a5d7fe1a230
  questions: 35697f4e2def282c
  can-a-coordinator-see-how-i-voted: 20ac5720e43b944d
  can-i-see-my-vote-after-submitting-it: 6b9c5c4e1089a7a0
  can-i-change-or-withdraw-my-vote: 6a5a22b918b731d2
  will-i-receive-an-email-confirming-my-vote: e8fc2f9252ff4b45
  does-a-public-poll-reveal-more-information: a7d6779921949378
  is-anonymous-voting-suitable-for-every-election: 81863080a1e7cb8e
title_source: 1bc4567506ad4d51
title_generated: 911f939f43e472e8
needs_review:
  introduction: use "Stimme" instead of "Abstimmung" for "vote"
  how-anonymous-voting-protects-voters: use "Stimme" instead of "Abstimmung" for "vote"
  while-voting-is-open: use "Stimme" instead of "Abstimmung" for "vote"
  why-anonymous-votes-do-not-have-reasons: use "Stimme" instead of "Abstimmung" for "vote"
  results-and-exports: use "Stimme" instead of "Abstimmung" for "vote"
  participation-verification: use "Stimme" instead of "Abstimmung" for "vote"; use "Zustimmung" instead of "Dafür" for "agree"
  reminders: use "Stimme" instead of "Abstimmung" for "vote"
  what-coordinators-and-administrators-can-see: use "Stimme" instead of "Abstimmung" for "vote"
  limits-of-anonymous-voting: use "Entscheidung" instead of "Abstimmung" for "decision"; use "Stimme" instead of "Abstimmung" for "vote"
  does-a-public-poll-reveal-more-information: use "Stimme" instead of "Abstimmung" for "vote"
---

<!-- translation-section: introduction -->

# Anonyme Abstimmung

Anonymes Abstimmen, auch als blindes Abstimmen bekannt, trennt die Aufzeichnung darüber, wer abgestimmt hat, von den Stimmen selbst. Nachdem die Abstimmung beendet wurde, können alle, die das Ergebnis sehen können, auch sehen, wer teilgenommen hat. Niemand kann über Loomio eine abgegebene Stimme mit der Person verknüpfen, die sie abgegeben hat.

Diese Seite erklärt, welchen Schutz anonymes Abstimmen bietet, welche Informationen gespeichert bleiben und welche Grenzen diese Garantie hat.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Wie anonymes Abstimmen die Abstimmenden schützt

Eine anonyme Abstimmung speichert zwei getrennte Arten von Datensätzen:

| Teilnahmedatensätze | Abgegebene Stimmen |
| --- | --- |
| Wer stimmberechtigt ist | Die ausgewählten Optionen oder Bewertungen |
| Wer eingeladen wurde und von wem | Die Abstimmung, zu der die Stimme gehört |
| Ob jede stimmberechtigte Person abgestimmt hat | Kein Name und kein Benutzerkonto |
| Keine ausgewählten Optionen oder Bewertungen | Keine Verknüpfung mit einem Teilnahmedatensatz |

Es gibt keine gemeinsame Kennung, die diese Datensätze verbindet. Bei abgegebenen Stimmen werden auch der tatsächliche Zeitpunkt der Stimmabgabe, Einladungsinformationen, schriftliche Begründungen, Anhänge und andere Metadaten weggelassen, die helfen könnten, eine abstimmende Person zu identifizieren.

Diese Trennung wird beim Speichern der Stimme durchgesetzt. Sie beruht nicht allein darauf, Namen in der Benutzeroberfläche auszublenden.

<!-- translation-section: while-voting-is-open -->

## Solange die Abstimmung offen ist

Das Ergebnis bleibt für alle verborgen, bis die Abstimmung beendet wird. Das gilt auch für Abstimmungskoordinierende, Gruppenadmins und Instanzadmins, die die Anwendung nutzen.

Wenn eine Person abstimmt:

- wird ihre abgegebene Stimme ohne ihren Namen oder ihren Teilnahmedatensatz gespeichert;
- wird ihr Teilnahmedatensatz so markiert, dass er zeigt, dass sie abgestimmt hat;
- werden kein Ereignis zur Stimmabgabe, keine Benachrichtigung, keine E-Mail, kein Kommentar und kein Aktivitätseintrag erstellt;
- wird nach der Stimmabgabe keine Kopie ihrer Auswahl zurückgegeben; und
- bestätigt die Benutzeroberfläche nur, dass ihre Stimme erfasst wurde.

Der Teilnahmedatensatz speichert keinen genauen Zeitpunkt der Stimmabgabe. Abgegebene Stimmen werden nicht nach dem Zeitpunkt der Stimmabgabe sortiert.

<!-- translation-section: votes-cannot-be-changed -->

## Stimmen können nicht geändert werden

Jede stimmberechtigte Person kann einmal abstimmen. Eine abgegebene anonyme Stimme kann nicht eingesehen, geändert, zurückgezogen oder ersetzt werden, auch nicht durch Koordinierende oder Admins.

Damit eine Person ihre Stimme abrufen oder ersetzen könnte, müsste eine dauerhafte Verknüpfung zwischen dieser Person und der Stimme bestehen. Bei anonymen Abstimmungen wird diese Verknüpfung bewusst nicht erstellt.

Prüfe deine Auswahl sorgfältig, bevor du deine Stimme abgibst.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Warum anonyme Stimmen keine Begründungen haben

Neue anonyme Stimmen können keine schriftliche Begründung und keinen Anhang enthalten. Begründungen können Namen, persönliche Angaben, typische Schreibweisen, Erwähnungen oder andere Informationen enthalten, die die abstimmende Person identifizieren. Außerdem würden sie es erleichtern, einzelne Stimmen vom zusammengefassten Ergebnis zu unterscheiden.

Teilnehmende können weiterhin im Thread über die Abstimmung diskutieren, sofern dort eine Diskussion möglich ist. Diese Kommentare sind gewöhnliche Diskussionsbeiträge mit Namen und werden nicht mit einer anonymen Stimme verknüpft.

<!-- translation-section: results-and-exports -->

## Ergebnis und Exporte

Nachdem die Abstimmung beendet wurde, wird das Ergebnis aus den getrennt gespeicherten Stimmen berechnet und als Summen sowie in weiteren zusammengefassten Formen angezeigt, die der Abstimmungstyp unterstützt.

Die Anwendung veröffentlicht keine Stimmenkennungen, keine Reihenfolge der Stimmabgabe und keine Zeitpunkte der Stimmabgabe. Exporte von Abstimmungen enthalten zusammengefasste Ergebnisse statt einer Zeile für jede anonyme Stimme. Eine Ausnahme ist eine beendete STV-Wahl, die im BLT-Format exportiert werden kann. Ein BLT-Export enthält die Rangfolgen der Kandidierenden, die für eine erneute Auszählung der Wahl benötigt werden. Stimmen mit derselben Rangfolge werden zusammengefasst. Identitäten der Abstimmenden und Metadaten der Stimmzettel sind nicht enthalten.

Eine anonyme Abstimmung kann nach ihrem Ende nicht wieder geöffnet werden.

<!-- translation-section: participation-verification -->

## Wer teilgenommen hat

Nachdem eine anonyme Abstimmung beendet wurde, können alle, die ihr Ergebnis sehen können, auch sehen, wer teilgenommen hat. Solange die Abstimmung offen ist, kann dies niemand sehen.

Wähle **Stimmen ansehen**, um die Liste zu sehen. Sie zeigt immer, wer stimmberechtigt war. Ob die einzelnen Personen abgestimmt haben, zeigt sie nur, wenn genügend Personen abgestimmt haben. Dafür muss das Quorum der Abstimmung erreicht sein, falls eines festgelegt wurde. Andernfalls muss mindestens die Hälfte der Stimmberechtigten abgestimmt haben. In jedem Fall sind mindestens drei Stimmen erforderlich. Die Liste zeigt nie, wie oder wann jemand abgestimmt hat.

Mitglieder der Gruppe und die Abstimmenden sehen außerdem, wann die einzelnen Personen der Gruppe beigetreten sind und wer sie eingeladen hat. Gruppenadmins sehen auch die E-Mail-Adressen, um Personen mit demselben Namen unterscheiden zu können.

Da alle, die das Ergebnis sehen können, auch sehen können, wer abgestimmt hat, kann ein einseitiges Ergebnis erkennen lassen, wie Personen abgestimmt haben. Wenn beispielsweise jede Stimme auf Zustimmung lautet, haben alle Personen, die abgestimmt haben, zugestimmt.

Koordinierende können stimmberechtigte Personen hinzufügen, solange die Abstimmung offen ist, auch nachdem andere Personen bereits abgestimmt haben. Bereits hinzugefügte Abstimmende können nicht aus einer anonymen Abstimmung entfernt werden.

<!-- translation-section: reminders -->

## Erinnerungen

Bei einer anonymen Abstimmung, die mindestens 24 Stunden dauert, erhalten stimmberechtigte Personen, die noch nicht abgestimmt haben, innerhalb der letzten 24 Stunden eine automatische Erinnerung.

Wer die Erinnerung erhält, wird ausschließlich anhand der Teilnahmedatensätze bestimmt. Dabei werden abgegebene Stimmen weder geprüft noch mit diesen Datensätzen verknüpft. Wenn sich die Frist ändert, verwendet die stündliche Erinnerungsprüfung die aktuelle Frist, ohne eine gesonderte geplante Erinnerung für die Abstimmung zu verwalten.

Abstimmungen mit einer Gesamtdauer von weniger als 24 Stunden versenden diese automatische Erinnerung nicht.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Was Koordinierende und Admins sehen können

Über die Anwendung können Abstimmungskoordinierende, Gruppenadmins oder Instanzadmins je nach Berechtigung Folgendes sehen:

- die Abstimmung und ihre Stimmberechtigten;
- ob die einzelnen stimmberechtigten Personen abgestimmt haben, sofern ihre Rolle den Zugriff erlaubt und genügend Personen abgestimmt haben; und
- das zusammengefasste Ergebnis, nachdem die Abstimmung beendet wurde.

Mit den Funktionen der Anwendung können sie Folgendes nicht sehen:

- welche Auswahl zu einer Person gehört;
- einzelne Stimmen oder Abstimmungsmuster;
- wann eine bestimmte Stimme abgegeben wurde; oder
- eine Begründung, einen Anhang, ein Ereignis oder eine Benachrichtigung, die mit einer abgegebenen Stimme verknüpft sind.

<!-- translation-section: limits-of-anonymous-voting -->

## Grenzen des anonymen Abstimmens

Diese Schutzmaßnahmen verhindern, dass Personen, die die Anwendung nutzen, eine abgegebene Stimme mit der abstimmenden Person verknüpfen. Sie bieten keinen kryptografischen Schutz gegenüber Personen, die das System betreiben und die Datenbank, Sicherungskopien, Serverprotokolle, den Prozessspeicher, den Netzwerkverkehr oder eine veränderte Version der Anwendung untersuchen können.

Auch das Ergebnis selbst kann Informationen offenlegen. Ein kleiner Kreis von Stimmberechtigten, ein einstimmiges Ergebnis, eine auffällige Kombination ausgewählter Optionen oder Informationen, die außerhalb der Abstimmung geteilt werden, können Rückschlüsse auf die Auswahl einer Person erleichtern. Abstimmende können sich außerdem entscheiden, in der Diskussion unabhängig von ihrer abgegebenen Stimme offenzulegen, wie sie abgestimmt haben.

Berücksichtige die Anzahl der Stimmberechtigten und die Sensibilität der Entscheidung, wenn du beurteilst, ob anonymes Abstimmen auf Anwendungsebene geeignet ist.

<!-- translation-section: questions -->

## Fragen

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Kann jemand sehen, wie ich abgestimmt habe?

Nein. Sobald genügend Personen abgestimmt haben, können Personen, die das Ergebnis sehen können, auch sehen, ob du abgestimmt hast. Niemand kann dich über die Anwendung mit einer abgegebenen Stimme verknüpfen. Bis dahin bleibt verborgen, ob du abgestimmt hast.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Kann ich meine Stimme nach der Abgabe ansehen?

Nein. Die Anwendung bestätigt, dass deine Stimme gespeichert wurde, und entfernt anschließend deine Auswahl aus der Abstimmungsoberfläche. Sie kann deine Stimme nicht abrufen, ohne die Verknüpfung herzustellen, die bei anonymen Abstimmungen bewusst vermieden wird.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Kann ich meine Stimme ändern oder zurückziehen?

Nein. Es gibt keine Verknüpfung, über die die Anwendung erkennen könnte, welche abgegebene Stimme geändert oder entfernt werden soll.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Erhalte ich eine E-Mail zur Bestätigung meiner Stimme?

Nein. Wenn du abstimmst, erscheint nur eine Bestätigung auf dem Bildschirm und dein Teilnahmedatensatz wird aktualisiert. Es wird keine Bestätigungs-E-Mail versendet und keine Benachrichtigung oder kein Aktivitätsereignis erstellt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Gibt eine öffentliche Abstimmung mehr Informationen preis?

Nachdem eine öffentliche Abstimmung beendet wurde, können alle ihr Ergebnis sehen und erfahren, wer teilgenommen hat. Einzelne Stimmen sowie Angaben zu Mitgliedschaften und Einladungen sind für sie nicht sichtbar.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Eignet sich anonymes Abstimmen für jede Wahl?

Nein. Die Anwendung hält Identitäten und Stimmen getrennt. Entscheidungen, die Schutz vor Systembetreibenden erfordern, oder unabhängig überprüfbare kryptografische Wahlen benötigen ein System, das für diese Anforderungen entwickelt wurde.
