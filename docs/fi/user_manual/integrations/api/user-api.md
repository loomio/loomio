---
title: Käyttäjän API
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
  introduction: 6c95f0ef2a5d0747
  authentication-change: ef5565f4bac05366
  response-size-and-related-records: 1ea8996ccd5ca9e4
  endpoint-summary: 812a669b54bbc4d0
  groups: 90cb5d1f24e992a5
  list-groups: df684aa56efc78a1
  get-a-group: 87ced5f9a42a7d8d
  webhooks: f565394547a58b3a
  list-webhooks: 98f8a771a4c04f09
  create-a-webhook: e0c7dbd1c08c271a
  update-a-webhook: a25fbbf239fcc11f
  test-a-webhook-destination: 27f192cbf55a4f93
  delete-a-webhook: 80a1f3375889563e
  event-types: dd8f8986f1e24c8f
  http-delivery: eada4d7167eb42ce
  payload-formats: 92f516b8fb744530
  search: da94961f07100d11
  params: 5f1f26fbf3a48a0f
  participation-report: e4b9c69857540db3
  params-2: 59e72438bd28860c
  example: 7dfb3f60859b9fe8
  create-discussion: da1c062e7de1bcd0
  params-3: 6a86b878a64e712c
  example-2: 0fba0ddffe1d1f8f
  show-discussion: 2778ff537e0822fa
  example-3: c7ed6992d843dd65
  list-discussions: a872d7d650b3be39
  params-4: 1cd0fa9d9232c807
  example-4: b222dce2575e8280
  list-threads: f5fde109cca72501
  params-5: 388daffe7494ea6d
  example-5: d6cf4d886a1df9b7
  read-thread: 8f5a6754db1648ba
  example-6: e2131309d330a532
  edit-discussion: ade6029d0315e52e
  params-6: 570e1d19835a4a95
  example-7: d08e45b4083b8410
  soft-delete-discussion: 7ebe8097253c1030
  example-8: f962c071ea9159d2
  create-comment: c539a5a7b04b4033
  params-7: dab88b27a02241be
  example-9: '00959cecc9acc4ae'
  edit-comment: 603505df828e5c81
  params-8: 0f1d5296a760810f
  example-10: 7364c0a3dbb727dd
  soft-delete-comment: e87c02ef4f7709c6
  example-11: 8c932571964443df
  create-poll: 93833cd2686a96d2
  params-9: 3582d580d886d879
  example-12: 9611661842c9b137
  show-poll: f438fecfa0feeff2
  example-13: 0ecae479bcd60370
  list-polls: b530a76d4a046042
  params-10: 68d03ea84e14b66c
  example-14: 25eed6385a44588a
  edit-poll: 8cefc97698f1d60b
  params-11: e8b3287ff6fb1af7
  example-15: 95f3d16271c830f4
  soft-delete-poll: 4ddd6e9f63ec1b7a
  example-16: a8cd755e3914d3c2
  list-memberships: e8217cfaaddebed2
  params-12: 6446f97d4bee530c
  example-17: ead5bc61074133f2
  manage-memberships: 709e8d046137c799
  params-13: 516005428bce7726
  example-18: 3ec1f78536421977
title_source: c23fb6526b722360
title_generated: 5b15ba096ff57860
---

<!-- translation-section: introduction -->

# Loomion käyttäjän API:n dokumentaatio

<!-- seo-description: Loomion käyttäjän API:n avulla voit luoda ja hallita keskusteluja, kommentteja, kyselyitä, ketjuja ja ryhmäjäsenyyksiä muista ohjelmistoista. -->

`/api/b2` on Loomio-integraatioiden käyttäjäkohtainen API. Se käyttää käyttäjätilin API-avainta, ja kaikki toiminnot tehdään kyseisen käyttäjän nimissä.

Ryhmiä koskevissa toiminnoissa noudatetaan API-avaimen käyttäjän jäsenyyksiä ja ryhmäoikeuksia. Instanssin ylläpitäjän asema ei laajenna API-avaimen pääsyä ryhmiin tai sisältöön. Käytä instanssin hallintaan palvelimen API:a.

Käytä sen Loomio-käyttäjätilin API-avainta, jonka nimissä toiminnot tehdään. Erillinen bottitili on hyödyllinen, jos integraatiota ei pidä kutsua kyselyihin tai sen ei pidä saada ilmoituksia.

