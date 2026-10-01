---
title: Gebruikers-API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: 4ee18c463684fb94
  authentication-change: 1c1cc58becf6ad4b
  response-size-and-related-records: 735d1d35a3a343dd
  endpoint-summary: bcbb2adaa0d8bba6
  groups: 0c6e911511f85881
  list-groups: 4cba76d083f837c4
  get-a-group: a89ab5039cbf87d6
  webhooks: 9dd5e05d339046b0
  list-webhooks: 2a597bd9b8cc2f9f
  create-a-webhook: a0093855b53e33a7
  update-a-webhook: 679aedcb4557d645
  test-a-webhook-destination: 3d6bb26885185169
  delete-a-webhook: 0ed5f5de6a541adb
  event-types: 924736a753f7b43a
  http-delivery: c9950d9c8d4feeec
  payload-formats: ceda73ec7c6819ca
  search: a07534c85e54187d
  params: b533584c2391221e
  participation-report: 0ea32beca2d9a367
  params-2: 0f7b288566bd8932
  example: 1c16c9e251f642bf
  create-discussion: 435f026d774f7b53
  params-3: 88bcb6a229cf9973
  example-2: 5e091ce3ea138f88
  show-discussion: 0ee3d453e384f2d0
  example-3: 7213bc1825fa9f70
  list-discussions: 9b255219a6cbeab7
  params-4: 60b02e2a6c5ee01f
  example-4: 90831a7a0e5d51d9
  list-threads: f6765bc7c5b9a175
  params-5: d681189f9e92b838
  example-5: 2561a53159002733
  read-thread: 2d312dd9e8203112
  example-6: 1d8eea48ed40ed9a
  edit-discussion: 0e6bd48b5be190a3
  params-6: 1cc03168c99aec4e
  example-7: 8645f5f0c964cae3
  soft-delete-discussion: c1441a9398424415
  example-8: 1ae9ab816ee02158
  create-comment: 4fc3123243eeccdc
  params-7: 90c34691c2b4b03e
  example-9: a73430cb90081c6c
  edit-comment: 8d1a5c2503fbf6b2
  params-8: 61f64b501aa2a450
  example-10: 58d69d9cf77e0261
  soft-delete-comment: b97e300f1f91cc00
  example-11: 10d9d8e05700bb30
  create-poll: 7fca677223fa7120
  params-9: 6e4f67ead9637da5
  example-12: aaabda160a186876
  show-poll: 3f989a5b458e403c
  example-13: 79ef152a72b7f5ec
  list-polls: 8ac0f572460a8276
  params-10: 517a1983bc1a0042
  example-14: 41fb741925ccc590
  edit-poll: aa45ee79d0e481a4
  params-11: a61cdf2c4eec64f8
  example-15: a318836c64f997e7
  soft-delete-poll: a522d09a9016e227
  example-16: ec135b18c9ffff87
  list-memberships: bcd8f45833960e53
  params-12: f7ec3cdaf101a99c
  example-17: dc020f3f25d79a6d
  manage-memberships: 483b3c96780bdae6
  params-13: b83e4c7b662bfc47
  example-18: 2de424c95f7ab615
title_source: c23fb6526b722360
title_generated: d28b6e74f9b5edd3
---

<!-- translation-section: introduction -->

# Documentatie van de Loomio Gebruikers-API

<!-- seo-description: Gebruik de Loomio Gebruikers-API om vanuit andere software discussies, reacties, peilingen, threads en groepslidmaatschappen aan te maken en te beheren. -->

`/api/b2` is de gebruikersgerichte API voor integraties met Loomio. Deze gebruikt de API-sleutel van een gebruikersaccount en voert elke actie uit als die gebruiker.

Groepsacties gebruiken de lidmaatschappen en groepsrechten van de gebruiker van de API-sleutel. De status van instantiebeheerder geeft een API-sleutel geen extra toegang tot groepen of inhoud; gebruik de Server-API voor beheer op instantieniveau.

