---
title: Gebruikers-API
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
  introduction: aea317397fcd7378
  authentication-change: 721f88a9e354b737
  response-size-and-related-records: dab40542694bd0e1
  endpoint-summary: 7db1589758f372a4
  groups: 0c6e911511f85881
  list-groups: 5bf105efcc552327
  get-a-group: a41b5462211123db
  webhooks: a9753e7c17dca483
  list-webhooks: 477b5c6ded67689b
  create-a-webhook: b1523e79668b33fa
  update-a-webhook: 8e3596ac1126704d
  test-a-webhook-destination: 401b8441867cdfe6
  delete-a-webhook: caee702a1e3359f4
  event-types: 5c42e0e7cad145a5
  http-delivery: ce614da664502ca2
  payload-formats: 3fb4f75d51647eca
  search: 506aaaffa8b25428
  params: e0d2664172fd5654
  participation-report: 79204f95b97d17ec
  params-2: f9b4e385898f7ac2
  example: 02f3ba823c53e4a1
  create-discussion: ec5d638b69db30b2
  params-3: c07d6d8432f77db7
  example-2: 5e091ce3ea138f88
  show-discussion: 58b1840761bb3663
  example-3: 7213bc1825fa9f70
  list-discussions: ae8960170693fdc2
  params-4: c0e6b54cb8f58074
  example-4: 90831a7a0e5d51d9
  list-threads: e973f4594d795ccf
  params-5: 07f5e470c5d62cea
  example-5: 2561a53159002733
  read-thread: 74963a9becf6928a
  example-6: bd57f91b43e2f776
  edit-discussion: 5c4c339f356aff63
  params-6: 24b13ac3beef9e06
  example-7: 8645f5f0c964cae3
  soft-delete-discussion: dcaf7db08f9e91f5
  example-8: 1ae9ab816ee02158
  create-comment: 90d313f5af1a3e51
  params-7: c44697d428a3fd1b
  example-9: a73430cb90081c6c
  edit-comment: ba3c3ec14eacc488
  params-8: 61f64b501aa2a450
  example-10: 58d69d9cf77e0261
  soft-delete-comment: 0d63fb6c9a5f79d9
  example-11: 10d9d8e05700bb30
  create-poll: d088735bb1f7717b
  params-9: 0d9a721bb694cb8b
  example-12: aaabda160a186876
  show-poll: e79017f88378c19f
  example-13: 79ef152a72b7f5ec
  list-polls: 661e622805e2c4ac
  params-10: f590c99189f542b5
  example-14: 41fb741925ccc590
  edit-poll: f532afb2772119d0
  params-11: e9ce3d5a6f0574e8
  example-15: a318836c64f997e7
  soft-delete-poll: 44988dcea34e31ff
  example-16: ec135b18c9ffff87
  list-memberships: aa424e112c5755a5
  params-12: f7ec3cdaf101a99c
  example-17: dc020f3f25d79a6d
  manage-memberships: dfbc997ac87cfaa3
  params-13: e3b6900547e45341
  example-18: 8f742537b614f6e2
title_source: c23fb6526b722360
title_generated: d28b6e74f9b5edd3
---

<!-- translation-section: introduction -->

# Documentatie voor de Loomio Gebruikers-API

<!-- seo-description: Gebruik de Loomio Gebruikers-API om vanuit andere software discussies, reacties, peilingen, discussiedraden en groepslidmaatschappen aan te maken en te beheren. -->

`/api/b2` is de API voor integraties met Loomio die namens een gebruiker werken. De API gebruikt de API-sleutel van een gebruikersaccount en voert elke handeling uit als die gebruiker.

Voor groepshandelingen gelden de lidmaatschappen en groepsrechten van de gebruiker bij de API-sleutel. Beheerdersrechten voor de installatie geven een API-sleutel geen extra toegang tot groepen of inhoud. Gebruik de Server API voor beheer op installatieniveau.

Gebruik de API-sleutel van het Loomio-account waarmee de handelingen moeten worden uitgevoerd. Een apart botaccount is handig als de integratie geen uitnodigingen voor peilingen of meldingen moet ontvangen.

