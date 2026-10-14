---
title: API карыстальніка
source_revision: 79280ee7a1246dbb8bb16686856608069718bc14
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-09'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: dcbe9217091f8cb2
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
  introduction: d140e7a85e834ed6
  authentication-change: adcd9b6e708832e8
  response-size-and-related-records: fb7c80e5add0ce54
  endpoint-summary: e33f124e2636249b
  groups: 8a31f2457ed0bf48
  list-groups: 0f1ed9fe46ad975d
  get-a-group: e50257305da3005e
  webhooks: 3654136d8b45e07f
  list-webhooks: 50413790d5d0291e
  create-a-webhook: eb811bee0b274576
  update-a-webhook: 1f3435ef195194e0
  test-a-webhook-destination: b0871d57d780518d
  delete-a-webhook: 85f0342828ce9330
  event-types: 85af050b98ebd07a
  http-delivery: 5e3bf2907ebbead8
  payload-formats: a3bf082ada430cf4
  search: b53fa7c0b4a7526a
  params: f848a045b6d30e21
  participation-report: 77f4f7ee4543c73e
  params-2: afa0284992112bed
  example: d502c57ce9e40b8c
  create-discussion: b1ceb64b9b7d5a88
  params-3: d3f56b290de19793
  example-2: f2d82535c19073dd
  show-discussion: 341241d834bc6665
  example-3: c08bf8eddc19c136
  list-discussions: ab1d9277cd60af45
  params-4: 31c663853121dc59
  example-4: d2b96c7c9580c80d
  list-threads: c80ed6be8b89c6b1
  params-5: 35f405ba66fead37
  example-5: 8d1532bc479677d4
  read-thread: 29fb0da0b92cc49d
  example-6: e93326dcc528c613
  edit-discussion: a9e10120012beb0f
  params-6: cfeddf26aa493d8c
  example-7: 5cf572b27954029b
  soft-delete-discussion: d9851d89ea3d33ea
  example-8: eeb7353d36505f60
  create-comment: e6c258c9dc99746c
  params-7: c0d4fe2304fd4faa
  example-9: 3593a520c37de8eb
  edit-comment: 2259892a9ef1145a
  params-8: a18d7836ee67214e
  example-10: 8f66d1d23310a629
  soft-delete-comment: e122f53dad3ee4e1
  example-11: 972b24ebf5e7a7c8
  create-poll: 180330afd3f2a5a4
  params-9: 7dca53db44242c78
  example-12: 7cd3b084944560e7
  show-poll: 96abe04dedbdb102
  example-13: 97469e22c25d02c2
  list-polls: 94463b5d23f7369b
  params-10: 636049e8660ef16f
  example-14: 137fbaaf3431463a
  edit-poll: 3a808ea9dc13b55a
  params-11: aabfec1ba1e950b0
  example-15: b83fc7cbb059e94d
  soft-delete-poll: 05abd7476ccf2f87
  example-16: 7ac8f6afc54e6ce9
  list-memberships: f65fd3d4e9087b9b
  params-12: 2356c691c8731786
  example-17: 17d08f9455c4bac4
  manage-memberships: cfb3da7791127f92
  params-13: 01c031587abdff59
  example-18: d44885f7b0ec9c83
title_source: c23fb6526b722360
title_generated: 142976b96af3aa95
---

<!-- translation-section: introduction -->

# Дакументацыя API карыстальніка Loomio

<!-- seo-description: Выкарыстоўвайце API карыстальніка Loomio, каб ствараць абмеркаванні, каментарыі, апытанні, тэмы і кіраваць імі, а таксама ўдзелам у групах з іншых праграм. -->

`/api/b2` — гэта API для інтэграцый з Loomio, арыентаваны на карыстальнікаў. Ён выкарыстоўвае ключ API ўліковага запісу, і ўсе дзеянні выконваюцца ад імя гэтага ўліковага запісу.

Аперацыі з групамі выкарыстоўваюць удзел у групах і правы ўліковага запісу, якому належыць ключ API. Статус адміністратара асобніка не пашырае доступ ключа API да груп або змесціва; для адміністравання асобніка выкарыстоўвайце API сервера.

Выкарыстоўвайце ключ API ўліковага запісу Loomio, ад імя якога будуць выконвацца дзеянні. Асобны ўліковы запіс бота карысны, калі інтэграцыя не павінна атрымліваць запрашэнні да апытанняў або апавяшчэнні.

Карыстальнікі, якія ўвайшлі ў сістэму, могуць знайсці свой ключ API і ідэнтыфікатары груп на [старонцы доступу да API](/profile/api_access).

