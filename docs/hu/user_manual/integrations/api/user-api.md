---
title: Felhasználói API
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
  introduction: 6a8c304efad5e193
  authentication-change: 8595394b3e99d846
  response-size-and-related-records: 336382675a734c26
  endpoint-summary: 51c20df34e786f90
  groups: 416e445b12c9f929
  list-groups: 61e1544f5cab5188
  get-a-group: 68ef0d7b55abbc68
  webhooks: de42acce7868f13c
  list-webhooks: 8ee5dd2b4886dd75
  create-a-webhook: 68fbc313dec80d7f
  update-a-webhook: 4607e3f00a9ca2c0
  test-a-webhook-destination: 1420e3e8a218d19c
  delete-a-webhook: e071ab6f6c952750
  event-types: 7c65d4eb4c20984b
  http-delivery: d9067ca82281461f
  payload-formats: 0d4aac5d1c4ed0df
  search: b173b3a8653861fe
  params: 46689ee9ffc52b36
  participation-report: db1611172dbee2ba
  params-2: 7d8173437418226e
  example: 44005c7a5322bd3c
  create-discussion: f8af0601adc0926c
  params-3: 0b68981fa9cfc3c5
  example-2: 1b153746050d6ef7
  show-discussion: 27bc4592c6b00f18
  example-3: 784553fa46b05a22
  list-discussions: 07a09ee2cb8ed8af
  params-4: 51e4e3c0edfbf6a4
  example-4: b4a79b23cff114d4
  list-threads: 01dfeba9f5e7ddea
  params-5: efc7a6035ca0f437
  example-5: 5b540b5d089ee459
  read-thread: 03c47160363d4425
  example-6: 16028691a5847913
  edit-discussion: e4471a42a9c8dde8
  params-6: a68340cd14fe8b03
  example-7: d7a8af42ee8c3b8a
  soft-delete-discussion: 9fa8c2db73696dac
  example-8: 5c19b934bfd67843
  create-comment: 53dc3ff4e93bd7a7
  params-7: 34f67fc6e50337e3
  example-9: 52a99d7feed14cc1
  edit-comment: f2a62f719d0b1b22
  params-8: 3736f49b44d16deb
  example-10: 6420c8e56783fa22
  soft-delete-comment: 7ff7737773e1eb3d
  example-11: 0f3a5b5abfca4020
  create-poll: 26cb0dd337e6a248
  params-9: 4cf39bbf1f354cba
  example-12: 5aa979418c6e1d79
  show-poll: bbfe46a434896c75
  example-13: 26a88ad91585edd2
  list-polls: 71465827ba43ab85
  params-10: 6e8ade5a02484ae7
  example-14: 6f31a4d032c805bc
  edit-poll: b9b2061fb45242f1
  params-11: 5aba3b85e2f52ffa
  example-15: 65055ca15b3280b4
  soft-delete-poll: 457528422c6d6d11
  example-16: a719ba5488a406c7
  list-memberships: ea0647475db52608
  params-12: bb891859fee16c3a
  example-17: 747605072570c858
  manage-memberships: d4a6c7f85de0935a
  params-13: 6404df7dc0d7b2a1
  example-18: 6d6ad447cee9646a
title_source: c23fb6526b722360
title_generated: 788437eb515e46bd
---

<!-- translation-section: introduction -->

# A Loomio felhasználói API dokumentációja

<!-- seo-description: A Loomio felhasználói API-jával más szoftverekből hozhatsz létre és kezelhetsz beszélgetéseket, hozzászólásokat, szavazásokat, szálakat és csoporttagságokat. -->

A `/api/b2` a Loomióval való integrációkhoz készült felhasználói API. Egy felhasználói fiók API-kulcsát használja, és minden műveletet az adott felhasználó nevében hajt végre.

A csoportműveleteknél az API-kulcs tulajdonosának tagságai és csoportjogosultságai érvényesek. A példányadminisztrátori szerepkör nem ad az API-kulcsnak további hozzáférést csoportokhoz vagy tartalmakhoz. A példány szintű adminisztrációhoz használd a Server API-t.

Annak a Loomio-fióknak az API-kulcsát használd, amelynek nevében a műveleteket végre szeretnéd hajtani. Külön botfiók hasznos, ha az integrációt nem szeretnéd szavazásokra meghívni, vagy nem szeretnéd, hogy értesítéseket kapjon.

