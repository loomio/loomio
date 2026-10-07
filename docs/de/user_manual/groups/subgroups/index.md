---
title: Untergruppen
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: 5bdd92ce200f197a
  permissions: ee02991523f1ebe4
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: ea06820dfdbb7bd3
  add-a-subgroup: '0583e95e8fd8424d'
  subgroup-settings: e79b4c0cb34a6e3c
  privacy: 26282a8289be0239
  permissions: 4b785e952cf5bd1b
  find-subgroups: c4956da3eeabc8d5
  invite-to-a-subgroup: 79ef72a3ea7f6750
  simultaneously-invite-people-to-subgroups-and-parent-group: b4dbc6f6abf00a2d
  administer-a-subgroup: 930d4e980b22508e
  delete-a-subgroup: 54f25462618ec475
title_source: 9f81e728f70cae3e
title_generated: 5ec97dd47e254e8e
---

<!-- translation-section: introduction -->

# Untergruppen

Untergruppen helfen dir, deine Kommunikation und Mitglieder so zu organisieren, dass die passenden Personen zusammenarbeiten.

Eine Organisation kann zum Beispiel folgende Untergruppen haben:
- Vorstand
- Arbeitsteam oder Projektarbeitsgruppe
- eine Untergruppe zu einem Thema (wie „Strategie“ oder „Lernen“)

Untergruppen funktionieren wie Gruppen, befinden sich aber innerhalb deiner Hauptgruppe. Die meisten Funktionen und Einstellungen sind dieselben wie in der Hauptgruppe. Das bedeutet auch, dass jemand Mitglied deiner Untergruppe sein kann, etwa deines Vorstands, ohne Mitglied deiner Hauptgruppe zu sein.

<!-- translation-section: add-a-subgroup -->

## Eine Untergruppe hinzufügen

>[!Note]
>Wer neue Untergruppen hinzufügen darf, wird in den [Berechtigungseinstellungen](/en/user_manual/groups/settings/permissions) der Gruppe festgelegt. Standardmäßig können nur Admins neue Untergruppen erstellen.

Um eine Untergruppe hinzuzufügen, öffne die Seite deiner Hauptgruppe und klicke in der Seitenleiste auf **Neue Untergruppe**.  

![Schaltfläche „Neue Untergruppe“ in der Seitenleiste der Oatmilk Cooperative](subgroups-sidebar.png)

Klicke auf **Neue Untergruppe**, gib ihr einen Namen und wähle die Privatsphäre-Einstellung. Klicke dann auf **Untergruppe erstellen**.

![Formular für eine neue Untergruppe namens Packaging Working Group](subgroups_new.png)

Wenn du bereit bist, [lade Leute](/en/user_manual/groups/inviting_people/) in die Untergruppe ein.

Du kannst die [Gruppeneinstellungen](/en/user_manual/groups/settings/) der Untergruppe bearbeiten, indem du auf der Seite der Untergruppe auf das Zahnradsymbol klickst.

