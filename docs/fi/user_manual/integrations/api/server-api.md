---
title: Palvelimen API
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
  introduction: 55390a36963e398e
  authentication: 855a7206b1149d0e
  user-object: 2e9d1a877ba75af8
  list-users: dfecbabec62a5002
  example: 3849933612930aeb
  show-user: f23fc592e91f39f3
  examples: 72553f72841bd2b2
  update-user: 504cc603a26b0056
  params: bc2f30eca71b33af
  examples-2: ecf3c59fbba63df4
  deactivate-user: 875b0beeaa2d5dfa
  examples-3: '029b15010a0bb0ac'
  reactivate-user: d77797ce4b382cf5
  examples-4: 71f7a704f75f9908
  redact-user: 18aee3ea14da1198
  examples-5: d9f3383f70af754a
  delete-user: 76628b53c802942c
  examples-6: b825122fc917651e
  sso-profile-sync-settings: '0891ada3701b4b2e'
title_source: 370e81eb20eece44
title_generated: 6b950a4b886b152a
---

<!-- translation-section: introduction -->

# Loomion palvelimen API-dokumentaatio

<!-- seo-description: Hallitse käyttäjätilejä itse ylläpitämässäsi Loomio-asennuksessa Loomion palvelimen API:n avulla. -->

`/api/b3` on tarkoitettu palvelintason toimintoihin. Käytä `/api/b2`-rajapintaa toimintoihin, jotka suoritetaan Loomio-käyttäjätilillä.

<!-- translation-section: authentication -->

## Todennus

Aseta `B3_API_KEY`-muuttujan arvoksi salainen merkkijono, jossa on yli 16 merkkiä.

Lähetä avain bearer-tunnuksena:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Lähetä tunnistetiedot vain `Authorization`-otsakkeessa. Kyselymerkkijonossa tai pyynnön rungossa lähetetyt API-avaimet hylätään.

<!-- translation-section: user-object -->

## Käyttäjäobjekti

Käyttäjää koskevat vastaukset ovat tämän muotoisia:

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

Etsi käyttäjä Loomio-käyttäjätunnuksen tai ulkoisen identiteetin perusteella.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Esimerkit

Loomio-käyttäjätunnuksen perusteella:

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

Päivitä Loomio-käyttäjätunnuksen tai ulkoisen identiteetin perusteella löytyneen käyttäjän profiilitiedot.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Parametrit

| Kenttä | Kuvaus |
| --- | --- |
| `name` | Näyttönimi |
| `username` | Loomio-käyttäjänimi |
| `email` | Sähköpostiosoite |

<!-- translation-section: examples-2 -->

### Esimerkit

Loomio-käyttäjätunnuksen perusteella:

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

## Poista käyttäjä käytöstä

Poista Loomio-käyttäjätunnuksen tai ulkoisen identiteetin perusteella löytynyt käyttäjätili käytöstä.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Esimerkit

Loomio-käyttäjätunnuksen perusteella:

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

## Ota käyttäjä uudelleen käyttöön

Ota Loomio-käyttäjätunnuksen tai ulkoisen identiteetin perusteella löytynyt käytöstä poistettu käyttäjätili uudelleen käyttöön.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Esimerkit

Loomio-käyttäjätunnuksen perusteella:

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

## Poista käyttäjän henkilötiedot

Henkilötietojen poisto säilyttää käyttäjän kommentit ja muun hänen luomansa sisällön ryhmissä. Se poistaa tunnetut henkilöön yhdistettävät tiedot, kuten nimen, esittelytekstin, profiilikuvan, sähköpostiosoitteen, kirjautumistiedot, identiteetit ja aktiiviset istunnot.

Tämä on suositeltu tapa poistaa käyttäjä Loomiosta.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Esimerkit

Loomio-käyttäjätunnuksen perusteella:

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

Poistaminen poistaa käyttäjän ja hänen luomansa tietueet. Kommentit poistetaan keskusteluketjuista ja äänet kyselyistä. Myös käyttäjän luomat ryhmät, keskustelut, kyselyt ja muut tietueet voivat poistua tietokantakytkentöjen kautta.

Poistaminen hävittää paljon tietoja. Käytä sen sijaan mieluiten henkilötietojen poistoa.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Esimerkit

Loomio-käyttäjätunnuksen perusteella:

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

Käytä näitä asetuksia, kun toinen järjestelmä hallinnoi Loomion profiilitietoja.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` estää käyttäjiä muokkaamasta itse seuraavia kenttiä:

| Kenttä | Huomautukset |
| --- | --- |
| `name` | Hallinnoidaan ulkoisella synkronoinnilla |
| `username` | Hallinnoidaan ulkoisella synkronoinnilla |
| `email` | Hallinnoidaan ulkoisella synkronoinnilla |
| `avatar_kind` / `uploaded_avatar` | Hallinnoidaan ulkoisella synkronoinnilla |

Käyttäjät voivat edelleen muokata Loomiossa hallinnoitavia kenttiä, kuten `short_bio` ja `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` päivittää kentät `name` ja `email` SSO-kirjautumisen tiedoista. Jätä asetus kommentoiduksi tai määrittämättä, jos vain ulkoisen synkronointiskriptin tulee päivittää nämä tiedot.

`LOOMIO_SSO_FORCE_USER_ATTRS` toimii edelleen nykyisissä asennuksissa. Se estää käyttäjiä muokkaamasta tietojaan ja päivittää kentät `name` ja `email` SSO-kirjautumisen yhteydessä.
