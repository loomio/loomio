---
title: Пользовательский API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: 2b783ec54f27b2ce
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: a8b52c1a9bfdb16c
  create-a-webhook: 007312bcc204853a
  update-a-webhook: 124b07d2c401e319
  test-a-webhook-destination: 8fc3ac4ad10de6f6
  delete-a-webhook: 34eda1e07d65db80
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: bb5a1cfc7a6179aa
  params: 7eebe4e259830976
  participation-report: a1798112a78390fe
  params-2: 464322ffc1ac56e5
  example: 63bed6e82107f992
  create-discussion: ad202a0bdbfa7c2e
  params-3: 529f10e32be74c5c
  example-2: f25daafbba33718c
  show-discussion: b61aea6bf3d55e16
  example-3: e095e8e34cd562a0
  list-discussions: f209b8feb7c795a6
  params-4: 3ec197245f595be6
  example-4: 37d59c03fee8a15b
  list-threads: 34edc6c34552e136
  params-5: a5f41285afccdc8b
  example-5: 81c145ad5f6eb232
  read-thread: 0de1409aaa00b9ac
  example-6: 7c7553e1a3e94070
  edit-discussion: 1ab04653354b8036
  params-6: 4d3f5862a5f948b4
  example-7: d2a61a34af9e99c3
  soft-delete-discussion: fdb0d4db8470524c
  example-8: 423894a70b5ce489
  create-comment: bf95ee58b610f2fd
  params-7: 7af2127e1f721b66
  example-9: 4e7d49ac39938c12
  edit-comment: 49e722ec6bca25a1
  params-8: b2be783e4398d866
  example-10: bf626a7f693182c3
  soft-delete-comment: afb51bf4074aeab7
  example-11: e39b758ad0d7aa62
  create-poll: b2a11ae34ce22151
  params-9: 3e592c12f9cbb757
  example-12: f5d6029049637276
  show-poll: 2e7a14ac23eeffa6
  example-13: 1a5acf0b8a6f62f2
  list-polls: 606f27566d6d5f98
  params-10: 1b1a6f003f91eb9a
  example-14: 710a82f6b2203f48
  edit-poll: 42b85770aebd8ef2
  params-11: 52d278a2f38d6a9f
  example-15: 8f7d523fc36f5da7
  soft-delete-poll: 0f1b24e1263dcfbe
  example-16: ec71cfcd4a0b98ab
  list-memberships: 82712683aa3a424a
  params-12: d2fc821e97d53145
  example-17: 266443e0eb35078c
  manage-memberships: 3c821029101515ad
  params-13: 249b307203206387
  example-18: ffd950cd7ab5aaec
