---
title: Інтеграції чату
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
  introduction: d41de149cc307061
  what-it-looks-like-in-chat: 8cb9654b137f8fee
  generate-a-webhook-url: 8510e452c921c3ac
  set-up-a-chat-integration: 97f4fc55a465e4d9
  invite-to-poll: 69fa742d73eeb46a
  automatic-notifications: 598b264cac4b45c3
title_source: 0eca19d30c6d7d3c
title_generated: cabbf17c354c8fd1
---

<!-- translation-section: introduction -->

# Інтеграції чату

Loomio може надсилати сповіщення до вашого чату.

Чат і Loomio добре доповнюють одне одного. Використовуйте чат для коротких розмов і своєчасних оновлень. Переносьте важливі питання до Loomio, коли людям потрібен час для участі, необхідно ухвалити рішення або групі знадобиться зберегти історію обговорення.

Loomio підтримує Slack, Discord, Microsoft Teams, Matrix і Mattermost.

Ви можете будь-коли надіслати сповіщення до свого чату так само, як запрошуєте окремих людей проголосувати або приєднатися до теми.

Ви також можете налаштувати автоматичні сповіщення про певні події, наприклад коли хтось створює тему.

<!-- translation-section: what-it-looks-like-in-chat -->

## Як це виглядає в чаті
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Отримайте URL-адресу вебхука
Ми підготували покрокові інструкції для кожного підтримуваного сервісу. Дотримуйтесь інструкції для свого сервісу, щоб отримати URL-адресу вебхука. Вона знадобиться для додавання інтеграції чату в Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Інтеграція через вебхуки також працює з іншими сервісами, які приймають вхідні вебхуки з форматуванням HTML або Markdown, наприклад Zapier чи Rocketchat. Виберіть бота Mattermost і вкажіть власну URL-адресу вебхука.

<!-- translation-section: set-up-a-chat-integration -->

## Налаштуйте інтеграцію чату

Після налаштування вибраного сервісу (див. вище) ви отримаєте URL-адресу вебхука. Відкрийте **Інтеграції чату** в меню групи та додайте нову інтеграцію чату для своєї групи.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Поки що залиште всі прапорці порожніми. Введіть назву (наприклад, "Discord #general") і URL-адресу, а потім натисніть кнопку **Зберегти** внизу форми.

![](loomio-chatbot-form.png)

Якщо згодом ви захочете отримувати автоматичні сповіщення через цю інтеграцію, поверніться до її налаштувань і виберіть відповідні події.

<!-- translation-section: invite-to-poll -->

### Запросіть до голосування

Так можна надіслати до чату сповіщення із запрошенням проголосувати за пропозицію. Так само можна поширити висновок, запросити до теми, нагадати про голосування або повідомити про редагування опитування.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Автоматичні сповіщення
Щоб надсилати сповіщення щоразу, коли відбувається певна подія, відкрийте налаштування інтеграції чату та виберіть цю подію.

![](chatbot_enable_automatic_notifications.png)
