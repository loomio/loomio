---
title: Chat-Integrationen
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: fd2656c860f576cc
  what-it-looks-like-in-chat: 8d9d5066ec88b65b
  generate-a-webhook-url: 7f58df5039e4df47
  set-up-a-chat-integration: 95276484314b65c8
  invite-to-poll: 5f823a58827363db
  automatic-notifications: 0e83deffc2f2f02f
title_source: 0eca19d30c6d7d3c
title_generated: 7e5772575945c225
---

<!-- translation-section: introduction -->

# Chat-Integrationen

Loomio kann Benachrichtigungen an deinen Chatraum senden.

Chat-Dienste und Loomio ergänzen sich gut. Nutze den Chat für kurze Gespräche und zeitnahe Updates. Verlege wichtige Themen nach Loomio, wenn Menschen Zeit zum Mitmachen brauchen, eine Entscheidung ansteht oder die Gruppe eine dauerhafte Dokumentation benötigt.

Loomio unterstützt Slack, Discord, Microsoft Teams, Matrix und Mattermost.

Du kannst jederzeit Benachrichtigungen an deinen Chatraum senden, genauso wie du einzelne Personen zur Abstimmung oder zu einer Diskussion einladen kannst.

Du kannst Benachrichtigungen auch so einrichten, dass sie bei bestimmten Ereignissen automatisch gesendet werden, etwa wenn jemand eine Diskussion beginnt.

<!-- translation-section: what-it-looks-like-in-chat -->

## So sieht es im Chat aus
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Eine Webhook-URL erstellen
Für jeden unterstützten Dienst gibt es eine Schritt-für-Schritt-Anleitung. Folge der Anleitung für deinen Dienst, um die Webhook-URL zu erhalten, die du für die Chat-Integration in Loomio brauchst.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Das Webhook-System lässt sich auch mit anderen Diensten nutzen, die eingehende Webhooks mit HTML- oder Markdown-Formatierung unterstützen, zum Beispiel Zapier oder Rocketchat. Wähle dazu den Mattermost-Bot und verwende eine eigene Webhook-URL.

<!-- translation-section: set-up-a-chat-integration -->

## Eine Chat-Integration einrichten

Nachdem du den gewählten Dienst eingerichtet hast (siehe oben), erhältst du eine Webhook-URL. Öffne **Chat-Integrationen** im Gruppenmenü und füge eine neue Chat-Integration für deine Gruppe hinzu.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Lass die Kontrollkästchen vorerst frei. Gib einen Namen (zum Beispiel „Discord #general“) und die URL ein. Klicke dann unten im Formular auf „Speichern“.

![](loomio-chatbot-form.png)

Wenn die Integration später automatische Benachrichtigungen erhalten soll, öffne erneut ihre Einstellungen und wähle die entsprechenden Ereignisse aus.

<!-- translation-section: invite-to-poll -->

### Zur Abstimmung einladen

So sendest du eine Benachrichtigung an deinen Chatraum und lädst Menschen ein, über einen Vorschlag abzustimmen. Für Fazit teilen, Zur Diskussion einladen, An Abstimmung erinnern, Abstimmung bearbeitet und ähnliche Aktionen gehst du genauso vor.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatische Benachrichtigungen
Damit bei einem bestimmten Ereignis eine Benachrichtigung gesendet wird, bearbeite die Chat-Integration und wähle das Ereignis aus.

![](chatbot_enable_automatic_notifications.png)
