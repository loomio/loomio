---
title: Gebruikers-API
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
  introduction: f5847b68f6746818
  authentication-change: aaf45b09dc9b3f32
  response-size-and-related-records: b7637be233e78ec6
  endpoint-summary: b16be979102ac036
  groups: 0c6e911511f85881
  list-groups: 1bd3e523f2ede444
  get-a-group: 91925311e67f5b6f
  webhooks: 0fd0f939a97c637b
  list-webhooks: 86e6735a4672b09f
  create-a-webhook: a0093855b53e33a7
  update-a-webhook: 9845d5e10916d063
  test-a-webhook-destination: 589a34dfeba79514
  delete-a-webhook: '0975f1bfc9fc2078'
  event-types: b608c72c1d76334c
  http-delivery: 505eb8000572c4db
  payload-formats: 142420a88cc51ef2
  search: 7e8fc20a2585ef31
  params: b9dc931978bf5b90
  participation-report: 5b6817951ab49dfb
  params-2: 8987c69b0bdc74d1
  example: 1c16c9e251f642bf
  create-discussion: 1a3dc39f81880a5c
  params-3: c6a6332bde118b19
  example-2: 5e091ce3ea138f88
  show-discussion: 94a62facb4fcc354
  example-3: 7213bc1825fa9f70
  list-discussions: 9b255219a6cbeab7
  params-4: 0d91ce72dff3dd2e
  example-4: 90831a7a0e5d51d9
  list-threads: 0110c658162e8e7e
  params-5: cf663d34523c134e
  example-5: 2561a53159002733
  read-thread: 91e03972c10aaebb
  example-6: e13b5b87861c2763
  edit-discussion: 33cecbb77904b925
  params-6: a6c91df79d2d036e
  example-7: 8645f5f0c964cae3
  soft-delete-discussion: ec1c550ea8e9775d
  example-8: 1ae9ab816ee02158
  create-comment: 4fc3123243eeccdc
  params-7: 90c34691c2b4b03e
  example-9: a73430cb90081c6c
  edit-comment: e649cc2a3c811095
  params-8: 61f64b501aa2a450
  example-10: 58d69d9cf77e0261
  soft-delete-comment: d733a10418d3f4e0
  example-11: 10d9d8e05700bb30
  create-poll: 7fca677223fa7120
  params-9: e1c3e7f53c783933
  example-12: aaabda160a186876
  show-poll: 5ace98993d9e32a2
  example-13: 79ef152a72b7f5ec
  list-polls: 9be66577744d9287
  params-10: '035598002a6ab032'
  example-14: 41fb741925ccc590
  edit-poll: aa45ee79d0e481a4
  params-11: 986a72c0caf40837
  example-15: a318836c64f997e7
  soft-delete-poll: c4c60e82a5ef6b04
  example-16: ec135b18c9ffff87
  list-memberships: bcd8f45833960e53
  params-12: f7ec3cdaf101a99c
  example-17: dc020f3f25d79a6d
  manage-memberships: 71075781b0158bc7
  params-13: dc78140eae98db81
  example-18: 8c30d56f58911bf4
title_source: c23fb6526b722360
title_generated: d28b6e74f9b5edd3
---

<!-- translation-section: introduction -->

# Documentatie van de Loomio Gebruikers-API

<!-- seo-description: Gebruik de Loomio Gebruikers-API om vanuit andere software discussies, reacties, peilingen, threads en groepslidmaatschappen aan te maken en te beheren. -->

`/api/b2` is de gebruikersgerichte API voor integraties met Loomio. Deze gebruikt de API-sleutel van een gebruikersaccount, en elke actie wordt uitgevoerd als die gebruiker.

Groepsbewerkingen gebruiken de lidmaatschappen en groepsrechten van de gebruiker van de API-sleutel. De status van instantiebeheerder geeft een API-sleutel geen ruimere toegang tot groepen of inhoud; gebruik de Server-API voor beheer op instantieniveau.

