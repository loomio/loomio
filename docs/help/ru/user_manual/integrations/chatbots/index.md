---
title: Интеграция чата
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
  introduction: 4cd31645b8969e10
  what-it-looks-like-in-chat: e370aae9abd07169
  generate-a-webhook-url: 6283eac2dbdca600
  set-up-a-chat-integration: dcaa7393e89f86b8
  invite-to-poll: '099aa9c1a65f16d5'
  automatic-notifications: f4cb6947bc8faea4
title_source: 0eca19d30c6d7d3c
title_generated: af59c665c54611ef
---

<!-- translation-section: introduction -->

# Интеграция чата

Loomio может отправлять уведомления в ваш чат.

Чаты и Loomio хорошо дополняют друг друга. Используйте чат для быстрого общения и своевременных сообщений. Переносите важные темы в Loomio, когда людям нужно время для участия, когда необходимо принять решение или когда группе нужно надолго сохранить запись обсуждения.

Loomio поддерживает Slack, Discord, Microsoft Teams, Matrix и Mattermost.

Вы можете вручную отправлять уведомления в ваш чат, когда приглашаете людей в ветку или опрос. Вы также можете настроить автоматические уведомления об определённых событиях, например когда кто-то начинает обсуждение.

<!-- translation-section: what-it-looks-like-in-chat -->

## Как это выглядит в чате

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Подключите ваш сервис чата

Следуйте инструкции для вашего сервиса чата, чтобы получить URL вебхука (или, для Matrix, токен доступа бота и идентификатор комнаты):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Вы также можете подключить другие сервисы, которые поддерживают входящие вебхуки с форматированием HTML или Markdown, например Zapier или Rocket.Chat. Выберите интеграцию чата **самое важное** в Loomio и введите собственный URL вебхука.

<!-- translation-section: set-up-a-chat-integration -->

## Настройте интеграцию чата

Чтобы добавлять или изменять интеграции чата, вы должны быть администратором группы.

1. После настройки вашего сервиса чата (см. выше) откройте **Настройки** на странице вашей группы в Loomio и выберите **Интеграция чата**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Добавьте новую интеграцию чата для вашего сервиса, введите название (например, "Discord #general") и вставьте URL вебхука.

   ![](loomio-chatbot-form.png)

3. Выберите события, уведомления о которых нужно отправлять автоматически, или оставьте все события невыбранными, если хотите отправлять уведомления только вручную, затем сохраните настройки. Вы можете изменить эти настройки в любое время.

<!-- translation-section: invite-to-poll -->

### Отправьте уведомление вручную

Чтобы уведомить ваш чат об опросе или обсуждении, откройте опрос или обсуждение и выберите **Приглашать** (или другое действие для отправки уведомления, например **Поделиться результатом**, **Напомнить проголосовать** или **Опрос изменён**). Выберите вашу интеграцию чата в списке получателей и отправьте уведомление.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Автоматические уведомления

Чтобы отправлять уведомление каждый раз, когда происходит определённое событие, откройте настройки интеграции чата и выберите это событие.

![](chatbot_enable_automatic_notifications.png)