Bejelentkezés után az API-kulcsodat és a csoportazonosítókat az [API-hozzáférési oldalon](/profile/api_access) találod.

Az API-kulcsot az `Authorization: Bearer` fejlécben küldd el. A lekérdezési karakterláncban megadott API-kulcsokat a rendszer elutasítja, mert az URL-eket a proxyk és a hozzáférési naplók rögzíthetik.

<!-- translation-section: authentication-change -->

### A hitelesítés változása

Korábban az API-kulcsot `api_key` URL-paraméterként is meg lehetett adni. A `?api_key=YOUR_API_KEY` paramétert használó kérések már nem működnek. Helyette a HTTP `Authorization` fejlécet használd:

```text
Authorization: Bearer YOUR_API_KEY
```

A példákban a `YOUR_API_KEY` API-kulcs, a `123` csoportazonosító és a `https://www.loomio.com/` URL szerepel. Cseréld ki ezeket a saját API-kulcsodra, csoportazonosítódra és a Loomio-telepítésed URL-jére.

<!-- translation-section: response-size-and-related-records -->

## Válaszméret és kapcsolódó rekordok

A felhasználói API válaszai összetett formátumúak: az elsődleges rekordok mellett kapcsolódó rekordokat is tartalmaznak, például témákat, csoportokat, felhasználókat, szavazásokat és reakciókat. Így a kliens egyetlen kérésből feltöltheti a helyi rekordtárát, de a válasz több adatot tartalmazhat, mint amennyire egy egyszerű integrációnak szüksége van.

