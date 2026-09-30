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
  introduction: 23bff028511a2056
  user-api: 685b8949bb17311b
  server-api: e3481f170cbc29af
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Используйте API Loomio, чтобы связать Loomio с другими программами и автоматизированными процессами.

[Спецификация OpenAPI 3.1](openapi.yaml) описывает все общедоступные операции API пользователя и API сервера в машиночитаемом формате. Импортируйте её в клиент API или используйте для создания типизированного клиентского кода. В руководствах ниже описаны процессы, права доступа и особенности работы, которые спецификация не отражает полностью.

<!-- translation-section: user-api -->

## API пользователя

[API пользователя](/en/user_manual/integrations/api/user-api) позволяет выполнять действия от имени пользователя Loomio. Через него можно просматривать группы, создавать темы, комментарии и опросы, а также управлять ими и участием в группах в пределах прав этого пользователя.

Для интеграций с отправкой событий [вебхуки группы](/en/user_manual/integrations/api/user-api#webhooks) передают выбранные события Loomio на веб-адрес в формате JSON. Используйте конечные точки REST для чтения или изменения данных Loomio, а вебхук — когда интеграции нужно получать события без периодических запросов.

<!-- translation-section: server-api -->

## API сервера

[API сервера](/en/user_manual/integrations/api/server-api) позволяет операторам самостоятельно размещённых установок Loomio управлять учётными записями пользователей. Для аутентификации используется секретный ключ, общий для всего сервера.
