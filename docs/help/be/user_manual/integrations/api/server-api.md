---
title: Серверны API
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
  introduction: 56319c3aa5ec1af8
  authentication: 865e7f0b407875bc
  user-object: 703248fc6ae72bf2
  list-users: fd16666f0a6c4165
  example: 0e6e853b0ae2d70b
  show-user: 99cc64fca06474d8
  examples: 180b5da009ee753a
  update-user: 3b1730ab640ca87b
  params: 9457e580506f9fc5
  examples-2: 73d607760ad24e8c
  deactivate-user: 384cc3b44fa710c8
  examples-3: a27e14a673bea203
  reactivate-user: ac2e746127dbf3e2
  examples-4: e8edfdf46add1e2c
  redact-user: 5a4c5c9a0bd57ff3
  examples-5: f3f2cad481061b9d
  delete-user: 22353119a302770d
  examples-6: 6668ffba8d1dceb2
  sso-profile-sync-settings: 37712ba0df4529aa
  provisioning: 133c85997e2e1803
title_source: 370e81eb20eece44
title_generated: 90268b173489314d
---

<!-- translation-section: introduction -->

# Дакументацыя сервернага API Loomio

<!-- seo-description: Выкарыстоўвайце серверны API Loomio для стварэння ўліковых запісаў, пошуку груп і кіравання ўдзелам у групах у самастойна размешчанай інсталяцыі Loomio. -->

`/api/server0` прызначаны для аперацый на ўзроўні сервера. Выкарыстоўвайце `/api/user0` для дзеянняў ад імя ўліковага запісу Loomio.

Выкарыстоўвайце адзін серверны ключ для стварэння ўліковых запісаў і кіравання імі, пошуку груп ва ўсёй інсталяцыі і кіравання ўдзелам у гэтых групах і ролямі. Уліковы запіс бота, карыстальніцкі ключ API або ўдзел у групах не патрабуюцца. Карыстальніцкія ключы API па-ранейшаму падпарадкоўваюцца дазволам адпаведных уліковых запісаў у групах.

<!-- translation-section: authentication -->

## Аўтэнтыфікацыя

Ключ задаецца наладай `SERVER_API_KEY` у асяроддзі сервера. Для новых інсталяцый яго генеруе `create_env.sh`.

Перадавайце ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Перадавайце даныя для аўтэнтыфікацыі толькі ў загалоўку `Authorization`. Ключы API ў радках запыту або целах запытаў адхіляюцца.

<!-- translation-section: provisioning -->

## Стварэнне ўліковых запісаў і кіраванне ўдзелам у групах

| Метад | Канцавы пункт | Прызначэнне |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Стварыць уліковы запіс |
| `GET` | `/api/server0/groups` | Знайсці групы ва ўсёй інсталяцыі |
| `GET` | `/api/server0/memberships` | Атрымаць спіс запісаў аб удзеле ў групе |
| `POST` | `/api/server0/memberships` | Запрасіць удзельнікаў або сінхранізаваць поўны спіс удзельнікаў |
| `PATCH` | `/api/server0/memberships/:id` | Змяніць ролі адміністратараў групы і дэлегатаў |
| `DELETE` | `/api/server0/memberships/:id` | Скасаваць адзін запіс аб удзеле ў групе |

Канцавыя пункты для абнаўлення, дэактывацыі, паўторнай актывацыі, абязлічвання і выдалення наяўных уліковых запісаў апісаны ніжэй.

### Стварэнне ўліковага запісу

`POST /api/server0/users`

Адпраўце аб’ект `user` з абавязковым полем `email`. Прабелы па краях адрасоў электроннай пошты выдаляюцца, а літары пераводзяцца ў ніжні рэгістр. Неабавязковыя палі: `name`, `username` і `is_admin`. Тут `is_admin` азначае ролю адміністратара інсталяцыі; ролі адміністратараў групы задаюцца ў запісах аб удзеле ў групе. Не ўказвайце `username`, каб згенераваць яго аўтаматычна. Невядомыя палі адхіляюцца.

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

Адказ мае код HTTP `201` і змяшчае аб’ект `user`. Пры некарэктных палях або адрасе электроннай пошты ці імені карыстальніка, якія ўжо выкарыстоўваюцца, вяртаецца HTTP `422`. Стварэнне ўліковага запісу не адпраўляе запрашэнне, не выконвае ўваход і не пазначае адрас электроннай пошты як пацверджаны. Запрасіце людзей у групу праз канцавы пункт для кіравання ўдзелам у групах, каб адправіць запрашэнне праз звычайны механізм апавяшчэнняў.

### Пошук груп

`GET /api/server0/groups`