Gebruik de API-sleutel van het Loomio-gebruikersaccount dat de acties zal uitvoeren. Een apart botaccount is handig wanneer een integratie geen uitnodigingen voor peilingen of meldingen moet ontvangen.

Ingelogde gebruikers kunnen hun API-sleutel en groeps-ID's vinden op de [pagina voor API-toegang](/profile/api_access).

Stuur de API-sleutel mee in een `Authorization: Bearer`-header. API-sleutels in querystrings worden geweigerd omdat URL's kunnen worden vastgelegd door proxy's en in toegangslogboeken.

<!-- translation-section: authentication-change -->

### Wijziging in authenticatie

De API-sleutel werd eerder geaccepteerd als URL-parameter `api_key`. Verzoeken met `?api_key=YOUR_API_KEY` werken niet meer. Gebruik in plaats daarvan de HTTP-header `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

De voorbeelden gebruiken `YOUR_API_KEY`, groeps-ID `123` en `https://www.loomio.com/`. Vervang deze door jouw API-sleutel, groeps-ID en de URL van jouw Loomio-installatie.

<!-- translation-section: response-size-and-related-records -->

## Omvang van antwoorden en gerelateerde records

Antwoorden van de Gebruikers-API gebruiken een samengesteld formaat: de primaire records worden aangevuld met gerelateerde records zoals topics, groepen, gebruikers, peilingen en emoji-reacties. Hiermee kan een client vanuit één verzoek een lokale recordopslag vullen, maar het antwoord kan meer gegevens bevatten dan een eenvoudige integratie nodig heeft.

Geef `compact=1` mee om omvangrijke gerelateerde topics, groepen, hoofdgroepen, lidmaatschappen, emoji-reacties, labels en vertalingen weg te laten. Primaire records en de gerelateerde records die nodig zijn om hun inhoud te interpreteren blijven aanwezig.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Voor directe controle geef je `exclude_types` mee met recordtypen in het enkelvoud, gescheiden door spaties. Zo laat `exclude_types=group reaction` gerelateerde groepen en emoji-reacties weg. Veelgebruikte waarden zijn `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` en `topic_item`. Uitsluitingen gelden voor gerelateerde records, niet voor de primaire resource die via het endpoint wordt opgevraagd.

Antwoorden met collecties bevatten `meta.total` wanneer een exacte omvang van de collectie is gedefinieerd. Het totaal wordt berekend voordat `limit` en `offset` worden toegepast. Endpoints zoals zoeken, die bewust een begrensde verzameling resultaten teruggeven, laten `meta.total` weg in plaats van `null` terug te geven.

<!-- translation-section: endpoint-summary -->

## Overzicht van endpoints

| Methode | Endpoint | Doel |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Geef de groepen van de gebruiker van de API-sleutel weer |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Haal een zichtbare groep op |
| `GET` | `/api/b2/reports` | Genereer een participatierapport |
| `GET` | `/api/b2/search` | Doorzoek zichtbare discussies, reacties, peilingen, stemmen en conclusies |
| `POST` | `/api/b2/discussions` | Maak een discussie aan |
| `GET` | `/api/b2/discussions/:id` | Haal een discussie op |
| `GET` | `/api/b2/discussions` | Geef discussies in een groep weer |
| `PATCH` | `/api/b2/discussions/:id` | Bewerk een discussie |
| `DELETE` | `/api/b2/discussions/:id` | Verwijder een discussie met behoud van het record |
| `GET` | `/api/b2/threads` | Geef zichtbare discussiethreads en zelfstandige peilingthreads weer |
| `GET` | `/api/b2/threads/:topic_id` | Haal een thread op |
| `GET` | `/api/b2/threads/:topic_id/items` | Haal de geordende items in een thread op |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Haal een volledige thread op als Markdown |
| `POST` | `/api/b2/comments` | Maak een reactie of antwoord aan |
| `PATCH` | `/api/b2/comments/:id` | Bewerk een reactie |
| `DELETE` | `/api/b2/comments/:id` | Verwijder een reactie met behoud van het record |
| `POST` | `/api/b2/polls` | Maak een peiling aan |
| `GET` | `/api/b2/polls/:id` | Haal een peiling op |
| `GET` | `/api/b2/polls` | Geef peilingen in een groep weer |
| `PATCH` | `/api/b2/polls/:id` | Bewerk een peiling |
| `DELETE` | `/api/b2/polls/:id` | Verwijder een peiling met behoud van het record |
| `GET` | `/api/b2/memberships` | Geef de lidmaatschappen van een groep weer |
| `POST` | `/api/b2/memberships` | Voeg leden toe en verwijder eventueel leden die niet in de lijst staan |
| `GET` | `/api/b2/chatbots` | Geef de chatintegraties en webhooks van een groep weer |
| `POST` | `/api/b2/chatbots` | Maak een chatintegratie of webhook aan |
| `PATCH` | `/api/b2/chatbots/:id` | Werk een chatintegratie of webhook bij |
| `DELETE` | `/api/b2/chatbots/:id` | Verwijder een chatintegratie of webhook |
| `POST` | `/api/b2/chatbots/check` | Stuur een verbindingstest voor een webhook |