Kirjautuneet käyttäjät löytävät API-avaimensa ja ryhmiensä tunnukset [API-käyttösivulta](/profile/api_access).

Lähetä API-avain `Authorization: Bearer` -otsakkeessa. Kyselymerkkijonossa lähetetyt API-avaimet hylätään, koska välityspalvelimet ja käyttölokit voivat tallentaa URL-osoitteita.

<!-- translation-section: authentication-change -->

### Todennuksen muutos

API-avain hyväksyttiin aiemmin URL-parametrina `api_key`. Pyynnöt, joissa käytetään parametria `?api_key=YOUR_API_KEY`, eivät enää toimi. Käytä sen sijaan HTTP-otsaketta `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Esimerkeissä käytetään arvoja `YOUR_API_KEY`, ryhmätunnusta `123` ja osoitetta `https://www.loomio.com/`. Korvaa ne omalla API-avaimellasi, ryhmätunnuksellasi ja Loomio-asennuksesi URL-osoitteella.

<!-- translation-section: response-size-and-related-records -->

## Vastauksen koko ja liittyvät tietueet

Käyttäjän API:n vastaukset ovat yhdistelmämuotoisia: ensisijaisten tietueiden mukana tulee niihin liittyviä tietueita, kuten aiheita, ryhmiä, käyttäjiä, kyselyitä ja reaktioita. Näin asiakasohjelma voi täyttää paikallisen tietuevarastonsa yhdellä pyynnöllä, mutta vastaus voi sisältää enemmän tietoa kuin yksinkertainen integraatio tarvitsee.

Anna parametri `compact=1`, jos haluat jättää pois tilaa vievät liittyvät aiheet, ryhmät, pääryhmät, jäsenyydet, reaktiot, tunnisteet ja käännökset. Ensisijaiset tietueet ja niiden sisällön tulkintaan tarvittavat liittyvät tietueet säilyvät vastauksessa.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Jos haluat valita pois jätettävät tyypit itse, anna parametrille `exclude_types` välilyönneillä erotetut tietuetyypit yksikkömuodossa. Esimerkiksi `exclude_types=group reaction` jättää pois liittyvät ryhmät ja reaktiot. Tavallisia arvoja ovat `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` ja `topic_item`. Poisjättö koskee liittyviä tietueita, ei päätepisteestä pyydettyä ensisijaista resurssia.

Kokoelmavastauksissa on `meta.total`, kun kokoelman tarkka koko on määritetty. Kokonaismäärä lasketaan ennen parametrien `limit` ja `offset` käyttöä. Esimerkiksi hakupäätepiste jättää `meta.total`-kentän pois, kun se palauttaa tarkoituksella rajatun tulosjoukon. Se ei palauta arvoa `null`.

<!-- translation-section: endpoint-summary -->

## Päätepisteiden yhteenveto

| Menetelmä | Päätepiste | Tarkoitus |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Listaa API-avaimen käyttäjän ryhmät |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Hae käyttäjälle näkyvä ryhmä |
| `GET` | `/api/b2/reports` | Luo osallistumisraportti |
| `GET` | `/api/b2/search` | Hae näkyvistä keskusteluista, kommenteista, kyselyistä, äänistä ja yhteenvedoista |
| `POST` | `/api/b2/discussions` | Luo keskustelu |
| `GET` | `/api/b2/discussions/:id` | Hae keskustelu |
| `GET` | `/api/b2/discussions` | Listaa ryhmän keskustelut |
| `PATCH` | `/api/b2/discussions/:id` | Muokkaa keskustelua |
| `DELETE` | `/api/b2/discussions/:id` | Poista keskustelu pehmeästi |
| `GET` | `/api/b2/threads` | Listaa näkyvät keskusteluketjut ja erillisten kyselyiden ketjut |
| `GET` | `/api/b2/threads/:topic_id` | Hae ketju |
| `GET` | `/api/b2/threads/:topic_id/items` | Hae ketjun kohteet järjestyksessä |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Hae koko ketju Markdown-muodossa |
| `POST` | `/api/b2/comments` | Luo kommentti tai vastaus |
| `PATCH` | `/api/b2/comments/:id` | Muokkaa kommenttia |
| `DELETE` | `/api/b2/comments/:id` | Poista kommentti pehmeästi |
| `POST` | `/api/b2/polls` | Luo kysely |
| `GET` | `/api/b2/polls/:id` | Hae kysely |
| `GET` | `/api/b2/polls` | Listaa ryhmän kyselyt |
| `PATCH` | `/api/b2/polls/:id` | Muokkaa kyselyä |
| `DELETE` | `/api/b2/polls/:id` | Poista kysely pehmeästi |
| `GET` | `/api/b2/memberships` | Listaa ryhmän jäsenyydet |
| `POST` | `/api/b2/memberships` | Lisää jäseniä ja halutessasi poista luettelosta puuttuvat jäsenet |
| `GET` | `/api/b2/chatbots` | Listaa ryhmän chat-integraatiot ja webhookit |
| `POST` | `/api/b2/chatbots` | Luo chat-integraatio tai webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Päivitä chat-integraatio tai webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Poista chat-integraatio tai webhook |
| `POST` | `/api/b2/chatbots/check` | Lähetä webhookin yhteystesti |

