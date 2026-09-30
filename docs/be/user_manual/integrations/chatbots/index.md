---
title: Інтэграцыі з чатам
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
  introduction: ed3e771ed9d18b59
  what-it-looks-like-in-chat: 0f6f7b91542c2c00
  generate-a-webhook-url: ac686ec3c95018cd
  set-up-a-chat-integration: bde265ab79a58f27
  invite-to-poll: '089e99b5fd983f12'
  automatic-notifications: 02635c94f5b97ef8
title_source: 0eca19d30c6d7d3c
title_generated: 8f5e52e68c5ef859
---

<!-- translation-section: introduction -->

# Інтэграцыі з чатам

Loomio можа адпраўляць апавяшчэнні ў чат вашай групы.

Чат і Loomio добра дапаўняюць адно аднаго. Выкарыстоўвайце чат для кароткіх размоў і хуткіх абнаўленняў. Пераносьце важныя тэмы ў Loomio, калі людзям патрэбны час для ўдзелу, групе трэба прыняць рашэнне або захаваць запіс абмеркавання.

Loomio падтрымлівае Slack, Discord, Microsoft Teams, Matrix і Mattermost.

Вы можаце ў любы час адправіць апавяшчэнне ў чат вашай групы, гэтак жа як запрашаеце асобных людзей прагаласаваць або далучыцца да тэмы.

Таксама можна наладзіць аўтаматычныя апавяшчэнні пра пэўныя падзеі, напрыклад пра пачатак новай тэмы.

<!-- translation-section: what-it-looks-like-in-chat -->

## Як гэта выглядае ў чаце
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Стварыце URL-адрас вэбхука
Мы падрыхтавалі пакрокавыя інструкцыі для кожнага сэрвісу, які падтрымліваем. Выконвайце інструкцыю для свайго сэрвісу, каб атрымаць URL-адрас вэбхука. Ён спатрэбіцца для дадання інтэграцыі з чатам у Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Праз вэбхук можна падключыць і іншыя сэрвісы, якія прымаюць уваходныя вэбхукі з фарматаваннем HTML або Markdown, напрыклад Zapier ці Rocketchat. Выберыце бота Mattermost і ўкажыце ўласны URL-адрас вэбхука.

<!-- translation-section: set-up-a-chat-integration -->

## Наладзьце інтэграцыю з чатам

Пасля наладкі выбранага сэрвісу (гл. вышэй) у вас будзе URL-адрас вэбхука. Адкрыйце **Інтэграцыі з чатам** у меню групы і дадайце новую інтэграцыю з чатам для сваёй групы.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Пакуль можна не адзначаць сцяжкі. Увядзіце назву (напрыклад, «Discord #general») і URL-адрас, затым націсніце кнопку захавання ўнізе формы.

![](loomio-chatbot-form.png)

Калі пазней вы захочаце атрымліваць аўтаматычныя апавяшчэнні праз гэтую інтэграцыю, вярніцеся да яе налад і выберыце патрэбныя падзеі.

<!-- translation-section: invite-to-poll -->

### Запрасіце прагаласаваць у апытанні

Так можна адправіць у чат запрашэнне прагаласаваць па прапанове. Такім жа чынам можна падзяліцца высновай, запрасіць да тэмы, нагадаць пра галасаванне, паведаміць пра змяненне апытання і іншыя падзеі.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Аўтаматычныя апавяшчэнні
Каб адпраўляць апавяшчэнне кожны раз, калі адбываецца пэўная падзея, адрэдагуйце інтэграцыю з чатам і выберыце гэтую падзею.

![](chatbot_enable_automatic_notifications.png)