generated:
  introduction: aedf23b96d7f19b6
  authentication-change: 38dd5642ed8107aa
  response-size-and-related-records: 8e55b95de8c747c7
  endpoint-summary: 48e909bf77417e42
  groups: 6437a4d2d344fc84
  list-groups: 3e73b0f3f713893d
  get-a-group: 903fcd80859e2b86
  webhooks: be408175342153db
  list-webhooks: aaccfcfc570a3b27
  create-a-webhook: fccc6ab01c127312
  update-a-webhook: ae7faebed70e7c01
  test-a-webhook-destination: 8fc40e28d9ce8802
  delete-a-webhook: 5d9e52cd4b2068aa
  event-types: bd6f8dada7bcb42e
  http-delivery: 9f2bc6e024beb6df
  payload-formats: 77d9de47bc416007
  search: 59fb19af99d52bcf
  params: de325e549f5ac675
  participation-report: d50c7dfbd3f1e880
  params-2: 7abff89d64c071ca
  example: 1bdf016bc880eabd
  create-discussion: a3ff62737a8d34c1
  params-3: b349673db9be0e99
  example-2: 690f0279492858d8
  show-discussion: 28e1960245ffb6b3
  example-3: e58de587668b7ac8
  list-discussions: 3e3c5f581fa441f8
  params-4: 001f9a75ee6e7b16
  example-4: f3c49eeee2275538
  list-threads: f440cd558b8f0c8c
  params-5: b07e7573aa2b0daa
  example-5: a5e050d92e0e6900
  read-thread: cf604ed2b5af6245
  example-6: 6ba320f705196695
  edit-discussion: 15e8d7743592c00a
  params-6: 0465daffc0575e1e
  example-7: 82c83f4c98cfa810
  soft-delete-discussion: 8851f21427b18fee
  example-8: fe9f98a45420d2f8
  create-comment: 2b982fe587fb5ae2
  params-7: 77ba1fbb9c50fea6
  example-9: b4a36bed503fc5c2
  edit-comment: 17b7a8a76a9ca997
  params-8: 9a302e02b6c154d4
  example-10: 106d81c23b163f25
  soft-delete-comment: 4051732c85af1dc0
  example-11: a495b608032367a1
  create-poll: f736ff354f51d048
  params-9: f44fc4cb9be07f2a
  example-12: 1083cb7465e698cb
  show-poll: b6c3a4cce5cfca64
  example-13: bf93cd7731e57c13
  list-polls: 78dab704ce4002e5
  params-10: '0879c17214bcb80c'
  example-14: c2d3e68d114dd69d
  edit-poll: 4687e29cec78fa57
  params-11: f8d6e3db4c995c03
  example-15: 48a42a0c2822f86c
  soft-delete-poll: 460ab89f6b1e5140
  example-16: cdd15966b047896c
  list-memberships: 0ac833f3ea110169
  params-12: a9673779f8af1501
  example-17: 5312d47c9b01ea9f
  manage-memberships: d41c6cd06228277d
  params-13: 3bcff61ed8a597bc
  example-18: 3b5ff61e909a1045
title_source: c23fb6526b722360
title_generated: 8b52d9996be5c890
---

<!-- translation-section: introduction -->

# Документация пользовательского API Loomio

<!-- seo-description: Пользовательский API Loomio позволяет создавать обсуждения, комментарии, голосования и темы, а также управлять участием в группах из других приложений. -->

`/api/b2` — пользовательский API для интеграций с Loomio. Он использует API-ключ учётной записи, и каждое действие выполняется от имени этого пользователя.

При работе с группами действуют права и членство пользователя, которому принадлежит API-ключ. Статус администратора экземпляра не расширяет доступ API-ключа к группам и их содержимому. Для управления экземпляром используйте серверный API.

Используйте API-ключ учётной записи Loomio, от имени которой будут выполняться действия. Отдельная учётная запись бота удобна, если интеграция не должна получать приглашения к голосованиям и уведомления.

Пользователи, вошедшие в систему, могут найти свой API-ключ и идентификаторы групп на [странице доступа к API](/profile/api_access).

Передавайте API-ключ в заголовке `Authorization: Bearer`. API-ключи в строке запроса отклоняются, поскольку URL могут сохраняться в журналах прокси-серверов и доступа.

<!-- translation-section: authentication-change -->

### Изменение способа аутентификации

Раньше API-ключ можно было передать в параметре URL `api_key`. Запросы с `?api_key=YOUR_API_KEY` больше не работают. Используйте заголовок HTTP `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

В примерах используются `YOUR_API_KEY`, идентификатор группы `123` и `https://www.loomio.com/`. Замените их своим API-ключом, идентификатором группы и URL вашей установки Loomio.

<!-- translation-section: response-size-and-related-records -->

## Размер ответа и связанные записи

Ответы пользовательского API имеют составной формат: вместе с основными записями возвращаются связанные записи, например темы, группы, пользователи, голосования и реакции. Это позволяет клиенту заполнить локальное хранилище записей одним запросом, но объём данных может быть больше, чем требуется простой интеграции.