Als je bent ingelogd, vind je jouw API-sleutel en groeps-ID's op de [pagina voor API-toegang](/profile/api_access).

Stuur de API-sleutel mee in een `Authorization: Bearer`-header. API-sleutels in querystrings worden geweigerd, omdat proxyservers en toegangslogboeken URL's kunnen vastleggen.

<!-- translation-section: authentication-change -->

### Wijziging in authenticatie

Voorheen werd de API-sleutel geaccepteerd als URL-parameter `api_key`. Verzoeken met `?api_key=YOUR_API_KEY` werken niet meer. Gebruik in plaats daarvan de HTTP-header `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

De voorbeelden gebruiken `YOUR_API_KEY`, groeps-ID `123` en `https://www.loomio.com/`. Vervang deze door jouw API-sleutel, groeps-ID en de URL van jouw Loomio-installatie.

<!-- translation-section: response-size-and-related-records -->

## Omvang van antwoorden en gerelateerde records

Antwoorden van de Gebruikers-API hebben een samengesteld formaat: de hoofdrecords worden geleverd met gerelateerde records, zoals onderwerpen, groepen, gebruikers, peilingen en reacties. Zo kan een client met één verzoek een lokale verzameling records vullen. Het antwoord kan daardoor meer gegevens bevatten dan een eenvoudige integratie nodig heeft.

Geef `compact=1` mee om omvangrijke gerelateerde onderwerpen, groepen, bovenliggende groepen, lidmaatschappen, reacties, tags en vertalingen weg te laten. De hoofdrecords en de gerelateerde records die nodig zijn om hun inhoud te begrijpen, blijven aanwezig.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Voor meer controle geef je `exclude_types` mee met enkelvoudige recordtypen, gescheiden door spaties. Met `exclude_types=group reaction` laat je bijvoorbeeld gerelateerde groepen en reacties weg. Veelgebruikte waarden zijn `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` en `topic_item`. Uitsluitingen gelden voor gerelateerde records, niet voor de hoofdresource die je via het endpoint opvraagt.

Antwoorden met verzamelingen bevatten `meta.total` wanneer de exacte omvang van de verzameling is gedefinieerd. Het totaal wordt berekend voordat `limit` en `offset` worden toegepast. Endpoints zoals zoeken, die bewust een begrensde reeks resultaten teruggeven, laten `meta.total` weg in plaats van `null` terug te geven.

<!-- translation-section: endpoint-summary -->

## Overzicht van endpoints

| Methode | Endpoint | Doel |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Groepen van de gebruiker bij de API-sleutel tonen |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Een zichtbare groep ophalen |
| `GET` | `/api/b2/reports` | Een deelnamerapport maken |
| `GET` | `/api/b2/search` | Zichtbare discussies, reacties, peilingen, stemmen en conclusies doorzoeken |
| `POST` | `/api/b2/discussions` | Een discussie aanmaken |
| `GET` | `/api/b2/discussions/:id` | Een discussie ophalen |
| `GET` | `/api/b2/discussions` | Discussies in een groep tonen |
| `PATCH` | `/api/b2/discussions/:id` | Een discussie bewerken |
| `DELETE` | `/api/b2/discussions/:id` | Een discussie zacht verwijderen |
| `GET` | `/api/b2/threads` | Zichtbare discussiedraden en zelfstandige peilingsdraden tonen |
| `GET` | `/api/b2/threads/:topic_id` | Een discussiedraad ophalen |
| `GET` | `/api/b2/threads/:topic_id/items` | De items in een discussiedraad in volgorde ophalen |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Een volledige discussiedraad als Markdown ophalen |
| `POST` | `/api/b2/comments` | Een reactie of antwoord aanmaken |
| `PATCH` | `/api/b2/comments/:id` | Een reactie bewerken |
| `DELETE` | `/api/b2/comments/:id` | Een reactie zacht verwijderen |
| `POST` | `/api/b2/polls` | Een peiling aanmaken |
| `GET` | `/api/b2/polls/:id` | Een peiling ophalen |
| `GET` | `/api/b2/polls` | Peilingen in een groep tonen |
| `PATCH` | `/api/b2/polls/:id` | Een peiling bewerken |
| `DELETE` | `/api/b2/polls/:id` | Een peiling zacht verwijderen |
| `GET` | `/api/b2/memberships` | Lidmaatschappen van een groep tonen |
| `POST` | `/api/b2/memberships` | Leden toevoegen en eventueel ontbrekende leden verwijderen |
| `GET` | `/api/b2/chatbots` | Chatintegraties en webhooks van een groep tonen |
| `POST` | `/api/b2/chatbots` | Een chatintegratie of webhook aanmaken |
| `PATCH` | `/api/b2/chatbots/:id` | Een chatintegratie of webhook bijwerken |
| `DELETE` | `/api/b2/chatbots/:id` | Een chatintegratie of webhook verwijderen |
| `POST` | `/api/b2/chatbots/check` | Een testbericht naar een webhook sturen |

