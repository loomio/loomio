---
title: Käyttäjän API
source_revision: aa8cf2cef8336b4d86d7200c0d66c0eb8f973256
source_file: docs/help/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-17'
sections:
  introduction: b6e6ec7463276869
  response-size-and-related-records: 8349c4d8e567a0c1
  endpoint-summary: 258f7560def524ec
  groups: 0473f1f7fb78f074
  list-groups: e94dbf27dff819ff
  get-a-group: 80912be614c0ea89
  webhooks: f65fa289f8c1b808
  list-webhooks: 6ec5700a0ac5cbc7
  create-a-webhook: 173ce08be83b4b58
  update-a-webhook: 2bf0f59f8bff06ec
  test-a-webhook-destination: 0637a17a98f20f4b
  delete-a-webhook: 6ba2c6360e4f1d2a
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: bb5a1cfc7a6179aa
  params: 1e7478b9883d2a47
  participation-report: a1798112a78390fe
  params-2: 464322ffc1ac56e5
  example: ba3f68d5b68a955b
  create-discussion: 958fc684640462a9
  params-3: 657d582c89333097
  example-2: bca512c06153265f
  show-discussion: 40102aeffe4f1286
  example-3: fe0959389ff4f2f6
  list-discussions: '09ff7f0d3a937b41'
  params-4: dcebc294fbb9d837
  example-4: dd55f55bf83d135f
  list-threads: '09f7bd670e581400'
  params-5: 79b1cefac558effc
  example-5: 1864da3b097f66d6
  read-thread: ac36d1b81c1eeed4
  example-6: 8c582a286e04ca75
  edit-discussion: 918161e7aa8f4aa6
  params-6: b819796d34354623
  example-7: 8b591051e20fa1e4
  soft-delete-discussion: c8ffe951171e6f07
  example-8: d0e726a1a20cc469
  create-comment: f95f56b81c8f22b5
  params-7: 5ad8ede0919c5f47
  example-9: 61514be87d3a8857
  edit-comment: 80322da74162d58f
  params-8: 288331c60f3c9b28
  example-10: c0aed6ea023ff3d4
  soft-delete-comment: 04baf86923c7e8f1
  example-11: 129076a53c6c4b31
  create-poll: cf62e787784a5e87
  params-9: 89465a6e2dfa6bdb
  example-12: 4397219f26129191
  show-poll: d759508986aab08c
  example-13: 01f20dba176f4f23
  list-polls: 56e5ed4ae45e5428
  params-10: e68e8cf62b21488d
  example-14: a1149e09d37d9b0a
  edit-poll: 65467ad0b431ddbf
  params-11: 70b594511872194a
  example-15: 8c4d585a050423ac
  soft-delete-poll: 61cf76310e08d7ff
  example-16: fb15cb7d90550c2f
  list-memberships: 5fab06bb8ecf1fd0
  params-12: decaff0790566fb0
  example-17: 7714e1b8d2d07999
  manage-memberships: 802d39c06674d395
  params-13: 771b5338a4ba3d0b
  example-18: a06882d9d8de45f0
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
  request-bodies: 0ec99fc25454f511
  poll-many-options: 05024e64103f7d39
  poll-detailed-options: a511f74ddaa0b6bf
  edit-poll-detailed-options: 767b869e6b9efcff
generated:
  introduction: 79b80b79cf1d4a4b
  response-size-and-related-records: 87e051571807352f
  endpoint-summary: d56aa1f4f9c17d9b
  groups: 90cb5d1f24e992a5
  list-groups: ed24a135fe9088c3
  get-a-group: 91aff341161c2394
  webhooks: e73d4cb7f83c25b4
  list-webhooks: cc239ec8179c7dae
  create-a-webhook: b66d53e367058bb1
  update-a-webhook: 79ca7d560f9b575a
  test-a-webhook-destination: 9f79169a479e5c39
  delete-a-webhook: c4873476a1f36102
  event-types: 9f9748babb039cae
  http-delivery: 2d1d6fc5d7922698
  payload-formats: d394fecd58bbed23
  search: 5ab45c77ade684bf
  params: 360ddc508f68084a
  participation-report: 55fd9e3db40b5ff0
  params-2: 3ce560e91874fccf
  example: 8fe2ca5e0ce1ef54
  create-discussion: 76d1c1380446f757
  params-3: 62a5863a1d0f1b77
  example-2: 837050d46473aebb
  show-discussion: 3b58b169ede843bc
  example-3: adf60c1c4e45b023
  list-discussions: d11f55e24d613248
  params-4: c559dee9799412e1
  example-4: 5d02cf00e2521ab0
  list-threads: 9c7cb48c4977d32e
  params-5: 396c06598fd253d1
  example-5: 36b5b93fdb139b8a
  read-thread: ee082dbdf55fba16
  example-6: a8bb273a6a26edab
  edit-discussion: 6284d36049b811e2
  params-6: 53ee13b332e1511a
  example-7: f5550a7f984a720c
  soft-delete-discussion: 13d0ce805d0d6f08
  example-8: d917c1674698606a
  create-comment: 760ffa5337bb4206
  params-7: 3e91f1a09fa4d219
  example-9: e178e288c6cd136b
  edit-comment: 05f1bb19af5ec028
  params-8: 6b81235fc1ed828d
  example-10: 28995ede3ad25270
  soft-delete-comment: 977685f913b2e21c
  example-11: ddd01401a330404b
  create-poll: 78f509019129c5b4
  params-9: 9600d6d761b44a3d
  example-12: 11a4fa1d9d300f25
  show-poll: 78e2d62ec74c6ba1
  example-13: ab17e283652db476
  list-polls: d2b002c22b7c81cd
  params-10: 5e7c92669349a80e
  example-14: f82cc8d22e1e51d8
  edit-poll: cd7a502aa1393a65
  params-11: 2747b20e45a53e6b
  example-15: 1a331a3465d68912
  soft-delete-poll: 17a19d2b4d4c6c1f
  example-16: a53303fe098ba244
  list-memberships: b4dd711e0383ef86
  params-12: e5a6d0c42a0469c1
  example-17: a6a7b048a9d4a2aa
  manage-memberships: fbffb56771ac7d19
  params-13: f370b912fd04376a
  example-18: bd796727fc28d2ce
  pagination: dc8b8a2a1cb3701d
  comments: db2e367bbd191954
  discussions: 10d9c93435f43042
  memberships: '08c454bdcdc5e9fb'
  polls: 59769ed0da6b0cfb
  threads: 83a528e0bbcae4a6
  request-bodies: d9e08bef27b6bda7
  poll-many-options: e21a9e7b9e33dd98
  poll-detailed-options: aacb7ebfe244e6a0
  edit-poll-detailed-options: 7dc051a97b9ec28c
