---
title: Szerver API
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
  introduction: bee3f4a45e12c397
  authentication: ddb9a0bd8da813f1
  user-object: 5195b906e413d60e
  list-users: aa4551d8071be32d
  example: 60d916f8463e867d
  show-user: 4f25885d1db9e7a1
  examples: ec07faf03b02571a
  update-user: 352601bd3b8ddc43
  params: 527e202a75ab4fec
  examples-2: 608e0931e2fb96ae
  deactivate-user: 7b4345018d07ab56
  examples-3: 2f7e8aeb9328013a
  reactivate-user: 6e8219c173bd6362
  examples-4: cfdab40febda9047
  redact-user: f51737d722b281f3
  examples-5: 9e03ac32ecd2b514
  delete-user: b8415a5276b48fce
  examples-6: 411cea8b87a6620b
  sso-profile-sync-settings: 607dd9711b58bab0
title_source: 370e81eb20eece44
title_generated: 4c1219c444b5c15c
---

<!-- translation-section: introduction -->

# A Loomio szerver API dokumentációja

<!-- seo-description: A Loomio szerver API-jával kezelheted a felhasználói fiókokat egy saját üzemeltetésű Loomio-példányon. -->

A `/api/b3` szerver szintű műveletekre szolgál. A Loomio-felhasználói fiókkal végzett műveletekhez a `/api/b2` végpontot használd.

<!-- translation-section: authentication -->

## Hitelesítés

A `B3_API_KEY` értékének adj meg egy 16 karakternél hosszabb titkos kulcsot.

A kulcsot bearer tokenként küldd el:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

A hitelesítési adatokat csak az `Authorization` fejlécben küldd el. A lekérdezési karakterláncban vagy a kérés törzsében megadott API-kulcsokat a rendszer elutasítja.

<!-- translation-section: user-object -->

## Felhasználói objektum

A felhasználói válaszok szerkezete:

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

## Felhasználók listázása

Listázd a Loomio-példány összes felhasználói fiókját.

`GET /api/b3/users`

<!-- translation-section: example -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Válasz:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Felhasználó lekérése

Keresd meg a felhasználót a Loomio-felhasználói azonosítója vagy a külső azonosítója alapján.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Külső azonosító alapján:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Válasz:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Felhasználó adatainak frissítése

Frissítsd a Loomio-felhasználói azonosító vagy külső azonosító alapján megtalált felhasználó profiladatait.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Paraméterek

| Mező | Leírás |
| --- | --- |
| `name` | Megjelenített név |
| `username` | Loomio-felhasználónév |
| `email` | E-mail-cím |

<!-- translation-section: examples-2 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Külső azonosító alapján:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Válaszként a frissített felhasználót kapod:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Felhasználó deaktiválása

Deaktiváld a Loomio-felhasználói azonosító vagy külső azonosító alapján megtalált felhasználói fiókot.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Külső azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Válasz:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Felhasználó újraaktiválása

Aktiváld újra a Loomio-felhasználói azonosító vagy külső azonosító alapján megtalált, deaktivált felhasználói fiókot.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Külső azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Válasz:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Felhasználó személyes adatainak eltávolítása

A személyes adatok eltávolításakor a felhasználó hozzászólásai és a többi általa létrehozott tartalom megmaradnak a csoportjaiban. Az ismert személyazonosításra alkalmas adatok törlődnek: a név, a bemutatkozás, a profilkép, az e-mail-cím, a bejelentkezési adatok, a külső azonosítók és az aktív munkamenetek.

Ezt a módszert ajánljuk, ha el szeretnél távolítani egy felhasználót a Loomióból.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Külső azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Válasz:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Felhasználó törlése

A törlés eltávolítja a felhasználót és az általa létrehozott rekordokat. A hozzászólásai eltűnnek a témákból, a szavazatai a szavazásokból. Az adatbázis-kapcsolatok révén az általa létrehozott csoportok, beszélgetések, szavazások és más rekordok is törlődhetnek.

Ez jelentős adatvesztéssel jár. Helyette erősen ajánlott a személyes adatok eltávolítása.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Külső azonosító alapján:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Válasz:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Az SSO-profil szinkronizálásának beállításai

Ezeket a beállításokat akkor használd, ha a Loomio-profil mezőit egy másik rendszer kezeli.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

A `LOOMIO_DISABLE_EDIT_USER_PROFILE=1` megakadályozza, hogy a felhasználók maguk szerkesszék ezeket a mezőket:

| Mező | Megjegyzés |
| --- | --- |
| `name` | Külső szinkronizálás kezeli |
| `username` | Külső szinkronizálás kezeli |
| `email` | Külső szinkronizálás kezeli |
| `avatar_kind` / `uploaded_avatar` | Külső szinkronizálás kezeli |

A felhasználók továbbra is szerkeszthetik a csak a Loomióban tárolt mezőket, például a `short_bio` és a `location` mezőt.

A `LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` az SSO-bejelentkezés adataiból frissíti a `name` és az `email` mezőt. Hagyd kikommentelve vagy beállítatlanul, ha ezeket az adatokat kizárólag egy külső szinkronizáló szkriptnek kell frissítenie.

A `LOOMIO_SSO_FORCE_USER_ATTRS` a meglévő telepítéseknél továbbra is működik. Letiltja, hogy a felhasználók szerkesszék a profiljukat, és SSO-bejelentkezéskor frissíti a `name` és az `email` mezőt.