Перадавайце ключ API ў загалоўку `Authorization: Bearer`. Ключы API ў радках запыту адхіляюцца, бо URL-адрасы могуць запісвацца проксі-серверамі і ў журналах доступу.

<!-- translation-section: authentication-change -->

### Змена аўтэнтыфікацыі

Раней ключ API прымаўся як параметр URL `api_key`. Запыты з `?api_key=YOUR_API_KEY` больш не працуюць. Замест гэтага выкарыстоўвайце HTTP-загаловак `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

У прыкладах выкарыстоўваюцца `YOUR_API_KEY`, ідэнтыфікатар групы `123` і `https://www.loomio.com/`. Замяніце іх сваім ключом API, ідэнтыфікатарам групы і URL-адрасам вашай усталёўкі Loomio.

<!-- translation-section: response-size-and-related-records -->

## Памер адказу і звязаныя запісы

Адказы API карыстальніка маюць складаны фармат: разам з асноўнымі запісамі перадаюцца звязаныя запісы, такія як тэмы, групы, карыстальнікі, апытанні і рэакцыі. Гэта дазваляе кліенту запоўніць лакальнае сховішча запісаў адным запытам, але адказ можа ўтрымліваць больш даных, чым патрабуецца простай інтэграцыі.

Перадайце `compact=1`, каб выключыць аб’ёмныя звязаныя запісы тэм, груп, бацькоўскіх груп, удзелу ў групах, рэакцый, тэгаў і перакладаў. Асноўныя запісы і звязаныя запісы, патрэбныя для разумення іх змесціва, застаюцца ў адказе.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Для непасрэднага кантролю перадайце `exclude_types` з тыпамі запісаў у адзіночным ліку, падзеленымі прабеламі. Напрыклад, `exclude_types=group reaction` выключае звязаныя групы і рэакцыі. Распаўсюджаныя значэнні: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` і `topic_item`. Выключэнні ўжываюцца да звязаных запісаў, а не да асноўнага рэсурсу, запытанага праз канцавы пункт.

Адказы з калекцыямі ўключаюць `meta.total`, калі вызначаны дакладны памер калекцыі. Агульная колькасць вылічаецца да ўжывання `limit` і `offset`. Канцавыя пункты, такія як пошук, якія наўмысна вяртаюць абмежаваны набор вынікаў, не ўключаюць `meta.total` замест таго, каб вяртаць `null`.

<!-- translation-section: endpoint-summary -->

## Агляд канцавых пунктаў

| Метад | Канцавы пункт | Прызначэнне |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Атрымаць спіс груп уліковага запісу, якому належыць ключ API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Атрымаць даступную групу |
| `GET` | `/api/b2/reports` | Стварыць справаздачу аб удзеле |
| `GET` | `/api/b2/search` | Шукаць даступныя абмеркаванні, каментарыі, апытанні, галасы і высновы |
| `POST` | `/api/b2/discussions` | Стварыць абмеркаванне |
| `GET` | `/api/b2/discussions/:id` | Атрымаць абмеркаванне |
| `GET` | `/api/b2/discussions` | Атрымаць спіс абмеркаванняў у групе |
| `PATCH` | `/api/b2/discussions/:id` | Рэдагаваць абмеркаванне |
| `DELETE` | `/api/b2/discussions/:id` | Выдаліць абмеркаванне з захаваннем запісу |
| `GET` | `/api/b2/threads` | Атрымаць спіс даступных тэм абмеркаванняў і асобных апытанняў |
| `GET` | `/api/b2/threads/:topic_id` | Атрымаць тэму |
| `GET` | `/api/b2/threads/:topic_id/items` | Атрымаць упарадкаваныя элементы тэмы |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Атрымаць поўную тэму ў фармаце Markdown |
| `POST` | `/api/b2/comments` | Стварыць каментарый або адказ |
| `PATCH` | `/api/b2/comments/:id` | Рэдагаваць каментарый |
| `DELETE` | `/api/b2/comments/:id` | Выдаліць каментарый з захаваннем запісу |
| `POST` | `/api/b2/polls` | Стварыць апытанне |
| `GET` | `/api/b2/polls/:id` | Атрымаць апытанне |
| `GET` | `/api/b2/polls` | Атрымаць спіс апытанняў у групе |
| `PATCH` | `/api/b2/polls/:id` | Рэдагаваць апытанне |
| `DELETE` | `/api/b2/polls/:id` | Выдаліць апытанне з захаваннем запісу |
| `GET` | `/api/b2/memberships` | Атрымаць спіс запісаў удзелу ў групе |
| `POST` | `/api/b2/memberships` | Дадаць удзельнікаў і пры неабходнасці выдаліць удзельнікаў, якіх няма ў спісе |
| `GET` | `/api/b2/chatbots` | Атрымаць спіс інтэграцый з чатам і вэбхукаў групы |
| `POST` | `/api/b2/chatbots` | Стварыць інтэграцыю з чатам або вэбхук |
| `PATCH` | `/api/b2/chatbots/:id` | Абнавіць інтэграцыю з чатам або вэбхук |
| `DELETE` | `/api/b2/chatbots/:id` | Выдаліць інтэграцыю з чатам або вэбхук |
| `POST` | `/api/b2/chatbots/check` | Адправіць тэст падключэння вэбхука |

<!-- translation-section: groups -->

## Групы

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"ь адміністратараў групы |\n| `delegates_count` | Колькасць дэлегатаў |\n| `discussions_count` | Колькасць ","after":"ь адміністратараў групы |\n| `discussions_count` | Колькасць "} -->

### Спіс груп

Вяртае групы, у якіх уліковы запіс, якому належыць ключ API, мае актыўны ўдзел.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Адказ утрымлівае ўсе адпаведныя запісы ў масіве `groups` без падзелу на старонкі. Ён уключае бацькоўскія групы і падгрупы, у тым ліку групы, падпіска якіх цяпер неактыўная. Правярайце поле `enabled`, калі інтэграцыя павінна працаваць толькі з уключанымі групамі.

Важныя палі групы:

| Поле | Апісанне |
| --- | --- |
| `id` | Лікавы ідэнтыфікатар групы, які выкарыстоўваецца іншымі канцавымі пунктамі API карыстальніка |
| `key` | Нязменны кароткі ключ, які выкарыстоўваецца ў URL-адрасах Loomio |
| `handle` | Чытэльны для людзей ідэнтыфікатар групы |
| `name` | Назва групы |
| `full_name` | Назва групы з кантэкстам яе бацькоўскай групы |
| `parent_id` | Лікавы ідэнтыфікатар бацькоўскай групы для падгрупы, у іншых выпадках — `null` |
| `enabled` | Ці актыўныя група і яе падпіска |
| `memberships_count` | Колькасць актыўных запісаў удзелу і запісаў, якія чакаюць пацвярджэння |
| `accepted_memberships_count` | Колькасць пацверджаных запісаў удзелу |
| `pending_memberships_count` | Колькасць запрашэнняў, якія чакаюць прыняцця |
| `admin_memberships_count` | Колькасць адміністратараў групы |
| `discussions_count` | Колькасць абмеркаванняў непасрэдна ў групе |
| `polls_count` | Колькасць апытанняў непасрэдна ў групе |
| `subgroups_count` | Колькасць падгруп |

Адказ можа ўключаць дадатковыя налады групы, звязаныя запісы бацькоўскіх груп і запісы ўдзелу ўліковага запісу API ў групах. Кліенты павінны ігнараваць палі, якія яны не выкарыстоўваюць.

<!-- translation-section: get-a-group -->

### Атрыманне групы

Вяртае адну групу, даступную ўліковаму запісу, якому належыць ключ API.

`GET /api/b2/groups/:id_or_key_or_handle`

Ідэнтыфікатарам можа быць лікавы ID групы, ключ або чытэльны ідэнтыфікатар.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Адказ утрымлівае групу ў масіве `groups` і выкарыстоўвае тыя ж палі, што і канцавы пункт спісу. Запыт групы, да якой уліковы запіс з ключом API не мае доступу, вяртае памылку правоў доступу.

<!-- translation-section: webhooks -->

## Вэбхукі

API карыстальніка працуе на аснове запытаў: інтэграцыя звяртаецца да Loomio, калі ёй трэба прачытаць або змяніць даныя. Вэбхук групы забяспечвае адпраўку даных у зваротным кірунку. Loomio адпраўляе выбраныя падзеі групы на ваш канчатковы пункт адразу, калі яны адбываюцца, таму інтэграцыі не трэба перыядычна звяртацца да REST API, каб правяраць змены.

Вэбхукі наладжваюцца асобна для кожнай групы і патрабуюць правоў адміністрацыі групы. Імі можна кіраваць праз інтэрфейс Loomio:

1. Адкрыйце групу.
2. Адкрыйце меню групы і выберыце **Інтэграцыі з чатам**.
3. Дадайце інтэграцыю, якая адпавядае фармату даных, што прымае ваш канчатковы пункт. Для канчатковага пункта агульнага прызначэння выкарыстоўвайце фармат Mattermost/Markdown.
4. Увядзіце назву і URL прызначэння.
5. Выберыце падзеі, якія Loomio мае адпраўляць аўтаматычна.
6. Захавайце інтэграцыю і націсніце **Тэставае падключэнне**, каб адправіць тэставае паведамленне.

Выкарыстоўвайце HTTPS-адрас прызначэння з URL, які немагчыма адгадаць. Loomio патрабуе, каб адрас прызначэння вызначаўся як публічны адрас, і блакуе запыты да лакальных або прыватных сеткавых адрасоў.

Агенты і іншыя інтэграцыі могуць замест гэтага кіраваць вэбхукамі праз апісаныя ніжэй канчатковыя пункты чат-ботаў з аўтэнтыфікацыяй Bearer. Рэсурс называецца `chatbots` для сумяшчальнасці з інтэграцыямі Loomio з чатам, але ён таксама прадстаўляе выходныя вэбхукі агульнага прызначэння.

<!-- translation-section: list-webhooks -->

### Спіс вэбхукаў

Вяртае інтэграцыі з чатам, наладжаныя для групы. Уліковы запіс, якому належыць ключ API, павінен мець правы адміністратара гэтай групы. Адказ уключае URL-адрасы прызначэння, таму яго нельга раскрываць звычайным удзельнікам групы.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Адказ утрымлівае масіў `chatbots` з наступнымі палямі:

| Поле | Апісанне |
| --- | --- |
| `id` | Ідэнтыфікатар інтэграцыі для абнаўлення і выдалення |
| `group_id` | Група, якая атрымлівае падзеі |
| `name` | Назва інтэграцыі для адміністравання |
| `kind` | `webhook` для выходнага вэбхука або `matrix` для інтэграцыі з Matrix |
| `webhook_kind` | Фармат даных: `markdown`, `slack`, `discord`, `microsoft` або `webex` |
| `server` | URL-адрас прызначэння |
| `event_kinds` | Падзеі, якія адпраўляюцца аўтаматычна |
| `notification_only` | Ці ўтрымліваюць паведамленні толькі загаловак апавяшчэння |

<!-- translation-section: create-a-webhook -->

### Стварэнне вэбхука

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

Уліковы запіс, якому належыць ключ API, павінен мець правы адміністратара групы `group_id`. Перад захаваннем правяраецца, ці з’яўляецца адрас прызначэння публічным URL-адрасам.

<!-- translation-section: update-a-webhook -->

### Абнаўленне вэбхука

`PATCH /api/b2/chatbots/:id`

Перадайце ўсе палі, якія трэба змяніць. Вэбхук нельга перанесці ў іншую групу, змяніўшы `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Праверка адраса прызначэння вэбхука