Gebruik de API-sleutel van het Loomio-gebruikersaccount dat de acties zal uitvoeren. Een apart botaccount is handig als een integratie geen uitnodigingen voor peilingen of meldingen moet ontvangen.

Ingelogde gebruikers kunnen hun API-sleutel en groeps-ID's vinden op de [pagina voor API-toegang](/profile/api_access).

Stuur de API-sleutel mee in een `Authorization: Bearer`-header. API-sleutels in querystrings worden geweigerd omdat URL's kunnen worden vastgelegd door proxy's en toegangslogboeken.

<!-- translation-section: authentication-change -->

### Wijziging in authenticatie

De API-sleutel werd voorheen geaccepteerd als URL-parameter `api_key`. Verzoeken met `?api_key=YOUR_API_KEY` werken niet meer. Gebruik in plaats daarvan de HTTP-header `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

De voorbeelden gebruiken `YOUR_API_KEY`, groeps-ID `123` en `https://www.loomio.com/`. Vervang deze door jouw API-sleutel, groeps-ID en de URL van jouw Loomio-installatie.

<!-- translation-section: response-size-and-related-records -->

## Responsgrootte en gerelateerde records

Responsen van de Gebruikers-API gebruiken een samengesteld formaat: de primaire records worden aangevuld met gerelateerde records zoals topics, groepen, gebruikers, peilingen en emoji-reacties. Hiermee kan een client met één verzoek een lokale recordopslag vullen, maar de respons kan meer gegevens bevatten dan een eenvoudige integratie nodig heeft.

Geef `compact=1` mee om omvangrijke gerelateerde topics, groepen, hoofdgroepen, lidmaatschappen, emoji-reacties, labels en vertalingen weg te laten. Primaire records en de gerelateerde records die nodig zijn om hun inhoud te interpreteren, blijven aanwezig.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Voor directe controle geef je `exclude_types` mee met recordtypen in het enkelvoud, gescheiden door spaties. Zo laat `exclude_types=group reaction` gerelateerde groepen en emoji-reacties weg. Veelgebruikte waarden zijn `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` en `topic_item`. Uitsluitingen gelden voor gerelateerde records, niet voor de primaire resource die via het endpoint wordt opgevraagd.

Responsen met collecties bevatten `meta.total` wanneer een exacte collectiegrootte is gedefinieerd. Het totaal wordt berekend voordat `limit` en `offset` worden toegepast. Endpoints zoals zoeken, die bewust een begrensde verzameling resultaten teruggeven, laten `meta.total` weg in plaats van `null` terug te geven.

<!-- translation-section: endpoint-summary -->

## Overzicht van endpoints

| Methode | Endpoint | Doel |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Groepen van de gebruiker van de API-sleutel opvragen |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Een zichtbare groep ophalen |
| `GET` | `/api/b2/reports` | Een participatierapport genereren |
| `GET` | `/api/b2/search` | Zichtbare discussies, reacties, peilingen, stemmen en conclusies doorzoeken |
| `POST` | `/api/b2/discussions` | Een discussie aanmaken |
| `GET` | `/api/b2/discussions/:id` | Een discussie ophalen |
| `GET` | `/api/b2/discussions` | Discussies in een groep opvragen |
| `PATCH` | `/api/b2/discussions/:id` | Een discussie bewerken |
| `DELETE` | `/api/b2/discussions/:id` | Een discussie verwijderen met behoud van het record |
| `GET` | `/api/b2/threads` | Zichtbare discussiethreads en threads met zelfstandige peilingen opvragen |
| `GET` | `/api/b2/threads/:topic_id` | Een thread ophalen |
| `GET` | `/api/b2/threads/:topic_id/items` | De items in een thread in volgorde ophalen |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Een volledige thread als Markdown ophalen |
| `POST` | `/api/b2/comments` | Een reactie of antwoord aanmaken |
| `PATCH` | `/api/b2/comments/:id` | Een reactie bewerken |
| `DELETE` | `/api/b2/comments/:id` | Een reactie verwijderen met behoud van het record |
| `POST` | `/api/b2/polls` | Een peiling aanmaken |
| `GET` | `/api/b2/polls/:id` | Een peiling ophalen |
| `GET` | `/api/b2/polls` | Peilingen in een groep opvragen |
| `PATCH` | `/api/b2/polls/:id` | Een peiling bewerken |
| `DELETE` | `/api/b2/polls/:id` | Een peiling verwijderen met behoud van het record |
| `GET` | `/api/b2/memberships` | Lidmaatschappen van een groep opvragen |
| `POST` | `/api/b2/memberships` | Leden toevoegen en desgewenst leden verwijderen die niet in de lijst staan |
| `GET` | `/api/b2/chatbots` | Chatintegraties en webhooks van een groep opvragen |
| `POST` | `/api/b2/chatbots` | Een chatintegratie of webhook aanmaken |
| `PATCH` | `/api/b2/chatbots/:id` | Een chatintegratie of webhook bijwerken |
| `DELETE` | `/api/b2/chatbots/:id` | Een chatintegratie of webhook verwijderen |
| `POST` | `/api/b2/chatbots/check` | Een verbindingstest voor een webhook versturen |

