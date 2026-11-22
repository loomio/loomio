---
title: Slack
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/slack/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ea379b6fc01065b6
generated:
  introduction: 8344dbaf913cc5e4
title_source: b27fb38ba323745c
title_generated: b27fb38ba323745c
---

<!-- translation-section: introduction -->

# Интеграция со Slack

Loomio может отправлять уведомления в ваши каналы Slack при появлении новых обсуждений, опросов, комментариев, голосов и выводов.

---

1. Откройте [api.slack.com](https://api.slack.com), войдите в свою учётную запись и выберите **Создать новое приложение (Create New App)**.

   ![](s1.png)

2. Задайте название вашему приложению Slack и выберите рабочее пространство.

   ![](s2.png)

3. Выберите **Входящие вебхуки (Incoming Webhooks)**.

   ![](s3.png)

4. Включите **Активировать входящие вебхуки (Activate Incoming Webhooks)**.

   ![](s4.png)

5. Выберите **Добавить новый вебхук в рабочее пространство (Add New Webhook to Workspace)**.

   ![](s5.png)

6. Выберите канал, в котором должны появляться уведомления Loomio.

   ![](s6.png)

7. Скопируйте URL вебхука.

   ![](s7.png)

Теперь, когда у вас есть URL вебхука, завершите его подключение в Loomio:

[Настройте интеграцию с чатом в Loomio](../chatbots/#set-up-a-chat-integration)

_Slack не разрабатывает и не поддерживает Loomio и не связан с ним._
