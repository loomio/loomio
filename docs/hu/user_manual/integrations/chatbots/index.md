---
title: Csevegési integrációk
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
  introduction: 779b2fb09c483fa5
  what-it-looks-like-in-chat: '04819bbcd1b31926'
  generate-a-webhook-url: 792b515bc0f1254e
  set-up-a-chat-integration: 472b775cb86822fa
  invite-to-poll: a658a7c34446d38f
  automatic-notifications: ac7775d8bd814ae7
title_source: 0eca19d30c6d7d3c
title_generated: ca0520d18e5461f9
---

<!-- translation-section: introduction -->

# Csevegési integrációk

A Loomio értesítéseket tud küldeni a csevegőszobádba.

A csevegőeszközök és a Loomio jól működnek együtt. Használd a csevegést gyors beszélgetésekhez és aktuális hírek megosztásához. Vidd át a fontos témákat a Loomióba, amikor a résztvevőknek időre van szükségük a bekapcsolódáshoz, döntést kell hozni, vagy a csoportnak tartósan meg kell őriznie az elhangzottakat.

A Loomio támogatja a Slack, Discord, Microsoft Teams, Matrix és Mattermost szolgáltatásokat.

Bármikor küldhetsz értesítéseket a csevegőszobádba, ugyanúgy, ahogyan egyes embereket hívnál meg szavazni vagy csatlakozni egy szálhoz.

Azt is beállíthatod, hogy egy adott esemény bekövetkezésekor mindig értesítést küldjön, például amikor valaki új szálat indít.

<!-- translation-section: what-it-looks-like-in-chat -->

## Így jelenik meg a csevegésben
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Webhook URL létrehozása
Minden támogatott szolgáltatáshoz készítettünk lépésről lépésre követhető útmutatót. Kövesd a szolgáltatásodhoz tartozó útmutatót, hogy megkapd a webhook URL-t, amelyre a csevegési integráció hozzáadásához lesz szükséged a Loomióban.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Webhookalapú rendszerünk más, HTML- vagy Markdown-formázású bejövő webhookokat támogató rendszerekkel is használható. Ilyen például a Zapier vagy a Rocketchat. Válaszd ki a Mattermost botot, de adj meg egy egyéni webhook URL-t.

<!-- translation-section: set-up-a-chat-integration -->

## Csevegési integráció beállítása

Miután beállítottad a kiválasztott szolgáltatást (lásd fent), rendelkezésedre áll egy webhook URL. Nyisd meg a **Csevegési integrációk** menüpontot a csoport menüjéből, és adj hozzá egy új csevegési integrációt a csoportodhoz.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Egyelőre valószínűleg nem szeretnél egyetlen jelölőnégyzetet sem bejelölni. Csak add meg a nevet (például „Discord #general”) és az URL-t, majd kattints az űrlap alján található mentés gombra.

![](loomio-chatbot-form.png)

Ha később úgy döntesz, hogy az integráció automatikus értesítéseket is kapjon, térj vissza a beállításaihoz, és válaszd ki a megfelelő eseményeket.

<!-- translation-section: invite-to-poll -->

### Meghívás szavazásra

Így küldhetsz értesítést a csevegőszobádba, amellyel meghívod az embereket, hogy szavazzanak egy javaslatról. Ugyanez a folyamat a következtetés megosztásakor, a szálba való meghíváskor, a szavazásra emlékeztetéskor, a szavazás szerkesztésekor és más hasonló esetekben is.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatikus értesítések
Ha azt szeretnéd, hogy egy adott esemény bekövetkezésekor mindig értesítést küldjön, szerkeszd a csevegési integrációt, és válaszd ki az eseményt.

![](chatbot_enable_automatic_notifications.png)
