---
title: Szerver API
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
  introduction: aa125dc9f745e1a9
  authentication: 7e8a9bf9af61e255
  user-object: afe27321e49ef0cb
  list-users: 8123ae29057d56d7
  example: 7fed26f99982f674
  show-user: b646341db5d58b9a
  examples: 93210687eb70ac86
  update-user: 60c6072d33231f94
  params: 131cfe6ff1893b66
  examples-2: 7b09bcdef10e15a0
  deactivate-user: 0d2dc555116c7405
  examples-3: 2aa72b039fb4db99
  reactivate-user: 9412d9e85438896d
  examples-4: 99419c235d006ca6
  redact-user: '040168d88958cf0e'
  examples-5: abf7efe55dbccdbd
  delete-user: d7ff3cf32ea0bca2
  examples-6: e40bd4111216486d
  sso-profile-sync-settings: 4010344e72bad294
  provisioning: 2dcdf57eb71bd92f
title_source: 370e81eb20eece44
title_generated: 4c1219c444b5c15c
---

<!-- translation-section: introduction -->

# A Loomio szerver API dokumentációja

<!-- seo-description: Hozz létre felhasználói fiókokat, keresd meg a csoportokat, és kezeld a tagságokat a saját szerveren futtatott Loomio rendszerben a Loomio szerver API segítségével. -->

A `/api/server0` a szerverszintű műveletekre szolgál. A Loomio felhasználói fiókkal végzett, felhasználói szintű műveletekhez használd a `/api/user0` API-t.

Egyetlen szerverkulccsal hozhatsz létre és kezelhetsz fiókokat, keresheted meg a rendszer összes csoportját, és kezelheted a tagságaikat és szerepköreiket. Ehhez nincs szükség botfiókra, felhasználói API-kulcsra vagy csoporttagságra. A felhasználói API-kulcsokra továbbra is a felhasználó csoportjogosultságai érvényesek.

<!-- translation-section: authentication -->

## Hitelesítés

A kulcs a szerverkörnyezet `SERVER_API_KEY` beállításában található. Új telepítéseknél a `create_env.sh` hozza létre.

Küldd el a kulcsot bearer tokenként:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

A hitelesítési adatokat kizárólag az `Authorization` fejlécben küldd el. A rendszer elutasítja a lekérdezési karakterláncban vagy a kérés törzsében küldött API-kulcsokat.

<!-- translation-section: provisioning -->

## Fiókok és tagságok létrehozása és kezelése

| Metódus | Végpont | Cél |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Fiók létrehozása |
| `GET` | `/api/server0/groups` | A rendszer összes csoportjának megkeresése |
| `GET` | `/api/server0/memberships` | Egy csoport tagságainak listázása |
| `POST` | `/api/server0/memberships` | Tagok meghívása vagy a teljes taglista szinkronizálása |
| `PATCH` | `/api/server0/memberships/:id` | Csoportadmini és küldötti szerepkörök módosítása |
| `DELETE` | `/api/server0/memberships/:id` | Egy tagság visszavonása |

A meglévő fiókok frissítésére, inaktiválására, újraaktiválására, személyes adataik eltávolítására és törlésére szolgáló végpontokat alább ismertetjük.

### Fiók létrehozása

`POST /api/server0/users`

Küldj egy `user` objektumot a kötelező `email` mezővel. Az e-mail-címek elejéről és végéről a rendszer eltávolítja a szóközöket, és a címeket kisbetűssé alakítja. Az opcionális mezők: `name`, `username` és `is_admin`. Az `is_admin` itt a Loomio-példány adminját jelenti; a csoportadmini szerepköröket a tagságokon keresztül kezelheted. A felhasználónév automatikus létrehozásához hagyd ki a `username` mezőt. A rendszer elutasítja az ismeretlen mezőket.

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

A válasz HTTP `201` állapotkódot és egy `user` objektumot tartalmaz. Érvénytelen mezők vagy már használatban lévő e-mail-cím vagy felhasználónév esetén a válasz HTTP `422`. A fiók létrehozása nem küld meghívót, nem jelentkezteti be az illetőt, és nem jelöli ellenőrzöttként az e-mail-címét. Hívd meg egy csoportba a tagsági végponttal, hogy a szokásos értesítési folyamaton keresztül kapjon meghívót.

### Csoportok megkeresése

`GET /api/server0/groups`

Listázd az összes nem törölt csoportot, beleértve a privát csoportokat és a lejárt előfizetésű csoportokat is. A találatok azonosító szerint növekvő sorrendben jelennek meg. A lapozáshoz használd a `limit` (alapértelmezett és maximális értéke `50`) és az `offset` (alapértelmezett értéke `0`) paramétereket.

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

