---
title: Benutzer-API
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: 2b783ec54f27b2ce
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: a8b52c1a9bfdb16c
  create-a-webhook: 007312bcc204853a
  update-a-webhook: 124b07d2c401e319
  test-a-webhook-destination: 8fc3ac4ad10de6f6
  delete-a-webhook: 34eda1e07d65db80
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: bb5a1cfc7a6179aa
  params: 7eebe4e259830976
  participation-report: a1798112a78390fe
  params-2: 464322ffc1ac56e5
  example: 63bed6e82107f992
  create-discussion: ad202a0bdbfa7c2e
  params-3: 529f10e32be74c5c
  example-2: f25daafbba33718c
  show-discussion: b61aea6bf3d55e16
  example-3: e095e8e34cd562a0
  list-discussions: f209b8feb7c795a6
  params-4: 3ec197245f595be6
  example-4: 37d59c03fee8a15b
  list-threads: 34edc6c34552e136
  params-5: a5f41285afccdc8b
  example-5: 81c145ad5f6eb232
  read-thread: 0de1409aaa00b9ac
  example-6: 7c7553e1a3e94070
  edit-discussion: 1ab04653354b8036
  params-6: 4d3f5862a5f948b4
  example-7: d2a61a34af9e99c3
  soft-delete-discussion: fdb0d4db8470524c
  example-8: 423894a70b5ce489
  create-comment: bf95ee58b610f2fd
  params-7: 7af2127e1f721b66
  example-9: 4e7d49ac39938c12
  edit-comment: 49e722ec6bca25a1
  params-8: b2be783e4398d866
  example-10: bf626a7f693182c3
  soft-delete-comment: afb51bf4074aeab7
  example-11: e39b758ad0d7aa62
  create-poll: b2a11ae34ce22151
  params-9: 3e592c12f9cbb757
  example-12: f5d6029049637276
  show-poll: 2e7a14ac23eeffa6
  example-13: 1a5acf0b8a6f62f2
  list-polls: 606f27566d6d5f98
  params-10: 1b1a6f003f91eb9a
  example-14: 710a82f6b2203f48
  edit-poll: 42b85770aebd8ef2
  params-11: 52d278a2f38d6a9f
  example-15: 8f7d523fc36f5da7
  soft-delete-poll: 0f1b24e1263dcfbe
  example-16: ec71cfcd4a0b98ab
  list-memberships: 82712683aa3a424a
  params-12: d2fc821e97d53145
  example-17: 266443e0eb35078c
  manage-memberships: 3c821029101515ad
  params-13: 249b307203206387
  example-18: ffd950cd7ab5aaec
generated:
  introduction: 50c21a3619cb8368
  authentication-change: 9820b8e67c43d240
  response-size-and-related-records: 7ffa0d8a8c0cf309
  endpoint-summary: 7b89d9b9c352fa6e
  groups: db87cc751307f655
  list-groups: 45c669703823d14a
  get-a-group: 1ee0b0e16e7d2e33
  webhooks: ee96993caa26dc11
  list-webhooks: 5f1083df35d2f2f0
  create-a-webhook: 14dc451d5a899385
  update-a-webhook: 6346d42dbfb20995
  test-a-webhook-destination: b176f7209d1029b9
  delete-a-webhook: '039345c865b476ba'
  event-types: 5dfcc5e8a9a3050c
  http-delivery: 4cd0f713bda83588
  payload-formats: 7b8a6d2a9923d088
  search: d8a39a0790142377
  params: 890f88c083447d3b
  participation-report: 6aa6cd65703b22bd
  params-2: 39afbd7ea62d248b
  example: 283f4ac137796be8
  create-discussion: 0d9c271699fbed81
  params-3: 17efc23aca1165ea
  example-2: bfef3ad949316b73
  show-discussion: 1cf0451738c21534
  example-3: 88bb7bbc37d073e0
  list-discussions: 47737855c482b7e2
  params-4: 3925005405e7159c
  example-4: 36bdbf6c4b2980c4
  list-threads: 4846166f50887c9e
  params-5: d73ccecb24249ee4
  example-5: 63dcae5a90f8bced
  read-thread: 262af93613148ffa
  example-6: eebdc545a019af0b
  edit-discussion: d6aab557c638aeef
  params-6: c3f63561bba27b60
  example-7: 340710cb7a71029d
  soft-delete-discussion: 16ee0fbbd4b9c5b1
  example-8: e5c4f3210fe5b068
  create-comment: bff653cfac0bc233
  params-7: d1b920d9f8377b5a
  example-9: fceb04acf0a9139a
  edit-comment: 8f7e7878bd612e49
  params-8: ea962f1cc34fa6c7
  example-10: 5ec1a5dcecd98f46
  soft-delete-comment: 3a4d275d9def2074
  example-11: e408906f906f24e4
  create-poll: 99fb9381a4ea7f7c
  params-9: 51a8a51d3148f519
  example-12: 6d417ca6a02c1116
  show-poll: 43891ebbba6234c3
  example-13: 36ba1c6024f34ad3
  list-polls: 055efc4676b4c427
  params-10: c5032f6802beb8cc
  example-14: ffa11a2884c77b66
  edit-poll: 40530b6aab11a031
  params-11: 8a68c44ac4dd6ce1
  example-15: eb7bd24917af90aa
  soft-delete-poll: c7f67496d0d9da8f
  example-16: 6ffbc3adebc92c94
  list-memberships: 6807a5ffc8dc3e45
  params-12: 051c5900ac55ad7b
  example-17: f5e92b48a90d58c5
  manage-memberships: 9c8ce0b74f09647f
  params-13: 1daadb341a53f596
  example-18: b4517e40d95a0f21