Передайте `compact=1`, чтобы исключить объёмные связанные записи о темах, группах, родительских группах, участии в группах, реакциях, тегах и переводах. Основные записи и связанные записи, необходимые для понимания их содержимого, останутся в ответе.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Для точного выбора исключений передайте в `exclude_types` типы записей в единственном числе, разделённые пробелами. Например, `exclude_types=group reaction` исключает связанные группы и реакции. Распространённые значения: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` и `topic_item`. Исключения относятся к связанным записям, а не к основному ресурсу, запрошенному через конечную точку.

Ответы с коллекциями содержат `meta.total`, когда определён точный размер коллекции. Общее число рассчитывается до применения `limit` и `offset`. Конечные точки, которые намеренно возвращают ограниченный набор результатов, например поиск, не включают `meta.total` вместо значения `null`.

<!-- translation-section: endpoint-summary -->

## Обзор конечных точек

| Метод | Конечная точка | Назначение |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Получить список групп пользователя, которому принадлежит API-ключ |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Получить доступную группу |
| `GET` | `/api/b2/reports` | Сформировать отчёт об участии |
| `GET` | `/api/b2/search` | Найти доступные обсуждения, комментарии, голосования, голоса и заключения |
| `POST` | `/api/b2/discussions` | Создать обсуждение |
| `GET` | `/api/b2/discussions/:id` | Получить обсуждение |
| `GET` | `/api/b2/discussions` | Получить список обсуждений в группе |
| `PATCH` | `/api/b2/discussions/:id` | Изменить обсуждение |
| `DELETE` | `/api/b2/discussions/:id` | Пометить обсуждение как удалённое |
| `GET` | `/api/b2/threads` | Получить список доступных тем обсуждений и отдельных голосований |
| `GET` | `/api/b2/threads/:topic_id` | Получить тему |
| `GET` | `/api/b2/threads/:topic_id/items` | Получить элементы темы по порядку |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Получить всю тему в формате Markdown |
| `POST` | `/api/b2/comments` | Создать комментарий или ответ |
| `PATCH` | `/api/b2/comments/:id` | Изменить комментарий |
| `DELETE` | `/api/b2/comments/:id` | Пометить комментарий как удалённый |
| `POST` | `/api/b2/polls` | Создать голосование |
| `GET` | `/api/b2/polls/:id` | Получить голосование |
| `GET` | `/api/b2/polls` | Получить список голосований в группе |
| `PATCH` | `/api/b2/polls/:id` | Изменить голосование |
| `DELETE` | `/api/b2/polls/:id` | Пометить голосование как удалённое |
| `GET` | `/api/b2/memberships` | Получить список участников группы |
| `POST` | `/api/b2/memberships` | Добавить участников и при необходимости удалить тех, кого нет в списке |
| `GET` | `/api/b2/chatbots` | Получить список интеграций чата и вебхуков группы |
| `POST` | `/api/b2/chatbots` | Создать интеграцию чата или вебхук |
| `PATCH` | `/api/b2/chatbots/:id` | Обновить интеграцию чата или вебхук |
| `DELETE` | `/api/b2/chatbots/:id` | Удалить интеграцию чата или вебхук |
| `POST` | `/api/b2/chatbots/check` | Отправить тестовое сообщение для проверки соединения с вебхуком |

<!-- translation-section: groups -->

## Группы

<!-- translation-section: list-groups -->

### Список групп

Возвращает группы, в которых пользователь, которому принадлежит API-ключ, является действующим участником.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Ответ содержит все подходящие записи в массиве `groups` без разбивки на страницы. В него входят родительские группы и подгруппы, в том числе группы, чья подписка сейчас неактивна. Если интеграция должна работать только с активными группами, проверяйте поле `enabled`.

Важные поля группы:

| Поле | Описание |
| --- | --- |
| `id` | Числовой идентификатор группы, используемый другими конечными точками пользовательского API |
| `key` | Постоянный короткий ключ, используемый в URL Loomio |
| `handle` | Читаемый идентификатор группы |
| `name` | Название группы |
| `full_name` | Название группы с указанием родительской группы |
| `parent_id` | Числовой идентификатор родительской группы для подгруппы, иначе `null` |
| `enabled` | Активны ли группа и её подписка |
| `memberships_count` | Число действующих участников и ожидающих вступления |
| `accepted_memberships_count` | Число подтверждённых участников |
| `pending_memberships_count` | Число приглашений, ожидающих ответа |
| `admin_memberships_count` | Число администраторов группы |
| `delegates_count` | Число делегатов |
| `discussions_count` | Число обсуждений непосредственно в группе |
| `polls_count` | Число голосований непосредственно в группе |
| `subgroups_count` | Число подгрупп |

Ответ также может содержать дополнительные настройки группы, связанные записи родительской группы и сведения об участии пользователя API в группах. Клиентам следует игнорировать поля, которые они не используют.

<!-- translation-section: get-a-group -->

### Получение группы

Возвращает одну группу, доступную пользователю, которому принадлежит API-ключ.

`GET /api/b2/groups/:id_or_key_or_handle`

В качестве идентификатора можно указать числовой ID, ключ или читаемый идентификатор группы.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Ответ содержит группу в массиве `groups` с теми же полями, что и конечная точка для получения списка. Если у пользователя, которому принадлежит API-ключ, нет доступа к группе, запрос вернёт ошибку доступа.

<!-- translation-section: webhooks -->

## Вебхуки

Пользовательский API работает по запросу: интеграция обращается к Loomio, когда ей нужно прочитать или изменить данные. Вебхук группы работает в обратном направлении. Loomio отправляет выбранные события группы на вашу конечную точку по мере их возникновения, поэтому интеграции не нужно регулярно опрашивать REST API.

Вебхуки настраиваются отдельно для каждой группы. Для этого нужны права администратора группы. Управлять ими можно через интерфейс Loomio:

1. Откройте группу.
2. Откройте меню группы и выберите **Интеграция чата**.
3. Добавьте интеграцию с форматом данных, который принимает ваша конечная точка. Для конечной точки общего назначения используйте формат Mattermost/Markdown.
4. Введите название и URL назначения.
5. Выберите события, которые Loomio должна отправлять автоматически.
6. Сохраните интеграцию и нажмите **Тестовое соединение**, чтобы отправить тестовое сообщение.

Используйте HTTPS-адрес назначения с URL, который трудно угадать. Loomio требует, чтобы адрес назначения был публичным, и блокирует запросы к локальным или частным сетевым адресам.

Агенты и другие интеграции также могут управлять вебхуками через описанные ниже эндпоинты чат-интеграций с авторизацией Bearer. Ресурс называется `chatbots` для совместимости с чат-интеграциями Loomio, но также используется для обычных исходящих вебхуков.

<!-- translation-section: list-webhooks -->

### Список вебхуков

Возвращает интеграции чата, настроенные для группы. Пользователь, которому принадлежит API-ключ, должен быть администратором этой группы. Ответ содержит URL назначения, поэтому его нельзя показывать обычным участникам группы.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Ответ содержит массив `chatbots` со следующими полями:

| Поле | Описание |
| --- | --- |
| `id` | ID интеграции для обновления и удаления |
| `group_id` | Группа, в которой происходят события |
| `name` | Название интеграции для администраторов |
| `kind` | `webhook` для исходящего вебхука или `matrix` для интеграции с Matrix |
| `webhook_kind` | Формат данных: `markdown`, `slack`, `discord`, `microsoft` или `webex` |
| `server` | URL назначения |
| `event_kinds` | События, отправляемые автоматически |
| `notification_only` | Содержат ли сообщения только заголовок уведомления |

<!-- translation-section: create-a-webhook -->

### Создать вебхук

`POST /api/b2/chatbots`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": ["new_discussion", "new_comment", "poll_created", "outcome_created"],
    "notification_only": false
  }' \
  https://www.loomio.com/api/b2/chatbots
```