<!-- translation-section: groups -->

## Groepen

<!-- translation-section: list-groups -->

### Groepen tonen

Geef de groepen terug waarvan de gebruiker bij de API-sleutel actief lid is.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Het antwoord bevat alle overeenkomende records in een `groups`-array zonder paginering. Deze omvat bovenliggende groepen en subgroepen, ook als hun abonnement momenteel niet actief is. Controleer het veld `enabled` als een integratie alleen voor ingeschakelde groepen mag werken.

Belangrijke groepsvelden zijn:

| Veld | Beschrijving |
| --- | --- |
| `id` | Numerieke groeps-ID die door andere endpoints van de Gebruikers-API wordt gebruikt |
| `key` | Vaste korte sleutel die in Loomio-URL's wordt gebruikt |
| `handle` | Leesbare aanduiding van de groep |
| `name` | Groepsnaam |
| `full_name` | Groepsnaam met de context van de bovenliggende groep |
| `parent_id` | Numerieke ID van de bovenliggende groep voor een subgroep, anders `null` |
| `enabled` | Of de groep en het abonnement actief zijn |
| `memberships_count` | Aantal actieve en aangevraagde lidmaatschappen |
| `accepted_memberships_count` | Aantal geaccepteerde lidmaatschappen |
| `pending_memberships_count` | Aantal openstaande uitnodigingen |
| `admin_memberships_count` | Aantal groepsbeheerders |
| `delegates_count` | Aantal afgevaardigden |
| `discussions_count` | Aantal discussies direct in de groep |
| `polls_count` | Aantal peilingen direct in de groep |
| `subgroups_count` | Aantal subgroepen |

Het antwoord kan aanvullende groepsinstellingen, gerelateerde records van bovenliggende groepen en de lidmaatschappen van de API-gebruiker bevatten. Clients kunnen velden die ze niet gebruiken negeren.

<!-- translation-section: get-a-group -->

### Een groep ophalen

Geef één groep terug die zichtbaar is voor de gebruiker bij de API-sleutel.

`GET /api/b2/groups/:id_or_key_or_handle`

Als identificatie kun je de numerieke ID, sleutel of aanduiding van de groep gebruiken.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Het antwoord bevat de groep in de `groups`-array en gebruikt dezelfde velden als het endpoint voor de groepslijst. Een verzoek om een groep waartoe de gebruiker bij de API-sleutel geen toegang heeft, geeft een rechtenfout.

<!-- translation-section: webhooks -->

## Webhooks

De Gebruikers-API werkt op basis van verzoeken: een integratie roept Loomio aan wanneer ze gegevens wil lezen of wijzigen. Met een groepswebhook stuurt Loomio gegevens de andere kant op. Loomio stuurt geselecteerde groepsgebeurtenissen naar jouw endpoint zodra ze plaatsvinden. Daardoor hoeft een integratie de REST API niet regelmatig op wijzigingen te controleren.

