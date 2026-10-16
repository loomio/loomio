---
title: Benutzer-API
source_revision: 28ecc59f68d407f76f08133bfa0172aadbb53065
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-15'
sections:
  introduction: b6e6ec7463276869
  response-size-and-related-records: 298da635bf97dadd
  endpoint-summary: 258f7560def524ec
  groups: 0473f1f7fb78f074
  list-groups: 01de10c378eeba37
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: 6093df92815f7156
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
  create-discussion: 958fc684640462a9
  params-3: 657d582c89333097
  example-2: 57681d83fffe9515
  show-discussion: 40102aeffe4f1286
  example-3: c0ebd013a1b7fbd2
  list-discussions: '09ff7f0d3a937b41'
  params-4: dcebc294fbb9d837
  example-4: ffda1a4726380e2f
  list-threads: '09f7bd670e581400'
  params-5: 79b1cefac558effc
  example-5: a40ae2317faab46d
  read-thread: ac36d1b81c1eeed4
  example-6: 8c582a286e04ca75
  edit-discussion: 918161e7aa8f4aa6
  params-6: b819796d34354623
  example-7: 552295f78d3490af
  soft-delete-discussion: c8ffe951171e6f07
  example-8: 965c5761f34f9920
  create-comment: f95f56b81c8f22b5
  params-7: 5ad8ede0919c5f47
  example-9: 70ee3750f1543e9b
  edit-comment: 80322da74162d58f
  params-8: 288331c60f3c9b28
  example-10: ec89de8cc86b6fc8
  soft-delete-comment: 04baf86923c7e8f1
  example-11: f3675b780da755cd
  create-poll: cf62e787784a5e87
  params-9: df1611a9dedef2d8
  example-12: fa7410dd3a0a385f
  show-poll: d759508986aab08c
  example-13: 2867289a6c2beb9d
  list-polls: 56e5ed4ae45e5428
  params-10: e68e8cf62b21488d
  example-14: 40958a09c058d4cc
  edit-poll: 65467ad0b431ddbf
  params-11: 77f118397592bc05
  example-15: e56befa0f2ae3360
  soft-delete-poll: 61cf76310e08d7ff
  example-16: afbf95df96734a4d
  list-memberships: 5fab06bb8ecf1fd0
  params-12: decaff0790566fb0
  example-17: 5d92092b70ce545a
  manage-memberships: 802d39c06674d395
  params-13: 771b5338a4ba3d0b
  example-18: a50b01823a6935a0
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
generated:
  introduction: f778fae02fa4331f
  response-size-and-related-records: 1faa00e782012554
  endpoint-summary: 4e12def60a852379
  groups: db87cc751307f655
  list-groups: 9c8f1f3a6717f911
  get-a-group: 1ee0b0e16e7d2e33
  webhooks: ee96993caa26dc11
  list-webhooks: b76d61488a3e2224
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
  create-discussion: 8c4d11a06e4b6500
  params-3: 42034bd38d61b10c
  example-2: 40b4bba0b39c4da2
  show-discussion: d81c7badd2cfd295
  example-3: ee3d6fc8a6a763a4
  list-discussions: 2dc28c7b1363098e
  params-4: edfe5f2ac0ae52fd
  example-4: 07c583377dcb7143
  list-threads: d91fa1f1016bbb4d
  params-5: 3e73ec224f20d3be
  example-5: 45356225cb8c868a
  read-thread: 92e0154afe08d618
  example-6: d465fc2dc217909c
  edit-discussion: ab307e85dc546160
  params-6: 5395f007d6c5c31d
  example-7: 5ddd7b4a0c7a8021
  soft-delete-discussion: 1395088b4d0c72bc
  example-8: e66fd0ef75c44e1d
  create-comment: 1d85e52ffa11bfac
  params-7: 1c554ea1fd8e07da
  example-9: af2cc5126a8b898d
  edit-comment: e5ebb0524365193c
  params-8: e6a929f21fda4dd5
  example-10: 47dabfcaaedc73fc
  soft-delete-comment: 4a839408c151246d
  example-11: ac19659a36ed59ff
  create-poll: beb33dd0fa8d7dee
  params-9: 4573a6be98a7860a
  example-12: 9b40f6504100469b
  show-poll: 0a25a5fa3bf3e57b
  example-13: 18de5a8970c7fd46
  list-polls: adf58d3a44dcc080
  params-10: 3fb1ec0ee2ec56b6
  example-14: 3eb9fd2941628565
  edit-poll: a3cd2d0261b007b7
  params-11: 388a43e6d193b71a
  example-15: d9e8739876751125
  soft-delete-poll: a8dea565392fdf20
  example-16: 47fe424c51ef5da4
  list-memberships: 5376683ff86ffe2c
  params-12: 394843efd56209cd
  example-17: a8ab835936a1affc
  manage-memberships: 4b0e4aaf9d7860fd
  params-13: ec38db03fcff899e
  example-18: 3a8cb60c8bfb0cc0
  pagination: 37b08f9679e9d664
  comments: 7c7d401f44657acf
  discussions: 0d7c8f60574c2577
  memberships: 792334797baa1f3d
  polls: 5c9a90865f265253
  threads: 19bc02fc1c26317b
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