Владелец ключа API должен быть администратором группы `group_id`. Перед сохранением проверяется, что URL назначения общедоступен.

<!-- translation-section: update-a-webhook -->

### Обновить вебхук

`PATCH /api/b2/chatbots/:id`

Передайте поля, которые нужно изменить. Изменение `group_id` не позволяет перенести вебхук в другую группу.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Проверить адрес назначения вебхука

Отправьте тестовое сообщение в формате Markdown на адрес назначения до или после сохранения настроек.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Удалить вебхук

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

После удаления настроек новые сообщения доставляться не будут. Содержимое группы Loomio сохранится.

<!-- translation-section: event-types -->

### Типы событий

Вебхук может получать события следующих типов:

| Событие | Когда отправляется |
| --- | --- |
| `new_discussion` | Начато обсуждение |
| `discussion_edited` | Обсуждение изменено |
| `new_comment` | Создан комментарий |
| `poll_created` | Начат опрос |
| `poll_edited` | Опрос изменён |
| `poll_closing_soon` | Скоро закончится срок голосования |
| `poll_expired` | Закончился срок голосования |
| `poll_closed_by_user` | Пользователь закрыл опрос вручную |
| `poll_reopened` | Опрос открыт повторно |
| `outcome_created` | Опубликовано заключение |
| `outcome_updated` | Заключение обновлено |
| `outcome_review_due` | Наступил срок пересмотра заключения |
| `stance_created` | Подан голос |
| `stance_updated` | Голос изменён |

