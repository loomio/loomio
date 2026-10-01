---
title: Chatintegraties
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
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
  introduction: a66c0877b90854ac
  what-it-looks-like-in-chat: 72cbed0dabe2ca5d
  generate-a-webhook-url: c213ae41a84e20d0
  set-up-a-chat-integration: a593e0b4a8caee58
  invite-to-poll: fd2c8124b962a055
  automatic-notifications: 87853357f7d47935
title_source: 0eca19d30c6d7d3c
title_generated: 99e4f4eed4403e25
---

<!-- translation-section: introduction -->

# Chatintegraties

Loomio kan meldingen naar je chatruimte sturen.

Chattools en Loomio werken goed samen. Gebruik chat voor korte gesprekken en tijdige updates. Verplaats belangrijke onderwerpen naar Loomio wanneer mensen tijd nodig hebben om deel te nemen, wanneer er een besluit moet worden genomen of wanneer de groep een blijvend verslag nodig heeft.

Loomio ondersteunt Slack, Discord, Microsoft Teams, Matrix en Mattermost.

Je kunt op elk gewenst moment meldingen naar je chatruimte sturen, op dezelfde manier als je individuele mensen uitnodigt om te stemmen of deel te nemen aan een thread.

Je kunt ook instellen dat er altijd een melding wordt verstuurd wanneer een bepaalde gebeurtenis plaatsvindt, bijvoorbeeld wanneer iemand een thread start.

<!-- translation-section: what-it-looks-like-in-chat -->

## Zo ziet het eruit in de chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Genereer een webhook-URL
We hebben stapsgewijze handleidingen gemaakt voor elke dienst die we ondersteunen. Volg de handleiding voor jouw dienst om de webhook-URL te verkrijgen die je nodig hebt om de chatintegratie in Loomio toe te voegen.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Ons systeem op basis van webhooks kan ook worden gebruikt met andere systemen die inkomende webhooks met HTML- of Markdown-opmaak ondersteunen, zoals Zapier of Rocketchat. Selecteer de Mattermost-bot en gebruik een aangepaste webhook-URL.

<!-- translation-section: set-up-a-chat-integration -->

## Stel een chatintegratie in

Nadat je de gekozen dienst hebt ingesteld (zie hierboven), heb je een webhook-URL. Open **Chatintegraties** in het groepsmenu en voeg een nieuwe chatintegratie toe voor je groep.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Waarschijnlijk wil je voorlopig geen selectievakjes aanvinken. Vul de naam (zoals "Discord #general") en de URL in en klik op de knop om op te slaan onderaan het formulier.

![](loomio-chatbot-form.png)

Als je later wilt dat de integratie automatische meldingen ontvangt, ga je terug naar de instellingen en selecteer je de betreffende gebeurtenissen.

<!-- translation-section: invite-to-poll -->

### Uitnodigen voor een peiling

Zo stuur je een melding naar je chatruimte om mensen uit te nodigen om op een voorstel te stemmen. Dezelfde stappen gelden voor Conclusie delen, Uitnodigen voor een thread, Herinneren om te stemmen, Peiling bewerkt enzovoort.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatische meldingen
Bewerk de chatintegratie en selecteer een gebeurtenis om telkens een melding te sturen wanneer die gebeurtenis plaatsvindt.

![](chatbot_enable_automatic_notifications.png)
