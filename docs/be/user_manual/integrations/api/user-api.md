---
title: API карыстальніка
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
  introduction: 153a39b3292f08dd
  authentication-change: 3264ff42712c60c7
  response-size-and-related-records: 68a736295f8c776d
  endpoint-summary: 8c4adba41572f926
  groups: 8a31f2457ed0bf48
  list-groups: e2e35c3c38839f37
  get-a-group: b18305916178618e
  webhooks: 3e833010f7f86c47
  list-webhooks: bb804f94ce5da9dc
  create-a-webhook: 3a47cf5961f612c1
  update-a-webhook: 38f9a810c9736f07
  test-a-webhook-destination: 6c36fe8e91f1f0cc
  delete-a-webhook: 5dbca123b01e1d4c
  event-types: 4852cd2b89d284a1
  http-delivery: 788c2a592bc51b39
  payload-formats: 632c42eaa22892ef
  search: 7c34fef5ac319f07
  params: 55e6f2df3c5d2987
  participation-report: 549cd9768a16faf6
  params-2: 0d4eae8aef29a8c7
  example: 6700bb59171ec8f6
  create-discussion: 0db59b88083a19dc
  params-3: 513781247b7618d2
  example-2: f2d82535c19073dd
  show-discussion: d65fe903d2ad672b
  example-3: c08bf8eddc19c136
  list-discussions: a7c6cad4515dca86
  params-4: db03d756160e3094
  example-4: d2b96c7c9580c80d
  list-threads: 4e209e5286058535
  params-5: ea0b9640c41bdeaa
  example-5: 8d1532bc479677d4
  read-thread: 1987baddcf2f1da0
  example-6: 3a6f276225d43fd3
  edit-discussion: 9fae4997ce6d049d
  params-6: 376cd592d08cc1bd
  example-7: 5cf572b27954029b
  soft-delete-discussion: c0e1f89dac10402c
  example-8: eeb7353d36505f60
  create-comment: fedcb9d30c9b6aea
  params-7: 795e6756294c9dda
  example-9: 3593a520c37de8eb
  edit-comment: 761f5d25ea451d5a
  params-8: ec3e5fab925a52ab
  example-10: 8f66d1d23310a629
  soft-delete-comment: 6f1d5d6a82450ccf
  example-11: 972b24ebf5e7a7c8
  create-poll: fe74c334ec8bf3d8
  params-9: 26983bab6f92905c
  example-12: 7cd3b084944560e7
  show-poll: 7f451c9b7ca0ac96
  example-13: 97469e22c25d02c2
  list-polls: ec3ab4e8fafbac06
  params-10: 6cf920d55731e815
  example-14: 137fbaaf3431463a
  edit-poll: 23faa0f177670c20
  params-11: 1319cdeb0f445ff5
  example-15: b83fc7cbb059e94d
  soft-delete-poll: 06c8c9b2990a8e74
  example-16: 7ac8f6afc54e6ce9
  list-memberships: 3f5f2092c96bf74b
  params-12: 2356c691c8731786
  example-17: 17d08f9455c4bac4
  manage-memberships: 4268d03d5a1115b5
  params-13: ac82240d9451207d
  example-18: 90a57cb386359d3d
title_source: c23fb6526b722360
title_generated: 142976b96af3aa95
---

<!-- translation-section: introduction -->

# Дакументацыя API карыстальніка Loomio

<!-- seo-description: Выкарыстоўвайце API карыстальніка Loomio, каб ствараць абмеркаванні, каментарыі, апытанні і ніткі, а таксама кіраваць удзелам у групах з іншага праграмнага забеспячэння. -->

`/api/b2` — API для інтэграцый з Loomio, якія дзейнічаюць ад імя карыстальніка. Ён выкарыстоўвае ключ API ўліковага запісу, і кожнае дзеянне выконваецца ад імя гэтага карыстальніка.

Аперацыі з групамі залежаць ад удзелу ў групах і правоў карыстальніка, якому належыць ключ API. Правы адміністратара сервера не пашыраюць доступ ключа API да груп або іх змесціва. Для адміністравання сервера выкарыстоўвайце API сервера.

Выкарыстоўвайце ключ API ўліковага запісу Loomio, ад імя якога будуць выконвацца дзеянні. Асобны ўліковы запіс бота падыходзіць для інтэграцыі, якой не трэба атрымліваць запрашэнні да апытанняў або апавяшчэнні.