```text
Authorization: Bearer YOUR_API_KEY
```

Die Beispiele verwenden `YOUR_API_KEY`, die Gruppen-ID `123` und `https://www.loomio.com/`. Ersetze diese durch deinen API-Schlüssel, deine Gruppen-ID und die URL deiner Loomio-Installation.

<!-- translation-section: endpoint-summary -->

## Übersicht der Endpunkte

| Methode | Endpunkt | Zweck |
| --- | --- | --- |
| `POST` | `/api/b2/comments` | Einen Kommentar oder eine Antwort erstellen |
| `PATCH` | `/api/b2/comments/:id` | Einen Kommentar bearbeiten |
| `DELETE` | `/api/b2/comments/:id` | Einen Kommentar als gelöscht markieren |
| `POST` | `/api/b2/discussions` | Eine Diskussion erstellen |
| `GET` | `/api/b2/discussions/:id` | Eine Diskussion abrufen |
| `GET` | `/api/b2/discussions` | Diskussionen in einer Gruppe auflisten |
| `PATCH` | `/api/b2/discussions/:id` | Eine Diskussion bearbeiten |
| `DELETE` | `/api/b2/discussions/:id` | Eine Diskussion als gelöscht markieren |
| `GET` | `/api/b2/groups` | Gruppen des Kontos auflisten, dessen API-Schlüssel verwendet wird |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Eine sichtbare Gruppe abrufen |
| `GET` | `/api/b2/memberships` | Mitgliedschaften einer Gruppe auflisten |
| `POST` | `/api/b2/memberships` | Mitglieder hinzufügen und optional nicht aufgeführte Mitglieder entfernen |
| `GET` | `/api/b2/reports` | Einen Beteiligungsbericht erstellen |
| `POST` | `/api/b2/polls` | Eine Abstimmung erstellen |
| `GET` | `/api/b2/polls/:id` | Eine Abstimmung abrufen |
| `GET` | `/api/b2/polls` | Abstimmungen in einer Gruppe auflisten |
| `PATCH` | `/api/b2/polls/:id` | Eine Abstimmung bearbeiten |
| `DELETE` | `/api/b2/polls/:id` | Eine Abstimmung als gelöscht markieren |
| `GET` | `/api/b2/search` | Sichtbare Diskussionen, Kommentare, Abstimmungen, Stimmen und Fazits durchsuchen |
| `GET` | `/api/b2/threads` | Sichtbare Diskussions-Threads und Threads eigenständiger Abstimmungen auflisten |
| `GET` | `/api/b2/threads/:topic_id` | Einen Thread abrufen |
| `GET` | `/api/b2/threads/:topic_id/items` | Die geordneten Einträge eines Threads abrufen |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Einen vollständigen Thread als Markdown abrufen |
| `GET` | `/api/b2/chatbots` | Chat-Integrationen und Webhooks einer Gruppe auflisten |
| `POST` | `/api/b2/chatbots` | Eine Chat-Integration oder einen Webhook erstellen |
| `PATCH` | `/api/b2/chatbots/:id` | Eine Chat-Integration oder einen Webhook aktualisieren |
| `DELETE` | `/api/b2/chatbots/:id` | Eine Chat-Integration oder einen Webhook löschen |
| `POST` | `/api/b2/chatbots/check` | Einen Verbindungstest für einen Webhook senden |

<!-- translation-section: pagination -->

## Seiteneinteilung

Diskussionen, Gruppen, Mitgliedschaften, Abstimmungen, Threads, Thread-Einträge und Webhooks akzeptieren `limit` (Standardwert `50`) und `offset` (Standardwert `0`). Bei Gruppen, Thread-Einträgen und Webhooks ist `limit` auf `500` begrenzt.

