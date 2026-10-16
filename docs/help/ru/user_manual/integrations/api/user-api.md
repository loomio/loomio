---
title: Пользовательский API
source_revision: 28ecc59f68d407f76f08133bfa0172aadbb53065
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-15'
sections:
  introduction: b6e6ec7463276869
  response-size-and-related-records: 298da635bf97dadd
  endpoint-summary: 258f7560def524ec
  groups: 0473f1f7fb78f074
  list-groups: 01de10c378eeba37
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: 6093df92815f7156
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
  create-discussion: 958fc684640462a9
  params-3: 657d582c89333097
  example-2: 57681d83fffe9515
  show-discussion: 40102aeffe4f1286
  example-3: c0ebd013a1b7fbd2
  list-discussions: '09ff7f0d3a937b41'
  params-4: dcebc294fbb9d837
  example-4: ffda1a4726380e2f
  list-threads: '09f7bd670e581400'
  params-5: 79b1cefac558effc
  example-5: a40ae2317faab46d
  read-thread: ac36d1b81c1eeed4
  example-6: 8c582a286e04ca75
  edit-discussion: 918161e7aa8f4aa6
  params-6: b819796d34354623
  example-7: 552295f78d3490af
  soft-delete-discussion: c8ffe951171e6f07
  example-8: 965c5761f34f9920
  create-comment: f95f56b81c8f22b5
  params-7: 5ad8ede0919c5f47
  example-9: 70ee3750f1543e9b
  edit-comment: 80322da74162d58f
  params-8: 288331c60f3c9b28
  example-10: ec89de8cc86b6fc8
  soft-delete-comment: 04baf86923c7e8f1
  example-11: f3675b780da755cd
  create-poll: cf62e787784a5e87
  params-9: df1611a9dedef2d8
  example-12: fa7410dd3a0a385f
  show-poll: d759508986aab08c
  example-13: 2867289a6c2beb9d
  list-polls: 56e5ed4ae45e5428
  params-10: e68e8cf62b21488d
  example-14: 40958a09c058d4cc
  edit-poll: 65467ad0b431ddbf
  params-11: 77f118397592bc05
  example-15: e56befa0f2ae3360
  soft-delete-poll: 61cf76310e08d7ff
  example-16: afbf95df96734a4d
  list-memberships: 5fab06bb8ecf1fd0
  params-12: decaff0790566fb0
  example-17: 5d92092b70ce545a
  manage-memberships: 802d39c06674d395
  params-13: 771b5338a4ba3d0b
  example-18: a50b01823a6935a0
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
generated:
  introduction: 5cb4aad5e173aa42
  response-size-and-related-records: c21d8eba9c49e29d
  endpoint-summary: 05f134ce28b6883d
  groups: 6437a4d2d344fc84
  list-groups: 2ab2b4a99fdb3bc2
  get-a-group: 01132bb83e4197e9
  webhooks: 1097a8dab740d326
  list-webhooks: 7b8c30a560c1c606
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
  create-discussion: 9602c086818967ac
  params-3: 72dc472b98cb64ac
  example-2: 30b76b63bb33a679
  show-discussion: 75da3c168f4cad7f
  example-3: 31b454c256d2a74f
  list-discussions: 96cddb0227eb7fa4
  params-4: '0497daa157e17452'
  example-4: b766e7bb1454a09d
  list-threads: 3e920b9981d918ec
  params-5: 20dbf3545bdf09c0
  example-5: 85f1c79ec99e7d0a
  read-thread: c7002d2a9811d757
  example-6: fc64883fa1cc1f8a
  edit-discussion: c9fb270b91560bd6
  params-6: aae7b6daec5cd353
  example-7: 10a28e37a2b5cd53
  soft-delete-discussion: aa537b8ce30aea81
  example-8: 41548f642a07a9f4
  create-comment: b441ec53d5d6a7fb
  params-7: c46adb2f65d67e90
  example-9: f18ca691a13a3adc
  edit-comment: af9856dd4626dbcf
  params-8: 3648169be1a25c7d
  example-10: 16fd17384c019a18
  soft-delete-comment: 1566f240d01d6c3b
  example-11: 7a36e65d1122da56
  create-poll: b4411ea24ffb6ef6
  params-9: a188f25cee3b5303
  example-12: 11b6714976005123
  show-poll: 7b737d8cc34061cf
  example-13: 2ab2d5ce6dc816c2
  list-polls: 0bb595415576a3d0
  params-10: b3ad2d0cd1b1e47a
  example-14: 2c39e80d469cfb65
  edit-poll: a7478b1e96f90ba5
  params-11: '029b023cfe9bf434'
  example-15: f2b355673312c408
  soft-delete-poll: 9bdb26fa2724239c
  example-16: 6f328dceffd3ad96
  list-memberships: bcbe77221dfff7f7
  params-12: cf6cc9ac7cf4e352
  example-17: f638e2aef87ec2d3
  manage-memberships: 46c7848a583d1000
  params-13: 6e1fbd3dbb021a69
  example-18: e668e8cfee7a81ef
  pagination: 1720a5ac18ac1606
  comments: f36c9c54bc6764a9
  discussions: 6ae42ca77d674c7f
  memberships: 80f5ff5576bc2d3c
  polls: 420f8fe7a44ecca2
  threads: a9131a0c4da2086a
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

