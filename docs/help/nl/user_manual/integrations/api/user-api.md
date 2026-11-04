---
title: Gebruikers-API
source_revision: 81fbad246f674a34694bb2ebfc8416dd04e46ee6
source_file: docs/help/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-28'
sections:
  introduction: 68d638b236cac8c3
  response-size-and-related-records: 6f8cf57b45766ad1
  endpoint-summary: faaeafa590fb56e0
  groups: 0473f1f7fb78f074
  list-groups: 9aef26f9b926766b
  get-a-group: 05fd7cc3b212e7e1
  webhooks: f65fa289f8c1b808
  list-webhooks: fa6555a40e1c4929
  create-a-webhook: 82f92d8c0291ebba
  update-a-webhook: 7e838aa6eba73663
  test-a-webhook-destination: bceeb98f6e8c0000
  delete-a-webhook: 36bb783e464646d0
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: 9f562d745e3eb6b2
  params: 9fa99390aca5fcce
  participation-report: 2d11a398e2293ea4
  params-2: 464322ffc1ac56e5
  example: 7cab9083deb72c59
  create-discussion: 560273365cd6c232
  params-3: 657d582c89333097
  example-2: 71b3da6ca440fc97
  show-discussion: e4c59f833a2e0f0e
  example-3: 2371364611978a4d
  list-discussions: 70edb4a95bf5cafd
  params-4: dcebc294fbb9d837
  example-4: 62b76a3e8ccd9d3f
  list-threads: 46509be0004f5b26
  params-5: 79b1cefac558effc
  example-5: 785a417a6afa1b29
  read-thread: d7b366d09189eeaf
  example-6: 13abd928820aa15e
  edit-discussion: 9bee023a69bdff84
  params-6: b819796d34354623
  example-7: a98e95cf6bec9f7d
  soft-delete-discussion: 97396a318d1c74a2
  example-8: e92d4004513fc701
  create-comment: a3c290a9028f0f28
  params-7: 5ad8ede0919c5f47
  example-9: a13b59af4b411c26
  edit-comment: fd9b7963e483d2a1
  params-8: 288331c60f3c9b28
  example-10: 48c0def4c835d801
  soft-delete-comment: be989b770bd2025a
  example-11: e9019f5c028e3632
  create-poll: f339b99e95def65f
  params-9: 1c63b4ef4047f3c3
  example-12: 58ea197b72a8bd0f
  show-poll: 40b4370bcac536e5
  example-13: 6e74d6164d61fd19
  list-polls: e52282b2b9fe775b
  params-10: e68e8cf62b21488d
  example-14: cda8994926bc7002
  edit-poll: b2c8cd57e7dea231
  params-11: 70b594511872194a
  example-15: fda29e1741869e22
  soft-delete-poll: 740d74b8f48adfd8
  example-16: aa8016ff2c0dcd5d
  list-memberships: 769573d5f0f4a077
  params-12: decaff0790566fb0
  example-17: 213d79e474d7ab1d
  manage-memberships: c492589da7e249c8
  params-13: 771b5338a4ba3d0b
  example-18: bacb90328233ce5b
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
  request-bodies: 0ec99fc25454f511
  poll-many-options: 54f4ab737df476d9
  poll-detailed-options: 1df1348a129c3991
  edit-poll-detailed-options: 2be9b78ff51be3ec