<!-- translation-section: groups -->

## Ryhmät

<!-- translation-section: list-groups -->

### Listaa ryhmät

Palauta ryhmät, joissa API-avaimen käyttäjällä on aktiivinen jäsenyys.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

Vastaus sisältää kaikki ehdot täyttävät tietueet sivuttamattomassa `groups`-taulukossa. Mukana ovat pääryhmät ja alaryhmät, myös ryhmät, joiden tilaus ei ole tällä hetkellä voimassa. Tarkista `enabled`-kenttä, jos integraation pitää käsitellä vain käytössä olevia ryhmiä.

Tärkeitä ryhmän kenttiä ovat:

| Kenttä | Kuvaus |
| --- | --- |
| `id` | Numeerinen ryhmätunnus, jota muut käyttäjän API:n päätepisteet käyttävät |
| `key` | Loomion URL-osoitteissa käytetty pysyvä lyhyt tunnus |
| `handle` | Ihmiselle luettava ryhmätunniste |
| `name` | Ryhmän nimi |
| `full_name` | Ryhmän nimi pääryhmän yhteydessä |
| `parent_id` | Alaryhmän pääryhmän numeerinen tunnus, muuten `null` |
| `enabled` | Ovatko ryhmä ja sen tilaus aktiivisia |
| `memberships_count` | Aktiivisten ja odottavien jäsenyyksien määrä |
| `accepted_memberships_count` | Hyväksyttyjen jäsenyyksien määrä |
| `pending_memberships_count` | Odottavien kutsujen määrä |
| `admin_memberships_count` | Ryhmän ylläpitäjien määrä |
| `delegates_count` | Edustajien määrä |
| `discussions_count` | Suoraan ryhmään kuuluvien keskustelujen määrä |
| `polls_count` | Suoraan ryhmään kuuluvien kyselyiden määrä |
| `subgroups_count` | Alaryhmien määrä |

Vastaus voi sisältää myös muita ryhmäasetuksia, liittyviä pääryhmän tietueita ja API-käyttäjän jäsenyyksiä. Asiakasohjelman tulee ohittaa kentät, joita se ei käytä.

<!-- translation-section: get-a-group -->

### Hae ryhmä

Palauta yksi API-avaimen käyttäjälle näkyvä ryhmä.

`GET /api/b2/groups/:id_or_key_or_handle`

Tunnisteena voi käyttää ryhmän numeerista tunnusta, lyhyttä tunnusta tai ryhmätunnistetta.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

Vastaus sisältää ryhmän `groups`-taulukossa ja käyttää samoja kenttiä kuin listauspäätepiste. Jos API-avaimen käyttäjällä ei ole pääsyä pyydettyyn ryhmään, palvelin palauttaa oikeusvirheen.

<!-- translation-section: webhooks -->

## Webhookit

Käyttäjän API perustuu pyyntöihin: integraatio kutsuu Loomiota, kun se haluaa lukea tai muuttaa tietoja. Ryhmän webhook lähettää tietoa toiseen suuntaan. Loomio lähettää valitut ryhmän tapahtumat päätepisteeseesi niiden tapahtuessa, joten integraation ei tarvitse kysellä muutoksia REST API:sta.

Webhookit määritetään ryhmäkohtaisesti, ja niiden hallintaan tarvitaan ryhmän ylläpitäjän oikeudet. Voit hallita niitä Loomion käyttöliittymässä:

1. Avaa ryhmä.
2. Avaa ryhmän valikko ja valitse **Chat-integraatiot**.
3. Lisää integraatio, jonka sisältömuoto sopii päätepisteellesi. Yleiskäyttöiselle päätepisteelle sopii Mattermost/Markdown-muoto.
4. Anna nimi ja kohteen URL-osoite.
5. Valitse tapahtumat, jotka Loomion pitää lähettää automaattisesti.
6. Tallenna integraatio ja lähetä testiviesti valitsemalla **Testaa yhteys**.

Käytä HTTPS-kohdetta, jonka URL-osoitetta ei voi arvata. Loomio edellyttää, että kohdeosoite vastaa julkista osoitetta, ja estää pyynnöt paikallisiin tai yksityisiin verkko-osoitteisiin.

Agentit ja muut integraatiot voivat hallita webhookeja myös alla kuvattujen Bearer-todennettujen chatbot-päätepisteiden kautta. Resurssin nimi on `chatbots`, jotta se on yhteensopiva Loomion chat-integraatioiden kanssa. Se kattaa myös yleiset lähtevät webhookit.

<!-- translation-section: list-webhooks -->

### Listaa webhookit

Palauta ryhmälle määritetyt chat-integraatiot. API-avaimen käyttäjän on oltava kyseisen ryhmän ylläpitäjä. Vastaus sisältää kohteiden URL-osoitteet, joten sitä ei saa näyttää tavallisille ryhmän jäsenille.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

Vastaus sisältää `chatbots`-taulukon, jossa on seuraavat kentät:

| Kenttä | Kuvaus |
| --- | --- |
| `id` | Integraation tunnus, jota käytetään päivittämiseen ja poistamiseen |
| `group_id` | Ryhmä, jonka tapahtumia lähetetään |
| `name` | Integraation ylläpidossa käytettävä nimi |
| `kind` | `webhook` tarkoittaa lähtevää webhookia ja `matrix` Matrix-integraatiota |
| `webhook_kind` | Viestin muoto: `markdown`, `slack`, `discord`, `microsoft` tai `webex` |
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

API-avaimen käyttäjän on oltava `group_id`-ryhmän ylläpitäjä. Ennen tallennusta tarkistetaan, että kohteen URL-osoite on julkinen.

<!-- translation-section: update-a-webhook -->

### Päivitä webhook

`PATCH /api/b2/chatbots/:id`

Lähetä kentät, joita haluat muuttaa. Webhookia ei voi siirtää toiseen ryhmään muuttamalla `group_id`-kenttää.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Testaa webhookin kohde

Lähetä kohteeseen Markdown-muotoinen testiviesti ennen asetusten tallentamista tai sen jälkeen.

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

Asetusten poistaminen lopettaa tulevat lähetykset. Se ei poista ryhmän sisältöä Loomiosta.

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
| `poll_closing_soon` | Kyselyn sulkeutumisaika lähestyy |
| `poll_expired` | Kyselyn sulkeutumisaika saavutetaan |
| `poll_closed_by_user` | Käyttäjä sulkee kyselyn käsin |
| `poll_reopened` | Kysely avataan uudelleen |
| `outcome_created` | Johtopäätös julkaistaan |
| `outcome_updated` | Johtopäätöstä päivitetään |
| `outcome_review_due` | Johtopäätöksen tarkistamisen määräaika koittaa |
| `stance_created` | Ääni annetaan |
| `stance_updated` | Ääntä muutetaan |

Webhook kuuluu yhteen ryhmään ja vastaanottaa ryhmästä tilaamansa tapahtumat. Käyttäjät voivat myös valita integraation erikseen jakaessaan sisältöä tai lähettäessään joitakin ilmoituksia, vaikka vastaavaa automaattista tapahtumaa ei olisi valittu.

<!-- translation-section: http-delivery -->

### HTTP-lähetys

Loomio lähettää määritettyyn URL-osoitteeseen asynkronisen HTTP `POST` -pyynnön, jossa on seuraava otsake:

```text
Content-Type: application/json; charset=utf-8
```