A `compact=1` paraméterrel kihagyhatod a nagy méretű kapcsolódó témákat, csoportokat, szülőcsoportokat, tagságokat, reakciókat, címkéket és fordításokat. Az elsődleges rekordok és a tartalmuk értelmezéséhez szükséges kapcsolódó rekordok megmaradnak.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Ha pontosan szeretnéd szabályozni a választ, add meg az `exclude_types` paraméterben az egyes számú rekordtípusokat szóközzel elválasztva. Például az `exclude_types=group reaction` kihagyja a kapcsolódó csoportokat és reakciókat. Gyakori értékek: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` és `topic_item`. A kizárás a kapcsolódó rekordokra vonatkozik, nem a végponttól kért elsődleges erőforrásra.

A gyűjteményt visszaadó válaszok tartalmazzák a `meta.total` értéket, ha a gyűjtemény pontos mérete meghatározható. Az összesítést a `limit` és az `offset` alkalmazása előtt számítja ki a rendszer. Azok a végpontok, például a keresés, amelyek szándékosan korlátozott eredményhalmazt adnak vissza, kihagyják a `meta.total` mezőt ahelyett, hogy `null` értéket adnának vissza.

<!-- translation-section: endpoint-summary -->

## Végpontok áttekintése

| Metódus | Végpont | Cél |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Az API-kulcs tulajdonosához tartozó csoportok listázása |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Egy látható csoport lekérése |
| `GET` | `/api/b2/reports` | Részvételi jelentés készítése |
| `GET` | `/api/b2/search` | Keresés a látható beszélgetések, hozzászólások, szavazások, leadott szavazatok és következtetések között |
| `POST` | `/api/b2/discussions` | Beszélgetés létrehozása |
| `GET` | `/api/b2/discussions/:id` | Beszélgetés lekérése |
| `GET` | `/api/b2/discussions` | Egy csoport beszélgetéseinek listázása |
| `PATCH` | `/api/b2/discussions/:id` | Beszélgetés szerkesztése |
| `DELETE` | `/api/b2/discussions/:id` | Beszélgetés logikai törlése |
| `GET` | `/api/b2/threads` | Látható beszélgetésszálak és önálló szavazási szálak listázása |
| `GET` | `/api/b2/threads/:topic_id` | Szál lekérése |
| `GET` | `/api/b2/threads/:topic_id/items` | Egy szál elemeinek lekérése sorrendben |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Teljes szál lekérése Markdown-formátumban |
| `POST` | `/api/b2/comments` | Hozzászólás vagy válasz létrehozása |
| `PATCH` | `/api/b2/comments/:id` | Hozzászólás szerkesztése |
| `DELETE` | `/api/b2/comments/:id` | Hozzászólás logikai törlése |
| `POST` | `/api/b2/polls` | Szavazás létrehozása |
| `GET` | `/api/b2/polls/:id` | Szavazás lekérése |
| `GET` | `/api/b2/polls` | Egy csoport szavazásainak listázása |
| `PATCH` | `/api/b2/polls/:id` | Szavazás szerkesztése |
| `DELETE` | `/api/b2/polls/:id` | Szavazás logikai törlése |
| `GET` | `/api/b2/memberships` | Egy csoport tagságainak listázása |
| `POST` | `/api/b2/memberships` | Tagok hozzáadása és szükség esetén a listából hiányzó tagok eltávolítása |
| `GET` | `/api/b2/chatbots` | Egy csoport csevegési integrációinak és webhookjainak listázása |
| `POST` | `/api/b2/chatbots` | Csevegési integráció vagy webhook létrehozása |
| `PATCH` | `/api/b2/chatbots/:id` | Csevegési integráció vagy webhook frissítése |
| `DELETE` | `/api/b2/chatbots/:id` | Csevegési integráció vagy webhook törlése |
| `POST` | `/api/b2/chatbots/check` | Webhook-kapcsolat tesztelése |

<!-- translation-section: groups -->

## Csoportok

<!-- translation-section: list-groups -->

### Csoportok listázása

Azoknak a csoportoknak a lekérése, amelyekben az API-kulcs tulajdonosának aktív tagsága van.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

A válasz az összes megfelelő rekordot tartalmazza egy lapozás nélküli `groups` tömbben. Szülőcsoportok és alcsoportok is szerepelnek benne, köztük olyan csoportok is, amelyek előfizetése jelenleg nem aktív. Ellenőrizd az `enabled` mezőt, ha az integrációnak csak aktív csoportokkal szabad működnie.

A fontosabb csoportmezők:

| Mező | Leírás |
| --- | --- |
| `id` | Más felhasználói API-végpontok által használt numerikus csoportazonosító |
| `key` | A Loomio URL-jeiben használt állandó rövid kulcs |
| `handle` | A csoport ember által olvasható azonosítója |
| `name` | A csoport neve |
| `full_name` | A csoport neve a szülőcsoport megjelölésével |
| `parent_id` | Alcsoport esetén a szülőcsoport numerikus azonosítója, egyébként `null` |
| `enabled` | Aktív-e a csoport és az előfizetése |
| `memberships_count` | Az aktív és függőben lévő tagságok száma |
| `accepted_memberships_count` | Az elfogadott tagságok száma |
| `pending_memberships_count` | A függőben lévő meghívások száma |
| `admin_memberships_count` | A csoportadminisztrátorok száma |
| `delegates_count` | A küldöttek száma |
| `discussions_count` | A közvetlenül a csoporthoz tartozó beszélgetések száma |
| `polls_count` | A közvetlenül a csoporthoz tartozó szavazások száma |
| `subgroups_count` | Az alcsoportok száma |

A válasz további csoportbeállításokat, kapcsolódó szülőcsoport-rekordokat és az API-felhasználó tagságait is tartalmazhatja. A kliensek hagyják figyelmen kívül a nem használt mezőket.

<!-- translation-section: get-a-group -->

### Csoport lekérése

Az API-kulcs tulajdonosa számára látható csoport lekérése.

`GET /api/b2/groups/:id_or_key_or_handle`

Az azonosító lehet a csoport numerikus azonosítója, kulcsa vagy olvasható azonosítója.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

A válasz a `groups` tömbben tartalmazza a csoportot, ugyanazokkal a mezőkkel, mint a listázó végpont. Ha az API-kulcs tulajdonosa nem fér hozzá a kért csoporthoz, a kérés jogosultsági hibát ad vissza.

<!-- translation-section: webhooks -->

## Webhookok

A felhasználói API kérésekre válaszol: az integráció akkor hívja meg a Loomiót, amikor adatot szeretne olvasni vagy módosítani. A csoport webhookja az ellenkező irányban továbbít adatot. A Loomio a kiválasztott csoporteseményeket az előfordulásukkor elküldi a végpontodra, így az integrációnak nem kell rendszeresen lekérdeznie a REST API-t a változásokért.

A webhookokat csoportonként kell beállítani, és kezelésükhöz csoportadminisztrátori jogosultság szükséges. A Loomio felületén így kezelheted őket:

1. Nyisd meg a csoportot.
2. Nyisd meg a csoport menüjét, és válaszd a **Csevegési integrációk** lehetőséget.
3. Add hozzá azt az integrációt, amelynek adatformátumát a végpontod fogadni tudja. Általános célú végponthoz használd a Mattermost/Markdown formátumot.
4. Adj meg egy nevet és a cél URL-t.
5. Válaszd ki azokat az eseményeket, amelyeket a Loomio automatikusan elküldjön.
6. Mentsd az integrációt, majd a **Kapcsolat tesztelése** lehetőséggel küldj tesztüzenetet.

Olyan HTTPS-címet használj célként, amelynek URL-je nem található ki könnyen. A Loomio megköveteli, hogy a cél nyilvános címre mutasson, és blokkolja a helyi vagy magánhálózati címekre irányuló kéréseket.

Az ügynökök és más integrációk az alább ismertetett, Bearer-hitelesítést használó chatbotvégpontokon keresztül is kezelhetik a webhookokat. Az erőforrás neve `chatbots`, hogy kompatibilis legyen a Loomio csevegési integrációival, de általános kimenő webhookokat is jelöl.

<!-- translation-section: list-webhooks -->

### Webhookok listázása

Egy csoporthoz beállított csevegési integrációk lekérése. Az API-kulcs tulajdonosának a csoport adminisztrátorának kell lennie. A válasz tartalmazza a cél URL-eket, ezért nem szabad elérhetővé tenni a csoport többi tagja számára.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

A válasz egy `chatbots` tömböt tartalmaz a következő mezőkkel:

| Mező | Leírás |
| --- | --- |
| `id` | Az integráció frissítéséhez és törléséhez használt azonosító |
| `group_id` | Az eseményekhez tartozó csoport |
| `name` | Az integráció adminisztrációs neve |
| `kind` | Kimenő webhook esetén `webhook`, Matrix-integráció esetén `matrix` |
| `webhook_kind` | Az adat formátuma: `markdown`, `slack`, `discord`, `microsoft` vagy `webex` |
| `server` | Cél-URL |
| `event_kinds` | Automatikusan elküldött események |
| `notification_only` | Az üzenetek csak az értesítés címét tartalmazzák-e |

<!-- translation-section: create-a-webhook -->

### Webhook létrehozása

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

Az API-kulcshoz tartozó felhasználónak a `group_id` által jelölt csoport adminisztrátorának kell lennie. Mentés előtt a rendszer ellenőrzi, hogy a cél nyilvánosan elérhető URL-e.

<!-- translation-section: update-a-webhook -->

### Webhook frissítése

`PATCH /api/b2/chatbots/:id`

Küldd el a módosítani kívánt mezőket. A `group_id` módosításával nem helyezheted át a webhookot másik csoportba.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Webhook céljának tesztelése

A beállítások mentése előtt vagy után küldj a cél címére egy Markdown-kompatibilis tesztüzenetet.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Webhook törlése

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

A beállítás törlése leállítja a későbbi kézbesítéseket. A Loomio-csoport tartalmát nem törli.

<!-- translation-section: event-types -->

### Eseménytípusok

A webhook ezekre az eseménytípusokra iratkozhat fel:

| Esemény | Mikor küldi el a rendszer |
| --- | --- |
| `new_discussion` | Beszélgetés indul |
| `discussion_edited` | Szerkesztenek egy beszélgetést |
| `new_comment` | Hozzászólás születik |
| `poll_created` | Szavazás indul |
| `poll_edited` | Szerkesztenek egy szavazást |
| `poll_closing_soon` | Közeledik egy szavazás lezárási ideje |
| `poll_expired` | Egy szavazás eléri a lezárási idejét |
| `poll_closed_by_user` | Valaki kézzel lezár egy szavazást |
| `poll_reopened` | Újra megnyitnak egy szavazást |
| `outcome_created` | Közzétesznek egy következtetést |
| `outcome_updated` | Frissítenek egy következtetést |
| `outcome_review_due` | Esedékessé válik egy következtetés felülvizsgálata |
| `stance_created` | Valaki leadja a szavazatát |
| `stance_updated` | Valaki módosítja a szavazatát |

A webhook egy csoporthoz tartozik, és annak feliratkozott eseményeit fogadja. Az integrációt az emberek egyes értesítések megosztásakor vagy küldésekor külön is kiválaszthatják, akkor is, ha a megfelelő automatikus esemény nincs kiválasztva.

<!-- translation-section: http-delivery -->

### HTTP-kézbesítés

A Loomio aszinkron HTTP `POST` kérést küld a beállított URL-re ezzel a fejléccel:

```text
Content-Type: application/json; charset=utf-8
```

A kérés időkorlátja öt másodperc. A rendszer minden `2xx` választ sikeresnek tekint, beleértve a `204 No Content` választ is. A webhookot fogadó szolgáltatás válaszoljon gyorsan, a hosszabb feladatokat dolgozza fel aszinkron módon, és kezelje a többször vagy eltérő sorrendben érkező kézbesítéseket.

A Loomio jelenleg nem ad a webhookhoz aláírást, közös titkot tartalmazó fejlécet, eseményazonosítót vagy kézbesítési azonosítót. A teljes cél-URL-t kezeld hozzáférési adatként, ne tedd nyilvánossá, és használj benne nehezen kitalálható tokent, ha a fogadó szolgáltatás ezt támogatja. Ha állandó, géppel feldolgozható eseménysémára vagy aláírt kézbesítésre van szükséged, használd a webhookot változásjelzésként, majd kérd le az aktuális rekordokat a hitelesített felhasználói API-n keresztül.

<!-- translation-section: payload-formats -->

### Adatformátumok

A webhookok csevegőszolgáltatásoknak szánt üzeneteket küldenek. Ezek nem teljes Loomio-rekordok. Az üzenetben lévő hivatkozások megmutatják, melyik Loomio-tartalmat érinti az esemény. Ha az integrációnak strukturált, aktuális adatokra van szüksége, lekérheti őket a felhasználói API-n keresztül.

| Integráció formátuma | Fő JSON-mezők |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, körülbelül 1900 karakterre korlátozva |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Az általános Markdown-formátum például ilyen szerkezetű üzenettörzset küld:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Az üzenet pontos szövege az eseménytől, a csoport nyelvi beállításától, a csak értesítést tartalmazó beállítástól és a Loomio verziójától függ. Az üzenetet fogadó szolgáltatás a választott formátum dokumentált felső szintű mezőire támaszkodjon az egyes mondatok elemzése helyett.

<!-- translation-section: search -->

## Keresés

Keress az API-kulcshoz tartozó felhasználó számára látható beszélgetések, hozzászólások, szavazások, leadott szavazatok és következtetések között. A találatok között nyilvános tartalom is szerepelhet olyan csoportból, amelynek a felhasználó nem tagja. A privát tartalmakra a témák szokásos láthatósági szabályai vonatkoznak.

`GET /api/b2/search`

<!-- translation-section: params -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `query` | Keresett szöveg. Pontos és közelítő egyezések is támogatottak |
| `group_id` | A találatokat egy látható csoportra korlátozza |
| `org_id` | A találatokat egy látható szülőcsoportra és annak látható alcsoportjaira korlátozza. Közvetlen beszélgetésekhez használd a `0` értéket |
| `type` | A találatokat egy típusra korlátozza: `Discussion`, `Comment`, `Poll`, `Stance` vagy `Outcome` |
| `types` | A találattípusok vesszővel elválasztott listája |
| `tag` | A találatokat az ezzel a címkével ellátott témákra korlátozza |
| `author_id` | A találatokat egy szerző tartalmaira korlátozza. `query` nélkül a szerző közelmúltbeli, látható tevékenységét adja vissza |
| `order` | Állítsd `authored_at_desc` értékre, hogy az egyező tartalmakat a létrehozásuk ideje szerint rendezze |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

A válasz egy `search_results` tömböt tartalmaz. Minden találat azonosítja az egyező rekordot és annak látható környezetét. A mezők között szerepel a `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` és `tags`. Az adott találatra nem vonatkozó mezők értéke `null`.

<!-- translation-section: participation-report -->

## Részvételi jelentés

A Loomio Részvételi jelentésében használt összesített részvételi adatokat adja vissza.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `section` | A jelentés része: `base`, `users` vagy `countries`. Személyenkénti tevékenységhez használd a `users` értéket |
| `group_scope` | `custom` vagy `my`. A régi `all` értéket a rendszer `my` értékként kezeli, mert a felhasználói API-kulcsok nem adnak hozzáférést a teljes példányhoz |
| `group_ids` | Vesszővel elválasztott csoportazonosítók, ha `group_scope=custom`. A rendszer figyelmen kívül hagyja azokat az azonosítókat, amelyekhez az API-felhasználó nem rendelkezik tagsággal |
| `start_month` | Az első szerepeltetendő hónap `YYYY-MM` formátumban; alapértelmezés szerint 12 hónappal ezelőtt |
| `end_month` | Az utolsó szerepeltetendő hónap `YYYY-MM` formátumban; alapértelmezés szerint az aktuális hónap |
| `interval` | A `base` rész időköze: `day`, `week`, `month` vagy `year` |
| `member_type` | Állítsd `delegate` értékre a `section=users` mellett, hogy csak a jelenlegi küldöttek jelenjenek meg |

Valaki akkor küldött, ha a kiválasztott csoportok bármelyikében aktív küldötti tagsága van. A rendszer az összes kiválasztott csoportból összesíti az adatait. A küldöttek akkor is szerepelnek a jelentésben, ha minden tevékenységi számuk nulla. A számok a témákat, hozzászólásokat, szavazásokat, leadott szavazatokat, következtetéseket és reakciókat fedik le; nem a szavazási részvételi arányt mutatják. A felhasználói sorok a névhez kötött szavazólapok kiadott, leadott és elmulasztott számát is tartalmazzák. Az anonim szavazások minden személyenkénti szavazatszámból kimaradnak. Az `all_votes_cast` csak akkor igaz, ha legalább egy szavazólapot kiadtak, és mindegyiket leadták.

Az API ugyanazokat a csoportláthatósági szabályokat alkalmazza, mint a Loomio felületén elérhető jelentés. A felhasználói API-kulcs nem teszi elérhetővé azoknak a csoportoknak a jelentésadatait, amelyekhez a felhasználó nem fér hozzá.

<!-- translation-section: example -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

A `users` tömb teljes tevékenységi sorokat tartalmaz:

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

## Beszélgetés létrehozása

Hozz létre egy beszélgetést az API-kulcshoz tartozó felhasználóként.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | A csoport, amelyben a téma létrejön |
| `title` | A téma címe, kötelező |
| `description` | A téma leírása, nem kötelező |
| `description_format` | `md` vagy `html`, nem kötelező, alapértelmezett értéke `md` |
| `recipient_audience` | `group` vagy null. Ha `group`, a teljes csoport értesítést kap az új témáról |
| `recipient_user_ids` | Az értesítendő vagy a témába meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A témába meghívandó személyek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóban szereplő üzenet |

<!-- translation-section: example-2 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Beszélgetés lekérése

Kérj le egy beszélgetést a számmal megadott azonosítója vagy a szöveges kulcsa alapján.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Beszélgetések listázása

Listázd az API-kulcshoz tartozó felhasználó számára látható beszélgetéseket egy csoportban. Nyilvánosan látható csoport esetén a csoporton kívüli felhasználó is listázhatja a nyilvános beszélgetéseket. A privát beszélgetéseket csak azok érhetik el, akik a Loomióban is olvashatják őket.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a beszélgetéseit listázni szeretnéd |
| `status` | Szöveg, nem kötelező, alapértelmezett értéke `open`. Értékek: `open`, `closed`, `all` |
| `limit` | Egész szám, nem kötelező, alapértelmezett értéke 50. Az oldal mérete |
| `offset` | Egész szám, nem kötelező, alapértelmezett értéke 0. A lapozás kezdőpozíciója |

Korábbi paraméterek: a `per` és a `from` továbbra is használható a `limit`, illetve az `offset` helyett.

<!-- translation-section: example-4 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Témák listázása

Listázd az API-kulcshoz tartozó felhasználó számára látható beszélgetések és szavazások témáit, a legutóbbi aktivitás szerint rendezve. A téma azonosítója a `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `limit` | Egész szám, nem kötelező, alapértelmezett értéke 50. Az oldal mérete |
| `offset` | Egész szám, nem kötelező, alapértelmezett értéke 0. A lapozás kezdőpozíciója |

