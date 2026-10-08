---
title: Пользовательский API
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
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
  introduction: b1c162d85c4f9441
  authentication-change: 8000228cfdf51317
  response-size-and-related-records: d46f276f260c7a9f
  endpoint-summary: ca1964ceb4794a50
  groups: 6437a4d2d344fc84
  list-groups: b95b458461d1c440
  get-a-group: 01132bb83e4197e9
  webhooks: 1097a8dab740d326
  list-webhooks: 3705b6c619d32584
  create-a-webhook: 762b2fa08ef41e73
  update-a-webhook: f675559efaf7e9f9
  test-a-webhook-destination: 9ebc6a7163c25a76
  delete-a-webhook: 35e008d5ddc4da99
  event-types: c42bdcd09375770c
  http-delivery: d94b54f18f7a1d4d
  payload-formats: 69e924e41c88a86c
  search: b8d33a716dc1abd2
  params: a6fa6ece346d25fe
  participation-report: 9a40f68886cab19c
  params-2: cf57ccfadfc50d2e
  example: 39aa413c0b611f48
  create-discussion: 230b4ee81d25b8c3
  params-3: 398ea223c33419ea
  example-2: 690f0279492858d8
  show-discussion: dc6daef4349e794d
  example-3: e58de587668b7ac8
  list-discussions: 520f24b4481b1b60
  params-4: 7ceae46c574bbc50
  example-4: f3c49eeee2275538
  list-threads: 17f5180242e59d3d
  params-5: e0e518aaa8836ce2
  example-5: a5e050d92e0e6900
  read-thread: cdb410811430eebe
  example-6: 63f979890e1e285a
  edit-discussion: 7511e3d8c151451e
  params-6: 5588dc0aae1e1ede
  example-7: 82c83f4c98cfa810
  soft-delete-discussion: 2ab67242616777cc
  example-8: fe9f98a45420d2f8
  create-comment: 8baa56606da8ab7b
  params-7: 44ccc84b9878ff08
  example-9: b4a36bed503fc5c2
  edit-comment: 185ace65818cec07
  params-8: 264cfdcb20ae291a
  example-10: 106d81c23b163f25
  soft-delete-comment: 6d43b0405d422d02
  example-11: a495b608032367a1
  create-poll: a422459779a3de00
  params-9: 6d08948f569846d2
  example-12: 1083cb7465e698cb
  show-poll: 26f16e7d942a8c96
  example-13: bf93cd7731e57c13
  list-polls: 56dbd59e87a437ba
  params-10: a20ad3469485b852
  example-14: c2d3e68d114dd69d
  edit-poll: 43479e8c268a257d
  params-11: 6aca1dd84627559b
  example-15: 48a42a0c2822f86c
  soft-delete-poll: 63f7efc072349e4a
  example-16: cdd15966b047896c
  list-memberships: bf11b4e0e3dbd943
  params-12: 522bb7fe545abfd2
  example-17: 5312d47c9b01ea9f
  manage-memberships: c4b373810e4ba035
  params-13: dda04742cdadea57
  example-18: 23eeecd3f05bd8b7
title_source: c23fb6526b722360
title_generated: 8b52d9996be5c890
---

<!-- translation-section: introduction -->

# Документация пользовательского API Loomio

<!-- seo-description: Используйте пользовательский API Loomio для создания обсуждений, комментариев, опросов и веток, а также управления ими и участием в группах из других программ. -->

`/api/b2` — пользовательский API для интеграций с Loomio. Он использует API-ключ учётной записи пользователя, и каждое действие выполняется от имени этого пользователя.

Операции с группами учитывают участие в группах и права в них пользователя, которому принадлежит API-ключ. Статус администратора экземпляра Loomio не расширяет доступ API-ключа к группам или содержимому; для администрирования на уровне экземпляра используйте серверный API.

Используйте API-ключ учётной записи Loomio, от имени которой будут выполняться действия. Отдельная учётная запись бота полезна, если интеграция не должна получать приглашения в опросы или уведомления.

Пользователи, вошедшие в систему, могут найти свой API-ключ и идентификаторы групп на [странице доступа к API](/profile/api_access).

Передавайте API-ключ в заголовке `Authorization: Bearer`. API-ключи в строках запроса отклоняются, поскольку URL могут записываться прокси-серверами и журналами доступа.

