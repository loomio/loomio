---
title: Server-API
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: feda11f0de69bf91
  authentication: 1d0ce4362fc71a29
  user-object: 3adb7cc3e9eb665d
  list-users: e4c36202ce0f8e31
  example: 6c89ecaebcc2a346
  show-user: 61043d7736eb713b
  examples: 874e62de2a395328
  update-user: d69c0fdb895716ef
  params: 29afbab19704dc95
  examples-2: de7ff6e2cf8e9892
  deactivate-user: 20ef93172b87112d
  examples-3: 74301dfc2d5c51ee
  reactivate-user: f21cdfc42a35db1b
  examples-4: 124a283eb08c21ed
  redact-user: 4dae6b90566243f1
  examples-5: 8d9b3f6418433548
  delete-user: 8e23864f810ff128
  examples-6: d11b984e005416bf
  sso-profile-sync-settings: 6bcf4fd55174cc40
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Dokumentation der Loomio Server-API

<!-- seo-description: Verwalte mit der Loomio Server-API Benutzerkonten auf einer selbst gehosteten Loomio-Installation. -->

`/api/b3` ist für Vorgänge auf Serverebene vorgesehen. Verwende `/api/b2` für benutzerbezogene Aktionen, die über ein Loomio-Benutzerkonto ausgeführt werden.

<!-- translation-section: authentication -->

## Authentifizierung

Setze `B3_API_KEY` auf einen geheimen Wert mit mehr als 16 Zeichen.

Sende den Schlüssel als Bearer-Token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Sende Zugangsdaten ausschließlich im `Authorization`-Header. API-Schlüssel in URL-Abfrageparametern oder im Anfragekörper werden abgelehnt.

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

Gibt Folgendes zurück:

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

Gibt Folgendes zurück:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Benutzerkonto aktualisieren

Aktualisiere die Profilfelder eines Benutzerkontos, das du anhand seiner Loomio-Benutzer-ID oder externen Identität findest.

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

Deaktiviere ein Benutzerkonto, das du anhand seiner Loomio-Benutzer-ID oder externen Identität findest.

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

Gibt Folgendes zurück:

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

## Personenbezogene Daten entfernen

Beim Entfernen personenbezogener Daten bleiben die Kommentare und andere von der Person erstellte Inhalte in ihren Gruppen erhalten. Bekannte Informationen, die die Person identifizieren können, werden jedoch entfernt, darunter Name, Kurzbiografie, Profilfoto, E-Mail-Adresse, Anmeldedaten, Identitäten und aktive Sitzungen.

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

Beim Löschen werden das Benutzerkonto und die von der Person erstellten Datensätze entfernt. Kommentare werden aus Threads und Stimmen aus Abstimmungen entfernt. Über Datenbankverknüpfungen können auch Gruppen, Diskussionen, Abstimmungen und andere von der Person erstellte Datensätze gelöscht werden.

Dabei werden umfangreiche Daten gelöscht. Es wird dringend empfohlen, stattdessen die personenbezogenen Daten zu entfernen.

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

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` aktualisiert `name` und `email` anhand der SSO-Anmeldedaten. Lass die Einstellung auskommentiert oder nicht gesetzt, wenn ausschließlich ein externes Synchronisierungsskript diese Felder aktualisieren soll.

`LOOMIO_SSO_FORCE_USER_ATTRS` funktioniert weiterhin bei bestehenden Installationen. Die Einstellung verhindert die Bearbeitung durch die Personen selbst und aktualisiert `name` und `email` bei der SSO-Anmeldung.
