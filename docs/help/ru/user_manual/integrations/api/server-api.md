---
title: Серверный API
source_revision: 81fbad246f674a34694bb2ebfc8416dd04e46ee6
source_file: docs/help/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-28'
sections:
  introduction: 33c4ce1c59342826
  authentication: a215188bb0ae2b38
  user-object: 7e9e8ff3e48a4055
  list-users: 16e557db2983e597
  example: 5a370a67d3dc961f
  show-user: ef061aab9e142a98
  examples: 5b98557c8af42e29
  update-user: fc52abc60aa4eb6e
  params: 368f797e2a2b5c3d
  examples-2: b6bc03ca1e104210
  deactivate-user: 19c9b37ded7cad07
  examples-3: 706a02fb50225d20
  reactivate-user: 03bccb45ded4f11c
  examples-4: 5c9cf19d21267502
  redact-user: 9560a30820cb43cc
  examples-5: df81d06971fb0391
  delete-user: 1aad5e4da586e0ed
  examples-6: 23542029b0bc8237
  sso-profile-sync-settings: 416144004d040e4f
  provisioning: de7ad238bf914455
generated:
  introduction: fd6cbcbf23982613
  authentication: 92b51ac9d5531078
  user-object: 8b553d4926e2868d
  list-users: 8b6bac18c486bdf7
  example: cf15795707e7fe5c
  show-user: 4bebe3faad9fc795
  examples: e8b72d9caaef1db7
  update-user: 2f91be4f61ae6623
  params: b90a135705752392
  examples-2: 9a95cf2bf6259e86
  deactivate-user: f6b55899d1c1c0f2
  examples-3: 1a1f103d1e0de5d8
  reactivate-user: 6a1a96adf30e8e96
  examples-4: 9e52908e46df8542
  redact-user: 9313b1828c10c88f
  examples-5: 11bfe580a38ef70d
  delete-user: '09b63bde1e0912f5'
  examples-6: 1b54b3f3711c0cc3
  sso-profile-sync-settings: eae944ece1f36e24
  provisioning: 76daec53639e2d73
title_source: 370e81eb20eece44
title_generated: 54fb8698778f7bcf
---

<!-- translation-section: introduction -->

# Документация серверного API Loomio

<!-- seo-description: Используйте серверный API Loomio для создания учётных записей пользователей, поиска групп и управления участием в группах в самостоятельно размещённой установке Loomio. -->

`/api/server0` предназначен для операций на уровне сервера. Используйте `/api/user0` для действий от имени учётной записи пользователя Loomio.

Используйте один серверный ключ для создания учётных записей и управления ими, поиска групп во всей установке и управления участием в этих группах и ролями участников. Учётная запись бота, пользовательский ключ API и участие в этих группах не требуются. Пользовательские ключи API по-прежнему действуют в рамках разрешений пользователя в группах.

<!-- translation-section: authentication -->

## Аутентификация

Ключ задаётся параметром `SERVER_API_KEY` в окружении сервера. Для новых установок его создаёт `create_env.sh`.

Передавайте ключ как токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Передавайте учётные данные только в заголовке `Authorization`. Ключи API в строках запроса или телах запросов отклоняются.

<!-- translation-section: provisioning -->

## Создание учётных записей и управление участием в группах

| Метод | Конечная точка | Назначение |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Создать учётную запись |
| `GET` | `/api/server0/groups` | Найти группы во всей установке |
| `GET` | `/api/server0/memberships` | Получить список записей об участии в группе |
| `POST` | `/api/server0/memberships` | Пригласить участников или синхронизировать полный список участников |
| `PATCH` | `/api/server0/memberships/:id` | Изменить роли администратора группы и делегата |
| `DELETE` | `/api/server0/memberships/:id` | Отозвать участие одного пользователя в группе |

Конечные точки для обновления, деактивации, повторной активации, обезличивания и удаления существующих учётных записей описаны ниже.

### Создание учётной записи

`POST /api/server0/users`

Передайте объект `user` с обязательным полем `email`. Пробелы по краям адресов электронной почты удаляются, а сами адреса приводятся к нижнему регистру. Необязательные поля: `name`, `username` и `is_admin`. Здесь `is_admin` означает администратора установки; роли администраторов групп задаются в записях об участии в группах. Не передавайте `username`, чтобы имя пользователя было создано автоматически. Неизвестные поля отклоняются.

