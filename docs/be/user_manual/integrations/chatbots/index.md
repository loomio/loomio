---
title: Інтэграцыі з чатам
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
  introduction: 161bcb944b6fccd5
  what-it-looks-like-in-chat: 0f6f7b91542c2c00
  generate-a-webhook-url: be94eec80c9ce063
  set-up-a-chat-integration: 9742f177f2dde37a
  invite-to-poll: a3307e8a73f06b90
  automatic-notifications: 02635c94f5b97ef8
title_source: 0eca19d30c6d7d3c
title_generated: 8f5e52e68c5ef859
---

<!-- translation-section: introduction -->

# Інтэграцыі з чатам

Loomio можа адпраўляць апавяшчэнні ў ваш чат.

Інструменты для чата і Loomio добра працуюць разам. Выкарыстоўвайце чат для хуткіх размоў і своечасовых паведамленняў. Пераносьце важныя пытанні ў Loomio, калі людзям патрэбны час для ўдзелу, калі трэба прыняць рашэнне або калі групе спатрэбіцца захаваны запіс.

Loomio падтрымлівае Slack, Discord, Microsoft Teams, Matrix і Mattermost.

Вы можаце адпраўляць апавяшчэнні ў ваш чат у любы час гэтак жа, як запрашаеце асобных людзей прагаласаваць або далучыцца да тэмы.

Вы таксама можаце наладзіць аўтаматычнае адпраўленне апавяшчэнняў пры пэўных падзеях, напрыклад пры стварэнні тэмы.

<!-- translation-section: what-it-looks-like-in-chat -->

## Як гэта выглядае ў чаце
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Стварыце URL вэбхука
Мы падрыхтавалі пакрокавыя інструкцыі для кожнага сэрвісу, які падтрымліваем. Выкарыстоўвайце інструкцыю для вашага сэрвісу, каб атрымаць URL вэбхука, неабходны для дадання інтэграцыі з чатам у Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Нашу сістэму на аснове вэбхукаў можна таксама выкарыстоўваць з іншымі сістэмамі, якія падтрымліваюць уваходныя вэбхукі з фарматаваннем HTML або Markdown. Напрыклад, гэта могуць быць Zapier або Rocketchat.
Проста выберыце бота Mattermost, але ўкажыце ўласны URL вэбхука.

<!-- translation-section: set-up-a-chat-integration -->

## Наладзьце інтэграцыю з чатам

Пасля наладжвання абранага сэрвісу (гл. вышэй) у вас будзе URL вэбхука.
Адкрыйце **Інтэграцыі з чатам** у меню групы і дадайце новую інтэграцыю з чатам для вашай групы.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

На гэтым этапе, верагодна, не трэба пазначаць ніводнага сцяжка. Проста ўвядзіце назву (напрыклад, «Discord #general») і URL, затым націсніце кнопку захавання ўнізе формы.

![](loomio-chatbot-form.png)

Калі пазней вы вырашыце, што інтэграцыя павінна атрымліваць аўтаматычныя апавяшчэнні, вярніцеся да яе налад і выберыце адпаведныя падзеі.

<!-- translation-section: invite-to-poll -->

### Запрасіць да апытання

Вось як адправіць у ваш чат апавяшчэнне з запрашэннем прагаласаваць па прапанове.
Такі ж парадак дзеянняў выкарыстоўваецца для «Падзяліцца высновай», «Запрасіць да тэмы», «Нагадаць пра галасаванне», «Апытанне адрэдагавана» і іншых дзеянняў.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Аўтаматычныя апавяшчэнні
Каб адпраўляць апавяшчэнне кожны раз, калі адбываецца пэўная падзея, адрэдагуйце інтэграцыю з чатам і выберыце гэтую падзею.

![](chatbot_enable_automatic_notifications.png)
