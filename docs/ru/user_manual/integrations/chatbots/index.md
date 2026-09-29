---
title: Интеграция чата
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
  introduction: 8ef945f550cfd617
  what-it-looks-like-in-chat: 3915fbf6da411a3c
  generate-a-webhook-url: 5da98ae61c03dca0
  set-up-a-chat-integration: 989d24a54a50f11d
  invite-to-poll: d8ef39cc0658b966
  automatic-notifications: 371dca7c9c3c6512
title_source: 0eca19d30c6d7d3c
title_generated: af59c665c54611ef
---

<!-- translation-section: introduction -->

# Интеграция чата

Loomio может отправлять уведомления в ваш чат.

Чат и Loomio удобно использовать вместе. В чате можно быстро обсудить вопрос и обменяться новостями. Переносите важные темы в Loomio, если людям нужно время на участие, группе предстоит принять решение или сохранить запись обсуждения.

Loomio поддерживает Slack, Discord, Microsoft Teams, Matrix и Mattermost.

Вы можете в любой момент отправить уведомление в чат, как если бы приглашали отдельных людей проголосовать или присоединиться к обсуждению.

Вы также можете настроить автоматическую отправку уведомлений о событиях, например о начале обсуждения.

<!-- translation-section: what-it-looks-like-in-chat -->

## Как это выглядит в чате
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Получите URL вебхука
Мы подготовили пошаговые инструкции для каждого поддерживаемого сервиса. Следуйте инструкции для вашего сервиса, чтобы получить URL вебхука для подключения чата к Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

С помощью вебхуков можно подключить и другие сервисы, которые принимают входящие вебхуки в формате HTML или Markdown, например Zapier или Rocketchat. Выберите бота Mattermost и укажите собственный URL вебхука.

<!-- translation-section: set-up-a-chat-integration -->

## Настройте интеграцию чата

После настройки выбранного сервиса (см. выше) у вас будет URL вебхука. В меню группы откройте **Интеграция чата** и добавьте новую интеграцию чата для группы.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Пока оставьте все флажки снятыми. Укажите название (например, «Discord #general») и URL, затем нажмите кнопку сохранения внизу формы.

![](loomio-chatbot-form.png)

Если позже вы захотите получать автоматические уведомления через эту интеграцию, вернитесь к её настройкам и выберите нужные события.

<!-- translation-section: invite-to-poll -->

### Пригласить голосовать

Так можно отправить в чат уведомление с приглашением проголосовать по предложению. Таким же образом можно поделиться итогом, пригласить к обсуждению, напомнить о голосовании, сообщить об изменении опроса и отправить другие уведомления.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Автоматические уведомления
Чтобы получать уведомление каждый раз, когда происходит определённое событие, откройте настройки интеграции чата и выберите это событие.

![](chatbot_enable_automatic_notifications.png)