<!-- translation-section: authentication-change -->

### Изменение аутентификации

Раньше API-ключ принимался как параметр URL `api_key`. Запросы с `?api_key=YOUR_API_KEY` больше не работают. Вместо этого используйте HTTP-заголовок `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

В примерах используются `YOUR_API_KEY`, идентификатор группы `123` и `https://www.loomio.com/`. Замените их своим API-ключом, идентификатором группы и URL вашей установки Loomio.

<!-- translation-section: response-size-and-related-records -->

## Размер ответа и связанные записи

Ответы пользовательского API имеют составной формат: вместе с основными записями возвращаются связанные записи, например темы, группы, пользователи, опросы и реакции. Это позволяет клиенту заполнить локальное хранилище записей одним запросом, но ответ может содержать больше данных, чем нужно простой интеграции.

Передайте `compact=1`, чтобы исключить объёмные связанные записи тем, групп, родительских групп, участия в группах, реакций, тегов и переводов. Основные записи и связанные записи, необходимые для интерпретации их содержимого, остаются в ответе.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Для прямого управления передайте `exclude_types` с типами записей в единственном числе, разделёнными пробелами. Например, `exclude_types=group reaction` исключает связанные группы и реакции. Часто используемые значения: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` и `topic_item`. Исключения применяются к связанным записям, а не к основному ресурсу, запрошенному через конечную точку.

Ответы со списками включают `meta.total`, если для списка определён точный размер. Общее количество рассчитывается до применения `limit` и `offset`. Конечные точки, такие как поиск, которые намеренно возвращают ограниченный набор результатов, не включают `meta.total`, а не возвращают `null`.

<!-- translation-section: endpoint-summary -->

## Обзор конечных точек

| Метод | Конечная точка | Назначение |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Получить список групп пользователя, которому принадлежит API-ключ |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Получить доступную группу |
| `GET` | `/api/b2/reports` | Сформировать отчёт об участии |
| `GET` | `/api/b2/search` | Найти доступные обсуждения, комментарии, опросы, голоса и выводы |
| `POST` | `/api/b2/discussions` | Создать обсуждение |
| `GET` | `/api/b2/discussions/:id` | Получить обсуждение |
| `GET` | `/api/b2/discussions` | Получить список обсуждений в группе |
| `PATCH` | `/api/b2/discussions/:id` | Изменить обсуждение |
| `DELETE` | `/api/b2/discussions/:id` | Удалить обсуждение с сохранением записи |
| `GET` | `/api/b2/threads` | Получить список доступных веток обсуждений и отдельных опросов |
| `GET` | `/api/b2/threads/:topic_id` | Получить ветку |
| `GET` | `/api/b2/threads/:topic_id/items` | Получить упорядоченные элементы ветки |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Получить полную ветку в формате Markdown |
| `POST` | `/api/b2/comments` | Создать комментарий или ответ |
| `PATCH` | `/api/b2/comments/:id` | Изменить комментарий |
| `DELETE` | `/api/b2/comments/:id` | Удалить комментарий с сохранением записи |
| `POST` | `/api/b2/polls` | Создать опрос |
| `GET` | `/api/b2/polls/:id` | Получить опрос |
| `GET` | `/api/b2/polls` | Получить список опросов в группе |
| `PATCH` | `/api/b2/polls/:id` | Изменить опрос |
| `DELETE` | `/api/b2/polls/:id` | Удалить опрос с сохранением записи |
| `GET` | `/api/b2/memberships` | Получить список записей об участии в группе |
| `POST` | `/api/b2/memberships` | Добавить участников и при необходимости удалить участников, отсутствующих в списке |
| `GET` | `/api/b2/chatbots` | Получить список интеграций чата и вебхуков группы |
| `POST` | `/api/b2/chatbots` | Создать интеграцию чата или вебхук |
| `PATCH` | `/api/b2/chatbots/:id` | Обновить интеграцию чата или вебхук |
| `DELETE` | `/api/b2/chatbots/:id` | Удалить интеграцию чата или вебхук |
| `POST` | `/api/b2/chatbots/check` | Отправить тестовое сообщение для проверки соединения с вебхуком |

<!-- translation-section: groups -->

## Группы

<!-- translation-section: list-groups -->

### Список групп

Возвращает группы, в которых пользователь, которому принадлежит API-ключ, является активным участником.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Ответ содержит все подходящие записи в массиве `groups` без разбиения на страницы. В него входят родительские группы и подгруппы, в том числе группы, подписка которых сейчас неактивна. Проверяйте поле `enabled`, если интеграция должна работать только с активными группами.

Основные поля группы:

| Поле | Описание |
| --- | --- |
| `id` | Числовой идентификатор группы, используемый другими конечными точками пользовательского API |
| `key` | Постоянный короткий ключ, используемый в URL Loomio |
| `handle` | Человекочитаемый идентификатор группы |
| `name` | Название группы |
| `full_name` | Название группы с указанием родительской группы |
| `parent_id` | Числовой идентификатор родительской группы для подгруппы, в остальных случаях `null` |
| `enabled` | Активны ли группа и её подписка |
| `memberships_count` | Количество активных и ожидающих подтверждения записей об участии |
| `accepted_memberships_count` | Количество подтверждённых записей об участии |
| `pending_memberships_count` | Количество приглашений, ожидающих принятия |
| `admin_memberships_count` | Количество администраторов группы |
| `discussions_count` | Количество обсуждений непосредственно в группе |
| `polls_count` | Количество опросов непосредственно в группе |
| `subgroups_count` | Количество подгрупп |

Ответ может включать дополнительные настройки группы, связанные записи родительских групп и записи об участии пользователя API в группах. Клиентам следует игнорировать поля, которые они не используют.

<!-- translation-section: get-a-group -->

### Получение группы

Возвращает одну группу, доступную пользователю, которому принадлежит API-ключ.

`GET /api/b2/groups/:id_or_key_or_handle`

В качестве идентификатора можно использовать числовой идентификатор, ключ или человекочитаемый идентификатор группы.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Ответ содержит группу в массиве `groups` и использует те же поля, что и конечная точка списка групп. Запрос группы, к которой у пользователя с API-ключом нет доступа, возвращает ошибку прав доступа.

<!-- translation-section: webhooks -->

## Вебхуки

Пользовательский API работает на основе запросов: интеграция обращается к Loomio, когда ей нужно прочитать или изменить данные. Вебхук группы позволяет отправлять данные в обратном направлении. Loomio отправляет выбранные события группы на вашу конечную точку по мере их возникновения, поэтому интеграции не нужно регулярно опрашивать REST API для обнаружения изменений.

Вебхуки настраиваются отдельно для каждой группы и требуют прав администратора группы. Ими можно управлять через интерфейс Loomio:

1. Откройте группу.
2. Откройте меню группы и выберите **Интеграция чата**.
3. Добавьте интеграцию, соответствующую формату данных, который принимает ваша конечная точка. Для конечной точки общего назначения используйте формат Mattermost/Markdown.
4. Введите название и URL назначения.
5. Выберите события, которые Loomio должен отправлять автоматически.
6. Сохраните интеграцию и используйте **Тестовое соединение**, чтобы отправить тестовое сообщение.

Используйте HTTPS и URL назначения, который невозможно угадать. Loomio требует, чтобы адрес назначения разрешался в публичный адрес, и блокирует запросы к локальным адресам и адресам частных сетей.

Агенты и другие интеграции могут управлять вебхуками через описанные ниже конечные точки чат-ботов с аутентификацией Bearer. Ресурс называется `chatbots` для совместимости с интеграциями чата Loomio, но также представляет исходящие вебхуки общего назначения.

<!-- translation-section: list-webhooks -->

### Список вебхуков

Возвращает интеграции чата, настроенные для группы. Пользователь, которому принадлежит API-ключ, должен быть администратором этой группы. Ответ включает URL назначения, поэтому его нельзя раскрывать обычным участникам группы.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Ответ содержит массив `chatbots` со следующими полями:

| Поле | Описание |
| --- | --- |
| `id` | Идентификатор интеграции, используемый для обновления и удаления |
| `group_id` | Группа, получающая события |
| `name` | Название интеграции для администрирования |
| `kind` | `webhook` для исходящего вебхука или `matrix` для интеграции с Matrix |
| `webhook_kind` | Формат данных: `markdown`, `slack`, `discord`, `microsoft` или `webex` |
| `server` | URL назначения |
| `event_kinds` | События, отправляемые автоматически |
| `notification_only` | Содержат ли сообщения только заголовок уведомления |

<!-- translation-section: create-a-webhook -->

### Создание вебхука

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

Пользователь, которому принадлежит API-ключ, должен быть администратором группы с идентификатором `group_id`. Перед сохранением проверяется, что URL назначения является публичным.

<!-- translation-section: update-a-webhook -->

### Обновление вебхука

`PATCH /api/b2/chatbots/:id`

Передайте поля, которые нужно изменить. Вебхук нельзя перенести в другую группу, изменив `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Проверка адреса назначения вебхука

