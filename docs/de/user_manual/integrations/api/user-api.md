---
title: Benutzer-API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: 8e54484eccd9ce0e
  authentication-change: 65ccd2abee3d278d
  response-size-and-related-records: 7c117c4b6fc6474a
  endpoint-summary: 6eff5477fe0de2d6
  groups: db87cc751307f655
  list-groups: a32a6125d28be41b
  get-a-group: 4236e2eabc7f9973
  webhooks: 36613bafacd43e3b
  list-webhooks: a34bd84eff2b4e07
  create-a-webhook: 51ac310788094227
  update-a-webhook: e8a36a97282e7360
  test-a-webhook-destination: 9fc376f5673cd698
  delete-a-webhook: 268ca96702912116
  event-types: dc3030e1a20fd2da
  http-delivery: 1ec86ddce9fd22c5
  payload-formats: f065a36f967c1e01
  search: bc56435ede584978
  params: 23ea4cb8ac14df89
  participation-report: 43868e1e9bcd90b5
  params-2: aaa7c32d2e1c14a3
  example: 15d1b0509f83ef33
  create-discussion: 3114090be91d1686
  params-3: 8578464ba00a55ad
  example-2: bfef3ad949316b73
  show-discussion: fee009da35033524
  example-3: 88bb7bbc37d073e0
  list-discussions: 37a01612a03349b5
  params-4: 32d84a5fe9df81cc
  example-4: 36bdbf6c4b2980c4
  list-threads: 9265c57196d294fa
  params-5: 1c34e2d5586a9f5f
  example-5: 63dcae5a90f8bced
  read-thread: b27063fd996de068
  example-6: 5b4fd58d8a93eaac
  edit-discussion: 518309f6c6de8c35
  params-6: d994441d76958874
  example-7: 340710cb7a71029d
  soft-delete-discussion: 7e72d933a7bb2ac1
  example-8: e5c4f3210fe5b068
  create-comment: e7c50649a2349aff
  params-7: 2122fa8c0294d5b8
  example-9: fceb04acf0a9139a
  edit-comment: ce8b431d612673b0
  params-8: 9d2a76554e16150f
  example-10: 5ec1a5dcecd98f46
  soft-delete-comment: e241354e295ae526
  example-11: e408906f906f24e4
  create-poll: 6387b4f1d0e86458
  params-9: 16f9715ca4b3ff2c
  example-12: 6d417ca6a02c1116
  show-poll: 01b030bedff62047
  example-13: 36ba1c6024f34ad3
  list-polls: d4da6950f4e283dd
  params-10: 6672105df260ffae
  example-14: ffa11a2884c77b66
  edit-poll: 15364df6e0bfc108
  params-11: a16bd08f2bb93a69
  example-15: eb7bd24917af90aa
  soft-delete-poll: 310b781d7fbe32e8
  example-16: 6ffbc3adebc92c94
  list-memberships: a71b67a689165b85
  params-12: 051c5900ac55ad7b
  example-17: f5e92b48a90d58c5
  manage-memberships: f8beda20b3d0d5ce
  params-13: de1dad57e5b298cd
  example-18: 43bdc7aa2e3a2c11
title_source: c23fb6526b722360
title_generated: 69e07cde5ab8d5b0
---

<!-- translation-section: introduction -->

# Dokumentation der Loomio-Benutzer-API

<!-- seo-description: Mit der Loomio-Benutzer-API kannst du Diskussionen, Kommentare, Abstimmungen, Threads und Gruppenmitgliedschaften aus anderer Software heraus erstellen und verwalten. -->

`/api/b2` ist die API für Integrationen, die im Namen eines Loomio-Benutzerkontos handeln. Sie verwendet dessen API-Schlüssel. Jede Aktion wird als dieser Benutzer ausgeführt.

Für Aktionen in Gruppen gelten die Mitgliedschaften und Gruppenberechtigungen des Benutzers, dessen API-Schlüssel verwendet wird. Administratorrechte für die Instanz erweitern den Zugriff des API-Schlüssels auf Gruppen oder Inhalte nicht. Verwende für die Verwaltung der Instanz die Server-API.

Verwende den API-Schlüssel des Loomio-Benutzerkontos, das die Aktionen ausführen soll. Ein eigenes Bot-Konto ist sinnvoll, wenn die Integration keine Einladungen zu Abstimmungen oder Benachrichtigungen erhalten soll.

Angemeldete Benutzer finden ihren API-Schlüssel und ihre Gruppen-IDs auf der [Seite für den API-Zugriff](/profile/api_access).

