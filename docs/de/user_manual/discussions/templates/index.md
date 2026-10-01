---
title: Diskussionsvorlagen
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: 1886093dd5128b3c
  how-templates-are-used: 2f4cd073b70433e7
  choose-who-is-notified-by-default: 91c68ed243760be0
  template-settings: 5aa53615efec7ae3
  example-bottle-trial-review: 966f1df72550fe4e
  create-a-template: 71bdcac7fbb20017
  manage-the-template-list: d4d079feab24bbd7
  share-templates-between-groups: c82b18eb73786f39
  let-members-create-templates: 21d8ca6904700d2a
  templates-for-non-members: 682494b3f4d2f42c
  related: 58cbfc7ebe12fceb
title_source: 5ac608aa42806d13
title_generated: 3bc3bb95557b6309
needs_review:
  template-settings: use "Entscheidung" instead of "Abstimmung" for "decision"
---

<!-- translation-section: introduction -->

# Diskussionsvorlagen

Diskussionsvorlagen helfen deiner Gruppe, Diskussionen jedes Mal auf dieselbe Weise zu starten. Eine Vorlage kann einen Titel, Kontext, Schlagwörter und Anweisungen für die Person vorgeben, die die Diskussion startet. Sie legt auch Standardeinstellungen fest, etwa ob die ganze Gruppe benachrichtigt wird und welche Abstimmungen vorgeschlagen werden.

Jede neue Diskussion in einer Gruppe beginnt mit einer Vorlage. Wenn jemand **Diskussion starten** auswählt, zeigt Loomio die Vorlagen der Gruppe an. Auch **Leere Vorlage** ist eine Vorlage, sodass deine Gruppe deren Standardeinstellungen ebenfalls ändern kann.

Vorlagen eignen sich für Abläufe, die deine Gruppe wiederholt, etwa Projektbewertungen, Beratungsprozesse, die Vorbereitung von Treffen, Finanzierungsentscheidungen oder die Freigabe von Dokumenten. Die Person, die die Diskussion startet, kann vorher weiterhin alles bearbeiten.

<!-- translation-section: how-templates-are-used -->

## So werden Vorlagen verwendet

1. Ein Mitglied wählt auf der Gruppenseite **Diskussion starten** aus.
2. Loomio listet die sichtbaren Vorlagen der Gruppe auf. Jede zeigt ihren Titel und Untertitel.
3. Das Mitglied wählt eine Vorlage aus. Loomio öffnet das Formular für eine neue Diskussion, das mit den Angaben aus der Vorlage ausgefüllt ist.
4. Die Vorlagenhilfe erscheint oben im Formular als Anleitung.
5. Das Mitglied bearbeitet Titel, Kontext, Schlagwörter und Einladungsliste und wählt dann **Diskussion starten** aus.

![](list.png)

Änderungen an einer Vorlage wirken sich nur auf Diskussionen aus, die nach der Änderung gestartet werden. Bereits damit gestartete Diskussionen behalten ihre Inhalte und Einstellungen.

<!-- translation-section: choose-who-is-notified-by-default -->

## Wähle, wer standardmäßig benachrichtigt wird

Die Einstellung **Einladen** legt fest, wen das Formular für eine neue Diskussion standardmäßig einlädt. Es gibt zwei Optionen:

- **Jeder in der Gruppe**: Die Gruppe erscheint im Feld **Einladen** des Diskussionsformulars, und jedes Mitglied wird benachrichtigt, wenn die Diskussion startet.
- **Keine**: Das Feld **Einladen** ist zunächst leer. Niemand wird benachrichtigt, es sei denn, die Person, die die Diskussion startet, fügt Personen hinzu.

Die integrierten Vorlagen von Loomio, einschließlich **Leere Vorlage**, verwenden **Jeder in der Gruppe**. Wenn deine Gruppe nicht bei jeder neuen Diskussion alle Mitglieder benachrichtigen möchte, bearbeite die verwendeten Vorlagen und setze **Einladen** auf **Keine**.