Адпраўце тэставае паведамленне, сумяшчальнае з Markdown, на адрас прызначэння да або пасля захавання яго налад.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Выдаленне вэбхука

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Выдаленне канфігурацыі спыняе далейшую дастаўку паведамленняў. Яно не выдаляе ніякага змесціва групы Loomio.

<!-- translation-section: event-types -->

### Тыпы падзей

Вэбхук можа падпісацца на наступныя тыпы падзей:

| Падзея | Калі адпраўляецца |
| --- | --- |
| `new_discussion` | Пачынаецца абмеркаванне |
| `discussion_edited` | Рэдагуецца абмеркаванне |
| `new_comment` | Ствараецца каментарый |
| `poll_created` | Пачынаецца апытанне |
| `poll_edited` | Рэдагуецца апытанне |
| `poll_closing_soon` | Набліжаецца час закрыцця апытання |
| `poll_expired` | Надыходзіць час закрыцця апытання |
| `poll_closed_by_user` | Апытанне закрываюць уручную |
| `poll_reopened` | Апытанне адкрываецца зноў |
| `outcome_created` | Публікуецца выснова |
| `outcome_updated` | Абнаўляецца выснова |
| `outcome_review_due` | Надыходзіць час перагляду высновы |
| `stance_created` | Падаецца голас |
| `stance_updated` | Змяняецца голас |