title_source: c23fb6526b722360
title_generated: 5b15ba096ff57860
---

<!-- translation-section: introduction -->

# Loomion käyttäjän API:n dokumentaatio

<!-- seo-description: Luo ja hallitse keskusteluja, kommentteja, kyselyjä, ketjuja ja ryhmien jäsenyyksiä muista ohjelmistoista Loomion käyttäjän API:n avulla. -->

`/api/b2` on käyttäjille tarkoitettu API Loomio-integraatioita varten. Se käyttää käyttäjätilin API-avainta, ja jokainen toiminto suoritetaan kyseisenä käyttäjänä.

Ryhmiin kohdistuvat toiminnot käyttävät API-avaimen käyttäjän jäsenyyksiä ja ryhmäkohtaisia käyttöoikeuksia. Loomio-asennuksen ylläpitäjän asema ei laajenna API-avaimen pääsyä ryhmiin tai sisältöön. Käytä palvelimen API:a asennustason hallintaan.

Käytä sen Loomio-käyttäjätilin API-avainta, joka suorittaa toiminnot. Erillinen bottitili on hyödyllinen, kun integraatiota ei pidä kutsua kyselyihin tai sen ei pidä saada ilmoituksia.

Kirjautuneet käyttäjät löytävät API-avaimensa ja ryhmien tunnukset [API-käyttöoikeuksien sivulta](/profile/api_access).

Lähetä API-avain `Authorization: Bearer` -otsakkeessa. Kyselymerkkijonoissa olevat API-avaimet hylätään, koska URL-osoitteet voivat tallentua välityspalvelimiin ja käyttölokeihin.

```text
Authorization: Bearer YOUR_API_KEY
```

Esimerkeissä käytetään arvoa `YOUR_API_KEY`, ryhmän tunnistetta `123` ja osoitetta `https://www.loomio.com/`. Korvaa ne omalla API-avaimellasi, ryhmän tunnisteella ja Loomio-asennuksesi URL-osoitteella.

<!-- translation-section: request-bodies -->

### Pyyntöjen runkojen lähettäminen

Lähetä JSON-muotoinen runko otsakkeella `Content-Type: application/json`. cURL-esimerkit käyttävät valitsinta `--json`, joka asettaa tämän otsakkeen automaattisesti. Keskustelujen, kommenttien ja kyselyjen luomisen ja muokkaamisen rajapintapisteet hyväksyvät joko litteän objektin tai resurssin nimen alle sisäkkäin sijoitetun objektin, kuten `{"poll": {...}}`.

Lähetä taulukot JSON-taulukkoina, kuten `"options": ["foo", "bar"]`. Jos käytät sen sijaan lomakekoodausta, taulukot tarvitsevat hakasulkeelliset kenttänimet, kuten `options[]=foo&options[]=bar`; muoto `options=foo&options=bar` säilyttää vain viimeisen arvon.

Tarkista HTTP-tilakoodi ja vastauksen runko jokaisen pyynnön jälkeen. Validoinnin epäonnistuessa palautetaan `422` ja `errors`-objekti; kun kyselyn luominen onnistuu, kysely palautetaan taulukossa `polls` ja sen vaihtoehdot taulukossa `poll_options`.

<!-- translation-section: endpoint-summary -->

## Rajapintapisteiden yhteenveto

| Metodi | Rajapintapiste | Tarkoitus |
| --- | --- | --- |
| `POST` | `/api/b2/comments` | Luo kommentti tai vastaus |
| `PATCH` | `/api/b2/comments/:id` | Muokkaa kommenttia |
| `DELETE` | `/api/b2/comments/:id` | Poista kommentti säilyttäen sen tietue |
| `POST` | `/api/b2/discussions` | Luo keskustelu |
| `GET` | `/api/b2/discussions/:id` | Hae keskustelu |
| `GET` | `/api/b2/discussions` | Listaa ryhmän keskustelut |
| `PATCH` | `/api/b2/discussions/:id` | Muokkaa keskustelua |
| `DELETE` | `/api/b2/discussions/:id` | Poista keskustelu säilyttäen sen tietue |
| `GET` | `/api/b2/groups` | Listaa API-avaimen käyttäjän ryhmät |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Hae näkyvissä oleva ryhmä |
| `GET` | `/api/b2/memberships` | Listaa ryhmän jäsenyydet |
| `POST` | `/api/b2/memberships` | Lisää jäseniä ja poista halutessasi luettelosta puuttuvat jäsenet |
| `GET` | `/api/b2/reports` | Luo osallistumisraportti |
| `POST` | `/api/b2/polls` | Luo kysely |
| `GET` | `/api/b2/polls/:id` | Hae kysely |
| `GET` | `/api/b2/polls` | Listaa ryhmän kyselyt |
| `PATCH` | `/api/b2/polls/:id` | Muokkaa kyselyä |
| `DELETE` | `/api/b2/polls/:id` | Poista kysely säilyttäen sen tietue |
| `GET` | `/api/b2/search` | Hae näkyvissä olevia keskusteluja, kommentteja, kyselyjä, ääniä ja johtopäätöksiä |
| `GET` | `/api/b2/threads` | Listaa näkyvissä olevat keskusteluketjut ja itsenäisten kyselyjen ketjut |
| `GET` | `/api/b2/threads/:topic_id` | Hae ketju |
| `GET` | `/api/b2/threads/:topic_id/items` | Hae ketjun kohteet järjestyksessä |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Hae koko ketju Markdown-muodossa |
| `GET` | `/api/b2/chatbots` | Listaa ryhmän chat-integraatiot ja webhookit |
| `POST` | `/api/b2/chatbots` | Luo chat-integraatio tai webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Päivitä chat-integraatio tai webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Poista chat-integraatio tai webhook |
| `POST` | `/api/b2/chatbots/check` | Lähetä webhookin yhteystesti |

<!-- translation-section: pagination -->

## Sivutus

Keskustelut, ryhmät, jäsenyydet, kyselyt, ketjut, ketjujen kohteet ja webhookit hyväksyvät parametrit `limit` (oletus `50`) ja `offset` (oletus `0`). Ryhmien, ketjujen kohteiden ja webhookien kohdalla parametrin `limit` enimmäisarvo on `500`.

