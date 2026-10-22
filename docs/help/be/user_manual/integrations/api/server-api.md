---
title: Серверны API
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
  introduction: f499a409ab967e98
  authentication: 454d82e66f6770be
  user-object: 703248fc6ae72bf2
  list-users: 20bf854c15320fc7
  example: badf59034ba2e652
  show-user: 5bed11cda03a6214
  examples: 8fd0810bb4ed6ee3
  update-user: cbc7f08874ccbb8c
  params: 9457e580506f9fc5
  examples-2: 8469910fa0ec44b3
  deactivate-user: 9b4aca761d3c0b51
  examples-3: 6b25a8307b634ed8
  reactivate-user: b909bfd5c137ffd9
  examples-4: 0dc45af35d76eb8c
  redact-user: 28f99301ca0b5be5
  examples-5: 1cc144aa68b0b8ca
  delete-user: 757d960524c32b85
  examples-6: c937499934bcc504
  sso-profile-sync-settings: 37712ba0df4529aa
  provisioning: 88a08e98c12d922f
title_source: 370e81eb20eece44
title_generated: 90268b173489314d
---

<!-- translation-section: introduction -->

# Дакументацыя сервернага API Loomio

<!-- seo-description: Выкарыстоўвайце серверны API Loomio для стварэння ўліковых запісаў, пошуку груп і кіравання ўдзелам у групах у самастойна размешчанай інсталяцыі Loomio. -->

`/api/b3` прызначаны для аперацый на ўзроўні сервера. Выкарыстоўвайце `/api/b2` для дзеянняў ад імя ўліковага запісу Loomio.

Выкарыстоўвайце адзін серверны ключ для стварэння ўліковых запісаў і кіравання імі, пошуку груп ва ўсёй інсталяцыі і кіравання ўдзелам у гэтых групах і ролямі. Уліковы запіс бота, карыстальніцкі ключ API або ўдзел у групах не патрабуюцца. Карыстальніцкія ключы API па-ранейшаму падпарадкоўваюцца дазволам адпаведных уліковых запісаў у групах.

<!-- translation-section: authentication -->

## Аўтэнтыфікацыя

Задайце для `B3_API_KEY` сакрэтнае значэнне даўжынёй больш за 16 сімвалаў.

Перадавайце ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Перадавайце даныя для аўтэнтыфікацыі толькі ў загалоўку `Authorization`. Ключы API ў радках запыту або целах запытаў адхіляюцца.

<!-- translation-section: provisioning -->

## Стварэнне ўліковых запісаў і кіраванне ўдзелам у групах

| Метад | Канцавы пункт | Прызначэнне |
| --- | --- | --- |
| `POST` | `/api/b3/users` | Стварыць уліковы запіс |
| `GET` | `/api/b3/groups` | Знайсці групы ва ўсёй інсталяцыі |
| `GET` | `/api/b3/memberships` | Атрымаць спіс запісаў аб удзеле ў групе |
| `POST` | `/api/b3/memberships` | Запрасіць удзельнікаў або сінхранізаваць поўны спіс удзельнікаў |
| `PATCH` | `/api/b3/memberships/:id` | Змяніць ролі адміністратараў групы і дэлегатаў |
| `DELETE` | `/api/b3/memberships/:id` | Скасаваць адзін запіс аб удзеле ў групе |

Канцавыя пункты для абнаўлення, дэактывацыі, паўторнай актывацыі, абязлічвання і выдалення наяўных уліковых запісаў апісаны ніжэй.

### Стварэнне ўліковага запісу

`POST /api/b3/users`

Адпраўце аб’ект `user` з абавязковым полем `email`. Прабелы па краях адрасоў электроннай пошты выдаляюцца, а літары пераводзяцца ў ніжні рэгістр. Неабавязковыя палі: `name`, `username` і `is_admin`. Тут `is_admin` азначае ролю адміністратара інсталяцыі; ролі адміністратараў групы задаюцца ў запісах аб удзеле ў групе. Не ўказвайце `username`, каб згенераваць яго аўтаматычна. Невядомыя палі адхіляюцца.

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

Адказ мае код HTTP `201` і змяшчае аб’ект `user`. Пры некарэктных палях або адрасе электроннай пошты ці імені карыстальніка, якія ўжо выкарыстоўваюцца, вяртаецца HTTP `422`. Стварэнне ўліковага запісу не адпраўляе запрашэнне, не выконвае ўваход і не пазначае адрас электроннай пошты як пацверджаны. Запрасіце людзей у групу праз канцавы пункт для кіравання ўдзелам у групах, каб адправіць запрашэнне праз звычайны механізм апавяшчэнняў.

### Пошук груп

`GET /api/b3/groups`

Атрымайце спіс усіх груп, якія не былі выдалены, у тым ліку прыватных груп і груп з пратэрмінаванымі падпіскамі. Вынікі ўпарадкаваны паводле ўзрастання ID. Выкарыстоўвайце `limit` (значэнне па змаўчанні і максімум — `50`) і `offset` (па змаўчанні — `0`) для пастаронкавага прагляду.

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

