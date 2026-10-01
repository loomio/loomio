---
title: Szerver API
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
  introduction: 379e4ba89c9df618
  authentication: 4d854b1e0542a044
  user-object: e7eddad7bd991401
  list-users: 51e0b842a6e86883
  example: 60d916f8463e867d
  show-user: 5142ee896b10008d
  examples: 74ab4378e2cdd8ca
  update-user: 54f5981b669af24b
  params: 131cfe6ff1893b66
  examples-2: 4e83e784297e6db7
  deactivate-user: f4a0b2e2fe10e5e6
  examples-3: 3ee062bfd7fafd31
  reactivate-user: 390bd04ec7199f8d
  examples-4: cc465604a39ed723
  redact-user: 587379079ab8ef84
  examples-5: 21cb7c29527c70f6
  delete-user: 4adac6f76eed97b6
  examples-6: 453e6872ada898f0
  sso-profile-sync-settings: 4010344e72bad294
title_source: 370e81eb20eece44
title_generated: 4c1219c444b5c15c
---

<!-- translation-section: introduction -->

# A Loomio szerver API dokumentációja

<!-- seo-description: Kezeld a felhasználói fiókokat a saját szerveren futtatott Loomio rendszerben a Loomio szerver API segítségével. -->

A `/api/b3` a szerverszintű műveletekre szolgál. A Loomio felhasználói fiókkal végzett, felhasználói szintű műveletekhez használd a `/api/b2` API-t.

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

Listázd a Loomio rendszer összes felhasználói fiókját.

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

## Felhasználó lekérdezése

Keress meg egy felhasználót a Loomio felhasználói azonosítója vagy külső identitása alapján.

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

Frissítsd a Loomio felhasználói azonosító vagy külső identitás alapján megtalált felhasználó profilmezőit.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Paraméterek

| Mező | Leírás |
| --- | --- |
| `name` | Megjelenített név |
| `username` | Loomio felhasználónév |
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

Deaktiváld a Loomio felhasználói azonosító vagy külső identitás alapján megtalált felhasználói fiókot.

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

Aktiválj újra egy deaktivált felhasználói fiókot a Loomio-felhasználóazonosítója vagy külső azonosítója alapján.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Példák

Loomio-felhasználóazonosító alapján:

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

A személyes adatok eltávolítása megőrzi a felhasználó hozzászólásait és más, általa létrehozott tartalmakat a csoportjaiban, de eltávolítja az ismert, személyazonosításra alkalmas adatokat, például a nevet, a bemutatkozást, a profilképet, az e-mail-címet, a bejelentkezési adatokat, a külső azonosítókat és az aktív munkameneteket.

Ez az ajánlott módja egy felhasználó eltávolításának a Loomióból.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Példák

Loomio-felhasználóazonosító alapján:

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

A törlés eltávolítja a felhasználót és az általa létrehozott rekordokat. A hozzászólások törlődnek a szálakból, a szavazatok törlődnek a szavazásokból, és az adatbázisban lévő kapcsolatok révén a felhasználó által létrehozott csoportok, beszélgetések, szavazások és egyéb rekordok is törlődhetnek.

Ez jelentős adatvesztéssel jár. Helyette erősen ajánlott a személyes adatok eltávolítása.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Példák

Loomio-felhasználóazonosító alapján:

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

## SSO-profilszinkronizálási beállítások

Használd ezeket a beállításokat, ha egy másik rendszer kezeli a Loomio profilmezőit.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

A `LOOMIO_DISABLE_EDIT_USER_PROFILE=1` megakadályozza, hogy a felhasználók saját maguk szerkesszék ezeket a mezőket:

| Mező | Tudnivalók |
| --- | --- |
| `name` | Külső szinkronizálás kezeli |
| `username` | Külső szinkronizálás kezeli |
| `email` | Külső szinkronizálás kezeli |
| `avatar_kind` / `uploaded_avatar` | Külső szinkronizálás kezeli |

A felhasználók továbbra is szerkeszthetik a Loomio helyi mezőit, például a `short_bio` és a `location` mezőt.

A `LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` az SSO-bejelentkezés adataiból frissíti a `name` és az `email` mezőt. Hagyd meg kommentként, vagy ne állítsd be, ha ezeket a mezőket kizárólag egy külső szinkronizáló szkriptnek kell frissítenie.

A `LOOMIO_SSO_FORCE_USER_ATTRS` a meglévő telepítéseken továbbra is működik. Letiltja a felhasználók általi szerkesztést, és SSO-bejelentkezéskor frissíti a `name` és az `email` mezőt.
