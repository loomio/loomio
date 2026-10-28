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
  introduction: dcc488cf4bf95bee
  authentication: 1624bd7743eed571
  user-object: b2b4d79ee8f505b3
  list-users: 06b5e7ad34fdde1a
  example: 3acb0505edca3183
  show-user: 6167c19ab35d6a15
  examples: d9c41824e0384a20
  update-user: bedc612e54a1e308
  params: 29afbab19704dc95
  examples-2: 6057d28374ef1c17
  deactivate-user: b213bef5de71e919
  examples-3: ad853eb7c669f07e
  reactivate-user: e709bb67a8d00443
  examples-4: c29f5a10871166df
  redact-user: fe5179c466b43750
  examples-5: 056d2bbc8a653543
  delete-user: 5934de908f4137ec
  examples-6: 58907f0c1dad712b
  sso-profile-sync-settings: f77b2da54455de67
  provisioning: 3a44352fd4d2f00a
title_source: 370e81eb20eece44
title_generated: 110d7181b51daf50
---

<!-- translation-section: introduction -->

# Dokumentation der Loomio Server-API

<!-- seo-description: Nutze die Loomio Server-API, um Benutzerkonten auf einer selbst gehosteten Loomio-Installation bereitzustellen, Gruppen zu finden und Mitgliedschaften zu verwalten. -->

`/api/server0` ist für Vorgänge auf Serverebene vorgesehen. Nutze `/api/user0` für Aktionen, die du mit einem Loomio-Benutzerkonto ausführst.

Nutze einen Serverschlüssel, um Konten zu erstellen und zu verwalten, Gruppen in der gesamten Installation zu finden und deren Mitgliedschaften und Rollen zu verwalten. Dafür sind weder ein Bot-Konto noch ein Benutzer-API-Schlüssel oder eine Mitgliedschaft in den Gruppen erforderlich. Für Benutzer-API-Schlüssel gelten weiterhin die Gruppenberechtigungen der jeweiligen Person.

<!-- translation-section: authentication -->

## Authentifizierung

Der Schlüssel wird über die Einstellung `SERVER_API_KEY` in der Serverumgebung festgelegt. `create_env.sh` erzeugt einen Schlüssel für neue Installationen.

Sende den Schlüssel als Bearer-Token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Sende Zugangsdaten ausschließlich im `Authorization`-Header. API-Schlüssel in Abfragezeichenfolgen oder im Anfragetext werden abgelehnt.

<!-- translation-section: provisioning -->

## Konten und Mitgliedschaften bereitstellen

| Methode | Endpunkt | Zweck |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Ein Konto erstellen |
| `GET` | `/api/server0/groups` | Gruppen in der gesamten Installation finden |
| `GET` | `/api/server0/memberships` | Mitgliedschaften in einer Gruppe auflisten |
| `POST` | `/api/server0/memberships` | Mitglieder einladen oder eine vollständige Mitgliederliste synchronisieren |
| `PATCH` | `/api/server0/memberships/:id` | Admin- und Delegiertenrollen in einer Gruppe ändern |
| `DELETE` | `/api/server0/memberships/:id` | Eine Mitgliedschaft widerrufen |

Die bestehenden Endpunkte zum Aktualisieren, Deaktivieren, Reaktivieren, Anonymisieren und Löschen von Konten werden weiter unten beschrieben.

### Ein Konto erstellen

`POST /api/server0/users`

Sende ein `user`-Objekt mit dem Pflichtfeld `email`. Leerzeichen am Anfang und Ende von E-Mail-Adressen werden entfernt, und die Adressen werden in Kleinbuchstaben umgewandelt. Optionale Felder sind `name`, `username` und `is_admin`. Hier bezeichnet `is_admin` einen Admin der Instanz; Admin-Rollen für Gruppen werden über Mitgliedschaften verwaltet. Lasse `username` weg, um automatisch einen Benutzernamen zu erzeugen. Unbekannte Felder werden abgelehnt.

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

Die Antwort ist HTTP `201` mit einem `user`-Objekt. Ungültige Felder oder eine bereits verwendete E-Mail-Adresse oder ein bereits verwendeter Benutzername führen zu HTTP `422`. Beim Erstellen eines Kontos wird keine Einladung gesendet, die Person wird nicht angemeldet und ihre E-Mail-Adresse wird nicht als bestätigt markiert. Lade sie über den Mitgliedschaftsendpunkt in eine Gruppe ein, um eine Einladung über den üblichen Benachrichtigungsablauf zu senden.

### Gruppen finden

`GET /api/server0/groups`

