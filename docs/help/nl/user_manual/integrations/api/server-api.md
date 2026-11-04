---
title: Server-API
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
  introduction: b0f5eb2c0fe42acb
  authentication: 057e2041af6e5768
  user-object: 66215e30fa8625e7
  list-users: ecc095d8fa9209b5
  example: 70d85e218cfbae39
  show-user: 8657da657cde1ca4
  examples: 03ae5ccfa152f0c9
  update-user: e85ee21c6183c44c
  params: a58deea182d61629
  examples-2: 8abc6939fafb3e20
  deactivate-user: 8a44a5bdb677303a
  examples-3: 9fc8b784d0771cf6
  reactivate-user: 1c48a79696d8794c
  examples-4: d0c7dba457e394ff
  redact-user: 1316a90a271c7523
  examples-5: 12807e6b1faa91f6
  delete-user: 9c81035bb2371aec
  examples-6: d27f47c9dafd8dcb
  sso-profile-sync-settings: 5d80d185e6028502
  provisioning: 34ab255c91bdcf5e
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Documentatie van de Loomio Server-API

<!-- seo-description: Gebruik de Loomio Server-API om gebruikersaccounts aan te maken, groepen te vinden en lidmaatschappen te beheren op een zelfgehoste Loomio-installatie. -->

`/api/server0` is voor bewerkingen op serverniveau. Gebruik `/api/user0` voor gebruikersgerichte acties die je uitvoert met een Loomio-gebruikersaccount.

Gebruik één serversleutel om accounts aan te maken en te beheren, groepen in de hele installatie te vinden en hun lidmaatschappen en rollen te beheren. Je hebt geen botaccount, API-sleutel voor een gebruiker of lidmaatschap van de groepen nodig. API-sleutels voor gebruikers blijven de groepsrechten van de gebruiker volgen.

<!-- translation-section: authentication -->

## Authenticatie

De sleutel is de instelling `SERVER_API_KEY` in de serveromgeving. `create_env.sh` genereert er een voor nieuwe installaties.

Stuur de sleutel als een bearer-token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Stuur inloggegevens alleen in de `Authorization`-header. API-sleutels in querystrings of de inhoud van verzoeken worden geweigerd.

<!-- translation-section: provisioning -->

## Accounts en lidmaatschappen aanmaken en beheren

| Methode | Endpoint | Doel |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Een account aanmaken |
| `GET` | `/api/server0/groups` | Groepen in de hele installatie vinden |
| `GET` | `/api/server0/memberships` | Lidmaatschappen in een groep opvragen |
| `POST` | `/api/server0/memberships` | Leden uitnodigen of een volledige ledenlijst synchroniseren |
| `PATCH` | `/api/server0/memberships/:id` | De groepsrollen admin en afgevaardigde wijzigen |
| `DELETE` | `/api/server0/memberships/:id` | Eén lidmaatschap intrekken |

De bestaande endpoints voor het bijwerken, deactiveren, reactiveren, anonimiseren en verwijderen van accounts worden hieronder beschreven.

### Een account aanmaken

`POST /api/server0/users`

Verstuur een `user`-object met een verplicht veld `email`. Spaties aan het begin en einde van e-mailadressen worden verwijderd en de adressen worden omgezet naar kleine letters. Optionele velden zijn `name`, `username` en `is_admin`. Hier betekent `is_admin` een admin van de installatie; adminrollen voor groepen worden via lidmaatschappen beheerd. Laat `username` weg om automatisch een gebruikersnaam te genereren. Onbekende velden worden geweigerd.

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

Het antwoord is HTTP `201` met een `user`-object. Ongeldige velden of een e-mailadres of gebruikersnaam die al in gebruik is, leveren HTTP `422` op. Bij het aanmaken van een account wordt geen uitnodiging verstuurd, wordt de persoon niet ingelogd en wordt het e-mailadres niet als geverifieerd gemarkeerd. Nodig de persoon via het lidmaatschapsendpoint uit voor een groep om een uitnodiging via de normale meldingsprocedure te versturen.

### Groepen vinden

`GET /api/server0/groups`

Vraag alle groepen op die niet zijn verwijderd, inclusief privégroepen en groepen met verlopen abonnementen. De resultaten worden gesorteerd op oplopend ID. Gebruik `limit` (standaard en maximaal `50`) en `offset` (standaard `0`) om ze per pagina op te vragen.

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

### Lidmaatschappen opvragen

`GET /api/server0/memberships?group_id=123`