<!-- translation-section: groups -->

## Groepen

<!-- translation-section: list-groups -->

### Groepen opvragen

Geeft de groepen terug waarin de gebruiker van de API-sleutel een actief lidmaatschap heeft.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

De respons bevat alle overeenkomende records in een `groups`-array zonder paginering. Deze bevat hoofdgroepen en subgroepen, ook groepen waarvan het abonnement momenteel niet actief is. Controleer het veld `enabled` als een integratie alleen met ingeschakelde groepen moet werken.

Belangrijke groepsvelden zijn:

| Veld | Beschrijving |
| --- | --- |
| `id` | Numerieke groeps-ID die andere endpoints van de Gebruikers-API gebruiken |
| `key` | Vaste korte sleutel die in Loomio-URL's wordt gebruikt |
| `handle` | Leesbare identificatienaam van de groep |
| `name` | Groepsnaam |
| `full_name` | Groepsnaam inclusief de context van de hoofdgroep |
| `parent_id` | Numerieke ID van de hoofdgroep voor een subgroep, anders `null` |
| `enabled` | Of de groep en het abonnement actief zijn |
| `memberships_count` | Aantal actieve en nog niet geaccepteerde lidmaatschappen |
| `accepted_memberships_count` | Aantal geaccepteerde lidmaatschappen |
| `pending_memberships_count` | Aantal nog niet geaccepteerde uitnodigingen |
| `admin_memberships_count` | Aantal groepsbeheerders |
| `delegates_count` | Aantal afgevaardigden |
| `discussions_count` | Aantal discussies rechtstreeks in de groep |
| `polls_count` | Aantal peilingen rechtstreeks in de groep |
| `subgroups_count` | Aantal subgroepen |

De respons kan aanvullende groepsinstellingen, gerelateerde records van hoofdgroepen en de lidmaatschappen van de API-gebruiker bevatten. Clients moeten velden die ze niet gebruiken negeren.

<!-- translation-section: get-a-group -->

### Een groep ophalen

Geeft één groep terug die zichtbaar is voor de gebruiker van de API-sleutel.

`GET /api/b2/groups/:id_or_key_or_handle`

De identificatie kan de numerieke ID, sleutel of identificatienaam van de groep zijn.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

De respons bevat de groep in de `groups`-array en gebruikt dezelfde velden als het endpoint voor het opvragen van groepen. Een verzoek voor een groep waartoe de gebruiker van de API-sleutel geen toegang heeft, geeft een fout wegens onvoldoende rechten terug.

<!-- translation-section: webhooks -->

## Webhooks

De Gebruikers-API werkt met verzoeken: een integratie roept Loomio aan wanneer deze gegevens wil lezen of wijzigen. Een groepswebhook zorgt voor verzending in de andere richting. Loomio stuurt geselecteerde groepsgebeurtenissen naar jouw endpoint zodra ze plaatsvinden, zodat een integratie de REST-API niet herhaaldelijk hoeft op te vragen om wijzigingen te vinden.