<!-- translation-section: example-5 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Téma olvasása

Olvasd el a témát, az eseményeinek rendezett sorát vagy a teljes látható tartalmát Markdown-dokumentumként.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Példa

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Az `items` végpont az eseményeket sorrendben adja vissza, beleértve a látható hozzászólásokat, szavazásokat, leadott szavazatokat és következtetéseket. A `markdown` végpont a téma teljes látható tartalmát egyetlen Markdown-dokumentumként adja vissza. A szavazatok indoklása csak akkor szerepel benne, ha látható az API-kulcshoz tartozó felhasználó számára.

Minden témához tartozó végpont ugyanazokat a jogosultságokat érvényesíti, mint a Loomio felülete. Az API-kulcs nem ad hozzáférést olyan témához, amelyet a felhasználó egyébként nem nyithat meg.

<!-- translation-section: edit-discussion -->

## Beszélgetés szerkesztése

Szerkessz egy beszélgetést az API-kulcshoz tartozó felhasználóként. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie a beszélgetés szerkesztésére.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `title` | Az új cím |
| `description` | Az új leírás |
| `description_format` | `md` vagy `html`, nem kötelező, alapértelmezett értéke `md` |
| `recipient_audience` | `group` vagy null. Ha `group`, a teljes csoport értesítést kap a módosításról |
| `recipient_user_ids` | Az értesítendő vagy a témába meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A témába meghívandó személyek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóban szereplő üzenet |