Отправьте тестовое сообщение в формате, совместимом с Markdown, на адрес назначения до или после сохранения его конфигурации.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Удаление вебхука

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Удаление конфигурации прекращает дальнейшую отправку сообщений. Содержимое группы Loomio при этом не удаляется.

<!-- translation-section: event-types -->

### Типы событий

Вебхук может подписаться на следующие типы событий:

| Событие | Когда отправляется |
| --- | --- |
| `new_discussion` | Начато обсуждение |
| `discussion_edited` | Обсуждение отредактировано |
| `new_comment` | Создан комментарий |
| `poll_created` | Начат опрос |
| `poll_edited` | Опрос отредактирован |
| `poll_closing_soon` | Приближается время закрытия опроса |
| `poll_expired` | Наступило время закрытия опроса |
| `poll_closed_by_user` | Пользователь закрыл опрос вручную |
| `poll_reopened` | Голосование в опросе возобновлено |
| `outcome_created` | Опубликован вывод |
| `outcome_updated` | Вывод обновлён |
| `outcome_review_due` | Наступил срок пересмотра вывода |
| `stance_created` | Подан голос |
| `stance_updated` | Голос изменён |

Вебхук принадлежит одной группе и получает события этой группы, на которые он подписан. Пользователи также могут явно выбрать интеграцию, когда делятся содержимым или отправляют некоторые уведомления, даже если соответствующее автоматическое событие не выбрано.

