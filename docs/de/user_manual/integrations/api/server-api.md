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
  introduction: 480b6c239d45972b
  authentication: ecd585ba65981ba5
  user-object: 3adb7cc3e9eb665d
  list-users: 033f14fca67a5e23
  example: 8f403a2977009c74
  show-user: 80dd8efe92ceb79e
  examples: eaafccf66ef2d775
  update-user: 620aa7b607ede47f
  params: 29afbab19704dc95
  examples-2: b02a73c32db1876c
  deactivate-user: 27daebc7fc243038
  examples-3: 57ea2dd4103a0727
  reactivate-user: 52fc65a2af4365e4
  examples-4: 1b15a2cb329eb275
  redact-user: 2f8cba328aade36b
  examples-5: 3c5a37f465f2aee6
  delete-user: 9922e2c29b82a36e
  examples-6: fc7f9089cba75346
  sso-profile-sync-settings: bcd8e215358c1d6f
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Dokumentation der Loomio-Server-API

<!-- seo-description: Verwalte Benutzerkonten einer selbst gehosteten Loomio-Installation mit der Loomio-Server-API. -->

`/api/b3` dient für Vorgänge auf Serverebene. Verwende `/api/b2` für Aktionen, die über ein Loomio-Benutzerkonto ausgeführt werden.

<!-- translation-section: authentication -->

## Authentifizierung

Lege für `B3_API_KEY` einen geheimen Wert mit mehr als 16 Zeichen fest.

Sende den Schlüssel als Bearer-Token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Sende Zugangsdaten ausschließlich im `Authorization`-Header. API-Schlüssel in URL-Parametern oder im Anfragetext werden abgelehnt.

<!-- translation-section: user-object -->

## Benutzerobjekt

Antworten mit Benutzerdaten haben diese Struktur:

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

## Benutzer auflisten

Liste alle Benutzerkonten der Loomio-Installation auf.

`GET /api/b3/users`

<!-- translation-section: example -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Antwort:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Benutzer anzeigen

Finde einen Benutzer anhand seiner Loomio-Benutzer-ID oder externen Identität.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Anhand der externen Identität:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Antwort:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Benutzer aktualisieren

Aktualisiere die Profilfelder eines Benutzers, den du anhand seiner Loomio-Benutzer-ID oder externen Identität gefunden hast.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Parameter

| Feld | Beschreibung |
| --- | --- |
| `name` | Anzeigename |
| `username` | Loomio-Benutzername |
| `email` | E-Mail-Adresse |

<!-- translation-section: examples-2 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Anhand der externen Identität:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Antwort mit dem aktualisierten Benutzer:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Benutzer deaktivieren

Deaktiviere ein Benutzerkonto anhand seiner Loomio-Benutzer-ID oder externen Identität.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Anhand der externen Identität:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Antwort:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Benutzer reaktivieren

Reaktiviere ein deaktiviertes Benutzerkonto anhand seiner Loomio-Benutzer-ID oder externen Identität.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Anhand der externen Identität:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Antwort:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Benutzerdaten anonymisieren

Bei der Anonymisierung bleiben die Kommentare und anderen Inhalte des Benutzers in seinen Gruppen erhalten. Bekannte personenbezogene Daten werden entfernt, darunter Name, Biografie, Profilfoto, E-Mail-Adresse, Anmeldedaten, Identitäten und aktive Sitzungen.

Dies ist die empfohlene Methode, um einen Benutzer aus Loomio zu entfernen.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Anhand der externen Identität:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Antwort:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Benutzerkonto löschen

Beim Löschen werden das Benutzerkonto und die von der Person erstellten Einträge entfernt. Kommentare werden aus Diskussionen und Stimmen aus Abstimmungen entfernt. Auch Gruppen, Diskussionen, Abstimmungen und andere von der Person erstellte Einträge können über Datenbankverknüpfungen gelöscht werden.

Dabei können viele Daten verloren gehen. Stattdessen wird dringend empfohlen, das Benutzerkonto zu anonymisieren.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Anhand der externen Identität:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Antwort:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Einstellungen für den SSO-Profilabgleich

Verwende diese Einstellungen, wenn ein anderes System die Loomio-Profilfelder verwaltet.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` verhindert, dass Nutzer diese Felder selbst bearbeiten:

| Feld | Hinweise |
| --- | --- |
| `name` | Wird durch externen Abgleich verwaltet |
| `username` | Wird durch externen Abgleich verwaltet |
| `email` | Wird durch externen Abgleich verwaltet |
| `avatar_kind` / `uploaded_avatar` | Wird durch externen Abgleich verwaltet |

Nutzer können weiterhin Felder bearbeiten, die nur in Loomio verwaltet werden, etwa `short_bio` und `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` aktualisiert `name` und `email` anhand der SSO-Anmeldedaten. Lass die Zeile auskommentiert oder die Variable ungesetzt, wenn nur ein externes Abgleichskript diese Felder aktualisieren soll.

`LOOMIO_SSO_FORCE_USER_ATTRS` funktioniert weiterhin bei bestehenden Installationen. Die Einstellung verhindert, dass Nutzer ihr Profil selbst bearbeiten, und aktualisiert `name` und `email` bei der SSO-Anmeldung.
