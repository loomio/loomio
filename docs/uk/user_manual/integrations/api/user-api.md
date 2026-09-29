---
title: Користувацький API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: 46fe14d2fbe3c315
  authentication-change: 14857aed606a359e
  response-size-and-related-records: 519f26eb65f49982
  endpoint-summary: 4720b4ea99fbb7c1
  groups: 29fb3c5431af0d9d
  list-groups: cae1884a4553b535
  get-a-group: 5da4c09bf5120ab5
  webhooks: 654f1e8bde9a0ae0
  list-webhooks: 5a7ce7d3bcbfea5e
  create-a-webhook: 9d2ee42c90fdd376
  update-a-webhook: 4523a2b87b804fe0
  test-a-webhook-destination: a5b7fdb9d451a61d
  delete-a-webhook: ca94307760e00d28
  event-types: 66bf9ae69bc6f4e9
  http-delivery: 752ef2b9b02c2a86
  payload-formats: 7700965ba29bd9e2
  search: 406527e93ae7e74a
  params: 3d19ca124f4ed8d2
  participation-report: 2c88be9ea762e179
  params-2: c1cd2249bf200b03
  example: '0479bd92d93f071d'
  create-discussion: 8813f077039e8556
  params-3: 2366e3297b49ea24
  example-2: d3afd8b07cafbafe
  show-discussion: 69414530f21e1071
  example-3: 9b708f2964d9bea2
  list-discussions: 5368d89161600f83
  params-4: 8320659c42300f5e
  example-4: 85f44b4bda657252
  list-threads: 1900ecd58c91ee56
  params-5: 903bae9cab5bbd44
  example-5: 7ed12262f8d98d97
  read-thread: 40758513466caa14
  example-6: e305e22929a2282c
  edit-discussion: 128d26cee7828ea1
  params-6: 7f636aaeea156c3e
  example-7: 89938affb558be23
  soft-delete-discussion: e667fc9c84ef1fca
  example-8: 8fe131ccb65bb461
  create-comment: be9141b2a553b756
  params-7: 4869e589bbfd7622
  example-9: fdaf15c97794e960
  edit-comment: 24038f8b2ab75ed3
  params-8: d82f4b426b0bb152
  example-10: 7ad2fd7a50b709cd
  soft-delete-comment: 9062e0ee8d595c71
  example-11: 5e9fb439ca500e87
  create-poll: bde585d61d6dcadd
  params-9: f18a5ef2eec35ab7
  example-12: 2e0bdb9ca131e97a
  show-poll: 748f91107a066fdc
  example-13: f36e6ce9144d7f70
  list-polls: 2ac7d8e97373a05c
  params-10: d75cc17fc40a3ece
  example-14: b533bef0bd397e43
  edit-poll: 46267f3fc5c5ee28
  params-11: a2a8cca63fc5e558
  example-15: a7a58418b09f9bc3
  soft-delete-poll: 349d8cb80fc51791
  example-16: 18314b5c12a8a769
  list-memberships: 18b64656110e5f5c
  params-12: 6d57afb59b215d75
  example-17: 57678f757f3de503
  manage-memberships: 2247a673d97b1a66
  params-13: f1e273d5b0def40d
  example-18: e15e5f4a71964196
title_source: c23fb6526b722360
title_generated: a8877cdee7d58933
---

<!-- translation-section: introduction -->

# Документація користувацького API Loomio

<!-- seo-description: Використовуйте користувацький API Loomio, щоб створювати обговорення, коментарі, опитування й теми та керувати ними й членством у групах з іншого програмного забезпечення. -->

`/api/b2` — користувацький API для інтеграцій із Loomio. Він використовує ключ API облікового запису користувача. Усі дії виконуються від імені цього користувача.

Дії з групами залежать від членства та прав доступу користувача, якому належить ключ API. Статус адміністратора інстанції не розширює доступ ключа API до груп або їхнього вмісту. Для адміністрування інстанції використовуйте Server API.

Використовуйте ключ API облікового запису Loomio, від імені якого виконуватимуться дії. Окремий обліковий запис бота стане в пригоді, якщо інтеграція не повинна отримувати запрошення до опитувань або сповіщення.

Якщо ви ввійшли в систему, свій ключ API та ідентифікатори груп ви знайдете на [сторінці доступу до API](/profile/api_access).