<!-- translation-section: groups -->

## Groepen

<!-- translation-section: list-groups -->

### Groepen weergeven

Geef de groepen terug waarin de gebruiker van de API-sleutel een actief lidmaatschap heeft.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Het antwoord bevat alle overeenkomende records in een `groups`-array zonder paginering. Deze bevat hoofdgroepen en subgroepen, ook groepen waarvan het abonnement momenteel niet actief is. Controleer het veld `enabled` wanneer een integratie alleen met ingeschakelde groepen moet werken.

Belangrijke groepsvelden zijn:

| Veld | Beschrijving |
| --- | --- |
| `id` | Numerieke groeps-ID die door andere endpoints van de Gebruikers-API wordt gebruikt |
| `key` | Stabiele korte sleutel die in Loomio-URL's wordt gebruikt |
| `handle` | Leesbare identificatienaam van de groep |
| `name` | Groepsnaam |
| `full_name` | Groepsnaam inclusief de context van de hoofdgroep |
| `parent_id` | Numerieke ID van de hoofdgroep voor een subgroep, anders `null` |
| `enabled` | Of de groep en het abonnement actief zijn |
| `memberships_count` | Aantal actieve lidmaatschappen en lidmaatschappen in afwachting van acceptatie |
| `accepted_memberships_count` | Aantal geaccepteerde lidmaatschappen |
| `pending_memberships_count` | Aantal uitnodigingen in afwachting van acceptatie |
| `admin_memberships_count` | Aantal groepsbeheerders |
| `delegates_count` | Aantal afgevaardigden |
| `discussions_count` | Aantal discussies rechtstreeks in de groep |
| `polls_count` | Aantal peilingen rechtstreeks in de groep |
| `subgroups_count` | Aantal subgroepen |

Het antwoord kan aanvullende groepsinstellingen, gerelateerde records van hoofdgroepen en de lidmaatschappen van de API-gebruiker bevatten. Clients moeten velden die ze niet gebruiken negeren.

<!-- translation-section: get-a-group -->

### Een groep ophalen

Geef één groep terug die zichtbaar is voor de gebruiker van de API-sleutel.

`GET /api/b2/groups/:id_or_key_or_handle`

De identificatie kan de numerieke ID, sleutel of identificatienaam van de groep zijn.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Het antwoord bevat de groep in de `groups`-array en gebruikt dezelfde velden als het endpoint voor het weergeven van groepen. Een verzoek voor een groep waartoe de gebruiker van de API-sleutel geen toegang heeft, geeft een foutmelding over toegangsrechten terug.

<!-- translation-section: webhooks -->

## Webhooks

De Gebruikers-API werkt op basis van verzoeken: een integratie roept Loomio aan wanneer deze gegevens wil lezen of wijzigen. Een groepswebhook zorgt voor het versturen in de andere richting. Loomio stuurt geselecteerde groepsgebeurtenissen naar jouw endpoint zodra ze plaatsvinden, zodat een integratie niet herhaaldelijk de REST-API hoeft op te vragen om wijzigingen te vinden.