Вэбхук належыць адной групе і атрымлівае з яе падзеі, на якія падпісаны. Людзі таксама могуць яўна выбраць інтэграцыю, калі дзеляцца змесцівам або адпраўляюць некаторыя апавяшчэнні, нават калі адпаведная аўтаматычная падзея не выбрана.

<!-- translation-section: http-delivery -->

### Дастаўка праз HTTP

Loomio адпраўляе асінхронны HTTP-запыт `POST` на наладжаны URL з наступным загалоўкам:

```text
Content-Type: application/json; charset=utf-8
```

Час чакання адказу на запыт складае пяць секунд. Адказ `2xx`, у тым ліку `204 No Content`, лічыцца паспяховым. Сэрвісы, якія прымаюць вэбхукі, павінны адказваць хутка, выконваць працяглую апрацоўку асінхронна і карэктна апрацоўваць паўторныя паведамленні або паведамленні, якія прыходзяць не па парадку.

Зараз Loomio не дадае подпіс вэбхука, загаловак з агульным сакрэтам, ідэнтыфікатар падзеі або ідэнтыфікатар дастаўкі. Стаўцеся да поўнага URL прызначэння як да ўліковых даных: не раскрывайце яго публічна і дадайце ў URL токен, які немагчыма адгадаць, калі сэрвіс атрымання падтрымлівае гэта. Калі патрэбная стабільная машыначытальная схема падзей або дастаўка з подпісам, выкарыстоўвайце вэбхук як апавяшчэнне пра змены і атрымлівайце актуальныя запісы праз API карыстальніка з аўтэнтыфікацыяй.