Передавайте ключ API в заголовку `Authorization: Bearer`. Ключі API в параметрах запиту відхиляються, оскільки URL-адреси можуть зберігатися в журналах проксі-серверів і доступу.

<!-- translation-section: authentication-change -->

### Зміна способу автентифікації

Раніше ключ API можна було передавати в параметрі URL `api_key`. Запити з `?api_key=YOUR_API_KEY` більше не працюють. Натомість використовуйте HTTP-заголовок `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

У прикладах використано `YOUR_API_KEY`, ідентифікатор групи `123` та `https://www.loomio.com/`. Замініть їх на свій ключ API, ідентифікатор групи та URL-адресу свого сервера Loomio.

<!-- translation-section: response-size-and-related-records -->

## Розмір відповіді та пов’язані записи

Відповіді користувацького API мають складений формат: разом з основними записами надходять пов’язані записи, зокрема теми, групи, користувачі, опитування та реакції. Завдяки цьому клієнт може заповнити локальне сховище записів одним запитом. Відповідь може містити більше даних, ніж потрібно простій інтеграції.

Передайте `compact=1`, щоб виключити об’ємні пов’язані записи тем, груп, батьківських груп, членства, реакцій, тегів і перекладів. Основні записи та пов’язані записи, потрібні для розуміння їхнього вмісту, залишаться у відповіді.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Для точнішого керування передайте `exclude_types` із типами записів в однині, розділеними пробілами. Наприклад, `exclude_types=group reaction` виключає пов’язані групи та реакції. Поширені значення: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` і `topic_item`. Виключення стосуються пов’язаних записів, а не основного ресурсу, який запитує кінцева точка.

Відповіді з колекціями містять `meta.total`, якщо можна визначити точний розмір колекції. Загальну кількість обчислюють до застосування `limit` та `offset`. Кінцеві точки, як-от пошук, які навмисно повертають обмежений набір результатів, не включають `meta.total` замість повернення `null`.

<!-- translation-section: endpoint-summary -->

## Огляд кінцевих точок

| Метод | Кінцева точка | Призначення |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Перелічити групи користувача, якому належить ключ API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Отримати доступну групу |
| `GET` | `/api/b2/reports` | Сформувати звіт про участь |
| `GET` | `/api/b2/search` | Знайти доступні обговорення, коментарі, опитування, голоси та висновки |
| `POST` | `/api/b2/discussions` | Створити обговорення |
| `GET` | `/api/b2/discussions/:id` | Отримати обговорення |
| `GET` | `/api/b2/discussions` | Перелічити обговорення в групі |
| `PATCH` | `/api/b2/discussions/:id` | Редагувати обговорення |
| `DELETE` | `/api/b2/discussions/:id` | М’яко видалити обговорення |
| `GET` | `/api/b2/threads` | Перелічити доступні теми обговорень і окремих опитувань |
| `GET` | `/api/b2/threads/:topic_id` | Отримати тему |
| `GET` | `/api/b2/threads/:topic_id/items` | Отримати впорядковані елементи теми |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Отримати повну тему у форматі Markdown |
| `POST` | `/api/b2/comments` | Створити коментар або відповідь |
| `PATCH` | `/api/b2/comments/:id` | Редагувати коментар |
| `DELETE` | `/api/b2/comments/:id` | М’яко видалити коментар |
| `POST` | `/api/b2/polls` | Створити опитування |
| `GET` | `/api/b2/polls/:id` | Отримати опитування |
| `GET` | `/api/b2/polls` | Перелічити опитування в групі |
| `PATCH` | `/api/b2/polls/:id` | Редагувати опитування |
| `DELETE` | `/api/b2/polls/:id` | М’яко видалити опитування |
| `GET` | `/api/b2/memberships` | Перелічити членства в групі |
| `POST` | `/api/b2/memberships` | Додати учасників і, за потреби, вилучити тих, кого немає в списку |
| `GET` | `/api/b2/chatbots` | Перелічити інтеграції чату та вебхуки групи |
| `POST` | `/api/b2/chatbots` | Створити інтеграцію чату або вебхук |
| `PATCH` | `/api/b2/chatbots/:id` | Оновити інтеграцію чату або вебхук |
| `DELETE` | `/api/b2/chatbots/:id` | Видалити інтеграцію чату або вебхук |
| `POST` | `/api/b2/chatbots/check` | Надіслати тестовий запит для перевірки з’єднання з вебхуком |

<!-- translation-section: groups -->

## Групи

<!-- translation-section: list-groups -->

### Перелічити групи

Повертає групи, у яких користувач, якому належить ключ API, має активне членство.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Відповідь містить усі відповідні записи в масиві `groups` без поділу на сторінки. До нього входять батьківські групи й підгрупи, зокрема групи, підписка яких зараз неактивна. Якщо інтеграція має працювати лише з активними групами, перевіряйте поле `enabled`.

Важливі поля групи:

| Поле | Опис |
| --- | --- |
| `id` | Числовий ідентифікатор групи, який використовують інші кінцеві точки користувацького API |
| `key` | Стабільний короткий ключ, який використовують в URL-адресах Loomio |
| `handle` | Зрозумілий людині ідентифікатор групи |
| `name` | Назва групи |
| `full_name` | Назва групи з урахуванням батьківської групи |
| `parent_id` | Числовий ідентифікатор батьківської групи для підгрупи, інакше `null` |
| `enabled` | Чи активні група та її підписка |
| `memberships_count` | Кількість активних членств і членств, що очікують підтвердження |
| `accepted_memberships_count` | Кількість підтверджених членств |
| `pending_memberships_count` | Кількість запрошень, що очікують відповіді |
| `admin_memberships_count` | Кількість адміністраторів групи |
| `delegates_count` | Кількість делегатів |
| `discussions_count` | Кількість обговорень безпосередньо в групі |
| `polls_count` | Кількість опитувань безпосередньо в групі |
| `subgroups_count` | Кількість підгруп |

Відповідь може містити додаткові налаштування групи, пов’язані записи батьківської групи та членства користувача API. Клієнти мають ігнорувати поля, які не використовують.

<!-- translation-section: get-a-group -->

### Отримати групу

Повертає одну групу, доступну користувачеві, якому належить ключ API.

`GET /api/b2/groups/:id_or_key_or_handle`

Ідентифікатором може бути числовий ID групи, її ключ або коротка назва.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Відповідь містить групу в масиві `groups` із тими самими полями, що й кінцева точка для переліку груп. Запит групи, до якої користувач із ключем API не має доступу, повертає помилку доступу.

<!-- translation-section: webhooks -->

## Вебхуки

Користувацький API працює через запити: інтеграція звертається до Loomio, коли їй потрібно прочитати або змінити дані. Вебхук групи дає змогу отримувати зміни від Loomio. Loomio надсилає вибрані події групи на вашу кінцеву точку, щойно вони відбуваються. Тому інтеграції не потрібно регулярно опитувати REST API.

Вебхуки налаштовують окремо для кожної групи. Для цього потрібні права адміністратора групи. Керувати ними можна через інтерфейс Loomio:

1. Відкрийте групу.
2. Відкрийте меню групи та виберіть **Інтеграції чату**.
3. Додайте інтеграцію, формат даних якої підтримує ваша кінцева точка. Для кінцевої точки загального призначення використовуйте формат Mattermost/Markdown.
4. Введіть назву та URL-адресу призначення.
5. Виберіть події, які Loomio має надсилати автоматично.
6. Збережіть інтеграцію та натисніть **Тестове підключення**, щоб надіслати тестове повідомлення.

Використовуйте HTTPS-адресу призначення з URL-адресою, яку неможливо вгадати. Loomio вимагає, щоб адреса призначення вказувала на публічну IP-адресу, і блокує запити до локальних або приватних мережевих адрес.

Агенти та інші інтеграції також можуть керувати веб-хуками через описані нижче кінцеві точки чат-ботів з автентифікацією Bearer. Ресурс має назву `chatbots` для сумісності з інтеграціями чату Loomio, але також охоплює звичайні вихідні веб-хуки.

<!-- translation-section: list-webhooks -->

### Перелічити вебхуки

Повертає інтеграції чату, налаштовані для групи. Користувач, якому належить ключ API, має бути адміністратором цієї групи. Відповідь містить URL-адреси призначення, тому її не можна відкривати звичайним учасникам групи.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Відповідь містить масив `chatbots` із такими полями:

| Поле | Опис |
| --- | --- |
| `id` | Ідентифікатор інтеграції для оновлення та видалення |
| `group_id` | Група, події якої надсилаються |
| `name` | Назва інтеграції для адміністраторів |
| `kind` | `webhook` для вихідного вебхука або `matrix` для інтеграції з Matrix |
| `webhook_kind` | Формат даних: `markdown`, `slack`, `discord`, `microsoft` або `webex` |
| `server` | URL призначення |
| `event_kinds` | Події, що надсилаються автоматично |
| `notification_only` | Чи містять повідомлення лише заголовок сповіщення |

<!-- translation-section: create-a-webhook -->

### Створити вебхук

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

Користувач, якому належить ключ API, має бути адміністратором групи `group_id`. Перед збереженням перевіряється, чи URL призначення є загальнодоступним.

<!-- translation-section: update-a-webhook -->

### Оновити вебхук

`PATCH /api/b2/chatbots/:id`

Надішліть поля, які потрібно змінити. Зміна `group_id` не дає змоги перенести вебхук до іншої групи.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Перевірити адресу призначення вебхука

Надішліть на адресу призначення тестове повідомлення, сумісне з Markdown, до або після збереження налаштувань.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Видалити вебхук

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Після видалення налаштувань нові події більше не надсилатимуться. Вміст групи Loomio не видаляється.

<!-- translation-section: event-types -->

### Типи подій

Вебхук може отримувати події таких типів:

| Подія | Коли надсилається |
| --- | --- |
| `new_discussion` | Розпочато обговорення |
| `discussion_edited` | Обговорення змінено |
| `new_comment` | Створено коментар |
| `poll_created` | Розпочато опитування |
| `poll_edited` | Опитування змінено |
| `poll_closing_soon` | Наближається час закриття опитування |
| `poll_expired` | Настав час закриття опитування |
| `poll_closed_by_user` | Людина закрила опитування вручну |
| `poll_reopened` | Опитування відкрито повторно |
| `outcome_created` | Опубліковано висновок |
| `outcome_updated` | Висновок оновлено |
| `outcome_review_due` | Настав час переглянути висновок |
| `stance_created` | Подано голос |
| `stance_updated` | Голос змінено |

Вебхук належить одній групі й отримує події цієї групи, на які його підписано. Люди також можуть явно вибрати інтеграцію під час поширення вмісту або надсилання деяких сповіщень, навіть якщо відповідну автоматичну подію не вибрано.

<!-- translation-section: http-delivery -->

### Доставка через HTTP

Loomio асинхронно надсилає HTTP-запит `POST` на налаштований URL із таким заголовком:

```text
Content-Type: application/json; charset=utf-8
```

Час очікування відповіді — п’ять секунд. Відповідь `2xx`, зокрема `204 No Content`, вважається успішною. Сервіс, що приймає вебхук, має швидко відповідати, виконувати тривалі завдання асинхронно та обробляти повторні події або події, отримані не за порядком.

Наразі Loomio не додає підпис вебхука, заголовок зі спільним секретом, ідентифікатор події або ідентифікатор доставки. Вважайте повний URL призначення секретом і не публікуйте його. Якщо сервіс-одержувач підтримує це, додайте до URL токен, який неможливо вгадати. Якщо потрібна стабільна машиночитна схема подій або підписана доставка, використовуйте вебхук як сповіщення про зміну, а поточні записи отримуйте через API користувача з автентифікацією.

<!-- translation-section: payload-formats -->

### Формати даних

Вебхуки передають повідомлення для відображення в чат-сервісах. Вони не містять повних серіалізованих записів Loomio. Посилання в повідомленні вказують на відповідний вміст Loomio. Якщо інтеграції потрібні структуровані актуальні дані, вона може отримати їх через API користувача.

| Формат інтеграції | Основні поля JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, не більше приблизно 1 900 символів |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Наприклад, загальний формат Markdown надсилає дані такого вигляду:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Точний текст повідомлення залежить від події, мови групи, налаштування надсилання лише сповіщень і версії Loomio. Сервісам-одержувачам слід використовувати задокументовані поля верхнього рівня вибраного формату, а не розбирати текст речень.

<!-- translation-section: search -->

## Пошук

Шукайте обговорення, коментарі, опитування, голоси та висновки, доступні користувачу, якому належить ключ API. Результати містять загальнодоступний вміст, навіть якщо користувач не є учасником відповідної групи. Доступ до приватного вмісту визначається звичайними правилами видимості тем.

`GET /api/b2/search`

<!-- translation-section: params -->

### Параметри

| Назва | Опис |
| --- | --- |
| `query` | Текст пошуку. Підтримуються точні та приблизні збіги |
| `group_id` | Обмежити результати однією доступною групою |
| `org_id` | Обмежити результати доступною батьківською групою та її доступними підгрупами. Для прямих обговорень використовуйте `0` |
| `type` | Обмежити результати одним типом: `Discussion`, `Comment`, `Poll`, `Stance` або `Outcome` |
| `types` | Список типів результатів, розділених комами |
| `tag` | Обмежити результати темами із цією міткою |
| `author_id` | Обмежити результати вмістом одного автора. Без `query` повертає нещодавню видиму активність цього автора |
| `order` | Установіть `authored_at_desc`, щоб упорядкувати знайдений вміст за часом створення |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Відповідь містить масив `search_results`. Кожен результат указує на знайдений запис і його видимий контекст. Поля включають `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` і `tags`. Поля, які не стосуються результату, мають значення `null`.

<!-- translation-section: participation-report -->

## Звіт про участь

Повертає ті самі зведені дані про участь, які використовуються у звіті Loomio про участь.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `section` | Розділ звіту: `base`, `users` або `countries`. Використовуйте `users` для даних про активність окремих людей |
| `group_scope` | `custom` або `my`. Застаріле значення `all` обробляється як `my`, оскільки ключі API користувача не надають доступу до всього екземпляра |
| `group_ids` | Ідентифікатори груп, розділені комами, коли задано `group_scope=custom`. Ідентифікатори груп, учасником яких не є користувач API, ігноруються |
| `start_month` | Перший місяць звіту у форматі `YYYY-MM`; за замовчуванням — 12 місяців тому |
| `end_month` | Останній місяць звіту у форматі `YYYY-MM`; за замовчуванням — поточний місяць |
| `interval` | Інтервал для розділу `base`: `day`, `week`, `month` або `year` |
| `member_type` | Установіть `delegate` разом із `section=users`, щоб отримати дані лише про чинних делегатів |

Людина є делегатом, якщо має чинне членство з роллю делегата в будь-якій із вибраних груп. Показники підсумовуються за всіма вибраними групами. Рядки делегатів повертаються, навіть якщо всі показники активності дорівнюють нулю. Показники охоплюють теми, коментарі, опитування, голоси, висновки та реакції; вони не є часткою участі в голосуванні. Рядки користувачів також містять кількість іменних бюлетенів: виданих, поданих і пропущених. Анонімні опитування не враховуються в жодному персональному показнику голосування. `all_votes_cast` має значення true, лише якщо було видано принаймні один бюлетень і всі видані бюлетені подано.

API застосовує ті самі правила видимості груп, що й звіт у Loomio. Ключ API користувача не дає доступу до даних звіту для груп, недоступних цьому користувачу.

<!-- translation-section: example -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Масив `users` містить повні рядки даних про активність:

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

Створіть обговорення від імені користувача, якому належить ключ API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Група, у якій буде створено тему |
| `title` | Назва теми, обов’язкове поле |
| `description` | Контекст теми, необов’язкове поле |
| `description_format` | `md` або `html`, необов’язкове поле, типове значення — `md` |
| `recipient_audience` | `group` або null. Якщо вказано `group`, уся група отримає сповіщення про нову тему |
| `recipient_user_ids` | Масив ID користувачів, яких потрібно сповістити або запросити до теми |
| `recipient_emails` | Масив електронних адрес людей, яких потрібно запросити до теми |
| `recipient_message` | Повідомлення для електронного листа із запрошенням |

<!-- translation-section: example-2 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Отримання обговорення

Отримайте обговорення за його числовим ID або текстовим ключем.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Список обговорень

Отримайте список обговорень у групі, доступних користувачу, якому належить ключ API. Якщо група загальнодоступна, людина, яка не є її учасником, може отримати список публічних обговорень. Приватні обговорення доступні лише тим, хто має право переглядати їх у Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове поле. ID групи, обговорення якої потрібно отримати |
| `status` | Рядок, необов’язкове поле, типове значення — `open`. Значення: `open`, `closed`, `all` |
| `limit` | Ціле число, необов’язкове поле, типове значення — 50. Розмір сторінки |
| `offset` | Ціле число, необов’язкове поле, типове значення — 0. Зміщення для посторінкового перегляду |

Для сумісності підтримуються `per` і `from` як відповідники `limit` і `offset`. Вони працюватимуть і надалі.

<!-- translation-section: example-4 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Список тем

Отримайте список доступних користувачу тем обговорень і опитувань, упорядкований за останньою активністю. ID теми — це її `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `limit` | Ціле число, необов’язкове поле, типове значення — 50. Розмір сторінки |
| `offset` | Ціле число, необов’язкове поле, типове значення — 0. Зміщення для посторінкового перегляду |

