---
title: Käyttäjän API
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
  introduction: 82936da950a90063
  authentication-change: ee5087ebf126ae0a
  response-size-and-related-records: 0e1d92a7ad1f391c
  endpoint-summary: 6c7d4b9271102b3c
  groups: 90cb5d1f24e992a5
  list-groups: 228c3fa74ab9459e
  get-a-group: 837752af598ee859
  webhooks: acbe78e2952a1e1c
  list-webhooks: 260944acde5a3fec
  create-a-webhook: 359b0317b246b050
  update-a-webhook: 7fe0a1d8d85a045f
  test-a-webhook-destination: 7c8ce63b2a659b16
  delete-a-webhook: 7198ce329aff90c4
  event-types: db4ba60443b8466f
  http-delivery: f059dbd9bb8f390e
  payload-formats: 782aebdf41cc6dcf
  search: b55ecceb40237e7c
  params: ad0572816bc60f53
  participation-report: 55fd9e3db40b5ff0
  params-2: ef76a602fbe0dc51
  example: deb96c96f2ab4702
  create-discussion: da1c062e7de1bcd0
  params-3: 19f57860d3331c7e
  example-2: 0fba0ddffe1d1f8f
  show-discussion: '096aebb57506c836'
  example-3: c7ed6992d843dd65
  list-discussions: d064fedf47ea03e3
  params-4: 38dbdf7e63e5fa0d
  example-4: b222dce2575e8280
  list-threads: 0d23c4d0ca44592d
  params-5: 388daffe7494ea6d
  example-5: d6cf4d886a1df9b7
  read-thread: 29a83504323398f8
  example-6: af1ef46d2a6ddf3c
  edit-discussion: ade6029d0315e52e
  params-6: 4326a178b57c8764
  example-7: d08e45b4083b8410
  soft-delete-discussion: 2c8f1bf23acaebcd
  example-8: f962c071ea9159d2
  create-comment: c539a5a7b04b4033
  params-7: 87f345afdaec1bc6
  example-9: '00959cecc9acc4ae'
  edit-comment: 603505df828e5c81
  params-8: e6836557a5083bef
  example-10: 7364c0a3dbb727dd
  soft-delete-comment: afddb368fd65f5af
  example-11: 8c932571964443df
  create-poll: 93833cd2686a96d2
  params-9: b5783bf746bce341
  example-12: 9611661842c9b137
  show-poll: 86b2d478fd42b23f
  example-13: 0ecae479bcd60370
  list-polls: 63865d4c709d0066
  params-10: bb3fd38480473289
  example-14: 25eed6385a44588a
  edit-poll: 0c4561ac2e55f047
  params-11: d9fcce24a9ee612a
  example-15: 95f3d16271c830f4
  soft-delete-poll: 3a4808a295fb7054
  example-16: a8cd755e3914d3c2
  list-memberships: 7bcf34c761672393
  params-12: c1652df746fd2551
  example-17: ead5bc61074133f2
  manage-memberships: a3eaa757aec3056b
  params-13: 1a32dde1ed5bba30
  example-18: d55622b3846080ad
title_source: c23fb6526b722360
title_generated: 5b15ba096ff57860
---

<!-- translation-section: introduction -->

# Loomion käyttäjän API:n dokumentaatio

<!-- seo-description: Luo ja hallitse keskusteluja, kommentteja, kyselyjä, ketjuja ja ryhmien jäsenyyksiä muista ohjelmistoista Loomion käyttäjän API:n avulla. -->

`/api/b2` on käyttäjäkohtainen API Loomio-integraatioille. Se käyttää käyttäjätilin API-avainta, ja kaikki toiminnot suoritetaan kyseisenä käyttäjänä.

Ryhmätoiminnoissa käytetään API-avaimen käyttäjän jäsenyyksiä ja ryhmäkohtaisia käyttöoikeuksia. Loomio-asennuksen ylläpitäjän asema ei laajenna API-avaimen pääsyä ryhmiin tai sisältöön. Käytä Server API:a asennustason hallintaan.

Käytä sen Loomio-käyttäjätilin API-avainta, joka suorittaa toiminnot. Erillinen bottitili on hyödyllinen, kun integraatiota ei pidä kutsua kyselyihin eikä sen pidä vastaanottaa ilmoituksia.

