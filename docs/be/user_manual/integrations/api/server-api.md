---
title: Серверны API
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
  introduction: 5ed4d7bf7176fb20
  authentication: c8b030321312b22a
  user-object: 3b7210a14adea4ea
  list-users: 479e925a26aef93e
  example: badf59034ba2e652
  show-user: 1fae9bf95ea9bdf3
  examples: '06381aa6e2ef340b'
  update-user: 75bb3bfda05f6168
  params: ce2e93e145a3df55
  examples-2: 03502004dcab3998
  deactivate-user: 73ba580c820e7a3c
  examples-3: 79b6541c4b5b757c
  reactivate-user: 4b046f6f9451ce56
  examples-4: 715b4da4f7358de2
  redact-user: 8ed1c283437b61dd
  examples-5: 845cabb854080b6e
  delete-user: 7c9ddaa4702f22f6
  examples-6: 82ebd7be38b5d92c
  sso-profile-sync-settings: d59895bb751cd86a
title_source: 370e81eb20eece44
title_generated: 90268b173489314d
---

<!-- translation-section: introduction -->

# Дакументацыя сервернага API Loomio

<!-- seo-description: Выкарыстоўвайце серверны API Loomio для кіравання ўліковымі запісамі карыстальнікаў у Loomio на вашым серверы. -->

`/api/b3` прызначаны для аперацый на ўзроўні сервера. Выкарыстоўвайце `/api/b2` для дзеянняў ад імя ўліковага запісу ў Loomio.

<!-- translation-section: authentication -->

## Аўтэнтыфікацыя

Задайце для `B3_API_KEY` сакрэтнае значэнне даўжынёй больш за 16 сімвалаў.

Перадавайце ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Перадавайце ўліковыя даныя толькі ў загалоўку `Authorization`. Ключы API ў радках запыту або целах запытаў адхіляюцца.

<!-- translation-section: user-object -->

## Аб'ект уліковага запісу

Адказы з данымі ўліковага запісу маюць такую структуру:

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

## Спіс уліковых запісаў

Атрымайце спіс усіх уліковых запісаў у гэтай устаноўцы Loomio.

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

Знайдзіце ўліковы запіс па ID карыстальніка ў Loomio або знешняй ідэнтычнасці.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Прыклады

Па ID карыстальніка ў Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Па знешняй ідэнтычнасці:

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

Абнавіце палі профілю ўліковага запісу, знойдзенага па ID карыстальніка ў Loomio або знешняй ідэнтычнасці.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Параметры

| Поле | Апісанне |
| --- | --- |
| `name` | Імя для паказу |
| `username` | Імя карыстальніка ў Loomio |
| `email` | Адрас электроннай пошты |

<!-- translation-section: examples-2 -->

### Прыклады

Па ID карыстальніка ў Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Па знешняй ідэнтычнасці:

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

Дэактывуйце ўліковы запіс, знойдзены па ID карыстальніка ў Loomio або знешняй ідэнтычнасці.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Прыклады

Па ID карыстальніка ў Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Па знешняй ідэнтычнасці:

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

Паўторна актывуйце дэактываваны ўліковы запіс, знойдзены паводле ID уліковага запісу Loomio або знешняй ідэнтычнасці.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Прыклады

Паводле ID уліковага запісу Loomio:

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

Выдаленне асабістых даных захоўвае каментарыі і іншы створаны людзьмі змест у іх групах, але выдаляе вядомыя звесткі, якія дазваляюць ідэнтыфікаваць асобу: імя, біяграфію, фота профілю, адрас электроннай пошты, уліковыя даныя для ўваходу, ідэнтычнасці і актыўныя сеансы.

Гэта рэкамендаваны спосаб выдалення ўліковага запісу з Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Прыклады

Паводле ID уліковага запісу Loomio:

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

Выдаленне прыбірае ўліковы запіс і запісы, створаныя праз яго. Каментарыі выдаляюцца з тэм, галасы — з апытанняў, а групы, абмеркаванні, апытанні і іншыя запісы, створаныя праз гэты ўліковы запіс, таксама могуць быць выдаленыя праз сувязі ў базе даных.

Гэта прыводзіць да значнай страты даных. Настойліва рэкамендуецца замест гэтага выдаляць асабістыя даныя.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Прыклады

Паводле ID уліковага запісу Loomio:

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

## Налады сінхранізацыі профілю SSO

Выкарыстоўвайце гэтыя налады, калі палямі профілю Loomio кіруе іншая сістэма.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` не дазваляе людзям самастойна рэдагаваць наступныя палі:

| Поле | Заўвагі |
| --- | --- |
| `name` | Кіруецца знешняй сінхранізацыяй |
| `username` | Кіруецца знешняй сінхранізацыяй |
| `email` | Кіруецца знешняй сінхранізацыяй |
| `avatar_kind` / `uploaded_avatar` | Кіруецца знешняй сінхранізацыяй |

Людзі па-ранейшаму могуць рэдагаваць лакальныя палі Loomio, такія як `short_bio` і `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` абнаўляе `name` і `email` з даных уваходу праз SSO. Пакіньце гэты радок закаментаваным або не задавайце гэтую зменную, калі скрыпт знешняй сінхранізацыі павінен быць адзінай крыніцай гэтых абнаўленняў.

`LOOMIO_SSO_FORCE_USER_ATTRS` па-ранейшаму працуе ў існуючых усталяваннях. Гэтая налада адначасова забараняе людзям рэдагаваць палі і абнаўляе `name` і `email` пры ўваходзе праз SSO.