<!-- translation-section: payload-formats -->

### Фарматы даных паведамленняў

Даныя вэбхукаў — гэта паведамленні, прызначаныя для паказу ў сэрвісах чата. Яны не з'яўляюцца поўнымі серыялізаванымі запісамі Loomio. Спасылкі ў паведамленні паказваюць на адпаведнае змесціва Loomio; інтэграцыя можа дадаткова звярнуцца да API карыстальніка, калі ёй патрэбны структураваныя даныя пра актуальны стан.

| Фармат інтэграцыі | Асноўныя палі JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, абмежавана прыблізна 1 900 сімваламі |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Напрыклад, агульны фармат Markdown адпраўляе цела паведамлення наступнай структуры:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Дакладны тэкст паведамлення залежыць ад падзеі, моўных налад групы, налады адпраўкі толькі апавяшчэння і версіі Loomio. Сэрвісы атрымання павінны абапірацца на задакументаваныя палі верхняга ўзроўню выбранага фармату, а не разбіраць фармулёўкі сказаў.

<!-- translation-section: search -->

## Пошук

Шукайце абмеркаванні, каментарыі, апытанні, галасы і высновы, даступныя ўліковаму запісу з API-ключом. Вынікі ўключаюць публічнае змесціва, нават калі гэты ўліковы запіс не належыць да ўдзельнікаў адпаведнай групы; доступ да прыватнага змесціва вызначаецца звычайнымі правіламі бачнасці тэм.

`GET /api/b2/search`

<!-- translation-section: params -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `query` | Тэкст пошуку. Падтрымліваюцца дакладныя і недакладныя супадзенні |
| `group_id` | Абмежаваць вынікі адной даступнай групай |
| `org_id` | Абмежаваць вынікі даступнай бацькоўскай групай і яе даступнымі падгрупамі. Выкарыстоўвайце `0` для прамых абмеркаванняў |
| `type` | Абмежаваць вынікі адным тыпам: `Discussion`, `Comment`, `Poll`, `Stance` або `Outcome` |
| `types` | Спіс тыпаў вынікаў, падзеленых коскамі |
| `tag` | Абмежаваць вынікі тэмамі з гэтым тэгам |
| `author_id` | Абмежаваць вынікі змесцівам, створаным адным уліковым запісам. Без `query` вяртае яго нядаўнюю даступную актыўнасць |
| `order` | Задайце `authored_at_desc`, каб упарадкаваць адпаведнае змесціва паводле часу стварэння |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Адказ змяшчае масіў `search_results`. Кожны вынік вызначае знойдзены запіс і яго даступны кантэкст праз палі, сярод якіх `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` і `tags`. Палі, якія не прымяняюцца да выніку, маюць значэнне `null`.

<!-- translation-section: participation-report -->

## Справаздача аб удзеле

Вяртае тыя ж зводныя даныя аб удзеле, якія выкарыстоўваюцца ў справаздачы аб удзеле ў Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `section` | Раздзел справаздачы: `base`, `users` або `countries`. Выкарыстоўвайце `users` для актыўнасці асобных людзей |
| `group_scope` | `custom` або `my`. Састарэлае значэнне `all` трактуецца як `my`, бо ключы API карыстальніка ніколі не даюць доступу да ўсяго асобніка Loomio |
| `group_ids` | Ідэнтыфікатары груп, падзеленыя коскамі, калі `group_scope=custom`. Ідэнтыфікатары груп, да якіх уліковы запіс API не належыць, ігнаруюцца |
| `start_month` | Першы месяц для ўключэння ў фармаце `YYYY-MM`; па змаўчанні — месяц 12 месяцаў таму |
| `end_month` | Апошні месяц для ўключэння ў фармаце `YYYY-MM`; па змаўчанні — бягучы месяц |
| `interval` | Інтэрвал для раздзела `base`: `day`, `week`, `month` або `year` |
| `member_type` | Задайце `delegate` разам з `section=users`, каб вярнуць толькі дзейных дэлегатаў |