Карыстальнікі, якія ўвайшлі ў сістэму, могуць знайсці свой ключ API і ідэнтыфікатары груп на [старонцы доступу да API](/profile/api_access).

Перадавайце ключ API ў загалоўку `Authorization: Bearer`. Ключы API ў радку запыту адхіляюцца, бо URL-адрасы могуць захоўвацца ў журналах проксі-сервераў і доступу.

<!-- translation-section: authentication-change -->

### Змена спосабу аўтэнтыфікацыі

Раней ключ API можна было перадаваць у параметры URL-адраса `api_key`. Запыты з `?api_key=YOUR_API_KEY` больш не працуюць. Замест гэтага выкарыстоўвайце HTTP-загаловак `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

У прыкладах выкарыстоўваюцца `YOUR_API_KEY`, ідэнтыфікатар групы `123` і `https://www.loomio.com/`. Замяніце іх сваім ключом API, ідэнтыфікатарам групы і URL-адрасам вашага сервера Loomio.

<!-- translation-section: response-size-and-related-records -->

## Памер адказу і звязаныя запісы

Адказы API карыстальніка маюць складаны фармат: разам з асноўнымі запісамі вяртаюцца звязаныя запісы, напрыклад тэмы, групы, карыстальнікі, апытанні і рэакцыі. Гэта дазваляе кліенту запоўніць лакальнае сховішча запісаў адным запытам, але аб'ём даных можа быць большым, чым патрэбна простай інтэграцыі.

Перадайце `compact=1`, каб выключыць аб'ёмныя звязаныя запісы тэм, груп, бацькоўскіх груп, удзелу ў групах, рэакцый, тэгаў і перакладаў. Асноўныя запісы і звязаныя запісы, неабходныя для разумення іх змесціва, застануцца ў адказе.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Для дакладнейшага кіравання перадайце `exclude_types` з тыпамі запісаў у адзіночным ліку, падзеленымі прабеламі. Напрыклад, `exclude_types=group reaction` выключае звязаныя групы і рэакцыі. Распаўсюджаныя значэнні: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` і `topic_item`. Выключэнні тычацца звязаных запісаў, а не асноўнага рэсурсу, запытанага праз гэты адрас API.

Адказы з калекцыямі ўтрымліваюць `meta.total`, калі можна вызначыць дакладны памер калекцыі. Агульная колькасць вылічаецца да прымянення `limit` і `offset`. Адрасы API, якія наўмысна вяртаюць абмежаваны набор вынікаў, напрыклад пошук, не ўключаюць `meta.total` замест вяртання `null`.

<!-- translation-section: endpoint-summary -->

## Агляд адрасоў API

| Метад | Адрас API | Прызначэнне |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Атрымаць спіс груп карыстальніка, якому належыць ключ API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Атрымаць даступную групу |
| `GET` | `/api/b2/reports` | Стварыць справаздачу аб удзеле |
| `GET` | `/api/b2/search` | Шукаць даступныя абмеркаванні, каментарыі, апытанні, галасы і высновы |
| `POST` | `/api/b2/discussions` | Стварыць абмеркаванне |
| `GET` | `/api/b2/discussions/:id` | Атрымаць абмеркаванне |
| `GET` | `/api/b2/discussions` | Атрымаць спіс абмеркаванняў у групе |
| `PATCH` | `/api/b2/discussions/:id` | Рэдагаваць абмеркаванне |
| `DELETE` | `/api/b2/discussions/:id` | Мякка выдаліць абмеркаванне |
| `GET` | `/api/b2/threads` | Атрымаць спіс даступных нітак абмеркаванняў і асобных апытанняў |
| `GET` | `/api/b2/threads/:topic_id` | Атрымаць нітку |
| `GET` | `/api/b2/threads/:topic_id/items` | Атрымаць элементы ніткі па парадку |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Атрымаць поўную нітку ў фармаце Markdown |
| `POST` | `/api/b2/comments` | Стварыць каментарый або адказ |
| `PATCH` | `/api/b2/comments/:id` | Рэдагаваць каментарый |
| `DELETE` | `/api/b2/comments/:id` | Мякка выдаліць каментарый |
| `POST` | `/api/b2/polls` | Стварыць апытанне |
| `GET` | `/api/b2/polls/:id` | Атрымаць апытанне |
| `GET` | `/api/b2/polls` | Атрымаць спіс апытанняў у групе |
| `PATCH` | `/api/b2/polls/:id` | Рэдагаваць апытанне |
| `DELETE` | `/api/b2/polls/:id` | Мякка выдаліць апытанне |
| `GET` | `/api/b2/memberships` | Атрымаць спіс удзельнікаў групы |
| `POST` | `/api/b2/memberships` | Дадаць удзельнікаў і, пры неабходнасці, выдаліць тых, каго няма ў спісе |
| `GET` | `/api/b2/chatbots` | Атрымаць спіс інтэграцый з чатам і вэбхукаў групы |
| `POST` | `/api/b2/chatbots` | Стварыць інтэграцыю з чатам або вэбхук |
| `PATCH` | `/api/b2/chatbots/:id` | Абнавіць інтэграцыю з чатам або вэбхук |
| `DELETE` | `/api/b2/chatbots/:id` | Выдаліць інтэграцыю з чатам або вэбхук |
| `POST` | `/api/b2/chatbots/check` | Адправіць тэставы запыт для праверкі падключэння вэбхука |