Вебхук относится к одной группе и получает выбранные события из неё. Пользователи также могут выбрать интеграцию при публикации или отправке некоторых уведомлений, даже если соответствующее автоматическое событие не выбрано.

<!-- translation-section: http-delivery -->

### Доставка по HTTP

Loomio отправляет асинхронный HTTP-запрос `POST` на настроенный URL со следующим заголовком:

```text
Content-Type: application/json; charset=utf-8
```

Время ожидания ответа — пять секунд. Ответ `2xx`, включая `204 No Content`, считается успешным. Получателям вебхуков следует быстро отвечать на запросы, выполнять длительные задачи асинхронно и учитывать возможность повторной доставки или доставки не по порядку.

Сейчас Loomio не добавляет подпись вебхука, заголовок с общим секретом, ID события или ID доставки. Считайте полный URL назначения секретом и не публикуйте его. Если принимающий сервис поддерживает такую возможность, добавьте в URL токен, который невозможно угадать. Если вам нужна стабильная машиночитаемая схема событий или доставка с подписью, используйте вебхук как уведомление об изменении, а актуальные записи получайте через Пользовательский API с аутентификацией.

<!-- translation-section: payload-formats -->

### Форматы данных

Данные вебхуков предназначены для отображения сообщений в чат-сервисах. Они не содержат полные записи Loomio. Ссылки в сообщении указывают на соответствующее содержимое Loomio. Если интеграции нужны структурированные актуальные данные, она может запросить их через Пользовательский API.

| Формат интеграции | Основные поля JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, не более примерно 1 900 символов |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Например, сообщение в общем формате Markdown имеет следующую структуру:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Точный текст сообщения зависит от события, языка группы, настройки отправки только заголовка уведомления и версии Loomio. Используйте документированные поля верхнего уровня выбранного формата. Не разбирайте текст сообщения по словам.

<!-- translation-section: search -->

## Поиск

Ищите обсуждения, комментарии, опросы, голоса и заключения, доступные владельцу ключа API. В результаты входит общедоступное содержимое, даже если пользователь не состоит в группе. Доступ к закрытому содержимому определяется обычными правилами видимости темы.

`GET /api/b2/search`

<!-- translation-section: params -->

### Параметры

| Название | Описание |
| --- | --- |
| `query` | Поисковый текст. Поддерживаются точные и приблизительные совпадения |
| `group_id` | Ограничить результаты одной доступной группой |
| `org_id` | Ограничить результаты доступной родительской группой и её доступными подгруппами. Для прямых обсуждений используйте `0` |
| `type` | Ограничить результаты одним типом: `Discussion`, `Comment`, `Poll`, `Stance` или `Outcome` |
| `types` | Список типов результатов через запятую |
| `tag` | Ограничить результаты темами с этим тегом |
| `author_id` | Ограничить результаты содержимым одного автора. Без `query` возвращается его недавняя доступная активность |
| `order` | Укажите `authored_at_desc`, чтобы упорядочить совпадения по времени публикации |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Ответ содержит массив `search_results`. Каждая запись указывает найденный объект и его доступный контекст. Среди полей — `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` и `tags`. Поля, которые не относятся к результату, имеют значение `null`.

