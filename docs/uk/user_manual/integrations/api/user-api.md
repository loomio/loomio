---
title: Користувацький API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: a0e13b58e4c3b8fa
  authentication-change: 23644b95dd7651bb
  response-size-and-related-records: 62693e524331b00e
  endpoint-summary: 771f479507769e36
  groups: 29fb3c5431af0d9d
  list-groups: db8d264d23898a3f
  get-a-group: c948675d4e014c18
  webhooks: 111047c05c8290bb
  list-webhooks: 0050654ead387ec0
  create-a-webhook: 53f31e99aaee8c5e
  update-a-webhook: 6a9a535cc666280f
  test-a-webhook-destination: 718dd1c5b0e9c96c
  delete-a-webhook: f956cb69b7d11aff
  event-types: 4f6d118ab568411e
  http-delivery: 3a820e9058ab4e79
  payload-formats: f7a11f663275e376
  search: b306d9ce068e0767
  params: 060c4213c8144076
  participation-report: 0ca6f32512a6ad49
  params-2: 110330c5e2e021fe
  example: cc8764dcc83c6241
  create-discussion: fac4917ed0edae2d
  params-3: f4f7913982c74a9b
  example-2: d3afd8b07cafbafe
  show-discussion: 81e354b9dac1e685
  example-3: 9b708f2964d9bea2
  list-discussions: 5270a91e52db8db5
  params-4: 4cbfc64f535f9a31
  example-4: 85f44b4bda657252
  list-threads: '09d3c13328dcc1e5'
  params-5: 17492331bcb533de
  example-5: 7ed12262f8d98d97
  read-thread: e9c2ad6f979a746d
  example-6: 1fb5f064047e7404
  edit-discussion: 11664a4cd5281aaa
  params-6: 825b8f634ad161bc
  example-7: 89938affb558be23
  soft-delete-discussion: 574ecbe40f629570
  example-8: 8fe131ccb65bb461
  create-comment: be9141b2a553b756
  params-7: f6d076a4f63be951
  example-9: fdaf15c97794e960
  edit-comment: 1e703f0af0ed4f04
  params-8: 44c4ec0b260bee55
  example-10: 7ad2fd7a50b709cd
  soft-delete-comment: 8601be0519432a72
  example-11: 5e9fb439ca500e87
  create-poll: bde585d61d6dcadd
  params-9: 60c9456eae03d8d7
  example-12: 2e0bdb9ca131e97a
  show-poll: 9f3a07a466da4b2c
  example-13: f36e6ce9144d7f70
  list-polls: 70b7d8260846b927
  params-10: 264ec60f3e1e4179
  example-14: b533bef0bd397e43
  edit-poll: c93b0986916e3ec8
  params-11: abecf8e4b1fc42cc
  example-15: a7a58418b09f9bc3
  soft-delete-poll: eb284069a6df0f19
  example-16: 18314b5c12a8a769
  list-memberships: 38ace856fb49ee5a
  params-12: af55acc8fa8af30e
  example-17: 57678f757f3de503
  manage-memberships: '09115ca306d1c737'
  params-13: b5b4336014259380
  example-18: 2cb8f19018e06130
title_source: c23fb6526b722360
title_generated: a8877cdee7d58933
needs_review:
  params: use "висновок" instead of "результат" for "outcome"
  params-9: use "Погоджуюся" instead of "За" for "agree"
  list-polls: use "висновок" instead of "рішення" for "outcome"
---

<!-- translation-section: introduction -->

# Документація користувацького API Loomio

<!-- seo-description: Використовуйте користувацький API Loomio, щоб створювати обговорення, коментарі, опитування, теми та керувати ними й участю в групах з іншого програмного забезпечення. -->

`/api/b2` — це API для інтеграцій із Loomio, орієнтований на користувачів. Він використовує API-ключ облікового запису користувача, і кожна дія виконується від імені цього користувача.