![](use.png)

Die Person, die die Diskussion startet, kann die Einladungsliste vorher jederzeit ändern. Sie kann die Gruppe entfernen, um niemanden zu benachrichtigen, oder stattdessen bestimmte Personen hinzufügen. Diese Einstellung betrifft nur Benachrichtigungen. Gruppenmitglieder können die Diskussion weiterhin in der Gruppe finden und lesen, unabhängig davon, welche Option du wählst.

Die Gruppe wird nur dann zur Einladungsliste hinzugefügt, wenn die Person, die die Diskussion startet, die ganze Gruppe benachrichtigen darf. Admins dürfen das immer. Mitglieder dürfen es, wenn **Mitglieder können alle Mitglieder der Gruppe benachrichtigen** in den Berechtigungen der Gruppe aktiviert ist.

<!-- translation-section: template-settings -->

## Vorlageneinstellungen

Admins der Gruppe können eine Vorlage über das Aktionsmenü neben der Vorlage in der Vorlagenliste bearbeiten. Das Formular enthält diese Einstellungen:

![](form.png)

- **Vorlagentitel**: der kurze Name, der in der Vorlagenliste angezeigt wird.
- **Vorlagenuntertitel**: eine Zeile, die erklärt, wann die Vorlage verwendet werden soll.
- **Vorlagenhilfe**: Anweisungen, die oben im Formular für eine neue Diskussion angezeigt werden. Erkläre hier den Ablauf und verlinke hilfreiche Materialien. Die Vorlagenhilfe ist nicht Teil der Diskussion.
- **Gruppe**: ob die Vorlage eine Diskussion in der Gruppe oder eine direkte Diskussion startet. Eine direkte Diskussion ist nur für die dazu eingeladenen Personen sichtbar.
- **Standardtitel**: ein Titel, der für jede neue Diskussion vorausgefüllt wird. Die Person, die die Diskussion startet, kann ihn bearbeiten.
- **Beispieltitel**: ein Beispiel, das in einem leeren Titelfeld angezeigt wird. Verwende es, wenn ein Standardtitel nicht zu jeder Diskussion passen würde.
- **Schlagwörter**: Schlagwörter, die jeder neuen Diskussion zugewiesen werden. Die Person, die die Diskussion startet, kann sie entfernen.
- **Kontext**: der Ausgangstext der Diskussion. Verwende Überschriften, Fragen oder Links, um den Teilnehmenden Orientierung beim Schreiben zu geben.
- **Einladen**: ob standardmäßig alle in der Gruppe eingeladen werden. Siehe [Wähle, wer standardmäßig benachrichtigt wird](#choose-who-is-notified-by-default).
- **Umfragevorlagen**: Abstimmungen, die für diesen Ablauf vorgeschlagen werden. Sie werden im Formular für eine neue Diskussion aufgelistet. Sie erscheinen auch zuerst, wenn jemand eine Abstimmung in der Diskussion startet. Sie starten nicht automatisch.
- **Gleichzeitige Abstimmungen zulassen**: ob in der Diskussion mehrere Abstimmungen gleichzeitig offen sein können.
- **Kommentarlängenbegrenzung**: eine optionale Höchstlänge für Kommentare.

Verwende einen Standardtitel nur, wenn er dauerhaft zutreffend bleibt. Schreibe andernfalls einen Beispieltitel, der die Person, die die Diskussion startet, dazu anregt, die konkrete Überprüfung, den Zeitraum, das Dokument oder die Entscheidung zu benennen.

<!-- translation-section: example-bottle-trial-review -->

## Beispiel: Auswertung eines Mehrwegflaschenversuchs

Oatmilk Cooperative wertet ihren Mehrwegflaschenversuch nach jedem Durchlauf aus. Ihre Vorlage heißt „Auswertung des Mehrwegflaschenversuchs“ und hat einen Standardtitel. Sie fügt das Schlagwort „Mehrwegflaschenversuch“ hinzu. Ihr Kontext fordert die Mitglieder auf, den Wochenbericht zu lesen und Rücklaufquoten, Reinigungsprotokolle, Rückmeldungen von Cafés und Transportkosten zu berücksichtigen. Sie empfiehlt ein Stimmungsbild, gefolgt von einem Konsentverfahren.

Das eignet sich als Vorlage, weil der Zweck und die Bewertungsgrundlagen in jedem Durchlauf gleich bleiben. Nur die Beobachtungen und Entscheidungen ändern sich.

<!-- translation-section: create-a-template -->

## Eine Vorlage erstellen

Admins der Gruppe können in der Vorlagenliste **Neue Vorlage** auswählen. Wähle ein Beispiel aus der Galerie von Loomio oder beginne mit einer leeren Vorlage, passe sie an und speichere sie.

Du kannst die Galerie durchsuchen oder filtern. Ein Beispiel wird deiner Gruppe erst hinzugefügt, wenn du es speicherst.

<!-- translation-section: manage-the-template-list -->

## Die Vorlagenliste verwalten

Wenn eine Gruppe erstellt wird, fügt Loomio eine Reihe von Vorlagen hinzu, die zur Art der Gruppe passen. Anfangs sind nur **Leere Vorlage** und **Übungsdiskussion** sichtbar. Die anderen sind ausgeblendet, und Admins können sie einblenden.

Admins der Gruppe können über das Aktionsmenü neben einer Vorlage:

- ihre Inhalte und Einstellungen bearbeiten;
- sie in der Vorlagenliste ausblenden;
- sie unter **Versteckte Vorlagen** wieder einblenden;
- die Reihenfolge der sichtbaren Vorlagen ändern;
- sie als JSON-Datei exportieren; oder
- sie löschen.

Eine ausgeblendete Vorlage bleibt für die spätere Verwendung erhalten. Wenn du eine Vorlage löschst, werden damit gestartete Diskussionen nicht gelöscht.

<!-- translation-section: share-templates-between-groups -->

## Vorlagen zwischen Gruppen teilen

Wähle im Aktionsmenü einer Vorlage **JSON exportieren**, um sie als Datei herunterzuladen. Um sie in einer anderen Gruppe zu verwenden, wähle **Neue Vorlage** und dann **JSON importieren**. Das Formular öffnet sich mit den importierten Inhalten, damit du sie vor dem Speichern prüfen kannst.

Links zu eigenen Abstimmungsvorlagen sind nicht in der Datei enthalten. Exportiere und importiere diese Abstimmungsvorlagen separat.

<!-- translation-section: let-members-create-templates -->

## Mitglieder Vorlagen erstellen lassen

Standardmäßig können nur Admins der Gruppe Vorlagen erstellen und bearbeiten. Ein Admin kann unter **Gruppen-Einstellungen** → **Berechtigungen** die Einstellung **Mitglieder können Vorlagen erstellen.** aktivieren.

Wenn diese Einstellung aktiviert ist, können Mitglieder Diskussions- und Abstimmungsvorlagen erstellen und ihre eigenen Vorlagen bearbeiten. Admins können jede Vorlage in der Gruppe bearbeiten. Die Vorlage eines Mitglieds erscheint nach dem Speichern in der Vorlagenliste der Gruppe. Vereinbare deshalb mit deiner Gruppe, wie Vorlagen benannt und geprüft werden sollen, bevor du diese Berechtigung aktivierst.

<!-- translation-section: templates-for-non-members -->

## Vorlagen für Nichtmitglieder

Wenn **Nichtmitglieder können Diskussionen starten** aktiviert ist, wählen Personen außerhalb der Gruppe aus derselben Vorlagenliste. Ihr Diskussionsformular lädt die Gruppe nie standardmäßig ein. Siehe [Private Einreichungen sammeln](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Weiterführende Informationen

- [Abstimmungsvorlagen](/en/user_manual/polls/poll_templates)