```text
Authorization: Bearer YOUR_API_KEY
```

В примерах используются `YOUR_API_KEY`, идентификатор группы `123` и `https://www.loomio.com/`. Замените их вашим API-ключом, идентификатором группы и URL вашей установки Loomio.

<!-- translation-section: endpoint-summary -->

## Обзор конечных точек

| Метод | Конечная точка | Назначение |
| --- | --- | --- |
| `POST` | `/api/b2/comments` | Создать комментарий или ответ |
| `PATCH` | `/api/b2/comments/:id` | Изменить комментарий |
| `DELETE` | `/api/b2/comments/:id` | Удалить комментарий с сохранением записи |
| `POST` | `/api/b2/discussions` | Создать обсуждение |
| `GET` | `/api/b2/discussions/:id` | Получить обсуждение |
| `GET` | `/api/b2/discussions` | Получить список обсуждений в группе |
| `PATCH` | `/api/b2/discussions/:id` | Изменить обсуждение |
| `DELETE` | `/api/b2/discussions/:id` | Удалить обсуждение с сохранением записи |
| `GET` | `/api/b2/groups` | Получить список групп пользователя, которому принадлежит API-ключ |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Получить доступную группу |
| `GET` | `/api/b2/memberships` | Получить список записей об участии в группе |
| `POST` | `/api/b2/memberships` | Добавить участников и при необходимости удалить участников, отсутствующих в списке |
| `GET` | `/api/b2/reports` | Сформировать отчёт об участии |
| `POST` | `/api/b2/polls` | Создать опрос |
| `GET` | `/api/b2/polls/:id` | Получить опрос |
| `GET` | `/api/b2/polls` | Получить список опросов в группе |
| `PATCH` | `/api/b2/polls/:id` | Изменить опрос |
| `DELETE` | `/api/b2/polls/:id` | Удалить опрос с сохранением записи |
| `GET` | `/api/b2/search` | Найти доступные обсуждения, комментарии, опросы, голоса и выводы |
| `GET` | `/api/b2/threads` | Получить список доступных веток обсуждений и отдельных опросов |
| `GET` | `/api/b2/threads/:topic_id` | Получить ветку |
| `GET` | `/api/b2/threads/:topic_id/items` | Получить упорядоченные элементы ветки |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Получить полную ветку в формате Markdown |
| `GET` | `/api/b2/chatbots` | Получить список интеграций чата и вебхуков группы |
| `POST` | `/api/b2/chatbots` | Создать интеграцию чата или вебхук |
| `PATCH` | `/api/b2/chatbots/:id` | Обновить интеграцию чата или вебхук |
| `DELETE` | `/api/b2/chatbots/:id` | Удалить интеграцию чата или вебхук |
| `POST` | `/api/b2/chatbots/check` | Отправить тестовое сообщение для проверки соединения с вебхуком |

<!-- translation-section: pagination -->

## Постраничная выдача

Конечные точки обсуждений, групп, записей об участии в группах, опросов, веток, элементов веток и вебхуков принимают `limit` (по умолчанию `50`) и `offset` (по умолчанию `0`). Для групп, элементов веток и вебхуков значение `limit` ограничено числом `500`.

Чтобы получить следующую страницу, увеличьте `offset` на количество возвращённых основных записей. `meta.total` — полное количество записей, соответствующих запросу; связанные записи не учитываются в размере страницы.

Отчёты об участии возвращают все запрошенные данные, а поиск — до 20 результатов. Ни отчёты, ни поиск не поддерживают постраничную выдачу.

Конечные точки обсуждений, опросов и записей об участии в группах также принимают устаревшие псевдонимы `per` для `limit` и `from` для `offset`. Для новых интеграций используйте `limit` и `offset`.

<!-- translation-section: response-size-and-related-records -->

## Связанные записи

Ответы пользовательского API имеют составной формат: вместе с основными записями возвращаются связанные записи, например темы, группы, пользователи, опросы и реакции. Это позволяет клиенту заполнить локальное хранилище записей одним запросом, но ответ может содержать больше данных, чем нужно простой интеграции.

