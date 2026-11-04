---
title: Інтеграції чату
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
  introduction: 64828d94c32a7d0c
  what-it-looks-like-in-chat: 8cb9654b137f8fee
  generate-a-webhook-url: dabf1610ea23f54e
  set-up-a-chat-integration: 7a06838e6b042cb2
  invite-to-poll: 6fdfb312281c7e39
  automatic-notifications: 0e455059dc0991e9
title_source: 0eca19d30c6d7d3c
title_generated: cabbf17c354c8fd1
---

<!-- translation-section: introduction -->

# Інтеграції чату

Loomio може надсилати сповіщення до вашого чату.

Інструменти чату та Loomio добре доповнюють одне одного. Використовуйте чат для швидкого спілкування та своєчасних повідомлень. Переносьте важливі питання до Loomio, коли людям потрібен час для участі, коли потрібно ухвалити рішення або коли групі потрібно зберегти запис для подальшого використання.

Loomio підтримує Slack, Discord, Microsoft Teams, Matrix і Mattermost.

Ви можете надсилати сповіщення до вашого чату будь-коли — так само, як запрошуєте окремих людей голосувати або приєднатися до теми.

Ви також можете налаштувати автоматичне надсилання сповіщень щоразу, коли відбувається певна подія, наприклад коли хтось створює тему.

<!-- translation-section: what-it-looks-like-in-chat -->

## Як це виглядає в чаті
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Отримайте URL вебхука
Ми підготували покрокові інструкції для кожного сервісу, який підтримуємо. Скористайтеся інструкцією для вашого сервісу, щоб отримати URL вебхука, потрібний для додавання інтеграції чату в Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Наша система на основі вебхуків також може працювати з іншими системами, які підтримують вхідні вебхуки з форматуванням HTML або Markdown. Наприклад, це можуть бути Zapier або Rocketchat.

Виберіть бота Mattermost, але вкажіть власний URL вебхука.

<!-- translation-section: set-up-a-chat-integration -->

## Налаштуйте інтеграцію чату

Після налаштування вибраного сервісу (див. вище) ви отримаєте URL вебхука. Відкрийте **Інтеграції чату** в меню групи та додайте нову інтеграцію чату для вашої групи.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Наразі можна залишити всі прапорці невстановленими. Введіть назву (наприклад, "Discord #general") і URL, а потім натисніть кнопку збереження внизу форми.

![](loomio-chatbot-form.png)

Якщо згодом ви захочете, щоб інтеграція отримувала автоматичні сповіщення, поверніться до її налаштувань і виберіть відповідні події.

<!-- translation-section: invite-to-poll -->

### Запросіть до опитування

Ось як надіслати сповіщення до вашого чату із запрошенням голосувати щодо пропозиції. Так само можна поділитися висновком, запросити до теми, нагадати про голосування, повідомити про редагування опитування тощо.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Автоматичні сповіщення
Щоб надсилати сповіщення щоразу, коли відбувається певна подія, відредагуйте інтеграцію чату та виберіть цю подію.

![](chatbot_enable_automatic_notifications.png)