title_source: c23fb6526b722360
title_generated: 69e07cde5ab8d5b0
needs_review:
  params-9: use "Veto" instead of "Block" for "block"
---

<!-- translation-section: introduction -->

# Dokumentation der Loomio-Benutzer-API

<!-- seo-description: Nutze die Loomio-Benutzer-API, um Diskussionen, Kommentare, Abstimmungen, Threads und Gruppenmitgliedschaften aus anderer Software heraus zu erstellen und zu verwalten. -->

`/api/b2` ist die benutzerorientierte API für Integrationen mit Loomio. Sie verwendet den API-Schlüssel eines Benutzerkontos, und jede Aktion wird im Namen dieses Kontos ausgeführt.

Gruppenaktionen verwenden die Mitgliedschaften und Gruppenberechtigungen des Kontos, dessen API-Schlüssel verwendet wird. Administrationsrechte für die Instanz erweitern den Zugriff eines API-Schlüssels auf Gruppen oder Inhalte nicht; nutze für die Verwaltung auf Instanzebene die Server-API.

Verwende den API-Schlüssel des Loomio-Benutzerkontos, das die Aktionen ausführen soll. Ein eigenes Bot-Konto ist sinnvoll, wenn eine Integration keine Einladungen zu Abstimmungen oder Benachrichtigungen erhalten soll.

Angemeldete Personen finden ihren API-Schlüssel und ihre Gruppen-IDs auf der [Seite für den API-Zugriff](/profile/api_access).

Sende den API-Schlüssel in einem `Authorization: Bearer`-Header. API-Schlüssel in Abfrageparametern werden abgelehnt, da URLs von Proxys und in Zugriffsprotokollen aufgezeichnet werden können.

<!-- translation-section: authentication-change -->

### Änderung der Authentifizierung

Der API-Schlüssel wurde bisher als URL-Parameter `api_key` akzeptiert. Anfragen mit `?api_key=YOUR_API_KEY` funktionieren nicht mehr. Verwende stattdessen den HTTP-Header `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Die Beispiele verwenden `YOUR_API_KEY`, die Gruppen-ID `123` und `https://www.loomio.com/`. Ersetze diese durch deinen API-Schlüssel, deine Gruppen-ID und die URL deiner Loomio-Installation.

<!-- translation-section: response-size-and-related-records -->

## Antwortgröße und zugehörige Datensätze

Antworten der Benutzer-API verwenden ein zusammengesetztes Format: Die primären Datensätze werden durch zugehörige Datensätze wie Topics, Gruppen, Benutzerkonten, Abstimmungen und Reaktionen ergänzt. So kann ein Client mit einer einzigen Anfrage einen lokalen Datenspeicher befüllen. Die Antwort kann jedoch mehr Daten enthalten, als eine einfache Integration benötigt.

Übergebe `compact=1`, um umfangreiche zugehörige Topics, Gruppen, Hauptgruppen, Mitgliedschaften, Reaktionen, Schlagwörter und Übersetzungen wegzulassen. Primäre Datensätze und die zugehörigen Datensätze, die zum Verständnis ihrer Inhalte benötigt werden, bleiben enthalten.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Für eine gezielte Steuerung übergib `exclude_types` mit durch Leerzeichen getrennten Datensatztypen im Singular. Beispielsweise lässt `exclude_types=group reaction` zugehörige Gruppen und Reaktionen weg. Übliche Werte sind `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` und `topic_item`. Ausschlüsse gelten für zugehörige Datensätze, nicht für die primäre Ressource, die über den Endpunkt angefordert wird.

Antworten mit Datensatzsammlungen enthalten `meta.total`, wenn eine genaue Gesamtanzahl definiert ist. Die Gesamtanzahl wird berechnet, bevor `limit` und `offset` angewendet werden. Endpunkte wie die Suche, die bewusst eine begrenzte Ergebnismenge zurückgeben, lassen `meta.total` weg, statt `null` zurückzugeben.

<!-- translation-section: endpoint-summary -->

## Übersicht der Endpunkte

