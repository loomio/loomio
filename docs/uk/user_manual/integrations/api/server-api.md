---
title: Серверний API
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
  introduction: 19a28592ddc6d828
  authentication: 6b6e57cb08e2fbd6
  user-object: 221a852684ddd91a
  list-users: e3b5908bb28013d2
  example: 555a73db424d0735
  show-user: fbb27685a132cb69
  examples: b950b8c09ad458a7
  update-user: 805dc74451d8738d
  params: 15c193ddca37fa8f
  examples-2: e9afaedb540009cc
  deactivate-user: 75d7e0e3cc380ad4
  examples-3: d351f83d43eeb72e
  reactivate-user: 84a9f46e77805e23
  examples-4: 2d4aa4ea41a2b0f7
  redact-user: c113278512836fa0
  examples-5: ebbf695fa20060a7
  delete-user: 27b665c9c579a2d3
  examples-6: 045e0022fb5c8d64
  sso-profile-sync-settings: 782bb5ab08251406
title_source: 370e81eb20eece44
title_generated: 5d358a05b258cb17
---

<!-- translation-section: introduction -->

# Документація серверного API Loomio

<!-- seo-description: Використовуйте серверний API Loomio, щоб керувати обліковими записами користувачів у власному розгортанні Loomio. -->

`/api/b3` призначено для операцій на рівні сервера. Для дій від імені користувача Loomio використовуйте `/api/b2`.

<!-- translation-section: authentication -->

## Автентифікація

Задайте для `B3_API_KEY` секретне значення завдовжки понад 16 символів.

Передавайте ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Передавайте облікові дані лише в заголовку `Authorization`. API-ключі в рядку запиту або тілі запиту відхиляються.

<!-- translation-section: user-object -->

## Об’єкт користувача

Відповіді з даними користувача мають таку структуру:

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

## Список користувачів

Отримайте список усіх облікових записів користувачів у цьому розгортанні Loomio.

`GET /api/b3/users`

<!-- translation-section: example -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Відповідь:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Перегляд користувача

Знайдіть користувача за його ідентифікатором у Loomio або зовнішнім ідентифікатором.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Приклади

За ідентифікатором користувача в Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

За зовнішнім ідентифікатором:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Відповідь:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Оновлення користувача

Оновіть поля профілю користувача, знайденого за ідентифікатором у Loomio або зовнішнім ідентифікатором.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Параметри

| Поле | Опис |
| --- | --- |
| `name` | Відображуване ім’я |
| `username` | Ім’я користувача Loomio |
| `email` | Адреса електронної пошти |

<!-- translation-section: examples-2 -->

### Приклади

За ідентифікатором користувача в Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

За зовнішнім ідентифікатором:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Відповідь містить оновлені дані користувача:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Деактивація користувача

Деактивуйте обліковий запис користувача, знайдений за ідентифікатором у Loomio або зовнішнім ідентифікатором.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Приклади

За ідентифікатором користувача в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

За зовнішнім ідентифікатором:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Відповідь:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Повторна активація користувача

Повторно активуйте деактивований обліковий запис користувача, знайдений за ідентифікатором у Loomio або зовнішнім ідентифікатором.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Приклади

За ідентифікатором користувача в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

За зовнішнім ідентифікатором:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Відповідь:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Видалення персональних даних користувача

Під час видалення персональних даних коментарі користувача та інший створений ним вміст залишаються в його групах. Водночас видаляються відомі дані, за якими можна встановити особу: ім’я, біографія, фото профілю, адреса електронної пошти, облікові дані для входу, ідентифікатори та активні сеанси.

Це рекомендований спосіб вилучити користувача з Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Приклади

За ідентифікатором користувача в Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

За зовнішнім ідентифікатором:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Відповідь:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Видалення користувача

Видалення прибирає користувача та створені ним записи. Коментарі видаляються з тем, голоси — з опитувань. Групи, обговорення, опитування та інші створені користувачем записи також можуть бути видалені через зв’язки в базі даних.

Це призводить до значної втрати даних. Натомість наполегливо рекомендуємо знеособити користувача.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Приклади

За ідентифікатором користувача в Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

За зовнішнім ідентифікатором:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Відповідь:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Налаштування синхронізації профілю через SSO

Використовуйте ці налаштування, якщо полями профілю Loomio керує інша система.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` забороняє користувачам самостійно редагувати такі поля:

| Поле | Примітки |
| --- | --- |
| `name` | Керується зовнішньою синхронізацією |
| `username` | Керується зовнішньою синхронізацією |
| `email` | Керується зовнішньою синхронізацією |
| `avatar_kind` / `uploaded_avatar` | Керується зовнішньою синхронізацією |

Користувачі й далі можуть редагувати локальні поля Loomio, як-от `short_bio` і `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` оновлює `name` і `email` за даними входу через SSO. Якщо ці поля має оновлювати лише зовнішній скрипт синхронізації, залиште цей параметр закоментованим або не задавайте його.

`LOOMIO_SSO_FORCE_USER_ATTRS` і далі працює в наявних інсталяціях. Він забороняє користувачам редагувати ці поля та оновлює `name` і `email` під час входу через SSO.