Pyynnön aikakatkaisu on viisi sekuntia. `2xx`-vastaus, myös `204 No Content`, tulkitaan onnistumiseksi. Webhookin vastaanottajan kannattaa vastata nopeasti, käsitellä pidemmät tehtävät asynkronisesti ja varautua päällekkäisiin tai väärässä järjestyksessä saapuviin lähetyksiin.

Loomio ei tällä hetkellä lisää webhookin allekirjoitusta, jaetun salaisuuden otsaketta, tapahtumatunnusta eikä lähetystunnusta. Käsittele koko kohteen URL-osoitetta tunnistetietona äläkä julkaise sitä. Lisää URL-osoitteeseen vaikeasti arvattava tunniste, jos vastaanottava palvelu tukee sitä. Jos tarvitset vakaan, koneellisesti luettavan tapahtumamallin tai allekirjoitetun lähetyksen, käytä webhookia muutosilmoituksena ja hae ajantasaiset tietueet tunnistautumista edellyttävän käyttäjän API:n kautta.

<!-- translation-section: payload-formats -->

### Viestien muodot

Webhookin viestit on tarkoitettu näytettäviksi chat-palveluissa. Ne eivät sisällä täydellisiä Loomio-tietueita. Viestin linkit osoittavat sisältöön, jota tapahtuma koskee. Integraatio voi hakea ajantasaiset rakenteiset tiedot käyttäjän API:n kautta.

| Integraation muoto | JSON-pääkentät |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, enintään noin 1 900 merkkiä |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Esimerkiksi yleisen Markdown-muodon viestin runko on seuraavanlainen:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Viestin tarkka teksti riippuu tapahtumasta, ryhmän kieliasetuksesta, pelkän ilmoituksen asetuksesta ja Loomion versiosta. Vastaanottajan kannattaa käyttää valitun muodon dokumentoituja ylimmän tason kenttiä sen sijaan, että se tulkitsisi lauseiden sanamuotoa.

<!-- translation-section: search -->

## Haku

Hae keskusteluja, kommentteja, kyselyitä, ääniä ja johtopäätöksiä, jotka API-avaimen käyttäjä voi nähdä. Tuloksiin sisältyy julkista sisältöä, vaikka käyttäjä ei olisi ryhmän jäsen. Yksityisen sisällön näkyvyys määräytyy aiheen tavallisten käyttöoikeuksien mukaan.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `query` | Hakuteksti. Tukee tarkkoja ja likimääräisiä osumia |
| `group_id` | Rajaa tulokset yhteen näkyvään ryhmään |
| `org_id` | Rajaa tulokset näkyvään pääryhmään ja sen näkyviin alaryhmiin. Käytä suorille keskusteluille arvoa `0` |
| `type` | Rajaa tulokset yhteen tyyppiin: `Discussion`, `Comment`, `Poll`, `Stance` tai `Outcome` |
| `types` | Pilkuilla erotettu luettelo tulostyypeistä |
| `tag` | Rajaa tulokset aiheisiin, joissa on tämä tunniste |
| `author_id` | Rajaa tulokset yhden kirjoittajan sisältöön. Ilman `query`-parametria palauttaa kirjoittajan viimeaikaisen näkyvän toiminnan |
| `order` | Käytä arvoa `authored_at_desc`, jos haluat järjestää osumat kirjoitusajan mukaan |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

Vastaus sisältää `search_results`-taulukon. Jokainen tulos yksilöi löytyneen tietueen ja sen näkyvän asiayhteyden. Kenttiä ovat esimerkiksi `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` ja `tags`. Kentän arvo on `null`, jos kenttä ei koske tulosta.

<!-- translation-section: participation-report -->

## Osallistumisraportti

Palauta samat koostetut osallistumistiedot, joita Loomion osallistumisraportti käyttää.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `section` | Raportin osio: `base`, `users` tai `countries`. Käytä arvoa `users`, kun haluat nähdä toiminnan henkilöittäin |
| `group_scope` | `custom` tai `my`. Vanhaa arvoa `all` käsitellään arvona `my`, koska käyttäjän API-avaimet eivät anna pääsyä koko Loomio-asennuksen tietoihin |
| `group_ids` | Pilkuilla erotetut ryhmätunnukset, kun `group_scope=custom`. Ryhmät, joiden jäsen API:n käyttäjä ei ole, jätetään huomiotta |
| `start_month` | Ensimmäinen mukaan otettava kuukausi muodossa `YYYY-MM`. Oletus on 12 kuukautta sitten |
| `end_month` | Viimeinen mukaan otettava kuukausi muodossa `YYYY-MM`. Oletus on nykyinen kuukausi |
| `interval` | `base`-osion aikaväli: `day`, `week`, `month` tai `year` |
| `member_type` | Käytä arvoa `delegate` yhdessä arvon `section=users` kanssa, kun haluat palauttaa vain nykyiset delegaatit |