<!-- translation-section: participation-report -->

## Отчёт об участии

Возвращает те же сводные данные об активности, что и отчёт Loomio об участии.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Параметры

| Название | Описание |
| --- | --- |
| `section` | Раздел отчёта: `base`, `users` или `countries`. Для активности отдельных пользователей укажите `users` |
| `group_scope` | `custom` или `my`. Устаревшее значение `all` обрабатывается как `my`, поскольку ключи Пользовательского API не дают доступ ко всему экземпляру Loomio |
| `group_ids` | ID групп через запятую при `group_scope=custom`. ID групп, в которых владелец ключа API не состоит, игнорируются |
| `start_month` | Первый месяц периода в формате `YYYY-MM`. По умолчанию — месяц 12 месяцев назад |
| `end_month` | Последний месяц периода в формате `YYYY-MM`. По умолчанию — текущий месяц |
| `interval` | Интервал для раздела `base`: `day`, `week`, `month` или `year` |
| `member_type` | Укажите `delegate` вместе с `section=users`, чтобы получить данные только действующих делегатов |

Пользователь считается делегатом, если он является действующим делегатом хотя бы в одной выбранной группе. Его показатели суммируются по всем выбранным группам. Данные делегата возвращаются, даже если все показатели активности равны нулю. Они охватывают темы, комментарии, опросы, голоса, заключения и реакции; это не показатели участия в голосовании. Данные пользователей также содержат число назначенных, поданных и пропущенных бюллетеней в открытых голосованиях. Анонимные опросы исключаются из всех показателей голосования отдельных пользователей. Значение `all_votes_cast` равно true, только если был назначен хотя бы один бюллетень и все назначенные бюллетени были поданы.

API применяет те же правила видимости групп, что и отчёт в Loomio. Ключ Пользовательского API не позволяет получить данные отчёта по группам, к которым у его владельца нет доступа.

<!-- translation-section: example -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Массив `users` содержит полные записи об активности:

```json
{
  "users": [
    {
      "id": 456,
      "name": "Ada Lovelace",
      "country": "NZ",
      "delegate": true,
      "threads": 2,
      "comments": 8,
      "polls": 1,
      "votes": 5,
      "votes_cast": 5,
      "votes_issued": 6,
      "votes_missed": 1,
      "all_votes_cast": false,
      "outcomes": 1,
      "reactions": 4
    }
  ]
}
```

<!-- translation-section: create-discussion -->

## Создать обсуждение

Создайте обсуждение от имени пользователя, которому принадлежит ключ API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `group_id` | Группа, в которой будет создана тема |
| `title` | Название темы, обязательное поле |
| `description` | Описание темы, необязательное поле |
| `description_format` | `md` или `html`, необязательное поле, по умолчанию `md` |
| `recipient_audience` | `group` или null. Если указано `group`, вся группа получит уведомление о новой теме |
| `recipient_user_ids` | Массив идентификаторов пользователей, которых нужно уведомить или пригласить в тему |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить в тему |
| `recipient_message` | Сообщение для приглашения по электронной почте |

<!-- translation-section: example-2 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Получить обсуждение

Получите обсуждение по числовому идентификатору или строковому ключу.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Получить список обсуждений

Получите список обсуждений группы, доступных пользователю, которому принадлежит ключ API. Если группа общедоступна, человек, не состоящий в ней, может получить список её общедоступных обсуждений. Закрытые обсуждения доступны только тем, кто может читать их в Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `group_id` | Целое число, обязательное поле. Идентификатор группы, обсуждения которой нужно получить |
| `status` | Строка, необязательное поле, по умолчанию `open`. Значения: `open`, `closed`, `all` |
| `limit` | Целое число, необязательное поле, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательное поле, по умолчанию 0. Смещение для постраничного вывода |