Erhöhe `offset` um die Anzahl der zurückgegebenen primären Datensätze, um die nächste Seite abzurufen. `meta.total` ist die Gesamtanzahl der passenden Datensätze; zugehörige Datensätze zählen nicht zur Seitengröße.

Beteiligungsberichte geben die angeforderten Daten vollständig zurück, die Suche liefert bis zu 20 Ergebnisse. Beide unterstützen keine Seiteneinteilung.

Diskussionen, Abstimmungen und Mitgliedschaften akzeptieren außerdem die älteren Aliasse `per` für `limit` und `from` für `offset`. Verwende für neue Integrationen `limit` und `offset`.

<!-- translation-section: response-size-and-related-records -->

## Zugehörige Datensätze

Antworten der Benutzer-API verwenden ein zusammengesetztes Format: Die primären Datensätze werden durch zugehörige Datensätze wie Topics, Gruppen, Benutzerkonten, Abstimmungen und Reaktionen ergänzt. So kann ein Client mit einer einzigen Anfrage einen lokalen Datenspeicher befüllen. Die Antwort kann jedoch mehr Daten enthalten, als eine einfache Integration benötigt.

Übergib `compact=1`, um umfangreiche zugehörige Topics, Gruppen, Hauptgruppen, Mitgliedschaften, Reaktionen, Schlagwörter und Übersetzungen wegzulassen. Primäre Datensätze und die zugehörigen Datensätze, die zum Verständnis ihrer Inhalte benötigt werden, bleiben enthalten.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Für eine gezielte Steuerung übergib `exclude_types` mit durch Leerzeichen getrennten Datensatztypen im Singular. Beispielsweise lässt `exclude_types=group reaction` zugehörige Gruppen und Reaktionen weg. Übliche Werte sind `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` und `topic_item`. Ausschlüsse gelten für zugehörige Datensätze, nicht für die primäre Ressource, die über den Endpunkt angefordert wird.

Antworten mit Datensatzsammlungen enthalten `meta.total`, wenn eine genaue Gesamtanzahl definiert ist. Die Gesamtanzahl wird berechnet, bevor `limit` und `offset` angewendet werden. Endpunkte wie die Suche, die bewusst eine begrenzte Ergebnismenge zurückgeben, lassen `meta.total` weg, statt `null` zurückzugeben.

<!-- translation-section: comments -->

## Kommentare

<!-- translation-section: create-comment -->

### Kommentar erstellen

Erstelle einen Kommentar in einer Diskussion im Namen des Kontos, zu dem der API-Schlüssel gehört.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

#### Parameter

| Name | Beschreibung |
| --- | --- |
| `discussion_id` | Ganzzahl, erforderlich. ID der Diskussion, die du kommentieren möchtest |
| `body` | Kommentartext, erforderlich, sofern kein Anhang mitgesendet wird |
| `body_format` | Entweder `md` oder `html`, optional, Standardwert `md` |

<!-- translation-section: example-9 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

### Kommentar bearbeiten

Bearbeite einen Kommentar im Namen des Kontos, zu dem der API-Schlüssel gehört. Es gelten dieselben Berechtigungen wie in Loomio: Das Konto muss diesen Kommentar bearbeiten dürfen.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

#### Parameter

| Name | Beschreibung |
| --- | --- |
| `body` | Aktualisierter Kommentartext |
| `body_format` | Entweder `md` oder `html`, optional, Standardwert `md` |

<!-- translation-section: example-10 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

### Kommentar als gelöscht markieren

Markiere einen Kommentar im Namen des Kontos, zu dem der API-Schlüssel gehört, als gelöscht. Dadurch wird der Kommentar verworfen und sein Text ausgeblendet, sein Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: discussions -->

## Diskussionen

<!-- translation-section: create-discussion -->

### Diskussion erstellen

Erstelle eine Diskussion im Namen der Person mit dem API-Schlüssel.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

#### Parameter

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

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

### Diskussion abrufen

Rufe eine Diskussion über ihre ID (eine Ganzzahl) oder ihren Schlüssel (eine Zeichenfolge) ab.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

### Diskussionen auflisten

Liste die Diskussionen in einer Gruppe auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird. Bei einer öffentlich sichtbaren Gruppe können auch Personen ohne Mitgliedschaft die öffentlichen Diskussionen auflisten; private Diskussionen bleiben auf Personen beschränkt, die sie in Loomio lesen dürfen.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

#### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Diskussionen aufgelistet werden sollen |
| `status` | Zeichenfolge, optional, Standardwert `open`. Werte: `open`, `closed`, `all` |
| `limit` | Ganzzahl, optional, Standardwert 50. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seiteneinteilung übersprungen werden |

Abwärtskompatibilität: `per` und `from` werden als Aliasse für `limit` und `offset` akzeptiert und funktionieren weiterhin.

<!-- translation-section: example-4 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: edit-discussion -->

### Diskussion bearbeiten

Bearbeite eine Diskussion als die Person, deren API-Schlüssel verwendet wird. Es gelten dieselben Berechtigungen wie in Loomio: Die Person muss diese Diskussion bearbeiten dürfen.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

#### Parameter

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

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

### Diskussion als gelöscht markieren

Markiere eine Diskussion im Namen des Kontos, zu dem der API-Schlüssel gehört, als gelöscht. Dadurch wird die Diskussion verworfen, ihr Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: groups -->

## Gruppen

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"srechten für die Gruppe |\n| `delegates_count` | Anzahl der Delegierten |\n| `discussions_count` | Anzahl der","after":"srechten für die Gruppe |\n| `discussions_count` | Anzahl der"} -->

### Gruppen auflisten

Gibt die Gruppen zurück, in denen das Konto, dessen API-Schlüssel verwendet wird, eine aktive Mitgliedschaft hat.

`GET /api/b2/groups`

| Name | Beschreibung |
| --- | --- |
| `limit` | Ganzzahl, optional, Standard 50, höchstens 500. Seitengröße |
| `offset` | Ganzzahl, optional, Standard 0. Versatz für die Seiteneinteilung |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/groups?limit=50&offset=0'
```

Die Antwort enthält eine Seite mit `groups`, aufsteigend nach Gruppen-ID sortiert, sowie die Gesamtzahl der passenden Gruppen in `meta.total`. Sie umfasst Hauptgruppen und Untergruppen, einschließlich Gruppen, deren Abonnement derzeit nicht aktiv ist. Prüfe das Feld `enabled`, wenn eine Integration nur mit aktivierten Gruppen arbeiten soll.

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

<!-- translation-section: memberships -->

## Mitgliedschaften

<!-- translation-section: list-memberships -->

### Mitgliedschaften auflisten

Liste die Mitgliedschaften auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird. Gruppenmitglieder können Namen, IDs, Titel und Rollen der Mitglieder lesen. E-Mail-Adressen werden nur für das eigene Konto dieser Person ausgegeben oder wenn sie die Gruppe administriert.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

#### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Mitgliedschaften aufgelistet werden sollen |
| `limit` | Ganzzahl, optional, Standard 50. Seitengröße |
| `offset` | Ganzzahl, optional, Standard 0. Versatz für die Seiteneinteilung |

Abwärtskompatibilität: `per` und `from` werden als Aliase für `limit` und `offset` akzeptiert und funktionieren weiterhin.

Die Antwort enthält eine Seite mit `memberships` und zugehörigen `users`. `meta.total` ist die Gesamtzahl der sichtbaren Mitgliedschaften in der Gruppe vor der Seiteneinteilung.

<!-- translation-section: example-17 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123&limit=50&offset=0'
```

<!-- translation-section: manage-memberships -->

### Mitgliedschaften verwalten

Sende eine Liste von E-Mail-Adressen. Alle neuen E-Mail-Adressen werden zur Gruppe eingeladen. Anders als beim Auflisten von Mitgliedschaften benötigst du für diesen Vorgang Berechtigungen zur Administration der Gruppe.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

#### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Mitgliedschaften verwaltet werden sollen |
| `emails` | Array von Zeichenfolgen, erforderlich. E-Mail-Adressen der Personen, die zur Gruppe eingeladen werden sollen |
| `remove_absent` | Boolescher Wert. Wenn true, werden alle Personen aus der Gruppe entfernt, deren E-Mail-Adresse nicht in der Liste steht |

<!-- translation-section: example-18 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Wenn du `remove_absent=1` übergibst, werden alle Mitglieder aus der Gruppe entfernt, die nicht in der Liste enthalten sind. Sei vorsichtig: Du könntest alle Mitglieder deiner Gruppe entfernen.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Dies gibt ein Objekt mit `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}` zurück.

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

<!-- translation-section: polls -->

## Abstimmungen

<!-- translation-section: create-poll -->

### Abstimmung erstellen

