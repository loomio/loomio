---
title: Integrazioni di chat
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
  introduction: 5ab6c0e6af078a1f
  what-it-looks-like-in-chat: 2c7bda85ca387996
  generate-a-webhook-url: 9e41efea203f45fc
  set-up-a-chat-integration: 1c95fe5d29c7e45c
  invite-to-poll: 6961ed5fc32026e7
  automatic-notifications: e11c4d68347e3e4c
title_source: 0eca19d30c6d7d3c
title_generated: e4b2042ae11650a1
---

<!-- translation-section: introduction -->

# Integrazioni di chat

Loomio può inviare notifiche alla tua chat.

La chat e Loomio funzionano bene insieme. Usa la chat per conversazioni rapide e aggiornamenti tempestivi. Porta gli argomenti importanti su Loomio quando le persone hanno bisogno di tempo per partecipare, quando occorre prendere una decisione o quando il gruppo deve conservarne traccia.

Loomio supporta Slack, Discord, Microsoft Teams, Matrix e Mattermost.

Puoi inviare notifiche alla tua chat quando vuoi, proprio come inviti singole persone a votare o a partecipare a una discussione.

Puoi anche configurare l'invio automatico di notifiche per eventi specifici, per esempio quando qualcuno avvia una discussione.

<!-- translation-section: what-it-looks-like-in-chat -->

## Come appare nella chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Genera un URL webhook
Abbiamo preparato istruzioni dettagliate per ogni servizio supportato. Segui quelle del servizio che usi per ottenere l'URL webhook necessario ad aggiungere l'integrazione di chat in Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Il sistema basato sui webhook può funzionare anche con altri servizi che accettano webhook in ingresso formattati in HTML o Markdown, come Zapier o Rocketchat. Seleziona il bot Mattermost e usa un URL webhook personalizzato.

<!-- translation-section: set-up-a-chat-integration -->

## Configura un'integrazione di chat

Dopo aver configurato il servizio scelto (vedi sopra), avrai un URL webhook. Apri **Integrazioni di chat** dal menu del gruppo e aggiungi una nuova integrazione di chat per il tuo gruppo.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Per ora lascia deselezionate le caselle. Inserisci il nome (per esempio "Discord #general") e l'URL, poi seleziona il pulsante per salvare in fondo al modulo.

![](loomio-chatbot-form.png)

Se in seguito vuoi ricevere notifiche automatiche tramite l'integrazione, torna alle sue impostazioni e seleziona gli eventi pertinenti.

<!-- translation-section: invite-to-poll -->

### Invita a votare

Per invitare le persone a votare una proposta, invia una notifica alla tua chat in questo modo. La procedura è la stessa per Condividi conclusione, Invita alla discussione, Ricorda di votare, Sondaggio modificato e altri eventi.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notifiche automatiche
Per inviare una notifica ogni volta che si verifica un evento specifico, modifica l'integrazione di chat e seleziona quell'evento.

![](chatbot_enable_automatic_notifications.png)
