---
title: Серверный API
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
sections:
  introduction: a357cdc2bfc0223e
  authentication: cbabcc874f053455
  user-object: c3a00ec4e3d66b09
  list-users: c7d62eee05e7a6a4
  example: 2f817ab1533206e6
  show-user: 36fa596a6a5c2fd8
  examples: 522d17246020d82f
  update-user: 39d632ce15d489d3
  params: 368f797e2a2b5c3d
  examples-2: 3aab846e77253829
  deactivate-user: 132d435583a46920
  examples-3: d8c7c152ab2b0ace
  reactivate-user: 309592dead978456
  examples-4: 95251484d1fd7e1d
  redact-user: 47ea30122aa92fae
  examples-5: 9d3bb1c3a865f3e0
  delete-user: 2d5a1dbd23324e6f
  examples-6: 71ae30577730b261
  sso-profile-sync-settings: 416144004d040e4f
generated:
  introduction: 6be77da5e8ae7a3a
  authentication: eacf6a6d5de53b9e
  user-object: 165b185a830e763d
  list-users: '0825e466bc46b7f4'
  example: be04025e675768c2
  show-user: 368bb28fc7311888
  examples: f3042c6d1e00b62e
  update-user: bd9d312dab145041
  params: b90a135705752392
  examples-2: 78ec54ae1cd4284e
  deactivate-user: f757878f08ee346c
  examples-3: d13ad07fa878c866
  reactivate-user: 5a9bb46deb05976d
  examples-4: a5253b2968d0f852
  redact-user: 68872a6507433b05
  examples-5: e4c4bcf389dbdac3
  delete-user: e64589c702c9ea79
  examples-6: 33800478d741706c
  sso-profile-sync-settings: eae944ece1f36e24
title_source: 370e81eb20eece44
title_generated: 54fb8698778f7bcf
---

<!-- translation-section: introduction -->

# Документация серверного API Loomio

<!-- seo-description: Используйте серверный API Loomio для управления учётными записями пользователей в самостоятельно размещённой установке Loomio. -->

`/api/b3` предназначен для операций на уровне сервера. Используйте `/api/b2` для действий от имени учётной записи пользователя Loomio.

<!-- translation-section: authentication -->

## Аутентификация

Задайте для `B3_API_KEY` секретное значение длиной более 16 символов.

Передавайте ключ как токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Передавайте учётные данные только в заголовке `Authorization`. Ключи API в строках запроса или телах запросов отклоняются.

<!-- translation-section: user-object -->

## Объект пользователя

Ответы с данными пользователя имеют следующую структуру:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
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

`GET /api/b3/users`

<!-- translation-section: example -->

### Пример

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
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

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

По идентификатору во внешней системе:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/b3/users/123
```

По идентификатору во внешней системе:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

По идентификатору во внешней системе:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
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

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Примеры

По идентификатору пользователя Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

По внешней учётной записи:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
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

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Примеры

По идентификатору пользователя Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

По внешней учётной записи:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
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

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Примеры

По идентификатору пользователя Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

По внешней учётной записи:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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