Hae seuraava sivu kasvattamalla parametrin `offset` arvoa palautettujen ensisijaisten tietueiden määrällä. `meta.total` on kaikkien hakuehtoja vastaavien tietueiden määrä. Liittyviä tietueita ei lasketa sivun kokoon.

Osallistumisraportit palauttavat kaikki pyydetyt tiedot, ja haku palauttaa enintään 20 tulosta. Kumpikaan ei tue sivutusta.

Keskustelut, kyselyt ja jäsenyydet hyväksyvät myös vanhat parametrinimet `per` parametrille `limit` ja `from` parametrille `offset`. Käytä uusissa integraatioissa parametreja `limit` ja `offset`.

<!-- translation-section: response-size-and-related-records -->

## Liittyvät tietueet

Käyttäjän API:n vastaukset käyttävät yhdistelmämuotoa: ensisijaisten tietueiden mukana palautetaan liittyviä tietueita, kuten aiheita, ryhmiä, käyttäjiä, kyselyjä ja reaktioita. Näin asiakasohjelma voi täyttää paikallisen tietuevaraston yhdellä pyynnöllä, mutta vastaus voi sisältää enemmän tietoa kuin yksinkertainen integraatio tarvitsee.

Anna `compact=1`, jos haluat jättää pois paljon tilaa vievät liittyvät aiheet, ryhmät, pääryhmät, jäsenyydet, reaktiot, tunnisteet ja käännökset. Ensisijaiset tietueet ja niiden sisällön tulkintaan tarvittavat liittyvät tietueet säilyvät vastauksessa.

```bash
curl 'https://www.loomio.com/api/b2/threads/123/items?compact=1' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Jos haluat hallita poissulkemista tarkemmin, anna `exclude_types` ja välilyönneillä erotetut tietuetyypit yksikkömuodossa. Esimerkiksi `exclude_types=group reaction` jättää pois liittyvät ryhmät ja reaktiot. Tavallisia arvoja ovat `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` ja `topic_item`. Poissulkeminen koskee liittyviä tietueita, ei rajapintapisteeltä pyydettyä ensisijaista resurssia.

Kokoelmavastaukset sisältävät kentän `meta.total`, kun kokoelman tarkka koko on määritelty. Kokonaismäärä lasketaan ennen parametrien `limit` ja `offset` soveltamista. Rajapintapisteet, kuten haku, jotka palauttavat tarkoituksella rajatun tulosjoukon, jättävät kentän `meta.total` pois sen sijaan, että palauttaisivat arvon `null`.

<!-- translation-section: comments -->

## Kommentit

<!-- translation-section: create-comment -->

### Luo kommentti

Luo kommentti keskusteluun API-avaimen käyttäjänä.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `discussion_id` | Kokonaisluku, pakollinen. Kommentoitavan keskustelun tunniste |
| `body` | Kommentin sisältö, pakollinen, ellei mukana ole liitettä |
| `body_format` | Joko `md` tai `html`, valinnainen, oletus `md` |

<!-- translation-section: example-9 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/comments \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "discussion_id": 123,
    "body": "example comment",
    "body_format": "md"
  }'
```

<!-- translation-section: edit-comment -->

### Muokkaa kommenttia

Muokkaa kommenttia API-avaimen käyttäjänä. Samat käyttöoikeudet pätevät kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä kommenttia.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `body` | Päivitetty kommentin sisältö |
| `body_format` | Joko `md` tai `html`, valinnainen, oletus `md` |

<!-- translation-section: example-10 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/comments/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "body": "updated comment",
    "body_format": "md"
  }'
```

<!-- translation-section: soft-delete-comment -->

### Poista kommentti säilyttäen tietue

Poista kommentti API-avaimen käyttäjänä. Tämä poistaa kommentin käytöstä, piilottaa sen sisällön ja säilyttää kommentin tietueen.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/comments/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: discussions -->

## Keskustelut

<!-- translation-section: create-discussion -->

### Luo keskustelu

Luo keskustelu API-avaimen käyttäjänä.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Ryhmä, johon ketju luodaan |
| `title` | Ketjun otsikko, pakollinen |
| `description` | Ketjun konteksti, valinnainen |
| `description_format` | Joko `md` tai `html`, valinnainen, oletuksena `md` |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmälle ilmoitetaan uudesta ketjusta |
| `recipient_user_ids` | Taulukko niiden käyttäjien tunnuksista, joille ilmoitetaan ketjusta tai jotka kutsutaan siihen |
| `recipient_emails` | Taulukko ketjuun kutsuttavien henkilöiden sähköpostiosoitteista |
| `recipient_message` | Sähköpostikutsuun sisällytettävä viesti |

<!-- translation-section: example-2 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/discussions \
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

### Näytä keskustelu

Hae keskustelu käyttämällä keskustelun tunnusta (kokonaisluku) tai avainta (merkkijono).

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/discussions/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-discussions -->

### Listaa keskustelut

Listaa ryhmän keskustelut, jotka näkyvät API-avaimen käyttäjälle. Julkisesti näkyvän ryhmän julkiset keskustelut voi listata myös käyttäjä, joka ei ole ryhmän jäsen. Yksityiset keskustelut näkyvät vain käyttäjille, joilla on oikeus lukea niitä Loomiossa.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunnus, jonka keskustelut listataan |
| `status` | Merkkijono, valinnainen, oletus `open`. Arvot: `open`, `closed`, `all` |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksessa ohitettavien tietueiden määrä |

Vanhojen versioiden yhteensopivuus: `per` ja `from` hyväksytään parametrien `limit` ja `offset` vaihtoehtoisina niminä, ja ne toimivat jatkossakin.

<!-- translation-section: example-4 -->

#### Esimerkki

```bash
curl 'https://www.loomio.com/api/b2/discussions?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-discussion -->

### Muokkaa keskustelua

Muokkaa keskustelua API-avaimen käyttäjänä. Samat käyttöoikeudet pätevät kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä keskustelua.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `title` | Päivitetty otsikko |
| `description` | Päivitetty konteksti |
| `description_format` | Joko `md` tai `html`, valinnainen, oletus `md` |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmälle ilmoitetaan muokkauksesta |
| `recipient_user_ids` | Taulukko niiden käyttäjien tunnuksista, joille ilmoitetaan tai jotka kutsutaan ketjuun |
| `recipient_emails` | Taulukko ketjuun kutsuttavien henkilöiden sähköpostiosoitteista |
| `recipient_message` | Sähköpostikutsuun sisällytettävä viesti |

