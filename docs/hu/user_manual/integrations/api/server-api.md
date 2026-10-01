---
title: Szerver API
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
  introduction: c2960b1e0aba5146
  authentication: 4d854b1e0542a044
  user-object: e7eddad7bd991401
  list-users: 18f5f6ee047c1f38
  example: 60d916f8463e867d
  show-user: 1c1ba85d1b9ebd89
  examples: 74ab4378e2cdd8ca
  update-user: 4bc6749e1b3f3884
  params: 527e202a75ab4fec
  examples-2: 4e83e784297e6db7
  deactivate-user: 9d8683c81bcf5c28
  examples-3: 3ee062bfd7fafd31
  reactivate-user: 8ba7b742be6c6c91
  examples-4: 6d24f2d23ee61437
  redact-user: 075310fe88abb391
  examples-5: 90a880ff2c37401a
  delete-user: cac4c8ba6315b3b7
  examples-6: 83da958b7709d5ef
  sso-profile-sync-settings: 5a1db834cf23e9c5
title_source: 370e81eb20eece44
title_generated: 4c1219c444b5c15c
---

<!-- translation-section: introduction -->

# A Loomio szerver API dokumentációja

<!-- seo-description: Kezeld a felhasználói fiókokat saját szerveren futó Loomio-telepítésen a Loomio szerver API segítségével. -->

A `/api/b3` a szerverszintű műveletekhez használható. A Loomio felhasználói fiókkal végzett, felhasználói műveletekhez használd a `/api/b2` API-t.

<!-- translation-section: authentication -->

## Hitelesítés

Állítsd a `B3_API_KEY` értékét egy 16 karakternél hosszabb titkos kulcsra.

Küldd el a kulcsot bearer tokenként:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

A hitelesítési adatokat kizárólag az `Authorization` fejlécben küldd el. A rendszer elutasítja a lekérdezési karakterláncban vagy a kérés törzsében küldött API-kulcsokat.

<!-- translation-section: user-object -->

## Felhasználói objektum

A felhasználói adatokat tartalmazó válaszok szerkezete:

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

Listázd a Loomio-telepítés összes felhasználói fiókját.

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

## Felhasználó megjelenítése

Keresd meg a felhasználót a Loomio felhasználói azonosítója vagy külső identitása alapján.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Példák

Loomio felhasználói azonosító alapján:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Külső identitás alapján:

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

## Felhasználó frissítése

Frissítsd a Loomio felhasználói azonosítója vagy külső identitása alapján megtalált felhasználó profilmezőit.

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

Loomio felhasználói azonosító alapján:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Külső identitás alapján:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

A válasz a frissített felhasználót tartalmazza:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Felhasználó deaktiválása

Deaktiváld a Loomio felhasználói azonosítója vagy külső identitása alapján megtalált felhasználói fiókot.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Példák

Loomio felhasználói azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Külső identitás alapján:

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

Aktiváld újra a Loomio-felhasználói azonosítója vagy külső identitása alapján megtalált, deaktivált felhasználói fiókot.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Külső identitás alapján:

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

## Felhasználó személyazonosító adatainak eltávolítása

A személyazonosító adatok eltávolítása megőrzi a felhasználó hozzászólásait és egyéb, általa létrehozott tartalmait a csoportjaiban, de eltávolítja az ismert személyazonosító adatokat, például a nevet, a bemutatkozást, a profilképet, az e-mail-címet, a bejelentkezési adatokat, az identitásokat és az aktív munkameneteket.

Ez az ajánlott módja egy felhasználó eltávolításának a Loomióból.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Külső identitás alapján:

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

A törlés eltávolítja a felhasználót és az általa létrehozott rekordokat. A hozzászólások eltűnnek a szálakból, a szavazatok eltűnnek a szavazásokból, és az adatbázis-kapcsolatok révén a felhasználó által létrehozott csoportok, beszélgetések, szavazások és egyéb rekordok is törlődhetnek.

Ez jelentős adatvesztéssel jár. Helyette erősen ajánlott a személyazonosító adatok eltávolítása.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Példák

Loomio-felhasználói azonosító alapján:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Külső identitás alapján:

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

## Az SSO-profilszinkronizálás beállításai

Használd ezeket a beállításokat, ha egy másik rendszer kezeli a Loomio profilmezőit.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

A `LOOMIO_DISABLE_EDIT_USER_PROFILE=1` megakadályozza, hogy a felhasználók maguk szerkesszék ezeket a mezőket:

| Mező | Megjegyzések |
| --- | --- |
| `name` | Külső szinkronizálás kezeli |
| `username` | Külső szinkronizálás kezeli |
| `email` | Külső szinkronizálás kezeli |
| `avatar_kind` / `uploaded_avatar` | Külső szinkronizálás kezeli |

A felhasználók továbbra is szerkeszthetik a csak a Loomióban tárolt mezőket, például a `short_bio` és a `location` mezőt.

A `LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` az SSO-bejelentkezés adataiból frissíti a `name` és az `email` mezőt. Hagyd megjegyzésben, vagy ne állítsd be, ha ezeket a frissítéseket kizárólag egy külső szinkronizáló szkriptnek kell végeznie.

A `LOOMIO_SSO_FORCE_USER_ATTRS` továbbra is működik a meglévő telepítéseken. Letiltja a felhasználók általi szerkesztést, és SSO-bejelentkezéskor frissíti a `name` és az `email` mezőt.