Передайте `compact=1`, чтобы исключить объёмные связанные записи тем, групп, родительских групп, участия в группах, реакций, тегов и переводов. Основные записи и связанные записи, необходимые для интерпретации их содержимого, остаются в ответе.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Для прямого управления передайте `exclude_types` с типами записей в единственном числе, разделёнными пробелами. Например, `exclude_types=group reaction` исключает связанные группы и реакции. Часто используемые значения: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` и `topic_item`. Исключения применяются к связанным записям, а не к основному ресурсу, запрошенному через конечную точку.

Ответы со списками включают `meta.total`, если для списка определён точный размер. Общее количество рассчитывается до применения `limit` и `offset`. Конечные точки, такие как поиск, которые намеренно возвращают ограниченный набор результатов, не включают `meta.total`, а не возвращают `null`.

<!-- translation-section: comments -->

## Комментарии

<!-- translation-section: create-comment -->

### Создание комментария

Создайте комментарий в обсуждении от имени пользователя, которому принадлежит API-ключ.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

#### Параметры

| Название | Описание |
| --- | --- |
| `discussion_id` | Целое число, обязательный параметр. ID обсуждения, в котором нужно оставить комментарий |
| `body` | Текст комментария, обязателен, если нет вложения |
| `body_format` | `md` или `html`, необязательный параметр, по умолчанию `md` |

<!-- translation-section: example-9 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

### Редактирование комментария

Отредактируйте комментарий от имени пользователя, которому принадлежит API-ключ. Действуют те же права доступа, что и в Loomio: у пользователя должно быть право редактировать этот комментарий.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

#### Параметры

| Название | Описание |
| --- | --- |
| `body` | Обновлённый текст комментария |
| `body_format` | `md` или `html`, необязательный параметр, по умолчанию `md` |

<!-- translation-section: example-10 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

### Удаление комментария с сохранением записи

Удалите комментарий от имени пользователя, которому принадлежит API-ключ. Комментарий помечается как удалённый, его текст скрывается, но запись комментария сохраняется.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: discussions -->

## Обсуждения

<!-- translation-section: create-discussion -->

### Создание обсуждения

Создаёт обсуждение от имени пользователя, которому принадлежит API-ключ.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

#### Параметры

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

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

### Получение обсуждения

Получите обсуждение по его ID (целое число) или ключу (строка).

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

### Список обсуждений

Получите список обсуждений в группе, доступных пользователю, которому принадлежит API-ключ. Если группа общедоступна, человек, не состоящий в ней, может получить список её публичных обсуждений; закрытые обсуждения доступны только пользователям, которые могут читать их в Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

#### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. ID группы, список обсуждений которой нужно получить |
| `status` | Строка, необязательный параметр, по умолчанию `open`. Значения: `open`, `closed`, `all` |
| `limit` | Целое число, необязательный параметр, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничной выдачи |

Совместимость с прежними версиями: `per` и `from` принимаются как псевдонимы для `limit` и `offset` и продолжат работать.

<!-- translation-section: example-4 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: edit-discussion -->

### Редактирование обсуждения

Отредактируйте обсуждение от имени пользователя, которому принадлежит API-ключ. Действуют те же права доступа, что и в Loomio: у пользователя должно быть право редактировать это обсуждение.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

#### Параметры

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

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

### Удаление обсуждения с сохранением записи

Удалите обсуждение от имени пользователя, которому принадлежит API-ключ. Обсуждение помечается как удалённое, но его запись сохраняется.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: groups -->

## Группы

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":" администраторов группы |\n| `delegates_count` | Количество делегатов |\n| `discussions_count` | Количество","after":" администраторов группы |\n| `discussions_count` | Количество"} -->

### Список групп

Возвращает группы, в которых пользователь, которому принадлежит API-ключ, является активным участником.

`GET /api/b2/groups`

| Имя | Описание |
| --- | --- |
| `limit` | Целое число, необязательный параметр, по умолчанию 50, максимум 500. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для разбиения на страницы |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/groups?limit=50&offset=0'
```

Ответ содержит страницу записей `groups`, упорядоченных по возрастанию идентификатора группы, и общее количество подходящих групп в `meta.total`. В него входят родительские группы и подгруппы, в том числе группы, подписка которых сейчас неактивна. Проверяйте поле `enabled`, если интеграция должна работать только с активными группами.

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

<!-- translation-section: memberships -->

## Участники групп

<!-- translation-section: list-memberships -->

### Список участников группы

Получите список участников группы, доступный пользователю, которому принадлежит ключ API. Участники группы могут просматривать имена, идентификаторы, должности и роли участников. Адреса электронной почты включаются только для собственной учётной записи пользователя, которому принадлежит ключ API, или если этот пользователь является администратором группы.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

#### Параметры

| Имя | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. Идентификатор группы, список участников которой нужно получить |
| `limit` | Целое число, необязательный параметр, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для разбиения на страницы |

