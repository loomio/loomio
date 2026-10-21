---
title: Серверны API
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
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
  introduction: a7aa33636a63fe25
  authentication: 454d82e66f6770be
  user-object: 7103f3790b33497c
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
title_source: 370e81eb20eece44
title_generated: 90268b173489314d
---

<!-- translation-section: introduction -->

# Дакументацыя сервернага API Loomio

<!-- seo-description: Выкарыстоўвайце серверны API Loomio для кіравання ўліковымі запісамі ў самастойна размешчанай інсталяцыі Loomio. -->

`/api/b3` прызначаны для аперацый на ўзроўні сервера. Выкарыстоўвайце `/api/b2` для дзеянняў ад імя ўліковага запісу Loomio.

<!-- translation-section: authentication -->

## Аўтэнтыфікацыя

Задайце для `B3_API_KEY` сакрэтнае значэнне даўжынёй больш за 16 сімвалаў.

Перадавайце ключ як токен Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Перадавайце даныя для аўтэнтыфікацыі толькі ў загалоўку `Authorization`. Ключы API ў радках запыту або целах запытаў адхіляюцца.

<!-- translation-section: user-object -->

## Аб’ект уліковага запісу

Адказы з данымі ўліковых запісаў маюць такую структуру:

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
