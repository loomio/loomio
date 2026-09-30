---
title: Chat-integraatiot
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
  introduction: 05c674165147b6cd
  what-it-looks-like-in-chat: 03ae1e10b9e02c11
  generate-a-webhook-url: 0a81d3fd7d3826c6
  set-up-a-chat-integration: ecd4ac813b9f6e23
  invite-to-poll: 056f7538a55faaeb
  automatic-notifications: 44f4f7a058d945fd
title_source: 0eca19d30c6d7d3c
title_generated: 28857b17fdd84c01
---

<!-- translation-section: introduction -->

# Chat-integraatiot

Loomio voi lähettää ilmoituksia chat-huoneeseesi.

Chat ja Loomio toimivat hyvin yhdessä. Käytä chatia nopeaan keskusteluun ja ajankohtaisiin päivityksiin. Siirrä tärkeät aiheet Loomioon, kun osallistuminen vaatii aikaa, päätös on tehtävä tai ryhmä tarvitsee pysyvän tallenteen.

Loomio tukee Slackia, Discordia, Microsoft Teamsia, Matrixia ja Mattermostia.

Voit lähettää ilmoituksia chat-huoneeseesi milloin tahansa, aivan kuten voit kutsua yksittäisiä ihmisiä äänestämään tai osallistumaan keskusteluun.

Voit myös määrittää ilmoituksen lähtemään automaattisesti tietyn tapahtuman yhteydessä, esimerkiksi kun joku aloittaa keskustelun.

<!-- translation-section: what-it-looks-like-in-chat -->

## Tältä ilmoitus näyttää chatissa
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Luo webhook-URL
Olemme laatineet vaiheittaiset ohjeet jokaiselle tukemallemme palvelulle. Seuraa käyttämäsi palvelun ohjetta saadaksesi webhook-URL:n, jonka tarvitset chat-integraation lisäämiseen Loomiossa.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Webhook-järjestelmää voi käyttää myös muiden saapuvia webhookeja tukevien palvelujen kanssa, jos ne tukevat HTML- tai Markdown-muotoilua. Tällaisia palveluja ovat esimerkiksi Zapier ja Rocketchat. Valitse Mattermost-botti ja käytä omaa webhook-URL:ää.

<!-- translation-section: set-up-a-chat-integration -->

## Määritä chat-integraatio

Kun olet määrittänyt valitsemasi palvelun edellä olevien ohjeiden mukaan, saat webhook-URL:n. Avaa ryhmävalikosta **Chat-integraatiot** ja lisää ryhmällesi uusi chat-integraatio.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Jätä valintaruudut toistaiseksi tyhjiksi. Anna nimi, esimerkiksi ”Discord #general”, ja URL-osoite. Napsauta sitten lomakkeen alaosassa olevaa tallennuspainiketta.

![](loomio-chatbot-form.png)

Jos haluat myöhemmin ottaa automaattiset ilmoitukset käyttöön, palaa integraation asetuksiin ja valitse haluamasi tapahtumat.

<!-- translation-section: invite-to-poll -->

### Kutsu äänestämään

Näin lähetät chat-huoneeseesi ilmoituksen, jossa kutsut ihmisiä äänestämään ehdotuksesta. Jaa päätelmä, Kutsu keskusteluun, Muistuta äänestämään, Kyselyä muokattu ja muut ilmoitukset lähetetään samalla tavalla.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automaattiset ilmoitukset
Jos haluat lähettää ilmoituksen aina tietyn tapahtuman yhteydessä, muokkaa chat-integraatiota ja valitse kyseinen tapahtuma.

![](chatbot_enable_automatic_notifications.png)