Webhooks worden per groep ingesteld en vereisen groepsbeheerdersrechten. Je kunt ze beheren via de Loomio-interface:

1. Open de groep.
2. Open het groepsmenu en selecteer **Chatintegraties**.
3. Voeg de integratie toe die overeenkomt met het payloadformaat dat jouw endpoint accepteert. Gebruik het Mattermost/Markdown-formaat voor een endpoint voor algemeen gebruik.
4. Voer een naam en de bestemmings-URL in.
5. Selecteer de gebeurtenissen die Loomio automatisch moet versturen.
6. Sla de integratie op en gebruik **Test verbinding** om een testbericht te sturen.

Gebruik een HTTPS-bestemming met een niet te raden URL. Loomio vereist dat de bestemming naar een openbaar adres verwijst en blokkeert verzoeken naar lokale of privénetwerkadressen.

Agents en andere integraties kunnen webhooks ook beheren via de hieronder beschreven chatbot-endpoints met Bearer-authenticatie. De resource heet `chatbots` voor compatibiliteit met de chatintegraties van Loomio, maar vertegenwoordigt ook algemene uitgaande webhooks.

<!-- translation-section: list-webhooks -->

### Webhooks weergeven

Geef de chatintegraties terug die voor een groep zijn ingesteld. De gebruiker van de API-sleutel moet beheerder van die groep zijn. Het antwoord bevat bestemmings-URL's en mag daarom niet aan gewone groepsleden worden getoond.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Het antwoord bevat een `chatbots`-array met deze velden:

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

Stuur de velden mee die moeten veranderen. De webhook kan niet naar een andere groep worden overgezet door `group_id` te wijzigen.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Een webhookbestemming testen

Stuur een testbericht dat geschikt is voor Markdown naar een bestemming, voordat of nadat je de configuratie opslaat.

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

Als je de configuratie verwijdert, worden er geen nieuwe berichten meer afgeleverd. Er wordt geen inhoud uit de Loomio-groep verwijderd.

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
| `poll_closing_soon` | Een peiling nadert de sluitingstijd |
| `poll_expired` | Een peiling bereikt de sluitingstijd |
| `poll_closed_by_user` | Iemand sluit een peiling handmatig |
| `poll_reopened` | Een peiling wordt heropend |
| `outcome_created` | Een conclusie wordt gepubliceerd |
| `outcome_updated` | Een conclusie wordt bijgewerkt |
| `outcome_review_due` | Het is tijd om een conclusie te evalueren |
| `stance_created` | Een stem wordt uitgebracht |
| `stance_updated` | Een stem wordt gewijzigd |

De webhook hoort bij één groep en ontvangt de gebeurtenissen uit die groep waarop deze is geabonneerd. Mensen kunnen de integratie ook expliciet selecteren bij het delen of verzenden van bepaalde meldingen, zelfs als de bijbehorende automatische gebeurtenis niet is geselecteerd.

<!-- translation-section: http-delivery -->

### HTTP-aflevering

Loomio verstuurt een asynchrone HTTP `POST` naar de ingestelde URL met deze header:

```text
Content-Type: application/json; charset=utf-8
```

De time-out voor het verzoek is vijf seconden. Een `2xx`-antwoord, inclusief `204 No Content`, wordt als succesvol beschouwd. Webhookontvangers moeten snel reageren, langer durend werk asynchroon verwerken en dubbele afleveringen of afleveringen in een afwijkende volgorde kunnen verwerken.

Loomio voegt momenteel geen webhookhandtekening, header met een gedeeld geheim, gebeurtenis-ID of afleverings-ID toe. Behandel de volledige bestemmings-URL als een toegangsgegeven, maak deze niet openbaar en neem een niet te raden token op in de URL als de ontvangende dienst dit ondersteunt. Als je een stabiel, machineleesbaar gebeurtenisschema of ondertekende aflevering nodig hebt, gebruik de webhook dan als melding van een wijziging en haal de actuele records op via de geauthenticeerde Gebruikers-API.

<!-- translation-section: payload-formats -->

### Payloadformaten