| Methode | Endpunkt | Zweck |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Gruppen des Kontos auflisten, dessen API-Schlüssel verwendet wird |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Eine sichtbare Gruppe abrufen |
| `GET` | `/api/b2/reports` | Einen Beteiligungsbericht erstellen |
| `GET` | `/api/b2/search` | Sichtbare Diskussionen, Kommentare, Abstimmungen, Stimmen und Fazits durchsuchen |
| `POST` | `/api/b2/discussions` | Eine Diskussion erstellen |
| `GET` | `/api/b2/discussions/:id` | Eine Diskussion abrufen |
| `GET` | `/api/b2/discussions` | Diskussionen in einer Gruppe auflisten |
| `PATCH` | `/api/b2/discussions/:id` | Eine Diskussion bearbeiten |
| `DELETE` | `/api/b2/discussions/:id` | Eine Diskussion als gelöscht markieren |
| `GET` | `/api/b2/threads` | Sichtbare Diskussions-Threads und Threads eigenständiger Abstimmungen auflisten |
| `GET` | `/api/b2/threads/:topic_id` | Einen Thread abrufen |
| `GET` | `/api/b2/threads/:topic_id/items` | Die geordneten Einträge eines Threads abrufen |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Einen vollständigen Thread als Markdown abrufen |
| `POST` | `/api/b2/comments` | Einen Kommentar oder eine Antwort erstellen |
| `PATCH` | `/api/b2/comments/:id` | Einen Kommentar bearbeiten |
| `DELETE` | `/api/b2/comments/:id` | Einen Kommentar als gelöscht markieren |
| `POST` | `/api/b2/polls` | Eine Abstimmung erstellen |
| `GET` | `/api/b2/polls/:id` | Eine Abstimmung abrufen |
| `GET` | `/api/b2/polls` | Abstimmungen in einer Gruppe auflisten |
| `PATCH` | `/api/b2/polls/:id` | Eine Abstimmung bearbeiten |
| `DELETE` | `/api/b2/polls/:id` | Eine Abstimmung als gelöscht markieren |
| `GET` | `/api/b2/memberships` | Mitgliedschaften einer Gruppe auflisten |
| `POST` | `/api/b2/memberships` | Mitglieder hinzufügen und optional nicht aufgeführte Mitglieder entfernen |
| `GET` | `/api/b2/chatbots` | Chat-Integrationen und Webhooks einer Gruppe auflisten |
| `POST` | `/api/b2/chatbots` | Eine Chat-Integration oder einen Webhook erstellen |
| `PATCH` | `/api/b2/chatbots/:id` | Eine Chat-Integration oder einen Webhook aktualisieren |
| `DELETE` | `/api/b2/chatbots/:id` | Eine Chat-Integration oder einen Webhook löschen |
| `POST` | `/api/b2/chatbots/check` | Einen Verbindungstest für einen Webhook senden |

<!-- translation-section: groups -->

## Gruppen

<!-- translation-section: list-groups -->

### Gruppen auflisten

Gibt die Gruppen zurück, in denen das Konto, dessen API-Schlüssel verwendet wird, eine aktive Mitgliedschaft hat.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Die Antwort enthält alle passenden Datensätze in einem `groups`-Array ohne Seiteneinteilung. Sie umfasst Hauptgruppen und Untergruppen, einschließlich Gruppen, deren Abonnement derzeit nicht aktiv ist. Prüfe das Feld `enabled`, wenn eine Integration nur mit aktivierten Gruppen arbeiten soll.

Wichtige Gruppenfelder sind:

| Feld | Beschreibung |
| --- | --- |
| `id` | Numerische Gruppen-ID, die von anderen Endpunkten der Benutzer-API verwendet wird |
| `key` | Stabiler Kurzschlüssel, der in Loomio-URLs verwendet wird |
| `handle` | Lesbare Kennung der Gruppe |
| `name` | Gruppenname |
| `full_name` | Gruppenname einschließlich des Kontexts der Hauptgruppe |
| `parent_id` | Numerische ID der Hauptgruppe einer Untergruppe, andernfalls `null` |
| `enabled` | Ob die Gruppe und ihr Abonnement aktiv sind |
| `memberships_count` | Anzahl aktiver und ausstehender Mitgliedschaften |
| `accepted_memberships_count` | Anzahl angenommener Mitgliedschaften |
| `pending_memberships_count` | Anzahl ausstehender Einladungen |
| `admin_memberships_count` | Anzahl der Personen mit Administrationsrechten für die Gruppe |
| `discussions_count` | Anzahl der Diskussionen direkt in der Gruppe |
| `polls_count` | Anzahl der Abstimmungen direkt in der Gruppe |
| `subgroups_count` | Anzahl der Untergruppen |

Die Antwort kann zusätzliche Gruppeneinstellungen, zugehörige Datensätze der Hauptgruppen und die Mitgliedschaften des API-Kontos enthalten. Clients sollten Felder ignorieren, die sie nicht verwenden.

<!-- translation-section: get-a-group -->

### Eine Gruppe abrufen

Gibt eine Gruppe zurück, die für das Konto sichtbar ist, dessen API-Schlüssel verwendet wird.

`GET /api/b2/groups/:id_or_key_or_handle`