Kirjautuneet käyttäjät löytävät API-avaimensa ja ryhmien tunnukset [API-käyttöoikeuksien sivulta](/profile/api_access).

Lähetä API-avain `Authorization: Bearer` -otsakkeessa. Kyselymerkkijonoissa olevat API-avaimet hylätään, koska URL-osoitteet voivat tallentua välityspalvelimien lokeihin ja käyttölokeihin.

<!-- translation-section: authentication-change -->

### Muutos tunnistautumiseen

API-avain hyväksyttiin aiemmin URL-osoitteen `api_key`-parametrina. Pyynnöt, joissa käytetään `?api_key=YOUR_API_KEY`, eivät enää toimi. Käytä sen sijaan HTTP-pyynnön `Authorization`-otsaketta:

```text
Authorization: Bearer YOUR_API_KEY
```

Esimerkeissä käytetään arvoja `YOUR_API_KEY`, ryhmän tunnusta `123` ja osoitetta `https://www.loomio.com/`. Korvaa ne omalla API-avaimellasi, ryhmän tunnuksella ja Loomio-asennuksen URL-osoitteella.

<!-- translation-section: response-size-and-related-records -->

## Vastauksen koko ja liittyvät tietueet

Käyttäjän API:n vastaukset käyttävät yhdistelmämuotoa: ensisijaisten tietueiden mukana palautetaan niihin liittyviä tietueita, kuten aiheita, ryhmiä, käyttäjiä, kyselyjä ja reaktioita. Näin asiakasohjelma voi täyttää paikallisen tietuevaraston yhdellä pyynnöllä, mutta vastaus voi sisältää enemmän tietoa kuin yksinkertainen integraatio tarvitsee.

Anna `compact=1`, jos haluat jättää pois paljon tilaa vievät liittyvät aiheet, ryhmät, pääryhmät, jäsenyydet, reaktiot, tunnisteet ja käännökset. Ensisijaiset tietueet ja niiden sisällön tulkitsemiseen tarvittavat liittyvät tietueet säilyvät vastauksessa.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Jos haluat määrittää pois jätettävät tietuetyypit itse, anna `exclude_types`-parametrin arvoksi yksikkömuotoiset tietuetyypit välilyönneillä erotettuina. Esimerkiksi `exclude_types=group reaction` jättää pois liittyvät ryhmät ja reaktiot. Tavallisia arvoja ovat `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` ja `topic_item`. Pois jättäminen koskee liittyviä tietueita, ei päätepisteeltä pyydettyä ensisijaista resurssia.

Kokoelmavastaukset sisältävät `meta.total`-arvon, kun kokoelman tarkka koko on määritelty. Kokonaismäärä lasketaan ennen `limit`- ja `offset`-parametrien soveltamista. Päätepisteet, kuten haku, jotka palauttavat tarkoituksella rajatun tulosjoukon, jättävät `meta.total`-arvon pois sen sijaan, että palauttaisivat arvon `null`.

<!-- translation-section: endpoint-summary -->

## Päätepisteiden yhteenveto

| Metodi | Päätepiste | Tarkoitus |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Listaa API-avaimen käyttäjän ryhmät |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Hae näkyvissä oleva ryhmä |
| `GET` | `/api/b2/reports` | Luo osallistumisraportti |
| `GET` | `/api/b2/search` | Etsi näkyvissä olevia keskusteluja, kommentteja, kyselyjä, ääniä ja johtopäätöksiä |
| `POST` | `/api/b2/discussions` | Luo keskustelu |
| `GET` | `/api/b2/discussions/:id` | Hae keskustelu |
| `GET` | `/api/b2/discussions` | Listaa ryhmän keskustelut |
| `PATCH` | `/api/b2/discussions/:id` | Muokkaa keskustelua |
| `DELETE` | `/api/b2/discussions/:id` | Poista keskustelu loogisesti |
| `GET` | `/api/b2/threads` | Listaa näkyvissä olevat keskusteluketjut ja itsenäisten kyselyjen ketjut |
| `GET` | `/api/b2/threads/:topic_id` | Hae ketju |
| `GET` | `/api/b2/threads/:topic_id/items` | Hae ketjun kohteet järjestyksessä |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Hae koko ketju Markdown-muodossa |
| `POST` | `/api/b2/comments` | Luo kommentti tai vastaus |
| `PATCH` | `/api/b2/comments/:id` | Muokkaa kommenttia |
| `DELETE` | `/api/b2/comments/:id` | Poista kommentti loogisesti |
| `POST` | `/api/b2/polls` | Luo kysely |
| `GET` | `/api/b2/polls/:id` | Hae kysely |
| `GET` | `/api/b2/polls` | Listaa ryhmän kyselyt |
| `PATCH` | `/api/b2/polls/:id` | Muokkaa kyselyä |
| `DELETE` | `/api/b2/polls/:id` | Poista kysely loogisesti |
| `GET` | `/api/b2/memberships` | Listaa ryhmän jäsenyydet |
| `POST` | `/api/b2/memberships` | Lisää jäseniä ja poista halutessasi luettelosta puuttuvat jäsenet |
| `GET` | `/api/b2/chatbots` | Listaa ryhmän chat-integraatiot ja webhookit |
| `POST` | `/api/b2/chatbots` | Luo chat-integraatio tai webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Päivitä chat-integraatio tai webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Poista chat-integraatio tai webhook |
| `POST` | `/api/b2/chatbots/check` | Lähetä webhookin yhteystesti |

