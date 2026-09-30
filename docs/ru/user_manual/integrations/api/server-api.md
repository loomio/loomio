---
title: Серверный API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: 1115427d6f38482a
  authentication: 22a35693e25d44fe
  user-object: 165b185a830e763d
  list-users: '0825e466bc46b7f4'
  example: be04025e675768c2
  show-user: 73f1b85229274851
  examples: a788e54777caf05d
  update-user: c990ca63655e4bd7
  params: b90a135705752392
  examples-2: d5ff73860bf16afe
  deactivate-user: 3bfa1c9aa1427c41
  examples-3: 9aa8da145e45d095
  reactivate-user: c20d271f4df76ae7
  examples-4: 46b3133180cbf80b
  redact-user: 6d43b1100ee333eb
  examples-5: dad5d860f7c83343
  delete-user: b6fdd3bfd476ecbd
  examples-6: 663f9ad0cf0fd5c5
  sso-profile-sync-settings: 9a51a11feb01596a
title_source: 370e81eb20eece44
title_generated: 54fb8698778f7bcf
---

<!-- translation-section: introduction -->

# Документация по серверному API Loomio

<!-- seo-description: Используйте серверный API Loomio для управления учётными записями пользователей в собственной установке Loomio. -->

`/api/b3` предназначен для операций на уровне сервера. Для действий от имени пользователя Loomio используйте `/api/b2`.

<!-- translation-section: authentication -->

## Аутентификация

Задайте для `B3_API_KEY` секретный ключ длиной более 16 символов.

Передавайте ключ как токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Передавайте учётные данные только в заголовке `Authorization`. API-ключи в строке запроса или теле запроса отклоняются.

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

Найдите пользователя по его ID в Loomio или внешнему идентификатору.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

По внешнему идентификатору:

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

Обновите поля профиля пользователя, найденного по его ID в Loomio или внешнему идентификатору.

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

По внешнему идентификатору:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Ответ содержит обновлённые данные пользователя:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Деактивация пользователя

Деактивируйте учётную запись пользователя, найденную по его ID в Loomio или внешнему идентификатору.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

По внешнему идентификатору:

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

Повторно активируйте деактивированную учётную запись пользователя, найденную по его ID в Loomio или внешнему идентификатору.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

По внешнему идентификатору:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Ответ:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Удаление личных данных пользователя

При удалении личных данных комментарии пользователя и другие созданные им материалы остаются в его группах. При этом удаляются известные персональные данные: имя, биография, фотография профиля, адрес электронной почты, учётные данные для входа, внешние идентификаторы и активные сеансы.

Это рекомендуемый способ удалить пользователя из Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

По внешнему идентификатору:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Ответ:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Удаление пользователя

При удалении исчезают учётная запись пользователя и созданные им записи. Комментарии удаляются из обсуждений, голоса — из голосований. Связи в базе данных могут также привести к удалению групп, обсуждений, голосований и других записей, созданных пользователем.

Удаление может привести к значительной потере данных. Вместо него настоятельно рекомендуется обезличивание.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Примеры

По ID пользователя в Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

По внешнему идентификатору:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Ответ:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Настройки синхронизации профиля через SSO

Используйте эти настройки, если полями профиля Loomio управляет другая система.

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

Пользователи по-прежнему могут изменять локальные поля Loomio, например `short_bio` и `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` обновляет `name` и `email` на основе данных входа через SSO. Если единственным источником этих обновлений должен быть внешний скрипт синхронизации, оставьте эту строку закомментированной или не задавайте переменную.

`LOOMIO_SSO_FORCE_USER_ATTRS` по-прежнему работает в существующих установках. Эта настройка запрещает пользователям изменять профиль и обновляет `name` и `email` при входе через SSO.
