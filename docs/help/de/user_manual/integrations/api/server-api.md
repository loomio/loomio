---
title: Server-API
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
  introduction: f7a4f570e789c363
  authentication: cc8bfd594a0cca41
  user-object: b2b4d79ee8f505b3
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
  provisioning: 9184f89f1fc28eff
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Dokumentation der Loomio Server-API

<!-- seo-description: Nutze die Loomio Server-API, um Benutzerkonten auf einer selbst gehosteten Loomio-Installation bereitzustellen, Gruppen zu finden und Mitgliedschaften zu verwalten. -->

`/api/b3` ist für Vorgänge auf Serverebene vorgesehen. Nutze `/api/b2` für Aktionen, die du mit einem Loomio-Benutzerkonto ausführst.

Nutze einen Serverschlüssel, um Konten zu erstellen und zu verwalten, Gruppen in der gesamten Installation zu finden und deren Mitgliedschaften und Rollen zu verwalten. Dafür sind weder ein Bot-Konto noch ein Benutzer-API-Schlüssel oder eine Mitgliedschaft in den Gruppen erforderlich. Für Benutzer-API-Schlüssel gelten weiterhin die Gruppenberechtigungen der jeweiligen Person.

<!-- translation-section: authentication -->

## Authentifizierung

Setze `B3_API_KEY` auf einen geheimen Schlüssel mit mehr als 16 Zeichen.

Sende den Schlüssel als Bearer-Token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Sende Zugangsdaten ausschließlich im `Authorization`-Header. API-Schlüssel in Abfragezeichenfolgen oder im Anfragetext werden abgelehnt.

<!-- translation-section: provisioning -->

## Konten und Mitgliedschaften bereitstellen

| Methode | Endpunkt | Zweck |
| --- | --- | --- |
| `POST` | `/api/b3/users` | Ein Konto erstellen |
| `GET` | `/api/b3/groups` | Gruppen in der gesamten Installation finden |
| `GET` | `/api/b3/memberships` | Mitgliedschaften in einer Gruppe auflisten |
| `POST` | `/api/b3/memberships` | Mitglieder einladen oder eine vollständige Mitgliederliste synchronisieren |
| `PATCH` | `/api/b3/memberships/:id` | Admin- und Delegiertenrollen in einer Gruppe ändern |
| `DELETE` | `/api/b3/memberships/:id` | Eine Mitgliedschaft widerrufen |

Die bestehenden Endpunkte zum Aktualisieren, Deaktivieren, Reaktivieren, Anonymisieren und Löschen von Konten werden weiter unten beschrieben.

### Ein Konto erstellen

`POST /api/b3/users`

Sende ein `user`-Objekt mit dem Pflichtfeld `email`. Leerzeichen am Anfang und Ende von E-Mail-Adressen werden entfernt, und die Adressen werden in Kleinbuchstaben umgewandelt. Optionale Felder sind `name`, `username` und `is_admin`. Hier bezeichnet `is_admin` einen Admin der Instanz; Admin-Rollen für Gruppen werden über Mitgliedschaften verwaltet. Lasse `username` weg, um automatisch einen Benutzernamen zu erzeugen. Unbekannte Felder werden abgelehnt.

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

Die Antwort ist HTTP `201` mit einem `user`-Objekt. Ungültige Felder oder eine bereits verwendete E-Mail-Adresse oder ein bereits verwendeter Benutzername führen zu HTTP `422`. Beim Erstellen eines Kontos wird keine Einladung gesendet, die Person wird nicht angemeldet und ihre E-Mail-Adresse wird nicht als bestätigt markiert. Lade sie über den Mitgliedschaftsendpunkt in eine Gruppe ein, um eine Einladung über den üblichen Benachrichtigungsablauf zu senden.

### Gruppen finden

`GET /api/b3/groups`

Liste alle Gruppen auf, die nicht gelöscht wurden, einschließlich privater Gruppen und Gruppen mit abgelaufenem Abonnement. Die Ergebnisse sind nach aufsteigender ID sortiert. Nutze `limit` (Standard- und Höchstwert `50`) und `offset` (Standardwert `0`), um die Ergebnisse seitenweise abzurufen.

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

### Mitgliedschaften auflisten

`GET /api/b3/memberships?group_id=123`

`group_id` ist erforderlich. Die Ergebnisse enthalten angenommene Mitgliedschaften und ausstehende Einladungen, sortiert nach aufsteigender Mitgliedschafts-ID. Widerrufene Mitgliedschaften sind ausgeschlossen. Nutze `limit` (Standard- und Höchstwert `50`) und `offset` (Standardwert `0`), um die Ergebnisse seitenweise abzurufen.

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