<!-- translation-section: groups -->

## Ryhmät

<!-- translation-section: list-groups -->

### Listaa ryhmät

Palauttaa ryhmät, joissa API-avaimen käyttäjällä on aktiivinen jäsenyys.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Vastaus sisältää kaikki ehdot täyttävät tietueet sivuttamattomassa `groups`-taulukossa. Mukana ovat pääryhmät ja alaryhmät, myös ryhmät, joiden tilaus ei ole tällä hetkellä aktiivinen. Tarkista `enabled`-kenttä, kun integraation pitää toimia vain käytössä olevissa ryhmissä.

Tärkeitä ryhmän kenttiä ovat:

| Kenttä | Kuvaus |
| --- | --- |
| `id` | Numeerinen ryhmän tunnus, jota muut käyttäjän API:n päätepisteet käyttävät |
| `key` | Pysyvä lyhyt avain, jota käytetään Loomion URL-osoitteissa |
| `handle` | Ihmiselle luettava ryhmän tunniste |
| `name` | Ryhmän nimi |
| `full_name` | Ryhmän nimi ja sen pääryhmän tiedot |
| `parent_id` | Alaryhmän pääryhmän numeerinen tunnus, muulloin `null` |
| `enabled` | Ovatko ryhmä ja sen tilaus aktiivisia |
| `memberships_count` | Aktiivisten ja odottavien jäsenyyksien määrä |
| `accepted_memberships_count` | Hyväksyttyjen jäsenyyksien määrä |
| `pending_memberships_count` | Odottavien kutsujen määrä |
| `admin_memberships_count` | Ryhmän ylläpitäjien määrä |
| `delegates_count` | Edustajien määrä |
| `discussions_count` | Suoraan ryhmässä olevien keskustelujen määrä |
| `polls_count` | Suoraan ryhmässä olevien kyselyjen määrä |
| `subgroups_count` | Alaryhmien määrä |

Vastaus voi sisältää myös muita ryhmän asetuksia, liittyviä pääryhmätietueita ja API-käyttäjän jäsenyyksiä. Asiakasohjelmien tulee ohittaa kentät, joita ne eivät käytä.

<!-- translation-section: get-a-group -->

### Hae ryhmä

Palauttaa yhden API-avaimen käyttäjälle näkyvän ryhmän.

`GET /api/b2/groups/:id_or_key_or_handle`

Tunniste voi olla ryhmän numeerinen tunnus, avain tai ihmiselle luettava tunniste.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Vastaus sisältää ryhmän `groups`-taulukossa ja käyttää samoja kenttiä kuin listauksen päätepiste. Pyyntö ryhmästä, johon API-avaimen käyttäjällä ei ole pääsyä, palauttaa käyttöoikeusvirheen.

<!-- translation-section: webhooks -->

## Webhookit

Käyttäjän API perustuu pyyntöihin: integraatio kutsuu Loomiota, kun se haluaa lukea tai muuttaa tietoja. Ryhmän webhook välittää tiedot toiseen suuntaan. Loomio lähettää valitut ryhmän tapahtumat päätepisteeseesi niiden tapahtuessa, joten integraation ei tarvitse kysellä muutoksia REST API:lta.