Webhooks worden per groep ingesteld en vereisen beheerdersrechten voor die groep. Je kunt ze beheren via de Loomio-interface:

1. Open de groep.
2. Open het groepsmenu en selecteer **Chatintegraties**.
3. Voeg de integratie toe waarvan jouw endpoint het gegevensformaat accepteert. Gebruik voor een algemeen endpoint het formaat Mattermost/Markdown.
4. Voer een naam en de doel-URL in.
5. Selecteer de gebeurtenissen die Loomio automatisch moet versturen.
6. Sla de integratie op en gebruik **Test verbinding** om een testbericht te versturen.

Gebruik een HTTPS-bestemming met een URL die niet te raden is. Loomio vereist dat de bestemming naar een openbaar adres verwijst en blokkeert verzoeken naar lokale of privénetwerkadressen.

Agents en andere integraties kunnen webhooks ook beheren via de hieronder beschreven chatbot-endpoints met Bearer-authenticatie. De resource heet `chatbots` vanwege de compatibiliteit met de chatintegraties van Loomio, maar omvat ook algemene uitgaande webhooks.

<!-- translation-section: list-webhooks -->

### Webhooks tonen

Geef de chatintegraties terug die voor een groep zijn ingesteld. De gebruiker bij de API-sleutel moet beheerder van die groep zijn. Het antwoord bevat doel-URL's en mag daarom niet toegankelijk zijn voor gewone groepsleden.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Het antwoord bevat een `chatbots`-array met deze velden:

| Veld | Beschrijving |
| --- | --- |
| `id` | ID van de integratie voor updates en verwijdering |
| `group_id` | Groep die de gebeurtenissen ontvangt |
| `name` | Beheerdersnaam van de integratie |
| `kind` | `webhook` voor een uitgaande webhook of `matrix` voor een Matrix-integratie |
| `webhook_kind` | Payloadformaat: `markdown`, `slack`, `discord`, `microsoft` of `webex` |
| `server` | Doel-URL |
| `event_kinds` | Gebeurtenissen die automatisch worden verzonden |
| `notification_only` | Of berichten alleen de kop van de melding bevatten |

<!-- translation-section: create-a-webhook -->

### Een webhook maken

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

De gebruiker van de API-sleutel moet beheerder zijn van `group_id`. Voordat de doel-URL wordt opgeslagen, wordt gecontroleerd of deze openbaar is.

<!-- translation-section: update-a-webhook -->

### Een webhook bijwerken

`PATCH /api/b2/chatbots/:id`

Stuur de velden die je wilt wijzigen. Je kunt de webhook niet naar een andere groep verplaatsen door `group_id` te wijzigen.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Een webhookbestemming testen

Stuur een testbericht dat geschikt is voor Markdown naar de bestemming, voordat of nadat je de configuratie opslaat.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Een webhook verwijderen

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Als je de configuratie verwijdert, worden er geen nieuwe berichten meer afgeleverd. Inhoud van de Loomio-groep blijft behouden.

<!-- translation-section: event-types -->

### Gebeurtenistypen

Een webhook kan zich op deze gebeurtenistypen abonneren:

| Gebeurtenis | Wanneer deze wordt verzonden |
| --- | --- |
| `new_discussion` | Een discussie wordt gestart |
| `discussion_edited` | Een discussie wordt bewerkt |
| `new_comment` | Een reactie wordt geplaatst |
| `poll_created` | Een peiling wordt gestart |
| `poll_edited` | Een peiling wordt bewerkt |
| `poll_closing_soon` | De sluitingstijd van een peiling nadert |
| `poll_expired` | Een peiling bereikt de sluitingstijd |
| `poll_closed_by_user` | Iemand sluit een peiling handmatig |
| `poll_reopened` | Een peiling wordt heropend |
| `outcome_created` | Een conclusie wordt gepubliceerd |
| `outcome_updated` | Een conclusie wordt bijgewerkt |
| `outcome_review_due` | Een conclusie moet worden geëvalueerd |
| `stance_created` | Er wordt een stem uitgebracht |
| `stance_updated` | Een stem wordt gewijzigd |