<!-- translation-section: example-7 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Beszélgetés logikai törlése

Törölj logikailag egy beszélgetést az API-kulcshoz tartozó felhasználóként. A beszélgetés törölt állapotba kerül, de a rekordja megmarad.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Hozzászólás létrehozása

Hozz létre egy hozzászólást egy beszélgetésben az API-kulcshoz tartozó felhasználóként.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `discussion_id` | Egész szám, kötelező. Annak a beszélgetésnek az azonosítója, amelyhez hozzászólsz |
| `body` | A hozzászólás szövege, kötelező, kivéve ha mellékletet adsz meg |
| `body_format` | `md` vagy `html`, nem kötelező, alapértelmezett értéke `md` |

<!-- translation-section: example-9 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Hozzászólás szerkesztése

Szerkessz egy hozzászólást az API-kulcshoz tartozó felhasználóként. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie a hozzászólás szerkesztésére.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `body` | A hozzászólás új szövege |
| `body_format` | `md` vagy `html`, nem kötelező, alapértelmezett értéke `md` |

<!-- translation-section: example-10 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Hozzászólás logikai törlése

Törölj logikailag egy hozzászólást az API-kulcshoz tartozó felhasználóként. A hozzászólás szövege rejtetté válik, de a rekordja megmarad.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Szavazás létrehozása