Liste alle Gruppen auf, die nicht gelöscht wurden, einschließlich privater Gruppen und Gruppen mit abgelaufenem Abonnement. Die Ergebnisse sind nach aufsteigender ID sortiert. Nutze `limit` (Standard- und Höchstwert `50`) und `offset` (Standardwert `0`), um die Ergebnisse seitenweise abzurufen.

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

### Mitgliedschaften auflisten

`GET /api/server0/memberships?group_id=123`

`group_id` ist erforderlich. Die Ergebnisse enthalten angenommene Mitgliedschaften und ausstehende Einladungen, sortiert nach aufsteigender Mitgliedschafts-ID. Widerrufene Mitgliedschaften sind ausgeschlossen. Nutze `limit` (Standard- und Höchstwert `50`) und `offset` (Standardwert `0`), um die Ergebnisse seitenweise abzurufen.

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

`admin` und `delegate` sind Gruppenrollen. `accepted_at` ist der Zeitstempel der Annahme oder `null`, solange eine Einladung aussteht. Dieser Endpunkt gibt keine Einladungstoken, Anmeldedaten oder Stimmen preis.

### Mitglieder einladen oder synchronisieren

`POST /api/server0/memberships`

Sende die erforderliche `group_id` und ein erforderliches `emails`-Array. Standardmäßig werden dadurch die aufgeführten Personen hinzugefügt, die noch keine aktive Mitgliedschaft haben. Alle anderen Mitgliedschaften bleiben bestehen. Leerzeichen am Anfang und Ende von E-Mail-Adressen werden entfernt, die Adressen werden in Kleinbuchstaben umgewandelt und Duplikate werden entfernt. Für neue Adressen werden Konten und ausstehende Einladungen erstellt. Bereits vorhandene, bestätigte Mitglieder einer anderen aktiven Gruppe derselben Organisation werden automatisch aufgenommen, entsprechend dem Einladungsablauf der Benutzer-API.

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

Um eine vollständige Mitgliederliste zu synchronisieren, setze `remove_absent` ausdrücklich auf `true`. Alle Personen, die in der Liste fehlen, werden aus dieser Gruppe und ihren Untergruppen entfernt. Ein leeres Array mit `remove_absent: true` entfernt alle Mitglieder, einschließlich der Gruppenadmins. Lasse `remove_absent` weg oder setze es auf `false`, wenn du nur Personen hinzufügen möchtest. Die älteren Werte `1` und `0` werden ebenfalls akzeptiert.

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

Eine Wiederholung derselben Anfrage erstellt keine doppelten Mitgliedschaften und versendet keine erneuten Einladungen. Wenn du ein Mitglied mit widerrufener Mitgliedschaft erneut einlädst, erhält es wieder Zugriff auf die Gruppe, jedoch keine frühere Admin-Rolle. Neue Einladungen und Rollenänderungen nutzen den üblichen Benachrichtigungsablauf, wobei keine Person als ausführend erfasst wird.

Fehlende oder fehlerhaft formatierte E-Mail-Listen und ungültige boolesche Werte führen zu HTTP `400`. Ein aufgeführtes deaktiviertes Konto führt zu HTTP `422`; reaktiviere es ausdrücklich, bevor du es hinzufügst. Bei ungültigen Kontodaten, überschrittenen Abonnementgrenzen oder anderen Fehlern wird die gesamte Synchronisierung rückgängig gemacht, einschließlich neuer Konten und entfernter Mitgliedschaften. Das Hinzufügen erfordert eine aktive Gruppe und unterliegt weiterhin den Mitgliedergrenzen des Abonnements.

### Mitgliedschaftsrollen aktualisieren

`PATCH /api/server0/memberships/:id`

Sende ein `membership`-Objekt mit einem oder beiden booleschen Feldern `admin` und `delegate`. Nicht angegebene Rollen bleiben unverändert. Unbekannte Felder werden abgelehnt; über den Endpunkt kannst du keine Mitgliedschaft übertragen, keine Einladung annehmen und keine Stimmgewichte ändern.

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

Gibt ein `membership`-Objekt mit denselben Feldern wie eine aufgelistete Mitgliedschaft zurück. Das Zuweisen einer Rolle erzeugt die übliche Rollenbenachrichtigung; eine erneute Anfrage mit unveränderter Rolle löst keine weitere Benachrichtigung aus. Rollenänderungen erfordern eine aktive Gruppe. Widerrufene Mitgliedschaften führen zu HTTP `404`.

### Eine Mitgliedschaft entfernen

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
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

`GET /api/server0/users`

<!-- translation-section: example -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
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

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Anhand der externen Identität:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/server0/users/123
```

Anhand der externen Identität:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Anhand der externen Identität:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
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

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Anhand der externen Identität:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
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

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Anhand der externen Identität:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
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

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Beispiele

Anhand der Loomio-Benutzer-ID:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Anhand der externen Identität:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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