Sende den API-Schlüssel im Header `Authorization: Bearer`. API-Schlüssel in URL-Abfrageparametern werden abgewiesen, da URLs von Proxys und in Zugriffsprotokollen gespeichert werden können.

<!-- translation-section: authentication-change -->

### Änderung bei der Authentifizierung

Früher wurde der API-Schlüssel als URL-Parameter `api_key` akzeptiert. Anfragen mit `?api_key=YOUR_API_KEY` funktionieren nicht mehr. Verwende stattdessen den HTTP-Header `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Die Beispiele verwenden `YOUR_API_KEY`, die Gruppen-ID `123` und `https://www.loomio.com/`. Ersetze sie durch deinen API-Schlüssel, deine Gruppen-ID und die URL deiner Loomio-Installation.

<!-- translation-section: response-size-and-related-records -->

## Größe der Antworten und verknüpfte Datensätze

Antworten der Benutzer-API haben ein zusammengesetztes Format: Neben den angeforderten Datensätzen enthalten sie verknüpfte Datensätze wie Topics, Gruppen, Benutzer, Abstimmungen und Reaktionen. So kann ein Client seinen lokalen Datenspeicher mit einer einzigen Anfrage füllen. Die Antwort kann dadurch aber mehr Daten enthalten, als eine einfache Integration benötigt.

Mit `compact=1` lässt du umfangreiche verknüpfte Topics, Gruppen, übergeordnete Gruppen, Mitgliedschaften, Reaktionen, Schlagwörter und Übersetzungen weg. Die angeforderten Datensätze und die zum Verständnis ihrer Inhalte benötigten verknüpften Datensätze bleiben erhalten.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Mit `exclude_types` kannst du gezielt Datensatztypen ausschließen. Gib dazu die Typen im Singular durch Leerzeichen getrennt an. Beispielsweise lässt `exclude_types=group reaction` verknüpfte Gruppen und Reaktionen weg. Häufige Werte sind `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` und `topic_item`. Der Ausschluss betrifft verknüpfte Datensätze, nicht die vom Endpunkt angeforderte Hauptressource.

Antworten auf Sammlungsanfragen enthalten `meta.total`, wenn eine genaue Anzahl definiert ist. Die Anzahl wird vor der Anwendung von `limit` und `offset` berechnet. Endpunkte wie die Suche, die ihre Ergebnismenge bewusst begrenzen, lassen `meta.total` weg, statt `null` zurückzugeben.

<!-- translation-section: endpoint-summary -->

## Übersicht der Endpunkte

| Methode | Endpunkt | Zweck |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Gruppen des API-Schlüssel-Benutzers auflisten |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Eine sichtbare Gruppe abrufen |
| `GET` | `/api/b2/reports` | Einen Beteiligungsbericht erstellen |
| `GET` | `/api/b2/search` | Sichtbare Diskussionen, Kommentare, Abstimmungen, Stimmen und Fazits durchsuchen |
| `POST` | `/api/b2/discussions` | Eine Diskussion erstellen |
| `GET` | `/api/b2/discussions/:id` | Eine Diskussion abrufen |
| `GET` | `/api/b2/discussions` | Diskussionen in einer Gruppe auflisten |
| `PATCH` | `/api/b2/discussions/:id` | Eine Diskussion bearbeiten |
| `DELETE` | `/api/b2/discussions/:id` | Eine Diskussion vorläufig löschen |
| `GET` | `/api/b2/threads` | Sichtbare Threads von Diskussionen und eigenständigen Abstimmungen auflisten |
| `GET` | `/api/b2/threads/:topic_id` | Einen Thread abrufen |
| `GET` | `/api/b2/threads/:topic_id/items` | Die Einträge eines Threads in ihrer Reihenfolge abrufen |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Einen vollständigen Thread als Markdown abrufen |
| `POST` | `/api/b2/comments` | Einen Kommentar oder eine Antwort erstellen |
| `PATCH` | `/api/b2/comments/:id` | Einen Kommentar bearbeiten |
| `DELETE` | `/api/b2/comments/:id` | Einen Kommentar vorläufig löschen |
| `POST` | `/api/b2/polls` | Eine Abstimmung erstellen |
| `GET` | `/api/b2/polls/:id` | Eine Abstimmung abrufen |
| `GET` | `/api/b2/polls` | Abstimmungen in einer Gruppe auflisten |
| `PATCH` | `/api/b2/polls/:id` | Eine Abstimmung bearbeiten |
| `DELETE` | `/api/b2/polls/:id` | Eine Abstimmung vorläufig löschen |
| `GET` | `/api/b2/memberships` | Mitgliedschaften einer Gruppe auflisten |
| `POST` | `/api/b2/memberships` | Mitglieder hinzufügen und optional nicht aufgeführte Mitglieder entfernen |
| `GET` | `/api/b2/chatbots` | Chat-Integrationen und Webhooks einer Gruppe auflisten |
| `POST` | `/api/b2/chatbots` | Eine Chat-Integration oder einen Webhook erstellen |
| `PATCH` | `/api/b2/chatbots/:id` | Eine Chat-Integration oder einen Webhook aktualisieren |
| `DELETE` | `/api/b2/chatbots/:id` | Eine Chat-Integration oder einen Webhook löschen |
| `POST` | `/api/b2/chatbots/check` | Eine Testnachricht zur Prüfung der Webhook-Verbindung senden |