De webhook hoort bij één groep en ontvangt de gebeurtenissen uit die groep waarop hij is geabonneerd. Mensen kunnen de integratie ook expliciet kiezen bij het delen of verzenden van bepaalde meldingen, zelfs als de bijbehorende automatische gebeurtenis niet is geselecteerd.

<!-- translation-section: http-delivery -->

### HTTP-aflevering

Loomio verstuurt asynchroon een HTTP-`POST` naar de ingestelde URL met deze header:

```text
Content-Type: application/json; charset=utf-8
```

De time-out voor het verzoek is vijf seconden. Een `2xx`-antwoord, waaronder `204 No Content`, geldt als geslaagd. Ontvangers van webhooks moeten snel antwoorden, langer durend werk asynchroon verwerken en kunnen omgaan met dubbele of in een andere volgorde afgeleverde berichten.

Loomio voegt momenteel geen webhookhandtekening, header met een gedeeld geheim, gebeurtenis-ID of afleverings-ID toe. Behandel de volledige doel-URL als een toegangsmiddel en maak deze niet openbaar. Neem een niet te raden token op in de URL als de ontvangende dienst dat ondersteunt. Als je een stabiel, machineleesbaar gebeurtenisformaat of ondertekende aflevering nodig hebt, gebruik de webhook dan als melding van een wijziging en haal de actuele gegevens op via de geauthenticeerde gebruikers-API.

<!-- translation-section: payload-formats -->

### Payloadformaten

Webhookpayloads zijn berichten voor chatdiensten. Ze bevatten geen volledige geserialiseerde Loomio-gegevens. De links in een bericht verwijzen naar de betrokken inhoud in Loomio. Een integratie kan daarna via de gebruikers-API de actuele gegevens in gestructureerde vorm ophalen.

| Integratieformaat | Belangrijkste JSON-velden |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, beperkt tot ongeveer 1.900 tekens |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Het algemene Markdown-formaat verstuurt bijvoorbeeld een bericht met deze structuur:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

De exacte berichttekst hangt af van de gebeurtenis, de taalinstelling van de groep, de instelling voor alleen meldingen en de Loomio-versie. Gebruik als ontvanger de gedocumenteerde velden op het hoogste niveau van het gekozen formaat. Leid gegevens niet af uit de formulering van zinnen.

<!-- translation-section: search -->

## Zoeken

Zoek in discussies, reacties, peilingen, stemmen en conclusies die zichtbaar zijn voor de gebruiker van de API-sleutel. De resultaten bevatten ook openbare inhoud van groepen waarvan de gebruiker geen lid is. Voor privé-inhoud gelden de normale zichtbaarheidregels voor topics.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `query` | Zoektekst. Exacte en benaderende overeenkomsten worden ondersteund |
| `group_id` | Beperk de resultaten tot één zichtbare groep |
| `org_id` | Beperk de resultaten tot een zichtbare hoofdgroep en de zichtbare subgroepen daarvan. Gebruik `0` voor directe discussies |
| `type` | Beperk de resultaten tot één type: `Discussion`, `Comment`, `Poll`, `Stance` of `Outcome` |
| `types` | Lijst met resultaattypen, gescheiden door komma's |
| `tag` | Beperk de resultaten tot topics met dit label |
| `author_id` | Beperk de resultaten tot inhoud van één auteur. Zonder `query` wordt de recente zichtbare activiteit van die auteur geretourneerd |
| `order` | Stel in op `authored_at_desc` om overeenkomende inhoud te sorteren op aanmaaktijd |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Het antwoord bevat een array met `search_results`. Elk resultaat vermeldt het gevonden record en de zichtbare context ervan, met onder meer de velden `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` en `tags`. Velden die niet van toepassing zijn op een resultaat, hebben de waarde `null`.

<!-- translation-section: participation-report -->

## Deelnameverslag