```bash
curl https://loomio.example.org/api/server0/users \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "user": {
      "email": "ada@example.org",
      "name": "Ada Lovelace",
      "username": "ada",
      "is_admin": false
    }
  }'
```

В ответ возвращается HTTP `201` с объектом `user`. При недопустимых значениях полей или уже занятом адресе электронной почты либо имени пользователя возвращается HTTP `422`. Создание учётной записи не отправляет приглашение, не выполняет вход пользователя и не помечает его адрес электронной почты как подтверждённый. Пригласите пользователя в группу через конечную точку управления участием в группах, чтобы отправить приглашение с помощью обычного механизма уведомлений.

### Поиск групп

`GET /api/server0/groups`

Получите список всех неудалённых групп, включая закрытые группы и группы с истёкшими подписками. Результаты упорядочены по возрастанию ID. Для постраничного просмотра используйте `limit` (значение по умолчанию и максимальное значение — `50`) и `offset` (значение по умолчанию — `0`).

```bash
curl 'https://loomio.example.org/api/server0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "groups": [
    {
      "id": 123,
      "key": "examplegroup",
      "name": "Planning group",
      "handle": "planning",
      "parent_id": null,
      "group_privacy": "secret"
    }
  ],
  "meta": {
    "total": 1
  }
}
```

### Получение списка записей об участии в группе

`GET /api/server0/memberships?group_id=123`

Параметр `group_id` обязателен. Результаты включают записи о подтверждённом участии и приглашения, ожидающие принятия, и упорядочены по возрастанию ID записи об участии. Отозванные записи об участии исключаются. Для постраничного просмотра используйте `limit` (значение по умолчанию и максимальное значение — `50`) и `offset` (значение по умолчанию — `0`).

```bash
curl 'https://loomio.example.org/api/server0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "memberships": [
    {
      "id": 456,
      "group_id": 123,
      "user_id": 789,
      "user_email": "ada@example.org",
      "user_name": "Ada Lovelace",
      "admin": false,
      "delegate": false,
      "accepted_at": null,
      "pending": true
    }
  ],
  "meta": {
    "total": 1
  }
}
```

`admin` и `delegate` — роли в группе. `accepted_at` — дата и время принятия приглашения или `null`, пока приглашение ожидает принятия. Эта конечная точка не раскрывает токены приглашений, данные для входа или голоса.

### Приглашение участников или синхронизация списка участников

`POST /api/server0/memberships`

Передайте обязательные параметры `group_id` и массив `emails`. По умолчанию добавляются перечисленные пользователи, у которых ещё нет действующего участия в группе, а остальные участники сохраняются. Пробелы по краям адресов электронной почты удаляются, адреса приводятся к нижнему регистру, а дубликаты исключаются. Для новых адресов создаются учётные записи и приглашения, ожидающие принятия. Существующие участники другой активной группы той же организации с подтверждённым адресом электронной почты принимаются автоматически, как и при приглашении через пользовательский API.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

Чтобы синхронизировать полный список участников, явно задайте для `remove_absent` значение `true`. Все, кто отсутствует в списке, будут удалены из этой группы и её подгрупп. Пустой массив с `remove_absent: true` удаляет всех, включая администраторов группы. Если вы только добавляете пользователей, не передавайте `remove_absent` или задайте значение `false`. Устаревшие значения `1` и `0` также принимаются.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org"
    ],
    "remove_absent": true
  }'