Операції з групами використовують участь у групах і права доступу користувача, якому належить API-ключ. Статус адміністратора екземпляра не розширює доступ API-ключа до груп або вмісту; для адміністрування на рівні екземпляра використовуйте серверний API.

Використовуйте API-ключ облікового запису Loomio, від імені якого виконуватимуться дії. Окремий обліковий запис бота корисний, коли інтеграція не повинна отримувати запрошення до опитувань або сповіщення.

Користувачі, які ввійшли в систему, можуть знайти свій API-ключ та ідентифікатори груп на [сторінці доступу до API](/profile/api_access).

Надсилайте API-ключ у заголовку `Authorization: Bearer`. API-ключі в рядках запиту відхиляються, оскільки URL-адреси можуть записуватися проксі-серверами та журналами доступу.

<!-- translation-section: authentication-change -->

### Зміна автентифікації

Раніше API-ключ приймався як параметр URL `api_key`. Запити з `?api_key=YOUR_API_KEY` більше не працюють. Натомість використовуйте HTTP-заголовок `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

У прикладах використано `YOUR_API_KEY`, ідентифікатор групи `123` та `https://www.loomio.com/`. Замініть їх своїм API-ключем, ідентифікатором групи та URL-адресою вашого встановлення Loomio.

<!-- translation-section: response-size-and-related-records -->

## Розмір відповіді та пов’язані записи

Відповіді користувацького API мають складений формат: основні записи супроводжуються пов’язаними записами, як-от теми, групи, користувачі, опитування та реакції. Це дає змогу клієнту заповнити локальне сховище записів одним запитом, але відповідь може містити більше даних, ніж потрібно простій інтеграції.

