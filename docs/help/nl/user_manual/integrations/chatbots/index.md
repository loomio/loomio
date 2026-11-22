---
title: Chatintegraties
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: d671b54fe6ae3cd1
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: '0329f5f6cf39d17c'
  what-it-looks-like-in-chat: 05b45a200d61feff
  generate-a-webhook-url: 7681975ad7a8dd6f
  set-up-a-chat-integration: 2417ea1f18292a9b
  invite-to-poll: b36df8483f39f26d
  automatic-notifications: 198fc190253fcfb8
title_source: 0eca19d30c6d7d3c
title_generated: 99e4f4eed4403e25
---

<!-- translation-section: introduction -->

# Chatintegraties

Loomio kan meldingen naar je chatruimte sturen.

Chattools en Loomio werken goed samen. Gebruik chat voor korte gesprekken en tijdige updates. Verplaats belangrijke onderwerpen naar Loomio wanneer mensen tijd nodig hebben om deel te nemen, wanneer er een besluit moet worden genomen of wanneer de groep een blijvend verslag nodig heeft.

Loomio ondersteunt Slack, Discord, Microsoft Teams, Matrix en Mattermost.

Je kunt handmatig meldingen naar je chatruimte sturen wanneer je mensen uitnodigt voor een thread of peiling. Je kunt ook automatische meldingen instellen voor specifieke gebeurtenissen, bijvoorbeeld wanneer iemand een discussie start.

<!-- translation-section: what-it-looks-like-in-chat -->

## Zo ziet het eruit in de chat

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Verbind je chatdienst

Volg de handleiding voor jouw chatdienst om een webhook-URL te verkrijgen (of, voor Matrix, een toegangstoken voor een bot en een ruimte-ID):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Je kunt ook andere diensten verbinden die inkomende webhooks met HTML- of Markdown-opmaak accepteren, zoals Zapier of Rocket.Chat. Kies de chatintegratie **Meest belangrijk** in Loomio en voer je aangepaste webhook-URL in.

<!-- translation-section: set-up-a-chat-integration -->

## Stel een chatintegratie in

Je moet een groepsadmin zijn om chatintegraties toe te voegen of te bewerken.

1. Open na het instellen van je chatdienst (zie hierboven) het groepsmenu in Loomio en selecteer **Chatintegraties**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Voeg een nieuwe chatintegratie toe voor je dienst, voer een naam in (zoals "Discord #general") en plak de webhook-URL.

   ![](loomio-chatbot-form.png)

3. Selecteer de gebeurtenissen waarvoor je automatisch meldingen wilt versturen, of laat ze ongeselecteerd als je alleen handmatig meldingen wilt versturen. Sla daarna de instellingen op. Je kunt deze instellingen op elk moment wijzigen.

<!-- translation-section: invite-to-poll -->

### Verstuur handmatig een melding

Om je chatruimte op de hoogte te stellen van een peiling of discussie, open je het item en selecteer je **Uitnodigen** (of een andere meldingsactie zoals **Deel conclusie**, **Herinner om te stemmen** of **Peiling bewerkt**). Selecteer je chatintegratie in de lijst met ontvangers en verstuur de melding.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatische meldingen

Bewerk de chatintegratie en selecteer een gebeurtenis om telkens een melding te sturen wanneer die gebeurtenis plaatsvindt.

![](chatbot_enable_automatic_notifications.png)
