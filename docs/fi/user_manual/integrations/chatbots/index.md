---
title: Chat-integraatiot
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
  introduction: a75babac5890ac57
  what-it-looks-like-in-chat: fa55abaf399a7070
  generate-a-webhook-url: eecf0f79210b4ca8
  set-up-a-chat-integration: 40bd0330bc094f30
  invite-to-poll: 0c0ca0df4435b0f7
  automatic-notifications: 44f4f7a058d945fd
title_source: 0eca19d30c6d7d3c
title_generated: 28857b17fdd84c01
---

<!-- translation-section: introduction -->

# Chat-integraatiot

Loomio voi lähettää ilmoituksia chat-huoneeseesi.

Chat-työkalut ja Loomio toimivat hyvin yhdessä. Käytä chatia nopeaan keskusteluun ja ajankohtaisten päivitysten jakamiseen. Siirrä tärkeät aiheet Loomioon, kun ihmiset tarvitsevat aikaa osallistumiseen, kun on tehtävä päätös tai kun ryhmä tarvitsee pysyvän tallenteen.

Loomio tukee Slackia, Discordia, Microsoft Teamsia, Matrixia ja Mattermostia.

Voit lähettää ilmoituksia chat-huoneeseesi milloin haluat samalla tavalla kuin kutsuisit yksittäisiä ihmisiä äänestämään tai liittymään ketjuun.

Voit myös määrittää ilmoitukset lähetettäviksi aina tietyn tapahtuman yhteydessä, esimerkiksi kun joku aloittaa ketjun.

<!-- translation-section: what-it-looks-like-in-chat -->

## Miltä ilmoitus näyttää chatissa
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Luo webhook-URL
Olemme laatineet vaiheittaiset ohjeet jokaiselle tukemallemme palvelulle. Noudata käyttämäsi palvelun ohjeita saadaksesi webhook-URL:n, jota tarvitset chat-integraation lisäämiseen Loomiossa.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Webhook-pohjaista järjestelmäämme voi käyttää myös muiden järjestelmien kanssa, jotka tukevat saapuvia webhookeja HTML- tai Markdown-muodossa. Tällaisia ovat esimerkiksi Zapier ja Rocketchat. Valitse Mattermost-botti ja käytä omaa webhook-URL:ää.

<!-- translation-section: set-up-a-chat-integration -->

## Ota chat-integraatio käyttöön

Kun olet määrittänyt valitsemasi palvelun asetukset (katso yllä), sinulla on webhook-URL. Avaa ryhmän valikosta **Chat-integraatiot** ja lisää ryhmällesi uusi chat-integraatio.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Et todennäköisesti halua vielä valita mitään valintaruuduista. Syötä vain nimi (esimerkiksi "Discord #general") ja URL ja napsauta lomakkeen alareunan tallennuspainiketta.

![](loomio-chatbot-form.png)

Jos haluat myöhemmin integraation vastaanottavan automaattisia ilmoituksia, palaa sen asetuksiin ja valitse haluamasi tapahtumat.

<!-- translation-section: invite-to-poll -->

### Kutsu kyselyyn

Näin lähetät chat-huoneeseesi ilmoituksen, jossa kutsut ihmisiä äänestämään ehdotuksesta. Samat vaiheet koskevat myös toimintoja Jaa johtopäätös, Kutsu ketjuun, Muistuta äänestämään, Kyselyä muokattu ja muita vastaavia toimintoja.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automaattiset ilmoitukset
Jos haluat lähettää ilmoituksen aina tietyn tapahtuman yhteydessä, muokkaa chat-integraatiota ja valitse kyseinen tapahtuma.

![](chatbot_enable_automatic_notifications.png)