Передайте `compact=1`, щоб не включати об’ємні пов’язані записи тем, груп, батьківських груп, участі в групах, реакцій, тегів і перекладів. Основні записи та пов’язані записи, потрібні для розуміння їхнього вмісту, залишаються у відповіді.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Для безпосереднього керування передайте `exclude_types` із типами записів в однині, розділеними пробілами. Наприклад, `exclude_types=group reaction` виключає пов’язані групи та реакції. Поширені значення: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` та `topic_item`. Виключення застосовуються до пов’язаних записів, а не до основного ресурсу, запитаного через кінцеву точку.

Відповіді з колекціями містять `meta.total`, коли визначено точний розмір колекції. Загальна кількість обчислюється до застосування `limit` та `offset`. Кінцеві точки, як-от пошук, які навмисно повертають обмежений набір результатів, не включають `meta.total`, а не повертають `null`.

<!-- translation-section: endpoint-summary -->

## Огляд кінцевих точок

| Метод | Кінцева точка | Призначення |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Отримати список груп користувача, якому належить API-ключ |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Отримати доступну групу |
| `GET` | `/api/b2/reports` | Створити звіт про участь |
| `GET` | `/api/b2/search` | Знайти доступні обговорення, коментарі, опитування, голоси та висновки |
| `POST` | `/api/b2/discussions` | Створити обговорення |
| `GET` | `/api/b2/discussions/:id` | Отримати обговорення |
| `GET` | `/api/b2/discussions` | Отримати список обговорень у групі |
| `PATCH` | `/api/b2/discussions/:id` | Редагувати обговорення |
| `DELETE` | `/api/b2/discussions/:id` | Видалити обговорення зі збереженням запису |
| `GET` | `/api/b2/threads` | Отримати список доступних тем з обговореннями та окремими опитуваннями |
| `GET` | `/api/b2/threads/:topic_id` | Отримати тему |
| `GET` | `/api/b2/threads/:topic_id/items` | Отримати впорядковані елементи теми |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Отримати повну тему у форматі Markdown |
| `POST` | `/api/b2/comments` | Створити коментар або відповідь |
| `PATCH` | `/api/b2/comments/:id` | Редагувати коментар |
| `DELETE` | `/api/b2/comments/:id` | Видалити коментар зі збереженням запису |
| `POST` | `/api/b2/polls` | Створити опитування |
| `GET` | `/api/b2/polls/:id` | Отримати опитування |
| `GET` | `/api/b2/polls` | Отримати список опитувань у групі |
| `PATCH` | `/api/b2/polls/:id` | Редагувати опитування |
| `DELETE` | `/api/b2/polls/:id` | Видалити опитування зі збереженням запису |
| `GET` | `/api/b2/memberships` | Отримати список записів участі в групі |
| `POST` | `/api/b2/memberships` | Додати учасників і за потреби вилучити учасників, яких немає в списку |
| `GET` | `/api/b2/chatbots` | Отримати список інтеграцій чату та вебхуків групи |
| `POST` | `/api/b2/chatbots` | Створити інтеграцію чату або вебхук |
| `PATCH` | `/api/b2/chatbots/:id` | Оновити інтеграцію чату або вебхук |
| `DELETE` | `/api/b2/chatbots/:id` | Видалити інтеграцію чату або вебхук |
| `POST` | `/api/b2/chatbots/check` | Надіслати тестовий запит для перевірки підключення вебхука |

<!-- translation-section: groups -->

## Групи

<!-- translation-section: list-groups -->

### Список груп

Повертає групи, у яких користувач, якому належить API-ключ, має активну участь.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Відповідь містить усі відповідні записи в масиві `groups` без поділу на сторінки. До нього входять батьківські групи та підгрупи, зокрема групи, підписка яких наразі неактивна. Перевіряйте поле `enabled`, якщо інтеграція повинна працювати лише з увімкненими групами.

Основні поля групи:

| Поле | Опис |
| --- | --- |
| `id` | Числовий ідентифікатор групи, який використовують інші кінцеві точки користувацького API |
| `key` | Стабільний короткий ключ, який використовується в URL-адресах Loomio |
| `handle` | Зрозумілий людині псевдонім групи |
| `name` | Назва групи |
| `full_name` | Назва групи з урахуванням її батьківської групи |
| `parent_id` | Числовий ідентифікатор батьківської групи для підгрупи, інакше `null` |
| `enabled` | Чи активні група та її підписка |
| `memberships_count` | Кількість активних записів участі та записів, що очікують підтвердження |
| `accepted_memberships_count` | Кількість підтверджених записів участі |
| `pending_memberships_count` | Кількість запрошень, що очікують прийняття |
| `admin_memberships_count` | Кількість адміністраторів групи |
| `delegates_count` | Кількість делегатів |
| `discussions_count` | Кількість обговорень безпосередньо в групі |
| `polls_count` | Кількість опитувань безпосередньо в групі |
| `subgroups_count` | Кількість підгруп |

Відповідь може містити додаткові налаштування групи, пов’язані записи батьківських груп і записи участі користувача API в групах. Клієнти мають ігнорувати поля, які вони не використовують.

<!-- translation-section: get-a-group -->

### Отримання групи

Повертає одну групу, доступну користувачу, якому належить API-ключ.

`GET /api/b2/groups/:id_or_key_or_handle`

Ідентифікатором може бути числовий ідентифікатор, ключ або псевдонім групи.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Відповідь містить групу в масиві `groups` і використовує ті самі поля, що й кінцева точка списку. Запит групи, до якої користувач з API-ключем не має доступу, повертає помилку прав доступу.

<!-- translation-section: webhooks -->

## Вебхуки

Користувацький API працює на основі запитів: інтеграція звертається до Loomio, коли потрібно прочитати або змінити дані. Вебхук групи забезпечує надсилання даних у зворотному напрямку. Loomio надсилає вибрані події групи на вашу кінцеву точку, щойно вони відбуваються, тому інтеграції не потрібно періодично запитувати REST API про зміни.

Вебхуки налаштовуються окремо для кожної групи й потребують прав адміністратора групи. Ними можна керувати через інтерфейс Loomio:

1. Відкрийте групу.
2. Відкрийте меню групи й виберіть **Інтеграції чату**.
3. Додайте інтеграцію, що відповідає формату даних, який приймає ваша кінцева точка. Для кінцевої точки загального призначення використовуйте формат Mattermost/Markdown.
4. Введіть назву та URL призначення.
5. Виберіть події, які Loomio має надсилати автоматично.
6. Збережіть інтеграцію та скористайтеся **Тестове підключення**, щоб надіслати тестове повідомлення.

Використовуйте адресу призначення HTTPS з URL, який неможливо вгадати. Loomio вимагає, щоб адреса призначення визначалася як публічна адреса, і блокує запити до локальних або приватних мережевих адрес.

Агенти та інші інтеграції можуть натомість керувати вебхуками через описані нижче кінцеві точки чатботів з автентифікацією Bearer. Ресурс має назву `chatbots` для сумісності з інтеграціями чату Loomio, але також представляє вихідні вебхуки загального призначення.

<!-- translation-section: list-webhooks -->

### Список вебхуків

Повертає інтеграції чату, налаштовані для групи. Користувач, якому належить API-ключ, має бути адміністратором цієї групи. Відповідь містить URL-адреси призначення, тому її не можна розкривати звичайним учасникам групи.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Відповідь містить масив `chatbots` із такими полями:

| Поле | Опис |
| --- | --- |
| `id` | Ідентифікатор інтеграції для оновлення та видалення |
| `group_id` | Група, що отримує події |
| `name` | Назва інтеграції для адміністрування |
| `kind` | `webhook` для вихідного вебхука або `matrix` для інтеграції з Matrix |
| `webhook_kind` | Формат даних: `markdown`, `slack`, `discord`, `microsoft` або `webex` |
| `server` | URL-адреса призначення |
| `event_kinds` | Події, що надсилаються автоматично |
| `notification_only` | Чи містять повідомлення лише заголовок сповіщення |

<!-- translation-section: create-a-webhook -->

### Створення вебхука

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

Користувач, якому належить API-ключ, має бути адміністратором групи `group_id`. Перед збереженням перевіряється, чи є адреса призначення публічною URL-адресою.

<!-- translation-section: update-a-webhook -->

### Оновлення вебхука

`PATCH /api/b2/chatbots/:id`

Надішліть поля, які потрібно змінити. Вебхук не можна перенести до іншої групи, змінивши `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Перевірка адреси призначення вебхука

