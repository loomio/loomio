---
title: Серверны API
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
  introduction: 1b5cf772fda9bc32
  authentication: d328216d95f02e37
  user-object: 1d17335fdc62971c
  list-users: 463090ca7fcfbd84
  example: badf59034ba2e652
  show-user: eccf877aa767adc7
  examples: ab9de1e26f61e6f0
  update-user: e475f7dc482439b7
  params: '0109bee5f9b4b620'
  examples-2: 6e70ac8f815aa10b
  deactivate-user: 04d38830700581ae
  examples-3: f555fca36ba347c4
  reactivate-user: c7ac0b826773db26
  examples-4: ec48856870e1b67f
  redact-user: 84ee0f893dd72645
  examples-5: 84cd05ad29791351
  delete-user: 3723bf9fd67a96cb
  examples-6: feb9a9c0f3e77899
  sso-profile-sync-settings: d59b515dd91a0d63
title_source: 370e81eb20eece44
title_generated: 90268b173489314d
---

<!-- translation-section: introduction -->

# Дакументацыя сервернага API Loomio

<!-- seo-description: Выкарыстоўвайце серверны API Loomio, каб кіраваць уліковымі запісамі карыстальнікаў ва ўласнай інсталяцыі Loomio. -->

`/api/b3` прызначаны для аперацый на ўзроўні сервера. Для дзеянняў ад імя ўліковага запісу карыстальніка Loomio выкарыстоўвайце `/api/b2`.

<!-- translation-section: authentication -->

## Аўтэнтыфікацыя

Задайце для `B3_API_KEY` сакрэтны ключ даўжынёй больш за 16 сімвалаў.

Перадавайце ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Перадавайце ўліковыя даныя толькі ў загалоўку `Authorization`. Ключы API ў радку запыту або целе запыту адхіляюцца.

<!-- translation-section: user-object -->

## Аб’ект карыстальніка

Адказы з данымі карыстальніка маюць такую структуру:

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

## Спіс карыстальнікаў

Атрымайце спіс усіх уліковых запісаў карыстальнікаў у інсталяцыі Loomio.

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

## Звесткі пра карыстальніка

Знайдзіце ўліковы запіс па ідэнтыфікатары карыстальніка Loomio або знешнім ідэнтыфікатары.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Прыклады

Па ідэнтыфікатары карыстальніка Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Па знешнім ідэнтыфікатары:

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

## Абнаўленне звестак пра карыстальніка

Абнавіце палі профілю ўліковага запісу, знойдзенага па ідэнтыфікатары карыстальніка Loomio або знешнім ідэнтыфікатары.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Параметры

| Поле | Апісанне |
| --- | --- |
| `name` | Імя, якое паказваецца |
| `username` | Імя карыстальніка ў Loomio |
| `email` | Адрас электроннай пошты |

<!-- translation-section: examples-2 -->

### Прыклады

Па ідэнтыфікатары карыстальніка Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Па знешнім ідэнтыфікатары:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Вяртае абноўленыя звесткі пра карыстальніка:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Дэактывацыя ўліковага запісу

Дэактывуйце ўліковы запіс, знойдзены па ідэнтыфікатары карыстальніка Loomio або знешнім ідэнтыфікатары.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Прыклады

Па ідэнтыфікатары карыстальніка Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Па знешнім ідэнтыфікатары:

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

Паўторна актывуйце дэактываваны ўліковы запіс, знойдзены па ідэнтыфікатары карыстальніка Loomio або знешнім ідэнтыфікатары.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Прыклады

Па ідэнтыфікатары карыстальніка Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Па знешнім ідэнтыфікатары:

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

## Выдаленне асабістых даных карыстальніка

Пры выдаленні асабістых даных каментары і іншы змест, створаны карыстальнікам, захоўваюцца ў адпаведных групах. Выдаляюцца вядомыя даныя, якія дазваляюць ідэнтыфікаваць асобу: імя, біяграфія, фота профілю, адрас электроннай пошты, даныя для ўваходу, знешнія ідэнтыфікатары і актыўныя сеансы.

Гэта рэкамендаваны спосаб выдаліць уліковы запіс карыстальніка з Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Прыклады

Па ідэнтыфікатары карыстальніка Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Па знешнім ідэнтыфікатары:

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

## Выдаленне ўліковага запісу карыстальніка

Выдаленне прыбірае ўліковы запіс карыстальніка і створаныя ім запісы. Каментары выдаляюцца з тэм, галасы — з апытанняў. Праз сувязі ў базе даных таксама могуць быць выдалены групы, абмеркаванні, апытанні і іншыя запісы, створаныя гэтым карыстальнікам.

Гэта дзеянне можа прывесці да значнай страты даных. Настойліва рэкамендуецца замест гэтага выдаліць асабістыя даныя.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Прыклады

Па ідэнтыфікатары карыстальніка Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Па знешнім ідэнтыфікатары:

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

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` не дазваляе карыстальнікам самастойна змяняць гэтыя палі:

| Поле | Заўвагі |
| --- | --- |
| `name` | Кіруецца знешняй сінхранізацыяй |
| `username` | Кіруецца знешняй сінхранізацыяй |
| `email` | Кіруецца знешняй сінхранізацыяй |
| `avatar_kind` / `uploaded_avatar` | Кіруецца знешняй сінхранізацыяй |

Карыстальнікі па-ранейшаму могуць змяняць лакальныя палі Loomio, напрыклад `short_bio` і `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` абнаўляе `name` і `email` паводле даных уваходу праз SSO. Пакіньце гэты радок закаментаваным або не задавайце наладу, калі гэтыя палі павінен абнаўляць толькі знешні скрыпт сінхранізацыі.

`LOOMIO_SSO_FORCE_USER_ATTRS` па-ранейшаму працуе ў існых усталёўках. Гэтая налада забараняе карыстальнікам змяняць свае даныя і абнаўляе `name` і `email` пры ўваходзе праз SSO.