Henkilö on delegaatti, jos hänellä on aktiivinen delegaatin jäsenyys jossakin valitussa ryhmässä. Hänen lukumääränsä lasketaan yhteen kaikista valituista ryhmistä. Delegaatin rivi palautetaan, vaikka kaikki toiminnan lukumäärät olisivat nollia. Lukumäärät kattavat ketjut, kommentit, kyselyt, äänet, johtopäätökset ja reaktiot. Ne eivät kuvaa äänestysaktiivisuutta. Käyttäjän riveillä näkyvät myös tunnistettujen äänestyslippujen määrät: lähetetyt, annetut ja käyttämättä jääneet. Nimettömät kyselyt eivät sisälly henkilökohtaisiin äänimääriin. `all_votes_cast` on tosi vain, jos vähintään yksi äänestyslippu on lähetetty ja kaikki lähetetyt äänestysliput on käytetty.

API noudattaa samoja ryhmän näkyvyyssääntöjä kuin Loomion oma raportti. Käyttäjän API-avain ei voi paljastaa raporttitietoja ryhmistä, joihin käyttäjällä ei ole pääsyä.

<!-- translation-section: example -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

`users`-taulukko sisältää täydet toimintatiedot kullakin rivillä:

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
| `group_id` | Ryhmä, johon keskusteluketju luodaan |
| `title` | Keskusteluketjun otsikko, pakollinen |
| `description` | Keskusteluketjun taustatiedot, valinnainen |
| `description_format` | `md` tai `html`, valinnainen, oletus `md` |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmä saa ilmoituksen uudesta keskusteluketjusta |
| `recipient_user_ids` | Niiden käyttäjien tunnukset taulukkona, joille lähetetään ilmoitus tai kutsu keskusteluketjuun |
| `recipient_emails` | Keskusteluketjuun kutsuttavien henkilöiden sähköpostiosoitteet taulukkona |
| `recipient_message` | Sähköpostikutsuun lisättävä viesti |

<!-- translation-section: example-2 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Hae keskustelu

Hae keskustelu sen numeerisella tunnuksella tai merkkijonomuotoisella avaimella.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Listaa keskustelut

Listaa ryhmän keskustelut, jotka API-avaimen käyttäjä näkee. Julkisesti näkyvän ryhmän julkiset keskustelut voi listata myös henkilö, joka ei kuulu ryhmään. Yksityiset keskustelut näkyvät vain käyttäjille, joilla on niihin lukuoikeus Loomiossa.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunnus, jonka keskustelut listataan |
| `status` | Merkkijono, valinnainen, oletus `open`. Arvot: `open`, `closed`, `all` |
| `limit` | Kokonaisluku, valinnainen, oletus 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletus 0. Sivutuksen aloituskohta |

Vanhat parametrit `per` ja `from` toimivat edelleen parametrien `limit` ja `offset` vaihtoehtoisina niminä.

<!-- translation-section: example-4 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Listaa keskusteluketjut

Listaa API-avaimen käyttäjälle näkyvät keskustelu- ja kyselyketjut viimeisimmän toiminnan mukaan järjestettyinä. Keskusteluketjun tunnus on sen `topic_id`.

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

## Lue keskusteluketju

Lue keskusteluketju, sen aikajärjestyksessä olevat tapahtumat tai koko näkyvä Markdown-asiakirja.

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

`items`-rajapinta palauttaa tapahtumat järjestyksessä, mukaan lukien näkyvät kommentit, kyselyt, äänet ja johtopäätökset. `markdown`-rajapinta palauttaa koko näkyvän keskusteluketjun yhtenä Markdown-asiakirjana. Äänten perustelut sisältyvät vastaukseen vain, jos API-avaimen käyttäjä saa nähdä ne.

Kaikki keskusteluketjujen rajapinnat noudattavat samoja käyttöoikeuksia kuin Loomion käyttöliittymä. API-avain ei anna pääsyä keskusteluketjuun, jota käyttäjä ei normaalisti voi avata.