Als Bezeichner kannst du die numerische ID, den Schlüssel oder die lesbare Kennung der Gruppe verwenden.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Die Antwort enthält die Gruppe im `groups`-Array und verwendet dieselben Felder wie der Endpunkt zum Auflisten von Gruppen. Eine Anfrage für eine Gruppe, auf die das Konto keinen Zugriff hat, gibt einen Berechtigungsfehler zurück.

<!-- translation-section: webhooks -->

## Webhooks

Die Benutzer-API basiert auf Anfragen: Eine Integration ruft Loomio auf, wenn sie Daten lesen oder ändern möchte. Ein Gruppen-Webhook ermöglicht die Übertragung in die andere Richtung. Loomio sendet ausgewählte Gruppenereignisse an deinen Endpunkt, sobald sie eintreten. So muss eine Integration die REST-API nicht regelmäßig nach Änderungen abfragen.

Webhooks werden für jede Gruppe einzeln eingerichtet und erfordern Administrationsrechte für die Gruppe. Du kannst sie über die Loomio-Oberfläche verwalten:

1. Öffne die Gruppe.
2. Öffne das Gruppenmenü und wähle **Chat-Integrationen**.
3. Füge die Integration hinzu, die zum Nutzdatenformat passt, das dein Endpunkt akzeptiert. Verwende für einen allgemein nutzbaren Endpunkt das Mattermost/Markdown-Format.
4. Gib einen Namen und die Ziel-URL ein.
5. Wähle die Ereignisse aus, die Loomio automatisch senden soll.
6. Speichere die Integration und sende mit **Testverbindung** eine Testnachricht.

Verwende ein HTTPS-Ziel mit einer nicht erratbaren URL. Loomio verlangt, dass das Ziel zu einer öffentlichen Adresse aufgelöst wird, und blockiert Anfragen an lokale oder private Netzwerkadressen.

Agenten und andere Integrationen können Webhooks stattdessen über die unten beschriebenen Chatbot-Endpunkte mit Bearer-Authentifizierung verwalten. Die Ressource heißt aus Kompatibilitätsgründen mit Loomios Chat-Integrationen `chatbots`, steht aber auch für allgemeine ausgehende Webhooks.

<!-- translation-section: list-webhooks -->

### Webhooks auflisten

Gibt die für eine Gruppe eingerichteten Chat-Integrationen zurück. Das Konto, dessen API-Schlüssel verwendet wird, muss Administrationsrechte für diese Gruppe haben. Die Antwort enthält Ziel-URLs und darf deshalb gewöhnlichen Gruppenmitgliedern nicht zugänglich gemacht werden.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Die Antwort enthält ein `chatbots`-Array mit diesen Feldern:

| Feld | Beschreibung |
| --- | --- |
| `id` | ID der Integration für Aktualisierungen und das Löschen |
| `group_id` | Gruppe, die die Ereignisse empfängt |
| `name` | Name zur Verwaltung der Integration |
| `kind` | `webhook` für einen ausgehenden Webhook oder `matrix` für eine Matrix-Integration |
| `webhook_kind` | Nutzdatenformat: `markdown`, `slack`, `discord`, `microsoft` oder `webex` |
| `server` | Ziel-URL |
| `event_kinds` | Automatisch gesendete Ereignisse |
| `notification_only` | Ob Nachrichten nur die Überschrift der Benachrichtigung enthalten |

<!-- translation-section: create-a-webhook -->

### Einen Webhook erstellen

`POST /api/b2/chatbots`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": ["new_discussion", "new_comment", "poll_created", "outcome_created"],
    "notification_only": false
  }' \
  https://www.loomio.com/api/b2/chatbots