Webhooks worden per groep ingesteld en vereisen groepsbeheerdersrechten. Je kunt ze beheren via de Loomio-interface:

1. Open de groep.
2. Open het groepsmenu en selecteer **Chatintegraties**.
3. Voeg de integratie toe die overeenkomt met het payloadformaat dat jouw endpoint accepteert. Gebruik het Mattermost/Markdown-formaat voor een algemeen endpoint.
4. Voer een naam en de bestemmings-URL in.
5. Selecteer de gebeurtenissen die Loomio automatisch moet versturen.
6. Sla de integratie op en gebruik **Test verbinding** om een testbericht te versturen.

Gebruik een HTTPS-bestemming met een URL die niet te raden is. Loomio vereist dat de bestemming naar een openbaar adres verwijst en blokkeert verzoeken naar lokale of private netwerkadressen.

Agents en andere integraties kunnen webhooks ook beheren via de hieronder beschreven chatbot-endpoints met Bearer-authenticatie. De resource heet `chatbots` voor compatibiliteit met de chatintegraties van Loomio, maar vertegenwoordigt ook algemene uitgaande webhooks.

<!-- translation-section: list-webhooks -->

### Webhooks opvragen

Geeft de chatintegraties terug die voor een groep zijn ingesteld. De gebruiker van de API-sleutel moet beheerder van die groep zijn. De respons bevat bestemmings-URL's en mag daarom niet toegankelijk worden gemaakt voor gewone groepsleden.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

De respons bevat een `chatbots`-array met deze velden:

| Veld | Beschrijving |
| --- | --- |
| `id` | Integratie-ID die wordt gebruikt voor bijwerken en verwijderen |
| `group_id` | Groep die de gebeurtenissen ontvangt |
| `name` | Naam voor het beheer van de integratie |
| `kind` | `webhook` voor een uitgaande webhook of `matrix` voor een Matrix-integratie |
| `webhook_kind` | Payloadformaat: `markdown`, `slack`, `discord`, `microsoft` of `webex` |
| `server` | Bestemmings-URL |
| `event_kinds` | Gebeurtenissen die automatisch worden verstuurd |
| `notification_only` | Of berichten alleen de titel van de melding bevatten |

<!-- translation-section: create-a-webhook -->

### Een webhook aanmaken

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

De gebruiker van de API-sleutel moet beheerder zijn van `group_id`. Voordat de bestemming wordt opgeslagen, wordt gecontroleerd of deze een openbare URL is.

<!-- translation-section: update-a-webhook -->

### Een webhook bijwerken

`PATCH /api/b2/chatbots/:id`

Stuur alle velden mee die moeten veranderen. Je kunt de webhook niet naar een andere groep verplaatsen door `group_id` te wijzigen.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Een webhookbestemming testen

Stuur een testbericht dat compatibel is met Markdown naar een bestemming voordat of nadat je de configuratie opslaat.

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

Als je de configuratie verwijdert, worden er geen berichten meer afgeleverd. Er wordt geen inhoud uit de Loomio-groep verwijderd.

<!-- translation-section: event-types -->

### Gebeurtenistypen

Een webhook kan zich abonneren op deze gebeurtenistypen:

| Gebeurtenis | Wanneer deze wordt verzonden |
| --- | --- |
| `new_discussion` | Een discussie wordt gestart |
| `discussion_edited` | Een discussie wordt bewerkt |
| `new_comment` | Een reactie wordt geplaatst |
| `poll_created` | Een peiling wordt gestart |
| `poll_edited` | Een peiling wordt bewerkt |
| `poll_closing_soon` | Een peiling nadert het sluitingstijdstip |
| `poll_expired` | Een peiling bereikt het sluitingstijdstip |
| `poll_closed_by_user` | Iemand sluit een peiling handmatig |
| `poll_reopened` | Een peiling wordt heropend |
| `outcome_created` | Een conclusie wordt gepubliceerd |
| `outcome_updated` | Een conclusie wordt bijgewerkt |
| `outcome_review_due` | Het is tijd om een conclusie te evalueren |
| `stance_created` | Een stem wordt uitgebracht |
| `stance_updated` | Een stem wordt gewijzigd |