generated:
  introduction: f3d8568aa2fca7db
  response-size-and-related-records: 5e95efc7c968e8da
  endpoint-summary: '097123bbd3b2f095'
  groups: 0c6e911511f85881
  list-groups: 61cb18ea42378d08
  get-a-group: aabf872e1851a741
  webhooks: 0fd0f939a97c637b
  list-webhooks: f90cd75d625b0219
  create-a-webhook: 2b9e6be68ee46469
  update-a-webhook: faaab569dca58dc8
  test-a-webhook-destination: e99cd4ffd8c1b4c3
  delete-a-webhook: ed1c594e15bb8a7d
  event-types: b608c72c1d76334c
  http-delivery: 505eb8000572c4db
  payload-formats: 142420a88cc51ef2
  search: 81023b63f64596f9
  params: 9a3b53170a4c9f48
  participation-report: 0a4e67a57e683733
  params-2: 8987c69b0bdc74d1
  example: c637922b7b536bd5
  create-discussion: ac598fb49d27d351
  params-3: f7abfe69c4808958
  example-2: b94a2e65f650fc46
  show-discussion: d6f67b0b5e6c9c27
  example-3: 60b9a836a3a66f75
  list-discussions: 76087c0e7bbfb6a0
  params-4: 374d23cec3778c1e
  example-4: 3f2847f1734b6bc0
  list-threads: 6a50dc9eb367e8b1
  params-5: 903b89e13556c636
  example-5: f3a9b40bbe8ef72f
  read-thread: 2de2600792d054e1
  example-6: 5d31c34f3611a6c4
  edit-discussion: 100b12cab5727da8
  params-6: bdd29e58b4f36acd
  example-7: c6200d389986ac75
  soft-delete-discussion: '090a3b84702549cc'
  example-8: fc830c1bcfd26f53
  create-comment: d3c0caad70385be9
  params-7: 1fb3e2da130d8ea1
  example-9: 5d210ac8ee2a7b97
  edit-comment: ff99259b7456acc3
  params-8: 67c8fed5b19954b1
  example-10: 89301b376f1fb08d
  soft-delete-comment: d4b3146c678545d9
  example-11: 8215af2016765047
  create-poll: b5ee128d314f1163
  params-9: 72206bef7eeb111b
  example-12: 1e6a6817c4dcbc48
  show-poll: a920e725b0dd4a54
  example-13: b1a654227f638c2c
  list-polls: f3169fd07a5efa26
  params-10: 3fa33e4f881d81ed
  example-14: 564e2b68fc9bca98
  edit-poll: f4620cdf3b9c2f3e
  params-11: 78ae7f0547c1fb81
  example-15: c81c098fc82447c0
  soft-delete-poll: f971f5e9c9fe698e
  example-16: a0f9fb190fadfe4e
  list-memberships: 5f9c30f3d35a4ba8
  params-12: d46b97f01c9cf25f
  example-17: 970ad727179904d7
  manage-memberships: 996154cffc8b283c
  params-13: a4f101b58edf371b
  example-18: 6719a236ffc5cfcd
  pagination: bdde9f63c57d4c3e
  comments: c7440d8d45e22718
  discussions: a3e8b977dbe6ee66
  memberships: 19b391ee469950e2
  polls: 53d53a20a696adf2
  threads: 19bc02fc1c26317b
  request-bodies: 70722ea4a3d5d3c6
  poll-many-options: 9a7e0d5e9314f386
  poll-detailed-options: 163dfe901aa4202b
  edit-poll-detailed-options: 260b4d4491740b12
title_source: c23fb6526b722360
title_generated: d28b6e74f9b5edd3
---

<!-- translation-section: introduction -->

# Documentatie van de Loomio Gebruikers-API

<!-- seo-description: Gebruik de Loomio Gebruikers-API om vanuit andere software discussies, reacties, peilingen, threads en groepslidmaatschappen aan te maken en te beheren. -->

`/api/user0` is de gebruikersgerichte API voor integraties met Loomio. Deze gebruikt de API-sleutel van een gebruikersaccount, en elke actie wordt uitgevoerd als die gebruiker.

Groepsbewerkingen gebruiken de lidmaatschappen en groepsrechten van de gebruiker van de API-sleutel. De status van instantiebeheerder geeft een API-sleutel geen ruimere toegang tot groepen of inhoud; gebruik de Server-API voor beheer op instantieniveau.

Gebruik de API-sleutel van het Loomio-gebruikersaccount dat de acties zal uitvoeren. Een apart botaccount is handig als een integratie geen uitnodigingen voor peilingen of meldingen moet ontvangen.

Ingelogde gebruikers kunnen hun API-sleutel en groeps-ID's vinden op de [pagina voor API-toegang](/profile/api_access).

Stuur de API-sleutel mee in een `Authorization: Bearer`-header. API-sleutels in querystrings worden geweigerd omdat URL's kunnen worden vastgelegd door proxy's en toegangslogboeken.

```text
Authorization: Bearer YOUR_API_KEY
```

De voorbeelden gebruiken `YOUR_API_KEY`, groeps-ID `123` en `https://www.loomio.com/`. Vervang deze door jouw API-sleutel, groeps-ID en de URL van jouw Loomio-installatie.

<!-- translation-section: request-bodies -->

### Requestbody's verzenden

Verzend JSON met `Content-Type: application/json`. De cURL-voorbeelden gebruiken `--json`, waarmee deze header automatisch wordt ingesteld. De endpoints voor het aanmaken en bewerken van discussies, reacties en peilingen accepteren zowel een plat object als een object dat onder de resourcenaam is genest, zoals `{"poll": {...}}`.

Verzend arrays als JSON-arrays, zoals `"options": ["foo", "bar"]`. Als je formuliercodering gebruikt, hebben arrays veldnamen met vierkante haken nodig, zoals `options[]=foo&options[]=bar`; bij herhaling met `options=foo&options=bar` blijft alleen de laatste waarde behouden.

Controleer na elk verzoek de HTTP-status en de responsbody. Een validatiefout geeft `422` terug met een `errors`-object; als het aanmaken van een peiling slaagt, bevat de respons de peiling in `polls` en de opties in `poll_options`.

<!-- translation-section: endpoint-summary -->

## Overzicht van endpoints

