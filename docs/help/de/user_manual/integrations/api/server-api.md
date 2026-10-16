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
  introduction: 171b9bca49cbdf88
  authentication: cc8bfd594a0cca41
  user-object: 3adb7cc3e9eb665d
  list-users: e4c36202ce0f8e31
  example: a6bb2cb102a34c58
  show-user: 61043d7736eb713b
  examples: 9303eb254d92f61d
  update-user: a0cb72cd1a4b3864
  params: 29afbab19704dc95
  examples-2: de7ff6e2cf8e9892
  deactivate-user: 27525b7ca5fa6960
  examples-3: 265efd99c1a016fa
  reactivate-user: f21cdfc42a35db1b
  examples-4: 124a283eb08c21ed
  redact-user: 5a31537db5283bb7
  examples-5: 8d9b3f6418433548
  delete-user: 715316159c2a7f8b
  examples-6: d11b984e005416bf
  sso-profile-sync-settings: f77b2da54455de67
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Dokumentation der Loomio Server-API

<!-- seo-description: Nutze die Loomio Server-API, um Benutzerkonten auf einer selbst gehosteten Loomio-Installation zu verwalten. -->

`/api/b3` ist für Vorgänge auf Serverebene vorgesehen. Nutze `/api/b2` für Aktionen, die du mit einem Loomio-Benutzerkonto ausführst.

<!-- translation-section: authentication -->

## Authentifizierung

Setze `B3_API_KEY` auf einen geheimen Schlüssel mit mehr als 16 Zeichen.

Sende den Schlüssel als Bearer-Token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Sende Zugangsdaten ausschließlich im `Authorization`-Header. API-Schlüssel in Abfragezeichenfolgen oder im Anfragetext werden abgelehnt.

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

## Benutzerkonten auflisten

Liste alle Benutzerkonten auf der Loomio-Installation auf.

`GET /api/b3/users`

<!-- translation-section: example -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Gibt zurück:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Benutzerkonto anzeigen

Finde ein Benutzerkonto anhand seiner Loomio-Benutzer-ID oder externen Identität.

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

Gibt zurück:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Benutzerkonto aktualisieren

Aktualisiere die Profilfelder eines Benutzerkontos, das du anhand seiner Loomio-Benutzer-ID oder externen Identität gefunden hast.

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

Gibt das aktualisierte Benutzerkonto zurück:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Benutzerkonto deaktivieren

Deaktiviere ein Benutzerkonto, das du anhand seiner Loomio-Benutzer-ID oder externen Identität gefunden hast.

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

Gibt zurück:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Benutzerkonto reaktivieren

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

Rückgabe:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Personenbezogene Kontodaten entfernen

Dabei bleiben die Kommentare und andere von der Person erstellte Inhalte in ihren Gruppen erhalten. Bekannte personenbezogene Daten wie Name, Kurzbiografie, Profilfoto, E-Mail-Adresse, Anmeldedaten, Identitäten und aktive Sitzungen werden jedoch entfernt.

Dies ist die empfohlene Methode, um eine Person aus Loomio zu entfernen.

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

Rückgabe:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Benutzerkonto löschen

Das Löschen entfernt das Benutzerkonto und die von der Person erstellten Datensätze. Kommentare werden aus Threads und Stimmen aus Abstimmungen entfernt. Gruppen, Diskussionen, Abstimmungen und andere von der Person erstellte Datensätze können durch Datenbankverknüpfungen ebenfalls gelöscht werden.

Dabei werden umfangreiche Daten gelöscht. Es wird dringend empfohlen, stattdessen die personenbezogenen Kontodaten zu entfernen.

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

Rückgabe:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Einstellungen zur SSO-Profilsynchronisierung

Verwende diese Einstellungen, wenn ein anderes System die Loomio-Profilfelder verwaltet.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` verhindert, dass Personen diese Felder selbst bearbeiten:

| Feld | Hinweise |
| --- | --- |
| `name` | Durch externe Synchronisierung verwaltet |
| `username` | Durch externe Synchronisierung verwaltet |
| `email` | Durch externe Synchronisierung verwaltet |
| `avatar_kind` / `uploaded_avatar` | Durch externe Synchronisierung verwaltet |

Personen können weiterhin lokale Loomio-Felder wie `short_bio` und `location` bearbeiten.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` aktualisiert `name` und `email` anhand der SSO-Anmeldedaten. Lass die Zeile auskommentiert oder die Variable ungesetzt, wenn ausschließlich ein externes Synchronisierungsskript diese Aktualisierungen vornehmen soll.

`LOOMIO_SSO_FORCE_USER_ATTRS` funktioniert weiterhin für bestehende Installationen. Die Einstellung verhindert sowohl die Bearbeitung durch die Personen selbst als auch die Aktualisierung von `name` und `email` bei der SSO-Anmeldung.
