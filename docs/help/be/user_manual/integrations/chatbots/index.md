---
title: Інтэграцыі з чатам
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
  introduction: c82d1161d8f85a04
  what-it-looks-like-in-chat: 0f6f7b91542c2c00
  generate-a-webhook-url: 48a07d4fb2312baf
  set-up-a-chat-integration: ab14588bca6795c6
  invite-to-poll: 4dff9a0801f5207d
  automatic-notifications: 02635c94f5b97ef8
title_source: 0eca19d30c6d7d3c
title_generated: 8f5e52e68c5ef859
---

<!-- translation-section: introduction -->

# Інтэграцыі з чатам

Loomio можа адпраўляць апавяшчэнні ў ваш чат.

Чаты і Loomio добра працуюць разам. Выкарыстоўвайце чат для хуткага абмену паведамленнямі і своечасовых абнаўленняў. Пераносьце важныя пытанні ў Loomio, калі людзям патрэбны час для ўдзелу, калі трэба прыняць рашэнне або калі групе спатрэбіцца запіс, які захаваецца надоўга.

Loomio падтрымлівае Slack, Discord, Microsoft Teams, Matrix і Mattermost.

Вы можаце адпраўляць апавяшчэнні ў ваш чат у любы час гэтак жа, як запрашаеце асобных людзей прагаласаваць або далучыцца да тэмы.

Вы таксама можаце наладзіць аўтаматычныя апавяшчэнні пра пэўныя падзеі, напрыклад пра стварэнне новай тэмы.

<!-- translation-section: what-it-looks-like-in-chat -->

## Як гэта выглядае ў чаце
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Стварыце URL вэбхука
Мы падрыхтавалі пакрокавыя інструкцыі для кожнага сэрвісу, які падтрымліваем. Выканайце інструкцыі для вашага сэрвісу, каб атрымаць URL вэбхука, патрэбны для дадання інтэграцыі з чатам у Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Нашу сістэму на аснове вэбхукаў таксама можна выкарыстоўваць з іншымі сістэмамі, якія падтрымліваюць уваходныя вэбхукі з фарматаваннем HTML або Markdown. Гэта могуць быць, напрыклад, Zapier або Rocketchat.
Проста выберыце бота Mattermost, але ўкажыце ўласны URL вэбхука.

<!-- translation-section: set-up-a-chat-integration -->

## Наладзьце інтэграцыю з чатам

Пасля наладжвання выбранага сэрвісу (гл. вышэй) у вас будзе URL вэбхука.
Адкрыйце **Інтэграцыі з чатам** у меню групы і дадайце новую інтэграцыю з чатам для вашай групы.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Пакуль сцяжкі можна не пазначаць. Проста ўвядзіце назву (напрыклад, "Discord #general") і URL, а затым націсніце кнопку захавання ўнізе формы.

![](loomio-chatbot-form.png)

Калі пазней вы вырашыце, што інтэграцыя павінна атрымліваць аўтаматычныя апавяшчэнні, вярніцеся да яе налад і выберыце адпаведныя падзеі.

<!-- translation-section: invite-to-poll -->

### Запрасіце да апытання

Вось як адправіць у ваш чат апавяшчэнне з запрашэннем прагаласаваць па прапанове.
Такі ж парадак дзеянняў выкарыстоўваецца, каб падзяліцца высновай, запрасіць да тэмы, нагадаць пра галасаванне, паведаміць пра змены ў апытанні і г.д.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Аўтаматычныя апавяшчэнні
Каб адпраўляць апавяшчэнне кожны раз, калі адбываецца пэўная падзея, адрэдагуйце інтэграцыю з чатам і выберыце гэтую падзею.

![](chatbot_enable_automatic_notifications.png)