<!-- translation-section: http-delivery -->

### Доставка по HTTP

Loomio асинхронно отправляет HTTP-запрос `POST` на настроенный URL с таким заголовком:

```text
Content-Type: application/json; charset=utf-8
```

Время ожидания ответа на запрос составляет пять секунд. Ответ `2xx`, включая `204 No Content`, считается успешным. Получатели вебхуков должны отвечать быстро, выполнять длительную обработку асинхронно и учитывать возможность повторной доставки или доставки не по порядку.

В настоящее время Loomio не добавляет подпись вебхука, заголовок с общим секретом, идентификатор события или идентификатор доставки. Обращайтесь с полным URL назначения как с учётными данными, не публикуйте его и включайте в URL токен, который невозможно угадать, если принимающий сервис это поддерживает. Если требуется стабильная машиночитаемая схема событий или доставка с подписью, используйте вебхук как уведомление об изменении и получайте актуальные записи через пользовательский API с аутентификацией.

<!-- translation-section: payload-formats -->

### Форматы передаваемых данных

Данные вебхуков — это сообщения для отображения в чатах. Они не являются полными сериализованными записями Loomio. Ссылки в сообщении указывают на затронутое содержимое Loomio; если интеграции нужны структурированные данные о текущем состоянии, она может дополнительно запросить их через пользовательский API.

| Формат интеграции | Основные поля JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, ограничено примерно 1 900 символами |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Например, общий формат Markdown отправляет тело запроса следующего вида:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Точный текст сообщения зависит от события, языка группы, настройки отправки только уведомлений и версии Loomio. Получателям следует использовать документированные поля верхнего уровня выбранного формата, а не разбирать формулировки предложений.

<!-- translation-section: search -->

## Поиск

Поиск обсуждений, комментариев, опросов, голосов и выводов, доступных пользователю, которому принадлежит API-ключ. Результаты включают публичное содержимое, даже если пользователь не является участником соответствующей группы; доступ к закрытому содержимому определяется обычными правилами видимости веток.

`GET /api/b2/search`

<!-- translation-section: params -->

### Параметры