```

Das Konto, dessen API-Schlüssel verwendet wird, muss Administrationsrechte für die Gruppe mit der ID `group_id` haben. Vor dem Speichern wird geprüft, ob das Ziel eine öffentliche URL ist.

<!-- translation-section: update-a-webhook -->

### Einen Webhook aktualisieren

`PATCH /api/b2/chatbots/:id`

Sende alle Felder, die geändert werden sollen. Durch eine Änderung von `group_id` kann der Webhook nicht in eine andere Gruppe übertragen werden.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Ein Webhook-Ziel testen

Sende eine Markdown-kompatible Testnachricht an ein Ziel, bevor oder nachdem du dessen Konfiguration speicherst.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Webhook löschen

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Das Löschen der Konfiguration stoppt zukünftige Zustellungen. Dabei werden keine Inhalte der Loomio-Gruppe gelöscht.

<!-- translation-section: event-types -->

### Ereignistypen

Ein Webhook kann diese Ereignistypen abonnieren:

| Ereignis | Wann es gesendet wird |
| --- | --- |
| `new_discussion` | Eine Diskussion wird gestartet |
| `discussion_edited` | Eine Diskussion wird bearbeitet |
| `new_comment` | Ein Kommentar wird erstellt |
| `poll_created` | Eine Abstimmung wird gestartet |
| `poll_edited` | Eine Abstimmung wird bearbeitet |
| `poll_closing_soon` | Eine Abstimmung nähert sich ihrem Endzeitpunkt |
| `poll_expired` | Eine Abstimmung erreicht ihren Endzeitpunkt |
| `poll_closed_by_user` | Eine Person beendet eine Abstimmung manuell |
| `poll_reopened` | Eine Abstimmung wird wieder geöffnet |
| `outcome_created` | Ein Fazit wird veröffentlicht |
| `outcome_updated` | Ein Fazit wird aktualisiert |
| `outcome_review_due` | Die Überprüfung eines Fazits wird fällig |
| `stance_created` | Eine Stimme wird abgegeben |
| `stance_updated` | Eine Stimme wird geändert |

Der Webhook gehört zu einer Gruppe und empfängt die abonnierten Ereignisse aus dieser Gruppe. Personen können die Integration auch ausdrücklich beim Teilen oder beim Senden bestimmter Benachrichtigungen auswählen, selbst wenn das entsprechende automatische Ereignis nicht ausgewählt ist.

<!-- translation-section: http-delivery -->

### HTTP-Zustellung

Loomio sendet einen asynchronen HTTP `POST` mit diesem Header an die konfigurierte URL:

```text
Content-Type: application/json; charset=utf-8
```

Das Zeitlimit für die Anfrage beträgt fünf Sekunden. Eine `2xx`-Antwort, einschließlich `204 No Content`, gilt als erfolgreich. Dienste, die Webhooks empfangen, sollten zügig antworten, längere Aufgaben asynchron verarbeiten und mit doppelten Zustellungen oder Zustellungen in abweichender Reihenfolge umgehen können.

Loomio fügt derzeit keine Webhook-Signatur, keinen Header mit einem gemeinsamen Geheimnis, keine Ereignis-ID und keine Zustellungs-ID hinzu. Behandle die vollständige Ziel-URL als Zugangsdaten, mache sie nicht öffentlich zugänglich und füge der URL ein nicht erratbares Token hinzu, wenn der empfangende Dienst dies unterstützt. Wenn du ein stabiles, maschinenlesbares Ereignisschema oder eine signierte Zustellung benötigst, verwende den Webhook als Änderungsbenachrichtigung und rufe die aktuellen Datensätze über die authentifizierte Benutzer-API ab.

<!-- translation-section: payload-formats -->

### Nutzdatenformate

Webhook-Nutzdaten sind für die Anzeige in Chatdiensten bestimmte Nachrichten. Sie sind keine vollständig serialisierten Loomio-Datensätze. Links in der Nachricht verweisen auf die betroffenen Loomio-Inhalte; eine Integration kann die Benutzer-API nutzen, wenn sie den aktuellen Stand in strukturierter Form benötigt.

| Integrationsformat | Wichtigste JSON-Felder |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, auf etwa 1.900 Zeichen begrenzt |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Das allgemeine Markdown-Format sendet beispielsweise einen Nachrichteninhalt mit dieser Struktur:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Der genaue Nachrichtentext hängt vom Ereignis, der Sprache der Gruppe, der Einstellung für reine Benachrichtigungen und der Loomio-Version ab. Empfangende Dienste sollten sich auf die dokumentierten Felder der obersten Ebene des ausgewählten Formats verlassen, statt den Wortlaut der Sätze auszuwerten.

<!-- translation-section: search -->

## Suche

Suche nach Diskussionen, Kommentaren, Abstimmungen, Stimmen und Fazits, die für die Person mit dem API-Schlüssel sichtbar sind. Die Ergebnisse enthalten öffentliche Inhalte auch dann, wenn die Person kein Mitglied der jeweiligen Gruppe ist; für private Inhalte gelten weiterhin die üblichen Sichtbarkeitsregeln für Threads.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `query` | Suchtext. Exakte und unscharfe Treffer werden unterstützt |
| `group_id` | Beschränke die Ergebnisse auf eine sichtbare Gruppe |
| `org_id` | Beschränke die Ergebnisse auf eine sichtbare Hauptgruppe und ihre sichtbaren Untergruppen. Verwende `0` für direkte Diskussionen |
| `type` | Beschränke die Ergebnisse auf einen Typ: `Discussion`, `Comment`, `Poll`, `Stance` oder `Outcome` |
| `types` | Durch Kommas getrennte Liste der Ergebnistypen |
| `tag` | Beschränke die Ergebnisse auf Threads mit diesem Schlagwort |
| `author_id` | Beschränke die Ergebnisse auf Inhalte einer verfassenden Person. Ohne `query` wird deren jüngste sichtbare Aktivität zurückgegeben |
| `order` | Setze den Wert auf `authored_at_desc`, um passende Inhalte nach ihrem Erstellungszeitpunkt zu sortieren |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Die Antwort enthält ein `search_results`-Array. Jedes Ergebnis identifiziert den gefundenen Datensatz und seinen sichtbaren Kontext anhand von Feldern wie `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` und `tags`. Felder, die auf ein Ergebnis nicht zutreffen, haben den Wert `null`.

<!-- translation-section: participation-report -->

## Beteiligungsbericht

Rufe dieselben zusammengefassten Beteiligungsdaten ab, die im Beteiligungsbericht von Loomio verwendet werden.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `section` | Berichtsabschnitt: `base`, `users` oder `countries`. Verwende `users` für die Aktivität pro Person |
| `group_scope` | `custom` oder `my`. Der frühere Wert `all` wird wie `my` behandelt, da Schlüssel für die Benutzer-API niemals Zugriff auf die gesamte Instanz erhalten |
| `group_ids` | Durch Kommas getrennte Gruppen-IDs bei `group_scope=custom`. IDs von Gruppen, in denen die Person mit dem API-Schlüssel kein Mitglied ist, werden ignoriert |
| `start_month` | Erster einzubeziehender Monat im Format `YYYY-MM`; standardmäßig der Monat vor 12 Monaten |
| `end_month` | Letzter einzubeziehender Monat im Format `YYYY-MM`; standardmäßig der aktuelle Monat |
| `interval` | Intervall für den Abschnitt `base`: `day`, `week`, `month` oder `year` |
| `member_type` | Setze den Wert bei `section=users` auf `delegate`, um nur aktuelle Delegierte zurückzugeben |

Eine Person gilt als delegiert, wenn sie in mindestens einer ausgewählten Gruppe eine aktive Mitgliedschaft als delegierte Person hat. Ihre Anzahlen werden über alle ausgewählten Gruppen hinweg zusammengefasst. Zeilen für Delegierte werden auch dann zurückgegeben, wenn alle Aktivitätszahlen null sind. Die Anzahlen erfassen Threads, Kommentare, Abstimmungen, Stimmen, Fazits und Reaktionen; sie geben keine Beteiligungsquoten an Abstimmungen an. Die Zeilen für Personen enthalten außerdem die Anzahl der ausgegebenen, abgegebenen und nicht abgegebenen Stimmzettel bei nicht anonymen Abstimmungen. Anonyme Abstimmungen sind von allen personenbezogenen Zählungen zur Stimmabgabe ausgeschlossen. `all_votes_cast` ist nur dann wahr, wenn mindestens ein Stimmzettel ausgegeben und jeder ausgegebene Stimmzettel abgegeben wurde.

Die API wendet dieselben Sichtbarkeitsregeln für Gruppen an wie der Bericht in Loomio. Ein Schlüssel für die Benutzer-API kann keine Berichtsdaten aus Gruppen zugänglich machen, auf die die Person mit diesem Schlüssel keinen Zugriff hat.

<!-- translation-section: example -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Das `users`-Array enthält vollständige Aktivitätszeilen:

```json
{
  "users": [
    {
      "id": 456,
      "name": "Ada Lovelace",
      "country": "NZ",
      "delegate": true,
      "threads": 2,
      "comments": 8,
      "polls": 1,
      "votes": 5,
      "votes_cast": 5,
      "votes_issued": 6,
      "votes_missed": 1,
      "all_votes_cast": false,
      "outcomes": 1,
      "reactions": 4
    }
  ]
}
```

<!-- translation-section: create-discussion -->

## Diskussion erstellen

Erstelle eine Diskussion im Namen der Person mit dem API-Schlüssel.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Gruppe, in der der Thread erstellt wird |
| `title` | Titel des Threads, erforderlich |
| `description` | Kontext des Threads, optional |
| `description_format` | Entweder `md` oder `html`, optional, standardmäßig `md` |
| `recipient_audience` | `group` oder null. Bei `group` wird die gesamte Gruppe über den neuen Thread benachrichtigt |
| `recipient_user_ids` | Array von Benutzer-IDs der Personen, die benachrichtigt oder zum Thread eingeladen werden sollen |
| `recipient_emails` | Array von E-Mail-Adressen der Personen, die zum Thread eingeladen werden sollen |
| `recipient_message` | Nachricht, die in die Einladung per E-Mail aufgenommen wird |

<!-- translation-section: example-2 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Diskussion abrufen

Rufe eine Diskussion über ihre ID (eine Ganzzahl) oder ihren Schlüssel (eine Zeichenfolge) ab.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Diskussionen auflisten

Liste die Diskussionen in einer Gruppe auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird. Bei einer öffentlich sichtbaren Gruppe können auch Personen ohne Mitgliedschaft die öffentlichen Diskussionen auflisten; private Diskussionen bleiben auf Personen beschränkt, die sie in Loomio lesen dürfen.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Diskussionen aufgelistet werden sollen |
| `status` | Zeichenfolge, optional, Standardwert `open`. Werte: `open`, `closed`, `all` |
| `limit` | Ganzzahl, optional, Standardwert 50. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seiteneinteilung übersprungen werden |

Abwärtskompatibilität: `per` und `from` werden als Aliasse für `limit` und `offset` akzeptiert und funktionieren weiterhin.

<!-- translation-section: example-4 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Threads auflisten

Liste die Diskussions- und Abstimmungs-Threads auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird, sortiert nach der neuesten Aktivität. Die ID eines Threads ist seine `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `limit` | Ganzzahl, optional, Standardwert 50. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seiteneinteilung übersprungen werden |