Geeft dezelfde samengevoegde deelnamegegevens terug die Loomio in het deelnameverslag gebruikt.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `section` | Onderdeel van het verslag: `base`, `users` of `countries`. Gebruik `users` voor activiteit per persoon |
| `group_scope` | `custom` of `my`. De verouderde waarde `all` wordt behandeld als `my`, omdat sleutels voor de gebruikers-API nooit toegang tot de hele instantie geven |
| `group_ids` | Groeps-ID's, gescheiden door komma's, wanneer `group_scope=custom`. ID's van groepen waarvan de API-gebruiker geen lid is, worden genegeerd |
| `start_month` | Eerste maand in de notatie `YYYY-MM`; standaard 12 maanden geleden |
| `end_month` | Laatste maand in de notatie `YYYY-MM`; standaard de huidige maand |
| `interval` | Interval voor het onderdeel `base`: `day`, `week`, `month` of `year` |
| `member_type` | Stel in op `delegate` met `section=users` om alleen huidige afgevaardigden terug te krijgen |

Iemand is een afgevaardigde als die persoon in een van de geselecteerde groepen een actief lidmaatschap als afgevaardigde heeft. De aantallen worden over alle geselecteerde groepen samengevoegd. Afgevaardigden worden ook getoond als alle activiteitsaantallen nul zijn. De aantallen omvatten discussies, reacties, peilingen, stemmen, conclusies en emoji-reacties. Het zijn geen percentages voor deelname aan stemmingen. De rijen per gebruiker bevatten ook aantallen toegewezen, uitgebrachte en gemiste stemmen bij niet-anonieme stemmingen. Anonieme peilingen tellen niet mee in de stemtotalen per persoon. `all_votes_cast` is alleen waar als minstens één stem is toegewezen en alle toegewezen stemmen zijn uitgebracht.

De API past dezelfde regels voor groepszichtbaarheid toe als het verslag in Loomio. Een sleutel voor de gebruikers-API kan geen verslaggegevens tonen van groepen waartoe de gebruiker geen toegang heeft.

<!-- translation-section: example -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

De array `users` bevat volledige rijen met activiteitsgegevens:

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

## Discussie aanmaken

Maak een discussie aan namens de gebruiker van de API-sleutel.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Groep waarin de thread wordt aangemaakt |
| `title` | Titel van de thread, verplicht |
| `description` | Context voor de thread, optioneel |
| `description_format` | `md` of `html`, optioneel, standaard `md` |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding over de nieuwe thread |
| `recipient_user_ids` | Lijst met gebruikers-ID's van mensen die een melding krijgen of worden uitgenodigd voor de thread |
| `recipient_emails` | Lijst met e-mailadressen van mensen die worden uitgenodigd voor de thread |
| `recipient_message` | Bericht voor de uitnodiging per e-mail |

<!-- translation-section: example-2 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Discussie ophalen

Haal een discussie op met de numerieke discussie-ID of de sleutel als tekenreeks.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Discussies weergeven

Geef de discussies in een groep weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Bij een openbaar zichtbare groep kan ook iemand die geen lid is de openbare discussies weergeven. Privédiscussies blijven alleen zichtbaar voor gebruikers die ze in Loomio kunnen lezen.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan je de discussies wilt weergeven |
| `status` | Tekenreeks, optioneel, standaard `open`. Waarden: `open`, `closed`, `all` |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal resultaten per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Beginpositie voor paginering |

Voor compatibiliteit blijven `per` en `from` werken als alternatieve namen voor `limit` en `offset`.

<!-- translation-section: example-4 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Threads weergeven

