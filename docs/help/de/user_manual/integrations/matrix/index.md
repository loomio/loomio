---
title: Matrix
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 31651f229b065ec2
generated:
  introduction: d430b777fbd8c92c
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix-Integration

Loomio kann Benachrichtigungen an einen Matrix-Raum senden, wenn neue Diskussionen, Abstimmungen, Kommentare, Stimmen und Fazits hinzugefügt werden. Du musst Gruppenadmin sein, um eine Chat-Integration hinzuzufügen.

Anders als die anderen Chat-Integrationen von Loomio verwendet Matrix keinen Webhook. Stattdessen verbindet sich Loomio über ein Matrix-Konto, das als Bot dient und formatierte Nachrichten in deinem Raum veröffentlicht.

Diese Anleitung verwendet den Element-Client.

---

1. Erstelle ein Matrix-Konto für Loomio, melde dich damit in Element an und lade dieses Konto in den Matrix-Raum ein, in dem die Benachrichtigungen erscheinen sollen. Lass diese Sitzung angemeldet — beim Abmelden wird das Zugangstoken ungültig.

2. Öffne in deiner Loomio-Gruppe **Einstellungen**, wähle **Chat-Integrationen** und füge eine **Matrix**-Chat-Integration hinzu.

   ![Menü zum Hinzufügen eines Matrix-Bots in Loomio](loomio-add-matrix-bot.png)

   ![Formular für den Matrix-Bot in Loomio](loomio-matrix-bot-form.png)

3. Öffne in Element das Menü des Bot-Kontos und wähle **Alle Einstellungen**.

   ![Matrix-Einstellungsmenü](matrix-settings-menu.png)

4. Öffne **Hilfe & Über** und scrolle zum Abschnitt **Erweitert**.

   ![Matrix-Einstellungen](matrix-settings.png)

5. Kopiere das **Zugangstoken** und füge es in das Loomio-Formular ein.

   ![Matrix-Zugangstoken](matrix-access-token.png)

6. Öffne das Menü **Einstellungen** des Raums und gehe zu **Erweitert**.

   ![Matrix-Raumeinstellungen](matrix-room-settings.png)

7. Kopiere die **Interne Raum-ID**, füge sie in das Loomio-Formular ein und speichere die Integration.

   ![Matrix-Raum-ID](matrix-room-id.png)