<!-- translation-section: groups -->

## Групы

<!-- translation-section: list-groups -->

### Спіс груп

Вяртае групы, у якіх карыстальнік, якому належыць ключ API, мае актыўны ўдзел.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Адказ утрымлівае ўсе адпаведныя запісы ў масіве `groups` без падзелу на старонкі. Ён уключае бацькоўскія групы і падгрупы, у тым ліку групы, падпіска якіх цяпер неактыўная. Правярайце поле `enabled`, калі інтэграцыя павінна працаваць толькі з актыўнымі групамі.

Асноўныя палі групы:

| Поле | Апісанне |
| --- | --- |
| `id` | Лічбавы ідэнтыфікатар групы, які выкарыстоўваюць іншыя адрасы API карыстальніка |
| `key` | Сталы кароткі ключ, які выкарыстоўваецца ў URL-адрасах Loomio |
| `handle` | Зразумелы людзям ідэнтыфікатар групы |
| `name` | Назва групы |
| `full_name` | Назва групы з улікам яе бацькоўскай групы |
| `parent_id` | Лічбавы ідэнтыфікатар бацькоўскай групы для падгрупы, інакш `null` |
| `enabled` | Ці актыўныя група і яе падпіска |
| `memberships_count` | Колькасць актыўных удзельнікаў і тых, хто чакае далучэння |
| `accepted_memberships_count` | Колькасць прынятых запрашэнняў да ўдзелу |
| `pending_memberships_count` | Колькасць запрашэнняў, якія чакаюць адказу |
| `admin_memberships_count` | Колькасць адміністратараў групы |
| `delegates_count` | Колькасць дэлегатаў |
| `discussions_count` | Колькасць абмеркаванняў непасрэдна ў групе |
| `polls_count` | Колькасць апытанняў непасрэдна ў групе |
| `subgroups_count` | Колькасць падгруп |

Адказ можа таксама ўтрымліваць дадатковыя налады групы, звязаныя запісы бацькоўскай групы і звесткі пра ўдзел карыстальніка API ў групах. Кліенты павінны ігнараваць палі, якія ім не патрэбныя.

<!-- translation-section: get-a-group -->

### Атрымаць групу

Вяртае адну групу, даступную карыстальніку, якому належыць ключ API.

`GET /api/b2/groups/:id_or_key_or_handle`

Ідэнтыфікатарам можа быць лічбавы ID групы, яе ключ або кароткая назва.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Адказ утрымлівае групу ў масіве `groups` з тымі ж палямі, што і адрас API для спісу груп. Запыт групы, да якой карыстальнік з ключом API не мае доступу, вяртае памылку правоў доступу.

<!-- translation-section: webhooks -->

## Вэбхукі

API карыстальніка працуе праз запыты: інтэграцыя звяртаецца да Loomio, калі хоча прачытаць або змяніць даныя. Вэбхук групы перадае даныя ў адваротным кірунку. Loomio адпраўляе выбраныя падзеі групы на ваш адрас API адразу пасля іх узнікнення, таму інтэграцыі не трэба рэгулярна апытваць REST API пра змены.

Вэбхукі наладжваюцца асобна для кожнай групы. Для гэтага патрэбныя правы адміністратара групы. Кіраваць імі можна праз інтэрфейс Loomio:

1. Адкрыйце групу.
2. Адкрыйце меню групы і выберыце **Інтэграцыі з чатам**.
3. Дадайце інтэграцыю з фарматам даных, які прымае ваш адрас API. Для адраса агульнага прызначэння выкарыстоўвайце фармат Mattermost/Markdown.
4. Увядзіце назву і URL-адрас атрымальніка.
5. Выберыце падзеі, якія Loomio павінен адпраўляць аўтаматычна.
6. Захавайце інтэграцыю і націсніце **Тэставае падключэнне**, каб адправіць тэставае паведамленне.

Выкарыстоўвайце HTTPS-адрас атрымальніка, які немагчыма адгадаць. Loomio патрабуе, каб адрас вёў да публічнага IP-адраса, і блакуе запыты да лакальных або прыватных сеткавых адрасоў.

Агенты і іншыя інтэграцыі могуць кіраваць вэбхукамі праз апісаныя ніжэй адрасы API чат-ботаў з аўтэнтыфікацыяй Bearer. Рэсурс называецца `chatbots` дзеля сумяшчальнасці з інтэграцыямі Loomio з чатам, але ён таксама прадстаўляе звычайныя выходныя вэбхукі.

<!-- translation-section: list-webhooks -->

### Спіс вэбхукаў

Вяртае інтэграцыі з чатам, наладжаныя для групы. Карыстальнік, якому належыць ключ API, павінен быць адміністратарам гэтай групы. Адказ утрымлівае URL-адрасы атрымальнікаў, таму яго нельга паказваць звычайным удзельнікам групы.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Адказ утрымлівае масіў `chatbots` з наступнымі палямі:

| Поле | Апісанне |
| --- | --- |
| `id` | ID інтэграцыі для абнаўлення і выдалення |
| `group_id` | Група, падзеі якой перадаюцца |
| `name` | Назва інтэграцыі для адміністравання |
| `kind` | `webhook` для выходнага вэбхука або `matrix` для інтэграцыі з Matrix |
| `webhook_kind` | Фармат даных: `markdown`, `slack`, `discord`, `microsoft` або `webex` |
| `server` | URL атрымальніка |
| `event_kinds` | Падзеі, якія адпраўляюцца аўтаматычна |
| `notification_only` | Ці змяшчаюць паведамленні толькі загаловак апавяшчэння |

<!-- translation-section: create-a-webhook -->

### Стварыць вэбхук

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

Карыстальнікам, якому належыць ключ API, патрэбныя правы адміністратара групы `group_id`. Перад захаваннем правяраецца, ці вядзе URL атрымальніка на агульнадаступны адрас.

<!-- translation-section: update-a-webhook -->

### Абнавіць вэбхук

`PATCH /api/b2/chatbots/:id`

Перадайце палі, якія трэба змяніць. Змяніць групу вэбхука праз поле `group_id` нельга.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Праверыць адрас вэбхука

Адпраўце на адрас тэставае паведамленне ў фармаце, сумяшчальным з Markdown. Гэта можна зрабіць да або пасля захавання канфігурацыі.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Выдаліць вэбхук

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Пасля выдалення канфігурацыі новыя паведамленні больш не адпраўляюцца. Змесціва групы ў Loomio не выдаляецца.

<!-- translation-section: event-types -->

### Тыпы падзей

Вэбхук можа атрымліваць паведамленні пра наступныя тыпы падзей:

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
| `poll_reopened` | Апытанне адкрываюць паўторна |
| `outcome_created` | Публікуецца выснова |
| `outcome_updated` | Абнаўляецца выснова |
| `outcome_review_due` | Надыходзіць час перагледзець выснову |
| `stance_created` | Падаецца голас |
| `stance_updated` | Змяняецца голас |

Вэбхук належыць адной групе і атрымлівае паведамленні пра выбраныя падзеі гэтай групы. Людзі таксама могуць самі выбраць інтэграцыю, калі дзеляцца змесцівам або адпраўляюць некаторыя апавяшчэнні, нават калі адпаведная аўтаматычная падзея не выбрана.

<!-- translation-section: http-delivery -->

### Дастаўка праз HTTP

Loomio асінхронна адпраўляе HTTP-запыт `POST` на зададзены URL з наступным загалоўкам:

```text
Content-Type: application/json; charset=utf-8
```

Час чакання адказу складае пяць секунд. Любы адказ `2xx`, у тым ліку `204 No Content`, лічыцца паспяховым. Сэрвісам, якія прымаюць вэбхукі, варта адказваць хутка, выконваць працяглую апрацоўку асінхронна і ўлічваць магчымасць паўторнай дастаўкі або дастаўкі не ў парадку адпраўкі.