```

```json
{
  "added_emails": [],
  "removed_emails": [
    "alex@example.org"
  ]
}
```

Повторная отправка того же запроса не создаёт дубликаты записей об участии и не отправляет приглашения повторно. Повторное приглашение участника, чьё участие было отозвано, восстанавливает его доступ к группе, но не прежнюю роль администратора. Новые приглашения и изменения ролей используют обычный механизм уведомлений; при этом ни один пользователь не указывается как инициатор действия.

Если список адресов электронной почты отсутствует или имеет неверный формат, а также при недопустимых логических значениях возвращается HTTP `400`. Если в списке указана деактивированная учётная запись, возвращается HTTP `422`; перед добавлением явно активируйте её повторно. Недопустимые данные учётных записей, ограничения подписки и другие ошибки приводят к откату всей синхронизации, включая создание учётных записей и удаление участников из группы. Для добавления участников требуется активная группа; ограничения подписки на число участников продолжают действовать.

### Изменение ролей участника группы

`PATCH /api/server0/memberships/:id`

Передайте объект `membership`, содержащий одно или оба логических поля `admin` и `delegate`. Роли, поля которых не переданы, остаются без изменений. Неизвестные поля отклоняются; эта конечная точка не позволяет перенести запись об участии, принять приглашение или изменить вес голосов.

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

Возвращает объект `membership` с теми же полями, что и в списке записей об участии. Назначение роли создаёт обычное уведомление о роли; повторная отправка неизменённой роли не вызывает повторного уведомления. Для изменения ролей требуется активная группа. Для отозванных записей об участии возвращается HTTP `404`.

### Удаление одного участника из группы

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Возвращает `{"success": true}`. Удаление отзывает доступ к группе и её подгруппам, включая доступ к темам и право голосовать в активных опросах. Оно не удаляет учётную запись, не затрагивает другие группы и не отменяет доступ, предоставленный напрямую к веткам. Повторное удаление завершается успешно. Вы можете удалять участников из групп с истёкшими подписками; для удалённых групп возвращается HTTP `404`.

<!-- translation-section: user-object -->

## Объект пользователя

Ответы с данными пользователя имеют следующую структуру:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
  "is_admin": false,
  "active": true,
  "deactivated_at": null,
  "identities": [
    {
      "id": 456,
      "identity_type": "oauth",
      "uid": "external-123",
      "email": "ada@example.org",
      "name": "Ada Lovelace"
    }
  ]
}
```

<!-- translation-section: list-users -->

## Список пользователей

Получите список всех учётных записей пользователей в установке Loomio.

`GET /api/server0/users`

<!-- translation-section: example -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Ответ:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Получение данных пользователя

Найдите пользователя по его ID в Loomio или идентификатору во внешней системе.

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

По идентификатору во внешней системе:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Ответ:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Обновление данных пользователя

Обновите поля профиля пользователя, найденного по его ID в Loomio или идентификатору во внешней системе.

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Параметры

| Поле | Описание |
| --- | --- |
| `name` | Отображаемое имя |
| `username` | Имя пользователя в Loomio |
| `email` | Адрес электронной почты |

<!-- translation-section: examples-2 -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/123
```

По идентификатору во внешней системе:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Ответ с обновлёнными данными пользователя:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Деактивация пользователя

Деактивируйте учётную запись пользователя, найденную по его ID в Loomio или идентификатору во внешней системе.

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

По идентификатору во внешней системе:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
```

Ответ:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Повторная активация пользователя

Повторно активируйте деактивированную учётную запись пользователя, найденную по идентификатору пользователя Loomio или внешней учётной записи.

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Примеры

По идентификатору пользователя Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

По внешней учётной записи:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
```

Возвращает:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Обезличивание пользователя

Обезличивание сохраняет комментарии пользователя и другой созданный им контент в его группах, но удаляет известные сведения, позволяющие установить его личность, такие как имя, биография, фотография профиля, адрес электронной почты, данные для входа, внешние учётные записи и активные сеансы.

Это рекомендуемый способ удаления пользователя из Loomio.

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Примеры

По идентификатору пользователя Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

По внешней учётной записи:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
```

Возвращает:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Удаление пользователя

Удаление убирает пользователя и созданные им записи. Комментарии удаляются из веток, голоса — из опросов. Группы, обсуждения, опросы и другие записи, созданные пользователем, также могут быть удалены через связи в базе данных.

Эта операция приводит к удалению большого объёма данных. Настоятельно рекомендуется использовать обезличивание.

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Примеры

По идентификатору пользователя Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

По внешней учётной записи:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Возвращает:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Настройки синхронизации профиля через SSO

Используйте эти настройки, когда полями профиля Loomio управляет другая система.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` запрещает пользователям самостоятельно изменять следующие поля:

| Поле | Примечания |
| --- | --- |
| `name` | Управляется внешней синхронизацией |
| `username` | Управляется внешней синхронизацией |
| `email` | Управляется внешней синхронизацией |
| `avatar_kind` / `uploaded_avatar` | Управляется внешней синхронизацией |

Пользователи по-прежнему могут изменять локальные поля Loomio, такие как `short_bio` и `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` обновляет `name` и `email` на основе данных входа через SSO. Оставьте эту переменную закомментированной или не задавайте её, если единственным источником таких обновлений должен быть внешний скрипт синхронизации.

`LOOMIO_SSO_FORCE_USER_ATTRS` по-прежнему работает в существующих установках. Эта настройка одновременно запрещает пользователям изменять поля и обновляет `name` и `email` при входе через SSO.