<!-- translation-section: edit-discussion -->

## Muokkaa keskustelua

Muokkaa keskustelua API-avaimen käyttäjänä. Samat käyttöoikeudet pätevät kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä keskustelua.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `title` | Päivitetty otsikko |
| `description` | Päivitetyt taustatiedot |
| `description_format` | `md` tai `html`, valinnainen, oletus `md` |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmä saa ilmoituksen muokkauksesta |
| `recipient_user_ids` | Niiden käyttäjien tunnukset taulukkona, joille lähetetään ilmoitus tai kutsu keskusteluketjuun |
| `recipient_emails` | Keskusteluketjuun kutsuttavien henkilöiden sähköpostiosoitteet taulukkona |
| `recipient_message` | Sähköpostikutsuun lisättävä viesti |

<!-- translation-section: example-7 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Poista keskustelu pehmeästi

Poista keskustelu pehmeästi API-avaimen käyttäjänä. Keskustelu poistuu käytöstä, mutta sen tietue säilyy.

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
| `discussion_id` | Kokonaisluku, pakollinen. Sen keskustelun tunnus, johon kommentti lisätään |
| `body` | Kommentin teksti, pakollinen, ellei liitettä ole annettu |
| `body_format` | `md` tai `html`, valinnainen, oletus `md` |

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
| `body_format` | `md` tai `html`, valinnainen, oletus `md` |

<!-- translation-section: example-10 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Poista kommentti pehmeästi

Poista kommentti pehmeästi API-avaimen käyttäjänä. Kommentti poistuu käytöstä ja sen teksti piilotetaan, mutta kommentin tietue säilyy.

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
| `group_id` | Kokonaisluku, valinnainen, oletusarvo null. Sen ryhmän tunnus, johon kysely luodaan. Jos annat `discussion_id`-arvon, `group_id` ohitetaan |
| `discussion_id` | Kokonaisluku, valinnainen, oletusarvo null. Sen keskusteluketjun tunnus, johon kysely lisätään |
| `title` | Merkkijono, pakollinen. Kyselyn otsikko |
| `poll_type` | Merkkijono, pakollinen. Arvot: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Merkkijono, valinnainen. Kyselyn sisältöteksti |
| `details_format` | Merkkijono, valinnainen, oletusarvo `md`. Arvot: `md` tai `html` |
| `options` | Merkkijonojen taulukko. Jos `poll_type` on `proposal`, kelvolliset arvot ovat `agree`, `disagree`, `abstain` ja `block`. Jos `poll_type` on `meeting`, anna ISO 8601 -muotoisia päivämääriä tai päivämääriä ja kellonaikoja. Muissa kyselytyypeissä mikä tahansa merkkijono kelpaa |
| `closing_at` | ISO 8601 -muotoinen merkkijono tai null, oletusarvo null. Esimerkki: `2026-09-01T12:00:00Z`. Jos arvo on null, äänestäminen on pois käytöstä ja kysely katsotaan keskeneräiseksi |
| `specified_voters_only` | Totuusarvo, valinnainen, oletusarvo false. Jos arvo on true, vain nimetyt henkilöt voivat äänestää. Jos arvo on false, kaikki ryhmän jäsenet kutsutaan äänestämään |
| `hide_results` | Merkkijono, valinnainen, oletusarvo `off`. Arvot: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Totuusarvo, oletusarvo false. Näytä vaihtoehdot äänestäjille satunnaisessa järjestyksessä |
| `anonymous` | Totuusarvo, valinnainen, oletusarvo false. Piilota äänestäjien henkilöllisyydet |
| `recipient_audience` | `group` tai null, valinnainen, oletusarvo null. Jos arvo on `group`, koko ryhmälle lähetetään ilmoitus |
| `notify_on_closing_soon` | Merkkijono, valinnainen, oletusarvo `nobody`. Arvot: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Ilmoitettavien tai kutsuttavien käyttäjien tunnusten taulukko |
| `recipient_emails` | Äänestämään kutsuttavien henkilöiden sähköpostiosoitteiden taulukko |
| `recipient_message` | Sähköpostikutsuun lisättävä viesti |
| `notify_recipients` | Totuusarvo, oletusarvo false. Jos arvo on false, henkilöt lisätään lähettämättä ilmoituksia. Jos arvo on true, kaikki tällä pyynnöllä kutsutut saavat ilmoituksen sähköpostitse |

