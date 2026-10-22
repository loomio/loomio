---
title: Palvelimen API
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
  introduction: f02a8827ac2b70a9
  authentication: 76c4ebae56d9e683
  user-object: 902fa5b6ecd9535b
  list-users: dfecbabec62a5002
  example: 3849933612930aeb
  show-user: 488193629bd5a028
  examples: 04b02e2452f8d449
  update-user: '09daabaa021ff5fb'
  params: b29f72f9f8367e50
  examples-2: 0fad539c38c70148
  deactivate-user: cf07e34cc9850e2e
  examples-3: '082ccd9158a69ae7'
  reactivate-user: 1a743e4153c6eea6
  examples-4: '09d1f8c1ba598db8'
  redact-user: 6c1a2029e16a9f70
  examples-5: ddba94c3f79d9465
  delete-user: e2dbdde89b12df85
  examples-6: 5ee22a0723a6b25f
  sso-profile-sync-settings: 0e8908951c1924fc
  provisioning: 81f891b448f577cf
title_source: 370e81eb20eece44
title_generated: 6b950a4b886b152a
---

<!-- translation-section: introduction -->

# Loomion palvelimen API:n dokumentaatio

<!-- seo-description: Luo käyttäjätilejä, etsi ryhmiä ja hallitse jäsenyyksiä itse ylläpitämässäsi Loomio-asennuksessa Loomion palvelimen API:n avulla. -->

`/api/b3` on tarkoitettu palvelintason toimintoihin. Käytä `/api/b2`-rajapintaa käyttäjäkohtaisiin toimintoihin, jotka suoritetaan Loomion käyttäjätilillä.

Yhdellä palvelinavaimella voit luoda ja hallita tilejä, etsiä ryhmiä koko asennuksesta ja hallita niiden jäsenyyksiä ja rooleja. Bottitiliä, käyttäjän API-avainta tai ryhmien jäsenyyttä ei tarvita. Käyttäjien API-avaimet noudattavat edelleen käyttäjän ryhmäkohtaisia käyttöoikeuksia.

<!-- translation-section: authentication -->

## Todennus

Aseta `B3_API_KEY`-muuttujan arvoksi yli 16 merkin pituinen salainen avain.

Lähetä avain bearer-tokenina:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Lähetä tunnistetiedot vain `Authorization`-otsakkeessa. Kyselymerkkijonoissa tai pyyntöjen rungoissa lähetetyt API-avaimet hylätään.

<!-- translation-section: provisioning -->

## Tilien ja jäsenyyksien luominen ja hallinta

| Metodi | Päätepiste | Tarkoitus |
| --- | --- | --- |
| `POST` | `/api/b3/users` | Luo tili |
| `GET` | `/api/b3/groups` | Etsi ryhmiä koko asennuksesta |
| `GET` | `/api/b3/memberships` | Listaa ryhmän jäsenyydet |
| `POST` | `/api/b3/memberships` | Kutsu jäseniä tai synkronoi koko jäsenluettelo |
| `PATCH` | `/api/b3/memberships/:id` | Muuta ryhmän ylläpitäjän ja edustajan rooleja |
| `DELETE` | `/api/b3/memberships/:id` | Peru yksittäinen jäsenyys |

Olemassa olevien tilien päivittämisen, käytöstä poistamisen, uudelleenaktivoinnin, henkilötietojen poistamisen ja tilien poistamisen päätepisteet kuvataan alempana.

### Luo tili

`POST /api/b3/users`

Lähetä `user`-objekti, joka sisältää pakollisen `email`-kentän. Sähköpostiosoitteiden alusta ja lopusta poistetaan tyhjämerkit, ja osoitteet muunnetaan pieniksi kirjaimiksi. Valinnaiset kentät ovat `name`, `username` ja `is_admin`. Tässä `is_admin` tarkoittaa koko asennuksen ylläpitäjää; ryhmän ylläpitäjärooleja hallitaan jäsenyyksien kautta. Jätä `username` pois, jos haluat luoda käyttäjänimen automaattisesti. Tuntemattomat kentät hylätään.

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

Vastauksena palautetaan HTTP `201` ja `user`-objekti. Virheelliset kentät tai jo käytössä oleva sähköpostiosoite tai käyttäjänimi palauttavat HTTP `422`. Tilin luominen ei lähetä kutsua, kirjaa henkilöä sisään eikä merkitse hänen sähköpostiosoitettaan vahvistetuksi. Kutsu hänet ryhmään jäsenyyksien päätepisteen kautta, jolloin kutsu lähetetään tavallisen ilmoitusprosessin mukaisesti.

### Etsi ryhmiä

`GET /api/b3/groups`

