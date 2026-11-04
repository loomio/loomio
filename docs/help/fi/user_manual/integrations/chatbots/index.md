---
title: Chat-integraatiot
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
  introduction: d7779dd39f0f53dc
  what-it-looks-like-in-chat: fa55abaf399a7070
  generate-a-webhook-url: fae1c4727b0fb237
  set-up-a-chat-integration: 51240364969ecc72
  invite-to-poll: 80371497b2bda5ec
  automatic-notifications: 1104e02ce6bcedac
title_source: 0eca19d30c6d7d3c
title_generated: 28857b17fdd84c01
---

<!-- translation-section: introduction -->

# Chat-integraatiot

Loomio voi lähettää ilmoituksia chat-huoneeseesi.

Chat-työkalut ja Loomio toimivat hyvin yhdessä. Käytä chatia nopeaan keskusteluun ja ajankohtaisten tietojen jakamiseen. Siirrä tärkeät aiheet Loomioon, kun ihmiset tarvitsevat aikaa osallistumiseen, kun on tehtävä päätös tai kun ryhmä tarvitsee pysyvän kirjauksen asiasta.

Loomio tukee Slackia, Discordia, Microsoft Teamsia, Matrixia ja Mattermostia.

Voit lähettää ilmoituksia chat-huoneeseesi milloin haluat, samalla tavalla kuin kutsuisit yksittäisiä ihmisiä äänestämään tai liittymään ketjuun.

Voit myös määrittää ilmoitukset lähetettäviksi aina, kun tietty tapahtuma toteutuu, esimerkiksi kun joku aloittaa ketjun.

<!-- translation-section: what-it-looks-like-in-chat -->

## Miltä ilmoitus näyttää chatissa
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Luo webhook-URL
Olemme laatineet vaiheittaiset ohjeet jokaiselle tukemallemme palvelulle. Noudata käyttämäsi palvelun ohjeita saadaksesi webhook-URL:n, jonka tarvitset chat-integraation lisäämiseen Loomiossa.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Webhook-pohjaista järjestelmäämme voi käyttää myös muiden järjestelmien kanssa, jotka tukevat saapuvia webhooks-kutsuja HTML- tai Markdown-muodossa. Tällaisia ovat esimerkiksi Zapier ja Rocketchat. Valitse Mattermost-botti ja käytä oman palvelusi webhook-URL:ää.

<!-- translation-section: set-up-a-chat-integration -->

## Ota chat-integraatio käyttöön

Kun olet määrittänyt valitsemasi palvelun (katso yllä), sinulla on webhook-URL. Avaa ryhmän valikosta **Chat-integraatiot** ja lisää ryhmällesi uusi chat-integraatio.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Et luultavasti halua vielä valita mitään valintaruutuja. Syötä vain nimi (esimerkiksi "Discord #general") ja URL ja napsauta lomakkeen alareunassa olevaa tallennuspainiketta.

![](loomio-chatbot-form.png)

Jos haluat myöhemmin integraation vastaanottavan automaattisia ilmoituksia, palaa sen asetuksiin ja valitse haluamasi tapahtumat.

<!-- translation-section: invite-to-poll -->

### Kutsu kyselyyn

Näin lähetät chat-huoneeseesi ilmoituksen, joka kutsuu ihmisiä äänestämään ehdotuksesta. Samat vaiheet koskevat myös toimintoja Jaa johtopäätös, Kutsu ketjuun, Muistuta äänestämään, Kyselyä muokattu ja muita vastaavia toimintoja.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automaattiset ilmoitukset
Jos haluat lähettää ilmoituksen aina, kun tietty tapahtuma toteutuu, muokkaa chat-integraatiota ja valitse kyseinen tapahtuma.

![](chatbot_enable_automatic_notifications.png)