<!-- translation-section: example-7 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/discussions/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated thread title",
    "description": "updated context",
    "description_format": "md"
  }'
```

<!-- translation-section: soft-delete-discussion -->

### Poista keskustelu säilyttäen tietue

Poista keskustelu API-avaimen käyttäjänä. Tämä poistaa keskustelun käytöstä mutta säilyttää keskustelun tietueen.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/discussions/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: groups -->

## Ryhmät

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"hmän ylläpitäjien määrä |\n| `delegates_count` | Edustajien määrä |\n| `discussions_count` | Suoraan ry","after":"hmän ylläpitäjien määrä |\n| `discussions_count` | Suoraan ry"} -->

### Listaa ryhmät

Palauttaa ryhmät, joissa API-avaimen käyttäjällä on aktiivinen jäsenyys.

`GET /api/b2/groups`

| Nimi | Kuvaus |
| --- | --- |
| `limit` | Kokonaisluku, valinnainen, oletus 50, enintään 500. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksessa ohitettavien tietueiden määrä |

```bash
curl 'https://www.loomio.com/api/b2/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Vastaus sisältää `groups`-sivun, joka on järjestetty ryhmän tunnuksen mukaan nousevaan järjestykseen. Kenttä `meta.total` sisältää hakuehtoja vastaavien ryhmien kokonaismäärän. Mukana ovat pääryhmät ja alaryhmät, myös ryhmät, joiden tilaus ei ole tällä hetkellä aktiivinen. Tarkista `enabled`-kenttä, kun integraation pitää toimia vain käytössä olevissa ryhmissä.

Keskeisiä ryhmän kenttiä ovat:

| Kenttä | Kuvaus |
| --- | --- |
| `id` | Ryhmän numeerinen tunnus, jota muut käyttäjän API:n rajapintapisteet käyttävät |
| `key` | Pysyvä lyhyt avain, jota käytetään Loomion URL-osoitteissa |
| `handle` | Ryhmän helppolukuinen tunniste |
| `name` | Ryhmän nimi |
| `full_name` | Ryhmän nimi pääryhmän konteksti mukaan lukien |
| `parent_id` | Alaryhmän pääryhmän numeerinen tunnus, muuten `null` |
| `enabled` | Ovatko ryhmä ja sen tilaus aktiivisia |
| `memberships_count` | Aktiivisten ja odottavien jäsenyyksien määrä |
| `accepted_memberships_count` | Hyväksyttyjen jäsenyyksien määrä |
| `pending_memberships_count` | Odottavien kutsujen määrä |
| `admin_memberships_count` | Ryhmän ylläpitäjien määrä |
| `discussions_count` | Suoraan ryhmään kuuluvien keskustelujen määrä |
| `polls_count` | Suoraan ryhmään kuuluvien kyselyjen määrä |
| `subgroups_count` | Alaryhmien määrä |

Vastaus voi sisältää myös muita ryhmän asetuksia, liittyviä pääryhmän tietueita ja API-käyttäjän jäsenyyksiä. Asiakasohjelmien tulee jättää huomiotta kentät, joita ne eivät käytä.

<!-- translation-section: get-a-group -->

### Hae ryhmä

Palauttaa yhden API-avaimen käyttäjälle näkyvän ryhmän.

`GET /api/b2/groups/:id_or_key_or_handle`

Tunniste voi olla ryhmän numeerinen tunnus, avain tai helppolukuinen tunniste.

```bash
curl https://www.loomio.com/api/b2/groups/123 \
  -H 'Authorization: Bearer YOUR_API_KEY'

curl https://www.loomio.com/api/b2/groups/example-group \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Vastaus sisältää ryhmän `groups`-taulukossa ja käyttää samoja kenttiä kuin listauksen rajapintapiste. Jos pyyntö koskee ryhmää, johon API-avaimen käyttäjällä ei ole pääsyä, palautetaan käyttöoikeusvirhe.

<!-- translation-section: memberships -->

## Jäsenyydet

<!-- translation-section: list-memberships -->

### Listaa jäsenyydet

Listaa API-avaimen käyttäjälle näkyvät jäsenyydet. Ryhmän jäsenet voivat lukea jäsenten nimet, tunnisteet, nimikkeet ja roolit. Sähköpostiosoitteet sisältyvät tietoihin vain API-avaimen käyttäjän oman tilin osalta tai silloin, kun API-avaimen käyttäjä on ryhmän ylläpitäjä.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunniste, jonka jäsenyydet listataan |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksessa ohitettavien tietueiden määrä |

Vanha käytäntö: `per` ja `from` hyväksytään parametrien `limit` ja `offset` vaihtoehtoisina niminä, ja ne toimivat jatkossakin.

Vastaus sisältää sivun `memberships`-tietueita ja niihin liittyviä `users`-tietueita. `meta.total` on ryhmän näkyvien jäsenyyksien kokonaismäärä ennen sivutusta.

<!-- translation-section: example-17 -->

#### Esimerkki

```bash
curl 'https://www.loomio.com/api/b2/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: manage-memberships -->

### Hallitse jäsenyyksiä

Lähetä luettelo sähköpostiosoitteista. Kaikki uudet sähköpostiosoitteet kutsutaan ryhmään. Toisin kuin jäsenyyksien listaaminen, tämä toiminto edellyttää ryhmän ylläpitäjän oikeuksia.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunniste, jonka jäsenyyksiä hallitaan |
| `emails` | Merkkijonotaulukko, pakollinen. Ryhmään kutsuttavien henkilöiden sähköpostiosoitteet |
| `remove_absent` | Totuusarvo. Jos arvo on true, poista ryhmästä kaikki, joiden sähköpostiosoite ei ole luettelossa |

<!-- translation-section: example-18 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ]
  }'
```

Jos annat parametrin `remove_absent=1`, kaikki ryhmän jäsenet, jotka eivät ole luettelossa, poistetaan ryhmästä. Ole varovainen, sillä saatat poistaa kaikki ryhmäsi jäsenet.

```bash
curl https://www.loomio.com/api/b2/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ],
    "remove_absent": 1
  }'
```

Tämä palauttaa objektin, jonka sisältö on `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.

<!-- translation-section: participation-report -->

## Osallistumisraportti