Цяпер Loomio не дадае подпіс вэбхука, загаловак з агульным сакрэтам, ID падзеі або ID дастаўкі. Лічыце поўны URL атрымальніка ўліковымі данымі і не публікуйце яго. Калі сэрвіс-атрымальнік падтрымлівае гэта, уключыце ў URL токен, які немагчыма адгадаць. Калі патрэбная стабільная схема падзей для машыннай апрацоўкі або дастаўка з подпісам, выкарыстоўвайце вэбхук як апавяшчэнне пра змену, а актуальныя запісы атрымлівайце праз API карыстальніка з аўтэнтыфікацыяй.

<!-- translation-section: payload-formats -->

### Фарматы даных

Даныя вэбхукаў — гэта паведамленні для чат-сэрвісаў, а не поўныя серыялізаваныя запісы Loomio. Спасылкі ў паведамленні паказваюць на адпаведнае змесціва ў Loomio. Калі інтэграцыі патрэбныя структураваныя актуальныя даныя, яна можа атрымаць іх праз API карыстальніка.

| Фармат інтэграцыі | Асноўныя палі JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, не больш за прыкладна 1 900 сімвалаў |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Напрыклад, паведамленне ў агульным фармаце Markdown мае такую структуру:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Дакладны тэкст паведамлення залежыць ад падзеі, мовы групы, налады адпраўкі толькі загалоўка апавяшчэння і версіі Loomio. Пры апрацоўцы абапірайцеся на задакументаваныя палі верхняга ўзроўню выбранага фармату, а не на фармулёўкі сказаў.

<!-- translation-section: search -->

## Пошук

Шукайце абмеркаванні, каментарыі, апытанні, галасы і высновы, даступныя карыстальніку з ключом API. Вынікі ўключаюць агульнадаступнае змесціва, нават калі гэты карыстальнік не ўваходзіць у адпаведную групу. Доступ да прыватнага змесціва вызначаецца звычайнымі правіламі бачнасці тэм.

`GET /api/b2/search`

<!-- translation-section: params -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `query` | Тэкст для пошуку. Падтрымліваюцца дакладныя і прыблізныя супадзенні |
| `group_id` | Абмежаваць вынікі адной даступнай групай |
| `org_id` | Абмежаваць вынікі даступнай бацькоўскай групай і яе даступнымі падгрупамі. Для прамых абмеркаванняў выкарыстоўвайце `0` |
| `type` | Абмежаваць вынікі адным тыпам: `Discussion`, `Comment`, `Poll`, `Stance` або `Outcome` |
| `types` | Спіс тыпаў вынікаў, падзеленых коскамі |
| `tag` | Абмежаваць вынікі тэмамі з гэтым тэгам |
| `author_id` | Абмежаваць вынікі змесцівам аднаго аўтара. Без `query` вяртаюцца апошнія даступныя дзеянні гэтага аўтара |
| `order` | Задайце `authored_at_desc`, каб упарадкаваць адпаведнае змесціва паводле часу стварэння |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Адказ змяшчае масіў `search_results`. Кожны вынік вызначае знойдзены запіс і яго даступны кантэкст праз палі, у тым ліку `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` і `tags`. Палі, якія не датычацца выніку, маюць значэнне `null`.

<!-- translation-section: participation-report -->

## Справаздача аб удзеле

Вяртае зводныя даныя аб удзеле, якія выкарыстоўваюцца ў справаздачы Loomio аб удзеле.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `section` | Раздзел справаздачы: `base`, `users` або `countries`. Выкарыстоўвайце `users` для даных аб дзеяннях асобных людзей |
| `group_scope` | `custom` або `my`. Устарэлае значэнне `all` разглядаецца як `my`, бо ключы API карыстальніка не даюць доступу да даных усяго асобніка Loomio |
| `group_ids` | ID груп, падзеленыя коскамі, калі зададзена `group_scope=custom`. ID груп, у якіх карыстальнік з ключом API не мае членства, ігнаруюцца |
| `start_month` | Першы месяц перыяду ў фармаце `YYYY-MM`; па змаўчанні — месяц 12 месяцаў таму |
| `end_month` | Апошні месяц перыяду ў фармаце `YYYY-MM`; па змаўчанні — бягучы месяц |
| `interval` | Інтэрвал для раздзела `base`: `day`, `week`, `month` або `year` |
| `member_type` | Задайце `delegate` разам з `section=users`, каб атрымаць даныя толькі пра дзейных дэлегатаў |

