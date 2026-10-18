---
title: API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 919d6d18dd8a3882
  user-api: a492f870a8c74d8b
  server-api: b9cb580218aa28c6
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Використовуйте API Loomio, щоб підключати Loomio до іншого програмного забезпечення та автоматизованих робочих процесів.

[Контракт OpenAPI 3.1](openapi.yaml) описує кожну публічну операцію API користувача та API сервера в машиночитаному форматі. Імпортуйте його в API-клієнт або використовуйте для генерування типізованого клієнтського коду. Наведені нижче посібники пояснюють робочі процеси, права доступу та поведінку, які не повністю описані в контракті.

<!-- translation-section: user-api -->

## API користувача

[API користувача](/en/user_manual/integrations/api/user-api) виконує дії від імені користувача Loomio. Він дає змогу отримувати список груп, створювати теми, коментарі й опитування та керувати ними, а також керувати членством у групах відповідно до прав доступу цього користувача.

Для інтеграцій із надсиланням подій [вебхуки групи](/en/user_manual/integrations/api/user-api#webhooks) надсилають вибрані події Loomio до вебкінцевої точки у форматі JSON. Використовуйте кінцеві точки REST для читання або зміни даних Loomio, а вебхук — коли інтеграція має отримувати події без періодичних запитів.

<!-- translation-section: server-api -->

## API сервера

[API сервера](/en/user_manual/integrations/api/server-api) дає змогу операторам установок Loomio на власних серверах керувати обліковими записами користувачів. Для автентифікації використовується секрет, спільний для всього сервера.
