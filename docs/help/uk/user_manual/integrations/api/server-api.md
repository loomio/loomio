---
title: Серверний API
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
  introduction: 0bb4cfe96c40b199
  authentication: 2af70c829f9713be
  user-object: f748baf22fd77caf
  list-users: 78f2a66993fba747
  example: 85e726b4f61a566e
  show-user: 940022e884e8c388
  examples: aa5a8b547bcb499c
  update-user: 93eab9e0e20d6d65
  params: 15c193ddca37fa8f
  examples-2: 895c6589f35804da
  deactivate-user: e19633356c13850b
  examples-3: 4a854fd3288da799
  reactivate-user: 59cb271f58120bcf
  examples-4: 5ff6feded4b39332
  redact-user: ab842b5cbb9c9efc
  examples-5: a03b1b947966f2a5
  delete-user: aecdafc2cd13a0d7
  examples-6: 4c54386cd23fbc6a
  sso-profile-sync-settings: 895f8ad336537ba3
  provisioning: a30516de0ab3491b
title_source: 370e81eb20eece44
title_generated: 5d358a05b258cb17
---

<!-- translation-section: introduction -->

# Документація серверного API Loomio

<!-- seo-description: Використовуйте серверний API Loomio для створення облікових записів користувачів, пошуку груп і керування участю в групах у Loomio на власному сервері. -->

`/api/server0` призначений для операцій на рівні сервера. Використовуйте `/api/user0` для дій від імені облікового запису користувача Loomio.

Використовуйте один серверний ключ для створення облікових записів і керування ними, пошуку груп у всьому екземплярі Loomio та керування участю в цих групах і ролями учасників. Обліковий запис бота, ключ API користувача або участь у групах не потрібні. Ключі API користувачів і надалі діють відповідно до дозволів користувача в групах.

<!-- translation-section: authentication -->

## Автентифікація

Ключ задається налаштуванням `SERVER_API_KEY` у середовищі сервера. `create_env.sh` генерує його для нових інсталяцій.

Надсилайте ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Надсилайте облікові дані лише в заголовку `Authorization`. Ключі API в рядках запиту або тілах запитів відхиляються.

<!-- translation-section: provisioning -->

## Створення облікових записів і керування участю в групах

| Метод | Кінцева точка | Призначення |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Створити обліковий запис |
| `GET` | `/api/server0/groups` | Знайти групи в усьому екземплярі Loomio |
| `GET` | `/api/server0/memberships` | Отримати список записів про участь у групі |
| `POST` | `/api/server0/memberships` | Запросити учасників або синхронізувати повний список учасників |
| `PATCH` | `/api/server0/memberships/:id` | Змінити ролі адміністратора групи та делегата |
| `DELETE` | `/api/server0/memberships/:id` | Припинити участь одного учасника |

Наявні кінцеві точки для оновлення, деактивації, повторної активації, знеособлення та видалення облікових записів описано нижче.

### Створення облікового запису

`POST /api/server0/users`

Надішліть об’єкт `user` з обов’язковим полем `email`. Пробіли на початку та в кінці адрес електронної пошти видаляються, а літери перетворюються на малі. Необов’язкові поля: `name`, `username` та `is_admin`. Тут `is_admin` означає адміністратора екземпляра Loomio; ролі адміністраторів груп задаються в записах про участь у групах. Не вказуйте `username`, щоб згенерувати ім’я користувача автоматично. Невідомі поля відхиляються.

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

У відповідь повертається HTTP `201` з об’єктом `user`. Некоректні поля або адреса електронної пошти чи ім’я користувача, які вже використовуються, спричиняють відповідь HTTP `422`. Створення облікового запису не надсилає запрошення, не виконує вхід користувача й не позначає його адресу електронної пошти як підтверджену. Запросіть користувача до групи через кінцеву точку керування участю в групах, щоб надіслати запрошення через звичайний механізм сповіщень.

### Пошук груп

`GET /api/server0/groups`

Отримайте список усіх невидалених груп, зокрема приватних груп і груп із простроченими передплатами. Результати впорядковано за зростанням ID. Використовуйте `limit` (типове та максимальне значення — `50`) і `offset` (типове значення — `0`) для посторінкового перегляду.

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

