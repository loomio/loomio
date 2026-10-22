---
title: Szerver API
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
  introduction: 7dd1c45d8c9cf38a
  authentication: 4d854b1e0542a044
  user-object: afe27321e49ef0cb
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
  provisioning: f011bf14d0a9aaf4
title_source: 370e81eb20eece44
title_generated: 4c1219c444b5c15c
---

<!-- translation-section: introduction -->

# A Loomio szerver API dokumentációja

<!-- seo-description: Hozz létre felhasználói fiókokat, keresd meg a csoportokat, és kezeld a tagságokat a saját szerveren futtatott Loomio rendszerben a Loomio szerver API segítségével. -->

A `/api/b3` a szerverszintű műveletekre szolgál. A Loomio felhasználói fiókkal végzett, felhasználói szintű műveletekhez használd a `/api/b2` API-t.

Egyetlen szerverkulccsal hozhatsz létre és kezelhetsz fiókokat, keresheted meg a rendszer összes csoportját, és kezelheted a tagságaikat és szerepköreiket. Ehhez nincs szükség botfiókra, felhasználói API-kulcsra vagy csoporttagságra. A felhasználói API-kulcsokra továbbra is a felhasználó csoportjogosultságai érvényesek.

<!-- translation-section: authentication -->

## Hitelesítés

Állítsd a `B3_API_KEY` értékét egy 16 karakternél hosszabb titkos kulcsra.

Küldd el a kulcsot bearer tokenként:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

A hitelesítési adatokat kizárólag az `Authorization` fejlécben küldd el. A rendszer elutasítja a lekérdezési karakterláncban vagy a kérés törzsében küldött API-kulcsokat.

<!-- translation-section: provisioning -->

## Fiókok és tagságok létrehozása és kezelése

| Metódus | Végpont | Cél |
| --- | --- | --- |
| `POST` | `/api/b3/users` | Fiók létrehozása |
| `GET` | `/api/b3/groups` | A rendszer összes csoportjának megkeresése |
| `GET` | `/api/b3/memberships` | Egy csoport tagságainak listázása |
| `POST` | `/api/b3/memberships` | Tagok meghívása vagy a teljes taglista szinkronizálása |
| `PATCH` | `/api/b3/memberships/:id` | Csoportadmini és küldötti szerepkörök módosítása |
| `DELETE` | `/api/b3/memberships/:id` | Egy tagság visszavonása |

A meglévő fiókok frissítésére, inaktiválására, újraaktiválására, személyes adataik eltávolítására és törlésére szolgáló végpontokat alább ismertetjük.

### Fiók létrehozása

`POST /api/b3/users`

Küldj egy `user` objektumot a kötelező `email` mezővel. Az e-mail-címek elejéről és végéről a rendszer eltávolítja a szóközöket, és a címeket kisbetűssé alakítja. Az opcionális mezők: `name`, `username` és `is_admin`. Az `is_admin` itt a Loomio-példány adminját jelenti; a csoportadmini szerepköröket a tagságokon keresztül kezelheted. A felhasználónév automatikus létrehozásához hagyd ki a `username` mezőt. A rendszer elutasítja az ismeretlen mezőket.

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

A válasz HTTP `201` állapotkódot és egy `user` objektumot tartalmaz. Érvénytelen mezők vagy már használatban lévő e-mail-cím vagy felhasználónév esetén a válasz HTTP `422`. A fiók létrehozása nem küld meghívót, nem jelentkezteti be az illetőt, és nem jelöli ellenőrzöttként az e-mail-címét. Hívd meg egy csoportba a tagsági végponttal, hogy a szokásos értesítési folyamaton keresztül kapjon meghívót.

### Csoportok megkeresése

`GET /api/b3/groups`

Listázd az összes nem törölt csoportot, beleértve a privát csoportokat és a lejárt előfizetésű csoportokat is. A találatok azonosító szerint növekvő sorrendben jelennek meg. A lapozáshoz használd a `limit` (alapértelmezett és maximális értéke `50`) és az `offset` (alapértelmezett értéke `0`) paramétereket.

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

### Tagságok listázása

`GET /api/b3/memberships?group_id=123`

A `group_id` megadása kötelező. A találatok az elfogadott tagságokat és a függőben lévő meghívókat tartalmazzák, a tagság azonosítója szerint növekvő sorrendben. A visszavont tagságok nem szerepelnek közöttük. A lapozáshoz használd a `limit` (alapértelmezett és maximális értéke `50`) és az `offset` (alapértelmezett értéke `0`) paramétereket.

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