Для совместимости по-прежнему можно использовать `per` и `from` вместо `limit` и `offset`.

<!-- translation-section: example-4 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Получить список тем

Получите список тем обсуждений и голосований, доступных пользователю, которому принадлежит ключ API. Темы упорядочены по времени последней активности. Идентификатор темы — её `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `limit` | Целое число, необязательное поле, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательное поле, по умолчанию 0. Смещение для постраничного вывода |

<!-- translation-section: example-5 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Прочитать тему

Получите тему, упорядоченный список её событий или полный доступный вам документ в формате Markdown.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Пример

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Конечная точка `items` возвращает упорядоченный список событий, включая доступные комментарии, голосования, голоса и итоги. Конечная точка `markdown` возвращает всю доступную тему одним документом в формате Markdown. Причины голосования включаются, только если они доступны пользователю, которому принадлежит ключ API.

Для всех конечных точек тем действуют те же права доступа, что и в интерфейсе Loomio. Ключ API не даёт доступ к теме, которую пользователь обычно не может открыть.

<!-- translation-section: edit-discussion -->

## Редактировать обсуждение

Редактируйте обсуждение от имени пользователя, которому принадлежит ключ API. Действуют те же права доступа, что и в Loomio: пользователь должен иметь право редактировать это обсуждение.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `title` | Новое название |
| `description` | Новое описание |
| `description_format` | `md` или `html`, необязательное поле, по умолчанию `md` |
| `recipient_audience` | `group` или null. Если указано `group`, вся группа получит уведомление об изменении |
| `recipient_user_ids` | Массив идентификаторов пользователей, которых нужно уведомить или пригласить в тему |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить в тему |
| `recipient_message` | Сообщение для приглашения по электронной почте |

<!-- translation-section: example-7 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Удалить обсуждение без удаления записи

Удалите обсуждение от имени пользователя, которому принадлежит ключ API. Обсуждение будет помечено как удалённое, но его запись сохранится.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Создать комментарий

Создайте комментарий в обсуждении от имени пользователя, которому принадлежит ключ API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `discussion_id` | Целое число, обязательное поле. Идентификатор обсуждения, в котором нужно оставить комментарий |
| `body` | Текст комментария, обязателен, если не добавлено вложение |
| `body_format` | `md` или `html`, необязательное поле, по умолчанию `md` |

<!-- translation-section: example-9 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Редактировать комментарий

Редактируйте комментарий от имени пользователя, которому принадлежит ключ API. Действуют те же права доступа, что и в Loomio: пользователь должен иметь право редактировать этот комментарий.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `body` | Новый текст комментария |
| `body_format` | `md` или `html`, необязательное поле, по умолчанию `md` |

<!-- translation-section: example-10 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Удалить комментарий без удаления записи

Удалите комментарий от имени пользователя, которому принадлежит ключ API. Комментарий будет помечен как удалённый, его текст скрыт, а запись сохранится.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Создать голосование

Создайте голосование от имени пользователя, которому принадлежит ключ API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, необязательно, по умолчанию null. ID группы, в которой будет создано голосование. Если передан `discussion_id`, значение `group_id` игнорируется |
| `discussion_id` | Целое число, необязательно, по умолчанию null. ID обсуждения, в которое нужно добавить голосование |
| `title` | Строка, обязательно. Название голосования |
| `poll_type` | Строка, обязательно. Значения: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Строка, необязательно. Текст голосования |
| `details_format` | Строка, необязательно, по умолчанию `md`. Значения: `md` или `html` |
| `options` | Массив строк. Если `poll_type` — `proposal`, допустимые значения: `agree`, `disagree`, `abstain`, `block`. Если `poll_type` — `meeting`, укажите даты или дату и время в формате ISO 8601. Для остальных типов голосования подходит любая строка |
| `closing_at` | Строка в формате ISO 8601 или null, по умолчанию null. Пример: `2026-09-01T12:00:00Z`. Если значение равно null, голосовать нельзя, а голосование считается черновиком |
| `specified_voters_only` | Логическое значение, необязательно, по умолчанию false. Если true, голосовать могут только указанные люди. Если false, приглашение проголосовать получат все участники группы |
| `hide_results` | Строка, необязательно, по умолчанию `off`. Значения: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Логическое значение, по умолчанию false. Показывать варианты голосующим в случайном порядке |
| `anonymous` | Логическое значение, необязательно, по умолчанию false. Скрывать личности голосующих |
| `recipient_audience` | `group` или null, необязательно, по умолчанию null. Если `group`, уведомление получит вся группа |
| `notify_on_closing_soon` | Строка, необязательно, по умолчанию `nobody`. Значения: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Массив ID пользователей, которых нужно уведомить или пригласить |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить проголосовать |
| `recipient_message` | Сообщение для приглашения по электронной почте |
| `notify_recipients` | Логическое значение, по умолчанию false. Если false, люди будут добавлены без уведомлений. Если true, все приглашённые в этом запросе получат уведомление по электронной почте |

<!-- translation-section: example-12 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Получить голосование

Получите голосование по числовому ID или строковому ключу.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Список голосований

Получите список голосований группы, доступных пользователю, которому принадлежит ключ API. В публичной группе человек без членства может получить список публичных голосований. Закрытые голосования доступны только тем, кто может просматривать их в Loomio. Ответ содержит текущее заключение по каждому доступному голосованию, поэтому с помощью `status=closed` можно получить список предложений, по которым принято решение.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательно. ID группы, голосования которой нужно перечислить |
| `status` | Строка, необязательно, по умолчанию `active`. Значения: `active`, `closed`, `all` |
| `limit` | Целое число, необязательно, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательно, по умолчанию 0. Смещение для постраничного вывода |

Для совместимости по-прежнему можно использовать `per` и `from` вместо `limit` и `offset`.

<!-- translation-section: example-14 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Изменить голосование

Измените голосование от имени пользователя, которому принадлежит ключ API. Действуют те же права доступа, что и в Loomio: пользователь должен иметь право изменять это голосование.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Параметры

| Название | Описание |
| --- | --- |
| `title` | Новое название |
| `details` | Новый текст голосования |
| `details_format` | `md` или `html`, необязательно, по умолчанию `md` |
| `options` | Новые названия вариантов. В зависимости от состояния голосования изменение вариантов может повлиять на уже поданные голоса |
| `closing_at` | Строка в формате ISO 8601 или null |
| `recipient_audience` | `group` или null. Если `group`, уведомление получит вся группа |
| `recipient_user_ids` | Массив ID пользователей, которых нужно уведомить или пригласить |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить проголосовать |
| `recipient_message` | Сообщение для приглашения по электронной почте |

<!-- translation-section: example-15 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Скрыть голосование

Скройте голосование от имени пользователя, которому принадлежит ключ API. Голосование будет помечено как удалённое, но его запись сохранится.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Список участников групп

Получите список участников групп, доступный пользователю, которому принадлежит ключ API. Участники группы могут видеть имена, ID, должности и роли других участников. Адрес электронной почты доступен только для собственной учётной записи пользователя или администратору группы.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательно. ID группы, участников которой нужно перечислить |

<!-- translation-section: example-17 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Управление участниками группы

Отправьте список адресов электронной почты. Владельцы новых адресов получат приглашение в группу. В отличие от просмотра списка участников, для этой операции нужны права администратора группы.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательно. ID группы, составом которой нужно управлять |
| `emails` | Массив строк, обязательно. Адреса электронной почты людей, которых нужно пригласить в группу |
| `remove_absent` | Логическое значение. Если true, из группы будут удалены все, чьих адресов электронной почты нет в списке |

<!-- translation-section: example-18 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Если передать `remove_absent=1`, из группы будут удалены все участники, не включённые в список. Так можно случайно удалить из вашей группы всех участников.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Ответ содержит объект `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
