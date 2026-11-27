---
title: Інтэграцыі з чатам
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
  introduction: 5c2dc445f79f988a
  what-it-looks-like-in-chat: 58c5a5979eac3a80
  generate-a-webhook-url: ce62eee0b74afe27
  set-up-a-chat-integration: caea438f5b73e4b2
  invite-to-poll: 4e0d75f4268388d2
  automatic-notifications: ced1ccb2a4d807ce
title_source: 0eca19d30c6d7d3c
title_generated: 8f5e52e68c5ef859
---

<!-- translation-section: introduction -->

# Інтэграцыі з чатам

Loomio можа адпраўляць апавяшчэнні ў ваш чат.

Чаты і Loomio добра працуюць разам. Выкарыстоўвайце чат для хуткага абмену паведамленнямі і своечасовых абнаўленняў. Пераносьце важныя пытанні ў Loomio, калі людзям патрэбны час для ўдзелу, калі трэба прыняць рашэнне або калі групе патрэбны запіс, які захаваецца надоўга.

Loomio падтрымлівае Slack, Discord, Microsoft Teams, Matrix і Mattermost.

Вы можаце адпраўляць апавяшчэнні ў ваш чат уручную кожны раз, калі запрашаеце людзей да тэмы або апытання. Вы таксама можаце наладзіць аўтаматычныя апавяшчэнні пра пэўныя падзеі, напрыклад пра пачатак абмеркавання.

<!-- translation-section: what-it-looks-like-in-chat -->

## Як гэта выглядае ў чаце

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Падключыце ваш сэрвіс чата

Выконвайце інструкцыі для вашага сэрвісу чата, каб атрымаць URL вэбхука (або, для Matrix, токен доступу бота і ідэнтыфікатар пакоя):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Вы таксама можаце падключыць іншыя сэрвісы, якія прымаюць уваходныя вэбхукі з фарматаваннем HTML або Markdown, напрыклад Zapier або Rocket.Chat. У Loomio выкарыстоўвайце інтэграцыю з чатам **Найважнейшае** і ўвядзіце ўласны URL вэбхука.

<!-- translation-section: set-up-a-chat-integration -->

## Наладзьце інтэграцыю з чатам

Каб дадаваць або рэдагаваць інтэграцыі з чатам, патрэбныя правы адміністратара групы.

1. Пасля наладжвання вашага сэрвісу чата (гл. вышэй) адкрыйце **Налады** на старонцы вашай групы ў Loomio і выберыце **Інтэграцыі з чатам**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Дадайце новую інтэграцыю з чатам для вашага сэрвісу, увядзіце назву (напрыклад, "Discord #general") і ўстаўце URL вэбхука.

   ![](loomio-chatbot-form.png)

3. Выберыце падзеі, пра якія хочаце аўтаматычна адпраўляць апавяшчэнні, або пакіньце іх нявыбранымі, калі хочаце адпраўляць апавяшчэнні толькі ўручную, а затым захавайце налады. Вы можаце змяніць гэтыя налады ў любы час.

<!-- translation-section: invite-to-poll -->

### Адпраўце апавяшчэнне ўручную

Каб паведаміць у ваш чат пра апытанне або абмеркаванне, адкрыйце яго і выберыце **Запрасіць** (або іншае дзеянне для адпраўкі апавяшчэння, напрыклад **Падзяліцца высновай**, **Нагадаць прагаласаваць** або **Апытанне адрэдагавана**). Выберыце вашу інтэграцыю з чатам са спіса атрымальнікаў і адпраўце апавяшчэнне.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Аўтаматычныя апавяшчэнні

Каб адпраўляць апавяшчэнне кожны раз, калі адбываецца пэўная падзея, адрэдагуйце інтэграцыю з чатам і выберыце гэтую падзею.

![](chatbot_enable_automatic_notifications.png)