Webhookpayloads zijn berichten bedoeld voor weergave in chatdiensten. Het zijn geen volledige geserialiseerde Loomio-records. Links in het bericht verwijzen naar de betreffende Loomio-inhoud; een integratie kan vervolgens de Gebruikers-API gebruiken als deze de actuele toestand in een gestructureerd formaat nodig heeft.

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

De precieze berichttekst hangt af van de gebeurtenis, de taalinstelling van de groep, de instelling om alleen de melding te verzenden en de Loomio-versie. Ontvangers moeten de gedocumenteerde velden op het hoogste niveau van het gekozen formaat gebruiken, in plaats van de formulering van zinnen te ontleden.

<!-- translation-section: search -->

## Zoeken

Zoek discussies, reacties, peilingen, stemmen en conclusies die zichtbaar zijn voor de gebruiker van de API-sleutel. Het zoekresultaat bevat ook openbare inhoud als de gebruiker geen lid is van de bijbehorende groep; voor privé-inhoud blijven de normale zichtbaarheidsregels voor topics gelden.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `query` | Zoektekst. Exacte en benaderende overeenkomsten worden ondersteund |
| `group_id` | Beperk het zoekresultaat tot één zichtbare groep |
| `org_id` | Beperk het zoekresultaat tot een zichtbare hoofdgroep en de zichtbare subgroepen daarvan. Gebruik `0` voor directe discussies |
| `type` | Beperk het zoekresultaat tot één type: `Discussion`, `Comment`, `Poll`, `Stance` of `Outcome` |
| `types` | Door komma's gescheiden lijst van resultaattypen |
| `tag` | Beperk het zoekresultaat tot topics met dit label |
| `author_id` | Beperk het zoekresultaat tot inhoud van één auteur. Zonder `query` wordt de recente zichtbare activiteit van die auteur geretourneerd |
| `order` | Stel in op `authored_at_desc` om overeenkomende inhoud te sorteren op het tijdstip waarop deze is geschreven |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Het antwoord bevat een `search_results`-array. Elk zoekresultaat identificeert het overeenkomende record en de zichtbare context ervan met velden zoals `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` en `tags`. Velden die niet van toepassing zijn op een zoekresultaat zijn `null`.

<!-- translation-section: participation-report -->

## Deelnameverslag

Haal dezelfde samengevoegde deelnamegegevens op die het deelnameverslag van Loomio gebruikt.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `section` | Onderdeel van het verslag: `base`, `users` of `countries`. Gebruik `users` voor activiteit per persoon |
| `group_scope` | `custom` of `my`. De verouderde waarde `all` wordt behandeld als `my`, omdat sleutels voor de Gebruikers-API nooit toegang tot de volledige installatie krijgen |
| `group_ids` | Door komma's gescheiden groeps-ID's wanneer `group_scope=custom`. ID's van groepen waarvan de API-gebruiker geen lid is, worden genegeerd |
| `start_month` | Eerste maand om op te nemen, in het formaat `YYYY-MM`; standaard 12 maanden geleden |
| `end_month` | Laatste maand om op te nemen, in het formaat `YYYY-MM`; standaard de huidige maand |
| `interval` | Interval voor het onderdeel `base`: `day`, `week`, `month` of `year` |
| `member_type` | Stel in op `delegate` met `section=users` om alleen huidige afgevaardigden op te halen |

Iemand is een afgevaardigde als die persoon in minstens één geselecteerde groep een actief lidmaatschap als afgevaardigde heeft. De aantallen voor die persoon worden over alle geselecteerde groepen opgeteld. Rijen voor afgevaardigden worden ook geretourneerd als alle activiteitsaantallen nul zijn. De aantallen omvatten threads, reacties, peilingen, stemmen, conclusies en emoji-reacties; ze geven geen deelnamepercentages aan stemmingen weer. Gebruikersrijen bevatten ook het aantal uitgegeven, uitgebrachte en gemiste stembiljetten waarbij de identiteit bekend is. Anonieme peilingen worden uitgesloten van alle aantallen voor stemmen per persoon. `all_votes_cast` is alleen waar als er minstens één stembiljet is uitgegeven en elk uitgegeven stembiljet is uitgebracht.