| Methode | Endpoint | Doel |
| --- | --- | --- |
| `POST` | `/api/user0/comments` | Een reactie of antwoord aanmaken |
| `PATCH` | `/api/user0/comments/:id` | Een reactie bewerken |
| `DELETE` | `/api/user0/comments/:id` | Een reactie verwijderen met behoud van het record |
| `POST` | `/api/user0/discussions` | Een discussie aanmaken |
| `GET` | `/api/user0/discussions/:id` | Een discussie ophalen |
| `GET` | `/api/user0/discussions` | Discussies in een groep opvragen |
| `PATCH` | `/api/user0/discussions/:id` | Een discussie bewerken |
| `DELETE` | `/api/user0/discussions/:id` | Een discussie verwijderen met behoud van het record |
| `GET` | `/api/user0/groups` | Groepen van de gebruiker van de API-sleutel opvragen |
| `GET` | `/api/user0/groups/:id_or_key_or_handle` | Een zichtbare groep ophalen |
| `GET` | `/api/user0/memberships` | Lidmaatschappen van een groep opvragen |
| `POST` | `/api/user0/memberships` | Leden toevoegen en desgewenst leden verwijderen die niet in de lijst staan |
| `GET` | `/api/user0/reports` | Een participatierapport genereren |
| `POST` | `/api/user0/polls` | Een peiling aanmaken |
| `GET` | `/api/user0/polls/:id` | Een peiling ophalen |
| `GET` | `/api/user0/polls` | Peilingen in een groep opvragen |
| `PATCH` | `/api/user0/polls/:id` | Een peiling bewerken |
| `DELETE` | `/api/user0/polls/:id` | Een peiling verwijderen met behoud van het record |
| `GET` | `/api/user0/search` | Zichtbare discussies, reacties, peilingen, stemmen en conclusies doorzoeken |
| `GET` | `/api/user0/threads` | Zichtbare discussiethreads en threads met zelfstandige peilingen opvragen |
| `GET` | `/api/user0/threads/:topic_id` | Een thread ophalen |
| `GET` | `/api/user0/threads/:topic_id/items` | De items in een thread in volgorde ophalen |
| `GET` | `/api/user0/threads/:topic_id/markdown` | Een volledige thread als Markdown ophalen |
| `GET` | `/api/user0/chatbots` | Chatintegraties en webhooks van een groep opvragen |
| `POST` | `/api/user0/chatbots` | Een chatintegratie of webhook aanmaken |
| `PATCH` | `/api/user0/chatbots/:id` | Een chatintegratie of webhook bijwerken |
| `DELETE` | `/api/user0/chatbots/:id` | Een chatintegratie of webhook verwijderen |
| `POST` | `/api/user0/chatbots/check` | Een verbindingstest voor een webhook versturen |

<!-- translation-section: pagination -->

## Paginering

Discussies, groepen, lidmaatschappen, peilingen, threads, threaditems en webhooks accepteren `limit` (standaard `50`) en `offset` (standaard `0`). Voor groepen, threaditems en webhooks is `limit` maximaal `500`.

Verhoog `offset` met het aantal teruggegeven primaire records om de volgende pagina op te halen. `meta.total` is het totale aantal overeenkomende records; gerelateerde records tellen niet mee voor de paginagrootte.

Participatierapporten geven alle opgevraagde gegevens terug, en zoeken geeft maximaal 20 resultaten terug. Beide ondersteunen geen paginering.

Discussies, peilingen en lidmaatschappen accepteren ook de verouderde aliassen `per` voor `limit` en `from` voor `offset`. Gebruik `limit` en `offset` voor nieuwe integraties.

<!-- translation-section: response-size-and-related-records -->

## Gerelateerde records

Responsen van de Gebruikers-API gebruiken een samengesteld formaat: de primaire records worden aangevuld met gerelateerde records zoals topics, groepen, gebruikers, peilingen en emoji-reacties. Hiermee kan een client met één verzoek een lokale recordopslag vullen, maar de respons kan meer gegevens bevatten dan een eenvoudige integratie nodig heeft.

Geef `compact=1` mee om omvangrijke gerelateerde topics, groepen, hoofdgroepen, lidmaatschappen, emoji-reacties, labels en vertalingen weg te laten. Primaire records en de gerelateerde records die nodig zijn om hun inhoud te interpreteren, blijven aanwezig.

```bash
curl 'https://www.loomio.com/api/user0/threads/123/items?compact=1' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Voor directe controle geef je `exclude_types` mee met recordtypen in het enkelvoud, gescheiden door spaties. Zo laat `exclude_types=group reaction` gerelateerde groepen en emoji-reacties weg. Veelgebruikte waarden zijn `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` en `topic_item`. Uitsluitingen gelden voor gerelateerde records, niet voor de primaire resource die via het endpoint wordt opgevraagd.

Responsen met collecties bevatten `meta.total` wanneer een exacte collectiegrootte is gedefinieerd. Het totaal wordt berekend voordat `limit` en `offset` worden toegepast. Endpoints zoals zoeken, die bewust een begrensde verzameling resultaten teruggeven, laten `meta.total` weg in plaats van `null` terug te geven.

<!-- translation-section: comments -->

## Reacties

<!-- translation-section: create-comment -->

### Reactie aanmaken

Maak een reactie aan in een discussie als de gebruiker van de API-sleutel.

`POST /api/user0/comments`

<!-- translation-section: params-7 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `discussion_id` | Geheel getal, verplicht. ID van de discussie waarop je wilt reageren |
| `body` | Tekst van de reactie, verplicht tenzij een bijlage wordt meegestuurd |
| `body_format` | `md` of `html`, optioneel, standaard `md` |

<!-- translation-section: example-9 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/comments \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "discussion_id": 123,
    "body": "example comment",
    "body_format": "md"
  }'
```