Palauttaa samat koostetut osallistumistiedot, joita Loomion osallistumisraportti käyttää.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `section` | Raportin osio: `base`, `users` tai `countries`. Käytä arvoa `users` henkilökohtaisten toimintatietojen hakemiseen |
| `group_scope` | `custom` tai `my`. Vanha arvo `all` käsitellään arvona `my`, koska käyttäjän API-avaimet eivät koskaan anna koko instanssin kattavaa käyttöoikeutta |
| `group_ids` | Pilkuilla erotetut ryhmätunnukset, kun `group_scope=custom`. Sellaisten ryhmien tunnukset ohitetaan, joihin API-käyttäjä ei kuulu |
| `start_month` | Ensimmäinen mukaan otettava kuukausi muodossa `YYYY-MM`. Oletuksena 12 kuukautta sitten |
| `end_month` | Viimeinen mukaan otettava kuukausi muodossa `YYYY-MM`. Oletuksena kuluva kuukausi |
| `interval` | `base`-osion aikaväli: `day`, `week`, `month` tai `year` |
| `member_type` | Aseta arvoksi `delegate`, kun `section=users`, jos haluat palauttaa vain nykyiset edustajat |

Henkilö on edustaja, jos hänellä on aktiivinen edustajajäsenyys jossakin valituista ryhmistä. Hänen toimintansa määrät lasketaan yhteen kaikista valituista ryhmistä. Edustajien rivit palautetaan myös silloin, kun kaikki toimintamäärät ovat nollia. Määrät kattavat ketjut, kommentit, kyselyt, äänet, johtopäätökset ja reaktiot. Ne eivät ole äänestämisen osallistumisasteita. Käyttäjärivit sisältävät myös tunnistettujen äänestyslippujen määrät: myönnetyt, käytetyt ja käyttämättä jääneet. Anonyymit kyselyt jätetään pois kaikista henkilökohtaisista äänestysmääristä. `all_votes_cast` on tosi vain, kun vähintään yksi äänestyslippu on myönnetty ja kaikki myönnetyt äänestysliput on käytetty.

API soveltaa samoja ryhmien näkyvyyssääntöjä kuin sovelluksen raportti. Käyttäjän API-avain ei voi paljastaa raporttitietoja ryhmistä, joihin käyttäjällä ei ole pääsyä.

<!-- translation-section: example -->

### Esimerkki

```bash
curl 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

`users`-taulukko sisältää täydelliset toimintatietorivit:

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

## Kyselyt

<!-- translation-section: create-poll -->

### Luo kysely

Luo kysely API-avaimen käyttäjänä.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, valinnainen, oletus null. Kyselyn ryhmän tunniste. Jos `discussion_id` annetaan, `group_id` jätetään huomiotta |
| `discussion_id` | Kokonaisluku, valinnainen, oletus null. Sen keskusteluketjun tunniste, johon kysely lisätään |
| `title` | Merkkijono, pakollinen. Kyselyn otsikko |
| `poll_type` | Merkkijono, pakollinen. Arvot: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Merkkijono, valinnainen. Kyselyn leipäteksti |
| `details_format` | Merkkijono, valinnainen, oletus `md`. Arvot: `md` tai `html` |
| `options` | Vaihtoehtojen nimet merkkijonotaulukkona. Kun tyyppi on `proposal`, käytä arvoja `agree`, `disagree`, `abstain` tai `block`, jotta saat vakionimet, kuvakkeet, merkitykset ja kehotteet. Kun tyyppi on `meeting`, anna päivämäärät tai päivämäärät ja kellonajat ISO 8601 -muotoisina merkkijonoina. Anna muille kyselytyypeille vaihtoehtojen nimet. Käytä yksityiskohtaisiin vaihtoehtoihin sen sijaan kenttää `poll_options_attributes` |
| `poll_options_attributes` | Vaihtoehto kentälle `options`: taulukko vaihtoehto-objekteista, joilla on nimet, merkitykset, kehotteet, kuvakkeet ja järjestys. Katso [Luo kysely, jonka vaihtoehdoilla on yksityiskohtaiset tiedot](#create-a-poll-with-detailed-options) |
| `reason_prompt` | Merkkijono, valinnainen. Äänen perustelun yhteinen kehote kyselytyypeille, joilla ei ole vaihtoehtokohtaisia kehotteita, kuten `poll`, `score` ja `ranked_choice` |
| `stance_reason_required` | Merkkijono, oletus `optional`. Arvot: `disabled`, `optional`, `required`, `required_for_disagree_or_block`, `required_for_block`. Kaksi viimeistä koskevat kuvakkeita `disagree` ja `block`. Anonyymeissä kyselyissä äänten perustelut ovat pois käytöstä |
| `closing_at` | ISO 8601 -muotoinen merkkijono tai null, oletus null. Esimerkki: `2026-09-01T12:00:00Z`. Jos arvo on null, äänestäminen on pois käytöstä ja kysely katsotaan keskeneräiseksi |
| `specified_voters_only` | Totuusarvo, valinnainen, oletus false. Jos arvo on true, vain määritetyt henkilöt voivat äänestää. Jos arvo on false, kaikki ryhmän jäsenet kutsutaan äänestämään |
| `hide_results` | Merkkijono, valinnainen, oletus `off`. Arvot: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Totuusarvo, oletus false. Näytä vaihtoehdot äänestäjille satunnaisessa järjestyksessä |
| `anonymous` | Totuusarvo, valinnainen, oletus false. Piilota äänestäjien henkilöllisyydet |
| `recipient_audience` | `group` tai null, valinnainen, oletus null. Jos arvo on `group`, koko ryhmälle lähetetään ilmoitus |
| `notify_on_closing_soon` | Merkkijono, valinnainen, oletus `nobody`. Arvot: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Taulukko niiden käyttäjien tunnisteista, joille lähetetään ilmoitus tai kutsu |
| `recipient_emails` | Taulukko äänestämään kutsuttavien henkilöiden sähköpostiosoitteista |
| `recipient_message` | Sähköpostikutsuun sisällytettävä viesti |
| `notify_recipients` | Totuusarvo, oletus false. Jos arvo on false, lisää henkilöt lähettämättä ilmoituksia. Jos arvo on true, kaikki tässä pyynnössä kutsutut saavat sähköposti-ilmoituksen |

<!-- translation-section: example-12 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/polls \
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

#### Luo kyselyluonnos, jossa on useita vaihtoehtoja

Lähetä kaikkien vaihtoehtojen nimet `options`-taulukossa. Jos jätät kentän `closing_at` pois, luodaan keskeneräinen kysely, jossa äänestäminen on pois käytöstä. Tämä ei piilota kyselyä henkilöiltä, jotka voivat lukea sen ketjun. Lisää tulevaisuuteen ajoittuva `closing_at`, kun olet valmis avaamaan äänestämisen.

Lisää kaikkien vaihtoehtojesi nimet taulukkoon:

```bash
curl https://www.loomio.com/api/b2/polls \
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