<!-- translation-section: groups -->

## Gruppen

<!-- translation-section: list-groups -->

### Gruppen auflisten

Ruft die Gruppen ab, in denen der API-Schlüssel-Benutzer eine aktive Mitgliedschaft hat.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Die Antwort enthält alle passenden Datensätze in einem `groups`-Array ohne Paginierung. Dazu gehören übergeordnete Gruppen und Untergruppen, auch wenn deren Abonnement derzeit nicht aktiv ist. Prüfe das Feld `enabled`, wenn eine Integration nur für aktivierte Gruppen arbeiten soll.

Wichtige Gruppenfelder sind:

| Feld | Beschreibung |
| --- | --- |
| `id` | Numerische Gruppen-ID, die andere Endpunkte der Benutzer-API verwenden |
| `key` | Beständiger Kurzschlüssel für Loomio-URLs |
| `handle` | Lesbare Kennung der Gruppe |
| `name` | Gruppenname |
| `full_name` | Gruppenname mit dem Kontext der übergeordneten Gruppe |
| `parent_id` | Numerische ID der übergeordneten Gruppe bei einer Untergruppe, sonst `null` |
| `enabled` | Gibt an, ob die Gruppe und ihr Abonnement aktiv sind |
| `memberships_count` | Anzahl aktiver und ausstehender Mitgliedschaften |
| `accepted_memberships_count` | Anzahl angenommener Mitgliedschaften |
| `pending_memberships_count` | Anzahl ausstehender Einladungen |
| `admin_memberships_count` | Anzahl der Gruppenadministratoren |
| `delegates_count` | Anzahl der Delegierten |
| `discussions_count` | Anzahl der Diskussionen direkt in der Gruppe |
| `polls_count` | Anzahl der Abstimmungen direkt in der Gruppe |
| `subgroups_count` | Anzahl der Untergruppen |

Die Antwort kann weitere Gruppeneinstellungen, verknüpfte Datensätze übergeordneter Gruppen und die Mitgliedschaften des API-Benutzers enthalten. Clients sollten Felder ignorieren, die sie nicht verwenden.

<!-- translation-section: get-a-group -->

### Eine Gruppe abrufen

Ruft eine Gruppe ab, die für den API-Schlüssel-Benutzer sichtbar ist.

`GET /api/b2/groups/:id_or_key_or_handle`

Als Kennung kannst du die numerische ID, den Schlüssel oder die lesbare Kennung der Gruppe verwenden.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Die Antwort enthält die Gruppe im `groups`-Array und verwendet dieselben Felder wie der Endpunkt zum Auflisten. Wenn der API-Schlüssel-Benutzer keinen Zugriff auf die Gruppe hat, wird ein Berechtigungsfehler zurückgegeben.

<!-- translation-section: webhooks -->

## Webhooks

Die Benutzer-API arbeitet mit Anfragen: Eine Integration ruft Loomio auf, wenn sie Daten lesen oder ändern möchte. Ein Gruppen-Webhook übermittelt Ereignisse in die andere Richtung. Loomio sendet ausgewählte Gruppenereignisse an deinen Endpunkt, sobald sie eintreten. Die Integration muss die REST-API daher nicht regelmäßig auf Änderungen abfragen.

Webhooks werden für jede Gruppe einzeln eingerichtet. Dafür sind Administratorrechte in der Gruppe erforderlich. Du kannst sie über die Loomio-Oberfläche verwalten:

1. Öffne die Gruppe.
2. Öffne das Gruppenmenü und wähle **Chat-Integrationen**.
3. Füge die Integration hinzu, deren Nutzdatenformat dein Endpunkt unterstützt. Verwende für einen allgemeinen Endpunkt das Format Mattermost/Markdown.
4. Gib einen Namen und die Ziel-URL ein.
5. Wähle die Ereignisse aus, die Loomio automatisch senden soll.
6. Speichere die Integration und sende mit **Testverbindung** eine Testnachricht.