De webhook hoort bij één groep en ontvangt de gebeurtenissen uit die groep waarop hij is geabonneerd. Mensen kunnen de integratie ook expliciet selecteren bij het delen of verzenden van bepaalde meldingen, zelfs als de bijbehorende automatische gebeurtenis niet is geselecteerd.

<!-- translation-section: http-delivery -->

### HTTP-aflevering

Loomio verstuurt een asynchrone HTTP `POST` naar de ingestelde URL met deze header:

```text
Content-Type: application/json; charset=utf-8
```

De time-out voor het verzoek is vijf seconden. Een `2xx`-antwoord, inclusief `204 No Content`, geldt als geslaagd. Diensten die webhooks ontvangen, moeten snel antwoorden, langer durend werk asynchroon verwerken en dubbele afleveringen of afleveringen in een andere volgorde kunnen verwerken.

Loomio voegt momenteel geen webhookhandtekening, header met een gedeeld geheim, gebeurtenis-ID of afleverings-ID toe. Behandel de volledige bestemmings-URL als een toegangsgegeven, maak deze niet openbaar en neem een niet te raden token op in de URL als de ontvangende dienst dat ondersteunt. Als je een stabiel, machineleesbaar gebeurtenisschema of ondertekende aflevering nodig hebt, gebruik de webhook dan als melding van een wijziging en haal de actuele records op via de geauthenticeerde Gebruikers-API.

<!-- translation-section: payload-formats -->

### Payloadformaten

Webhookpayloads zijn berichten die zijn opgemaakt voor weergave in chatdiensten. Het zijn geen volledige geserialiseerde Loomio-records. Links in het bericht verwijzen naar de betreffende Loomio-inhoud; een integratie kan vervolgens de Gebruikers-API gebruiken als deze gestructureerde gegevens over de actuele toestand nodig heeft.

| Integratieformaat | Belangrijkste JSON-velden |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, beperkt tot ongeveer 1.900 tekens |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Het algemene Markdown-formaat verstuurt bijvoorbeeld een berichtinhoud met deze structuur:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

De exacte berichttekst hangt af van de gebeurtenis, de taalinstelling van de groep, de instelling om alleen de melding te versturen en de Loomio-versie. Ontvangende diensten moeten uitgaan van de gedocumenteerde velden op het hoogste niveau van het gekozen formaat, in plaats van de formulering van zinnen te ontleden.

<!-- translation-section: search -->

## Zoeken

Zoek discussies, reacties, peilingen, stemmen en conclusies die zichtbaar zijn voor de gebruiker van de API-sleutel. De zoekresultaten bevatten openbare inhoud, ook als de gebruiker geen lid is van de bijbehorende groep; voor privé-inhoud blijven de normale zichtbaarheidsregels voor topics gelden.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `query` | Zoektekst. Exacte en benaderende overeenkomsten worden ondersteund |
| `group_id` | Beperk de zoekresultaten tot één zichtbare groep |
| `org_id` | Beperk de zoekresultaten tot een zichtbare hoofdgroep en de zichtbare subgroepen daarvan. Gebruik `0` voor directe discussies |
| `type` | Beperk de zoekresultaten tot één type: `Discussion`, `Comment`, `Poll`, `Stance` of `Outcome` |
| `types` | Door komma's gescheiden lijst van resultaattypen |
| `tag` | Beperk de zoekresultaten tot topics met dit label |
| `author_id` | Beperk de zoekresultaten tot inhoud van één auteur. Zonder `query` wordt de recente zichtbare activiteit van die auteur teruggegeven |
| `order` | Stel in op `authored_at_desc` om overeenkomende inhoud te sorteren op het tijdstip waarop deze is geschreven |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Het antwoord bevat een `search_results`-array. Elk zoekresultaat identificeert het overeenkomende record en de zichtbare context ervan met onder andere de velden `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` en `tags`. Velden die niet van toepassing zijn op een zoekresultaat, zijn `null`.

