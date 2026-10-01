---
title: Server-API
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
  introduction: 616cc29d6b8577fc
  authentication: c1bbbba346b6c4a0
  user-object: b52df738c172f57b
  list-users: 96a22d3fe82474a5
  example: fd1b4660e2c0a7e7
  show-user: 7fe79e6c272dd86e
  examples: 3685117d142e09fe
  update-user: aded4c4f83ac4442
  params: a58deea182d61629
  examples-2: 37e396a4ce0741c5
  deactivate-user: c91fe6b7a837bb09
  examples-3: f99f5be0463e3e67
  reactivate-user: 5c78d09ef3a08ec3
  examples-4: 2c86dad407e9b2c5
  redact-user: c2476a7acc1c3069
  examples-5: d23652d2d650c235
  delete-user: de66e470913a72f5
  examples-6: e0695c18e79c6ade
  sso-profile-sync-settings: 5d80d185e6028502
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Documentatie van de Loomio Server-API

<!-- seo-description: Gebruik de Loomio Server-API om gebruikersaccounts te beheren op een zelfgehoste Loomio-installatie. -->

`/api/b3` is voor bewerkingen op serverniveau. Gebruik `/api/b2` voor gebruikersgerichte acties die je uitvoert met een Loomio-gebruikersaccount.

<!-- translation-section: authentication -->

## Authenticatie

Stel `B3_API_KEY` in op een geheime waarde van meer dan 16 tekens.

Stuur de sleutel als een bearer-token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Stuur inloggegevens alleen in de `Authorization`-header. API-sleutels in querystrings of de inhoud van verzoeken worden geweigerd.

<!-- translation-section: user-object -->

## Gebruikersobject

Antwoorden met gebruikersgegevens hebben deze structuur:

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

## Gebruikers opvragen

Vraag alle gebruikersaccounts op de Loomio-installatie op.

`GET /api/b3/users`

<!-- translation-section: example -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Geeft terug:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Gebruiker tonen

Zoek een gebruiker op basis van het Loomio-gebruikers-ID of de externe identiteit.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Op basis van de externe identiteit:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Geeft terug:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Gebruiker bijwerken

Werk de profielvelden bij van een gebruiker die je vindt op basis van het Loomio-gebruikers-ID of de externe identiteit.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Parameters

| Veld | Beschrijving |
| --- | --- |
| `name` | Weergavenaam |
| `username` | Loomio-gebruikersnaam |
| `email` | E-mailadres |

<!-- translation-section: examples-2 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Op basis van de externe identiteit:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Geeft de bijgewerkte gebruiker terug:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Gebruiker deactiveren

Deactiveer een gebruikersaccount dat je vindt op basis van het Loomio-gebruikers-ID of de externe identiteit.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Op basis van de externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Geeft terug:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Gebruiker opnieuw activeren

Activeer een gedeactiveerd gebruikersaccount opnieuw op basis van het Loomio-gebruikers-ID of de externe identiteit.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Op basis van de externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Retourneert:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Persoonsgegevens van gebruiker verwijderen

Bij het verwijderen van persoonsgegevens blijven de reacties van de gebruiker en andere door de gebruiker gemaakte inhoud in diens groepen behouden, maar worden bekende persoonlijk identificeerbare gegevens verwijderd, zoals naam, bio, profielfoto, e-mailadres, inloggegevens, identiteiten en actieve sessies.

Dit is de aanbevolen manier om een gebruiker uit Loomio te verwijderen.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Op basis van de externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Retourneert:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Gebruiker verwijderen

Verwijderen wist de gebruiker en de records die de gebruiker heeft aangemaakt. Reacties worden uit threads verwijderd en stemmen uit peilingen. Ook groepen, discussies, peilingen en andere records die de gebruiker heeft aangemaakt, kunnen via databasekoppelingen worden verwijderd.

Hierdoor gaan veel gegevens verloren. Het wordt sterk aanbevolen om in plaats daarvan de persoonsgegevens te verwijderen.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Op basis van de externe identiteit:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Retourneert:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Instellingen voor SSO-profielsynchronisatie

Gebruik deze instellingen wanneer een ander systeem de profielvelden in Loomio beheert.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` voorkomt dat gebruikers deze velden zelf bewerken:

| Veld | Toelichting |
| --- | --- |
| `name` | Beheerd via externe synchronisatie |
| `username` | Beheerd via externe synchronisatie |
| `email` | Beheerd via externe synchronisatie |
| `avatar_kind` / `uploaded_avatar` | Beheerd via externe synchronisatie |

Gebruikers kunnen velden die alleen in Loomio worden gebruikt, zoals `short_bio` en `location`, nog steeds bewerken.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` werkt `name` en `email` bij op basis van SSO-inloggegevens. Laat deze instelling als commentaar staan of stel deze niet in wanneer alleen een extern synchronisatiescript deze velden moet bijwerken.

`LOOMIO_SSO_FORCE_USER_ATTRS` werkt nog steeds voor bestaande installaties. Deze instelling voorkomt dat gebruikers de velden bewerken en werkt `name` en `email` bij wanneer ze via SSO inloggen.
