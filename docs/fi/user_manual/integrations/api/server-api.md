---
title: Palvelimen API
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
  introduction: 3b7adf7c100298e3
  authentication: ae7a3d2416a21d01
  user-object: 75913cd0fd24d9ab
  list-users: dfecbabec62a5002
  example: 3849933612930aeb
  show-user: d8b7983ed84e2087
  examples: d2751508eb33480a
  update-user: 0b1749b278aca484
  params: b29f72f9f8367e50
  examples-2: 863b6f5a7f852fa5
  deactivate-user: 4105588f39af51f2
  examples-3: bb762640d349ebb4
  reactivate-user: 1a743e4153c6eea6
  examples-4: '09d1f8c1ba598db8'
  redact-user: ae4db835ea764a14
  examples-5: ddba94c3f79d9465
  delete-user: c8772856db2a725b
  examples-6: 5ee22a0723a6b25f
  sso-profile-sync-settings: 340017f579ed2dc4
title_source: 370e81eb20eece44
title_generated: 6b950a4b886b152a
---

<!-- translation-section: introduction -->

# Loomion palvelimen API-dokumentaatio

<!-- seo-description: Hallitse käyttäjätilejä omalla palvelimella ylläpidetyssä Loomio-asennuksessa Loomion palvelimen API:n avulla. -->

`/api/b3` on tarkoitettu palvelintason toimintoihin. Käytä `/api/b2`-rajapintaa käyttäjäkohtaisiin toimintoihin, jotka suoritetaan Loomion käyttäjätilillä.

<!-- translation-section: authentication -->

## Tunnistautuminen

Aseta `B3_API_KEY`-muuttujan arvoksi yli 16 merkkiä pitkä salainen avain.

Lähetä avain bearer-tokenina:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Lähetä tunnistautumistiedot vain `Authorization`-otsakkeessa. Kyselymerkkijonossa tai pyynnön rungossa lähetetyt API-avaimet hylätään.

<!-- translation-section: user-object -->

## Käyttäjäobjekti

Käyttäjätietoja sisältävät vastaukset ovat tässä muodossa:

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

Hae käyttäjä Loomion käyttäjätunnisteen tai ulkoisen identiteetin perusteella.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Esimerkkejä

Loomion käyttäjätunnisteen perusteella:

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

Päivitä Loomion käyttäjätunnisteen tai ulkoisen identiteetin perusteella löydetyn käyttäjän profiilikentät.

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

Loomion käyttäjätunnisteen perusteella:

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

Poista käytöstä Loomion käyttäjätunnisteen tai ulkoisen identiteetin perusteella löydetty käyttäjätili.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Esimerkkejä

Loomion käyttäjätunnisteen perusteella:

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

## Poista käyttäjän henkilötiedot

Henkilötietojen poisto säilyttää käyttäjän kommentit ja muun hänen luomansa sisällön hänen ryhmissään, mutta poistaa tiedossa olevat henkilön tunnistamisen mahdollistavat tiedot, kuten nimen, esittelytekstin, profiilikuvan, sähköpostiosoitteen, kirjautumistiedot, identiteetit ja aktiiviset istunnot.

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

Poistaminen poistaa käyttäjän ja hänen luomansa tietueet. Kommentit poistetaan ketjuista ja äänet kyselyistä. Myös käyttäjän luomat ryhmät, keskustelut, kyselyt ja muut tietueet voivat poistua tietokannan suhteiden kautta.

Tämä poistaa paljon tietoja. Suosittelemme vahvasti henkilötietojen poistoa sen sijaan.

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

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` estää käyttäjiä muokkaamasta näitä kenttiä itse:

| Kenttä | Huomautukset |
| --- | --- |
| `name` | Ulkoisen synkronoinnin hallinnoima |
| `username` | Ulkoisen synkronoinnin hallinnoima |
| `email` | Ulkoisen synkronoinnin hallinnoima |
| `avatar_kind` / `uploaded_avatar` | Ulkoisen synkronoinnin hallinnoima |

Käyttäjät voivat edelleen muokata Loomion paikallisia kenttiä, kuten `short_bio` ja `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` päivittää kentät `name` ja `email` SSO-kirjautumistiedoista. Jätä asetus kommentoiduksi tai määrittämättä, kun vain ulkoisen synkronointiskriptin tulee tehdä nämä päivitykset.

`LOOMIO_SSO_FORCE_USER_ATTRS` toimii edelleen nykyisissä asennuksissa. Se estää käyttäjiä muokkaamasta kenttiä ja päivittää kentät `name` ja `email` SSO-kirjautumisen yhteydessä.