### Отримання списку записів про участь у групі

`GET /api/server0/memberships?group_id=123`

Поле `group_id` є обов’язковим. Результати містять записи про підтверджену участь і запрошення, що очікують прийняття, упорядковані за зростанням ID запису про участь. Записи про припинену участь не включаються. Використовуйте `limit` (типове та максимальне значення — `50`) і `offset` (типове значення — `0`) для посторінкового перегляду.

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

`admin` і `delegate` — це ролі в групі. `accepted_at` — часова позначка прийняття запрошення або `null`, поки запрошення очікує прийняття. Ця кінцева точка не розкриває токенів запрошень, облікових даних для входу або голосів.

### Запрошення або синхронізація учасників

`POST /api/server0/memberships`

Надішліть обов’язкове поле `group_id` і масив `emails`. Типово це додає перелічених людей, які ще не мають активної участі в групі, та залишає всіх інших учасників у групі. Пробіли на початку та в кінці адрес електронної пошти видаляються, літери перетворюються на малі, а дублікати адрес вилучаються. Для нових адрес створюються облікові записи та запрошення, що очікують прийняття. Наявні підтверджені учасники іншої активної групи в тій самій організації приймаються автоматично, як і під час запрошення через API користувача.

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

Щоб синхронізувати повний список учасників, явно встановіть `remove_absent` у `true`. Усі, кого немає в списку, вилучаються з цієї групи та її підгруп. Порожній масив із `remove_absent: true` вилучає всіх, зокрема адміністраторів групи. Не вказуйте `remove_absent` або встановіть його у `false`, якщо ви лише додаєте людей. Застарілі значення `1` і `0` також приймаються.

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

Повторення того самого запиту не створює дублікатів записів про участь і не надсилає повторних запрошень. Повторне запрошення вилученого учасника відновлює його доступ до групи без відновлення попередньої ролі адміністратора. Нові запрошення та зміни ролей використовують звичайний механізм сповіщень, при цьому жоден користувач не записується як виконавець дії.

Відсутні або неправильно сформовані списки адрес електронної пошти та некоректні булеві значення спричиняють відповідь HTTP `400`. Якщо в списку є деактивований обліковий запис, повертається HTTP `422`; перед додаванням явно активуйте його повторно. Некоректні дані облікового запису, обмеження передплати або інші помилки скасовують усю синхронізацію, зокрема створення нових облікових записів і вилучення учасників. Додавання потребує активної групи й підпорядковується обмеженням передплати щодо кількості учасників.

### Оновлення ролей учасника групи

`PATCH /api/server0/memberships/:id`

Надішліть об’єкт `membership`, що містить одне або обидва булеві поля `admin` і `delegate`. Невказані ролі залишаються без змін. Невідомі поля відхиляються; ця кінцева точка не дозволяє перенести участь, прийняти запрошення або змінити вагу голосів.

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

Повертається об’єкт `membership` із тими самими полями, що й у записі про участь зі списку. Надання ролі створює звичайне сповіщення про роль; повторне надсилання незміненої ролі не спричиняє повторного сповіщення. Зміни ролей потребують активної групи. Для записів про припинену участь повертається HTTP `404`.

### Припинення участі одного учасника

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Повертається `{"success": true}`. Вилучення скасовує доступ до групи та її підгруп, зокрема доступ до тем і право голосувати в активних опитуваннях. Воно не видаляє обліковий запис, не змінює інші групи й не скасовує прямий доступ до тем. Повторне вилучення завершується успішно. ви можете припиняти участь у групах із простроченими передплатами; для видалених груп повертається HTTP `404`.

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

`GET /api/server0/users`

<!-- translation-section: example -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
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

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

За зовнішніми ідентифікаційними даними:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/server0/users/123
```

За зовнішніми ідентифікаційними даними:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

За зовнішніми ідентифікаційними даними:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
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

Повторно активуйте деактивований обліковий запис користувача, знайдений за його ідентифікатором користувача Loomio або зовнішніми ідентифікаційними даними.

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

За зовнішнім ідентифікатором:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
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

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

За зовнішнім ідентифікатором:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
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

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Приклади

За ідентифікатором користувача Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

За зовнішнім ідентифікатором:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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