Атрымайце спіс усіх груп, якія не былі выдалены, у тым ліку прыватных груп і груп з пратэрмінаванымі падпіскамі. Вынікі ўпарадкаваны паводле ўзрастання ID. Выкарыстоўвайце `limit` (значэнне па змаўчанні і максімум — `50`) і `offset` (па змаўчанні — `0`) для пастаронкавага прагляду.

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

### Спіс запісаў аб удзеле ў групе

`GET /api/server0/memberships?group_id=123`

Параметр `group_id` абавязковы. Вынікі ўключаюць запісы аб пацверджаным удзеле ў групе і запрашэнні, якія чакаюць прыняцця, упарадкаваныя паводле ўзрастання ID запісу аб удзеле. Скасаваныя запісы аб удзеле выключаюцца. Выкарыстоўвайце `limit` (значэнне па змаўчанні і максімум — `50`) і `offset` (па змаўчанні — `0`) для пастаронкавага прагляду.

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

`admin` і `delegate` — гэта ролі ў групе. `accepted_at` змяшчае дату і час прыняцця запрашэння або `null`, пакуль запрашэнне чакае прыняцця. Гэты канцавы пункт не раскрывае токены запрашэнняў, даныя для ўваходу або галасы.

### Запрашэнне або сінхранізацыя ўдзельнікаў

`POST /api/server0/memberships`

Адпраўце абавязковыя `group_id` і масіў `emails`. Па змаўчанні гэта дадае людзей са спіса, якія яшчэ не маюць актыўнага ўдзелу ў групе, і захоўвае ўдзел усіх астатніх. Прабелы па краях адрасоў электроннай пошты выдаляюцца, літары пераводзяцца ў ніжні рэгістр, а дублікаты выдаляюцца. Для новых адрасоў ствараюцца ўліковыя запісы і запрашэнні, якія чакаюць прыняцця. Наяўныя ўдзельнікі іншай актыўнай групы ў той жа арганізацыі з пацверджанымі адрасамі электроннай пошты прымаюцца аўтаматычна, як і пры запрашэнні праз карыстальніцкі API.

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

Каб сінхранізаваць поўны спіс удзельнікаў, яўна задайце для `remove_absent` значэнне `true`. Усе, каго няма ў спісе, выдаляюцца з гэтай групы і яе падгруп. Пусты масіў з `remove_absent: true` выдаляе ўсіх, у тым ліку адміністратараў групы. Не ўказвайце `remove_absent` або задайце для яго `false`, калі толькі дадаяце людзей. Таксама прымаюцца састарэлыя значэнні `1` і `0`.

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

Паўтарэнне таго ж запыту не стварае дублікатаў запісаў аб удзеле і не адпраўляе запрашэнні паўторна. Паўторнае запрашэнне людзей са скасаваным удзелам аднаўляе іх доступ да групы, але не аднаўляе ранейшую ролю адміністратара. Новыя запрашэнні і змены роляў выкарыстоўваюць звычайны механізм апавяшчэнняў; пры гэтым ніводны ўліковы запіс не пазначаецца як ініцыятар дзеяння.

Пры адсутнасці спіса адрасоў электроннай пошты, яго некарэктным фармаце або недапушчальных лагічных значэннях вяртаецца HTTP `400`. Калі ў спісе ёсць дэактываваны ўліковы запіс, вяртаецца HTTP `422`; перад даданнем яўна актывуйце яго паўторна. Некарэктныя даныя ўліковых запісаў, абмежаванні падпіскі або іншыя памылкі адмяняюць усю сінхранізацыю, у тым ліку стварэнне новых уліковых запісаў і выдаленне ўдзельнікаў з групы. Дадаванне патрабуе актыўнай групы і падпарадкоўваецца абмежаванням падпіскі на колькасць удзельнікаў.

### Абнаўленне роляў удзельнікаў

`PATCH /api/server0/memberships/:id`

Адпраўце аб’ект `membership` з адным або абодвума лагічнымі палямі `admin` і `delegate`. Ролі, якія не ўказаны, застаюцца без змен. Невядомыя палі адхіляюцца; гэты канцавы пункт не дазваляе перанесці запіс аб удзеле, прыняць запрашэнне або змяніць вагу галасоў.

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

Вяртаецца аб’ект `membership` з тымі ж палямі, што і ў запісе аб удзеле са спіса. Прызначэнне ролі стварае звычайнае апавяшчэнне аб ролі; паўторнае задаванне нязмененай ролі не адпраўляе апавяшчэнне паўторна. Для змены роляў патрабуецца актыўная група. Для скасаваных запісаў аб удзеле вяртаецца HTTP `404`.