<!-- translation-section: example-5 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Thread lesen

Lies einen Thread, seinen geordneten Ereignisstrom oder sein vollständiges sichtbares Markdown-Dokument.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Beispiel

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Der Endpunkt `items` gibt den geordneten Ereignisstrom zurück, einschließlich sichtbarer Kommentare, Abstimmungen, Stimmen und Fazits. Der Endpunkt `markdown` gibt den vollständigen sichtbaren Thread als ein Markdown-Dokument zurück. Begründungen zu Stimmen werden nur aufgenommen, wenn sie für die Person sichtbar sind, deren API-Schlüssel verwendet wird.

Alle Thread-Endpunkte setzen dieselben Berechtigungen durch wie die Loomio-Oberfläche. Der API-Schlüssel gewährt keinen Zugriff auf einen Thread, den die Person normalerweise nicht öffnen darf.

<!-- translation-section: edit-discussion -->

## Diskussion bearbeiten

Bearbeite eine Diskussion als die Person, deren API-Schlüssel verwendet wird. Es gelten dieselben Berechtigungen wie in Loomio: Die Person muss diese Diskussion bearbeiten dürfen.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `title` | Aktualisierter Titel |
| `description` | Aktualisierter Kontext |
| `description_format` | Entweder `md` oder `html`, optional, Standardwert `md` |
| `recipient_audience` | `group` oder null. Bei `group` wird die gesamte Gruppe über die Bearbeitung benachrichtigt |
| `recipient_user_ids` | Array von Benutzer-IDs der Personen, die benachrichtigt oder zum Thread eingeladen werden sollen |
| `recipient_emails` | Array von E-Mail-Adressen der Personen, die zum Thread eingeladen werden sollen |
| `recipient_message` | Nachricht, die in die Einladung per E-Mail aufgenommen werden soll |