<!-- translation-section: example-5 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Читання теми

Прочитайте тему, упорядкований потік її подій або повний доступний документ у форматі Markdown.

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

Кінцева точка `items` повертає події в порядку їх появи, зокрема доступні коментарі, опитування, голоси та висновки. Кінцева точка `markdown` повертає всю доступну тему як один документ Markdown. Причини голосування включаються лише тоді, коли вони доступні користувачу, якому належить ключ API.

Для всіх кінцевих точок тем діють ті самі дозволи, що й в інтерфейсі Loomio. Ключ API не надає доступу до теми, яку користувач зазвичай не може відкрити.

<!-- translation-section: edit-discussion -->

## Редагування обговорення

Відредагуйте обговорення від імені користувача, якому належить ключ API. Діють ті самі дозволи, що й у Loomio: користувач повинен мати право редагувати це обговорення.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `title` | Оновлена назва |
| `description` | Оновлений контекст |
| `description_format` | `md` або `html`, необов’язкове поле, типове значення — `md` |
| `recipient_audience` | `group` або null. Якщо вказано `group`, уся група отримає сповіщення про зміну |
| `recipient_user_ids` | Масив ID користувачів, яких потрібно сповістити або запросити до теми |
| `recipient_emails` | Масив електронних адрес людей, яких потрібно запросити до теми |
| `recipient_message` | Повідомлення для електронного листа із запрошенням |