Webhookit määritetään ryhmäkohtaisesti, ja niiden hallinta edellyttää ryhmän ylläpitäjän oikeuksia. Voit hallita niitä Loomion käyttöliittymässä:

1. Avaa ryhmä.
2. Avaa ryhmän valikko ja valitse **Chat-integraatiot**.
3. Lisää integraatio, jonka viestimuodon päätepisteesi hyväksyy. Käytä yleiskäyttöiselle päätepisteelle Mattermost/Markdown-muotoa.
4. Anna nimi ja kohteen URL-osoite.
5. Valitse tapahtumat, jotka Loomion pitää lähettää automaattisesti.
6. Tallenna integraatio ja lähetä testiviesti valitsemalla **Testaa yhteys**.

Käytä HTTPS-kohdetta, jonka URL-osoitetta ei voi arvata. Loomio edellyttää, että kohde ratkeaa julkiseksi verkko-osoitteeksi, ja estää pyynnöt paikallisiin tai yksityisiin verkko-osoitteisiin.

Agentit ja muut integraatiot voivat vaihtoehtoisesti hallita webhookeja alla kuvatuilla chatbot-päätepisteillä, jotka käyttävät Bearer-tunnistautumista. Resurssin nimi on `chatbots`, jotta se on yhteensopiva Loomion chat-integraatioiden kanssa, mutta se kattaa myös yleiskäyttöiset lähtevät webhookit.

<!-- translation-section: list-webhooks -->

### Listaa webhookit

Palauttaa ryhmälle määritetyt chat-integraatiot. API-avaimen käyttäjän on oltava kyseisen ryhmän ylläpitäjä. Vastaus sisältää kohteiden URL-osoitteet, joten sitä ei saa näyttää ryhmän tavallisille jäsenille.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Vastaus sisältää `chatbots`-taulukon, jossa on nämä kentät:

| Kenttä | Kuvaus |
| --- | --- |
| `id` | Integraation tunnus, jota käytetään päivityksiin ja poistamiseen |
| `group_id` | Tapahtumat vastaanottava ryhmä |
| `name` | Integraation hallinnassa käytettävä nimi |
| `kind` | `webhook` lähtevälle webhookille tai `matrix` Matrix-integraatiolle |
| `webhook_kind` | Viestimuoto: `markdown`, `slack`, `discord`, `microsoft` tai `webex` |
| `server` | Kohteen URL-osoite |
| `event_kinds` | Automaattisesti lähetettävät tapahtumat |
| `notification_only` | Sisältävätkö viestit vain ilmoituksen otsikon |

<!-- translation-section: create-a-webhook -->

### Luo webhook

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

API-avaimen käyttäjän on oltava `group_id`-arvon määrittämän ryhmän ylläpitäjä. Ennen tallentamista tarkistetaan, että kohteen URL-osoite on julkinen.

<!-- translation-section: update-a-webhook -->

### Päivitä webhook

`PATCH /api/b2/chatbots/:id`

Lähetä kentät, joita haluat muuttaa. Webhookia ei voi siirtää toiseen ryhmään muuttamalla `group_id`-arvoa.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Testaa webhookin kohde

Lähetä kohteeseen Markdown-yhteensopiva testiviesti ennen sen asetusten tallentamista tai sen jälkeen.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Poista webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Asetusten poistaminen lopettaa tulevat toimitukset. Se ei poista Loomio-ryhmän sisältöä.

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
| `poll_expired` | Kyselyn sulkemisaika koittaa |
| `poll_closed_by_user` | Käyttäjä sulkee kyselyn käsin |
| `poll_reopened` | Kysely avataan uudelleen |
| `outcome_created` | Johtopäätös julkaistaan |
| `outcome_updated` | Johtopäätöstä päivitetään |
| `outcome_review_due` | Johtopäätöksen tarkistamisen määräaika koittaa |
| `stance_created` | Ääni annetaan |
| `stance_updated` | Ääntä muutetaan |

Webhook kuuluu yhteen ryhmään ja vastaanottaa siitä tilaamansa tapahtumat. Käyttäjät voivat myös valita integraation erikseen jakaessaan sisältöä tai lähettäessään tiettyjä ilmoituksia, vaikka vastaavaa automaattista tapahtumaa ei olisi valittu.