<!-- translation-section: example-7 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Diskussion als gelöscht markieren

Markiere eine Diskussion im Namen des Kontos, zu dem der API-Schlüssel gehört, als gelöscht. Dadurch wird die Diskussion verworfen, ihr Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Kommentar erstellen

Erstelle einen Kommentar in einer Diskussion im Namen des Kontos, zu dem der API-Schlüssel gehört.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `discussion_id` | Ganzzahl, erforderlich. ID der Diskussion, die du kommentieren möchtest |
| `body` | Kommentartext, erforderlich, sofern kein Anhang mitgesendet wird |
| `body_format` | Entweder `md` oder `html`, optional, Standardwert `md` |

<!-- translation-section: example-9 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Kommentar bearbeiten

Bearbeite einen Kommentar im Namen des Kontos, zu dem der API-Schlüssel gehört. Es gelten dieselben Berechtigungen wie in Loomio: Das Konto muss diesen Kommentar bearbeiten dürfen.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `body` | Aktualisierter Kommentartext |
| `body_format` | Entweder `md` oder `html`, optional, Standardwert `md` |

<!-- translation-section: example-10 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Kommentar als gelöscht markieren

Markiere einen Kommentar im Namen des Kontos, zu dem der API-Schlüssel gehört, als gelöscht. Dadurch wird der Kommentar verworfen und sein Text ausgeblendet, sein Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Abstimmung erstellen

Erstelle eine Abstimmung im Namen des Kontos, zu dem der API-Schlüssel gehört.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, optional, Standardwert null. ID der Gruppe für die Abstimmung. Wenn `discussion_id` übergeben wird, wird `group_id` ignoriert |
| `discussion_id` | Ganzzahl, optional, Standardwert null. ID des Diskussions-Threads, dem diese Abstimmung hinzugefügt werden soll |
| `title` | Zeichenfolge, erforderlich. Titel der Abstimmung |
| `poll_type` | Zeichenfolge, erforderlich. Werte: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Zeichenfolge, optional. Text der Abstimmung |
| `details_format` | Zeichenfolge, optional, Standardwert `md`. Werte: `md` oder `html` |
| `options` | Array von Zeichenfolgen. Wenn `poll_type` den Wert `proposal` hat, sind die gültigen Werte `agree` (Zustimmung), `disagree` (Widerspruch), `abstain` (Enthaltung), `block` (Veto). Wenn `poll_type` den Wert `meeting` hat, gib Datums- oder Datumszeit-Zeichenfolgen im ISO-8601-Format an. Für alle anderen Abstimmungstypen ist jede Zeichenfolge gültig |
| `closing_at` | ISO-8601-Zeichenfolge oder null, Standardwert null. Beispiel: `2026-09-01T12:00:00Z`. Bei null ist die Stimmabgabe deaktiviert und die Abstimmung gilt als in Bearbeitung |
| `specified_voters_only` | Boolescher Wert, optional, Standardwert false. Bei true können nur die angegebenen Personen abstimmen. Bei false werden alle Personen in der Gruppe zur Stimmabgabe eingeladen |
| `hide_results` | Zeichenfolge, optional, Standardwert `off`. Werte: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Boolescher Wert, Standardwert false. Zeigt den Abstimmenden die Optionen in zufälliger Reihenfolge an |
| `anonymous` | Boolescher Wert, optional, Standardwert false. Verbirgt die Identität der Abstimmenden |
| `recipient_audience` | `group` oder null, optional, Standardwert null. Bei `group` wird die gesamte Gruppe benachrichtigt |
| `notify_on_closing_soon` | Zeichenfolge, optional, Standardwert `nobody`. Werte: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array von Benutzer-IDs der Personen, die benachrichtigt oder eingeladen werden sollen |
| `recipient_emails` | Array von E-Mail-Adressen der Personen, die zur Stimmabgabe eingeladen werden sollen |
| `recipient_message` | Nachricht, die in die Einladung per E-Mail aufgenommen werden soll |
| `notify_recipients` | Boolescher Wert, Standardwert false. Bei false werden Personen hinzugefügt, ohne Benachrichtigungen zu senden. Bei true erhalten alle mit dieser Anfrage eingeladenen Personen eine Benachrichtigung per E-Mail |

