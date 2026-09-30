---
title: Csevegési integrációk
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
  introduction: 81f4a57a1af8cc0a
  what-it-looks-like-in-chat: '04819bbcd1b31926'
  generate-a-webhook-url: aa9457fd03ed2f94
  set-up-a-chat-integration: 6ed6330937a75541
  invite-to-poll: 2963690863a3cca8
  automatic-notifications: e7ab89c6f098fce9
title_source: 0eca19d30c6d7d3c
title_generated: ca0520d18e5461f9
---

<!-- translation-section: introduction -->

# Csevegési integrációk

A Loomio értesítéseket küldhet a csevegőszobádba.

A csevegőeszközök és a Loomio jól kiegészítik egymást. A csevegést használd gyors beszélgetésekre és időszerű hírek megosztására. A fontos témákat vidd át a Loomióba, ha az embereknek időre van szükségük a részvételhez, döntést kell hozni, vagy a csoportnak később is visszakereshető feljegyzésre lesz szüksége.

A Loomio támogatja a Slack, a Discord, a Microsoft Teams, a Matrix és a Mattermost használatát.

Bármikor küldhetsz értesítést a csevegőszobádba, ahogyan egyes embereket is meghívhatsz szavazásra vagy egy témába.

Azt is beállíthatod, hogy bizonyos eseményekkor, például egy téma indításakor, mindig menjen értesítés.

<!-- translation-section: what-it-looks-like-in-chat -->

## Így jelenik meg a csevegésben
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Webhook URL létrehozása
Minden támogatott szolgáltatáshoz készítettünk részletes útmutatót. A szolgáltatásodhoz tartozó útmutatót követve szerezd be azt a webhook URL-t, amellyel hozzáadhatod a csevegési integrációt a Loomióban.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

A webhookokra épülő rendszer más, HTML vagy Markdown formázású bejövő webhookokat fogadó szolgáltatásokkal is működhet, például a Zapierrel vagy a Rocketchattel. Ehhez válaszd a Mattermost botot, és adj meg egy egyéni webhook URL-t.

<!-- translation-section: set-up-a-chat-integration -->

## Csevegési integráció beállítása

Miután beállítottad a választott szolgáltatást (lásd fent), lesz egy webhook URL-ed. Nyisd meg a csoport menüjében a **Csevegési integrációk** pontot, és adj hozzá egy új csevegési integrációt a csoportodhoz.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Egyelőre valószínűleg nem kell bejelölnöd semmit. Add meg a nevet (például „Discord #general”) és az URL-t, majd kattints az űrlap alján lévő mentés gombra.

![](loomio-chatbot-form.png)

Ha később automatikus értesítéseket szeretnél küldeni az integrációval, térj vissza a beállításaihoz, és válaszd ki a megfelelő eseményeket.

<!-- translation-section: invite-to-poll -->

### Meghívás szavazásra

Így küldhetsz értesítést a csevegőszobádba, hogy szavazásra hívd az embereket egy javaslatban. Ugyanígy oszthatsz meg következtetést, hívhatsz meg embereket egy témába, emlékeztethetsz valakit a szavazásra, vagy jelezheted egy szavazás módosítását.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatikus értesítések
Ha egy adott esemény bekövetkezésekor mindig értesítést szeretnél küldeni, szerkeszd a csevegési integrációt, és válaszd ki az eseményt.

![](chatbot_enable_automatic_notifications.png)