<!-- translation-section: example-7 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Програмне видалення обговорення

Виконайте програмне видалення обговорення від імені користувача, якому належить ключ API. Обговорення буде вилучено з показу, але його запис залишиться.

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
| `discussion_id` | Ціле число, обов’язкове поле. ID обговорення, до якого потрібно додати коментар |
| `body` | Текст коментаря, обов’язковий, якщо не додано вкладення |
| `body_format` | `md` або `html`, необов’язкове поле, типове значення — `md` |

<!-- translation-section: example-9 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Редагування коментаря

Відредагуйте коментар від імені користувача, якому належить ключ API. Діють ті самі дозволи, що й у Loomio: користувач повинен мати право редагувати цей коментар.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `body` | Оновлений текст коментаря |
| `body_format` | `md` або `html`, необов’язкове поле, типове значення — `md` |

<!-- translation-section: example-10 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Програмне видалення коментаря

Виконайте програмне видалення коментаря від імені користувача, якому належить ключ API. Текст коментаря буде приховано, але його запис залишиться.

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
| `group_id` | Ціле число, необов’язкове, за замовчуванням null. ID групи для опитування. Якщо передано `discussion_id`, значення `group_id` ігнорується |
| `discussion_id` | Ціле число, необов’язкове, за замовчуванням null. ID теми обговорення, до якої потрібно додати опитування |
| `title` | Рядок, обов’язковий. Назва опитування |
| `poll_type` | Рядок, обов’язковий. Значення: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Рядок, необов’язковий. Основний текст опитування |
| `details_format` | Рядок, необов’язковий, за замовчуванням `md`. Значення: `md` або `html` |
| `options` | Масив рядків. Якщо `poll_type` дорівнює `proposal`, допустимі значення: `agree`, `disagree`, `abstain`, `block`. Якщо `poll_type` дорівнює `meeting`, укажіть дати або дату й час у форматі ISO 8601. Для всіх інших типів опитувань допустимий будь-який рядок |
| `closing_at` | Рядок у форматі ISO 8601 або null, за замовчуванням null. Приклад: `2026-09-01T12:00:00Z`. Якщо значення null, голосування вимкнено, а опитування вважається незавершеним |
| `specified_voters_only` | Логічне значення, необов’язкове, за замовчуванням false. Якщо true, голосувати можуть лише вказані люди. Якщо false, запрошення проголосувати отримають усі учасники групи |
| `hide_results` | Рядок, необов’язковий, за замовчуванням `off`. Значення: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Логічне значення, за замовчуванням false. Показувати варіанти учасникам голосування у випадковому порядку |
| `anonymous` | Логічне значення, необов’язкове, за замовчуванням false. Приховувати особи учасників голосування |
| `recipient_audience` | `group` або null, необов’язкове, за замовчуванням null. Якщо `group`, сповіщення отримає вся група |
| `notify_on_closing_soon` | Рядок, необов’язковий, за замовчуванням `nobody`. Значення: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Масив ID користувачів, яких потрібно сповістити або запросити |
| `recipient_emails` | Масив електронних адрес людей, яких потрібно запросити до голосування |
| `recipient_message` | Повідомлення для запрошення електронною поштою |
| `notify_recipients` | Логічне значення, за замовчуванням false. Якщо false, додати людей без надсилання сповіщень. Якщо true, усі запрошені в цьому запиті отримають лист зі сповіщенням |

