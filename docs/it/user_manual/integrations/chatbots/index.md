---
title: Integrazioni di chat
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: ad0b0869b4a26236
  what-it-looks-like-in-chat: 2c7bda85ca387996
  generate-a-webhook-url: 2c84616091203bf7
  set-up-a-chat-integration: 3699649831a2dbd7
  invite-to-poll: e888e0f8e3b7ce3d
  automatic-notifications: e11c4d68347e3e4c
title_source: 0eca19d30c6d7d3c
title_generated: e4b2042ae11650a1
---

<!-- translation-section: introduction -->

# Integrazioni di chat

Loomio può inviare notifiche alla tua chat.

Gli strumenti di chat e Loomio funzionano bene insieme. Usa la chat per conversazioni rapide e aggiornamenti tempestivi. Sposta gli argomenti importanti su Loomio quando le persone hanno bisogno di tempo per partecipare, quando occorre prendere una decisione o quando il gruppo avrà bisogno di una documentazione duratura.

Loomio supporta Slack, Discord, Microsoft Teams, Matrix e Mattermost.

Puoi inviare notifiche alla tua chat quando vuoi, nello stesso modo in cui inviteresti singole persone a votare o a partecipare a una conversazione.

Puoi anche configurare le notifiche affinché vengano inviate ogni volta che si verifica un evento specifico, per esempio quando qualcuno avvia una conversazione.

<!-- translation-section: what-it-looks-like-in-chat -->

## Come appare nella chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Genera un URL webhook
Abbiamo preparato guide passo passo per ogni servizio supportato. Segui quella del tuo servizio per ottenere l'URL webhook necessario per aggiungere l'integrazione di chat in Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Il nostro sistema basato su webhook può essere usato anche con altri sistemi che supportano webhook in ingresso con formattazione HTML o Markdown, come Zapier o Rocketchat.
Seleziona il bot Mattermost e usa un URL webhook personalizzato.

<!-- translation-section: set-up-a-chat-integration -->

## Configura un'integrazione di chat

Dopo aver configurato il servizio che hai scelto (vedi sopra), avrai un URL webhook.
Apri **Integrazioni di chat** dal menu del gruppo e aggiungi una nuova integrazione di chat per il tuo gruppo.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Per ora puoi lasciare deselezionate tutte le caselle. Inserisci il nome (per esempio "Discord #general") e l'URL, poi fai clic sul pulsante di salvataggio in fondo al modulo.

![](loomio-chatbot-form.png)

Se in seguito decidi di far ricevere notifiche automatiche all'integrazione, torna alle sue impostazioni e seleziona gli eventi pertinenti.

<!-- translation-section: invite-to-poll -->

### Invita al sondaggio

Ecco come inviare una notifica alla tua chat per invitare le persone a votare su una proposta.
La procedura è la stessa per Condividi la conclusione, Invita alla conversazione, Ricorda di votare, Sondaggio modificato, ecc.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notifiche automatiche
Per inviare una notifica ogni volta che si verifica un evento specifico, modifica l'integrazione di chat e seleziona quell'evento.

![](chatbot_enable_automatic_notifications.png)
