---
title: Chatintegraties
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
  introduction: 1f3479954027af30
  what-it-looks-like-in-chat: 72cbed0dabe2ca5d
  generate-a-webhook-url: 00e8cc9e6e64edae
  set-up-a-chat-integration: ea7cc0831271b85c
  invite-to-poll: 12cb38a8a184bce4
  automatic-notifications: 6cade69f5eee75aa
title_source: 0eca19d30c6d7d3c
title_generated: 99e4f4eed4403e25
---

<!-- translation-section: introduction -->

# Chatintegraties

Loomio kan meldingen naar je chatruimte sturen.

Chat en Loomio vullen elkaar aan. Gebruik chat voor korte gesprekken en snelle updates. Verplaats belangrijke onderwerpen naar Loomio als mensen tijd nodig hebben om mee te doen, als er een besluit genomen moet worden of als de groep het gesprek later wil kunnen terugvinden.

Loomio ondersteunt Slack, Discord, Microsoft Teams, Matrix en Mattermost.

Je kunt op elk moment een melding naar je chatruimte sturen, net zoals je mensen kunt uitnodigen om te stemmen of deel te nemen aan een discussie.

Je kunt ook instellen dat Loomio automatisch een melding stuurt bij een bepaalde gebeurtenis, bijvoorbeeld wanneer iemand een discussie start.

<!-- translation-section: what-it-looks-like-in-chat -->

## Zo ziet het eruit in de chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Een webhook-URL aanmaken
Voor elke ondersteunde dienst is er een stapsgewijze handleiding. Volg de handleiding voor jouw dienst om de webhook-URL te krijgen die je nodig hebt om de chatintegratie in Loomio toe te voegen.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Je kunt ons webhooksysteem ook gebruiken met andere diensten die inkomende webhooks met HTML- of Markdown-opmaak ondersteunen, zoals Zapier of Rocketchat. Selecteer hiervoor de Mattermost-bot en gebruik een aangepaste webhook-URL.

<!-- translation-section: set-up-a-chat-integration -->

## Een chatintegratie instellen

Nadat je de gekozen dienst hebt ingesteld (zie hierboven), heb je een webhook-URL. Open **Chatintegraties** via het groepsmenu en voeg een nieuwe chatintegratie toe voor je groep.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Laat de selectievakjes voorlopig leeg. Vul de naam in (bijvoorbeeld "Discord #general") en de URL, en klik onderaan het formulier op de knop om op te slaan.

![](loomio-chatbot-form.png)

Wil je later automatische meldingen ontvangen via de integratie? Ga dan terug naar de instellingen en selecteer de relevante gebeurtenissen.

<!-- translation-section: invite-to-poll -->

### Uitnodigen om te stemmen

Zo stuur je een melding naar je chatruimte om mensen uit te nodigen om over een voorstel te stemmen. De stappen zijn hetzelfde voor een conclusie delen, uitnodigen voor een discussie, herinneren aan een stemming, een gewijzigde poll en andere gebeurtenissen.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatische meldingen
Wil je bij een bepaalde gebeurtenis automatisch een melding sturen? Bewerk dan de chatintegratie en selecteer die gebeurtenis.

![](chatbot_enable_automatic_notifications.png)