<!-- translation-section: participation-report -->

## Deelnameverslag

Geef dezelfde samengevoegde deelnamegegevens terug die Loomio gebruikt voor het deelnameverslag.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `section` | Onderdeel van het verslag: `base`, `users` of `countries`. Gebruik `users` voor activiteit per persoon |
| `group_scope` | `custom` of `my`. De oude waarde `all` wordt behandeld als `my`, omdat sleutels voor de Gebruikers-API nooit toegang tot de hele instantie krijgen |
| `group_ids` | Door komma's gescheiden groeps-ID's wanneer `group_scope=custom`. ID's van groepen waarvan de API-gebruiker geen lid is, worden genegeerd |
| `start_month` | Eerste maand die wordt opgenomen, in het formaat `YYYY-MM`; standaard 12 maanden geleden |
| `end_month` | Laatste maand die wordt opgenomen, in het formaat `YYYY-MM`; standaard de huidige maand |
| `interval` | Interval voor het onderdeel `base`: `day`, `week`, `month` of `year` |
| `member_type` | Stel in op `delegate` met `section=users` om alleen huidige afgevaardigden terug te geven |

Iemand is een afgevaardigde als die persoon in minstens één geselecteerde groep een actief lidmaatschap als afgevaardigde heeft. De aantallen voor die persoon worden over alle geselecteerde groepen samengevoegd. Rijen voor afgevaardigden worden ook teruggegeven als alle activiteitsaantallen nul zijn. De aantallen omvatten threads, reacties, peilingen, stemmen, conclusies en emoji-reacties; het zijn geen deelnamepercentages voor stemmen. Gebruikersrijen bevatten ook aantallen verstrekte, uitgebrachte en gemiste stembiljetten waarbij de identiteit van de stemmer bekend is. Anonieme peilingen worden uitgesloten van alle stemaantallen per persoon. `all_votes_cast` is alleen waar als er minstens één stembiljet is verstrekt en elk verstrekt stembiljet is uitgebracht.

De API past dezelfde zichtbaarheidsregels voor groepen toe als het verslag in de applicatie. Een API-sleutel van een gebruiker kan geen verslaggegevens beschikbaar maken uit groepen waartoe die gebruiker geen toegang heeft.

<!-- translation-section: example -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

De `users`-array bevat volledige activiteitsrijen:

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

Maak een discussie aan als de gebruiker van de API-sleutel.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Groep waarin de thread komt te staan |
| `title` | Titel van de thread, verplicht |
| `description` | Context voor de thread, optioneel |
| `description_format` | `md` of `html`, optioneel, standaard `md` |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding over de nieuwe thread |
| `recipient_user_ids` | Array van gebruikers-ID's van mensen die een melding of uitnodiging voor de thread moeten krijgen |
| `recipient_emails` | Array van e-mailadressen van mensen die je wilt uitnodigen voor de thread |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |

<!-- translation-section: example-2 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Discussie ophalen

Haal een discussie op met het discussie-ID, een geheel getal, of de sleutel, een tekenreeks.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Discussies weergeven

Geef de discussies in een groep weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Bij een openbaar zichtbare groep kan iemand die geen lid is de openbare discussies weergeven; privédiscussies blijven alleen toegankelijk voor gebruikers die ze in Loomio kunnen lezen.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan je de discussies wilt weergeven |
| `status` | Tekenreeks, optioneel, standaard `open`. Waarden: `open`, `closed`, `all` |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records om over te slaan bij paginering |

Voor compatibiliteit met oudere integraties worden `per` en `from` geaccepteerd als aliassen voor `limit` en `offset`. Ze blijven werken.

<!-- translation-section: example-4 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Threads weergeven