Hozz létre szavazást az API-kulcshoz tartozó felhasználóként.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, nem kötelező, alapértelmezés szerint null. A szavazás csoportjának azonosítója. Ha megadod a `discussion_id` értékét, a rendszer figyelmen kívül hagyja a `group_id` értékét |
| `discussion_id` | Egész szám, nem kötelező, alapértelmezés szerint null. Annak a beszélgetésnek az azonosítója, amelyhez hozzáadod a szavazást |
| `title` | Szöveg, kötelező. A szavazás címe |
| `poll_type` | Szöveg, kötelező. Lehetséges értékek: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Szöveg, nem kötelező. A szavazás leírása |
| `details_format` | Szöveg, nem kötelező, alapértelmezés szerint `md`. Lehetséges értékek: `md` vagy `html` |
| `options` | Szövegek tömbje. Ha a `poll_type` értéke `proposal`, az érvényes értékek: `agree`, `disagree`, `abstain`, `block`. Ha a `poll_type` értéke `meeting`, ISO 8601 formátumú dátumokat vagy dátumokat és időpontokat adj meg. Minden más szavazástípusnál bármilyen szöveg megadható |
| `closing_at` | ISO 8601 formátumú szöveg vagy null, alapértelmezés szerint null. Példa: `2026-09-01T12:00:00Z`. Ha null, a szavazás le van tiltva, és a szavazás előkészítés alatt áll |
| `specified_voters_only` | Logikai érték, nem kötelező, alapértelmezés szerint false. Ha true, csak a megadott személyek szavazhatnak. Ha false, a csoport minden tagja meghívást kap a szavazásra |
| `hide_results` | Szöveg, nem kötelező, alapértelmezés szerint `off`. Lehetséges értékek: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Logikai érték, alapértelmezés szerint false. A lehetőségeket véletlenszerű sorrendben jeleníti meg a szavazóknak |
| `anonymous` | Logikai érték, nem kötelező, alapértelmezés szerint false. Elrejti a szavazók személyazonosságát |
| `recipient_audience` | `group` vagy null, nem kötelező, alapértelmezés szerint null. Ha `group`, a teljes csoport értesítést kap |
| `notify_on_closing_soon` | Szöveg, nem kötelező, alapértelmezés szerint `nobody`. Lehetséges értékek: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Az értesítendő vagy meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szavazásra meghívandó személyek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóban szereplő üzenet |
| `notify_recipients` | Logikai érték, alapértelmezés szerint false. Ha false, a személyek értesítés nélkül kerülnek hozzáadásra. Ha true, a kéréssel meghívott minden személy értesítő e-mailt kap |