Надішліть тестове повідомлення, сумісне з Markdown, на адресу призначення до або після збереження її налаштувань.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Видалення вебхука

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Видалення конфігурації припиняє подальше надсилання повідомлень. Воно не видаляє жодного вмісту групи Loomio.

<!-- translation-section: event-types -->

### Типи подій

Вебхук може підписатися на такі типи подій:

| Подія | Коли надсилається |
| --- | --- |
| `new_discussion` | Розпочато обговорення |
| `discussion_edited` | Обговорення відредаговано |
| `new_comment` | Створено коментар |
| `poll_created` | Розпочато опитування |
| `poll_edited` | Опитування відредаговано |
| `poll_closing_soon` | Наближається час закриття опитування |
| `poll_expired` | Настав час закриття опитування |
| `poll_closed_by_user` | Людина закрила опитування вручну |
| `poll_reopened` | Опитування відкрито знову |
| `outcome_created` | Опубліковано висновок |
| `outcome_updated` | Висновок оновлено |
| `outcome_review_due` | Настав час перегляду висновку |
| `stance_created` | Подано голос |
| `stance_updated` | Голос змінено |

Вебхук належить одній групі й отримує події цієї групи, на які він підписаний. Люди також можуть явно вибрати інтеграцію, коли діляться вмістом або надсилають деякі сповіщення, навіть якщо відповідну автоматичну подію не вибрано.

<!-- translation-section: http-delivery -->

### Доставлення через HTTP

Loomio надсилає асинхронний HTTP-запит `POST` на налаштовану URL-адресу з таким заголовком:

```text
Content-Type: application/json; charset=utf-8
```

Час очікування відповіді на запит становить п’ять секунд. Відповідь `2xx`, зокрема `204 No Content`, вважається успішною. Сервіси, що отримують вебхуки, мають відповідати швидко, виконувати триваліші завдання асинхронно та коректно обробляти повторні повідомлення й повідомлення, доставлені не за порядком.

Наразі Loomio не додає підпис вебхука, заголовок зі спільним секретом, ідентифікатор події чи ідентифікатор доставлення. Ставтеся до повної URL-адреси призначення як до облікових даних, не розголошуйте її та додайте до неї токен, який неможливо вгадати, якщо сервіс-одержувач це підтримує. Якщо потрібна стабільна машиночитана схема подій або доставлення з підписом, використовуйте вебхук як сповіщення про зміни й отримуйте актуальні записи через користувацький API з автентифікацією.

<!-- translation-section: payload-formats -->

### Формати даних повідомлень

Дані вебхуків — це повідомлення, призначені для відображення в чат-сервісах. Вони не є повними серіалізованими записами Loomio. Посилання в повідомленні вказують на відповідний вміст Loomio; якщо інтеграції потрібні структуровані дані про поточний стан, вона може додатково звернутися до користувацького API.

| Формат інтеграції | Основні поля JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, обмежено приблизно 1 900 символами |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Наприклад, загальний формат Markdown надсилає тіло повідомлення такої структури:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Точний текст повідомлення залежить від події, локалі групи, налаштування надсилання лише заголовка сповіщення та версії Loomio. Сервіси-одержувачі мають використовувати задокументовані поля верхнього рівня вибраного формату, а не розбирати формулювання речень.

<!-- translation-section: search -->

## Пошук

Шукайте обговорення, коментарі, опитування, голоси та висновки, видимі користувачеві, якому належить API-ключ. Результати містять публічний вміст, навіть якщо користувач не є учасником відповідної групи; до приватного вмісту застосовуються звичайні правила видимості тем.

`GET /api/b2/search`

<!-- translation-section: params -->

### Параметри

| Назва | Опис |
| --- | --- |
| `query` | Текст для пошуку. Підтримуються точні та нечіткі збіги |
| `group_id` | Обмежте результати однією доступною групою |
| `org_id` | Обмежте результати доступною батьківською групою та її доступними підгрупами. Використовуйте `0` для прямих обговорень |
| `type` | Обмежте результати одним типом: `Discussion`, `Comment`, `Poll`, `Stance` або `Outcome` |
| `types` | Список типів результатів, розділених комами |
| `tag` | Обмежте результати темами з цим тегом |
| `author_id` | Обмежте результати вмістом одного автора. Без `query` повертає останню доступну активність цього автора |
| `order` | Установіть `authored_at_desc`, щоб упорядкувати знайдений вміст за часом його створення |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Відповідь містить масив `search_results`. Кожен результат визначає знайдений запис і його доступний контекст за допомогою полів, зокрема `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` і `tags`. Поля, які не стосуються певного результату, мають значення `null`.

<!-- translation-section: participation-report -->

## Звіт про участь

Повертає ті самі зведені дані про участь, які використовуються у звіті про участь Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `section` | Розділ звіту: `base`, `users` або `countries`. Використовуйте `users` для активності кожної людини окремо |
| `group_scope` | `custom` або `my`. Застаріле значення `all` трактується як `my`, оскільки ключі користувацького API ніколи не надають доступу до всього екземпляра Loomio |
| `group_ids` | Ідентифікатори груп, розділені комами, коли `group_scope=custom`. Ідентифікатори груп, до яких користувач API не належить, ігноруються |
| `start_month` | Перший місяць, який потрібно включити, у форматі `YYYY-MM`; за замовчуванням — місяць 12 місяців тому |
| `end_month` | Останній місяць, який потрібно включити, у форматі `YYYY-MM`; за замовчуванням — поточний місяць |
| `interval` | Інтервал для розділу `base`: `day`, `week`, `month` або `year` |
| `member_type` | Установіть `delegate` разом із `section=users`, щоб повернути лише поточних делегатів |