| Имя | Описание |
| --- | --- |
| `query` | Текст для поиска. Поддерживаются точные и приблизительные совпадения |
| `group_id` | Ограничивает результаты одной доступной группой |
| `org_id` | Ограничивает результаты доступной родительской группой и её доступными подгруппами. Используйте `0` для прямых обсуждений |
| `type` | Ограничивает результаты одним типом: `Discussion`, `Comment`, `Poll`, `Stance` или `Outcome` |
| `types` | Список типов результатов через запятую |
| `tag` | Ограничивает результаты ветками с этим тегом |
| `author_id` | Ограничивает результаты содержимым одного автора. Без `query` возвращает недавнюю доступную активность этого автора |
| `order` | Укажите `authored_at_desc`, чтобы упорядочить найденное содержимое по времени создания |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Ответ содержит массив `search_results`. Каждый результат указывает на найденную запись и доступные сведения о ней с помощью полей, включая `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` и `tags`. Поля, неприменимые к результату, имеют значение `null`.

<!-- translation-section: participation-report -->

## Отчёт об участии

Возвращает те же сводные данные об участии, которые используются в отчёте об участии Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `section` | Раздел отчёта: `base`, `users` или `countries`. Используйте `users` для активности отдельных пользователей |
| `group_scope` | `custom` или `my`. Устаревшее значение `all` трактуется как `my`, поскольку ключи пользовательского API никогда не предоставляют доступ ко всему экземпляру Loomio |
| `group_ids` | Идентификаторы групп через запятую при `group_scope=custom`. Идентификаторы групп, в которых пользователь API не состоит, игнорируются |
| `start_month` | Первый включаемый месяц в формате `YYYY-MM`; по умолчанию — месяц 12 месяцев назад |
| `end_month` | Последний включаемый месяц в формате `YYYY-MM`; по умолчанию — текущий месяц |
| `interval` | Интервал для раздела `base`: `day`, `week`, `month` или `year` |
| `member_type` | Укажите `delegate` вместе с `section=users`, чтобы получить только действующих делегатов |

Пользователь считается делегатом, если он является действующим участником с ролью делегата хотя бы в одной выбранной группе. Его показатели суммируются по всем выбранным группам. Строки делегатов возвращаются, даже если все показатели активности равны нулю. Показатели охватывают ветки, комментарии, опросы, голоса, выводы и реакции; они не отражают долю участия в голосовании. Строки пользователей также содержат число выданных, поданных и пропущенных именных бюллетеней. Анонимные опросы исключены из всех индивидуальных показателей голосования. Значение `all_votes_cast` равно true только в том случае, если был выдан хотя бы один бюллетень и все выданные бюллетени были поданы.

API применяет те же правила видимости групп, что и отчёт в приложении. API-ключ пользователя не может раскрыть данные отчёта из групп, к которым у этого пользователя нет доступа.

<!-- translation-section: example -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Массив `users` содержит строки со всеми показателями активности:

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

## Создание обсуждения

Создаёт обсуждение от имени пользователя, которому принадлежит API-ключ.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `group_id` | Группа, в которой будет находиться ветка |
| `title` | Заголовок ветки, обязательный параметр |
| `description` | Описание ветки, необязательный параметр |
| `description_format` | `md` или `html`, необязательный параметр, по умолчанию `md` |
| `recipient_audience` | `group` или null. При значении `group` вся группа получит уведомление о новой ветке |
| `recipient_user_ids` | Массив идентификаторов пользователей, которых нужно уведомить или пригласить в ветку |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить в ветку |
| `recipient_message` | Сообщение для включения в приглашение по электронной почте |

<!-- translation-section: example-2 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Получение обсуждения

Получите обсуждение по его ID (целое число) или ключу (строка).

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Список обсуждений

Получите список обсуждений в группе, доступных пользователю, которому принадлежит API-ключ. Если группа общедоступна, человек, не состоящий в ней, может получить список её публичных обсуждений; закрытые обсуждения доступны только пользователям, которые могут читать их в Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. ID группы, список обсуждений которой нужно получить |
| `status` | Строка, необязательный параметр, по умолчанию `open`. Значения: `open`, `closed`, `all` |
| `limit` | Целое число, необязательный параметр, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничной выдачи |

Совместимость с прежними версиями: `per` и `from` принимаются как псевдонимы для `limit` и `offset` и продолжат работать.