<!-- translation-section: example-12 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Abstimmung abrufen

Rufe eine Abstimmung anhand ihrer ID (einer Ganzzahl) oder ihres Schlüssels (einer Zeichenkette) ab.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Abstimmungen auflisten

Liste die Abstimmungen einer Gruppe auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird. Bei einer öffentlich sichtbaren Gruppe können auch Personen ohne Mitgliedschaft deren öffentliche Abstimmungen auflisten; private Abstimmungen bleiben auf Personen beschränkt, die sie in Loomio lesen können. Die Antwort enthält das aktuelle Fazit jeder sichtbaren Abstimmung. Mit `status=closed` kannst du daher Vorschläge auflisten, über die bereits entschieden wurde.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Abstimmungen aufgelistet werden sollen |
| `status` | Zeichenkette, optional, Standardwert `active`. Werte: `active`, `closed`, `all` |
| `limit` | Ganzzahl, optional, Standardwert 50. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seitennavigation übersprungen werden |

Abwärtskompatibilität: `per` und `from` werden als Aliasse für `limit` und `offset` akzeptiert und funktionieren weiterhin.

<!-- translation-section: example-14 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Abstimmung bearbeiten

Bearbeite eine Abstimmung als die Person, deren API-Schlüssel verwendet wird. Es gelten dieselben Berechtigungen wie in Loomio: Diese Person muss die Abstimmung bearbeiten dürfen.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `title` | Aktualisierter Titel |
| `details` | Aktualisierte Details der Abstimmung |
| `details_format` | Entweder `md` oder `html`, optional, Standardwert `md` |
| `options` | Aktualisierte Optionsnamen. Änderungen an den Optionen können sich je nach Zustand der Abstimmung auf vorhandene Stimmen auswirken |
| `closing_at` | ISO-8601-Zeichenkette oder null |
| `recipient_audience` | `group` oder null. Bei `group` wird die gesamte Gruppe benachrichtigt |
| `recipient_user_ids` | Array von Benutzer-IDs der Personen, die benachrichtigt oder eingeladen werden sollen |
| `recipient_emails` | Array von E-Mail-Adressen der Personen, die zur Stimmabgabe eingeladen werden sollen |
| `recipient_message` | Nachricht, die in die Einladung per E-Mail aufgenommen werden soll |

<!-- translation-section: example-15 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Abstimmung als gelöscht markieren

Markiere eine Abstimmung als gelöscht, indem du den API-Schlüssel der handelnden Person verwendest. Dadurch wird die Abstimmung verworfen, ihr Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Mitgliedschaften auflisten

Liste die Mitgliedschaften auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird. Gruppenmitglieder können Namen, IDs, Titel und Rollen der Mitglieder lesen. E-Mail-Adressen werden nur für das eigene Konto dieser Person ausgegeben oder wenn sie die Gruppe administriert.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Mitgliedschaften aufgelistet werden sollen |

<!-- translation-section: example-17 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Mitgliedschaften verwalten

Sende eine Liste von E-Mail-Adressen. Alle neuen E-Mail-Adressen werden zur Gruppe eingeladen. Anders als beim Auflisten von Mitgliedschaften benötigst du für diesen Vorgang Berechtigungen zur Administration der Gruppe.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Mitgliedschaften verwaltet werden sollen |
| `emails` | Array von Zeichenfolgen, erforderlich. E-Mail-Adressen der Personen, die zur Gruppe eingeladen werden sollen |
| `remove_absent` | Boolescher Wert. Wenn true, werden alle Personen aus der Gruppe entfernt, deren E-Mail-Adresse nicht in der Liste steht |

<!-- translation-section: example-18 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Wenn du `remove_absent=1` übergibst, werden alle Mitglieder aus der Gruppe entfernt, die nicht in der Liste enthalten sind. Sei vorsichtig: Du könntest alle Mitglieder deiner Gruppe entfernen.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Dies gibt ein Objekt mit `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}` zurück.
