---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: be668c189bb7d263
  user-api: 74f04ef3223a6769
  server-api: 8f22b7811aaac10d
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Використовуйте API Loomio, щоб підключати Loomio до іншого програмного забезпечення та автоматизованих робочих процесів.

[Специфікація OpenAPI 3.1](openapi.yaml) описує всі публічні операції API користувача й API сервера у форматі, придатному для машинного читання. Імпортуйте її в клієнт API або використовуйте для створення клієнтського коду з типами. Наведені нижче посібники пояснюють робочі процеси, дозволи та поведінку, які специфікація описує не повністю.

<!-- translation-section: user-api -->

## API користувача

[API користувача](/en/user_manual/integrations/api/user-api) виконує дії від імені користувача Loomio. Через нього можна переглядати групи, створювати теми, коментарі й опитування та керувати ними й участю в групах відповідно до дозволів користувача.

Для інтеграцій, які отримують події автоматично, [вебхуки групи](/en/user_manual/integrations/api/user-api#webhooks) надсилають вибрані події Loomio на вебадресу у форматі JSON. Використовуйте кінцеві точки REST, щоб читати або змінювати дані Loomio, а вебхук — щоб інтеграція отримувала події без періодичних запитів.

<!-- translation-section: server-api -->

## API сервера

[API сервера](/en/user_manual/integrations/api/server-api) дає операторам самостійно розгорнутих інсталяцій Loomio змогу керувати обліковими записами користувачів. Для автентифікації використовується спільний для сервера секретний ключ.