<!-- translation-section: edit-comment -->

### Reactie bewerken

Bewerk een reactie als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet toestemming hebben om die reactie te bewerken.

`PATCH /api/user0/comments/:id`

<!-- translation-section: params-8 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `body` | Bijgewerkte tekst van de reactie |
| `body_format` | `md` of `html`, optioneel, standaard `md` |

<!-- translation-section: example-10 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/comments/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "body": "updated comment",
    "body_format": "md"
  }'
```

<!-- translation-section: soft-delete-comment -->

### Reactie logisch verwijderen

Verwijder een reactie logisch als de gebruiker van de API-sleutel. Hiermee wordt de reactie verwijderd en de tekst verborgen, maar blijft het reactierecord bewaard.

`DELETE /api/user0/comments/:id`

<!-- translation-section: example-11 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/comments/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: discussions -->

## Discussies

<!-- translation-section: create-discussion -->

### Discussie aanmaken

Maak een discussie aan als de gebruiker van de API-sleutel.

`POST /api/user0/discussions`

<!-- translation-section: params-3 -->

#### Parameters

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

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/discussions \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "example thread",
    "recipient_emails": [
      "person@example.com"
    ]
  }'
```

<!-- translation-section: show-discussion -->

### Discussie ophalen

Haal een discussie op met het discussie-ID, een geheel getal, of de sleutel, een tekenreeks.

`GET /api/user0/discussions/:id`

<!-- translation-section: example-3 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/discussions/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-discussions -->

### Discussies weergeven

Geef de discussies in een groep weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Bij een openbaar zichtbare groep kan iemand die geen lid is de openbare discussies weergeven; privédiscussies blijven alleen toegankelijk voor gebruikers die ze in Loomio kunnen lezen.

`GET /api/user0/discussions`

<!-- translation-section: params-4 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan je de discussies wilt weergeven |
| `status` | Tekenreeks, optioneel, standaard `open`. Waarden: `open`, `closed`, `all` |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records om over te slaan bij paginering |

Voor compatibiliteit met oudere integraties worden `per` en `from` geaccepteerd als aliassen voor `limit` en `offset`. Ze blijven werken.

<!-- translation-section: example-4 -->

#### Voorbeeld

```bash
curl 'https://www.loomio.com/api/user0/discussions?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-discussion -->

### Discussie bewerken

Bewerk een discussie als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet die discussie mogen bewerken.

`PATCH /api/user0/discussions/:id`

<!-- translation-section: params-6 -->

#### Parameters

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

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/discussions/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated thread title",
    "description": "updated context",
    "description_format": "md"
  }'
```

<!-- translation-section: soft-delete-discussion -->

### Discussie logisch verwijderen

Verwijder een discussie logisch als de gebruiker van de API-sleutel. Hiermee wordt de discussie verwijderd, maar blijft het discussierecord bewaard.

`DELETE /api/user0/discussions/:id`

<!-- translation-section: example-8 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/discussions/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: groups -->

## Groepen

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"Aantal groepsbeheerders |\n| `delegates_count` | Aantal afgevaardigden |\n| `discussions_count` | Aantal dis","after":"Aantal groepsbeheerders |\n| `discussions_count` | Aantal dis"} -->

### Groepen opvragen

Geeft de groepen terug waarin de gebruiker van de API-sleutel een actief lidmaatschap heeft.

`GET /api/user0/groups`

| Naam | Beschrijving |
| --- | --- |
| `limit` | Geheel getal, optioneel, standaard 50, maximaal 500. Paginagrootte |
| `offset` | Geheel getal, optioneel, standaard 0. Verschuiving voor paginering |

```bash
curl 'https://www.loomio.com/api/user0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

De respons bevat een pagina met `groups`, gesorteerd op oplopende groeps-ID, met het totale aantal overeenkomende groepen in `meta.total`. Deze bevat hoofdgroepen en subgroepen, ook groepen waarvan het abonnement momenteel niet actief is. Controleer het veld `enabled` als een integratie alleen met ingeschakelde groepen moet werken.

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
| `discussions_count` | Aantal discussies rechtstreeks in de groep |
| `polls_count` | Aantal peilingen rechtstreeks in de groep |
| `subgroups_count` | Aantal subgroepen |

De respons kan aanvullende groepsinstellingen, gerelateerde records van hoofdgroepen en de lidmaatschappen van de API-gebruiker bevatten. Clients moeten velden die ze niet gebruiken negeren.

<!-- translation-section: get-a-group -->

### Een groep ophalen

Geeft één groep terug die zichtbaar is voor de gebruiker van de API-sleutel.

`GET /api/user0/groups/:id_or_key_or_handle`

De identificatie kan de numerieke ID, sleutel of identificatienaam van de groep zijn.

```bash
curl https://www.loomio.com/api/user0/groups/123 \
  -H 'Authorization: Bearer YOUR_API_KEY'