### Спіс запісаў аб удзеле ў групе

`GET /api/b3/memberships?group_id=123`

Параметр `group_id` абавязковы. Вынікі ўключаюць запісы аб пацверджаным удзеле ў групе і запрашэнні, якія чакаюць прыняцця, упарадкаваныя паводле ўзрастання ID запісу аб удзеле. Скасаваныя запісы аб удзеле выключаюцца. Выкарыстоўвайце `limit` (значэнне па змаўчанні і максімум — `50`) і `offset` (па змаўчанні — `0`) для пастаронкавага прагляду.

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

`admin` і `delegate` — гэта ролі ў групе. `accepted_at` змяшчае дату і час прыняцця запрашэння або `null`, пакуль запрашэнне чакае прыняцця. Гэты канцавы пункт не раскрывае токены запрашэнняў, даныя для ўваходу або галасы.

### Запрашэнне або сінхранізацыя ўдзельнікаў

`POST /api/b3/memberships`

Адпраўце абавязковыя `group_id` і масіў `emails`. Па змаўчанні гэта дадае людзей са спіса, якія яшчэ не маюць актыўнага ўдзелу ў групе, і захоўвае ўдзел усіх астатніх. Прабелы па краях адрасоў электроннай пошты выдаляюцца, літары пераводзяцца ў ніжні рэгістр, а дублікаты выдаляюцца. Для новых адрасоў ствараюцца ўліковыя запісы і запрашэнні, якія чакаюць прыняцця. Наяўныя ўдзельнікі іншай актыўнай групы ў той жа арганізацыі з пацверджанымі адрасамі электроннай пошты прымаюцца аўтаматычна, як і пры запрашэнні праз карыстальніцкі API.

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

Каб сінхранізаваць поўны спіс удзельнікаў, яўна задайце для `remove_absent` значэнне `true`. Усе, каго няма ў спісе, выдаляюцца з гэтай групы і яе падгруп. Пусты масіў з `remove_absent: true` выдаляе ўсіх, у тым ліку адміністратараў групы. Не ўказвайце `remove_absent` або задайце для яго `false`, калі толькі дадаяце людзей. Таксама прымаюцца састарэлыя значэнні `1` і `0`.

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

Паўтарэнне таго ж запыту не стварае дублікатаў запісаў аб удзеле і не адпраўляе запрашэнні паўторна. Паўторнае запрашэнне людзей са скасаваным удзелам аднаўляе іх доступ да групы, але не аднаўляе ранейшую ролю адміністратара. Новыя запрашэнні і змены роляў выкарыстоўваюць звычайны механізм апавяшчэнняў; пры гэтым ніводны ўліковы запіс не пазначаецца як ініцыятар дзеяння.

Пры адсутнасці спіса адрасоў электроннай пошты, яго некарэктным фармаце або недапушчальных лагічных значэннях вяртаецца HTTP `400`. Калі ў спісе ёсць дэактываваны ўліковы запіс, вяртаецца HTTP `422`; перад даданнем яўна актывуйце яго паўторна. Некарэктныя даныя ўліковых запісаў, абмежаванні падпіскі або іншыя памылкі адмяняюць усю сінхранізацыю, у тым ліку стварэнне новых уліковых запісаў і выдаленне ўдзельнікаў з групы. Дадаванне патрабуе актыўнай групы і падпарадкоўваецца абмежаванням падпіскі на колькасць удзельнікаў.

### Абнаўленне роляў удзельнікаў

`PATCH /api/b3/memberships/:id`

Адпраўце аб’ект `membership` з адным або абодвума лагічнымі палямі `admin` і `delegate`. Ролі, якія не ўказаны, застаюцца без змен. Невядомыя палі адхіляюцца; гэты канцавы пункт не дазваляе перанесці запіс аб удзеле, прыняць запрашэнне або змяніць вагу галасоў.

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

Вяртаецца аб’ект `membership` з тымі ж палямі, што і ў запісе аб удзеле са спіса. Прызначэнне ролі стварае звычайнае апавяшчэнне аб ролі; паўторнае задаванне нязмененай ролі не адпраўляе апавяшчэнне паўторна. Для змены роляў патрабуецца актыўная група. Для скасаваных запісаў аб удзеле вяртаецца HTTP `404`.

### Скасаванне аднаго запісу аб удзеле

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
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

`GET /api/b3/users`

<!-- translation-section: example -->

### Прыклад

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
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

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Прыклады

Паводле ID уліковага запісу ў Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Паводле знешняй ідэнтычнасці:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/b3/users/123
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Прыклады

Паводле ID уліковага запісу ў Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
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

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Прыклады

Паводле ідэнтыфікатара ў Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
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

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Прыклады

Паводле ідэнтыфікатара ў Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
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

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Прыклады

Паводле ідэнтыфікатара ў Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Паводле знешняй ідэнтычнасці:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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
