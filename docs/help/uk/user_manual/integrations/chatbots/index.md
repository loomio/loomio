---
title: Інтеграції чату
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
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
  introduction: 5ba82ecd9b785b3c
  what-it-looks-like-in-chat: 2ffe0288cd413e96
  generate-a-webhook-url: 6a371fc56779b852
  set-up-a-chat-integration: 191c4c3240759371
  invite-to-poll: f678f603e000bd4d
  automatic-notifications: 2ef9dc0b92c6804f
title_source: 0eca19d30c6d7d3c
title_generated: cabbf17c354c8fd1
---

<!-- translation-section: introduction -->

# Інтеграції чату

Loomio може надсилати сповіщення до вашого чату.

Інструменти чату та Loomio добре доповнюють одне одного. Використовуйте чат для швидкого спілкування та своєчасних повідомлень. Переносьте важливі питання до Loomio, коли людям потрібен час для участі, коли потрібно ухвалити рішення або коли групі потрібно зберегти запис для подальшого використання.

Loomio підтримує Slack, Discord, Microsoft Teams, Matrix і Mattermost.

Ви можете надсилати сповіщення до вашого чату вручну щоразу, коли запрошуєте людей до теми або опитування. Ви також можете налаштувати автоматичні сповіщення про певні події, наприклад коли хтось починає обговорення.

<!-- translation-section: what-it-looks-like-in-chat -->

## Як це виглядає в чаті

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Підключіть ваш сервіс чату

Скористайтеся інструкцією для вашого сервісу чату, щоб отримати URL вебхука (або, для Matrix, токен доступу бота та ідентифікатор кімнати):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Ви також можете підключити інші сервіси, які приймають вхідні вебхуки з форматуванням HTML або Markdown, наприклад Zapier або Rocket.Chat. У Loomio скористайтеся інтеграцією чату **Головне** та введіть власний URL вебхука.

<!-- translation-section: set-up-a-chat-integration -->

## Налаштуйте інтеграцію чату

Щоб додавати або редагувати інтеграції чату, ви повинні бути адміністратором групи.

1. Після налаштування вашого сервісу чату (див. вище) відкрийте **Налаштування** на сторінці вашої групи в Loomio та виберіть **Інтеграції чату**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Додайте нову інтеграцію чату для вашого сервісу, введіть назву (наприклад, "Discord #general") і вставте URL вебхука.

   ![](loomio-chatbot-form.png)

3. Виберіть події, про які потрібно автоматично надсилати сповіщення, або залиште їх невибраними, якщо хочете надсилати сповіщення лише вручну, а потім збережіть налаштування. Ви можете змінити ці налаштування будь-коли.

<!-- translation-section: invite-to-poll -->

### Надішліть сповіщення вручну

Щоб повідомити учасників вашого чату про опитування або обговорення, відкрийте його та виберіть **Запросити** (або іншу дію для надсилання сповіщень, наприклад **Поширити висновок**, **Нагадати проголосувати** або **Опитування відредаговано**). Виберіть вашу інтеграцію чату зі списку одержувачів і надішліть сповіщення.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Автоматичні сповіщення

Щоб надсилати сповіщення щоразу, коли відбувається певна подія, відредагуйте інтеграцію чату та виберіть цю подію.

![](chatbot_enable_automatic_notifications.png)