Verwende ein HTTPS-Ziel mit einer nicht erratbaren URL. Loomio verlangt, dass das Ziel zu einer öffentlichen Adresse aufgelöst wird, und blockiert Anfragen an lokale oder private Netzwerkadressen.

Agenten und andere Integrationen können Webhooks auch über die unten beschriebenen Chatbot-Endpunkte mit Bearer-Authentifizierung verwalten. Die Ressource heißt aus Kompatibilitätsgründen mit Loomios Chat-Integrationen `chatbots`, steht aber auch für allgemeine ausgehende Webhooks.

<!-- translation-section: list-webhooks -->

### Webhooks auflisten

Ruft die für eine Gruppe eingerichteten Chat-Integrationen ab. Der API-Schlüssel-Benutzer muss Administrator dieser Gruppe sein. Die Antwort enthält Ziel-URLs und darf daher gewöhnlichen Gruppenmitgliedern nicht zugänglich gemacht werden.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Die Antwort enthält ein `chatbots`-Array mit diesen Feldern:

| Feld | Beschreibung |
| --- | --- |
| `id` | Integrations-ID für Aktualisierungen und zum Löschen |
| `group_id` | Gruppe, aus der die Ereignisse stammen |
| `name` | Name der Integration für die Verwaltung |
| `kind` | `webhook` für einen ausgehenden Webhook oder `matrix` für eine Matrix-Integration |
| `webhook_kind` | Nutzdatenformat: `markdown`, `slack`, `discord`, `microsoft` oder `webex` |
| `server` | Ziel-URL |
| `event_kinds` | Automatisch gesendete Ereignisse |
| `notification_only` | Gibt an, ob Nachrichten nur die Überschrift der Benachrichtigung enthalten |

<!-- translation-section: create-a-webhook -->

### Webhook erstellen

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

Der Benutzer des API-Schlüssels muss Administrator der Gruppe `group_id` sein. Vor dem Speichern wird geprüft, ob die Ziel-URL öffentlich erreichbar ist.

<!-- translation-section: update-a-webhook -->

### Webhook aktualisieren

`PATCH /api/b2/chatbots/:id`

Sende die Felder, die geändert werden sollen. Durch Ändern von `group_id` kannst du den Webhook nicht einer anderen Gruppe zuordnen.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Webhook-Ziel testen

Sende vor oder nach dem Speichern der Konfiguration eine Markdown-kompatible Testnachricht an das Ziel.

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

Wenn du die Konfiguration löschst, werden keine weiteren Ereignisse zugestellt. Inhalte der Loomio-Gruppe bleiben erhalten.

<!-- translation-section: event-types -->

### Ereignistypen

Ein Webhook kann diese Ereignistypen abonnieren:

| Ereignis | Zeitpunkt des Versands |
| --- | --- |
| `new_discussion` | Eine Diskussion wird gestartet |
| `discussion_edited` | Eine Diskussion wird bearbeitet |
| `new_comment` | Ein Kommentar wird erstellt |
| `poll_created` | Eine Abstimmung wird gestartet |
| `poll_edited` | Eine Abstimmung wird bearbeitet |
| `poll_closing_soon` | Der Schließzeitpunkt einer Abstimmung rückt näher |
| `poll_expired` | Eine Abstimmung erreicht ihren Schließzeitpunkt |
| `poll_closed_by_user` | Eine Person schließt eine Abstimmung manuell |
| `poll_reopened` | Eine Abstimmung wird wieder geöffnet |
| `outcome_created` | Ein Fazit wird veröffentlicht |
| `outcome_updated` | Ein Fazit wird aktualisiert |
| `outcome_review_due` | Die Überprüfung eines Fazits wird fällig |
| `stance_created` | Eine Stimme wird abgegeben |
| `stance_updated` | Eine Stimme wird geändert |

Der Webhook gehört zu einer Gruppe und empfängt deren abonnierte Ereignisse. Personen können die Integration beim Teilen oder Senden bestimmter Benachrichtigungen auch ausdrücklich auswählen, selbst wenn das entsprechende automatische Ereignis nicht ausgewählt ist.

<!-- translation-section: http-delivery -->

### HTTP-Zustellung

Loomio sendet asynchron einen HTTP-`POST` an die konfigurierte URL mit diesem Header:

```text
Content-Type: application/json; charset=utf-8
```

Die Zeitüberschreitung für die Anfrage beträgt fünf Sekunden. Eine `2xx`-Antwort, einschließlich `204 No Content`, gilt als erfolgreich. Webhook-Empfänger sollten zügig antworten, längere Aufgaben asynchron verarbeiten und doppelte oder in anderer Reihenfolge eintreffende Zustellungen berücksichtigen.

Loomio fügt derzeit weder eine Webhook-Signatur noch einen Header mit einem gemeinsamen Geheimnis, eine Ereignis-ID oder eine Zustellungs-ID hinzu. Behandle die vollständige Ziel-URL wie einen Zugangsschlüssel und veröffentliche sie nicht. Wenn der empfangende Dienst es unterstützt, füge der URL ein nicht erratbares Token hinzu. Wenn du ein stabiles maschinenlesbares Ereignisschema oder signierte Zustellungen benötigst, nutze den Webhook als Änderungsbenachrichtigung und rufe die aktuellen Datensätze über die authentifizierte Benutzer-API ab.

<!-- translation-section: payload-formats -->

### Nutzdatenformate

Webhook-Nutzdaten sind für Chat-Dienste aufbereitete Nachrichten. Sie enthalten keine vollständigen serialisierten Loomio-Datensätze. Links in der Nachricht verweisen auf die betroffenen Loomio-Inhalte. Wenn eine Integration den aktuellen Stand als strukturierte Daten benötigt, kann sie ihn über die Benutzer-API abrufen.

| Integrationsformat | Wichtigste JSON-Felder |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, begrenzt auf etwa 1.900 Zeichen |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Das allgemeine Markdown-Format sendet beispielsweise einen Inhalt in dieser Form:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Der genaue Nachrichtentext hängt vom Ereignis, der Spracheinstellung der Gruppe, der Einstellung für reine Benachrichtigungen und der Loomio-Version ab. Empfänger sollten sich auf die dokumentierten Felder der obersten Ebene des gewählten Formats stützen, statt den Wortlaut der Sätze auszuwerten.

<!-- translation-section: search -->

## Suche

Suche nach Diskussionen, Kommentaren, Abstimmungen, Stimmen und Fazits, die für den Benutzer des API-Schlüssels sichtbar sind. Die Ergebnisse enthalten auch öffentliche Inhalte aus Gruppen, denen der Benutzer nicht angehört. Für private Inhalte gelten die üblichen Sichtbarkeitsregeln für Themen.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `query` | Suchtext. Exakte und ungefähre Treffer werden unterstützt |
| `group_id` | Ergebnisse auf eine sichtbare Gruppe beschränken |
| `org_id` | Ergebnisse auf eine sichtbare übergeordnete Gruppe und deren sichtbare Untergruppen beschränken. Verwende `0` für direkte Diskussionen |
| `type` | Ergebnisse auf einen Typ beschränken: `Discussion`, `Comment`, `Poll`, `Stance` oder `Outcome` |
| `types` | Durch Kommas getrennte Liste von Ergebnistypen |
| `tag` | Ergebnisse auf Themen mit diesem Schlagwort beschränken |
| `author_id` | Ergebnisse auf Inhalte einer Person beschränken. Ohne `query` wird die jüngste sichtbare Aktivität dieser Person zurückgegeben |
| `order` | Auf `authored_at_desc` setzen, um passende Inhalte nach Erstellungszeitpunkt zu sortieren |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Die Antwort enthält ein `search_results`-Array. Jedes Ergebnis kennzeichnet den gefundenen Datensatz und seinen sichtbaren Kontext. Dazu gehören die Felder `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` und `tags`. Felder, die für ein Ergebnis nicht gelten, haben den Wert `null`.

<!-- translation-section: participation-report -->

## Bericht zur Beteiligung

Gibt dieselben zusammengefassten Beteiligungsdaten zurück, die Loomio im Bericht zur Beteiligung verwendet.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `section` | Berichtsabschnitt: `base`, `users` oder `countries`. Verwende `users` für die Aktivität einzelner Personen |
| `group_scope` | `custom` oder `my`. Der bisherige Wert `all` wird wie `my` behandelt, da Schlüssel der Benutzer-API keinen instanzweiten Zugriff gewähren |
| `group_ids` | Durch Kommas getrennte Gruppen-IDs bei `group_scope=custom`. IDs von Gruppen, in denen der API-Benutzer kein Mitglied ist, werden ignoriert |
| `start_month` | Erster berücksichtigter Monat im Format `YYYY-MM`; standardmäßig vor 12 Monaten |
| `end_month` | Letzter berücksichtigter Monat im Format `YYYY-MM`; standardmäßig der aktuelle Monat |
| `interval` | Intervall für den Abschnitt `base`: `day`, `week`, `month` oder `year` |
| `member_type` | Mit `section=users` auf `delegate` setzen, um nur aktuelle Delegierte zurückzugeben |