De API past dezelfde zichtbaarheidsregels voor groepen toe als het verslag in Loomio. Een API-sleutel van een gebruiker kan geen verslaggegevens beschikbaar maken uit groepen waartoe die gebruiker geen toegang heeft.

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

## Een discussie aanmaken

Maak een discussie aan als de gebruiker van de API-sleutel.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Groep waarin de thread komt |
| `title` | Titel van de thread, verplicht |
| `description` | Context voor de thread, optioneel |
| `description_format` | `md` of `html`, optioneel, standaard `md` |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding over de nieuwe thread |
| `recipient_user_ids` | Array van gebruikers-ID's om een melding te sturen of uit te nodigen voor de thread |
| `recipient_emails` | Array van e-mailadressen van mensen om uit te nodigen voor de thread |
| `recipient_message` | Bericht om op te nemen in de uitnodiging per e-mail |

<!-- translation-section: example-2 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Discussie ophalen

Haal een discussie op met de discussie-ID (een geheel getal) of de sleutel (een tekenreeks).

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
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records dat je overslaat bij paginering |

Voor compatibiliteit met oudere integraties worden `per` en `from` geaccepteerd als aliassen voor `limit` en `offset`. Ze blijven werken.

<!-- translation-section: example-4 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Threads weergeven

Geef de discussiethreads en peilingthreads weer die zichtbaar zijn voor de gebruiker van de API-sleutel, gesorteerd op meest recente activiteit. De ID van een thread is de `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records dat je overslaat bij paginering |

<!-- translation-section: example-5 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Thread lezen

Lees een thread, de geordende stroom van gebeurtenissen ervan of het volledige zichtbare Markdown-document.

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

Het endpoint `items` geeft de geordende stroom van gebeurtenissen terug, inclusief zichtbare reacties, peilingen, stemmen en conclusies. Het endpoint `markdown` geeft de volledige zichtbare thread terug als één Markdown-document. Redenen bij stemmen worden alleen opgenomen als ze zichtbaar zijn voor de gebruiker van de API-sleutel.

Alle endpoints voor threads passen dezelfde toegangsrechten toe als de Loomio-interface. De API-sleutel geeft geen toegang tot een thread die de gebruiker normaal niet kan openen.

<!-- translation-section: edit-discussion -->

## Discussie bewerken

Bewerk een discussie als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet toestemming hebben om die discussie te bewerken.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `title` | Bijgewerkte titel |
| `description` | Bijgewerkte context |
| `description_format` | `md` of `html`, optioneel, standaard `md` |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding over de wijziging |
| `recipient_user_ids` | Array van gebruikers-ID's van mensen die je een melding wilt sturen of wilt uitnodigen voor de thread |
| `recipient_emails` | Array van e-mailadressen van mensen die je wilt uitnodigen voor de thread |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |

<!-- translation-section: example-7 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Discussie verwijderen met behoud van het record

Verwijder een discussie als de gebruiker van de API-sleutel. De discussie wordt verwijderd, maar het discussierecord blijft bewaard.

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

Bewerk een reactie als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet die reactie mogen bewerken.

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

## Reactie verwijderen met behoud van het record

Verwijder een reactie als de gebruiker van de API-sleutel. De reactie wordt verwijderd en de tekst wordt verborgen, maar het reactierecord blijft bewaard.

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
| `discussion_id` | Geheel getal, optioneel, standaard null. ID van de discussiethread waaraan je deze peiling wilt toevoegen |
| `title` | String, verplicht. Titel van de peiling |
| `poll_type` | String, verplicht. Waarden: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | String, optioneel. De hoofdtekst van de peiling |
| `details_format` | String, optioneel, standaard `md`. Waarden: `md` of `html` |
| `options` | Array van strings. Als `poll_type` gelijk is aan `proposal`, zijn de geldige waarden `agree`, `disagree`, `abstain`, `block`. Als `poll_type` gelijk is aan `meeting`, geef dan datums of datums met tijden mee als strings in ISO 8601-formaat. Voor alle andere peilingtypen is elke string geldig |
| `closing_at` | String in ISO 8601-formaat of null, standaard null. Voorbeeld: `2026-09-01T12:00:00Z`. Bij null is stemmen uitgeschakeld en wordt de peiling als een concept beschouwd |
| `specified_voters_only` | Boolean, optioneel, standaard false. Bij true kunnen alleen de opgegeven personen stemmen. Bij false wordt iedereen in de groep uitgenodigd om te stemmen |
| `hide_results` | String, optioneel, standaard `off`. Waarden: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Boolean, standaard false. Toon opties aan kiezers in willekeurige volgorde |
| `anonymous` | Boolean, optioneel, standaard false. Verberg de identiteit van kiezers |
| `recipient_audience` | `group` of null, optioneel, standaard null. Bij `group` krijgt de hele groep een melding |
| `notify_on_closing_soon` | String, optioneel, standaard `nobody`. Waarden: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array van gebruikers-ID's van personen die je een melding wilt sturen of wilt uitnodigen |
| `recipient_emails` | Array van e-mailadressen van personen die je wilt uitnodigen om te stemmen |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |
| `notify_recipients` | Boolean, standaard false. Bij false worden personen toegevoegd zonder meldingen te versturen. Bij true krijgt iedereen die via dit verzoek wordt uitgenodigd een melding per e-mail |

<!-- translation-section: example-12 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Peiling ophalen

Haal een peiling op met de peiling-ID, een geheel getal, of de sleutel, een string.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Peilingen weergeven

Geef de peilingen in een groep weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Bij een openbaar zichtbare groep kan iemand die geen lid is de openbare peilingen weergeven; besloten peilingen blijven beperkt tot gebruikers die ze in Loomio kunnen lezen. De respons bevat de huidige conclusie van elke zichtbare peiling, zodat je met `status=closed` voorstellen kunt weergeven waarover een besluit is genomen.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan je de peilingen wilt weergeven |
| `status` | String, optioneel, standaard `active`. Waarden: `active`, `closed`, `all` |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records dat wordt overgeslagen bij paginering |

Voor compatibiliteit met oudere integraties worden `per` en `from` geaccepteerd als aliassen voor `limit` en `offset`. Ze blijven werken.

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
| `details` | Bijgewerkte peilingdetails |
| `details_format` | `md` of `html`, optioneel, standaard `md` |
| `options` | Bijgewerkte optienamen. Het wijzigen van opties kan bestaande stemmen beïnvloeden, afhankelijk van de status van de peiling |
| `closing_at` | String in ISO 8601-formaat of null |
| `recipient_audience` | `group` of null. Bij `group` krijgt de hele groep een melding |
| `recipient_user_ids` | Array van gebruikers-ID's van personen die je een melding wilt sturen of wilt uitnodigen |
| `recipient_emails` | Array van e-mailadressen van personen die je wilt uitnodigen om te stemmen |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |

<!-- translation-section: example-15 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Peiling voorlopig verwijderen

Verwijder een peiling voorlopig als de gebruiker van de API-sleutel. De peiling wordt als verwijderd gemarkeerd en het peilingrecord blijft behouden.

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

Stuur een lijst met e-mailadressen. Alle nieuwe e-mailadressen ontvangen een uitnodiging voor de groep. Anders dan bij het weergeven van lidmaatschappen heb je voor deze handeling groepsbeheerdersrechten nodig.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de lidmaatschappen worden beheerd |
| `emails` | Array van strings, verplicht. E-mailadressen van mensen die je voor de groep wilt uitnodigen |
| `remove_absent` | Boolean. Indien true, verwijder iedereen uit de groep van wie het e-mailadres niet in de lijst staat |

<!-- translation-section: example-18 -->

### Voorbeeld

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Als je `remove_absent=1` meegeeft, worden alle leden van de groep die niet in de lijst staan uit de groep verwijderd. Let op: je kunt hiermee iedereen uit jouw groep verwijderen.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Dit retourneert een object met `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