#### Luo kysely, jonka vaihtoehdoilla on yksityiskohtaiset tiedot

Käytä nimiluetteloon kenttää `options` tai kenttää `poll_options_attributes`, kun kukin vaihtoehto tarvitsee merkityksen, perustelukehotteen tai kuvakkeen. Valitse yksi muoto pyyntöä kohden. Molemmat muodot toimivat joko suoraan JSON-rungossa tai `poll`-objektin sisällä.

Jokainen `poll_options_attributes`-taulukon objekti hyväksyy nämä kentät:

| Kenttä | Kuvaus |
| --- | --- |
| `name` | Merkkijono, pakollinen uudelle vaihtoehdolle. Äänestäjille näytettävä nimi |
| `meaning` | Merkkijono, valinnainen. Selittää, mitä tämän vaihtoehdon valitseminen tarkoittaa |
| `prompt` | Merkkijono, valinnainen. Perustelukehote, joka näytetään, kun tämä vaihtoehto valitaan kyselytyypissä `proposal`, `count` tai `check`. Aseta muille kyselytyypeille kyselyn `reason_prompt` |
| `icon` | Merkkijono, valinnainen. Käytä tyypeille `proposal`, `count` ja `check` arvoja `agree`, `disagree`, `abstain` tai `block` |
| `priority` | Kokonaisluku. Vaihtoehdon järjestysnumero, alkaen arvosta `0`. Anna kullekin vaihtoehdolle eri arvo; tapaamisvaihtoehdot järjestetään sen sijaan päivämäärän mukaan |
| `test_operator` | Merkkijono tai null, valinnainen. Ääniosuusvaatimus: `gte` tarkoittaa vähintään ja `lte` enintään. Poista vaatimus käytöstä asettamalla arvoksi null |
| `test_percent` | Kokonaisluku, valinnainen. Ääniosuusvaatimuksen prosenttiosuus, arvosta `0` arvoon `100` |
| `test_against` | Merkkijono, valinnainen. `score_percent` vertaa vaihtoehdon osuutta annettujen pisteiden kokonaismäärästä; `voter_percent` vertaa vaihtoehdon äänestäjien määrää kaikkiin äänioikeutettuihin |
| `id` | Kokonaisluku. Sisällytä, kun muokkaat olemassa olevaa vaihtoehtoa; jätä pois uudelta vaihtoehdolta |
| `_destroy` | Totuusarvo, valinnainen. Poista olemassa oleva vaihtoehto asettamalla arvoksi `true` ja antamalla vaihtoehdon `id` |

Luo ehdotus, jonka vaihtoehdoilla on mukautetut nimet ja kehotteet:

```bash
curl https://www.loomio.com/api/b2/polls \
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

Käytä tavallisessa kyselyssä samaa yksityiskohtaista vaihtoehtomuotoa ja aseta kyselylle yhteinen `reason_prompt`:

```bash
curl https://www.loomio.com/api/b2/polls \
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

Näistä esimerkeistä puuttuu `closing_at`, joten äänestäminen pysyy pois käytöstä, kunnes tulevaisuuteen ajoittuva sulkemispäivä on asetettu.

<!-- translation-section: show-poll -->

### Näytä kysely

Hae kysely sen kokonaislukumuotoisella tunnisteella tai merkkijonomuotoisella avaimella.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/polls/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-polls -->

### Listaa kyselyt

Listaa ryhmän kyselyt, jotka näkyvät API-avaimen käyttäjälle. Julkisesti näkyvän ryhmän julkiset kyselyt voi listata myös henkilö, joka ei ole ryhmän jäsen. Yksityiset kyselyt näkyvät vain käyttäjille, jotka voivat lukea niitä Loomiossa. Vastaus sisältää kunkin näkyvän kyselyn nykyisen johtopäätöksen, joten voit listata ratkaistut ehdotukset parametrilla `status=closed`.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunniste, jonka kyselyt listataan |
| `status` | Merkkijono, valinnainen, oletus `active`. Arvot: `active`, `closed`, `all` |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksessa ohitettavien tietueiden määrä |

Vanhojen parametrien tuki: `per` ja `from` hyväksytään parametrien `limit` ja `offset` vaihtoehtoisina niminä, ja ne toimivat jatkossakin.

<!-- translation-section: example-14 -->

#### Esimerkki

```bash
curl 'https://www.loomio.com/api/b2/polls?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-poll -->

### Muokkaa kyselyä

Muokkaa kyselyä API-avaimen käyttäjänä. Samat käyttöoikeudet pätevät kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä kyselyä.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `title` | Päivitetty otsikko |
| `details` | Päivitetyt kyselyn tiedot |
| `details_format` | Joko `md` tai `html`, valinnainen, oletus `md` |
| `options` | Päivitetyt vaihtoehtojen nimet. Vaihtoehtojen muuttaminen voi vaikuttaa annettuihin ääniin kyselyn tilasta riippuen |
| `poll_options_attributes` | Vaihtoehto kentälle `options`. Päivitä yksityiskohtaisia vaihtoehto-objekteja tunnisteen `id` perusteella, lisää objekteja ilman tunnistetta `id` tai poista vaihtoehto antamalla `id` ja `_destroy: true`. Pois jätetyt vaihtoehdot pysyvät ennallaan |
| `reason_prompt` | Päivitetty yhteinen perustelukehote kyselytyypeille, joilla ei ole vaihtoehtokohtaisia kehotteita |
| `stance_reason_required` | Päivitetty perusteluvaatimus; samat arvot pätevät kuin kyselyä luotaessa |
| `closing_at` | ISO 8601 -muotoinen merkkijono tai null |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmälle lähetetään ilmoitus |
| `recipient_user_ids` | Taulukko niiden käyttäjien tunnisteista, joille lähetetään ilmoitus tai kutsu |
| `recipient_emails` | Taulukko äänestämään kutsuttavien henkilöiden sähköpostiosoitteista |
| `recipient_message` | Sähköpostikutsuun sisällytettävä viesti |

<!-- translation-section: example-15 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/polls/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated poll title",
    "details": "updated details",
    "details_format": "md"
  }'
```

<!-- translation-section: edit-poll-detailed-options -->

#### Muokkaa vaihtoehtojen yksityiskohtaisia tietoja

