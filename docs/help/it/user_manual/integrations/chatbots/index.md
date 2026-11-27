---
title: Integrazioni di chat
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
  introduction: 365c87bc34b4caa4
  what-it-looks-like-in-chat: 7e3aaed598cdc9e6
  generate-a-webhook-url: 9b59d0929d235fa2
  set-up-a-chat-integration: 8d34ddecf7106dfa
  invite-to-poll: ded8cf986d97d7ae
  automatic-notifications: 97861a887ac7d460
title_source: 0eca19d30c6d7d3c
title_generated: e4b2042ae11650a1
---

<!-- translation-section: introduction -->

# Integrazioni di chat

Loomio può inviare notifiche alla tua chat.

Gli strumenti di chat e Loomio funzionano bene insieme. Usa la chat per conversazioni rapide e aggiornamenti tempestivi. Sposta gli argomenti importanti su Loomio quando le persone hanno bisogno di tempo per partecipare, quando occorre prendere una decisione o quando il gruppo ha bisogno di una documentazione duratura.

Loomio supporta Slack, Discord, Microsoft Teams, Matrix e Mattermost.

Puoi inviare notifiche alla tua chat manualmente ogni volta che inviti persone a una conversazione o a un sondaggio. Puoi anche configurare notifiche automatiche per eventi specifici, per esempio quando qualcuno avvia una discussione.

<!-- translation-section: what-it-looks-like-in-chat -->

## Come appare nella chat

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Collega il tuo servizio di chat

Segui la guida del tuo servizio di chat per ottenere un URL webhook (oppure, per Matrix, un token di accesso del bot e l'ID della stanza):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Puoi anche collegare altri servizi che accettano webhook in ingresso con formattazione HTML o Markdown, come Zapier o Rocket.Chat. Scegli l'integrazione di chat **Mattermost** in Loomio e inserisci il tuo URL webhook personalizzato.

<!-- translation-section: set-up-a-chat-integration -->

## Configura un'integrazione di chat

Devi essere un amministratore del gruppo per aggiungere o modificare le integrazioni di chat.

1. Dopo aver configurato il tuo servizio di chat (vedi sopra), apri **Configurazione** nella pagina del tuo gruppo in Loomio e seleziona **Integrazioni di chat**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Aggiungi una nuova integrazione di chat per il tuo servizio, inserisci un nome (per esempio "Discord #general") e incolla l'URL webhook.

   ![](loomio-chatbot-form.png)

3. Seleziona gli eventi per cui vuoi inviare notifiche automatiche, oppure lasciali deselezionati se vuoi inviare notifiche solo manualmente, poi salva. Puoi modificare queste impostazioni in qualsiasi momento.

<!-- translation-section: invite-to-poll -->

### Invia una notifica manualmente

Per inviare alla tua chat una notifica su un sondaggio o una discussione, apri l'elemento e seleziona **Invita** (o un'altra azione di notifica come **Condividi risultati**, **Ricorda di votare** o **Sondaggio modificato**). Seleziona la tua integrazione di chat dall'elenco dei destinatari e invia la notifica.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notifiche automatiche

Per inviare una notifica ogni volta che si verifica un evento specifico, modifica l'integrazione di chat e seleziona quell'evento.

![](chatbot_enable_automatic_notifications.png)