curl https://www.loomio.com/api/user0/groups/example-group \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

De respons bevat de groep in de `groups`-array en gebruikt dezelfde velden als het endpoint voor het opvragen van groepen. Een verzoek voor een groep waartoe de gebruiker van de API-sleutel geen toegang heeft, geeft een fout wegens onvoldoende rechten terug.

<!-- translation-section: memberships -->

## Lidmaatschappen

<!-- translation-section: list-memberships -->

### Lidmaatschappen weergeven

Geef de lidmaatschappen weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Groepsleden kunnen de namen, ID's, titels en rollen van leden lezen. E-mailadressen worden alleen opgenomen voor het eigen account van de gebruiker van de API-sleutel of wanneer die gebruiker een groepsbeheerder is.

`GET /api/user0/memberships`

<!-- translation-section: params-12 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de lidmaatschappen worden weergegeven |
| `limit` | Geheel getal, optioneel, standaard 50. Paginagrootte |
| `offset` | Geheel getal, optioneel, standaard 0. Verschuiving voor paginering |

Verouderd: `per` en `from` worden geaccepteerd als aliassen voor `limit` en `offset` en blijven werken.

De respons bevat een pagina met `memberships` en gerelateerde `users`. `meta.total` is het totale aantal zichtbare lidmaatschappen in de groep vóór paginering.

<!-- translation-section: example-17 -->

#### Voorbeeld

```bash
curl 'https://www.loomio.com/api/user0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: manage-memberships -->

### Lidmaatschappen beheren

Stuur een lijst met e-mailadressen. Alle nieuwe e-mailadressen worden uitgenodigd voor de groep. Anders dan bij het weergeven van lidmaatschappen zijn voor deze handeling groepsbeheerdersrechten vereist.

`POST /api/user0/memberships`

<!-- translation-section: params-13 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de lidmaatschappen worden beheerd |
| `emails` | Array van strings, verplicht. E-mailadressen van mensen die je voor de groep wilt uitnodigen |
| `remove_absent` | Boolean. Als de waarde true is, wordt iedereen van wie het e-mailadres niet in de lijst staat uit de groep verwijderd |

<!-- translation-section: example-18 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ]
  }'
```

Als je `remove_absent=1` meegeeft, worden alle leden van de groep die niet in de lijst staan uit de groep verwijderd. Let op: hiermee kun je iedereen uit jouw groep verwijderen.

```bash
curl https://www.loomio.com/api/user0/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ],
    "remove_absent": 1
  }'
```

Dit retourneert een object met `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.

<!-- translation-section: participation-report -->

## Deelnameverslag

Geef dezelfde samengevoegde deelnamegegevens terug die Loomio gebruikt voor het deelnameverslag.

`GET /api/user0/reports`

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
curl 'https://www.loomio.com/api/user0/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09' \
  -H 'Authorization: Bearer YOUR_API_KEY'
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

<!-- translation-section: polls -->

## Peilingen

<!-- translation-section: create-poll -->

### Peiling aanmaken

Maak een peiling aan als de gebruiker van de API-sleutel.

`POST /api/user0/polls`

<!-- translation-section: params-9 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, optioneel, standaard null. ID van de groep voor de peiling. Als `discussion_id` wordt meegegeven, wordt `group_id` genegeerd |
| `discussion_id` | Geheel getal, optioneel, standaard null. ID van de discussiethread waaraan deze peiling wordt toegevoegd |
| `title` | String, verplicht. Titel van de peiling |
| `poll_type` | String, verplicht. Waarden: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | String, optioneel. De tekst van de peiling |
| `details_format` | String, optioneel, standaard `md`. Waarden: `md` of `html` |
| `options` | Eenvoudige optienamen als array van strings. Gebruik voor `proposal` de waarden `agree`, `disagree`, `abstain` of `block` om de standaardlabels, pictogrammen, betekenissen en vragen te gebruiken. Geef voor `meeting` strings met datums of datums en tijden in ISO 8601-formaat mee. Geef voor andere peilingtypen optienamen mee. Gebruik voor gedetailleerde opties in plaats hiervan `poll_options_attributes` |
| `poll_options_attributes` | Alternatief voor `options`: een array van optieobjecten met namen, betekenissen, vragen, pictogrammen en volgorde. Zie [Een peiling met gedetailleerde opties aanmaken](#create-a-poll-with-detailed-options) |
| `reason_prompt` | String, optioneel. Gemeenschappelijke vraag naar de reden voor een stem, gebruikt bij peilingtypen zonder vragen per optie, zoals `poll`, `score` en `ranked_choice` |
| `stance_reason_required` | String, standaard `optional`. Waarden: `disabled`, `optional`, `required`, `required_for_disagree_or_block`, `required_for_block`. De laatste twee zijn van toepassing op de pictogrammen `disagree` en `block`. Bij anonieme peilingen zijn redenen voor stemmen uitgeschakeld |
| `closing_at` | ISO 8601-string of null, standaard null. Voorbeeld: `2026-09-01T12:00:00Z`. Bij null is stemmen uitgeschakeld en wordt de peiling als concept beschouwd |
| `specified_voters_only` | Boolean, optioneel, standaard false. Bij true kunnen alleen opgegeven personen stemmen. Bij false wordt iedereen in de groep uitgenodigd om te stemmen |
| `hide_results` | String, optioneel, standaard `off`. Waarden: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Boolean, standaard false. Toon opties aan kiezers in willekeurige volgorde |
| `anonymous` | Boolean, optioneel, standaard false. Verberg de identiteit van kiezers |
| `recipient_audience` | `group` of null, optioneel, standaard null. Bij `group` ontvangt de hele groep een melding |
| `notify_on_closing_soon` | String, optioneel, standaard `nobody`. Waarden: `nobody`, `author`, `voters_uncast`, `voters` |
| `recipient_user_ids` | Array van gebruikers-ID's van personen die een melding of uitnodiging moeten ontvangen |
| `recipient_emails` | Array van e-mailadressen van personen die worden uitgenodigd om te stemmen |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |
| `notify_recipients` | Boolean, standaard false. Voeg bij false personen toe zonder meldingen te versturen. Bij true ontvangt iedereen die via dit verzoek wordt uitgenodigd een melding per e-mail |

<!-- translation-section: example-12 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "example poll",
    "poll_type": "proposal",
    "options": [
      "agree",
      "disagree"
    ],
    "closing_at": "2026-09-01T12:00:00Z",
    "recipient_emails": [
      "person@example.com"
    ]
  }'
```