Для совместимости с прежними интеграциями `per` и `from` принимаются как альтернативные имена для `limit` и `offset` и продолжат работать.

Ответ содержит страницу записей `memberships` и связанные записи `users`. `meta.total` — общее количество доступных записей об участии в группе до разбиения на страницы.

<!-- translation-section: example-17 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123&limit=50&offset=0'
```

<!-- translation-section: manage-memberships -->

### Управление участниками группы

Отправьте список адресов электронной почты. На все новые адреса будут отправлены приглашения в группу. В отличие от получения списка участников, эта операция требует прав администратора группы.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

#### Параметры

| Имя | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. Идентификатор группы, составом участников которой нужно управлять |
| `emails` | Массив строк, обязательный параметр. Адреса электронной почты людей, которых нужно пригласить в группу |
| `remove_absent` | Логическое значение. Если true, из группы удаляются все, чьи адреса электронной почты отсутствуют в списке |

<!-- translation-section: example-18 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Если вы передадите `remove_absent=1`, все участники группы, не включённые в список, будут удалены из группы. Будьте осторожны: вы можете удалить всех участников вашей группы.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

В ответ возвращается объект с `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.

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

<!-- translation-section: polls -->

## Опросы

<!-- translation-section: create-poll -->

### Создание опроса

Создайте опрос от имени пользователя, которому принадлежит API-ключ.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

#### Параметры

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

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

### Получение опроса

Получите опрос по его ID (целому числу) или ключу (строке).

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

### Список опросов

Получите список опросов в группе, доступных пользователю, которому принадлежит API-ключ. Если группа общедоступна, пользователь, не состоящий в ней, может получить список её общедоступных опросов; доступ к закрытым от посторонних опросам имеют только пользователи, которые могут читать их в Loomio. Ответ включает текущий вывод каждого доступного опроса, поэтому вы можете использовать `status=closed`, чтобы получить список предложений, по которым уже принято решение.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

#### Параметры

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. ID группы, из которой нужно получить список опросов |
| `status` | Строка, необязательный параметр, по умолчанию `active`. Значения: `active`, `closed`, `all` |
| `limit` | Целое число, необязательный параметр, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничного вывода |

Для совместимости с прежними версиями `per` и `from` принимаются как синонимы `limit` и `offset` и продолжат работать.

<!-- translation-section: example-14 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

### Редактирование опроса

Отредактируйте опрос от имени пользователя, которому принадлежит API-ключ. Действуют те же права доступа, что и в Loomio: пользователь должен иметь право редактировать этот опрос.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

#### Параметры

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

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

### Мягкое удаление опроса

Выполните мягкое удаление опроса от имени пользователя, которому принадлежит API-ключ. Опрос помечается как удалённый, а его запись сохраняется.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

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

<!-- translation-section: threads -->

## Ветки

<!-- translation-section: list-threads -->

### Список веток

Получите список веток обсуждений и опросов, доступных пользователю, которому принадлежит API-ключ, в порядке последней активности. ID ветки — это её `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

#### Параметры

| Название | Описание |
| --- | --- |
| `limit` | Целое число, необязательный параметр, по умолчанию 50. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничной выдачи |

<!-- translation-section: example-5 -->

#### Пример

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

### Чтение ветки

Получите ветку, её упорядоченную последовательность событий или полное доступное содержимое в виде документа Markdown.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

Конечная точка `items` принимает следующие параметры постраничной выдачи:

| Название | Описание |
| --- | --- |
| `limit` | Целое число, необязательный параметр, по умолчанию 50, максимум 500. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничной выдачи |

<!-- translation-section: example-6 -->

#### Пример

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Конечная точка `items` возвращает страницу последовательности событий в порядке возрастания их порядковых номеров, включая доступные комментарии, опросы, голоса и выводы. `meta.total` — общее количество элементов в ветке. Запросите следующие страницы, чтобы прочитать всю последовательность. Конечная точка `markdown` возвращает полное доступное содержимое ветки в виде одного документа Markdown. Причины выбора включаются только тогда, когда они доступны пользователю, которому принадлежит API-ключ.

Все конечные точки для веток применяют те же права доступа, что и интерфейс Loomio. API-ключ не предоставляет доступ к ветке, которую пользователь не может открыть обычным способом.

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

| Название | Описание |
| --- | --- |
| `group_id` | Целое число, обязательный параметр. ID группы, вебхуки которой нужно перечислить |
| `limit` | Целое число, необязательный параметр, по умолчанию 50, максимум 500. Размер страницы |
| `offset` | Целое число, необязательный параметр, по умолчанию 0. Смещение для постраничной выдачи |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123&limit=50&offset=0'
```

Ответ содержит страницу `chatbots`, упорядоченную по возрастанию ID интеграции, и общее количество интеграций в группе в `meta.total`. Каждая интеграция содержит следующие поля:

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