Да дэлегатаў адносяцца людзі, якія маюць актыўны статус дэлегавання ў любой выбранай групе. Іх паказчыкі сумуюцца па ўсіх выбраных групах. Радкі дэлегатаў вяртаюцца, нават калі ўсе паказчыкі актыўнасці роўныя нулю. Паказчыкі ахопліваюць тэмы, каментарыі, апытанні, галасы, высновы і рэакцыі; гэта не паказчыкі долі ўдзелу ў галасаванні. Радкі карыстальнікаў таксама ўключаюць выдадзеныя, пададзеныя і прапушчаныя бюлетэні ў галасаваннях з ідэнтыфікацыяй. Ананімныя апытанні выключаюцца з усіх персанальных паказчыкаў галасавання. `all_votes_cast` мае значэнне true толькі тады, калі выдадзены хаця б адзін бюлетэнь і пададзены ўсе выдадзеныя бюлетэні.

API прымяняе тыя ж правілы бачнасці груп, што і справаздача ў праграме. API-ключ уліковага запісу не можа раскрыць даныя справаздачы з груп, да якіх гэты ўліковы запіс не мае доступу.

<!-- translation-section: example -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Масіў `users` змяшчае поўныя радкі даных аб актыўнасці:

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

## Стварэнне абмеркавання

Стварыце абмеркаванне ад імя ўліковага запісу з API-ключом.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Група, у якой будзе тэма |
| `title` | Загаловак тэмы, абавязковы |
| `description` | Кантэкст тэмы, неабавязковы |
| `description_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |
| `recipient_audience` | `group` або null. Калі `group`, уся група атрымае апавяшчэнне пра новую тэму |
| `recipient_user_ids` | Масіў ідэнтыфікатараў карыстальнікаў для апавяшчэння або запрашэння ў тэму |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей для запрашэння ў тэму |
| `recipient_message` | Паведамленне для ўключэння ў запрашэнне па электроннай пошце |

<!-- translation-section: example-2 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Атрымаць абмеркаванне

Атрымайце абмеркаванне паводле яго ID (цэлага ліку) або ключа (радка).

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Спіс абмеркаванняў

Атрымайце спіс абмеркаванняў у групе, даступных уліковаму запісу, якому належыць ключ API. Калі група публічна бачная, людзі па-за групай могуць атрымаць спіс яе публічных абмеркаванняў; прыватныя абмеркаванні застаюцца даступнымі толькі тым, хто мае права чытаць іх у Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, абавязковы. ID групы, спіс абмеркаванняў якой трэба атрымаць |
| `status` | Радок, неабавязковы, па змаўчанні `open`. Значэнні: `open`, `closed`, `all` |
| `limit` | Цэлы лік, неабавязковы, па змаўчанні 50. Памер старонкі |
| `offset` | Цэлы лік, неабавязковы, па змаўчанні 0. Зрушэнне для падзелу на старонкі |

Для сумяшчальнасці са старымі інтэграцыямі: `per` і `from` прымаюцца як сінонімы `limit` і `offset` і будуць працаваць надалей.

<!-- translation-section: example-4 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Спіс тэм

Атрымайце спіс тэм з абмеркаваннямі і апытаннямі, даступных уліковаму запісу, якому належыць ключ API, у парадку апошняй актыўнасці. ID тэмы — гэта яе `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `limit` | Цэлы лік, неабавязковы, па змаўчанні 50. Памер старонкі |
| `offset` | Цэлы лік, неабавязковы, па змаўчанні 0. Зрушэнне для падзелу на старонкі |

<!-- translation-section: example-5 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Чытанне тэмы

Прачытайце тэму, яе ўпарадкаваны паток падзей або поўны дакумент Markdown з яе даступным змесцівам.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Прыклад

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Канцавы пункт `items` вяртае ўпарадкаваны паток падзей, у тым ліку даступныя каментарыі, апытанні, галасы і высновы. Канцавы пункт `markdown` вяртае ўсё даступнае змесціва тэмы ў адным дакуменце Markdown. Прычыны галасоў уключаюцца толькі тады, калі яны даступныя ўліковаму запісу, якому належыць ключ API.