![Aktion zum Bearbeiten der Gruppeneinstellungen der Packaging Working Group](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Einstellungen der Untergruppe

<!-- translation-section: privacy -->

### Privatsphäre

Wähle unabhängig davon, wie Personen der Untergruppe beitreten können, wer sie finden kann:

| Privatsphäre | Wer kann sie finden? | Wer kann ihre Threads lesen? |
| --- | --- | --- |
| **Offen** | Alle | Alle |
| **Geschlossen** | Alle | Mitglieder der Untergruppe und eingeladene Gäste |
| **Für die übergeordnete Gruppe sichtbar** | Mitglieder der Hauptgruppe und der Untergruppe | Mitglieder der Untergruppe und eingeladene Gäste |
| **Geheim** | Eingeladene Mitglieder der Untergruppe | Mitglieder der Untergruppe und eingeladene Gäste |

Damit Mitglieder der Hauptgruppe selbst beitreten können, wähle beim Erstellen der Untergruppe oder unter **Gruppeneinstellungen bearbeiten → Privatsphäre** zunächst **Für die übergeordnete Gruppe sichtbar** und dann unter **Wie kann man teilnehmen?** die Einstellung **Mitglieder von [Hauptgruppe] können ohne Genehmigung beitreten**. Personen außerhalb der Hauptgruppe benötigen eine Einladung. Mitglieder können die Untergruppe verlassen und ihr erneut beitreten, solange sie noch der Hauptgruppe angehören.

![Privatsphäre-Einstellungen einer Untergruppe mit Sichtbarkeit für die Hauptgruppe und Beitritt ohne Genehmigung](subgroups_privacy_settings.png)

Durch den Beitritt wird eine Person ein gewöhnliches Mitglied der Untergruppe. Sie erhält dadurch keine Adminrechte, und die Privatsphäre bestehender Threads ändert sich nicht.

Öffentliche Untergruppen können ebenfalls den sofortigen Beitritt erlauben. Wenn diese Option ausgewählt ist, können alle beitreten. Ist die Hauptgruppe privat, stehen für Untergruppen die Einstellungen **Für die übergeordnete Gruppe sichtbar** und **Geheim** zur Verfügung.

Eine Untergruppe mit der Einstellung **Für die übergeordnete Gruppe sichtbar** bleibt privat, wenn ihre Hauptgruppe öffentlich wird. Wird eine Hauptgruppe privat, sind ihre öffentlichen Untergruppen nur noch für Mitglieder der Hauptgruppe zugänglich, und deren Threads werden privat. Geheime Untergruppen bleiben unverändert.

[Lies hier mehr über die Privatsphäre von Gruppen](/en/user_manual/groups/settings/privacy).

<!-- translation-section: permissions -->

### Berechtigungen

Untergruppen arbeiten unabhängig von der Hauptgruppe. Wenn die Privatsphäre-Einstellung der Untergruppe beispielsweise auf **Geheim** gesetzt ist, können nur eingeladene Mitglieder diese Untergruppe finden, sehen, wer dazugehört, und ihre Threads sehen.

Untergruppen mit der Einstellung **Geschlossen** oder **Für die übergeordnete Gruppe sichtbar** können Mitgliedern der Hauptgruppe erlauben, private Threads vor dem Beitritt zu lesen. Aktiviere unter **Berechtigungen** die Einstellung **Mitglieder von [Hauptgruppe] können private Threads sehen**. Diese Personen erhalten dadurch weder Stimmrechte noch eine Mitgliedschaft in der Untergruppe.

![Einstellung, die Mitgliedern der Hauptgruppe erlaubt, private Threads der Untergruppe zu sehen](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Untergruppen finden

Öffne das Seitenleistenmenü und klicke auf den Namen deiner Gruppe, um ihre Untergruppen zu sehen.

![Untergruppen der Oatmilk Cooperative in der Seitenleiste](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## In eine Untergruppe einladen

Lade Leute genauso in eine Untergruppe ein wie in eine Gruppe. Wenn sie bereits einer Hauptgruppe oder einer anderen Untergruppe derselben Organisation angehören, der auch du angehörst, kannst du ihren Namen eingeben oder diese Gruppe als Empfängerkreis auswählen. Wähle den Eintrag für den Empfängerkreis aus, um ihn in einzelne Personen aufzulösen, und entferne dann alle, die du nicht einladen möchtest.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Leute gleichzeitig in Untergruppen und die Hauptgruppe einladen

Wenn du im Tab **Mitglieder** deiner Hauptgruppe auf **Leute einladen** klickst, kannst du Leute gleichzeitig in mehrere Untergruppen einladen. Setze dazu die Häkchen bei den Untergruppen, denen sie sofort beitreten sollen.

![Auswahl der Hauptgruppe und einer Untergruppe im Einladungsformular](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Eine Untergruppe verwalten

Untergruppen können eigene Admins haben. Die Admins einer Untergruppe können andere Personen sein als die Admins der Hauptgruppe.

Ein Admin der Hauptgruppe kann sich jedoch selbst zum Admin jeder Untergruppe machen. So können Admins der Hauptgruppe Untergruppen bei Bedarf verwalten.

Öffne den Tab „Untergruppen“, suche die Untergruppe und klicke auf **Der Gruppe beitreten**.

![Schaltfläche „Der Gruppe beitreten“ bei einer geschlossenen Untergruppe](member_join_subgroup.png)

Sobald ein Admin der Hauptgruppe Mitglied der Untergruppe ist, kann er sich selbst zum Admin der Untergruppe machen.

![Aktion zum Ernennen eines Admins der Hauptgruppe zum Admin der Untergruppe](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Eine Untergruppe löschen

Admins können eine Untergruppe genauso löschen wie eine Gruppe. Achte beim Löschen einer Untergruppe darauf, dass du nicht die Hauptgruppe löschst.

Erfahre, [wie du Gruppen löschst](/en/user_manual/groups/deleting_your_group/).