Людина є делегатом, якщо вона має активне членство з роллю делегата в будь-якій із вибраних груп. Її показники підсумовуються за всіма вибраними групами. Рядки делегатів повертаються, навіть якщо всі показники активності дорівнюють нулю. Показники охоплюють теми, коментарі, опитування, голоси, висновки та реакції; вони не є показниками участі в голосуванні. Рядки користувачів також містять кількість виданих, поданих і пропущених бюлетенів, пов’язаних з особою. Анонімні опитування виключено з усіх індивідуальних показників голосування. `all_votes_cast` має значення true лише тоді, коли видано принаймні один бюлетень і подано всі видані бюлетені.

API застосовує ті самі правила видимості груп, що й звіт у застосунку. API-ключ користувача не може розкрити дані звіту з груп, до яких цей користувач не має доступу.

<!-- translation-section: example -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Масив `users` містить рядки з повними даними про активність:

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

## Створення обговорення

Створіть обговорення від імені користувача, якому належить API-ключ.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Група, у якій буде тема |
| `title` | Назва теми, обов’язкова |
| `description` | Контекст теми, необов’язковий |
| `description_format` | `md` або `html`, необов’язковий, за замовчуванням `md` |
| `recipient_audience` | `group` або null. Якщо `group`, уся група отримає сповіщення про нову тему |
| `recipient_user_ids` | Масив ідентифікаторів користувачів, яких потрібно сповістити або запросити до теми |
| `recipient_emails` | Масив електронних адрес людей, яких потрібно запросити до теми |
| `recipient_message` | Повідомлення, яке потрібно включити до запрошення електронною поштою |

<!-- translation-section: example-2 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Отримання обговорення

Отримайте обговорення за його ідентифікатором (цілим числом) або ключем (рядком).

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Список обговорень

Отримайте список обговорень у групі, доступних користувачу, якому належить ключ API. Якщо група публічно доступна, користувач, який не є її учасником, може отримати список її публічних обговорень; приватні обговорення залишаються доступними лише користувачам, які можуть читати їх у Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове. Ідентифікатор групи, список обговорень якої потрібно отримати |
| `status` | Рядок, необов’язковий, типове значення — `open`. Значення: `open`, `closed`, `all` |
| `limit` | Ціле число, необов’язкове, типове значення — 50. Розмір сторінки |
| `offset` | Ціле число, необов’язкове, типове значення — 0. Зміщення для поділу на сторінки |

Застарілі параметри: `per` і `from` приймаються як альтернативні назви для `limit` і `offset` та працюватимуть і надалі.

<!-- translation-section: example-4 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Список тем