Az `admin` és a `delegate` csoportszerepkörök. Az `accepted_at` az elfogadás időbélyege, vagy `null`, amíg a meghívó függőben van. Ez a végpont nem tesz elérhetővé meghívótokeneket, bejelentkezési adatokat vagy szavazatokat.

### Tagok meghívása vagy szinkronizálása

`POST /api/b3/memberships`

Küldd el a kötelező `group_id` értéket és az `emails` tömböt. Alapértelmezés szerint ez hozzáadja a felsorolt személyek közül azokat, akiknek még nincs aktív tagságuk, és mindenki más tagságát változatlanul hagyja. Az e-mail-címek elejéről és végéről a rendszer eltávolítja a szóközöket, a címeket kisbetűssé alakítja, és kiszűri az ismétlődéseket. Az új címekhez fiókokat és függőben lévő meghívókat hoz létre. Az ugyanazon szervezet másik aktív csoportjában már tagsággal és ellenőrzött e-mail-címmel rendelkező személyek tagságát automatikusan elfogadja, a felhasználói API meghívási folyamatával megegyezően.

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

A teljes taglista szinkronizálásához állítsd a `remove_absent` értékét kifejezetten `true` értékre. A rendszer mindenkit eltávolít a csoportból és annak alcsoportjaiból, aki hiányzik a listáról. Egy üres tömb a `remove_absent: true` beállítással mindenkit eltávolít, a csoport adminjait is beleértve. Ha csak személyeket szeretnél hozzáadni, hagyd ki a `remove_absent` paramétert, vagy állítsd `false` értékre. A korábban használt `1` és `0` értékeket is elfogadja a rendszer.

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

Ugyanannak a kérésnek a megismétlése nem hoz létre ismétlődő tagságokat, és nem küldi el újra a meghívókat. Egy visszavont tagságú tag újbóli meghívása helyreállítja a hozzáférését a csoporthoz, de a korábbi admini szerepkörét nem állítja vissza. Az új meghívók és a szerepkörváltozások a szokásos értesítési folyamatot használják, és a rendszer egyetlen felhasználót sem rögzít a művelet végrehajtójaként.

Hiányzó vagy hibás formátumú e-mail-lista és érvénytelen logikai érték esetén a válasz HTTP `400`. Ha a listán inaktivált fiók szerepel, a válasz HTTP `422`; a hozzáadás előtt külön aktiváld újra a fiókot. Érvénytelen fiókadatok, előfizetési korlátok vagy más hibák esetén a rendszer visszavonja a teljes szinkronizálást, az új fiókok létrehozását és a tagságok eltávolítását is beleértve. A hozzáadáshoz aktív csoport szükséges, és az előfizetés taglétszámkorlátai továbbra is érvényesek.

### Tagsági szerepkörök frissítése

`PATCH /api/b3/memberships/:id`

Küldj egy `membership` objektumot, amely az `admin` és a `delegate` logikai mezők egyikét vagy mindkettőt tartalmazza. A kihagyott szerepkörök változatlanok maradnak. A rendszer elutasítja az ismeretlen mezőket; a végponttal nem lehet tagságot áthelyezni, meghívót elfogadni vagy szavazati súlyokat módosítani.

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

Egy `membership` objektumot ad vissza, ugyanazokkal a mezőkkel, mint a listázott tagságok. Egy szerepkör megadása létrehozza a szokásos szerepkör-értesítést; egy változatlan szerepkör ismételt megadása nem küld újabb értesítést. A szerepkörök módosításához aktív csoport szükséges. Visszavont tagságok esetén a válasz HTTP `404`.

### Egy tagság eltávolítása

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

A válasz `{"success": true}`. Az eltávolítás visszavonja a hozzáférést a csoporthoz és annak alcsoportjaihoz, beleértve a témákhoz való hozzáférést és az aktív szavazásokon való szavazati jogot. Nem törli a fiókot, nem módosít más csoportokat, és nem szünteti meg a szálakhoz való közvetlen hozzáférést. Az eltávolítás megismétlése sikeres. Lejárt előfizetésű csoportokból is eltávolíthatsz tagságokat; törölt csoportok esetén a válasz HTTP `404`.

<!-- translation-section: user-object -->

## Felhasználói objektum

A felhasználói adatokat tartalmazó válaszok szerkezete:

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