<!-- translation-section: example-12 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Szavazás megtekintése

Kérj le egy szavazást a számmal megadott azonosítója vagy a szöveges kulcsa alapján.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Szavazások listázása

Listázd azokat a csoportbeli szavazásokat, amelyeket az API-kulcshoz tartozó felhasználó láthat. Nyilvánosan látható csoport esetén egy nem tag felhasználó is listázhatja a nyilvános szavazásokat. A privát szavazásokat csak azok érhetik el, akik a Loomióban is megtekinthetik őket. A válasz minden látható szavazás aktuális következtetését tartalmazza, így a `status=closed` használatával listázhatod a lezárt javaslatokat.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a szavazásait listázni szeretnéd |
| `status` | Szöveg, nem kötelező, alapértelmezés szerint `active`. Lehetséges értékek: `active`, `closed`, `all` |
| `limit` | Egész szám, nem kötelező, alapértelmezés szerint 50. Az oldal mérete |
| `offset` | Egész szám, nem kötelező, alapértelmezés szerint 0. A lapozáshoz használt eltolás |

Korábbi paraméterek: a `per` és a `from` továbbra is használható a `limit`, illetve az `offset` helyett.

<!-- translation-section: example-14 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Szavazás szerkesztése

Szerkessz egy szavazást az API-kulcshoz tartozó felhasználóként. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie a szavazás szerkesztésére.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `title` | Módosított cím |
| `details` | A szavazás módosított leírása |
| `details_format` | `md` vagy `html`, nem kötelező, alapértelmezés szerint `md` |
| `options` | A lehetőségek módosított nevei. A lehetőségek megváltoztatása a szavazás állapotától függően hatással lehet a már leadott szavazatokra |
| `closing_at` | ISO 8601 formátumú szöveg vagy null |
| `recipient_audience` | `group` vagy null. Ha `group`, a teljes csoport értesítést kap |
| `recipient_user_ids` | Az értesítendő vagy meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szavazásra meghívandó személyek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóban szereplő üzenet |