Listaa kaikki ryhmät, joita ei ole poistettu, mukaan lukien yksityiset ryhmät ja ryhmät, joiden tilaus on päättynyt. Tulokset järjestetään tunnuksen mukaan nousevaan järjestykseen. Selaa tuloksia sivuittain parametreilla `limit` (oletus ja enimmäisarvo `50`) ja `offset` (oletus `0`).

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

### Listaa jäsenyydet

`GET /api/b3/memberships?group_id=123`

`group_id` on pakollinen. Tulokset sisältävät hyväksytyt jäsenyydet ja odottavat kutsut jäsenyyden tunnuksen mukaan nousevassa järjestyksessä. Perutut jäsenyydet jätetään pois. Käytä sivutukseen parametreja `limit` (oletus ja enimmäisarvo `50`) ja `offset` (oletus `0`).

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

`admin` ja `delegate` ovat ryhmän rooleja. `accepted_at` on hyväksymisen aikaleima tai `null`, kun kutsu odottaa hyväksymistä. Tämä päätepiste ei paljasta kutsutunnisteita, kirjautumistietoja eikä ääniä.

### Kutsu tai synkronoi jäseniä

`POST /api/b3/memberships`

Lähetä pakolliset `group_id` ja `emails`-taulukko. Oletusarvoisesti tämä lisää luettelon henkilöt, joilla ei vielä ole aktiivista jäsenyyttä, ja säilyttää muiden jäsenyydet ennallaan. Sähköpostiosoitteiden alusta ja lopusta poistetaan tyhjämerkit, osoitteet muunnetaan pieniksi kirjaimiksi ja kaksoiskappaleet poistetaan. Uusille osoitteille luodaan tilit ja odottavat kutsut. Saman organisaation toisen aktiivisen ryhmän olemassa olevat vahvistetut jäsenet hyväksytään automaattisesti käyttäjän API:n kutsuprosessin mukaisesti.

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

Synkronoi koko jäsenluettelo asettamalla `remove_absent` nimenomaisesti arvoon `true`. Kaikki luettelosta puuttuvat poistetaan kyseisestä ryhmästä ja sen alaryhmistä. Tyhjä taulukko yhdessä asetuksen `remove_absent: true` kanssa poistaa kaikki, myös ryhmän ylläpitäjät. Jätä `remove_absent` pois tai aseta sen arvoksi `false`, kun vain lisäät henkilöitä. Myös vanhat arvot `1` ja `0` hyväksytään.

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

Saman pyynnön toistaminen ei luo päällekkäisiä jäsenyyksiä eikä lähetä kutsuja uudelleen. Jäsenen, jonka jäsenyys on peruttu, kutsuminen uudelleen palauttaa hänen pääsynsä ryhmään mutta ei aiempaa ylläpitäjäroolia. Uudet kutsut ja roolimuutokset käyttävät tavallista ilmoitusprosessia, eikä ketään käyttäjää kirjata toiminnon tekijäksi.

Puuttuvat tai väärin muotoillut sähköpostiluettelot ja virheelliset totuusarvot palauttavat HTTP `400`. Luettelossa oleva käytöstä poistettu tili palauttaa HTTP `422`; aktivoi se erikseen uudelleen ennen lisäämistä. Virheelliset tilitiedot, tilauksen rajoitukset tai muut virheet peruuttavat koko synkronoinnin, mukaan lukien uudet tilit ja jäsenyyksien poistot. Lisääminen edellyttää aktiivista ryhmää, ja tilauksen jäsenmäärärajoitukset ovat voimassa.

### Päivitä jäsenyyden roolit

`PATCH /api/b3/memberships/:id`

Lähetä `membership`-objekti, joka sisältää joko toisen tai molemmat totuusarvokentistä `admin` ja `delegate`. Pois jätetyt roolit säilyvät ennallaan. Tuntemattomat kentät hylätään; päätepisteellä ei voi siirtää jäsenyyttä, hyväksyä kutsua eikä muuttaa äänten painotuksia.

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

Palauttaa `membership`-objektin, jossa on samat kentät kuin listatussa jäsenyydessä. Roolin myöntäminen luo tavallisen rooli-ilmoituksen; muuttumattoman roolin lähettäminen uudelleen ei lähetä uutta ilmoitusta. Roolimuutokset edellyttävät aktiivista ryhmää. Perutut jäsenyydet palauttavat HTTP `404`.