### Tagságok listázása

`GET /api/server0/memberships?group_id=123`

A `group_id` megadása kötelező. A találatok az elfogadott tagságokat és a függőben lévő meghívókat tartalmazzák, a tagság azonosítója szerint növekvő sorrendben. A visszavont tagságok nem szerepelnek közöttük. A lapozáshoz használd a `limit` (alapértelmezett és maximális értéke `50`) és az `offset` (alapértelmezett értéke `0`) paramétereket.

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

Az `admin` és a `delegate` csoportszerepkörök. Az `accepted_at` az elfogadás időbélyege, vagy `null`, amíg a meghívó függőben van. Ez a végpont nem tesz elérhetővé meghívótokeneket, bejelentkezési adatokat vagy szavazatokat.

### Tagok meghívása vagy szinkronizálása

`POST /api/server0/memberships`

Küldd el a kötelező `group_id` értéket és az `emails` tömböt. Alapértelmezés szerint ez hozzáadja a felsorolt személyek közül azokat, akiknek még nincs aktív tagságuk, és mindenki más tagságát változatlanul hagyja. Az e-mail-címek elejéről és végéről a rendszer eltávolítja a szóközöket, a címeket kisbetűssé alakítja, és kiszűri az ismétlődéseket. Az új címekhez fiókokat és függőben lévő meghívókat hoz létre. Az ugyanazon szervezet másik aktív csoportjában már tagsággal és ellenőrzött e-mail-címmel rendelkező személyek tagságát automatikusan elfogadja, a felhasználói API meghívási folyamatával megegyezően.

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

A teljes taglista szinkronizálásához állítsd a `remove_absent` értékét kifejezetten `true` értékre. A rendszer mindenkit eltávolít a csoportból és annak alcsoportjaiból, aki hiányzik a listáról. Egy üres tömb a `remove_absent: true` beállítással mindenkit eltávolít, a csoport adminjait is beleértve. Ha csak személyeket szeretnél hozzáadni, hagyd ki a `remove_absent` paramétert, vagy állítsd `false` értékre. A korábban használt `1` és `0` értékeket is elfogadja a rendszer.

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

Ugyanannak a kérésnek a megismétlése nem hoz létre ismétlődő tagságokat, és nem küldi el újra a meghívókat. Egy visszavont tagságú tag újbóli meghívása helyreállítja a hozzáférését a csoporthoz, de a korábbi admini szerepkörét nem állítja vissza. Az új meghívók és a szerepkörváltozások a szokásos értesítési folyamatot használják, és a rendszer egyetlen felhasználót sem rögzít a művelet végrehajtójaként.

Hiányzó vagy hibás formátumú e-mail-lista és érvénytelen logikai érték esetén a válasz HTTP `400`. Ha a listán inaktivált fiók szerepel, a válasz HTTP `422`; a hozzáadás előtt külön aktiváld újra a fiókot. Érvénytelen fiókadatok, előfizetési korlátok vagy más hibák esetén a rendszer visszavonja a teljes szinkronizálást, az új fiókok létrehozását és a tagságok eltávolítását is beleértve. A hozzáadáshoz aktív csoport szükséges, és az előfizetés taglétszámkorlátai továbbra is érvényesek.

### Tagsági szerepkörök frissítése

`PATCH /api/server0/memberships/:id`

Küldj egy `membership` objektumot, amely az `admin` és a `delegate` logikai mezők egyikét vagy mindkettőt tartalmazza. A kihagyott szerepkörök változatlanok maradnak. A rendszer elutasítja az ismeretlen mezőket; a végponttal nem lehet tagságot áthelyezni, meghívót elfogadni vagy szavazati súlyokat módosítani.

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

Egy `membership` objektumot ad vissza, ugyanazokkal a mezőkkel, mint a listázott tagságok. Egy szerepkör megadása létrehozza a szokásos szerepkör-értesítést; egy változatlan szerepkör ismételt megadása nem küld újabb értesítést. A szerepkörök módosításához aktív csoport szükséges. Visszavont tagságok esetén a válasz HTTP `404`.

### Egy tagság eltávolítása

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
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

`GET /api/server0/users`

<!-- translation-section: example -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
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

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Példák

Loomio felhasználói azonosító alapján:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Külső identitás alapján:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/server0/users/123
```

Külső identitás alapján:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Példák

Loomio felhasználói azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Külső identitás alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
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

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Példák

Loomio-felhasználóazonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Külső azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
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

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Példák

Loomio-felhasználóazonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Külső azonosító alapján:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
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

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Példák

Loomio-felhasználóazonosító alapján:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Külső azonosító alapján:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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
