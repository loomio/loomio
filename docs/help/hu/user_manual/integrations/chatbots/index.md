---
title: Csevegési integrációk
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
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
  introduction: c7925ca006587da4
  what-it-looks-like-in-chat: f5c438705f532761
  generate-a-webhook-url: 9e94fdc4553ea9ee
  set-up-a-chat-integration: '09275597e834d8e2'
  invite-to-poll: 4d146ccc64978afd
  automatic-notifications: 9663bbc5cf9dd1c5
title_source: 0eca19d30c6d7d3c
title_generated: ca0520d18e5461f9
---

<!-- translation-section: introduction -->

# Csevegési integrációk

A Loomio értesítéseket tud küldeni a csevegőszobádba.

A csevegőeszközök és a Loomio jól működnek együtt. Használd a csevegést gyors beszélgetésekhez és aktuális hírek megosztásához. Vidd át a fontos témákat a Loomióba, amikor a résztvevőknek időre van szükségük a bekapcsolódáshoz, döntést kell hozni, vagy a csoportnak tartósan meg kell őriznie az elhangzottakat.

A Loomio támogatja a Slack, Discord, Microsoft Teams, Matrix és Mattermost szolgáltatásokat.

Kézzel is küldhetsz értesítéseket a csevegőszobádba, amikor embereket hívsz meg egy szálba vagy szavazásra. Automatikus értesítéseket is beállíthatsz bizonyos eseményekhez, például amikor valaki beszélgetést indít.

<!-- translation-section: what-it-looks-like-in-chat -->

## Így jelenik meg a csevegésben

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## A csevegőszolgáltatásod csatlakoztatása

Kövesd a csevegőszolgáltatásod útmutatóját a webhook URL beszerzéséhez (Matrix esetén egy bot hozzáférési tokenjére és a szoba azonosítójára lesz szükséged):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Más, HTML- vagy Markdown-formázású bejövő webhookokat fogadó szolgáltatásokat is csatlakoztathatsz, például a Zapiert vagy a Rocket.Chatet. Válaszd ki az **A legfontosabb** csevegési integrációt a Loomióban, és add meg az egyéni webhook URL-edet.

<!-- translation-section: set-up-a-chat-integration -->

## Csevegési integráció beállítása

Csevegési integrációk hozzáadásához vagy szerkesztéséhez csoportadminnak kell lenned.

1. A csevegőszolgáltatásod beállítása után (lásd fent) nyisd meg a csoportod oldalán a **Beállítások** menüpontot a Loomióban, és válaszd ki a **Csevegési integrációk** menüpontot.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Adj hozzá egy új csevegési integrációt a szolgáltatásodhoz, adj meg egy nevet (például „Discord #general”), és illeszd be a webhook URL-t.

   ![](loomio-chatbot-form.png)

3. Jelöld be azokat az eseményeket, amelyekről automatikus értesítést szeretnél küldeni, vagy hagyd őket üresen, ha csak kézzel szeretnél értesítéseket küldeni, majd mentsd a beállításokat. Ezeket a beállításokat bármikor módosíthatod.

<!-- translation-section: invite-to-poll -->

### Értesítés küldése kézzel

Ha értesíteni szeretnéd a csevegőszobádat egy szavazásról vagy beszélgetésről, nyisd meg az adott elemet, és válaszd ki a **Meghív** lehetőséget (vagy egy másik értesítési műveletet, például: **Oszd meg az eredményt**, **Emlékeztessen szavazásra** vagy **Szavazás szerkesztve**). Válaszd ki a csevegési integrációdat a címzettek listájából, és küldd el az értesítést.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Automatikus értesítések

Ha azt szeretnéd, hogy egy adott esemény bekövetkezésekor mindig értesítést küldjön, szerkeszd a csevegési integrációt, és válaszd ki az eseményt.

![](chatbot_enable_automatic_notifications.png)