Eine Person gilt als delegiert, wenn sie in mindestens einer ausgewählten Gruppe eine aktive Mitgliedschaft als Delegierte hat. Ihre Zahlen werden über alle ausgewählten Gruppen zusammengefasst. Zeilen für Delegierte werden auch dann zurückgegeben, wenn alle Aktivitätszahlen null sind. Die Zahlen umfassen Threads, Kommentare, Abstimmungen, Stimmen, Fazits und Reaktionen. Sie sind keine Quoten für die Teilnahme an Abstimmungen. Benutzerzeilen enthalten außerdem die Zahlen der für identifizierte Personen ausgegebenen, abgegebenen und nicht abgegebenen Stimmzettel. Anonyme Abstimmungen sind von allen personenbezogenen Stimmzahlen ausgenommen. `all_votes_cast` ist nur dann wahr, wenn mindestens ein Stimmzettel ausgegeben und jeder ausgegebene Stimmzettel abgegeben wurde.

Die API wendet dieselben Regeln für die Sichtbarkeit von Gruppen an wie der Bericht in Loomio. Ein Schlüssel der Benutzer-API kann keine Berichtsdaten aus Gruppen offenlegen, auf die sein Benutzer keinen Zugriff hat.

<!-- translation-section: example -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Das `users`-Array enthält vollständige Zeilen mit Aktivitätsdaten:

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

Erstelle eine Diskussion mit dem Benutzerkonto, zu dem der API-Schlüssel gehört.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Gruppe, in der der Thread erstellt wird |
| `title` | Titel des Threads, erforderlich |
| `description` | Kontext für den Thread, optional |
| `description_format` | `md` oder `html`, optional, Standardwert `md` |
| `recipient_audience` | `group` oder null. Bei `group` wird die gesamte Gruppe über den neuen Thread benachrichtigt |
| `recipient_user_ids` | Array mit Benutzer-IDs von Personen, die benachrichtigt oder zum Thread eingeladen werden sollen |
| `recipient_emails` | Array mit E-Mail-Adressen von Personen, die zum Thread eingeladen werden sollen |
| `recipient_message` | Nachricht für die Einladung per E-Mail |

<!-- translation-section: example-2 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Diskussion abrufen

Rufe eine Diskussion über ihre numerische ID oder ihren Schlüssel als Zeichenfolge ab.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Diskussionen auflisten

Liste die Diskussionen einer Gruppe auf, die für den Benutzer mit dem API-Schlüssel sichtbar sind. In einer öffentlich sichtbaren Gruppe können auch Personen ohne Mitgliedschaft die öffentlichen Diskussionen auflisten. Private Diskussionen bleiben auf Personen beschränkt, die sie in Loomio lesen dürfen.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Diskussionen aufgelistet werden sollen |
| `status` | Zeichenfolge, optional, Standardwert `open`. Werte: `open`, `closed`, `all` |
| `limit` | Ganzzahl, optional, Standardwert 50. Seitengröße |
| `offset` | Ganzzahl, optional, Standardwert 0. Versatz für die Seitennummerierung |

Aus Kompatibilitätsgründen werden `per` und `from` weiterhin als alternative Namen für `limit` und `offset` akzeptiert.

<!-- translation-section: example-4 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Threads auflisten

