---
title: Серверний API
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 8b28f9c34e3f7575
  authentication: cbabcc874f053455
  user-object: 7e9e8ff3e48a4055
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
  provisioning: 590e1f295602247d
generated:
  introduction: 8e90f0228a4d0ad5
  authentication: a72b817353d24a37
  user-object: f748baf22fd77caf
  list-users: af6d795943ec947b
  example: 4200161184dc5a59
  show-user: f0138fc49ffb6192
  examples: 9c9c9e8caa2c16de
  update-user: c11a743e47dd4472
  params: 15c193ddca37fa8f
  examples-2: 32ea0bc48b70e1f2
  deactivate-user: e99963c2aaca2bc9
  examples-3: f7060ff921976a1c
  reactivate-user: eef94151b6a80216
  examples-4: 173fd5ca620daef8
  redact-user: fd1b95739e0a3a16
  examples-5: 9147c9c4bce8d7e3
  delete-user: 7ac3bf2681314fb2
  examples-6: 6c1e1d366b9d8bdf
  sso-profile-sync-settings: 895f8ad336537ba3
  provisioning: 9ce0906c063531d2
title_source: 370e81eb20eece44
title_generated: 5d358a05b258cb17
---

<!-- translation-section: introduction -->

# Документація серверного API Loomio

<!-- seo-description: Використовуйте серверний API Loomio для створення облікових записів користувачів, пошуку груп і керування участю в групах у Loomio на власному сервері. -->

`/api/b3` призначений для операцій на рівні сервера. Використовуйте `/api/b2` для дій від імені облікового запису користувача Loomio.

Використовуйте один серверний ключ для створення облікових записів і керування ними, пошуку груп у всьому екземплярі Loomio та керування участю в цих групах і ролями учасників. Обліковий запис бота, ключ API користувача або участь у групах не потрібні. Ключі API користувачів і надалі діють відповідно до дозволів користувача в групах.

<!-- translation-section: authentication -->

## Автентифікація

Задайте для `B3_API_KEY` секретне значення довжиною понад 16 символів.

Надсилайте ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Надсилайте облікові дані лише в заголовку `Authorization`. Ключі API в рядках запиту або тілах запитів відхиляються.

<!-- translation-section: provisioning -->

## Створення облікових записів і керування участю в групах

| Метод | Кінцева точка | Призначення |
| --- | --- | --- |
| `POST` | `/api/b3/users` | Створити обліковий запис |
| `GET` | `/api/b3/groups` | Знайти групи в усьому екземплярі Loomio |
| `GET` | `/api/b3/memberships` | Отримати список записів про участь у групі |
| `POST` | `/api/b3/memberships` | Запросити учасників або синхронізувати повний список учасників |
| `PATCH` | `/api/b3/memberships/:id` | Змінити ролі адміністратора групи та делегата |
| `DELETE` | `/api/b3/memberships/:id` | Припинити участь одного учасника |

Наявні кінцеві точки для оновлення, деактивації, повторної активації, знеособлення та видалення облікових записів описано нижче.

### Створення облікового запису

`POST /api/b3/users`

Надішліть об’єкт `user` з обов’язковим полем `email`. Пробіли на початку та в кінці адрес електронної пошти видаляються, а літери перетворюються на малі. Необов’язкові поля: `name`, `username` та `is_admin`. Тут `is_admin` означає адміністратора екземпляра Loomio; ролі адміністраторів груп задаються в записах про участь у групах. Не вказуйте `username`, щоб згенерувати ім’я користувача автоматично. Невідомі поля відхиляються.

```bash
curl https://loomio.example.org/api/b3/users \
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

У відповідь повертається HTTP `201` з об’єктом `user`. Некоректні поля або адреса електронної пошти чи ім’я користувача, які вже використовуються, спричиняють відповідь HTTP `422`. Створення облікового запису не надсилає запрошення, не виконує вхід користувача й не позначає його адресу електронної пошти як підтверджену. Запросіть користувача до групи через кінцеву точку керування участю в групах, щоб надіслати запрошення через звичайний механізм сповіщень.

### Пошук груп

`GET /api/b3/groups`

Отримайте список усіх невидалених груп, зокрема приватних груп і груп із простроченими передплатами. Результати впорядковано за зростанням ID. Використовуйте `limit` (типове та максимальне значення — `50`) і `offset` (типове значення — `0`) для посторінкового перегляду.

```bash
curl 'https://loomio.example.org/api/b3/groups?limit=50&offset=0' \
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

### Отримання списку записів про участь у групі

`GET /api/b3/memberships?group_id=123`

Поле `group_id` є обов’язковим. Результати містять записи про підтверджену участь і запрошення, що очікують прийняття, упорядковані за зростанням ID запису про участь. Записи про припинену участь не включаються. Використовуйте `limit` (типове та максимальне значення — `50`) і `offset` (типове значення — `0`) для посторінкового перегляду.

```bash
curl 'https://loomio.example.org/api/b3/memberships?group_id=123&limit=50&offset=0' \
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

`admin` і `delegate` — це ролі в групі. `accepted_at` — часова позначка прийняття запрошення або `null`, поки запрошення очікує прийняття. Ця кінцева точка не розкриває токенів запрошень, облікових даних для входу або голосів.

### Запрошення або синхронізація учасників

`POST /api/b3/memberships`

Надішліть обов’язкові поля `group_id` і масив `emails`. Типово це додає перелічених людей, які ще не мають активної участі в групі, та залишає всіх інших учасників у групі. Пробіли на початку та в кінці адрес електронної пошти видаляються, літери перетворюються на малі, а дублікати адрес вилучаються. Для нових адрес створюються облікові записи та запрошення, що очікують прийняття. Наявні підтверджені учасники іншої активної групи в тій самій організації приймаються автоматично, як і під час запрошення через API користувача.

```bash
curl https://loomio.example.org/api/b3/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