<!-- translation-section: http-delivery -->

### HTTP-toimitus

Loomio lähettää määritettyyn URL-osoitteeseen asynkronisen HTTP `POST` -pyynnön, jossa on tämä otsake:

```text
Content-Type: application/json; charset=utf-8
```

Pyynnön aikakatkaisu on viisi sekuntia. `2xx`-vastaus, myös `204 No Content`, tulkitaan onnistumiseksi. Webhookin vastaanottajan tulee vastata nopeasti, käsitellä pidempään kestävät tehtävät asynkronisesti ja sietää toistuvia tai väärässä järjestyksessä saapuvia toimituksia.

Loomio ei tällä hetkellä lisää webhookin allekirjoitusta, jaetun salaisuuden otsaketta, tapahtuman tunnistetta tai toimituksen tunnistetta. Käsittele koko kohdeosoitetta tunnistautumistietona, älä julkaise sitä ja sisällytä URL-osoitteeseen tunnus, jota ei voi arvata, jos vastaanottava palvelu tukee sitä. Jos tarvitset vakaan koneellisesti luettavan tapahtumaskeeman tai allekirjoitetun toimituksen, käytä webhookia muutosilmoituksena ja hae ajantasaiset tietueet tunnistautumista vaativan käyttäjän API:n kautta.

<!-- translation-section: payload-formats -->

### Viestisisällön muodot

Webhookien viestisisällöt ovat chat-palveluille tarkoitettuja, esittämiseen suunniteltuja viestejä. Ne eivät ole täydellisiä sarjallistettuja Loomio-tietueita. Viestin linkit yksilöivät Loomio-sisällön, jota tapahtuma koskee. Integraatio voi hakea lisätietoja käyttäjän API:n kautta, kun se tarvitsee ajantasaisen tilan rakenteisessa muodossa.

| Integraation muoto | Keskeiset JSON-kentät |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, enintään noin 1 900 merkkiä |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Esimerkiksi yleinen Markdown-muoto lähettää seuraavan rakenteen mukaisen sisällön:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Viestin tarkka teksti riippuu tapahtumasta, ryhmän kieli- ja alueasetuksista, vain ilmoituksen sisältävästä asetuksesta ja Loomion versiosta. Vastaanottajan tulee käyttää valitun muodon dokumentoituja ylimmän tason kenttiä sen sijaan, että se jäsentäisi lauseiden sanamuotoja.

<!-- translation-section: search -->

## Haku

Hae API-avaimen käyttäjälle näkyviä keskusteluja, kommentteja, kyselyjä, ääniä ja johtopäätöksiä. Hakutulokset sisältävät julkista sisältöä myös silloin, kun käyttäjä ei ole sen ryhmän jäsen; yksityiseen sisältöön sovelletaan ketjujen tavallisia näkyvyyssääntöjä.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `query` | Hakuteksti. Tukee tarkkoja ja likimääräisiä osumia |
| `group_id` | Rajaa hakutulokset yhteen näkyvään ryhmään |
| `org_id` | Rajaa hakutulokset näkyvään pääryhmään ja sen näkyviin alaryhmiin. Käytä arvoa `0` suorille keskusteluille |
| `type` | Rajaa hakutulokset yhteen tyyppiin: `Discussion`, `Comment`, `Poll`, `Stance` tai `Outcome` |
| `types` | Pilkuilla erotettu luettelo hakutulosten tyypeistä |
| `tag` | Rajaa hakutulokset ketjuihin, joilla on tämä tunniste |
| `author_id` | Rajaa hakutulokset yhden kirjoittajan sisältöön. Ilman parametria `query` palauttaa kirjoittajan viimeaikaisen näkyvän toiminnan |
| `order` | Aseta arvoksi `authored_at_desc`, jotta hakua vastaava sisältö järjestetään kirjoitusajan mukaan |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Vastaus sisältää `search_results`-taulukon. Jokainen hakutulos yksilöi hakua vastaavan tietueen ja sen näkyvän kontekstin kentillä, joihin kuuluvat `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` ja `tags`. Kentät, jotka eivät koske kyseistä hakutulosta, saavat arvon `null`.

<!-- translation-section: participation-report -->

## Osallistumisraportti