<!-- translation-section: example-12 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Перегляд опитування

Отримайте опитування за його числовим ID або текстовим ключем.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Список опитувань

Отримайте список опитувань групи, видимих користувачеві, якому належить ключ API. Якщо група загальнодоступна, людина, яка не є її учасником, може переглянути її публічні опитування. Приватні опитування доступні лише тим, хто може переглядати їх у Loomio. Відповідь містить поточний висновок кожного видимого опитування, тому за допомогою `status=closed` можна отримати список пропозицій, за якими ухвалено рішення.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове. ID групи, опитування якої потрібно отримати |
| `status` | Рядок, необов’язковий, за замовчуванням `active`. Значення: `active`, `closed`, `all` |
| `limit` | Ціле число, необов’язкове, за замовчуванням 50. Розмір сторінки |
| `offset` | Ціле число, необов’язкове, за замовчуванням 0. Зміщення для посторінкового перегляду |

Для сумісності підтримуються `per` і `from` як відповідники `limit` і `offset`. Вони працюватимуть і надалі.

<!-- translation-section: example-14 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Редагування опитування

Відредагуйте опитування від імені користувача, якому належить ключ API. Діють ті самі дозволи, що й у Loomio: користувач повинен мати право редагувати це опитування.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `title` | Оновлена назва |
| `details` | Оновлений опис опитування |
| `details_format` | `md` або `html`, необов’язкове, за замовчуванням `md` |
| `options` | Оновлені назви варіантів. Залежно від стану опитування зміна варіантів може вплинути на вже подані голоси |
| `closing_at` | Рядок у форматі ISO 8601 або null |
| `recipient_audience` | `group` або null. Якщо `group`, сповіщення отримає вся група |
| `recipient_user_ids` | Масив ID користувачів, яких потрібно сповістити або запросити |
| `recipient_emails` | Масив електронних адрес людей, яких потрібно запросити до голосування |
| `recipient_message` | Повідомлення для запрошення електронною поштою |

