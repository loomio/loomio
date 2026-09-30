---
title: Server-API
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
  introduction: a26a2f1056804573
  authentication: 449e64b163b4db89
  user-object: b52df738c172f57b
  list-users: 96a22d3fe82474a5
  example: fd1b4660e2c0a7e7
  show-user: d2067c7b2f45338d
  examples: de3ab39a560a6cbb
  update-user: 5fe04ef4e3aa790f
  params: a58deea182d61629
  examples-2: '012888fe154f6948'
  deactivate-user: 3aae82c5b432d0d4
  examples-3: '082aaeab0c0552c4'
  reactivate-user: 5c78d09ef3a08ec3
  examples-4: 19b1cc2dab228455
  redact-user: a9d2f89363f230a0
  examples-5: 4034833efa840c7e
  delete-user: 13cb79255e9eb55d
  examples-6: 2fd7b488d8cfc314
  sso-profile-sync-settings: 9bd312bdf37617ce
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Documentatie voor de Loomio Server-API

<!-- seo-description: Gebruik de Loomio Server-API om gebruikersaccounts op een zelfgehoste Loomio-installatie te beheren. -->

`/api/b3` is bedoeld voor bewerkingen op serverniveau. Gebruik `/api/b2` voor acties die je met een Loomio-gebruikersaccount uitvoert.

<!-- translation-section: authentication -->

## Authenticatie

Stel `B3_API_KEY` in op een geheime waarde van meer dan 16 tekens.

Verstuur de sleutel als bearer-token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Verstuur inloggegevens alleen in de `Authorization`-header. API-sleutels in querystrings of aanvraagbody's worden geweigerd.

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

## Gebruiker opvragen

Zoek een gebruiker op basis van diens Loomio-gebruikers-ID of externe identiteit.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Voorbeelden

Op basis van Loomio-gebruikers-ID:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Op basis van externe identiteit:

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

Werk de profielvelden bij van een gebruiker die je opzoekt met diens Loomio-gebruikers-ID of externe identiteit.

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

Op basis van Loomio-gebruikers-ID:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Op basis van externe identiteit:

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

Deactiveer een gebruikersaccount op basis van het Loomio-gebruikers-ID of de externe identiteit.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Voorbeelden

Op basis van Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Op basis van externe identiteit:

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

Op basis van Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Op basis van externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Geeft terug:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Gebruikersgegevens anonimiseren

Bij anonimisering blijven de reacties van de gebruiker en andere inhoud die diegene heeft gemaakt binnen diens groepen behouden. Bekende persoonsgegevens worden verwijderd, waaronder naam, biografie, profielfoto, e-mailadres, inloggegevens, identiteiten en actieve sessies.

Dit is de aanbevolen manier om een gebruiker uit Loomio te verwijderen.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Voorbeelden

Op basis van Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Op basis van externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Geeft terug:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Gebruiker verwijderen

Bij verwijderen worden de gebruiker en de door die gebruiker aangemaakte gegevens gewist. Reacties verdwijnen uit threads en stemmen uit peilingen. Ook groepen, discussies, peilingen en andere gegevens die de gebruiker heeft aangemaakt, kunnen via databasekoppelingen worden verwijderd.

Dit heeft ingrijpende gevolgen. Anonimiseren wordt sterk aanbevolen als alternatief.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Voorbeelden

Op basis van Loomio-gebruikers-ID:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Op basis van externe identiteit:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Geeft terug:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Instellingen voor SSO-profielsynchronisatie

Gebruik deze instellingen als een ander systeem de profielvelden in Loomio beheert.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` voorkomt dat gebruikers deze velden zelf bewerken:

| Veld | Opmerkingen |
| --- | --- |
| `name` | Beheerd via externe synchronisatie |
| `username` | Beheerd via externe synchronisatie |
| `email` | Beheerd via externe synchronisatie |
| `avatar_kind` / `uploaded_avatar` | Beheerd via externe synchronisatie |

Gebruikers kunnen velden die alleen in Loomio worden beheerd, zoals `short_bio` en `location`, nog steeds bewerken.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` werkt `name` en `email` bij met gegevens van de SSO-aanmelding. Laat de instelling als commentaar staan of stel haar niet in als alleen een extern synchronisatiescript deze velden mag bijwerken.

`LOOMIO_SSO_FORCE_USER_ATTRS` werkt nog steeds voor bestaande installaties. Deze instelling voorkomt dat gebruikers hun profiel bewerken en werkt `name` en `email` bij wanneer ze zich via SSO aanmelden.