Palauttaa samat koostetut osallistumistiedot, joita Loomion osallistumisraportti käyttää.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `section` | Raportin osio: `base`, `users` tai `countries`. Käytä arvoa `users` henkilökohtaiseen toimintaan |
| `group_scope` | `custom` tai `my`. Vanha arvo `all` käsitellään arvona `my`, koska käyttäjän API-avaimet eivät koskaan anna koko Loomio-asennuksen kattavaa käyttöoikeutta |
| `group_ids` | Pilkuilla erotetut ryhmien tunnisteet, kun `group_scope=custom`. Tunnisteet ohitetaan, jos API:n käyttäjä ei ole kyseisten ryhmien jäsen |
| `start_month` | Ensimmäinen mukaan otettava kuukausi muodossa `YYYY-MM`; oletuksena 12 kuukautta sitten |
| `end_month` | Viimeinen mukaan otettava kuukausi muodossa `YYYY-MM`; oletuksena nykyinen kuukausi |
| `interval` | `base`-osion aikaväli: `day`, `week`, `month` tai `year` |
| `member_type` | Aseta arvoksi `delegate` yhdessä asetuksen `section=users` kanssa, jotta vain nykyiset edustajat palautetaan |

Henkilö on edustaja, kun hänellä on aktiivinen edustajajäsenyys jossakin valituista ryhmistä. Hänen lukumääränsä lasketaan yhteen kaikista valituista ryhmistä. Edustajien rivit palautetaan myös silloin, kun kaikki toimintojen lukumäärät ovat nollia. Lukumäärät kattavat ketjut, kommentit, kyselyt, äänet, johtopäätökset ja reaktiot. Ne eivät kuvaa äänestämisen osallistumisasteita. Käyttäjäriveillä ovat myös tunnistettujen äänestyslippujen määrät: myönnetyt, käytetyt ja käyttämättä jääneet. Anonyymit kyselyt jätetään pois kaikista henkilökohtaisista äänestämisen lukumääristä. `all_votes_cast` on tosi vain, kun vähintään yksi äänestyslippu on myönnetty ja kaikki myönnetyt äänestysliput on käytetty.

API soveltaa samoja ryhmien näkyvyyssääntöjä kuin Loomiossa oleva raportti. Käyttäjän API-avain ei voi paljastaa raporttitietoja ryhmistä, joihin käyttäjällä ei ole pääsyä.

<!-- translation-section: example -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

`users`-taulukko sisältää täydelliset toimintarivit:

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

## Luo keskustelu

Luo keskustelu API-avaimen käyttäjänä.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Ryhmä, johon ketju luodaan |
| `title` | Ketjun otsikko, pakollinen |
| `description` | Ketjun konteksti, valinnainen |
| `description_format` | Joko `md` tai `html`, valinnainen, oletus `md` |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmälle ilmoitetaan uudesta ketjusta |
| `recipient_user_ids` | Taulukko niiden käyttäjien tunnisteista, joille ilmoitetaan ketjusta tai jotka kutsutaan siihen |
| `recipient_emails` | Taulukko ketjuun kutsuttavien henkilöiden sähköpostiosoitteista |
| `recipient_message` | Sähköpostikutsuun sisällytettävä viesti |

<!-- translation-section: example-2 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Näytä keskustelu

Hae keskustelu sen tunnuksella (kokonaisluku) tai avaimella (merkkijono).

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Listaa keskustelut

Listaa ryhmän keskustelut, jotka näkyvät API-avaimen käyttäjälle. Julkisesti näkyvän ryhmän julkiset keskustelut voi listata myös ilman ryhmän jäsenyyttä. Yksityiset keskustelut näkyvät vain käyttäjille, joilla on oikeus lukea niitä Loomiossa.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunnus, jonka keskustelut listataan |
| `status` | Merkkijono, valinnainen, oletus `open`. Arvot: `open`, `closed`, `all` |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksen aloituskohta |

Vanhojen versioiden yhteensopivuus: `per` ja `from` hyväksytään parametrien `limit` ja `offset` vaihtoehtoisina niminä, ja ne toimivat jatkossakin.

<!-- translation-section: example-4 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Listaa ketjut