Liste die für den Benutzer mit dem API-Schlüssel sichtbaren Diskussions- und Abstimmungs-Threads auf, sortiert nach der letzten Aktivität. Die ID eines Threads ist seine `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `limit` | Ganzzahl, optional, Standardwert 50. Seitengröße |
| `offset` | Ganzzahl, optional, Standardwert 0. Versatz für die Seitennummerierung |

<!-- translation-section: example-5 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Thread lesen

Lies einen Thread, seine chronologisch geordneten Ereignisse oder sein vollständiges sichtbares Markdown-Dokument.

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

Der Endpunkt `items` gibt die Ereignisse in ihrer Reihenfolge zurück, einschließlich sichtbarer Kommentare, Abstimmungen, Stimmen und Fazits. Der Endpunkt `markdown` gibt den vollständigen sichtbaren Thread als ein Markdown-Dokument zurück. Begründungen für Stimmen sind nur enthalten, wenn sie für den Benutzer mit dem API-Schlüssel sichtbar sind.

Für alle Thread-Endpunkte gelten dieselben Berechtigungen wie in der Loomio-Oberfläche. Der API-Schlüssel gewährt keinen Zugriff auf einen Thread, den der Benutzer normalerweise nicht öffnen kann.

<!-- translation-section: edit-discussion -->

## Diskussion bearbeiten

Bearbeite eine Diskussion mit dem Benutzerkonto, zu dem der API-Schlüssel gehört. Es gelten dieselben Berechtigungen wie in Loomio: Der Benutzer muss diese Diskussion bearbeiten dürfen.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `title` | Neuer Titel |
| `description` | Neuer Kontext |
| `description_format` | `md` oder `html`, optional, Standardwert `md` |
| `recipient_audience` | `group` oder null. Bei `group` wird die gesamte Gruppe über die Bearbeitung benachrichtigt |
| `recipient_user_ids` | Array mit Benutzer-IDs von Personen, die benachrichtigt oder zum Thread eingeladen werden sollen |
| `recipient_emails` | Array mit E-Mail-Adressen von Personen, die zum Thread eingeladen werden sollen |
| `recipient_message` | Nachricht für die Einladung per E-Mail |

<!-- translation-section: example-7 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Diskussion vorläufig löschen

Lösche eine Diskussion mit dem Benutzerkonto, zu dem der API-Schlüssel gehört, vorläufig. Die Diskussion wird verworfen, ihr Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Kommentar erstellen

Erstelle mit dem Benutzerkonto, zu dem der API-Schlüssel gehört, einen Kommentar in einer Diskussion.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `discussion_id` | Ganzzahl, erforderlich. ID der Diskussion, die kommentiert werden soll |
| `body` | Kommentartext, erforderlich, sofern kein Anhang angegeben wird |
| `body_format` | `md` oder `html`, optional, Standardwert `md` |

<!-- translation-section: example-9 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Kommentar bearbeiten

Bearbeite einen Kommentar mit dem Benutzerkonto, zu dem der API-Schlüssel gehört. Es gelten dieselben Berechtigungen wie in Loomio: Der Benutzer muss diesen Kommentar bearbeiten dürfen.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `body` | Neuer Kommentartext |
| `body_format` | `md` oder `html`, optional, Standardwert `md` |

<!-- translation-section: example-10 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Kommentar vorläufig löschen

Lösche einen Kommentar mit dem Benutzerkonto, zu dem der API-Schlüssel gehört, vorläufig. Der Kommentar wird verworfen und sein Text ausgeblendet, sein Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Umfrage erstellen

Erstelle eine Umfrage mit dem Benutzerkonto, zu dem der API-Schlüssel gehört.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, optional, Standardwert null. ID der Gruppe für die Umfrage. Wenn `discussion_id` angegeben ist, wird `group_id` ignoriert |
| `discussion_id` | Ganzzahl, optional, Standardwert null. ID der Diskussion, zu der diese Umfrage hinzugefügt wird |
| `title` | Zeichenfolge, erforderlich. Titel der Umfrage |
| `poll_type` | Zeichenfolge, erforderlich. Werte: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Zeichenfolge, optional. Beschreibung der Umfrage |
| `details_format` | Zeichenfolge, optional, Standardwert `md`. Werte: `md` oder `html` |
| `options` | Array von Zeichenfolgen. Bei `poll_type` `proposal` sind `agree`, `disagree`, `abstain` und `block` gültig. Bei `poll_type` `meeting` gib Datums- oder Datumszeitangaben im ISO-8601-Format an. Für alle anderen Umfragetypen ist jede Zeichenfolge gültig |
| `closing_at` | Zeichenfolge im ISO-8601-Format oder null, Standardwert null. Beispiel: `2026-09-01T12:00:00Z`. Bei null ist die Stimmabgabe deaktiviert und die Umfrage gilt als Entwurf |
| `specified_voters_only` | Boolescher Wert, optional, Standardwert false. Bei true können nur die angegebenen Personen abstimmen. Bei false werden alle Gruppenmitglieder zur Abstimmung eingeladen |
| `hide_results` | Zeichenfolge, optional, Standardwert `off`. Werte: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Boolescher Wert, Standardwert false. Zeigt den Abstimmenden die Optionen in zufälliger Reihenfolge an |
| `anonymous` | Boolescher Wert, optional, Standardwert false. Verbirgt die Identität der Abstimmenden |
| `recipient_audience` | `group` oder null, optional, Standardwert null. Bei `group` wird die gesamte Gruppe benachrichtigt |
| `notify_on_closing_soon` | Zeichenfolge, optional, Standardwert `nobody`. Werte: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array von Benutzer-IDs der Personen, die benachrichtigt oder eingeladen werden sollen |
| `recipient_emails` | Array von E-Mail-Adressen der Personen, die zur Abstimmung eingeladen werden sollen |
| `recipient_message` | Nachricht für die Einladung per E-Mail |
| `notify_recipients` | Boolescher Wert, Standardwert false. Bei false werden Personen ohne Benachrichtigung hinzugefügt. Bei true erhalten alle mit dieser Anfrage eingeladenen Personen eine Benachrichtigung per E-Mail |

<!-- translation-section: example-12 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Umfrage abrufen

Rufe eine Umfrage über ihre numerische ID oder ihren Schlüssel als Zeichenfolge ab.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Umfragen auflisten

Liste die Umfragen einer Gruppe auf, die für die Person mit dem API-Schlüssel sichtbar sind. In einer öffentlich sichtbaren Gruppe können auch Personen ohne Mitgliedschaft öffentliche Umfragen auflisten. Private Umfragen sind nur für Personen sichtbar, die sie in Loomio lesen dürfen. Die Antwort enthält das aktuelle Fazit jeder sichtbaren Umfrage. Mit `status=closed` kannst du daher Vorschläge mit einem Fazit auflisten.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Umfragen aufgelistet werden sollen |
| `status` | Zeichenfolge, optional, Standardwert `active`. Werte: `active`, `closed`, `all` |
| `limit` | Ganzzahl, optional, Standardwert 50. Seitengröße |
| `offset` | Ganzzahl, optional, Standardwert 0. Versatz für die Seitennummerierung |

Aus Kompatibilitätsgründen werden `per` und `from` weiterhin als alternative Namen für `limit` und `offset` akzeptiert.

<!-- translation-section: example-14 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Umfrage bearbeiten

Bearbeite eine Umfrage mit dem Benutzerkonto, zu dem der API-Schlüssel gehört. Es gelten dieselben Berechtigungen wie in Loomio: Die Person muss diese Umfrage bearbeiten dürfen.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `title` | Aktualisierter Titel |
| `details` | Aktualisierte Beschreibung der Umfrage |
| `details_format` | `md` oder `html`, optional, Standardwert `md` |
| `options` | Aktualisierte Optionsnamen. Je nach Status der Umfrage kann eine Änderung der Optionen bestehende Stimmen beeinflussen |
| `closing_at` | Zeichenfolge im ISO-8601-Format oder null |
| `recipient_audience` | `group` oder null. Bei `group` wird die gesamte Gruppe benachrichtigt |
| `recipient_user_ids` | Array von Benutzer-IDs der Personen, die benachrichtigt oder eingeladen werden sollen |
| `recipient_emails` | Array von E-Mail-Adressen der Personen, die zur Abstimmung eingeladen werden sollen |
| `recipient_message` | Nachricht für die Einladung per E-Mail |

<!-- translation-section: example-15 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Umfrage vorläufig löschen

Lösche eine Umfrage vorläufig mit dem Benutzerkonto, zu dem der API-Schlüssel gehört. Die Umfrage wird verworfen, ihr Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Mitgliedschaften auflisten

Liste die Mitgliedschaften auf, die für die Person mit dem API-Schlüssel sichtbar sind. Gruppenmitglieder können Namen, IDs, Titel und Rollen der Mitglieder lesen. E-Mail-Adressen werden nur für das eigene Konto oder für Gruppenadministratoren angezeigt.

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

Sende eine Liste von E-Mail-Adressen. Neue Adressen auf der Liste erhalten eine Einladung zur Gruppe. Anders als beim Auflisten von Mitgliedschaften benötigst du für diese Aktion Gruppenadministratorrechte.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Mitgliedschaften verwaltet werden sollen |
| `emails` | Array von Zeichenfolgen, erforderlich. E-Mail-Adressen der Personen, die zur Gruppe eingeladen werden sollen |
| `remove_absent` | Boolescher Wert. Bei true werden alle Personen aus der Gruppe entfernt, deren E-Mail-Adresse nicht in der Liste steht |

<!-- translation-section: example-18 -->

### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Wenn du `remove_absent=1` angibst, werden alle Gruppenmitglieder entfernt, die nicht auf der Liste stehen. Achte darauf, dass du damit alle Mitglieder deiner Gruppe entfernen könntest.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Die Antwort ist ein Objekt mit `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