Hae vaihtoehtojen tunnisteet luonti- tai hakuvastauksen `poll_options`-taulukosta. Lähetä vain muutettavat kentät sekä kunkin olemassa olevan vaihtoehdon `id`:

```bash
curl https://www.loomio.com/api/b2/polls/123 \
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

Vaihtoehtojen tunnisteiden on kuuluttava muokattavaan kyselyyn. Muokkaaminen edellyttää oikeutta muokata kyselyä, eikä suljettuja kyselyjä voi muokata. Anonyymeissä kyselyissä myös vaihtoehtojen määritykset lukitaan ensimmäisen äänen antamisen jälkeen.

<!-- translation-section: soft-delete-poll -->

### Poista kysely loogisesti

Poista kysely loogisesti API-avaimen käyttäjänä. Tämä merkitsee kyselyn poistetuksi mutta säilyttää sen tietueen.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

#### Esimerkki

```bash
curl https://www.loomio.com/api/b2/polls/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: search -->

## Haku

Hae API-avaimen käyttäjälle näkyviä keskusteluja, kommentteja, kyselyitä, ääniä ja johtopäätöksiä. Hakutulokset sisältävät julkista sisältöä myös silloin, kun käyttäjä ei ole kyseisen ryhmän jäsen. Yksityiseen sisältöön sovelletaan ketjun tavallisia näkyvyyssääntöjä.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `query` | Hakuteksti. Tukee tarkkoja ja likimääräisiä osumia |
| `group_id` | Rajaa tulokset yhteen näkyvään ryhmään |
| `org_id` | Rajaa tulokset näkyvään pääryhmään ja sen näkyviin alaryhmiin. Käytä arvoa `0` suorille keskusteluille |
| `type` | Rajaa tulokset yhteen tyyppiin: `Discussion`, `Comment`, `Poll`, `Stance` tai `Outcome` |
| `types` | Pilkuilla erotettu luettelo hakutulosten tyypeistä |
| `tag` | Rajaa tulokset ketjuihin, joilla on tämä tunniste |
| `author_id` | Rajaa tulokset yhden tekijän sisältöön. Ilman `query`-parametria palauttaa kyseisen tekijän viimeaikaisen näkyvän toiminnan |
| `order` | Aseta arvoksi `authored_at_desc`, jos haluat järjestää hakua vastaavan sisällön luomisajan mukaan |

```bash
curl 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Vastaus sisältää `search_results`-taulukon. Jokainen hakutulos yksilöi hakua vastaavan tietueen ja sen näkyvän kontekstin kentillä, joihin kuuluvat `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` ja `tags`. Kentät, jotka eivät koske kyseistä hakutulosta, saavat arvon `null`.

<!-- translation-section: threads -->

## Ketjut

<!-- translation-section: list-threads -->

### Listaa ketjut

Listaa API-avaimen käyttäjälle näkyvät keskustelu- ja kyselyketjut viimeisimmän toiminnan mukaan järjestettyinä. Ketjun tunnus on sen `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

#### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksessa ohitettavien tietueiden määrä |

<!-- translation-section: example-5 -->

#### Esimerkki

```bash
curl 'https://www.loomio.com/api/b2/threads?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: read-thread -->

### Lue ketju

Lue ketju, sen järjestetty tapahtumavirta tai sen koko näkyvä sisältö Markdown-dokumenttina.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

`items`-päätepiste hyväksyy nämä sivutusparametrit:

| Nimi | Kuvaus |
| --- | --- |
| `limit` | Kokonaisluku, valinnainen, oletus 50, enimmäisarvo 500. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksessa ohitettavien tietueiden määrä |

<!-- translation-section: example-6 -->

#### Esimerkki

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

`items`-päätepiste palauttaa sivun tapahtumavirrasta nousevassa järjestysnumerojärjestyksessä. Se sisältää näkyvät kommentit, kyselyt, äänet ja johtopäätökset. `meta.total` on ketjun kohteiden kokonaismäärä. Hae seuraavat sivut lukeaksesi koko tapahtumavirran. `markdown`-päätepiste palauttaa koko näkyvän ketjun yhtenä Markdown-dokumenttina. Äänten perustelut sisällytetään vain, jos ne näkyvät API-avaimen käyttäjälle.

Kaikki ketjujen päätepisteet noudattavat samoja käyttöoikeuksia kuin Loomion käyttöliittymä. API-avain ei anna pääsyä ketjuun, jota käyttäjä ei normaalisti voi avata.

<!-- translation-section: webhooks -->

## Webhookit

Käyttäjän API perustuu pyyntöihin: integraatio kutsuu Loomiota, kun se haluaa lukea tai muuttaa tietoja. Ryhmän webhook mahdollistaa tiedon lähettämisen toiseen suuntaan. Loomio lähettää valitut ryhmän tapahtumat rajapintapisteeseesi niiden tapahtuessa, joten integraation ei tarvitse kysellä muutoksia REST API:sta.

Webhookit määritetään ryhmäkohtaisesti, ja niiden hallinta vaatii ryhmän ylläpitäjän oikeudet. Voit hallita niitä Loomion käyttöliittymässä:

1. Avaa ryhmä.
2. Avaa ryhmän valikko ja valitse **Chat-integraatiot**.
3. Lisää integraatio, jonka viestimuodon rajapintapisteesi hyväksyy. Käytä yleiskäyttöiselle rajapintapisteelle Mattermost/Markdown-muotoa.
4. Anna nimi ja kohteen URL-osoite.
5. Valitse tapahtumat, jotka Loomion tulee lähettää automaattisesti.
6. Tallenna integraatio ja lähetä testiviesti valitsemalla **Testaa yhteys**.

Käytä HTTPS-kohdetta, jonka URL-osoitetta ei voi arvata. Loomio edellyttää, että kohde ratkeaa julkiseksi osoitteeksi, ja estää pyynnöt paikallisiin tai yksityisiin verkko-osoitteisiin.

Agentit ja muut integraatiot voivat myös hallita webhookeja alla kuvattujen chatbot-rajapintapisteiden kautta käyttäen Bearer-todennusta. Resurssin nimi on `chatbots`, jotta se on yhteensopiva Loomion chat-integraatioiden kanssa, mutta se kattaa myös yleiset lähtevät webhookit.

<!-- translation-section: list-webhooks -->

### Listaa webhookit

Palauttaa ryhmälle määritetyt chat-integraatiot. API-avaimen käyttäjän on oltava kyseisen ryhmän ylläpitäjä. Vastaus sisältää kohteiden URL-osoitteet, joten sitä ei saa näyttää ryhmän tavallisille jäsenille.

`GET /api/b2/chatbots?group_id=123`

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunnus, jonka webhookit listataan |
| `limit` | Kokonaisluku, valinnainen, oletus 50, enimmäisarvo 500. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksessa ohitettavien tietueiden määrä |

```bash
curl 'https://www.loomio.com/api/b2/chatbots?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Vastaus sisältää sivun `chatbots`-tietueita integraation tunnuksen mukaan nousevassa järjestyksessä. `meta.total` sisältää ryhmän integraatioiden kokonaismäärän. Jokaisella integraatiolla on nämä kentät:

| Kenttä | Kuvaus |
| --- | --- |
| `id` | Integraation tunnus, jota käytetään päivityksiin ja poistamiseen |
| `group_id` | Tapahtumat vastaanottava ryhmä |
| `name` | Integraation hallinnollinen nimi |
| `kind` | `webhook` lähtevälle webhookille tai `matrix` Matrix-integraatiolle |
| `webhook_kind` | Viestimuoto: `markdown`, `slack`, `discord`, `microsoft` tai `webex` |
| `server` | Kohteen URL-osoite |
| `event_kinds` | Automaattisesti lähetettävät tapahtumat |
| `notification_only` | Sisältävätkö viestit vain ilmoituksen otsikon |

<!-- translation-section: create-a-webhook -->

### Luo webhook

`POST /api/b2/chatbots`

```bash
curl https://www.loomio.com/api/b2/chatbots \
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

API-avaimen käyttäjän on oltava `group_id`-arvon määrittämän ryhmän ylläpitäjä. Ennen tallentamista tarkistetaan, että kohde on julkinen URL-osoite.

<!-- translation-section: update-a-webhook -->

### Päivitä webhook

`PATCH /api/b2/chatbots/:id`

Lähetä kentät, joita haluat muuttaa. Webhookia ei voi siirtää toiseen ryhmään muuttamalla `group_id`-arvoa.

```bash
curl https://www.loomio.com/api/b2/chatbots/456 \
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

### Testaa webhookin kohde

Lähetä Markdown-yhteensopiva testiviesti kohteeseen ennen sen asetusten tallentamista tai sen jälkeen.

`POST /api/b2/chatbots/check`

```bash
curl https://www.loomio.com/api/b2/chatbots/check \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "server": "https://hooks.example.org/loomio/unguessable-token"
  }'
```

<!-- translation-section: delete-a-webhook -->

### Poista webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl https://www.loomio.com/api/b2/chatbots/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Asetusten poistaminen lopettaa tulevat toimitukset. Se ei poista mitään Loomio-ryhmän sisältöä.

<!-- translation-section: event-types -->

### Tapahtumatyypit

Webhook voi tilata seuraavat tapahtumatyypit:

| Tapahtuma | Milloin se lähetetään |
| --- | --- |
| `new_discussion` | Keskustelu aloitetaan |
| `discussion_edited` | Keskustelua muokataan |
| `new_comment` | Kommentti luodaan |
| `poll_created` | Kysely aloitetaan |
| `poll_edited` | Kyselyä muokataan |
| `poll_closing_soon` | Kyselyn sulkemisaika lähestyy |
| `poll_expired` | Kyselyn sulkemisaika saavutetaan |
| `poll_closed_by_user` | Henkilö sulkee kyselyn manuaalisesti |
| `poll_reopened` | Kysely avataan uudelleen |
| `outcome_created` | Johtopäätös julkaistaan |
| `outcome_updated` | Johtopäätöstä päivitetään |
| `outcome_review_due` | Johtopäätöksen tarkistamisen määräaika koittaa |
| `stance_created` | Ääni annetaan |
| `stance_updated` | Ääntä muutetaan |

Webhook kuuluu yhteen ryhmään ja vastaanottaa tilaamansa tapahtumat kyseisestä ryhmästä. Ihmiset voivat myös valita integraation erikseen jakaessaan sisältöä tai lähettäessään tiettyjä ilmoituksia, vaikka vastaavaa automaattista tapahtumaa ei olisi valittu.

<!-- translation-section: http-delivery -->

### HTTP-toimitus

Loomio lähettää määritettyyn URL-osoitteeseen asynkronisen HTTP `POST` -pyynnön, jossa on seuraava otsake:

```text
Content-Type: application/json; charset=utf-8
```

Pyynnön aikakatkaisu on viisi sekuntia. `2xx`-vastaus, mukaan lukien `204 No Content`, tulkitaan onnistuneeksi. Webhookin vastaanottajan tulee vastata nopeasti, käsitellä pidempään kestävät tehtävät asynkronisesti ja sietää päällekkäisiä tai väärässä järjestyksessä saapuvia toimituksia.

Loomio ei tällä hetkellä lisää webhook-allekirjoitusta, jaetun salaisuuden sisältävää otsaketta, tapahtumatunnusta tai toimitustunnusta. Käsittele koko kohde-URL-osoitetta tunnistetietona, älä paljasta sitä julkisesti ja sisällytä URL-osoitteeseen tunniste, jota ei voi arvata, jos vastaanottava palvelu tukee sitä. Jos tarvitset vakaan koneluettavan tapahtumarakenteen tai allekirjoitetun toimituksen, käytä webhookia muutosilmoituksena ja hae ajantasaiset tietueet käyttäjän API:n kautta todennettuna.

<!-- translation-section: payload-formats -->

### Viestisisällön muodot

Webhookien viestisisällöt on tarkoitettu chat-palveluissa esitettäviksi viesteiksi. Ne eivät ole täydellisiä sarjallistettuja Loomio-tietueita. Viestin linkit yksilöivät Loomio-sisällön, jota tapahtuma koskee. Integraatio voi hakea lisätietoja käyttäjän API:n kautta, kun se tarvitsee ajantasaisen tilan rakenteisessa muodossa.

| Integraation muoto | Keskeiset JSON-kentät |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, enintään noin 1 900 merkkiä |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Esimerkiksi yleinen Markdown-muoto lähettää seuraavan rakenteisen viestirungon:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Viestin tarkka teksti riippuu tapahtumasta, ryhmän kieliasetuksesta, pelkän ilmoituksen lähettämistä koskevasta asetuksesta ja Loomion versiosta. Vastaanottajan tulee käyttää valitun muodon dokumentoituja ylimmän tason kenttiä sen sijaan, että se jäsentäisi lauseiden sanamuotoja.
