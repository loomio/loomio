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
  introduction: dfd0ce72ff66de2d
  user-api: b2e9d3dc3d89821d
  server-api: e9ebee9b7c57d927
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Используйте API Loomio для подключения Loomio к другим программам и автоматизированным рабочим процессам.

[Контракт OpenAPI 3.1](openapi.yaml) описывает все публичные операции пользовательского и серверного API в машиночитаемом формате. Импортируйте его в API-клиент или используйте для генерации типизированного клиентского кода. Руководства ниже объясняют рабочие процессы, права доступа и поведение, которые не полностью отражены в контракте.

<!-- translation-section: user-api -->

## Пользовательский API

[Пользовательский API](/en/user_manual/integrations/api/user-api) выполняет действия от имени пользователя Loomio. Он позволяет получать список групп, создавать ветки, комментарии и опросы, управлять ими и членством в группах в соответствии с правами этого пользователя.

Для интеграций с отправкой событий [вебхуки группы](/en/user_manual/integrations/api/user-api#webhooks) передают выбранные события Loomio на веб-адрес в формате JSON. Используйте конечные точки REST для чтения или изменения данных Loomio, а вебхук — когда интеграция должна получать события без периодических запросов.

<!-- translation-section: server-api -->

## Серверный API

[Серверный API](/en/user_manual/integrations/api/server-api) позволяет операторам Loomio, размещённого на собственных серверах, управлять учётными записями пользователей. Для аутентификации используется секрет, общий для всего сервера.