Geef de discussie- en peilingthreads weer die zichtbaar zijn voor de gebruiker van de API-sleutel, gesorteerd op recentste activiteit. De ID van een thread is de `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal resultaten per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Beginpositie voor paginering |

<!-- translation-section: example-5 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Thread lezen

Lees een thread, de gebeurtenissen in volgorde of het volledige zichtbare Markdown-document.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Voorbeeld

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Het `items`-endpoint geeft de gebeurtenissen in volgorde terug, waaronder zichtbare reacties, peilingen, stemmen en conclusies. Het `markdown`-endpoint geeft de volledige zichtbare thread terug als één Markdown-document. Redenen voor stemmen worden alleen opgenomen als ze zichtbaar zijn voor de gebruiker van de API-sleutel.

Voor alle thread-endpoints gelden dezelfde toegangsrechten als in Loomio. Een API-sleutel geeft geen toegang tot een thread die de gebruiker normaal niet kan openen.

<!-- translation-section: edit-discussion -->

## Discussie bewerken

Bewerk een discussie namens de gebruiker van de API-sleutel. Dezelfde toegangsrechten gelden als in Loomio: de gebruiker moet deze discussie mogen bewerken.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `title` | Bijgewerkte titel |
| `description` | Bijgewerkte context |
| `description_format` | `md` of `html`, optioneel, standaard `md` |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding over de bewerking |
| `recipient_user_ids` | Lijst met gebruikers-ID's van mensen die een melding krijgen of worden uitgenodigd voor de thread |
| `recipient_emails` | Lijst met e-mailadressen van mensen die worden uitgenodigd voor de thread |
| `recipient_message` | Bericht voor de uitnodiging per e-mail |

<!-- translation-section: example-7 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Discussie voorlopig verwijderen

Verwijder een discussie voorlopig namens de gebruiker van de API-sleutel. De discussie wordt weggehaald, maar het discussierecord blijft bewaard.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Reactie aanmaken

Plaats een reactie in een discussie namens de gebruiker van de API-sleutel.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `discussion_id` | Geheel getal, verplicht. ID van de discussie waarop je wilt reageren |
| `body` | Tekst van de reactie, verplicht tenzij je een bijlage toevoegt |
| `body_format` | `md` of `html`, optioneel, standaard `md` |

<!-- translation-section: example-9 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Reactie bewerken

Bewerk een reactie namens de gebruiker van de API-sleutel. Dezelfde toegangsrechten gelden als in Loomio: de gebruiker moet deze reactie mogen bewerken.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `body` | Bijgewerkte tekst van de reactie |
| `body_format` | `md` of `html`, optioneel, standaard `md` |

<!-- translation-section: example-10 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Reactie voorlopig verwijderen

Verwijder een reactie voorlopig namens de gebruiker van de API-sleutel. De reactie wordt weggehaald en de tekst wordt verborgen, maar het reactierecord blijft bewaard.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Peiling maken

Maak een peiling aan namens de gebruiker van de API-sleutel.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, optioneel, standaard null. ID van de groep voor de peiling. Als `discussion_id` is opgegeven, wordt `group_id` genegeerd |
| `discussion_id` | Geheel getal, optioneel, standaard null. ID van de discussiedraad waaraan de peiling wordt toegevoegd |
| `title` | Tekst, verplicht. Titel van de peiling |
| `poll_type` | Tekst, verplicht. Mogelijke waarden: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Tekst, optioneel. De inhoud van de peiling |
| `details_format` | Tekst, optioneel, standaard `md`. Mogelijke waarden: `md` of `html` |
| `options` | Lijst met teksten. Als `poll_type` gelijk is aan `proposal`, zijn `agree`, `disagree`, `abstain` en `block` geldige waarden. Als `poll_type` gelijk is aan `meeting`, geef dan datums of datum-tijdwaarden in ISO 8601-formaat op. Voor alle andere peilingtypen is elke tekst geldig |
| `closing_at` | Tekst in ISO 8601-formaat of null, standaard null. Voorbeeld: `2026-09-01T12:00:00Z`. Bij null is stemmen uitgeschakeld en wordt de peiling beschouwd als werk in uitvoering |
| `specified_voters_only` | Booleaanse waarde, optioneel, standaard false. Bij true kunnen alleen opgegeven personen stemmen. Bij false wordt iedereen in de groep uitgenodigd om te stemmen |
| `hide_results` | Tekst, optioneel, standaard `off`. Mogelijke waarden: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booleaanse waarde, standaard false. Toon de opties in willekeurige volgorde aan stemmers |
| `anonymous` | Booleaanse waarde, optioneel, standaard false. Verberg de identiteit van stemmers |
| `recipient_audience` | `group` of null, optioneel, standaard null. Bij `group` krijgt de hele groep een melding |
| `notify_on_closing_soon` | Tekst, optioneel, standaard `nobody`. Mogelijke waarden: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Lijst met gebruikers-ID's van personen die een melding of uitnodiging krijgen |
| `recipient_emails` | Lijst met e-mailadressen van personen die worden uitgenodigd om te stemmen |
| `recipient_message` | Bericht voor de uitnodiging per e-mail |
| `notify_recipients` | Booleaanse waarde, standaard false. Bij false worden personen toegevoegd zonder meldingen te versturen. Bij true krijgt iedereen die via dit verzoek wordt uitgenodigd een e-mailmelding |

<!-- translation-section: example-12 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Peiling ophalen

Haal een peiling op met het numerieke peiling-ID of de sleutel als tekst.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Peilingen weergeven

Geef de peilingen in een groep weer die de gebruiker van de API-sleutel kan zien. Bij een openbaar zichtbare groep kunnen ook niet-leden de openbare peilingen weergeven. Privépeilingen blijven beperkt tot gebruikers die ze in Loomio kunnen lezen. Het antwoord bevat de huidige conclusie van elke zichtbare peiling. Gebruik `status=closed` om voorstellen met een conclusie weer te geven.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de peilingen worden weergegeven |
| `status` | Tekst, optioneel, standaard `active`. Mogelijke waarden: `active`, `closed`, `all` |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal resultaten per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Verschuiving voor paginering |

Voor compatibiliteit blijven `per` en `from` werken als alternatieve namen voor `limit` en `offset`.

<!-- translation-section: example-14 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Peiling bewerken

Bewerk een peiling namens de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet de peiling mogen bewerken.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `title` | Bijgewerkte titel |
| `details` | Bijgewerkte details van de peiling |
| `details_format` | `md` of `html`, optioneel, standaard `md` |
| `options` | Bijgewerkte optienamen. Afhankelijk van de status van de peiling kan het wijzigen van opties bestaande stemmen beïnvloeden |
| `closing_at` | Tekst in ISO 8601-formaat of null |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding |
| `recipient_user_ids` | Lijst met gebruikers-ID's van personen die een melding of uitnodiging krijgen |
| `recipient_emails` | Lijst met e-mailadressen van personen die worden uitgenodigd om te stemmen |
| `recipient_message` | Bericht voor de uitnodiging per e-mail |

<!-- translation-section: example-15 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Peiling verwijderen zonder het record te wissen

Verwijder een peiling namens de gebruiker van de API-sleutel zonder het record te wissen. De peiling wordt verwijderd, maar het peilingrecord blijft bestaan.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Lidmaatschappen weergeven

Geef de lidmaatschappen weer die de gebruiker van de API-sleutel kan zien. Groepsleden kunnen namen, ID's, titels en rollen van leden lezen. E-mailadressen zijn alleen opgenomen voor het eigen account van de gebruiker van de API-sleutel of wanneer die gebruiker groepsbeheerder is.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de lidmaatschappen worden weergegeven |

<!-- translation-section: example-17 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Lidmaatschappen beheren

Verstuur een lijst met e-mailadressen. Nieuwe adressen op de lijst krijgen een uitnodiging voor de groep. Hiervoor zijn beheerdersrechten voor de groep vereist.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de lidmaatschappen worden beheerd |
| `emails` | Lijst met teksten, verplicht. E-mailadressen van personen die voor de groep worden uitgenodigd |
| `remove_absent` | Booleaanse waarde. Bij true wordt iedereen van de groep verwijderd van wie het e-mailadres niet op de lijst staat |

<!-- translation-section: example-18 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Als je `remove_absent=1` opgeeft, worden alle groepsleden die niet op de lijst staan uit de groep verwijderd. Controleer de lijst zorgvuldig: je kunt hiermee iedereen uit jouw groep verwijderen.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Dit geeft een object terug met `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