Отримайте список тем з обговореннями та опитуваннями, доступних користувачу, якому належить ключ API, упорядкований за останньою активністю. Ідентифікатор теми — це її `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `limit` | Ціле число, необов’язкове, типове значення — 50. Розмір сторінки |
| `offset` | Ціле число, необов’язкове, типове значення — 0. Зміщення для поділу на сторінки |

<!-- translation-section: example-5 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Читання теми

Прочитайте тему, її впорядковану послідовність подій або повний документ Markdown з її доступним вмістом.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Приклад

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Кінцева точка `items` повертає впорядковану послідовність подій, зокрема доступні коментарі, опитування, голоси та висновки. Кінцева точка `markdown` повертає весь доступний вміст теми як один документ Markdown. Причини, зазначені разом із голосами, включаються лише тоді, коли вони доступні користувачу, якому належить ключ API.

Усі кінцеві точки для тем застосовують ті самі права доступу, що й інтерфейс Loomio. Ключ API не надає доступу до теми, яку користувач зазвичай не може відкрити.

<!-- translation-section: edit-discussion -->

## Редагування обговорення

Відредагуйте обговорення від імені користувача, якому належить ключ API. Застосовуються ті самі права доступу, що й у Loomio: користувач повинен мати дозвіл на редагування цього обговорення.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `title` | Оновлений заголовок |
| `description` | Оновлений контекст |
| `description_format` | `md` або `html`, необов’язковий, типове значення — `md` |
| `recipient_audience` | `group` або null. Якщо `group`, уся група отримає сповіщення про редагування |
| `recipient_user_ids` | Масив ідентифікаторів користувачів, яких потрібно сповістити або запросити до теми |
| `recipient_emails` | Масив електронних адрес людей, яких потрібно запросити до теми |
| `recipient_message` | Повідомлення, яке потрібно додати до запрошення електронною поштою |

<!-- translation-section: example-7 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## М’яке видалення обговорення

Виконайте м’яке видалення обговорення від імені користувача, якому належить ключ API. Обговорення буде видалено, але його запис залишиться в базі даних.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Створення коментаря

Створіть коментар в обговоренні від імені користувача, якому належить ключ API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `discussion_id` | Ціле число, обов’язковий параметр. ID обговорення, до якого додається коментар |
| `body` | Текст коментаря, обов’язковий, якщо не надано вкладення |
| `body_format` | `md` або `html`, необов’язковий параметр, за замовчуванням `md` |

<!-- translation-section: example-9 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Редагування коментаря

Відредагуйте коментар від імені користувача, якому належить ключ API. Діють ті самі права доступу, що й у Loomio: користувач повинен мати дозвіл на редагування цього коментаря.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `body` | Оновлений текст коментаря |
| `body_format` | `md` або `html`, необов’язковий параметр, за замовчуванням `md` |

<!-- translation-section: example-10 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## М’яке видалення коментаря

Виконайте м’яке видалення коментаря від імені користувача, якому належить ключ API. Коментар буде видалено, його текст буде приховано, але запис коментаря залишиться в базі даних.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Створення опитування

Створіть опитування від імені користувача, якому належить ключ API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, необов’язкове, за замовчуванням null. ID групи для опитування. Якщо передано `discussion_id`, `group_id` ігнорується |
| `discussion_id` | Ціле число, необов’язкове, за замовчуванням null. ID теми обговорення, до якої потрібно додати це опитування |
| `title` | Рядок, обов’язковий. Назва опитування |
| `poll_type` | Рядок, обов’язковий. Значення: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Рядок, необов’язковий. Основний текст опитування |
| `details_format` | Рядок, необов’язковий, за замовчуванням `md`. Значення: `md` або `html` |
| `options` | Масив рядків. Якщо `poll_type` має значення `proposal`, допустимі значення: `agree`, `disagree`, `abstain`, `block`. Якщо `poll_type` має значення `meeting`, передайте рядки з датою або датою й часом у форматі ISO 8601. Для всіх інших типів опитувань допустимий будь-який рядок |
| `closing_at` | Рядок у форматі ISO 8601 або null, за замовчуванням null. Приклад: `2026-09-01T12:00:00Z`. Якщо значення null, голосування вимкнено, а опитування вважається чернеткою |
| `specified_voters_only` | Логічне значення, необов’язкове, за замовчуванням false. Якщо true, голосувати можуть лише зазначені люди. Якщо false, усіх у групі буде запрошено голосувати |
| `hide_results` | Рядок, необов’язковий, за замовчуванням `off`. Значення: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Логічне значення, за замовчуванням false. Показувати виборцям варіанти у випадковому порядку |
| `anonymous` | Логічне значення, необов’язкове, за замовчуванням false. Приховувати особи виборців |
| `recipient_audience` | `group` або null, необов’язкове, за замовчуванням null. Якщо `group`, уся група отримає сповіщення |
| `notify_on_closing_soon` | Рядок, необов’язковий, за замовчуванням `nobody`. Значення: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Масив ID користувачів, яких потрібно сповістити або запросити |
| `recipient_emails` | Масив адрес електронної пошти людей, яких потрібно запросити голосувати |
| `recipient_message` | Повідомлення, яке потрібно додати до запрошення електронною поштою |
| `notify_recipients` | Логічне значення, за замовчуванням false. Якщо false, додати людей без надсилання сповіщень. Якщо true, усі запрошені цим запитом отримають сповіщення електронною поштою |

<!-- translation-section: example-12 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Отримання опитування

Отримайте опитування за його ID (цілим числом) або ключем (рядком).

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Список опитувань

Отримайте список опитувань у групі, доступних користувачеві, якому належить API-ключ. Якщо група публічно доступна, людина, яка не є її учасником, може отримати список її публічних опитувань; приватні опитування залишаються доступними лише користувачам, які можуть читати їх у Loomio. Відповідь містить поточний висновок кожного доступного опитування, тому ви можете використати `status=closed`, щоб отримати список пропозицій, щодо яких уже ухвалено рішення.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове. ID групи, список опитувань якої потрібно отримати |
| `status` | Рядок, необов’язковий, за замовчуванням `active`. Значення: `active`, `closed`, `all` |
| `limit` | Ціле число, необов’язкове, за замовчуванням 50. Розмір сторінки |
| `offset` | Ціле число, необов’язкове, за замовчуванням 0. Зміщення для розбиття на сторінки |

Сумісність із попередніми версіями: `per` і `from` приймаються як альтернативні назви для `limit` і `offset` та працюватимуть і надалі.

<!-- translation-section: example-14 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Редагування опитування

Відредагуйте опитування від імені користувача, якому належить ключ API. Діють ті самі права доступу, що й у Loomio: користувач повинен мати право редагувати це опитування.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `title` | Оновлена назва |
| `details` | Оновлений опис опитування |
| `details_format` | `md` або `html`, необов’язкове, за замовчуванням `md` |
| `options` | Оновлені назви варіантів. Зміна варіантів може вплинути на наявні голоси залежно від стану опитування |
| `closing_at` | Рядок у форматі ISO 8601 або null |
| `recipient_audience` | `group` або null. Якщо `group`, усю групу буде сповіщено |
| `recipient_user_ids` | Масив ID користувачів, яких потрібно сповістити або запросити |
| `recipient_emails` | Масив електронних адрес людей, яких потрібно запросити голосувати |
| `recipient_message` | Повідомлення, яке потрібно додати до запрошення електронною поштою |

<!-- translation-section: example-15 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## М’яке видалення опитування

Виконайте м’яке видалення опитування від імені користувача, якому належить ключ API. Опитування позначається як видалене, але його запис зберігається.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Список учасників групи

Отримайте список учасників групи, доступний користувачу, якому належить API-ключ. Учасники групи можуть переглядати імена, ідентифікатори, посади та ролі інших учасників. Адреси електронної пошти включаються лише для власного облікового запису користувача API-ключа або якщо цей користувач є адміністратором групи.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове. Ідентифікатор групи, список учасників якої потрібно отримати |

<!-- translation-section: example-17 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Керування учасниками групи

Надішліть список адрес електронної пошти. На всі нові адреси буде надіслано запрошення до групи. На відміну від отримання списку учасників, ця операція потребує прав адміністратора групи.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове. Ідентифікатор групи, учасниками якої потрібно керувати |
| `emails` | Масив рядків, обов’язковий. Адреси електронної пошти людей, яких потрібно запросити до групи |
| `remove_absent` | Логічне значення. Якщо true, видалити з групи всіх, чиїх адрес електронної пошти немає у списку |

<!-- translation-section: example-18 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Якщо ви передасте `remove_absent=1`, усіх учасників групи, яких не було включено до списку, буде видалено з групи. Будьте обережні: ви можете видалити всіх учасників вашої групи.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

У відповідь повертається об’єкт із `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