<!-- translation-section: poll-many-options -->

#### Een conceptpeiling met veel opties aanmaken

Stuur alle optienamen mee in de `options`-array. Als je `closing_at` weglaat, wordt een conceptpeiling aangemaakt waarin stemmen is uitgeschakeld; de peiling blijft zichtbaar voor personen die de thread kunnen lezen. Voeg een toekomstige `closing_at` toe wanneer je klaar bent om het stemmen te openen.

Voeg al jouw optienamen toe aan de array:

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Meeting venue",
    "poll_type": "poll",
    "options": [
      "Town hall",
      "Library",
      "Community centre"
    ]
  }'
```

<!-- translation-section: poll-detailed-options -->

#### Een peiling met gedetailleerde opties aanmaken

Gebruik `options` voor een lijst met namen, of `poll_options_attributes` wanneer elke optie een betekenis, een vraag naar de reden of een pictogram nodig heeft. Kies één formaat per verzoek. Beide formaten werken in een platte JSON-body of binnen een `poll`-object.

Elk object in `poll_options_attributes` accepteert deze velden:

| Veld | Beschrijving |
| --- | --- |
| `name` | String, verplicht voor een nieuwe optie. Het label dat aan kiezers wordt getoond |
| `meaning` | String, optioneel. Legt uit wat het kiezen van deze optie betekent |
| `prompt` | String, optioneel. Vraag naar de reden die wordt getoond wanneer deze optie wordt geselecteerd in een `proposal`, `count` of `check`. Stel voor andere peilingtypen `reason_prompt` in op de peiling |
| `icon` | String, optioneel. Gebruik voor `proposal`, `count` en `check` de waarden `agree`, `disagree`, `abstain` of `block` |
| `priority` | Geheel getal. Volgorde van de opties, beginnend bij `0`. Geef elke optie een andere prioriteit; opties voor bijeenkomsten worden in plaats daarvan op datum gesorteerd |
| `test_operator` | String of null, optioneel. Vereiste voor het stemmenaandeel: `gte` betekent ten minste, `lte` betekent niet meer dan. Stel in op null om de vereiste uit te schakelen |
| `test_percent` | Geheel getal, optioneel. Percentage voor de vereiste voor het stemmenaandeel, van `0` tot `100` |
| `test_against` | String, optioneel. `score_percent` vergelijkt het aandeel van de optie in de totale toegekende score of punten; `voter_percent` vergelijkt de kiezers van de optie met alle stemgerechtigde kiezers |
| `id` | Geheel getal. Geef mee bij het bewerken van een bestaande optie; laat weg voor een nieuwe optie |
| `_destroy` | Boolean, optioneel. Stel in op `true` en geef de `id` van een bestaande optie mee om deze te verwijderen |

Maak een voorstel aan met aangepaste optielabels en vragen:

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Should we adopt this proposal?",
    "poll_type": "proposal",
    "stance_reason_required": "optional",
    "poll_options_attributes": [
      {
        "name": "Support",
        "meaning": "I support adopting this proposal",
        "prompt": "What do you support about it?",
        "icon": "agree",
        "priority": 0
      },
      {
        "name": "Oppose",
        "meaning": "I would prefer another approach",
        "prompt": "What would you change?",
        "icon": "disagree",
        "priority": 1
      }
    ]
  }'
```

