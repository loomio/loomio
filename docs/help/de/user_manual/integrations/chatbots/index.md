---
title: Chat-Integrationen
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: '029386a6b77f9ede'
  what-it-looks-like-in-chat: 8d9d5066ec88b65b
  generate-a-webhook-url: 155076f23ce1a53a
  set-up-a-chat-integration: 37b289d5cbe53a24
  invite-to-poll: b7f4b9b553ef3d0c
  automatic-notifications: b68f3f051137c584
title_source: 0eca19d30c6d7d3c
title_generated: 7e5772575945c225
needs_review:
  invite-to-poll: use "Stimme" instead of "Abstimmung" for "vote"
---

<!-- translation-section: introduction -->

# Chat-Integrationen

Loomio kann Benachrichtigungen an deinen Chatraum senden.

Chat-Tools und Loomio ergänzen sich gut. Nutze den Chat für kurze Gespräche und aktuelle Informationen. Verlege wichtige Themen nach Loomio, wenn Menschen Zeit brauchen, um sich zu beteiligen, wenn eine Entscheidung getroffen werden muss oder wenn die Gruppe eine dauerhafte Dokumentation braucht.

Loomio unterstützt Slack, Discord, Microsoft Teams, Matrix und Mattermost.

Du kannst jederzeit Benachrichtigungen an deinen Chatraum senden, genauso wie du einzelne Personen einlädst, abzustimmen oder an einem Thread teilzunehmen.

Du kannst Benachrichtigungen auch so einstellen, dass sie immer gesendet werden, wenn ein bestimmtes Ereignis eintritt, etwa wenn jemand einen Thread startet.

<!-- translation-section: what-it-looks-like-in-chat -->

## So sieht es im Chat aus
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Erstelle eine Webhook-URL
Wir haben Schritt-für-Schritt-Anleitungen für jeden unterstützten Dienst vorbereitet. Folge der Anleitung für deinen Dienst, um die Webhook-URL zu erhalten, die du zum Hinzufügen der Chat-Integration in Loomio brauchst.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Unser Webhook-basiertes System lässt sich auch mit anderen Systemen verwenden, die eingehende Webhooks mit HTML- oder Markdown-Formatierung unterstützen. Dazu gehören beispielsweise Zapier oder Rocketchat. Wähle dafür den Mattermost-Bot und verwende eine eigene Webhook-URL.

<!-- translation-section: set-up-a-chat-integration -->

## Richte eine Chat-Integration ein

Nachdem du deinen gewählten Dienst eingerichtet hast (siehe oben), hast du eine Webhook-URL. Öffne **Chat-Integrationen** im Gruppenmenü und füge eine neue Chat-Integration für deine Gruppe hinzu.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Lass die Kontrollkästchen zunächst leer. Gib einfach den Namen (zum Beispiel „Discord #general“) und die URL ein und klicke unten im Formular auf die Schaltfläche zum Speichern.

![](loomio-chatbot-form.png)

Wenn du später automatische Benachrichtigungen über die Integration erhalten möchtest, öffne ihre Einstellungen erneut und wähle die entsprechenden Ereignisse aus.

<!-- translation-section: invite-to-poll -->

### Zur Abstimmung einladen

So sendest du eine Benachrichtigung an deinen Chatraum, um Personen einzuladen, ihre Stimme zu einem Vorschlag abzugeben. Dasselbe Verfahren gilt für „Fazit teilen“, „Zum Thread einladen“, „An die Stimmabgabe erinnern“, „Abstimmung bearbeitet“ usw.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatische Benachrichtigungen
Um bei jedem Auftreten eines bestimmten Ereignisses eine Benachrichtigung zu senden, bearbeite die Chat-Integration und wähle dieses Ereignis aus.

![](chatbot_enable_automatic_notifications.png)