<!-- translation-section: example-15 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Szavazás törlése visszaállítási lehetőséggel

Törölj egy szavazást visszaállítási lehetőséggel az API-kulcshoz tartozó felhasználóként. A szavazás kikerül a használatból, de a rekordja megmarad.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Tagságok listázása

Listázd az API-kulcshoz tartozó felhasználó számára látható tagságokat. A csoporttagok láthatják a tagok nevét, azonosítóját, beosztását és szerepkörét. Az e-mail-címek csak az API-kulcshoz tartozó felhasználó saját fiókjánál jelennek meg, vagy akkor, ha a felhasználó a csoport adminisztrátora.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a tagságait listázni szeretnéd |

<!-- translation-section: example-17 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Tagságok kezelése

Küldj el egy e-mail-címeket tartalmazó listát. Az új címek tulajdonosai meghívást kapnak a csoportba. A tagságok listázásával ellentétben ehhez a művelethez csoportadminisztrátori jogosultság szükséges.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a tagságait kezelni szeretnéd |
| `emails` | Szövegek tömbje, kötelező. A csoportba meghívandó személyek e-mail-címei |
| `remove_absent` | Logikai érték. Ha true, eltávolítja a csoportból azokat, akiknek az e-mail-címe nem szerepel a listán |

<!-- translation-section: example-18 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Ha megadod a `remove_absent=1` értéket, a rendszer eltávolítja a csoportból azokat a tagokat, akik nem szerepelnek a listán. Légy óvatos: akár a csoport összes tagját is eltávolíthatod.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

A válasz egy objektum: `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