`group_id` is verplicht. De resultaten bevatten geaccepteerde lidmaatschappen en openstaande uitnodigingen, gesorteerd op oplopend lidmaatschaps-ID. Ingetrokken lidmaatschappen worden niet opgenomen. Gebruik `limit` (standaard en maximaal `50`) en `offset` (standaard `0`) voor paginering.

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

`admin` en `delegate` zijn groepsrollen. `accepted_at` is het tijdstip van acceptatie, of `null` zolang een uitnodiging openstaat. Dit endpoint geeft geen uitnodigingstokens, inloggegevens of stemmen vrij.

### Leden uitnodigen of synchroniseren

`POST /api/server0/memberships`

Verstuur de verplichte velden `group_id` en de array `emails`. Standaard worden hiermee de vermelde personen toegevoegd die nog geen actief lidmaatschap hebben; alle anderen blijven lid. Spaties aan het begin en einde van e-mailadressen worden verwijderd, de adressen worden omgezet naar kleine letters en dubbele adressen worden verwijderd. Voor nieuwe adressen worden accounts en openstaande uitnodigingen aangemaakt. Bestaande geverifieerde leden van een andere actieve groep in dezelfde organisatie worden automatisch geaccepteerd, net als bij de uitnodigingsprocedure van de gebruikers-API.

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

Stel `remove_absent` expliciet in op `true` om een volledige ledenlijst te synchroniseren. Iedereen die niet op de lijst staat, wordt uit die groep en de bijbehorende subgroepen verwijderd. Een lege array met `remove_absent: true` verwijdert iedereen, inclusief de groepsadmins. Laat `remove_absent` weg of stel het in op `false` als je alleen personen wilt toevoegen. De oudere waarden `1` en `0` worden ook geaccepteerd.

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

Als je hetzelfde verzoek herhaalt, worden geen dubbele lidmaatschappen aangemaakt of uitnodigingen opnieuw verstuurd. Als je een lid met een ingetrokken lidmaatschap opnieuw uitnodigt, krijgt dit lid weer toegang tot de groep, zonder dat een eerdere adminrol wordt hersteld. Nieuwe uitnodigingen en rolwijzigingen gebruiken de normale meldingsprocedure, waarbij geen gebruiker wordt vastgelegd als degene die de actie uitvoert.

Ontbrekende of onjuist opgemaakte e-maillijsten en ongeldige booleaanse waarden leveren HTTP `400` op. Een gedeactiveerd account op de lijst levert HTTP `422` op; reactiveer het expliciet voordat je het toevoegt. Bij ongeldige accountgegevens, abonnementslimieten of andere fouten wordt de volledige synchronisatie teruggedraaid, inclusief nieuwe accounts en ingetrokken lidmaatschappen. Toevoegingen vereisen een actieve groep en blijven onderworpen aan de ledenlimieten van het abonnement.

### Lidmaatschapsrollen bijwerken

`PATCH /api/server0/memberships/:id`

Verstuur een `membership`-object met een of beide booleaanse velden `admin` en `delegate`. Weggelaten rollen blijven ongewijzigd. Onbekende velden worden geweigerd; het endpoint kan geen lidmaatschap overdragen, uitnodiging accepteren of stemgewichten wijzigen.

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

Geeft een `membership`-object terug met dezelfde velden als een opgevraagd lidmaatschap. Het toekennen van een rol maakt de gebruikelijke rolmelding aan; het opnieuw versturen van een ongewijzigde rol leidt niet tot een nieuwe melding. Rolwijzigingen vereisen een actieve groep. Ingetrokken lidmaatschappen leveren HTTP `404` op.

### Eén lidmaatschap verwijderen

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Geeft `{"success": true}` terug. Verwijdering trekt de toegang tot de groep en de bijbehorende subgroepen in, inclusief toegang tot onderwerpen en stemrechten in actieve peilingen. Het account wordt niet verwijderd, andere groepen worden niet gewijzigd en rechtstreekse toegang tot threads wordt niet ingetrokken. Een herhaalde verwijdering slaagt. Je kunt lidmaatschappen verwijderen uit groepen met verlopen abonnementen; verwijderde groepen leveren HTTP `404` op.

<!-- translation-section: user-object -->

## Gebruikersobject

Antwoorden met gebruikersgegevens hebben deze structuur:

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

## Gebruikers opvragen

Vraag alle gebruikersaccounts op de Loomio-installatie op.

`GET /api/server0/users`

<!-- translation-section: example -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
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

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Op basis van de externe identiteit:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/server0/users/123
```

Op basis van de externe identiteit:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Op basis van de externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
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

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Op basis van de externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
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

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Op basis van de externe identiteit:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
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

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Voorbeelden

Op basis van het Loomio-gebruikers-ID:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Op basis van de externe identiteit:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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