Gebruik voor een gewone peiling hetzelfde formaat voor gedetailleerde opties met een gemeenschappelijke `reason_prompt` op de peiling:

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Choose a venue",
    "poll_type": "poll",
    "reason_prompt": "Why do you prefer this venue?",
    "stance_reason_required": "optional",
    "poll_options_attributes": [
      {
        "name": "Town hall",
        "meaning": "Central, accessible venue",
        "priority": 0
      },
      {
        "name": "Library",
        "meaning": "Smaller room with no hire fee",
        "priority": 1
      }
    ]
  }'
```

In deze voorbeelden is `closing_at` weggelaten, dus stemmen blijft uitgeschakeld totdat een toekomstige sluitingsdatum is ingesteld.

<!-- translation-section: show-poll -->

### Peiling ophalen

Haal een peiling op met het peiling-ID, een geheel getal, of de sleutel, een string.

`GET /api/user0/polls/:id`

<!-- translation-section: example-13 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/polls/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-polls -->

### Peilingen weergeven

Geef de peilingen in een groep weer die zichtbaar zijn voor de gebruiker van de API-sleutel. Bij een openbaar zichtbare groep kan iemand die geen lid is de openbare peilingen weergeven; privépeilingen blijven alleen toegankelijk voor gebruikers die ze in Loomio kunnen lezen. Het antwoord bevat de huidige conclusie van elke zichtbare peiling, zodat je met `status=closed` voorstellen kunt weergeven waarover een besluit is genomen.

`GET /api/user0/polls`

<!-- translation-section: params-10 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de peilingen worden weergegeven |
| `status` | String, optioneel, standaard `active`. Waarden: `active`, `closed`, `all` |
| `limit` | Geheel getal, optioneel, standaard 50. Paginagrootte |
| `offset` | Geheel getal, optioneel, standaard 0. Startpositie voor paginering |

Voor achterwaartse compatibiliteit worden `per` en `from` geaccepteerd als aliassen voor `limit` en `offset`. Ze blijven werken.

<!-- translation-section: example-14 -->

#### Voorbeeld

```bash
curl 'https://www.loomio.com/api/user0/polls?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-poll -->

### Peiling bewerken

Bewerk een peiling als de gebruiker van de API-sleutel. Dezelfde rechten gelden als in Loomio: de gebruiker moet die peiling mogen bewerken.

`PATCH /api/user0/polls/:id`

<!-- translation-section: params-11 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `title` | Bijgewerkte titel |
| `details` | Bijgewerkte peilingtekst |
| `details_format` | `md` of `html`, optioneel, standaard `md` |
| `options` | Bijgewerkte optienamen. Het wijzigen van opties kan bestaande stemmen beïnvloeden, afhankelijk van de status van de peiling |
| `poll_options_attributes` | Alternatief voor `options`. Werk gedetailleerde optieobjecten bij op basis van `id`, voeg objecten zonder `id` toe of verwijder een optie met `id` en `_destroy: true`. Weggelaten opties blijven ongewijzigd |
| `reason_prompt` | Bijgewerkte gemeenschappelijke vraag naar de reden voor peilingtypen zonder vragen per optie |
| `stance_reason_required` | Bijgewerkte vereiste voor de reden; dezelfde waarden gelden als bij het aanmaken van een peiling |
| `closing_at` | ISO 8601-string of null |
| `recipient_audience` | `group` of null. Bij `group` ontvangt de hele groep een melding |
| `recipient_user_ids` | Array van gebruikers-ID's van personen die een melding of uitnodiging moeten ontvangen |
| `recipient_emails` | Array van e-mailadressen van personen die worden uitgenodigd om te stemmen |
| `recipient_message` | Bericht dat wordt opgenomen in de uitnodiging per e-mail |

<!-- translation-section: example-15 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated poll title",
    "details": "updated details",
    "details_format": "md"
  }'
```

<!-- translation-section: edit-poll-detailed-options -->

#### Gedetailleerde opties bewerken

Haal de optie-ID's op uit de `poll_options`-array in de respons op een aanmaak- of ophaalverzoek. Stuur alleen de velden mee die je wilt wijzigen, samen met de `id` van elke bestaande optie:

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "poll_options_attributes": [
      {
        "id": 456,
        "meaning": "Updated explanation",
        "prompt": "What would improve this proposal?"
      },
      {
        "name": "Abstain",
        "meaning": "I leave the decision to others",
        "icon": "abstain",
        "priority": 2
      }
    ]
  }'
```

Optie-ID's moeten behoren tot de peiling die je bewerkt. Voor bewerken heb je toestemming nodig om de peiling te bewerken, en gesloten peilingen kunnen niet worden bewerkt. Bij anonieme peilingen wordt de configuratie van de opties ook vastgezet nadat de eerste stem is uitgebracht.

<!-- translation-section: soft-delete-poll -->

### Peiling logisch verwijderen

Verwijder een peiling logisch als de gebruiker van de API-sleutel. Hiermee wordt de peiling als verwijderd gemarkeerd en blijft het peilingrecord bewaard.

`DELETE /api/user0/polls/:id`

<!-- translation-section: example-16 -->

#### Voorbeeld

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: search -->

## Zoeken