<!-- translation-section: example-4 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Список веток

Получите список веток обсуждений и опросов, доступных пользователю, которому принадлежит API-ключ, в порядке последней активности. ID ветки — это её `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Параметры

| Название | Описание |
| --- | --- |
| `limit` | Целое число, необязательный параметр, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничной выдачи |

<!-- translation-section: example-5 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Чтение ветки

Получите ветку, её упорядоченную последовательность событий или полное доступное содержимое в виде документа Markdown.

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

Конечная точка `items` возвращает упорядоченную последовательность событий, включая доступные комментарии, опросы, голоса и выводы. Конечная точка `markdown` возвращает полное доступное содержимое ветки в виде одного документа Markdown. Причины выбора включаются только тогда, когда они доступны пользователю, которому принадлежит API-ключ.

Все конечные точки для веток применяют те же права доступа, что и интерфейс Loomio. API-ключ не предоставляет доступ к ветке, которую пользователь не может открыть обычным способом.

<!-- translation-section: edit-discussion -->

## Редактирование обсуждения

Отредактируйте обсуждение от имени пользователя, которому принадлежит API-ключ. Действуют те же права доступа, что и в Loomio: у пользователя должно быть право редактировать это обсуждение.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Параметры

| Название | Описание |
| --- | --- |
| `title` | Обновлённый заголовок |
| `description` | Обновлённое описание |
| `description_format` | `md` или `html`, необязательный параметр, по умолчанию `md` |
| `recipient_audience` | `group` или null. Если указано `group`, вся группа получит уведомление об изменении |
| `recipient_user_ids` | Массив ID пользователей, которых нужно уведомить или пригласить в ветку |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить в ветку |
| `recipient_message` | Сообщение для включения в приглашение по электронной почте |

<!-- translation-section: example-7 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Удаление обсуждения с сохранением записи

Удалите обсуждение от имени пользователя, которому принадлежит API-ключ. Обсуждение помечается как удалённое, но его запись сохраняется.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Создание комментария

Создайте комментарий в обсуждении от имени пользователя, которому принадлежит API-ключ.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Параметры

| Название | Описание |
| --- | --- |
| `discussion_id` | Целое число, обязательный параметр. ID обсуждения, в котором нужно оставить комментарий |
| `body` | Текст комментария, обязателен, если нет вложения |
| `body_format` | `md` или `html`, необязательный параметр, по умолчанию `md` |

<!-- translation-section: example-9 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Редактирование комментария

Отредактируйте комментарий от имени пользователя, которому принадлежит API-ключ. Действуют те же права доступа, что и в Loomio: у пользователя должно быть право редактировать этот комментарий.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Параметры

| Название | Описание |
| --- | --- |
| `body` | Обновлённый текст комментария |
| `body_format` | `md` или `html`, необязательный параметр, по умолчанию `md` |

<!-- translation-section: example-10 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Удаление комментария с сохранением записи

Удалите комментарий от имени пользователя, которому принадлежит API-ключ. Комментарий помечается как удалённый, его текст скрывается, но запись комментария сохраняется.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Создание опроса

Создайте опрос от имени пользователя, которому принадлежит API-ключ.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, необязательно, по умолчанию null. ID группы для опроса. Если передан `discussion_id`, `group_id` игнорируется |
| `discussion_id` | Целое число, необязательно, по умолчанию null. ID ветки обсуждения, в которую нужно добавить этот опрос |
| `title` | Строка, обязательно. Заголовок опроса |
| `poll_type` | Строка, обязательно. Значения: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Строка, необязательно. Основной текст опроса |
| `details_format` | Строка, необязательно, по умолчанию `md`. Значения: `md` или `html` |
| `options` | Массив строк. Если `poll_type` — `proposal`, допустимые значения: `agree`, `disagree`, `abstain`, `block`. Если `poll_type` — `meeting`, укажите строки с датой или датой и временем в формате ISO 8601. Для остальных типов опросов допустима любая строка |
| `closing_at` | Строка в формате ISO 8601 или null, по умолчанию null. Пример: `2026-09-01T12:00:00Z`. Если значение null, голосование отключено, а опрос считается находящимся в процессе подготовки |
| `specified_voters_only` | Логическое значение, необязательно, по умолчанию false. Если true, голосовать могут только указанные люди. Если false, все участники группы получат приглашение голосовать |
| `hide_results` | Строка, необязательно, по умолчанию `off`. Значения: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Логическое значение, по умолчанию false. Показывать варианты голосующим в случайном порядке |
| `anonymous` | Логическое значение, необязательно, по умолчанию false. Скрывать личности голосующих |
| `recipient_audience` | `group` или null, необязательно, по умолчанию null. Если `group`, вся группа получит уведомление |
| `notify_on_closing_soon` | Строка, необязательно, по умолчанию `nobody`. Значения: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Массив ID пользователей, которым нужно отправить уведомление или приглашение |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить голосовать |
| `recipient_message` | Сообщение для включения в приглашение по электронной почте |
| `notify_recipients` | Логическое значение, по умолчанию false. Если false, добавить людей без отправки уведомлений. Если true, все приглашённые в этом запросе получат уведомление по электронной почте |

<!-- translation-section: example-12 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Получение опроса

Получите опрос по его ID (целому числу) или ключу (строке).

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Список опросов

Получите список опросов в группе, доступных пользователю, которому принадлежит API-ключ. Если группа общедоступна, пользователь, не состоящий в ней, может получить список её общедоступных опросов; доступ к закрытым от посторонних опросам имеют только пользователи, которые могут читать их в Loomio. Ответ включает текущий вывод каждого доступного опроса, поэтому вы можете использовать `status=closed`, чтобы получить список предложений, по которым уже принято решение.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. ID группы, из которой нужно получить список опросов |
| `status` | Строка, необязательный параметр, по умолчанию `active`. Значения: `active`, `closed`, `all` |
| `limit` | Целое число, необязательный параметр, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничного вывода |

Для совместимости с прежними версиями `per` и `from` принимаются как синонимы `limit` и `offset` и продолжат работать.

<!-- translation-section: example-14 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Редактирование опроса

Отредактируйте опрос от имени пользователя, которому принадлежит API-ключ. Действуют те же права доступа, что и в Loomio: пользователь должен иметь право редактировать этот опрос.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Параметры

| Название | Описание |
| --- | --- |
| `title` | Обновлённый заголовок |
| `details` | Обновлённое описание опроса |
| `details_format` | `md` или `html`, необязательно, по умолчанию `md` |
| `options` | Обновлённые названия вариантов. Изменение вариантов может повлиять на существующие голоса в зависимости от состояния опроса |
| `closing_at` | Строка в формате ISO 8601 или null |
| `recipient_audience` | `group` или null. Если `group`, вся группа получит уведомление |
| `recipient_user_ids` | Массив ID пользователей, которым нужно отправить уведомление или приглашение |
| `recipient_emails` | Массив адресов электронной почты людей, которых нужно пригласить голосовать |
| `recipient_message` | Сообщение для включения в приглашение по электронной почте |

<!-- translation-section: example-15 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Мягкое удаление опроса

Выполните мягкое удаление опроса от имени пользователя, которому принадлежит API-ключ. Опрос помечается как удалённый, а его запись сохраняется.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Список участников группы

Получите список участников группы, доступный пользователю, которому принадлежит ключ API. Участники группы могут просматривать имена, идентификаторы, должности и роли участников. Адреса электронной почты включаются только для собственной учётной записи пользователя, которому принадлежит ключ API, или если этот пользователь является администратором группы.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. Идентификатор группы, список участников которой нужно получить |

<!-- translation-section: example-17 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Управление участниками группы

Отправьте список адресов электронной почты. На все новые адреса будут отправлены приглашения в группу. В отличие от получения списка участников, эта операция требует прав администратора группы.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Параметры

| Имя | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. Идентификатор группы, составом участников которой нужно управлять |
| `emails` | Массив строк, обязательный параметр. Адреса электронной почты людей, которых нужно пригласить в группу |
| `remove_absent` | Логическое значение. Если true, из группы удаляются все, чьи адреса электронной почты отсутствуют в списке |

<!-- translation-section: example-18 -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Если вы передадите `remove_absent=1`, все участники группы, не включённые в список, будут удалены из группы. Будьте осторожны: вы можете удалить всех участников вашей группы.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

В ответ возвращается объект с `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