Статус дэлегата маюць людзі з актыўным членствам у якасці дэлегата ў любой з выбраных груп. Іх паказчыкі сумуюцца па ўсіх выбраных групах. Радкі дэлегатаў вяртаюцца, нават калі ўсе паказчыкі актыўнасці роўныя нулю. Падлічваюцца тэмы, каментарыі, апытанні, галасы, высновы і рэакцыі; гэтыя паказчыкі не з'яўляюцца доляй удзелу ў галасаваннях. Радкі карыстальнікаў таксама ўключаюць колькасць выдадзеных бюлетэняў для паіменнага галасавання, пададзеных галасоў і бюлетэняў без пададзенага голасу. Ананімныя апытанні не ўключаюцца ў паказчыкі галасавання асобных людзей. `all_votes_cast` мае значэнне true, толькі калі быў выдадзены хаця б адзін бюлетэнь і па кожным выдадзеным бюлетэні быў пададзены голас.

API прымяняе тыя ж правілы бачнасці груп, што і справаздача ў Loomio. Ключ API карыстальніка не дае доступу да даных справаздачы па групах, да якіх гэты карыстальнік не мае доступу.

<!-- translation-section: example -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Масіў `users` змяшчае поўныя радкі з данымі аб актыўнасці:

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

## Стварыць абмеркаванне

Стварыце абмеркаванне ад імя карыстальніка, якому належыць ключ API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Група, у якой будзе створана тэма |
| `title` | Назва тэмы, абавязковая |
| `description` | Кантэкст тэмы, неабавязковы |
| `description_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |
| `recipient_audience` | `group` або null. Калі выбрана `group`, уся група атрымае апавяшчэнне пра новую тэму |
| `recipient_user_ids` | Масіў ID карыстальнікаў, якіх трэба апавясціць або запрасіць да тэмы |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей, якіх трэба запрасіць да тэмы |
| `recipient_message` | Паведамленне для электроннага запрашэння |

<!-- translation-section: example-2 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Атрымаць абмеркаванне

Атрымайце абмеркаванне па яго лікавым ID або тэкставым ключы.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Спіс абмеркаванняў

Атрымайце спіс абмеркаванняў у групе, даступных карыстальніку, якому належыць ключ API. У публічнай групе людзі, якія не ўваходзяць у яе, могуць атрымаць спіс публічных абмеркаванняў. Прыватныя абмеркаванні даступныя толькі тым, хто можа чытаць іх у Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, абавязковы. ID групы, абмеркаванні якой трэба атрымаць |
| `status` | Радок, неабавязковы, па змаўчанні `open`. Значэнні: `open`, `closed`, `all` |
| `limit` | Цэлы лік, неабавязковы, па змаўчанні 50. Памер старонкі |
| `offset` | Цэлы лік, неабавязковы, па змаўчанні 0. Зрух для пагінацыі |

Для сумяшчальнасці `per` і `from` прымаюцца як альтэрнатыўныя назвы для `limit` і `offset` і будуць працаваць надалей.

<!-- translation-section: example-4 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Спіс тэм

Атрымайце спіс тэм абмеркаванняў і апытанняў, даступных карыстальніку, якому належыць ключ API. Тэмы ўпарадкаваны паводле апошняй актыўнасці. ID тэмы — гэта яе `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `limit` | Цэлы лік, неабавязковы, па змаўчанні 50. Памер старонкі |
| `offset` | Цэлы лік, неабавязковы, па змаўчанні 0. Зрух для пагінацыі |

<!-- translation-section: example-5 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Прачытаць тэму

Прачытайце тэму, упарадкаваны паток яе падзей або поўны даступны дакумент у фармаце Markdown.

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

Канчатковы пункт `items` вяртае ўпарадкаваны паток падзей, у тым ліку даступныя каментары, апытанні, галасы і высновы. Канчатковы пункт `markdown` вяртае ўсю даступную тэму як адзін дакумент Markdown. Прычыны галасавання ўключаюцца толькі тады, калі яны даступныя карыстальніку, якому належыць ключ API.

Для ўсіх канчатковых пунктаў тэм дзейнічаюць тыя ж правы доступу, што і ў інтэрфейсе Loomio. Ключ API не дае доступу да тэмы, якую карыстальнік звычайна не можа адкрыць.

<!-- translation-section: edit-discussion -->