<!-- translation-section: example-15 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## М’яке видалення опитування

М’яко видаліть опитування від імені користувача, якому належить ключ API. Опитування буде вилучено з перегляду, але його запис залишиться.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Список учасників групи

Отримайте список учасників групи, доступний користувачеві, якому належить ключ API. Учасники групи можуть переглядати імена, ID, посади й ролі інших учасників. Електронні адреси доступні лише для власного облікового запису користувача або якщо він є адміністратором групи.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове. ID групи, список учасників якої потрібно отримати |

<!-- translation-section: example-17 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Керування учасниками групи

Надішліть список електронних адрес. На всі нові адреси буде надіслано запрошення до групи. На відміну від перегляду списку учасників, для цієї дії потрібні права адміністратора групи.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Параметри

| Назва | Опис |
| --- | --- |
| `group_id` | Ціле число, обов’язкове. ID групи, учасниками якої потрібно керувати |
| `emails` | Масив рядків, обов’язковий. Електронні адреси людей, яких потрібно запросити до групи |
| `remove_absent` | Логічне значення. Якщо true, видалити з групи всіх, чиїх електронних адрес немає в списку |

<!-- translation-section: example-18 -->

### Приклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Якщо передати `remove_absent=1`, усіх учасників групи, яких немає в списку, буде видалено з групи. Будьте обережні: так можна видалити всіх учасників вашої групи.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

У відповіді повертається об’єкт `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
