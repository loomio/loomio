---
title: Chat-integraatiot
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
  introduction: 02f6dc825d340e35
  what-it-looks-like-in-chat: 34004d3b6c5fa6fa
  generate-a-webhook-url: 501f3ba1dfaf32a4
  set-up-a-chat-integration: 9b5f7533fa19bac2
  invite-to-poll: 278e527485b789d5
  automatic-notifications: c86a21b2d9d9df4a
title_source: 0eca19d30c6d7d3c
title_generated: 28857b17fdd84c01
---

<!-- translation-section: introduction -->

# Chat-integraatiot

Loomio voi lähettää ilmoituksia chat-huoneeseesi.

Chat-työkalut ja Loomio toimivat hyvin yhdessä. Käytä chatia nopeaan keskusteluun ja ajankohtaisten tietojen jakamiseen. Siirrä tärkeät aiheet Loomioon, kun ihmiset tarvitsevat aikaa osallistumiseen, kun on tehtävä päätös tai kun ryhmä tarvitsee pysyvän kirjauksen asiasta.

Loomio tukee Slackia, Discordia, Microsoft Teamsia, Matrixia ja Mattermostia.

Voit lähettää ilmoituksia chat-huoneeseesi manuaalisesti aina, kun kutsut ihmisiä ketjuun tai kyselyyn. Voit myös määrittää automaattisia ilmoituksia tietyille tapahtumille, esimerkiksi kun joku aloittaa keskustelun.

<!-- translation-section: what-it-looks-like-in-chat -->

## Miltä ilmoitus näyttää chatissa

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Yhdistä chat-palvelusi

Noudata käyttämäsi chat-palvelun ohjeita saadaksesi webhook-URL:n (tai Matrixin tapauksessa botin käyttöoikeustunnuksen ja huoneen tunnisteen):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Voit yhdistää myös muita palveluja, jotka hyväksyvät saapuvia webhook-kutsuja HTML- tai Markdown-muodossa, kuten Zapierin tai Rocket.Chatin. Valitse Loomiossa **Tärkeintä**-chat-integraatio ja syötä oman palvelusi webhook-URL.

<!-- translation-section: set-up-a-chat-integration -->

## Ota chat-integraatio käyttöön

Sinun on oltava ryhmän ylläpitäjä, jotta voit lisätä tai muokata chat-integraatioita.

1. Kun olet määrittänyt chat-palvelusi (katso yllä), avaa ryhmän valikko Loomiossa ja valitse **Chat-integraatiot**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Lisää palvelullesi uusi chat-integraatio, syötä nimi (esimerkiksi "Discord #general") ja liitä webhook-URL.

   ![](loomio-chatbot-form.png)

3. Valitse tapahtumat, joista haluat lähettää ilmoituksia automaattisesti, tai jätä ne valitsematta, jos haluat lähettää ilmoituksia vain manuaalisesti. Tallenna sitten asetukset. Voit muuttaa näitä asetuksia milloin tahansa.

<!-- translation-section: invite-to-poll -->

### Lähetä ilmoitus manuaalisesti

Jos haluat ilmoittaa chat-huoneeseesi kyselystä tai keskustelusta, avaa kyseinen kysely tai keskustelu ja valitse **Kutsu** (tai jokin muu ilmoitustoiminto, kuten **Jaa johtopäätös**, **Muistuta äänestämään** tai **Kyselyä muokattu**). Valitse chat-integraatiosi vastaanottajaluettelosta ja lähetä ilmoitus.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automaattiset ilmoitukset

Jos haluat lähettää ilmoituksen aina, kun tietty tapahtuma toteutuu, muokkaa chat-integraatiota ja valitse kyseinen tapahtuma.

![](chatbot_enable_automatic_notifications.png)