## Рэдагаваць абмеркаванне

Адрэдагуйце абмеркаванне ад імя карыстальніка, якому належыць ключ API. Дзейнічаюць тыя ж правы, што і ў Loomio: гэты карыстальнік павінен мець права рэдагаваць абмеркаванне.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `title` | Абноўленая назва |
| `description` | Абноўлены кантэкст |
| `description_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |
| `recipient_audience` | `group` або null. Калі выбрана `group`, уся група атрымае апавяшчэнне пра змены |
| `recipient_user_ids` | Масіў ID карыстальнікаў, якіх трэба апавясціць або запрасіць да тэмы |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей, якіх трэба запрасіць да тэмы |
| `recipient_message` | Паведамленне для электроннага запрашэння |

<!-- translation-section: example-7 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Мякка выдаліць абмеркаванне

Мякка выдаліце абмеркаванне ад імя карыстальніка, якому належыць ключ API. Абмеркаванне будзе пазначана як выдаленае, але яго запіс застанецца.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Стварыць каментар

Стварыце каментар у абмеркаванні ад імя карыстальніка, якому належыць ключ API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `discussion_id` | Цэлы лік, абавязковы. ID абмеркавання, да якога трэба дадаць каментар |
| `body` | Тэкст каментара, абавязковы, калі няма далучанага файла |
| `body_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |

<!-- translation-section: example-9 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Рэдагаваць каментар

Адрэдагуйце каментар ад імя карыстальніка, якому належыць ключ API. Дзейнічаюць тыя ж правы, што і ў Loomio: гэты карыстальнік павінен мець права рэдагаваць каментар.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `body` | Абноўлены тэкст каментара |
| `body_format` | `md` або `html`, неабавязковы, па змаўчанні `md` |

<!-- translation-section: example-10 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Мякка выдаліць каментар

Мякка выдаліце каментар ад імя карыстальніка, якому належыць ключ API. Тэкст каментара будзе схаваны, але яго запіс застанецца.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Стварыць апытанне

Стварыце апытанне ад імя карыстальніка, якому належыць ключ API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, неабавязковы, па змаўчанні null. Ідэнтыфікатар групы для апытання. Калі перададзены `discussion_id`, значэнне `group_id` ігнаруецца |
| `discussion_id` | Цэлы лік, неабавязковы, па змаўчанні null. Ідэнтыфікатар абмеркавання, у якое трэба дадаць апытанне |
| `title` | Радок, абавязковы. Назва апытання |
| `poll_type` | Радок, абавязковы. Значэнні: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Радок, неабавязковы. Тэкст апісання апытання |
| `details_format` | Радок, неабавязковы, па змаўчанні `md`. Значэнні: `md` або `html` |
| `options` | Масіў радкоў. Калі `poll_type` мае значэнне `proposal`, дапушчальныя значэнні: `agree`, `disagree`, `abstain`, `block`. Калі `poll_type` мае значэнне `meeting`, укажыце дату або дату і час у фармаце ISO 8601. Для ўсіх іншых тыпаў апытання падыходзіць любы радок |
| `closing_at` | Радок у фармаце ISO 8601 або null, па змаўчанні null. Прыклад: `2026-09-01T12:00:00Z`. Пры значэнні null галасаванне адключана, а апытанне лічыцца незавершаным |
| `specified_voters_only` | Лагічнае значэнне, неабавязковае, па змаўчанні false. Пры значэнні true галасаваць могуць толькі ўказаныя людзі. Пры значэнні false запрашэнне прагаласаваць атрымаюць усе ў групе |
| `hide_results` | Радок, неабавязковы, па змаўчанні `off`. Значэнні: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Лагічнае значэнне, па змаўчанні false. Паказваць варыянты ўдзельнікам галасавання ў выпадковым парадку |
| `anonymous` | Лагічнае значэнне, неабавязковае, па змаўчанні false. Хаваць асобы ўдзельнікаў галасавання |
| `recipient_audience` | `group` або null, неабавязковае, па змаўчанні null. Пры значэнні `group` апавяшчэнне атрымае ўся група |
| `notify_on_closing_soon` | Радок, неабавязковы, па змаўчанні `nobody`. Значэнні: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Масіў ідэнтыфікатараў карыстальнікаў, якіх трэба апавясціць або запрасіць |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей, якіх трэба запрасіць прагаласаваць |
| `recipient_message` | Паведамленне для запрашэння па электроннай пошце |
| `notify_recipients` | Лагічнае значэнне, па змаўчанні false. Пры значэнні false людзі будуць дададзены без адпраўкі апавяшчэнняў. Пры значэнні true усе запрошаныя праз гэты запыт атрымаюць апавяшчэнне па электроннай пошце |