Erstelle eine Abstimmung im Namen des Kontos, zu dem der API-Schlüssel gehört.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

#### Parameter

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

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

### Abstimmung abrufen

Rufe eine Abstimmung anhand ihrer ID (einer Ganzzahl) oder ihres Schlüssels (einer Zeichenkette) ab.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

### Abstimmungen auflisten

Liste die Abstimmungen einer Gruppe auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird. Bei einer öffentlich sichtbaren Gruppe können auch Personen ohne Mitgliedschaft deren öffentliche Abstimmungen auflisten; private Abstimmungen bleiben auf Personen beschränkt, die sie in Loomio lesen können. Die Antwort enthält das aktuelle Fazit jeder sichtbaren Abstimmung. Mit `status=closed` kannst du daher Vorschläge auflisten, über die bereits entschieden wurde.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

#### Parameter

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Abstimmungen aufgelistet werden sollen |
| `status` | Zeichenkette, optional, Standardwert `active`. Werte: `active`, `closed`, `all` |
| `limit` | Ganzzahl, optional, Standardwert 50. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seitennavigation übersprungen werden |

Abwärtskompatibilität: `per` und `from` werden als Aliasse für `limit` und `offset` akzeptiert und funktionieren weiterhin.

<!-- translation-section: example-14 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

### Abstimmung bearbeiten

Bearbeite eine Abstimmung als die Person, deren API-Schlüssel verwendet wird. Es gelten dieselben Berechtigungen wie in Loomio: Diese Person muss die Abstimmung bearbeiten dürfen.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

#### Parameter

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

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

### Abstimmung als gelöscht markieren

Markiere eine Abstimmung als gelöscht, indem du den API-Schlüssel der handelnden Person verwendest. Dadurch wird die Abstimmung verworfen, ihr Datensatz bleibt jedoch erhalten.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

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

<!-- translation-section: threads -->

## Threads

<!-- translation-section: list-threads -->

### Threads auflisten

Liste die Diskussions- und Abstimmungs-Threads auf, die für die Person sichtbar sind, deren API-Schlüssel verwendet wird, sortiert nach der neuesten Aktivität. Die ID eines Threads ist seine `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

#### Parameter

| Name | Beschreibung |
| --- | --- |
| `limit` | Ganzzahl, optional, Standardwert 50. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seiteneinteilung übersprungen werden |

<!-- translation-section: example-5 -->

#### Beispiel

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

### Thread lesen

Lies einen Thread, seinen geordneten Ereignisstrom oder sein vollständiges sichtbares Markdown-Dokument.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

Der Endpunkt `items` akzeptiert diese Parameter zur Seiteneinteilung:

| Name | Beschreibung |
| --- | --- |
| `limit` | Ganzzahl, optional, Standardwert 50, höchstens 500. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seiteneinteilung übersprungen werden |

<!-- translation-section: example-6 -->

#### Beispiel

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Der Endpunkt `items` gibt eine Seite des Ereignisstroms in aufsteigender Reihenfolge zurück, einschließlich sichtbarer Kommentare, Abstimmungen, Stimmen und Fazits. `meta.total` ist die Gesamtzahl der Einträge im Thread. Rufe die folgenden Seiten ab, um den gesamten Ereignisstrom zu lesen. Der Endpunkt `markdown` gibt den vollständigen sichtbaren Thread als ein Markdown-Dokument zurück. Begründungen zu Stimmen werden nur aufgenommen, wenn sie für die Person sichtbar sind, deren API-Schlüssel verwendet wird.

Alle Thread-Endpunkte setzen dieselben Berechtigungen durch wie die Loomio-Oberfläche. Der API-Schlüssel gewährt keinen Zugriff auf einen Thread, den die Person normalerweise nicht öffnen darf.

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

| Name | Beschreibung |
| --- | --- |
| `group_id` | Ganzzahl, erforderlich. ID der Gruppe, deren Webhooks aufgelistet werden sollen |
| `limit` | Ganzzahl, optional, Standardwert 50, höchstens 500. Anzahl der Einträge pro Seite |
| `offset` | Ganzzahl, optional, Standardwert 0. Anzahl der Einträge, die bei der Seiteneinteilung übersprungen werden |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123&limit=50&offset=0'
```

Die Antwort enthält eine Seite von `chatbots`, sortiert nach aufsteigender Integrations-ID, mit der Gesamtzahl für die Gruppe in `meta.total`. Jede Integration hat diese Felder:

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