Zoek discussies, reacties, peilingen, stemmen en conclusies die zichtbaar zijn voor de gebruiker van de API-sleutel. De zoekresultaten bevatten openbare inhoud, ook als de gebruiker geen lid is van de bijbehorende groep; voor privé-inhoud blijven de normale zichtbaarheidsregels voor topics gelden.

`GET /api/user0/search`

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
curl 'https://www.loomio.com/api/user0/search?query=quarterly+planning&type=Discussion' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Het antwoord bevat een `search_results`-array. Elk zoekresultaat identificeert het overeenkomende record en de zichtbare context ervan met onder andere de velden `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` en `tags`. Velden die niet van toepassing zijn op een zoekresultaat, zijn `null`.

<!-- translation-section: threads -->

## Threads

<!-- translation-section: list-threads -->

### Threads weergeven

Geef de discussie- en peilingthreads weer die zichtbaar zijn voor de gebruiker van de API-sleutel, gesorteerd op meest recente activiteit. Het ID van een thread is het bijbehorende `topic_id`.

`GET /api/user0/threads`

<!-- translation-section: params-5 -->

#### Parameters

| Naam | Beschrijving |
| --- | --- |
| `limit` | Geheel getal, optioneel, standaard 50. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records om over te slaan bij paginering |

<!-- translation-section: example-5 -->

#### Voorbeeld

```bash
curl 'https://www.loomio.com/api/user0/threads?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: read-thread -->

### Thread lezen

Lees een thread, de bijbehorende geordende stroom van gebeurtenissen of het volledige zichtbare Markdown-document.

`GET /api/user0/threads/:topic_id`

`GET /api/user0/threads/:topic_id/items`

`GET /api/user0/threads/:topic_id/markdown`

Het endpoint `items` accepteert deze pagineringsparameters:

| Naam | Beschrijving |
| --- | --- |
| `limit` | Geheel getal, optioneel, standaard 50, maximaal 500. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records om over te slaan bij paginering |

<!-- translation-section: example-6 -->

#### Voorbeeld

```text
GET https://www.loomio.com/api/user0/threads/<topic_id>
GET https://www.loomio.com/api/user0/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/user0/threads/<topic_id>/markdown
```

Het endpoint `items` retourneert een pagina van de stroom van gebeurtenissen in oplopende volgorde, inclusief zichtbare reacties, peilingen, stemmen en conclusies. `meta.total` is het totale aantal items in de thread. Haal de volgende pagina's op om de volledige stroom te lezen. Het endpoint `markdown` retourneert de volledige zichtbare thread als één Markdown-document. Redenen bij stemmen worden alleen opgenomen wanneer ze zichtbaar zijn voor de gebruiker van de API-sleutel.

Alle thread-endpoints handhaven dezelfde rechten als de Loomio-interface. De API-sleutel geeft geen toegang tot een thread die de gebruiker normaal gesproken niet kan openen.

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

`GET /api/user0/chatbots?group_id=123`

| Naam | Beschrijving |
| --- | --- |
| `group_id` | Geheel getal, verplicht. ID van de groep waarvan de webhooks worden opgevraagd |
| `limit` | Geheel getal, optioneel, standaard 50, maximaal 500. Aantal records per pagina |
| `offset` | Geheel getal, optioneel, standaard 0. Aantal records om over te slaan bij paginering |

```bash
curl 'https://www.loomio.com/api/user0/chatbots?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

De respons bevat een pagina met `chatbots`, gesorteerd op oplopende integratie-ID, met het totale aantal voor de groep in `meta.total`. Elke integratie heeft deze velden:

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

`POST /api/user0/chatbots`

```bash
curl https://www.loomio.com/api/user0/chatbots \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": [
      "new_discussion",
      "new_comment",
      "poll_created",
      "outcome_created"
    ],
    "notification_only": false
  }'
```

De gebruiker van de API-sleutel moet groepsbeheerder zijn van de groep met `group_id`. Voordat de bestemming wordt opgeslagen, wordt gecontroleerd of deze een openbare URL is.

<!-- translation-section: update-a-webhook -->

### Een webhook bijwerken

`PATCH /api/user0/chatbots/:id`

Stuur alle velden mee die moeten veranderen. Je kunt de webhook niet naar een andere groep verplaatsen door `group_id` te wijzigen.

```bash
curl https://www.loomio.com/api/user0/chatbots/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "name": "Planning events",
    "event_kinds": [
      "new_discussion",
      "outcome_created"
    ]
  }'
```

<!-- translation-section: test-a-webhook-destination -->

### Een webhookbestemming testen

Stuur een testbericht dat compatibel is met Markdown naar een bestemming voordat of nadat je de configuratie opslaat.

`POST /api/user0/chatbots/check`

```bash
curl https://www.loomio.com/api/user0/chatbots/check \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "server": "https://hooks.example.org/loomio/unguessable-token"
  }'
```

<!-- translation-section: delete-a-webhook -->

### Een webhook verwijderen

`DELETE /api/user0/chatbots/:id`

```bash
curl https://www.loomio.com/api/user0/chatbots/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
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