Listaa API-avaimen käyttäjälle näkyvät keskustelu- ja kyselyketjut viimeisimmän toiminnan mukaan järjestettyinä. Ketjun tunnus on sen `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksen aloituskohta |

<!-- translation-section: example-5 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Lue ketju

Lue ketju, sen järjestetty tapahtumavirta tai sen koko näkyvä sisältö Markdown-asiakirjana.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Esimerkki

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

`items`-päätepiste palauttaa järjestetyn tapahtumavirran, joka sisältää näkyvät kommentit, kyselyt, äänet ja johtopäätökset. `markdown`-päätepiste palauttaa koko näkyvän ketjun yhtenä Markdown-asiakirjana. Äänten perustelut sisällytetään vain, jos ne näkyvät API-avaimen käyttäjälle.

Kaikki ketjujen päätepisteet noudattavat samoja käyttöoikeuksia kuin Loomion käyttöliittymä. API-avain ei anna pääsyä ketjuun, jota käyttäjä ei normaalisti voi avata.

<!-- translation-section: edit-discussion -->

## Muokkaa keskustelua

Muokkaa keskustelua API-avaimen käyttäjänä. Samat käyttöoikeudet pätevät kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä keskustelua.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parametrit

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

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Poista keskustelu loogisesti

Poista keskustelu loogisesti API-avaimen käyttäjänä. Tämä poistaa keskustelun käytöstä mutta säilyttää sen tietueen.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Luo kommentti

Luo kommentti keskusteluun API-avaimen käyttäjänä.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `discussion_id` | Kokonaisluku, pakollinen. Kommentoitavan keskustelun tunnus |
| `body` | Kommentin teksti, pakollinen, ellei mukana ole liitettä |
| `body_format` | Joko `md` tai `html`, valinnainen, oletus `md` |

<!-- translation-section: example-9 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Muokkaa kommenttia

Muokkaa kommenttia API-avaimen käyttäjänä. Samat käyttöoikeudet pätevät kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä kommenttia.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `body` | Päivitetty kommentin teksti |
| `body_format` | Joko `md` tai `html`, valinnainen, oletus `md` |

<!-- translation-section: example-10 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Poista kommentti loogisesti

Poista kommentti loogisesti API-avaimen käyttäjänä. Tämä poistaa kommentin käytöstä ja piilottaa sen tekstin mutta säilyttää sen tietueen.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Luo kysely

Luo kysely API-avaimen käyttäjänä.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, valinnainen, oletus null. Kyselyn ryhmän tunniste. Jos annat `discussion_id`-parametrin, `group_id` ohitetaan |
| `discussion_id` | Kokonaisluku, valinnainen, oletus null. Sen keskusteluketjun tunniste, johon kysely lisätään |
| `title` | Merkkijono, pakollinen. Kyselyn otsikko |
| `poll_type` | Merkkijono, pakollinen. Arvot: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Merkkijono, valinnainen. Kyselyn leipäteksti |
| `details_format` | Merkkijono, valinnainen, oletus `md`. Arvot: `md` tai `html` |
| `options` | Merkkijonojen taulukko. Jos `poll_type` on `proposal`, sallitut arvot ovat `agree`, `disagree`, `abstain`, `block`. Jos `poll_type` on `meeting`, anna päivämäärät tai päivämäärät ja kellonajat ISO 8601 -muotoisina merkkijonoina. Muissa kyselytyypeissä mikä tahansa merkkijono on sallittu |
| `closing_at` | ISO 8601 -muotoinen merkkijono tai null, oletus null. Esimerkki: `2026-09-01T12:00:00Z`. Jos arvo on null, äänestäminen on poissa käytöstä ja kysely katsotaan keskeneräiseksi |
| `specified_voters_only` | Totuusarvo, valinnainen, oletus false. Jos arvo on true, vain nimetyt henkilöt voivat äänestää. Jos arvo on false, kaikki ryhmän jäsenet kutsutaan äänestämään |
| `hide_results` | Merkkijono, valinnainen, oletus `off`. Arvot: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Totuusarvo, oletus false. Näytä vaihtoehdot äänestäjille satunnaisessa järjestyksessä |
| `anonymous` | Totuusarvo, valinnainen, oletus false. Piilota äänestäjien henkilöllisyydet |
| `recipient_audience` | `group` tai null, valinnainen, oletus null. Jos arvo on `group`, koko ryhmälle lähetetään ilmoitus |
| `notify_on_closing_soon` | Merkkijono, valinnainen, oletus `nobody`. Arvot: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Taulukko niiden käyttäjien tunnisteista, joille lähetetään ilmoitus tai kutsu |
| `recipient_emails` | Taulukko niiden henkilöiden sähköpostiosoitteista, jotka kutsutaan äänestämään |
| `recipient_message` | Sähköpostikutsuun sisällytettävä viesti |
| `notify_recipients` | Totuusarvo, oletus false. Jos arvo on false, henkilöt lisätään lähettämättä ilmoituksia. Jos arvo on true, kaikki tällä pyynnöllä kutsutut saavat ilmoituksen sähköpostitse |

<!-- translation-section: example-12 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Näytä kysely

Hae kysely sen kokonaislukumuotoisella tunnisteella tai merkkijonomuotoisella avaimella.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Listaa kyselyt

Listaa ryhmän kyselyt, jotka näkyvät API-avaimen käyttäjälle. Julkisesti näkyvän ryhmän julkiset kyselyt voi listata myös henkilö, joka ei ole ryhmän jäsen. Yksityiset kyselyt näkyvät vain käyttäjille, joilla on oikeus lukea niitä Loomiossa. Vastaus sisältää kunkin näkyvän kyselyn nykyisen johtopäätöksen, joten voit käyttää parametria `status=closed` listataksesi ehdotukset, joista on tehty päätös.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunniste, jonka kyselyt listataan |
| `status` | Merkkijono, valinnainen, oletus `active`. Arvot: `active`, `closed`, `all` |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksen aloituskohta |

Vanhojen parametrien tuki: `per` ja `from` hyväksytään parametrien `limit` ja `offset` vaihtoehtoisina niminä, ja ne toimivat jatkossakin.

<!-- translation-section: example-14 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Muokkaa kyselyä

Muokkaa kyselyä API-avaimen käyttäjänä. Käyttöoikeudet ovat samat kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä kyselyä.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `title` | Päivitetty otsikko |
| `details` | Päivitetyt kyselyn tiedot |
| `details_format` | `md` tai `html`, valinnainen, oletus `md` |
| `options` | Päivitetyt vaihtoehtojen nimet. Vaihtoehtojen muuttaminen voi vaikuttaa jo annettuihin ääniin kyselyn tilasta riippuen |
| `closing_at` | ISO 8601 -muotoinen merkkijono tai null |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmälle lähetetään ilmoitus |
| `recipient_user_ids` | Taulukko niiden käyttäjien tunnisteista, joille lähetetään ilmoitus tai kutsu |
| `recipient_emails` | Taulukko niiden henkilöiden sähköpostiosoitteista, jotka kutsutaan äänestämään |
| `recipient_message` | Sähköpostikutsuun sisällytettävä viesti |

<!-- translation-section: example-15 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Poista kysely loogisesti

Poista kysely loogisesti API-avaimen käyttäjänä. Kysely poistuu käytöstä, mutta sen tietue säilyy.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Listaa jäsenyydet

Listaa API-avaimen käyttäjälle näkyvät jäsenyydet. Ryhmän jäsenet voivat lukea jäsenten nimet, tunnisteet, nimikkeet ja roolit. Sähköpostiosoitteet sisällytetään vain API-avaimen käyttäjän oman tilin tietoihin tai silloin, kun API-avaimen käyttäjä on ryhmän ylläpitäjä.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunniste, jonka jäsenyydet listataan |

<!-- translation-section: example-17 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Hallitse jäsenyyksiä

Lähetä luettelo sähköpostiosoitteista. Kaikki uudet sähköpostiosoitteet saavat kutsun ryhmään. Toisin kuin jäsenyyksien listaaminen, tämä toiminto edellyttää ryhmän ylläpitäjän oikeuksia.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunniste, jonka jäsenyyksiä hallitaan |
| `emails` | Merkkijonotaulukko, pakollinen. Ryhmään kutsuttavien ihmisten sähköpostiosoitteet |
| `remove_absent` | Totuusarvo. Jos arvo on true, poista ryhmästä kaikki, joiden sähköpostiosoite ei ole luettelossa |

<!-- translation-section: example-18 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Jos annat parametrin `remove_absent=1`, kaikki ryhmän jäsenet, joita ei ole luettelossa, poistetaan ryhmästä. Ole varovainen: saatat poistaa kaikki ryhmäsi jäsenet.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Tämä palauttaa objektin, joka sisältää `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