### Скасаванне аднаго запісу аб удзеле

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Вяртаецца `{"success": true}`. Выдаленне скасоўвае доступ да групы і яе падгруп, у тым ліку доступ да тэм і права галасаваць у актыўных апытаннях. Яно не выдаляе ўліковы запіс, не змяняе іншыя групы і не скасоўвае непасрэдна прадастаўлены доступ да тэм. Паўторнае выдаленне завяршаецца паспяхова. Вы можаце скасоўваць удзел у групах з пратэрмінаванымі падпіскамі; для выдаленых груп вяртаецца HTTP `404`.

<!-- translation-section: user-object -->

## Аб’ект уліковага запісу

Адказы з данымі ўліковых запісаў маюць такую структуру:

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

## Спіс уліковых запісаў

Атрымайце спіс усіх уліковых запісаў у інсталяцыі Loomio.

`GET /api/server0/users`

<!-- translation-section: example -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Вяртае:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Прагляд уліковага запісу

Знайдзіце ўліковы запіс паводле ID у Loomio або знешняй ідэнтычнасці.

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Прыклады

Паводле ID уліковага запісу ў Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Паводле знешняй ідэнтычнасці:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Вяртае:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Абнаўленне ўліковага запісу

Абнавіце палі профілю ўліковага запісу, знойдзенага паводле ID у Loomio або знешняй ідэнтычнасці.

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Параметры

| Поле | Апісанне |
| --- | --- |
| `name` | Імя для адлюстравання |
| `username` | Імя карыстальніка ў Loomio |
| `email` | Адрас электроннай пошты |

<!-- translation-section: examples-2 -->

### Прыклады

Паводле ID уліковага запісу ў Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/123
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Вяртае абноўлены ўліковы запіс:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Дэактывацыя ўліковага запісу

Дэактывуйце ўліковы запіс, знойдзены паводле ID у Loomio або знешняй ідэнтычнасці.

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Прыклады

Паводле ID уліковага запісу ў Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
```

Вяртае:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Паўторная актывацыя ўліковага запісу

Паўторна актывуйце дэактываваны ўліковы запіс, знойдзены паводле ідэнтыфікатара ў Loomio або знешняй ідэнтычнасці.

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Прыклады

Паводле ідэнтыфікатара ў Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
```

Вяртае:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Выдаленне асабістых даных

Выдаленне асабістых даных захоўвае каментарыі і іншы створаны карыстальнікамі кантэнт у іх групах, але выдаляе вядомыя звесткі, якія дазваляюць ідэнтыфікаваць асобу: імя, біяграфію, фота профілю, адрас электроннай пошты, уліковыя даныя для ўваходу, ідэнтычнасці і актыўныя сеансы.

Гэта рэкамендаваны спосаб выдалення ўліковага запісу з Loomio.

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Прыклады

Паводле ідэнтыфікатара ў Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
```

Вяртае:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Выдаленне ўліковага запісу

Выдаленне прыбірае ўліковы запіс і створаныя праз яго запісы. Каментарыі выдаляюцца з тэм, галасы — з апытанняў, а групы, абмеркаванні, апытанні і іншыя запісы, створаныя праз гэты ўліковы запіс, таксама могуць быць выдаленыя праз сувязі ў базе даных.

Гэта прыводзіць да значнай страты даных. Настойліва рэкамендуецца замест гэтага выдаліць асабістыя даныя.

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Прыклады

Паводле ідэнтыфікатара ў Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Вяртае:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Налады сінхранізацыі профілю праз SSO

Выкарыстоўвайце гэтыя налады, калі палямі профілю Loomio кіруе іншая сістэма.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` забараняе карыстальнікам самастойна рэдагаваць гэтыя палі:

| Поле | Заўвагі |
| --- | --- |
| `name` | Кіруецца знешняй сінхранізацыяй |
| `username` | Кіруецца знешняй сінхранізацыяй |
| `email` | Кіруецца знешняй сінхранізацыяй |
| `avatar_kind` / `uploaded_avatar` | Кіруецца знешняй сінхранізацыяй |

Карыстальнікі па-ранейшаму могуць рэдагаваць лакальныя палі Loomio, напрыклад `short_bio` і `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` абнаўляе `name` і `email` з даных уваходу праз SSO. Пакіньце гэту зменную закаментаванай або не задавайце яе, калі знешні скрыпт сінхранізацыі павінен быць адзінай крыніцай гэтых абнаўленняў.

`LOOMIO_SSO_FORCE_USER_ATTRS` па-ранейшаму працуе ў існых усталёўках. Гэта зменная адначасова забараняе карыстальнікам рэдагаваць палі і абнаўляе `name` і `email` пры ўваходзе праз SSO.