Усе канцавыя пункты для тэм прымяняюць тыя ж правы доступу, што і інтэрфейс Loomio. Ключ API не дае доступу да тэмы, якую нельга адкрыць праз адпаведны ўліковы запіс звычайным спосабам.

<!-- translation-section: edit-discussion -->

## Рэдагаванне абмеркавання

Адрэдагуйце абмеркаванне ад імя ўліковага запісу, якому належыць ключ API. Дзейнічаюць тыя ж правы доступу, што і ў Loomio: гэты ўліковы запіс павінен мець права рэдагаваць гэтае абмеркаванне.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `title` | Абноўленая назва |
| `description` | Абноўлены кантэкст |
| `description_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |
| `recipient_audience` | `group` або null. Калі `group`, уся група атрымае апавяшчэнне пра рэдагаванне |
| `recipient_user_ids` | Масіў ID уліковых запісаў людзей, якіх трэба апавясціць або запрасіць у тэму |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей, якіх трэба запрасіць у тэму |
| `recipient_message` | Паведамленне, якое трэба ўключыць у запрашэнне па электроннай пошце |

<!-- translation-section: example-7 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Мяккае выдаленне абмеркавання

Мякка выдаліце абмеркаванне ад імя ўліковага запісу, якому належыць ключ API. Гэта выдаляе абмеркаванне, але захоўвае яго запіс.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Стварэнне каментарыя

Стварыце каментарый у абмеркаванні ад імя ўліковага запісу, якому належыць ключ API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `discussion_id` | Цэлы лік, абавязковы. ID абмеркавання, у якім трэба пакінуць каментарый |
| `body` | Тэкст каментарыя, абавязковы, калі не дададзена ўкладанне |
| `body_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |

<!-- translation-section: example-9 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Рэдагаванне каментарыя

Адрэдагуйце каментарый ад імя ўліковага запісу, якому належыць ключ API. Дзейнічаюць тыя ж правы доступу, што і ў Loomio: гэты ўліковы запіс павінен мець права рэдагаваць гэты каментарый.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `body` | Абноўлены тэкст каментарыя |
| `body_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |

<!-- translation-section: example-10 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Мяккае выдаленне каментарыя

Мякка выдаліце каментарый ад імя ўліковага запісу, якому належыць ключ API. Гэта выдаляе каментарый і хавае яго тэкст, але захоўвае яго запіс.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Стварэнне апытання

Стварыце апытанне ад імя ўліковага запісу, якому належыць ключ API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, неабавязковы, па змаўчанні null. ID групы для апытання. Калі перададзены `discussion_id`, `group_id` ігнаруецца |
| `discussion_id` | Цэлы лік, неабавязковы, па змаўчанні null. ID тэмы абмеркавання, у якую трэба дадаць гэтае апытанне |
| `title` | Радок, абавязковы. Назва апытання |
| `poll_type` | Радок, абавязковы. Значэнні: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Радок, неабавязковы. Асноўны тэкст апытання |
| `details_format` | Радок, неабавязковы, па змаўчанні `md`. Значэнні: `md` або `html` |
| `options` | Масіў радкоў. Калі `poll_type` мае значэнне `proposal`, дапушчальныя значэнні: `agree`, `disagree`, `abstain`, `block`. Калі `poll_type` мае значэнне `meeting`, перадайце радкі з датай або датай і часам у фармаце ISO 8601. Для ўсіх іншых тыпаў апытанняў дапушчальны любы радок |
| `closing_at` | Радок у фармаце ISO 8601 або null, па змаўчанні null. Прыклад: `2026-09-01T12:00:00Z`. Калі значэнне null, галасаванне адключана, а апытанне лічыцца незавершаным |
| `specified_voters_only` | Лагічнае значэнне, неабавязковае, па змаўчанні false. Калі true, галасаваць могуць толькі ўказаныя людзі. Калі false, усе ўдзельнікі групы атрымаюць запрашэнне прагаласаваць |
| `hide_results` | Радок, неабавязковы, па змаўчанні `off`. Значэнні: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Лагічнае значэнне, па змаўчанні false. Паказваць варыянты выбаршчыкам у выпадковым парадку |
| `anonymous` | Лагічнае значэнне, неабавязковае, па змаўчанні false. Хаваць асобы выбаршчыкаў |
| `recipient_audience` | `group` або null, неабавязковы, па змаўчанні null. Калі `group`, уся група атрымае апавяшчэнне |
| `notify_on_closing_soon` | Радок, неабавязковы, па змаўчанні `nobody`. Значэнні: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Масіў ID карыстальнікаў, якім трэба даслаць апавяшчэнне або запрашэнне |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей, якіх трэба запрасіць прагаласаваць |
| `recipient_message` | Паведамленне, якое трэба ўключыць у запрашэнне па электроннай пошце |
| `notify_recipients` | Лагічнае значэнне, па змаўчанні false. Калі false, дадаць людзей без адпраўкі апавяшчэнняў. Калі true, усе, каго запрашаюць гэтым запытам, атрымаюць апавяшчэнне па электроннай пошце |

<!-- translation-section: example-12 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Атрыманне апытання

Атрымайце апытанне па яго ID — цэлым ліку — або ключы — радку.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Спіс апытанняў

Атрымайце спіс апытанняў у групе, даступных уліковаму запісу, якому належыць API-ключ. Для публічна бачнай групы людзі, якія не ўваходзяць у яе, могуць атрымаць спіс яе публічных апытанняў; прыватныя апытанні застаюцца даступнымі толькі тым, хто можа чытаць іх у Loomio. Адказ уключае бягучую выснову кожнага даступнага апытання, таму вы можаце выкарыстоўваць `status=closed`, каб атрымаць спіс прапаноў, па якіх прынята рашэнне.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, абавязковы. ID групы, з якой трэба атрымаць спіс апытанняў |
| `status` | Радок, неабавязковы, па змаўчанні `active`. Значэнні: `active`, `closed`, `all` |
| `limit` | Цэлы лік, неабавязковы, па змаўчанні 50. Памер старонкі |
| `offset` | Цэлы лік, неабавязковы, па змаўчанні 0. Зрушэнне для пагінацыі |

Для сумяшчальнасці са старымі інтэграцыямі: `per` і `from` прымаюцца як альтэрнатыўныя назвы для `limit` і `offset` і будуць працаваць надалей.

<!-- translation-section: example-14 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Рэдагаванне апытання

Адрэдагуйце апытанне ад імя ўліковага запісу, якому належыць API-ключ. Дзейнічаюць тыя ж правы доступу, што і ў Loomio: уліковы запіс павінен мець права рэдагаваць гэтае апытанне.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `title` | Абноўленая назва |
| `details` | Абноўленыя падрабязнасці апытання |
| `details_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |
| `options` | Абноўленыя назвы варыянтаў. Змена варыянтаў можа паўплываць на ўжо пададзеныя галасы ў залежнасці ад стану апытання |
| `closing_at` | Радок у фармаце ISO 8601 або null |
| `recipient_audience` | `group` або null. Калі `group`, уся група атрымае апавяшчэнне |
| `recipient_user_ids` | Масіў ID карыстальнікаў, якім трэба даслаць апавяшчэнне або запрашэнне |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей, якіх трэба запрасіць прагаласаваць |
| `recipient_message` | Паведамленне, якое трэба ўключыць у запрашэнне па электроннай пошце |