`admin` und `delegate` sind Gruppenrollen. `accepted_at` ist der Zeitstempel der Annahme oder `null`, solange eine Einladung aussteht. Dieser Endpunkt gibt keine Einladungstoken, Anmeldedaten oder Stimmen preis.

### Mitglieder einladen oder synchronisieren

`POST /api/b3/memberships`

Sende die erforderliche `group_id` und ein erforderliches `emails`-Array. Standardmäßig werden dadurch die aufgeführten Personen hinzugefügt, die noch keine aktive Mitgliedschaft haben. Alle anderen Mitgliedschaften bleiben bestehen. Leerzeichen am Anfang und Ende von E-Mail-Adressen werden entfernt, die Adressen werden in Kleinbuchstaben umgewandelt und Duplikate werden entfernt. Für neue Adressen werden Konten und ausstehende Einladungen erstellt. Bereits vorhandene, bestätigte Mitglieder einer anderen aktiven Gruppe derselben Organisation werden automatisch aufgenommen, entsprechend dem Einladungsablauf der Benutzer-API.

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

Um eine vollständige Mitgliederliste zu synchronisieren, setze `remove_absent` ausdrücklich auf `true`. Alle Personen, die in der Liste fehlen, werden aus dieser Gruppe und ihren Untergruppen entfernt. Ein leeres Array mit `remove_absent: true` entfernt alle Mitglieder, einschließlich der Gruppenadmins. Lasse `remove_absent` weg oder setze es auf `false`, wenn du nur Personen hinzufügen möchtest. Die älteren Werte `1` und `0` werden ebenfalls akzeptiert.

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

Eine Wiederholung derselben Anfrage erstellt keine doppelten Mitgliedschaften und versendet keine erneuten Einladungen. Wenn du ein Mitglied mit widerrufener Mitgliedschaft erneut einlädst, erhält es wieder Zugriff auf die Gruppe, jedoch keine frühere Admin-Rolle. Neue Einladungen und Rollenänderungen nutzen den üblichen Benachrichtigungsablauf, wobei keine Person als ausführend erfasst wird.

Fehlende oder fehlerhaft formatierte E-Mail-Listen und ungültige boolesche Werte führen zu HTTP `400`. Ein aufgeführtes deaktiviertes Konto führt zu HTTP `422`; reaktiviere es ausdrücklich, bevor du es hinzufügst. Bei ungültigen Kontodaten, überschrittenen Abonnementgrenzen oder anderen Fehlern wird die gesamte Synchronisierung rückgängig gemacht, einschließlich neuer Konten und entfernter Mitgliedschaften. Das Hinzufügen erfordert eine aktive Gruppe und unterliegt weiterhin den Mitgliedergrenzen des Abonnements.

### Mitgliedschaftsrollen aktualisieren

`PATCH /api/b3/memberships/:id`

Sende ein `membership`-Objekt mit einem oder beiden booleschen Feldern `admin` und `delegate`. Nicht angegebene Rollen bleiben unverändert. Unbekannte Felder werden abgelehnt; über den Endpunkt kannst du keine Mitgliedschaft übertragen, keine Einladung annehmen und keine Stimmgewichte ändern.

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

Gibt ein `membership`-Objekt mit denselben Feldern wie eine aufgelistete Mitgliedschaft zurück. Das Zuweisen einer Rolle erzeugt die übliche Rollenbenachrichtigung; eine erneute Anfrage mit unveränderter Rolle löst keine weitere Benachrichtigung aus. Rollenänderungen erfordern eine aktive Gruppe. Widerrufene Mitgliedschaften führen zu HTTP `404`.

### Eine Mitgliedschaft entfernen

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Gibt `{"success": true}` zurück. Das Entfernen widerruft den Zugriff auf die Gruppe und ihre Untergruppen, einschließlich des Zugriffs auf Themen und der Stimmrechte in aktiven Abstimmungen. Das Konto wird dabei nicht gelöscht, andere Gruppen werden nicht verändert und der direkte Zugriff auf Threads bleibt bestehen. Eine wiederholte Entfernung ist erfolgreich. Du kannst Mitgliedschaften aus Gruppen mit abgelaufenem Abonnement entfernen; gelöschte Gruppen führen zu HTTP `404`.

<!-- translation-section: user-object -->

## Benutzerobjekt

Antworten mit Benutzerdaten haben diese Struktur:

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