<!-- translation-section: example-12 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Атрымаць апытанне

Атрымайце апытанне па яго лікавым ідэнтыфікатары або радковым ключы.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Спіс апытанняў

Атрымайце спіс апытанняў групы, бачных карыстальніку, якому належыць ключ API. У агульнадаступнай групе людзі, якія не ўваходзяць у яе, могуць атрымаць спіс агульнадаступных апытанняў. Прыватныя апытанні даступныя толькі тым, хто можа праглядаць іх у Loomio. Адказ змяшчае бягучую выснову для кожнага бачнага апытання, таму праз `status=closed` можна атрымаць спіс прапаноў з прынятай высновай.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, абавязковы. Ідэнтыфікатар групы, апытанні якой трэба атрымаць |
| `status` | Радок, неабавязковы, па змаўчанні `active`. Значэнні: `active`, `closed`, `all` |
| `limit` | Цэлы лік, неабавязковы, па змаўчанні 50. Памер старонкі |
| `offset` | Цэлы лік, неабавязковы, па змаўчанні 0. Зрух для разбіўкі на старонкі |

Для сумяшчальнасці `per` і `from` прымаюцца як альтэрнатыўныя назвы для `limit` і `offset` і будуць працаваць надалей.

<!-- translation-section: example-14 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Рэдагаваць апытанне

Рэдагуйце апытанне ад імя карыстальніка, якому належыць ключ API. Дзейнічаюць тыя ж правы, што і ў Loomio: карыстальніку павінна быць дазволена рэдагаваць гэтае апытанне.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `title` | Абноўленая назва |
| `details` | Абноўленае апісанне апытання |
| `details_format` | `md` або `html`, неабавязковае, па змаўчанні `md` |
| `options` | Абноўленыя назвы варыянтаў. Змена варыянтаў можа паўплываць на існыя галасы ў залежнасці ад стану апытання |
| `closing_at` | Радок у фармаце ISO 8601 або null |
| `recipient_audience` | `group` або null. Пры значэнні `group` апавяшчэнне атрымае ўся група |
| `recipient_user_ids` | Масіў ідэнтыфікатараў карыстальнікаў, якіх трэба апавясціць або запрасіць |
| `recipient_emails` | Масіў адрасоў электроннай пошты людзей, якіх трэба запрасіць прагаласаваць |
| `recipient_message` | Паведамленне для запрашэння па электроннай пошце |

<!-- translation-section: example-15 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Мякка выдаліць апытанне

Мякка выдаліце апытанне ад імя карыстальніка, якому належыць ключ API. Апытанне будзе адхілена, але запіс пра яго застанецца.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Спіс удзельнікаў групы

Атрымайце спіс удзельнікаў груп, бачных карыстальніку, якому належыць ключ API. Удзельнікі групы могуць бачыць імёны, ідэнтыфікатары, пасады і ролі іншых удзельнікаў. Адрасы электроннай пошты даступныя толькі для ўласнага ўліковага запісу карыстальніка, якому належыць ключ API, або калі гэты карыстальнік мае правы адміністратара групы.

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

Адпраўце спіс адрасоў электроннай пошты. На ўсе новыя адрасы будуць адпраўлены запрашэнні ў групу. У адрозненне ад прагляду спіса ўдзельнікаў, для гэтай аперацыі патрэбныя правы адміністратара групы.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Параметры

| Назва | Апісанне |
| --- | --- |
| `group_id` | Цэлы лік, абавязковы. Ідэнтыфікатар групы, удзельнікамі якой трэба кіраваць |
| `emails` | Масіў радкоў, абавязковы. Адрасы электроннай пошты людзей, якіх трэба запрасіць у групу |
| `remove_absent` | Лагічнае значэнне. Пры значэнні true з групы будуць выдалены ўсе, чые адрасы электроннай пошты адсутнічаюць у спісе |

<!-- translation-section: example-18 -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Калі перадаць `remove_absent=1`, з групы будуць выдалены ўсе ўдзельнікі, не ўключаныя ў спіс. Будзьце ўважлівыя: так можна выдаліць з вашай групы ўсіх удзельнікаў.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

У адказ вяртаецца аб’ект `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