### Poista yksittäinen jäsenyys

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Palauttaa `{"success": true}`. Poistaminen peruu pääsyn ryhmään ja sen alaryhmiin, mukaan lukien pääsyn aiheisiin ja äänioikeuden aktiivisissa kyselyissä. Se ei poista tiliä, muuta muita ryhmiä eikä poista suoraa pääsyä ketjuihin. Poistamisen toistaminen onnistuu. Voit poistaa jäsenyyksiä ryhmistä, joiden tilaus on päättynyt; poistetut ryhmät palauttavat HTTP `404`.

<!-- translation-section: user-object -->

## Käyttäjäobjekti

Käyttäjätietoja sisältävien vastausten rakenne on seuraava:

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

## Listaa käyttäjät

Listaa kaikki Loomio-asennuksen käyttäjätilit.

`GET /api/b3/users`

<!-- translation-section: example -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Palauttaa:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Näytä käyttäjä

Etsi käyttäjä Loomion käyttäjä-ID:n tai ulkoisen identiteetin perusteella.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Esimerkkejä

Loomion käyttäjä-ID:n perusteella:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Ulkoisen identiteetin perusteella:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Palauttaa:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Päivitä käyttäjä

Päivitä Loomion käyttäjä-ID:n tai ulkoisen identiteetin perusteella löydetyn käyttäjän profiilikentät.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Parametrit

| Kenttä | Kuvaus |
| --- | --- |
| `name` | Näyttönimi |
| `username` | Loomion käyttäjänimi |
| `email` | Sähköpostiosoite |

<!-- translation-section: examples-2 -->

### Esimerkkejä

Loomion käyttäjä-ID:n perusteella:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Ulkoisen identiteetin perusteella:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Palauttaa päivitetyn käyttäjän:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Poista käyttäjätili käytöstä

Poista käytöstä käyttäjätili, joka on löydetty Loomion käyttäjä-ID:n tai ulkoisen identiteetin perusteella.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Esimerkkejä

Loomion käyttäjä-ID:n perusteella:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Ulkoisen identiteetin perusteella:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Palauttaa:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Aktivoi käyttäjä uudelleen

Aktivoi käytöstä poistettu käyttäjätili uudelleen Loomion käyttäjätunnisteen tai ulkoisen identiteetin perusteella.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Esimerkkejä

Loomion käyttäjätunnisteen perusteella:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Ulkoisen identiteetin perusteella:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Palauttaa:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Poista käyttäjän tunnistetiedot

Tunnistetietojen poistaminen säilyttää käyttäjän kommentit ja muun käyttäjän luoman sisällön hänen ryhmissään, mutta poistaa tiedossa olevat henkilön tunnistamiseen käytettävät tiedot, kuten nimen, esittelyn, profiilikuvan, sähköpostiosoitteen, kirjautumistiedot, identiteetit ja aktiiviset istunnot.

Tämä on suositeltu tapa poistaa käyttäjä Loomiosta.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Esimerkkejä

Loomion käyttäjätunnisteen perusteella:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Ulkoisen identiteetin perusteella:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Palauttaa:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Poista käyttäjä

Poistaminen poistaa käyttäjän ja hänen luomansa tietueet. Kommentit poistetaan ketjuista ja äänet kyselyistä. Myös käyttäjän luomat ryhmät, keskustelut, kyselyt ja muut tietueet voivat poistua tietokannan tietueiden välisten suhteiden kautta.

Tämä poistaa laajasti tietoja. Käyttäjän tunnistetietojen poistaminen on vahvasti suositeltu vaihtoehto.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Esimerkkejä

Loomion käyttäjätunnisteen perusteella:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Ulkoisen identiteetin perusteella:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Palauttaa:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## SSO-profiilin synkronointiasetukset

Käytä näitä asetuksia, kun toinen järjestelmä hallinnoi Loomion profiilikenttiä.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` estää käyttäjiä muokkaamasta itse seuraavia kenttiä:

| Kenttä | Huomautukset |
| --- | --- |
| `name` | Ulkoisen synkronoinnin hallinnoima |
| `username` | Ulkoisen synkronoinnin hallinnoima |
| `email` | Ulkoisen synkronoinnin hallinnoima |
| `avatar_kind` / `uploaded_avatar` | Ulkoisen synkronoinnin hallinnoima |

Käyttäjät voivat edelleen muokata Loomion paikallisia kenttiä, kuten `short_bio` ja `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` päivittää kentät `name` ja `email` SSO-kirjautumistiedoista. Jätä asetus kommentoiduksi tai määrittämättä, kun vain ulkoisen synkronointiskriptin on tarkoitus päivittää näitä kenttiä.

`LOOMIO_SSO_FORCE_USER_ATTRS` toimii edelleen olemassa olevissa asennuksissa. Se sekä estää käyttäjiä muokkaamasta kenttiä että päivittää kentät `name` ja `email` SSO-kirjautumisen yhteydessä.
