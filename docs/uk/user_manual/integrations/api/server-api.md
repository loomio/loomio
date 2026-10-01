---
title: Серверний API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: 51988570631ad24b
  authentication: a72b817353d24a37
  user-object: 221a852684ddd91a
  list-users: 3f93c1cb4de11f00
  example: 4200161184dc5a59
  show-user: d27c59bc5081f995
  examples: f56345987ca0b37e
  update-user: 229dbae693e8eb99
  params: 3d7aece7119cf2f9
  examples-2: 942749d5e165ed14
  deactivate-user: 95741cd2810de072
  examples-3: 14ff17adc9b9f9de
  reactivate-user: 44f39c25b461cb39
  examples-4: 4190849bcc3e6574
  redact-user: 8b73a62a1962dc98
  examples-5: bac87be19c56ee51
  delete-user: 73688b53b26b3f16
  examples-6: d2d96e03f5f7e01d
  sso-profile-sync-settings: b432d9ec52e23a57
title_source: 370e81eb20eece44
title_generated: 5d358a05b258cb17
---

<!-- translation-section: introduction -->

# Документація серверного API Loomio

<!-- seo-description: Використовуйте серверний API Loomio для керування обліковими записами користувачів у Loomio на власному сервері. -->

`/api/b3` призначений для операцій на рівні сервера. Використовуйте `/api/b2` для дій від імені облікового запису користувача Loomio.

<!-- translation-section: authentication -->

## Автентифікація

Задайте для `B3_API_KEY` секретне значення довжиною понад 16 символів.

Надсилайте ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Надсилайте облікові дані лише в заголовку `Authorization`. Ключі API в рядках запиту або тілах запитів відхиляються.

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

Отримайте список усіх облікових записів користувачів у вашій інсталяції Loomio.

`GET /api/b3/users`

<!-- translation-section: example -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Повертає:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Перегляд користувача

Знайдіть користувача за його ідентифікатором користувача Loomio або зовнішньою ідентичністю.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

За зовнішньою ідентичністю:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Повертає:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Оновлення користувача

Оновіть поля профілю користувача, знайденого за його ідентифікатором користувача Loomio або зовнішньою ідентичністю.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Параметри

| Поле | Опис |
| --- | --- |
| `name` | Ім’я для відображення |
| `username` | Ім’я користувача Loomio |
| `email` | Адреса електронної пошти |

<!-- translation-section: examples-2 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

За зовнішньою ідентичністю:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Повертає оновлені дані користувача:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Деактивація користувача

Деактивуйте обліковий запис користувача, знайдений за його ідентифікатором користувача Loomio або зовнішньою ідентичністю.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

За зовнішньою ідентичністю:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Повертає:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Повторна активація користувача

Повторно активуйте деактивований обліковий запис користувача, знайдений за ідентифікатором користувача Loomio або зовнішньою ідентичністю.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

За зовнішньою ідентичністю:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Повертає:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Знеособлення користувача

Знеособлення зберігає коментарі користувача та інший створений ним вміст у його групах, але видаляє відомі дані, що дозволяють ідентифікувати особу, як-от ім’я, біографію, фото профілю, адресу електронної пошти, облікові дані для входу, ідентичності та активні сеанси.

Це рекомендований спосіб видалення користувача з Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

За зовнішньою ідентичністю:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Повертає:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Видалення користувача

Видалення прибирає користувача та створені ним записи. Коментарі видаляються з тем, голоси — з опитувань, а групи, обговорення, опитування та інші записи, створені користувачем, також можуть бути видалені через зв’язки в базі даних.

Ця дія призводить до значної втрати даних. Натомість наполегливо рекомендується знеособлення.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

За зовнішньою ідентичністю:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Повертає:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Налаштування синхронізації профілю SSO

Використовуйте ці налаштування, коли інша система керує полями профілю Loomio.

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

Користувачі й надалі можуть редагувати локальні поля Loomio, як-от `short_bio` та `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` оновлює `name` та `email` із даних входу через SSO. Залиште цей параметр закоментованим або не задавайте його, якщо зовнішній скрипт синхронізації має бути єдиним джерелом цих оновлень.

`LOOMIO_SSO_FORCE_USER_ATTRS` і надалі працює в наявних інсталяціях. Він одночасно забороняє користувачам редагування та оновлює `name` і `email` під час входу через SSO.