Щоб синхронізувати повний список учасників, явно встановіть `remove_absent` у `true`. Усі, кого немає в списку, вилучаються з цієї групи та її підгруп. Порожній масив із `remove_absent: true` вилучає всіх, зокрема адміністраторів групи. Не вказуйте `remove_absent` або встановіть його у `false`, якщо ви лише додаєте людей. Застарілі значення `1` і `0` також приймаються.

```bash
curl https://loomio.example.org/api/b3/memberships \
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

Повторення того самого запиту не створює дублікатів записів про участь і не надсилає повторних запрошень. Повторне запрошення вилученого учасника відновлює його доступ до групи без відновлення попередньої ролі адміністратора. Нові запрошення та зміни ролей використовують звичайний механізм сповіщень, при цьому жоден користувач не записується як виконавець дії.

Відсутні або неправильно сформовані списки адрес електронної пошти та некоректні булеві значення спричиняють відповідь HTTP `400`. Якщо в списку є деактивований обліковий запис, повертається HTTP `422`; перед додаванням явно активуйте його повторно. Некоректні дані облікового запису, обмеження передплати або інші помилки скасовують усю синхронізацію, зокрема створення нових облікових записів і вилучення учасників. Додавання потребує активної групи й підпорядковується обмеженням передплати щодо кількості учасників.

### Оновлення ролей учасника групи

`PATCH /api/b3/memberships/:id`

Надішліть об’єкт `membership`, що містить одне або обидва булеві поля `admin` і `delegate`. Невказані ролі залишаються без змін. Невідомі поля відхиляються; ця кінцева точка не дозволяє перенести участь, прийняти запрошення або змінити вагу голосів.

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

Повертається об’єкт `membership` із тими самими полями, що й у записі про участь зі списку. Надання ролі створює звичайне сповіщення про роль; повторне надсилання незміненої ролі не спричиняє повторного сповіщення. Зміни ролей потребують активної групи. Для записів про припинену участь повертається HTTP `404`.

### Припинення участі одного учасника

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Повертається `{"success": true}`. Вилучення скасовує доступ до групи та її підгруп, зокрема доступ до тем і право голосувати в активних опитуваннях. Воно не видаляє обліковий запис, не змінює інші групи й не скасовує прямий доступ до тем. Повторне вилучення завершується успішно. Ви можете припиняти участь у групах із простроченими передплатами; для видалених груп повертається HTTP `404`.

<!-- translation-section: user-object -->

## Об’єкт користувача

Відповіді з даними користувача мають таку структуру:

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

## Список користувачів

Отримайте список усіх облікових записів користувачів у цій інсталяції Loomio.

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

Знайдіть користувача за його ідентифікатором у Loomio або зовнішніми ідентифікаційними даними.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

За зовнішніми ідентифікаційними даними:

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

Оновіть поля профілю користувача, знайденого за його ідентифікатором у Loomio або зовнішніми ідентифікаційними даними.

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

За ідентифікатором користувача Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

За зовнішніми ідентифікаційними даними:

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

Деактивуйте обліковий запис користувача, знайдений за його ідентифікатором у Loomio або зовнішніми ідентифікаційними даними.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

За зовнішніми ідентифікаційними даними:

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

Повторно активуйте деактивований обліковий запис користувача, знайдений за його ідентифікатором користувача Loomio або зовнішнім ідентифікатором.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

За зовнішнім ідентифікатором:

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

Знеособлення зберігає коментарі користувача та інший створений ним вміст у його групах, але видаляє відомі дані, що дають змогу ідентифікувати особу, як-от ім’я, біографію, фото профілю, адресу електронної пошти, облікові дані для входу, зовнішні ідентифікатори та активні сеанси.

Це рекомендований спосіб видалення користувача з Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

За зовнішнім ідентифікатором:

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

Ця операція призводить до значної втрати даних. Наполегливо рекомендуємо натомість використовувати знеособлення.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

За зовнішнім ідентифікатором:

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

## Налаштування синхронізації профілю через SSO

Використовуйте ці налаштування, коли інша система керує полями профілю Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` забороняє користувачам самостійно редагувати ці поля:

| Поле | Примітки |
| --- | --- |
| `name` | Керується зовнішньою синхронізацією |
| `username` | Керується зовнішньою синхронізацією |
| `email` | Керується зовнішньою синхронізацією |
| `avatar_kind` / `uploaded_avatar` | Керується зовнішньою синхронізацією |

Користувачі й надалі можуть редагувати локальні поля Loomio, як-от `short_bio` та `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` оновлює `name` та `email` на основі даних входу через SSO. Залиште цей параметр закоментованим або не задавайте його, якщо скрипт зовнішньої синхронізації має бути єдиним джерелом цих оновлень.

`LOOMIO_SSO_FORCE_USER_ATTRS` і надалі працює в наявних інсталяціях. Він одночасно забороняє користувачам редагувати поля та оновлює `name` і `email` під час входу через SSO.
