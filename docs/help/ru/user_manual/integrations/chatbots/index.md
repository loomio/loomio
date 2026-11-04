---
title: Интеграция чата
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
  introduction: b8894ea02cf0cd16
  what-it-looks-like-in-chat: 3915fbf6da411a3c
  generate-a-webhook-url: 44e61457a8c60d88
  set-up-a-chat-integration: 1ca67fbf177f6e16
  invite-to-poll: 9af3760306eb61f3
  automatic-notifications: 1130031c7b8899d0
title_source: 0eca19d30c6d7d3c
title_generated: af59c665c54611ef
---

<!-- translation-section: introduction -->

# Интеграция чата

Loomio может отправлять уведомления в ваш чат.

Чаты и Loomio хорошо дополняют друг друга. Используйте чат для быстрого общения и своевременных сообщений. Переносите важные темы в Loomio, когда людям нужно время для участия, когда необходимо принять решение или когда группе понадобится сохраняемая запись обсуждения.

Loomio поддерживает Slack, Discord, Microsoft Teams, Matrix и Mattermost.

Вы можете отправлять уведомления в ваш чат в любое время — так же, как приглашаете отдельных людей проголосовать или присоединиться к ветке.

Вы также можете настроить автоматическую отправку уведомлений при определённых событиях, например при создании ветки.

<!-- translation-section: what-it-looks-like-in-chat -->

## Как это выглядит в чате
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Получите URL вебхука
Мы подготовили пошаговые инструкции для каждого поддерживаемого сервиса. Следуйте инструкции для вашего сервиса, чтобы получить URL вебхука, который понадобится для добавления интеграции чата в Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Наша система на основе вебхуков также позволяет подключать другие системы, которые поддерживают входящие вебхуки с форматированием HTML или Markdown, например Zapier или Rocketchat.

Выберите бота Mattermost, но укажите собственный URL вебхука.

<!-- translation-section: set-up-a-chat-integration -->

## Настройте интеграцию чата

После настройки выбранного сервиса (см. выше) у вас будет URL вебхука. Откройте **Интеграция чата** в меню группы и добавьте новую интеграцию чата для вашей группы.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Пока можно оставить все флажки снятыми. Введите название (например, "Discord #general") и URL, затем нажмите кнопку сохранения внизу формы.

![](loomio-chatbot-form.png)

Если позже вы захотите получать автоматические уведомления через интеграцию, вернитесь к её настройкам и выберите нужные события.

<!-- translation-section: invite-to-poll -->

### Пригласите к участию в опросе

Так можно отправить в ваш чат уведомление с приглашением проголосовать по предложению. Таким же образом можно поделиться выводом, пригласить к участию в ветке, напомнить о необходимости проголосовать, сообщить об изменении опроса и т. д.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Автоматические уведомления
Чтобы отправлять уведомление каждый раз, когда происходит определённое событие, откройте настройки интеграции чата и выберите это событие.

![](chatbot_enable_automatic_notifications.png)