<!-- translation-section: example-15 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Мяккае выдаленне апытання

Выдаліце апытанне мяккім спосабам ад імя ўліковага запісу, якому належыць API-ключ. Гэта пазначае апытанне як выдаленае, але захоўвае яго запіс.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Спіс удзельнікаў групы

Атрымайце спіс удзельнікаў групы, бачны ўладальнікам ключа API. Удзельнікі групы могуць бачыць імёны, ідэнтыфікатары, пасады і ролі іншых удзельнікаў. Адрасы электроннай пошты ўключаюцца толькі для ўласнага ўліковага запісу, якому належыць ключ API, або калі ўладальнікі ключа API маюць правы адміністратараў групы.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, абавязковы. Ідэнтыфікатар групы, спіс удзельнікаў якой трэба атрымаць |

<!-- translation-section: example-17 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Кіраванне ўдзельнікамі групы

Адпраўце спіс адрасоў электроннай пошты. На ўсе новыя адрасы будуць адпраўлены запрашэнні ў групу. У адрозненне ад атрымання спіса ўдзельнікаў, гэтая аперацыя патрабуе правоў адміністратараў групы.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, абавязковы. Ідэнтыфікатар групы, удзельнікамі якой трэба кіраваць |
| `emails` | Масіў радкоў, абавязковы. Адрасы электроннай пошты людзей, якіх трэба запрасіць у групу |
| `remove_absent` | Лагічнае значэнне. Калі true, выдаліць з групы ўсіх, чые адрасы электроннай пошты адсутнічаюць у спісе |

<!-- translation-section: example-18 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Калі вы перадасце `remove_absent=1`, усе ўдзельнікі групы, чые адрасы не ўключаны ў спіс, будуць выдалены з групы. Будзьце ўважлівыя: вы можаце выдаліць усіх удзельнікаў вашай групы.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

У адказ вяртаецца аб’ект з `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
