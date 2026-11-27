---
title: Chat-Integrationen
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: 5a727120f9967d49
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: 6bd4c9eec3a4c39a
  what-it-looks-like-in-chat: da8019d878a0b5e5
  generate-a-webhook-url: 9476b6ac05eae49c
  set-up-a-chat-integration: 23c80ce4c45548f5
  invite-to-poll: a77d3f29e0bd51f1
  automatic-notifications: 6d3c740051ccfc3f
title_source: 0eca19d30c6d7d3c
title_generated: 7e5772575945c225
---

<!-- translation-section: introduction -->

# Chat-Integrationen

Loomio kann Benachrichtigungen an deinen Chatraum senden.

Chat-Tools und Loomio ergänzen sich gut. Nutze den Chat für kurze Gespräche und aktuelle Informationen. Verlege wichtige Themen nach Loomio, wenn Menschen Zeit brauchen, um sich zu beteiligen, wenn eine Entscheidung getroffen werden muss oder wenn die Gruppe eine dauerhafte Dokumentation braucht.

Loomio unterstützt Slack, Discord, Microsoft Teams, Matrix und Mattermost.

Du kannst manuell Benachrichtigungen an deinen Chatraum senden, wenn du Personen zu einem Thread oder einer Abstimmung einlädst. Du kannst auch automatische Benachrichtigungen für bestimmte Ereignisse einrichten, etwa wenn jemand eine Diskussion startet.

<!-- translation-section: what-it-looks-like-in-chat -->

## So sieht es im Chat aus

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Verbinde deinen Chat-Dienst

Folge der Anleitung für deinen Chat-Dienst, um eine Webhook-URL zu erhalten (oder bei Matrix einen Bot-Zugriffstoken und eine Raum-ID):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Du kannst auch andere Dienste verbinden, die eingehende Webhooks mit HTML- oder Markdown-Formatierung unterstützen, etwa Zapier oder Rocket.Chat. Wähle in Loomio die Chat-Integration **Am wichtigsten** und gib deine eigene Webhook-URL ein.

<!-- translation-section: set-up-a-chat-integration -->

## Richte eine Chat-Integration ein

Du musst Gruppenadmin sein, um Chat-Integrationen hinzuzufügen oder zu bearbeiten.

1. Nachdem du deinen Chat-Dienst eingerichtet hast (siehe oben), öffne **Einstellungen** auf deiner Gruppenseite in Loomio und wähle **Chat-Integrationen**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Füge eine neue Chat-Integration für deinen Dienst hinzu, gib einen Namen ein (zum Beispiel „Discord #general“) und füge die Webhook-URL ein.

   ![](loomio-chatbot-form.png)

3. Wähle die Ereignisse aus, für die automatisch Benachrichtigungen gesendet werden sollen, oder lass sie unausgewählt, wenn du Benachrichtigungen nur manuell senden möchtest. Speichere anschließend. Du kannst diese Einstellungen jederzeit ändern.

<!-- translation-section: invite-to-poll -->

### Sende eine Benachrichtigung manuell

Um deinen Chatraum über eine Abstimmung oder Diskussion zu benachrichtigen, öffne die Abstimmung oder Diskussion und wähle **Einladen** (oder eine andere Benachrichtigungsaktion wie **Fazit teilen**, **An Abstimmung erinnern** oder **Abstimmung bearbeitet**). Wähle deine Chat-Integration aus der Liste der Empfangenden und sende die Benachrichtigung.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatische Benachrichtigungen

Um bei jedem Auftreten eines bestimmten Ereignisses eine Benachrichtigung zu senden, bearbeite die Chat-Integration und wähle dieses Ereignis aus.

![](chatbot_enable_automatic_notifications.png)