<!-- translation-section: example-12 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Näytä kysely

Hae kysely sen numeerisella tunnuksella tai merkkijonomuotoisella avaimella.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Listaa kyselyt

Listaa ryhmän kyselyt, jotka näkyvät API-avaimen käyttäjälle. Julkisesti näkyvän ryhmän julkiset kyselyt voi listata myös henkilö, joka ei kuulu ryhmään. Yksityiset kyselyt näkyvät vain käyttäjille, joilla on oikeus lukea niitä Loomiossa. Vastaus sisältää kunkin näkyvän kyselyn nykyisen lopputuloksen, joten voit käyttää arvoa `status=closed` päätettyjen ehdotusten listaamiseen.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunnus, jonka kyselyt listataan |
| `status` | Merkkijono, valinnainen, oletusarvo `active`. Arvot: `active`, `closed`, `all` |
| `limit` | Kokonaisluku, valinnainen, oletusarvo 50. Sivun koko |
| `offset` | Kokonaisluku, valinnainen, oletusarvo 0. Sivutuksen aloituskohta |

Vanhat parametrit `per` ja `from` toimivat edelleen parametrien `limit` ja `offset` vaihtoehtoisina niminä.

<!-- translation-section: example-14 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Muokkaa kyselyä

Muokkaa kyselyä API-avaimen käyttäjänä. Samat käyttöoikeudet pätevät kuin Loomiossa: käyttäjällä on oltava oikeus muokata kyseistä kyselyä.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `title` | Päivitetty otsikko |
| `details` | Päivitetty kyselyn kuvaus |
| `details_format` | `md` tai `html`, valinnainen, oletusarvo `md` |
| `options` | Päivitetyt vaihtoehtojen nimet. Vaihtoehtojen muuttaminen voi vaikuttaa annettuihin ääniin kyselyn tilan mukaan |
| `closing_at` | ISO 8601 -muotoinen merkkijono tai null |
| `recipient_audience` | `group` tai null. Jos arvo on `group`, koko ryhmälle lähetetään ilmoitus |
| `recipient_user_ids` | Ilmoitettavien tai kutsuttavien käyttäjien tunnusten taulukko |
| `recipient_emails` | Äänestämään kutsuttavien henkilöiden sähköpostiosoitteiden taulukko |
| `recipient_message` | Sähköpostikutsuun lisättävä viesti |

<!-- translation-section: example-15 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Poista kysely pehmeästi

Poista kysely pehmeästi API-avaimen käyttäjänä. Kysely poistuu käytöstä, mutta sen tietue säilyy.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Listaa jäsenyydet

Listaa jäsenyydet, jotka näkyvät API-avaimen käyttäjälle. Ryhmän jäsenet voivat nähdä jäsenten nimet, tunnukset, tittelit ja roolit. Sähköpostiosoitteet näkyvät vain API-avaimen käyttäjän omalta tililtä tai silloin, kun API-avaimen käyttäjä on ryhmän ylläpitäjä.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunnus, jonka jäsenyydet listataan |

<!-- translation-section: example-17 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Hallinnoi jäsenyyksiä

Lähetä luettelo sähköpostiosoitteista. Uudet osoitteet kutsutaan ryhmään. Toisin kuin jäsenyyksien listaaminen, tämä toiminto edellyttää ryhmän ylläpitäjän oikeuksia.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parametrit

| Nimi | Kuvaus |
| --- | --- |
| `group_id` | Kokonaisluku, pakollinen. Sen ryhmän tunnus, jonka jäsenyyksiä hallinnoidaan |
| `emails` | Merkkijonojen taulukko, pakollinen. Ryhmään kutsuttavien henkilöiden sähköpostiosoitteet |
| `remove_absent` | Totuusarvo. Jos arvo on true, ryhmästä poistetaan kaikki, joiden sähköpostiosoite ei ole luettelossa |

<!-- translation-section: example-18 -->

### Esimerkki

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Jos annat arvon `remove_absent=1`, kaikki ryhmän jäsenet, joita ei ole luettelossa, poistetaan ryhmästä. Ole varovainen: voit poistaa ryhmästäsi kaikki jäsenet.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Vastaus on olio, jossa on `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