Geef de discussie- en peilingthreads weer die zichtbaar zijn voor de gebruiker van de API-sleutel, gesorteerd op meest recente activiteit. Het ID van een thread is het bijbehorende `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records om over te slaan bij paginering |

<!-- translation-section: example-5 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Thread lezen

Lees een thread, de bijbehorende geordende stroom van gebeurtenissen of het volledige zichtbare Markdown-document.

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

Het endpoint `items` retourneert de geordende stroom van gebeurtenissen, inclusief zichtbare reacties, peilingen, stemmen en conclusies. Het endpoint `markdown` retourneert de volledige zichtbare thread als één Markdown-document. Redenen bij stemmen worden alleen opgenomen wanneer ze zichtbaar zijn voor de gebruiker van de API-sleutel.

Alle thread-endpoints handhaven dezelfde rechten als de Loomio-interface. De API-sleutel geeft geen toegang tot een thread die de gebruiker normaal gesproken niet kan openen.

<!-- translation-section: edit-discussion -->

## Discussie bewerken

Bewerk een discussie als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet die discussie mogen bewerken.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `title` | Bijgewerkte titel |
| `description` | Bijgewerkte context |
| `description_format` | `md` of `html`, optioneel, standaard `md` |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding over de bewerking |
| `recipient_user_ids` | Array van gebruikers-ID's van mensen die een melding of uitnodiging voor de thread moeten krijgen |
| `recipient_emails` | Array van e-mailadressen van mensen die je wilt uitnodigen voor de thread |
| `recipient_message` | Bericht om op te nemen in de uitnodiging per e-mail |

<!-- translation-section: example-7 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Discussie logisch verwijderen

Verwijder een discussie logisch als de gebruiker van de API-sleutel. Hiermee wordt de discussie verwijderd, maar blijft het discussierecord bewaard.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Reactie aanmaken

Maak een reactie aan in een discussie als de gebruiker van de API-sleutel.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `discussion_id` | Geheel getal, verplicht. ID van de discussie waarop je wilt reageren |
| `body` | Tekst van de reactie, verplicht tenzij een bijlage wordt meegestuurd |
| `body_format` | `md` of `html`, optioneel, standaard `md` |

<!-- translation-section: example-9 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Reactie bewerken

Bewerk een reactie als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet toestemming hebben om die reactie te bewerken.

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

## Reactie logisch verwijderen

Verwijder een reactie logisch als de gebruiker van de API-sleutel. Hiermee wordt de reactie verwijderd en de tekst verborgen, maar blijft het reactierecord bewaard.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Peiling aanmaken

Maak een peiling aan als de gebruiker van de API-sleutel.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, optioneel, standaard null. ID van de groep voor de peiling. Als `discussion_id` wordt meegegeven, wordt `group_id` genegeerd |
| `discussion_id` | Geheel getal, optioneel, standaard null. ID van de discussiethread waaraan deze peiling wordt toegevoegd |
| `title` | String, verplicht. Titel van de peiling |
| `poll_type` | String, verplicht. Waarden: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | String, optioneel. De tekst van de peiling |
| `details_format` | String, optioneel, standaard `md`. Waarden: `md` of `html` |
| `options` | Array van strings. Als `poll_type` gelijk is aan `proposal`, zijn de geldige waarden `agree`, `disagree`, `abstain`, `block`. Als `poll_type` gelijk is aan `meeting`, geef dan strings met datums of datums en tijden in ISO 8601-formaat mee. Voor alle andere peilingtypen is elke string geldig |
| `closing_at` | ISO 8601-string of null, standaard null. Voorbeeld: `2026-09-01T12:00:00Z`. Bij null is stemmen uitgeschakeld en wordt de peiling als concept beschouwd |
| `specified_voters_only` | Boolean, optioneel, standaard false. Bij true kunnen alleen opgegeven personen stemmen. Bij false wordt iedereen in de groep uitgenodigd om te stemmen |
| `hide_results` | String, optioneel, standaard `off`. Waarden: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Boolean, standaard false. Toon opties aan kiezers in willekeurige volgorde |
| `anonymous` | Boolean, optioneel, standaard false. Verberg de identiteit van kiezers |
| `recipient_audience` | `group` of null, optioneel, standaard null. Bij `group` ontvangt de hele groep een melding |
| `notify_on_closing_soon` | String, optioneel, standaard `nobody`. Waarden: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array van gebruikers-ID's van personen die een melding of uitnodiging moeten ontvangen |
| `recipient_emails` | Array van e-mailadressen van personen die worden uitgenodigd om te stemmen |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |
| `notify_recipients` | Boolean, standaard false. Voeg bij false personen toe zonder meldingen te versturen. Bij true ontvangt iedereen die via dit verzoek wordt uitgenodigd een melding per e-mail |

<!-- translation-section: example-12 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Peiling ophalen

Haal een peiling op met het peiling-ID, een geheel getal, of de sleutel, een string.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Peilingen weergeven

Geef de peilingen in een groep weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Bij een openbaar zichtbare groep kan iemand die geen lid is de openbare peilingen weergeven; privépeilingen blijven alleen toegankelijk voor gebruikers die ze in Loomio kunnen lezen. Het antwoord bevat de huidige conclusie van elke zichtbare peiling, zodat je met `status=closed` voorstellen kunt weergeven waarover een besluit is genomen.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de peilingen worden weergegeven |
| `status` | String, optioneel, standaard `active`. Waarden: `active`, `closed`, `all` |
| `limit` | Geheel getal, optioneel, standaard 50. Paginagrootte |
| `offset` | Geheel getal, optioneel, standaard 0. Startpositie voor paginering |

Voor achterwaartse compatibiliteit worden `per` en `from` geaccepteerd als aliassen voor `limit` en `offset`. Ze blijven werken.

<!-- translation-section: example-14 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Peiling bewerken

Bewerk een peiling als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet die peiling mogen bewerken.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `title` | Bijgewerkte titel |
| `details` | Bijgewerkte peilingtekst |
| `details_format` | `md` of `html`, optioneel, standaard `md` |
| `options` | Bijgewerkte optienamen. Het wijzigen van opties kan bestaande stemmen beïnvloeden, afhankelijk van de status van de peiling |
| `closing_at` | ISO 8601-string of null |
| `recipient_audience` | `group` of null. Bij `group` ontvangt de hele groep een melding |
| `recipient_user_ids` | Array van gebruikers-ID's van personen die een melding of uitnodiging moeten ontvangen |
| `recipient_emails` | Array van e-mailadressen van personen die worden uitgenodigd om te stemmen |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |

<!-- translation-section: example-15 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Peiling logisch verwijderen

Verwijder een peiling logisch als de gebruiker van de API-sleutel. Hiermee wordt de peiling als verwijderd gemarkeerd en blijft het peilingrecord bewaard.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Lidmaatschappen weergeven

Geef de lidmaatschappen weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Groepsleden kunnen de namen, ID's, titels en rollen van leden lezen. E-mailadressen worden alleen opgenomen voor het eigen account van de gebruiker van de API-sleutel of wanneer die gebruiker een groepsbeheerder is.

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

Stuur een lijst met e-mailadressen. Alle nieuwe e-mailadressen worden uitgenodigd voor de groep. Anders dan bij het weergeven van lidmaatschappen zijn voor deze handeling groepsbeheerdersrechten vereist.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de lidmaatschappen worden beheerd |
| `emails` | Array van strings, verplicht. E-mailadressen van mensen die je voor de groep wilt uitnodigen |
| `remove_absent` | Boolean. Als de waarde true is, wordt iedereen van wie het e-mailadres niet in de lijst staat uit de groep verwijderd |

<!-- translation-section: example-18 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Als je `remove_absent=1` meegeeft, worden alle leden van de groep die niet in de lijst staan uit de groep verwijderd. Let op: hiermee kun je iedereen uit jouw groep verwijderen.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Dit retourneert een object met `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
