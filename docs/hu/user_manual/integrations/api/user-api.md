---
title: Felhasználói API
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
  introduction: b1504d9c4e0bd44d
  authentication-change: 659b7e61f9d0cd93
  response-size-and-related-records: 1d7260e356d4e886
  endpoint-summary: b23a26797c6fd55a
  groups: 416e445b12c9f929
  list-groups: d70459538f37081c
  get-a-group: a9353e450dc70f22
  webhooks: 0365275b6819e88d
  list-webhooks: 91b02af117b78f0d
  create-a-webhook: 0d0ef8acd63d6ce7
  update-a-webhook: cc23132a81e3f476
  test-a-webhook-destination: 1b9ee44679e5b9c8
  delete-a-webhook: 3cfeef1b5964dba2
  event-types: 0fcc6450a0622382
  http-delivery: 705628b930e9a862
  payload-formats: bed939de29e773ff
  search: 51bb7be4d587ab4e
  params: 9e8070d01214b284
  participation-report: ddc34962dd8e729d
  params-2: 19f58b7cbd82a90b
  example: 72c917979d97d8cf
  create-discussion: 640a1a953be756c7
  params-3: e9d6d3b49bda879c
  example-2: 1b153746050d6ef7
  show-discussion: 969ad550c89bd7a7
  example-3: 784553fa46b05a22
  list-discussions: 773fc193bc501d0b
  params-4: 4b2b2156fbe56316
  example-4: b4a79b23cff114d4
  list-threads: 16d57bb8165810d3
  params-5: e73d9d2fb92f3d53
  example-5: 5b540b5d089ee459
  read-thread: 6dea137615d33238
  example-6: 2a7d10965a917550
  edit-discussion: 3aab5169d34b379c
  params-6: 34ad1e3b4c173e95
  example-7: d7a8af42ee8c3b8a
  soft-delete-discussion: 789e0d0816511a4f
  example-8: 5c19b934bfd67843
  create-comment: 72293743ab5be8f2
  params-7: 47e1bc16d82c1d1b
  example-9: 52a99d7feed14cc1
  edit-comment: fcf6151b0a3d7221
  params-8: 3f4d445fc2001990
  example-10: 6420c8e56783fa22
  soft-delete-comment: f45d3ecadf01d68a
  example-11: 0f3a5b5abfca4020
  create-poll: 490bffddd6312228
  params-9: 2251bf3e77ae8741
  example-12: 5aa979418c6e1d79
  show-poll: c8b3157193b261e2
  example-13: 26a88ad91585edd2
  list-polls: ec19520361764e49
  params-10: 84e2fd6e50cc3e23
  example-14: 6f31a4d032c805bc
  edit-poll: 4aa467ed42a39635
  params-11: 9403160fffa57be5
  example-15: 65055ca15b3280b4
  soft-delete-poll: 6e18189d38623839
  example-16: a719ba5488a406c7
  list-memberships: 45ffb335f77cca36
  params-12: f6d9435a5db343f0
  example-17: 747605072570c858
  manage-memberships: cc1620565578898b
  params-13: '0359dfdc59860704'
  example-18: f39cff4e0d3c6d15
title_source: c23fb6526b722360
title_generated: 788437eb515e46bd
---

<!-- translation-section: introduction -->

# A Loomio felhasználói API dokumentációja

<!-- seo-description: A Loomio felhasználói API-val más szoftverekből hozhatsz létre és kezelhetsz beszélgetéseket, hozzászólásokat, szavazásokat, szálakat és csoporttagságokat. -->

A `/api/b2` a Loomio-integrációkhoz használható, felhasználóknak szánt API. Egy felhasználói fiók API-kulcsát használja, és minden műveletet az adott felhasználó nevében hajt végre.

A csoportműveletek az API-kulcshoz tartozó felhasználó tagságait és csoportjogosultságait használják. A példányadminisztrátori szerep nem bővíti az API-kulcs hozzáférését a csoportokhoz vagy a tartalmakhoz; a példányszintű adminisztrációhoz használd a szerver API-t.

Annak a Loomio-fióknak az API-kulcsát használd, amely a műveleteket végrehajtja. Egy külön botfiók hasznos, ha az integrációt nem szeretnéd meghívni szavazásokra, vagy nem kell értesítéseket kapnia.

Bejelentkezés után az [API-hozzáférés oldalán](/profile/api_access) találod meg az API-kulcsodat és a csoportazonosítókat.

Az API-kulcsot az `Authorization: Bearer` fejlécben küldd el. A rendszer elutasítja az URL lekérdezési paramétereiben küldött API-kulcsokat, mert a proxyk és a hozzáférési naplók rögzíthetik az URL-eket.

<!-- translation-section: authentication-change -->

### A hitelesítés változása

Korábban az API-kulcsot `api_key` URL-paraméterként is elfogadta a rendszer. A `?api_key=YOUR_API_KEY` paramétert használó kérések már nem működnek. Helyette használd a HTTP `Authorization` fejlécét:

```text
Authorization: Bearer YOUR_API_KEY
```

A példákban a `YOUR_API_KEY` API-kulcs, a `123` csoportazonosító és a `https://www.loomio.com/` URL szerepel. Cseréld le ezeket a saját API-kulcsodra, csoportazonosítódra és a Loomio-telepítésed URL-jére.

<!-- translation-section: response-size-and-related-records -->

## A válasz mérete és a kapcsolódó rekordok

A felhasználói API válaszai összetett formátumot használnak: az elsődleges rekordok mellett kapcsolódó rekordokat is tartalmaznak, például témákat, csoportokat, felhasználókat, szavazásokat és reakciókat. Így a kliens egyetlen kérésből feltölthet egy helyi rekordtárat, de a válasz több adatot is tartalmazhat, mint amennyire egy egyszerű integrációnak szüksége van.

Add meg a `compact=1` paramétert a nagy méretű kapcsolódó témák, csoportok, szülőcsoportok, tagságok, reakciók, címkék és fordítások kihagyásához. Az elsődleges rekordok és a tartalmuk értelmezéséhez szükséges kapcsolódó rekordok továbbra is szerepelnek a válaszban.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

A kihagyások közvetlen szabályozásához add meg az `exclude_types` paraméterben a rekordtípusokat egyes számban, szóközökkel elválasztva. Az `exclude_types=group reaction` például kihagyja a kapcsolódó csoportokat és reakciókat. Gyakori értékek: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` és `topic_item`. A kizárások a kapcsolódó rekordokra vonatkoznak, nem a végponttól kért elsődleges erőforrásra.

A gyűjteményeket visszaadó válaszok tartalmazzák a `meta.total` mezőt, ha a gyűjtemény pontos mérete meghatározott. A teljes elemszám kiszámítása a `limit` és az `offset` alkalmazása előtt történik. Azok a végpontok, amelyek szándékosan korlátozott eredményhalmazt adnak vissza, például a keresés, kihagyják a `meta.total` mezőt ahelyett, hogy `null` értéket adnának vissza.

<!-- translation-section: endpoint-summary -->

## A végpontok áttekintése

| Metódus | Végpont | Cél |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Az API-kulcshoz tartozó felhasználó csoportjainak listázása |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Egy látható csoport lekérése |
| `GET` | `/api/b2/reports` | Részvételi jelentés készítése |
| `GET` | `/api/b2/search` | Keresés a látható beszélgetések, hozzászólások, szavazások, szavazatok és következtetések között |
| `POST` | `/api/b2/discussions` | Beszélgetés létrehozása |
| `GET` | `/api/b2/discussions/:id` | Beszélgetés lekérése |
| `GET` | `/api/b2/discussions` | Egy csoport beszélgetéseinek listázása |
| `PATCH` | `/api/b2/discussions/:id` | Beszélgetés szerkesztése |
| `DELETE` | `/api/b2/discussions/:id` | Beszélgetés logikai törlése |
| `GET` | `/api/b2/threads` | A látható beszélgetési szálak és önálló szavazási szálak listázása |
| `GET` | `/api/b2/threads/:topic_id` | Szál lekérése |
| `GET` | `/api/b2/threads/:topic_id/items` | Egy szál rendezett elemeinek lekérése |
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
| `POST` | `/api/b2/memberships` | Tagok hozzáadása és opcionálisan a listáról hiányzó tagok eltávolítása |
| `GET` | `/api/b2/chatbots` | Egy csoport csevegési integrációinak és webhookjainak listázása |
| `POST` | `/api/b2/chatbots` | Csevegési integráció vagy webhook létrehozása |
| `PATCH` | `/api/b2/chatbots/:id` | Csevegési integráció vagy webhook frissítése |
| `DELETE` | `/api/b2/chatbots/:id` | Csevegési integráció vagy webhook törlése |
| `POST` | `/api/b2/chatbots/check` | Webhook-kapcsolat tesztüzenetének küldése |

<!-- translation-section: groups -->

## Csoportok

<!-- translation-section: list-groups -->

### Csoportok listázása

Visszaadja azokat a csoportokat, amelyekben az API-kulcshoz tartozó felhasználónak aktív tagsága van.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

A válasz az összes megfelelő rekordot egy lapozás nélküli `groups` tömbben tartalmazza. Szülőcsoportokat és alcsoportokat is tartalmaz, köztük olyan csoportokat, amelyek előfizetése jelenleg nem aktív. Ellenőrizd az `enabled` mezőt, ha az integrációnak csak engedélyezett csoportokon kell működnie.

A fontosabb csoportmezők:

| Mező | Leírás |
| --- | --- |
| `id` | A csoport számszerű azonosítója, amelyet a felhasználói API más végpontjai használnak |
| `key` | A Loomio URL-jeiben használt állandó rövid kulcs |
| `handle` | A csoport ember számára olvasható azonosítója |
| `name` | A csoport neve |
| `full_name` | A csoport neve a szülőcsoport nevével együtt |
| `parent_id` | Alcsoport esetén a szülőcsoport számszerű azonosítója, egyébként `null` |
| `enabled` | A csoport és az előfizetése aktív-e |
| `memberships_count` | Az aktív és függőben lévő tagságok száma |
| `accepted_memberships_count` | Az elfogadott tagságok száma |
| `pending_memberships_count` | A függőben lévő meghívók száma |
| `admin_memberships_count` | A csoportadminisztrátorok száma |
| `delegates_count` | A küldöttek száma |
| `discussions_count` | A közvetlenül a csoportban lévő beszélgetések száma |
| `polls_count` | A közvetlenül a csoportban lévő szavazások száma |
| `subgroups_count` | Az alcsoportok száma |

A válasz további csoportbeállításokat, kapcsolódó szülőcsoportrekordokat és az API-felhasználó tagságait is tartalmazhatja. A kliensek hagyják figyelmen kívül azokat a mezőket, amelyeket nem használnak.

<!-- translation-section: get-a-group -->

### Csoport lekérése

Visszaad egy, az API-kulcshoz tartozó felhasználó számára látható csoportot.

`GET /api/b2/groups/:id_or_key_or_handle`

Az azonosító lehet a csoport számszerű azonosítója, kulcsa vagy olvasható azonosítója.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

A válasz a `groups` tömbben tartalmazza a csoportot, és ugyanazokat a mezőket használja, mint a listázási végpont. Ha az API-kulcshoz tartozó felhasználó nem fér hozzá a kért csoporthoz, a kérés jogosultsági hibát ad vissza.

<!-- translation-section: webhooks -->

## Webhookok

A felhasználói API kérésekre épül: az integráció akkor hívja meg a Loomiót, amikor adatokat szeretne olvasni vagy módosítani. A csoport webhookja az ellenkező irányú adatküldést biztosítja. A Loomio a kiválasztott csoporteseményeket a bekövetkezésükkor elküldi a végpontodra, így az integrációnak nem kell rendszeresen lekérdeznie a REST API-t a változásokért.

A webhookokat csoportonként kell beállítani, és ehhez csoportadminisztrátori jogosultság szükséges. A Loomio felületén így kezelheted őket:

1. Nyisd meg a csoportot.
2. Nyisd meg a csoport menüjét, és válaszd ki a **Csevegési integrációk** menüpontot.
3. Add hozzá a végpontod által elfogadott adatformátumnak megfelelő integrációt. Általános célú végponthoz használd a Mattermost/Markdown formátumot.
4. Adj meg egy nevet és a cél URL-jét.
5. Válaszd ki azokat az eseményeket, amelyeket a Loomiónak automatikusan el kell küldenie.
6. Mentsd az integrációt, és a **Kapcsolat tesztelése** funkcióval küldj tesztüzenetet.

Használj HTTPS-célcímet olyan URL-lel, amelyet nem lehet kitalálni. A Loomio megköveteli, hogy a célcím nyilvános címre oldódjon fel, és blokkolja a helyi vagy privát hálózati címekre irányuló kéréseket.

Az ügynökök és más integrációk az alább ismertetett, Bearer-hitelesítést használó chatbot-végpontokon keresztül is kezelhetik a webhookokat. Az erőforrás neve a Loomio csevegési integrációival való kompatibilitás miatt `chatbots`, de általános kimenő webhookokat is jelöl.

<!-- translation-section: list-webhooks -->

### Webhookok listázása

Visszaadja egy csoport beállított csevegési integrációit. Az API-kulcshoz tartozó felhasználónak az adott csoport adminisztrátorának kell lennie. A válasz cél-URL-eket is tartalmaz, ezért nem tehető hozzáférhetővé a csoport többi tagja számára.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

A válasz egy `chatbots` tömböt tartalmaz az alábbi mezőkkel:

| Mező | Leírás |
| --- | --- |
| `id` | A frissítéshez és törléshez használt integrációazonosító |
| `group_id` | Az eseményeket fogadó csoport |
| `name` | Az integráció adminisztrációhoz használt neve |
| `kind` | Kimenő webhook esetén `webhook`, Matrix-integráció esetén `matrix` |
| `webhook_kind` | Az elküldött adatok formátuma: `markdown`, `slack`, `discord`, `microsoft` vagy `webex` |
| `server` | Cél-URL |
| `event_kinds` | Automatikusan elküldött események |
| `notification_only` | Az üzenetek csak az értesítés címsorát tartalmazzák-e |

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

Az API-kulcshoz tartozó felhasználónak a `group_id` által megadott csoport adminisztrátorának kell lennie. Mentés előtt a rendszer ellenőrzi, hogy a célcím nyilvános URL-e.

<!-- translation-section: update-a-webhook -->

### Webhook frissítése

`PATCH /api/b2/chatbots/:id`

Küldd el a módosítandó mezőket. A webhook nem helyezhető át másik csoportba a `group_id` módosításával.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Webhook célcímének tesztelése

Küldj Markdown-kompatibilis tesztüzenetet egy célcímre a beállításainak mentése előtt vagy után.

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

A konfiguráció törlése leállítja a további kézbesítéseket. A Loomio-csoport tartalmait nem törli.

<!-- translation-section: event-types -->

### Eseménytípusok

A webhook a következő eseménytípusokra iratkozhat fel:

| Esemény | Mikor küldi el a Loomio |
| --- | --- |
| `new_discussion` | Beszélgetés indul |
| `discussion_edited` | Beszélgetést szerkesztenek |
| `new_comment` | Hozzászólás jön létre |
| `poll_created` | Szavazás indul |
| `poll_edited` | Szavazást szerkesztenek |
| `poll_closing_soon` | Közeledik egy szavazás lezárási ideje |
| `poll_expired` | Egy szavazás eléri a lezárási idejét |
| `poll_closed_by_user` | Valaki kézzel lezár egy szavazást |
| `poll_reopened` | Szavazást újranyitnak |
| `outcome_created` | Következtetést tesznek közzé |
| `outcome_updated` | Következtetést frissítenek |
| `outcome_review_due` | Esedékessé válik egy következtetés felülvizsgálata |
| `stance_created` | Szavazatot adnak le |
| `stance_updated` | Szavazatot módosítanak |

A webhook egy csoporthoz tartozik, és ebből a csoportból kapja meg azokat az eseményeket, amelyekre feliratkozott. Megosztáskor vagy egyes értesítések küldésekor az emberek külön is kiválaszthatják az integrációt, akkor is, ha a megfelelő automatikus esemény nincs kiválasztva.

<!-- translation-section: http-delivery -->

### HTTP-kézbesítés

A Loomio aszinkron HTTP `POST` kérést küld a beállított URL-re ezzel a fejléccel:

```text
Content-Type: application/json; charset=utf-8
```

A kérés időkorlátja öt másodperc. A `2xx` válaszokat, köztük a `204 No Content` választ is sikeresnek tekinti. A webhookot fogadó szolgáltatásoknak gyorsan kell válaszolniuk, a hosszabb feladatokat aszinkron módon kell feldolgozniuk, és kezelniük kell az ismételt vagy eltérő sorrendben érkező kézbesítéseket.

A Loomio jelenleg nem ad a kéréshez webhook-aláírást, közös titkot tartalmazó fejlécet, eseményazonosítót vagy kézbesítési azonosítót. Kezeld a teljes cél-URL-t hitelesítő adatként, ne tedd nyilvánossá, és adj hozzá egy kitalálhatatlan tokent az URL-hez, ha a fogadó szolgáltatás támogatja ezt. Ha stabil, géppel olvasható eseménysémára vagy aláírt kézbesítésre van szükséged, használd a webhookot a változások jelzésére, és kérd le az aktuális rekordokat a hitelesített Felhasználói API-n keresztül.

<!-- translation-section: payload-formats -->

### Üzenetformátumok

A webhookok csevegőszolgáltatásokban való megjelenítésre szánt üzeneteket küldenek. Ezek nem teljes, szerializált Loomio-rekordok. Az üzenetben található hivatkozások azonosítják az érintett Loomio-tartalmat; ha az integrációnak strukturált adatokra van szüksége az aktuális állapotról, ezeket a Felhasználói API-n keresztül kérheti le.

| Integrációs formátum | Fő JSON-mezők |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, körülbelül 1900 karakterre korlátozva |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Az általános Markdown-formátum például ilyen szerkezetű törzset küld:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Az üzenet pontos szövege az eseménytől, a csoport nyelvi beállításától, a csak értesítést küldő beállítástól és a Loomio verziójától függ. A fogadó szolgáltatásoknak a kiválasztott formátum dokumentált, legfelső szintű mezőire kell támaszkodniuk a mondatok megfogalmazásának elemzése helyett.

<!-- translation-section: search -->

## Keresés

Keress az API-kulcshoz tartozó felhasználó számára látható beszélgetések, hozzászólások, szavazások, szavazatok és következtetések között. A találatok nyilvános tartalmakat akkor is tartalmaznak, ha a felhasználó nem tagja az adott csoportnak; a privát tartalmakra továbbra is a szálak szokásos láthatósági szabályai vonatkoznak.

`GET /api/b2/search`

<!-- translation-section: params -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `query` | Keresési szöveg. Pontos és közelítő egyezések is támogatottak |
| `group_id` | Korlátozd a találatokat egy látható csoportra |
| `org_id` | Korlátozd a találatokat egy látható szülőcsoportra és annak látható alcsoportjaira. Közvetlen beszélgetésekhez használd a `0` értéket |
| `type` | Korlátozd a találatokat egy típusra: `Discussion`, `Comment`, `Poll`, `Stance` vagy `Outcome` |
| `types` | Találattípusok vesszővel elválasztott listája |
| `tag` | Korlátozd a találatokat az ezzel a címkével ellátott szálakra |
| `author_id` | Korlátozd a találatokat egy szerző tartalmaira. A `query` nélkül a szerző közelmúltbeli, látható tevékenységét adja vissza |
| `order` | Állítsd `authored_at_desc` értékre, hogy az egyező tartalmakat a létrehozás ideje szerint rendezze |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

A válasz egy `search_results` tömböt tartalmaz. Minden találat azonosítja az egyező rekordot és annak látható környezetét, többek között a `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` és `tags` mezőkkel. Az adott találatra nem alkalmazható mezők értéke `null`.

<!-- translation-section: participation-report -->

## Részvételi jelentés

Ugyanazokat az összesített részvételi adatokat adja vissza, amelyeket a Loomio részvételi jelentése használ.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `section` | A jelentés része: `base`, `users` vagy `countries`. Személyenkénti tevékenységhez használd a `users` értéket |
| `group_scope` | `custom` vagy `my`. A korábbi `all` értéket `my` értékként kezeli, mert a Felhasználói API kulcsai soha nem biztosítanak a teljes példányra kiterjedő hozzáférést |
| `group_ids` | Vesszővel elválasztott csoportazonosítók, ha `group_scope=custom`. Az API-felhasználó tagságain kívül eső azonosítókat figyelmen kívül hagyja |
| `start_month` | Az első figyelembe vett hónap `YYYY-MM` formátumban; alapértelmezés szerint a 12 hónappal ezelőtti hónap |
| `end_month` | Az utolsó figyelembe vett hónap `YYYY-MM` formátumban; alapértelmezés szerint az aktuális hónap |
| `interval` | A `base` rész időköze: `day`, `week`, `month` vagy `year` |
| `member_type` | A `section=users` mellett állítsd `delegate` értékre, hogy csak a jelenlegi küldötteket adja vissza |

Egy személy akkor küldött, ha bármelyik kiválasztott csoportban aktív küldötti tagsággal rendelkezik. A hozzá tartozó darabszámokat az összes kiválasztott csoportból összesíti. A küldöttek sorait akkor is visszaadja, ha minden tevékenység darabszáma nulla. A darabszámok a szálakra, hozzászólásokra, szavazásokra, szavazatokra, következtetésekre és reakciókra vonatkoznak; nem a szavazási részvétel arányát mutatják. A felhasználói sorok a kiadott, leadott és le nem adott, személyhez köthető szavazólapok számát is tartalmazzák. A névtelen szavazások minden személyenkénti szavazati darabszámból kimaradnak. Az `all_votes_cast` értéke csak akkor igaz, ha legalább egy szavazólapot kiadtak, és minden kiadott szavazólapot leadtak.

Az API ugyanazokat a csoportláthatósági szabályokat alkalmazza, mint az alkalmazásban elérhető jelentés. Egy felhasználói API-kulcs nem teheti elérhetővé olyan csoportok jelentésadatait, amelyekhez az adott felhasználó nem fér hozzá.

<!-- translation-section: example -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

A `users` tömb teljes tevékenységi adatsorokat tartalmaz:

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

Hozz létre beszélgetést az API-kulcshoz tartozó felhasználó nevében.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | A csoport, amelyben a szál létrejön |
| `title` | A szál címe, kötelező |
| `description` | A szál leírása, nem kötelező |
| `description_format` | `md` vagy `html`, nem kötelező, alapértelmezés szerint `md` |
| `recipient_audience` | `group` vagy null. Ha `group`, az egész csoport értesítést kap az új szálról |
| `recipient_user_ids` | A szálról értesítendő vagy a szálba meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szálba meghívandó emberek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóba kerülő üzenet |

<!-- translation-section: example-2 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Beszélgetés lekérése

Kérj le egy beszélgetést az egész számként megadott azonosítójával vagy a karakterláncként megadott kulcsával.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Beszélgetések listázása

Listázd egy csoportban az API-kulcshoz tartozó felhasználó számára látható beszélgetéseket. Egy nyilvánosan látható csoport nyilvános beszélgetéseit olyan felhasználó is listázhatja, aki nem tagja a csoportnak; a privát beszélgetésekhez továbbra is csak azok a felhasználók férhetnek hozzá, akik a Loomióban is olvashatják őket.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a beszélgetéseit listázni szeretnéd |
| `status` | Karakterlánc, opcionális, alapértelmezés: `open`. Értékek: `open`, `closed`, `all` |
| `limit` | Egész szám, opcionális, alapértelmezés: 50. Oldalméret |
| `offset` | Egész szám, opcionális, alapértelmezés: 0. Eltolás a lapozáshoz |

Visszamenőleges kompatibilitás: a `per` és a `from` továbbra is használható a `limit`, illetve az `offset` alternatív neveként.

<!-- translation-section: example-4 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Szálak listázása

Listázd az API-kulcshoz tartozó felhasználó számára látható beszélgetési és szavazási szálakat a legutóbbi aktivitás szerinti sorrendben. A szál azonosítója a `topic_id` értéke.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `limit` | Egész szám, opcionális, alapértelmezés: 50. Oldalméret |
| `offset` | Egész szám, opcionális, alapértelmezés: 0. Eltolás a lapozáshoz |

<!-- translation-section: example-5 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Szál olvasása

Olvasd el egy szál tartalmát, a rendezett eseményfolyamát vagy a teljes látható Markdown-dokumentumát.

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

Az `items` végpont a rendezett eseményfolyamot adja vissza, beleértve a látható hozzászólásokat, szavazásokat, szavazatokat és következtetéseket. A `markdown` végpont a teljes látható szálat egyetlen Markdown-dokumentumként adja vissza. A szavazatok indoklásai csak akkor szerepelnek benne, ha az API-kulcshoz tartozó felhasználó számára láthatók.

A szálakhoz tartozó összes végpont ugyanazokat a jogosultságokat érvényesíti, mint a Loomio felülete. Az API-kulcs nem ad hozzáférést olyan szálhoz, amelyet a felhasználó egyébként nem nyithat meg.

<!-- translation-section: edit-discussion -->

## Beszélgetés szerkesztése

Szerkessz egy beszélgetést az API-kulcshoz tartozó felhasználóként. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie az adott beszélgetés szerkesztésére.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `title` | Frissített cím |
| `description` | Frissített leírás |
| `description_format` | `md` vagy `html`, opcionális, alapértelmezés: `md` |
| `recipient_audience` | `group` vagy null. Ha `group`, az egész csoport értesítést kap a szerkesztésről |
| `recipient_user_ids` | A szálról értesítendő vagy a szálba meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szálba meghívandó emberek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailben küldött meghívóba foglalandó üzenet |

<!-- translation-section: example-7 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Beszélgetés logikai törlése

Töröld logikailag a beszélgetést az API-kulcshoz tartozó felhasználó nevében. Ez eltávolítja a beszélgetést, de megőrzi a beszélgetés adatbázisrekordját.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Hozzászólás létrehozása

Hozz létre hozzászólást egy beszélgetésben az API-kulcshoz tartozó felhasználó nevében.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `discussion_id` | Egész szám, kötelező. Annak a beszélgetésnek az azonosítója, amelyhez hozzászólsz |
| `body` | A hozzászólás szövege, kötelező, kivéve ha mellékletet adsz meg |
| `body_format` | `md` vagy `html`, nem kötelező, alapértelmezés: `md` |

<!-- translation-section: example-9 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Hozzászólás szerkesztése

Szerkeszd a hozzászólást az API-kulcshoz tartozó felhasználó nevében. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie az adott hozzászólás szerkesztésére.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `body` | A hozzászólás módosított szövege |
| `body_format` | `md` vagy `html`, nem kötelező, alapértelmezés: `md` |

<!-- translation-section: example-10 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Hozzászólás logikai törlése

Töröld logikailag a hozzászólást az API-kulcshoz tartozó felhasználó nevében. Ez eltávolítja a hozzászólást és elrejti a szövegét, de megőrzi a hozzászólás adatbázisrekordját.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Szavazás létrehozása

Hozz létre szavazást az API-kulcshoz tartozó felhasználó nevében.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, nem kötelező, alapértéke null. A szavazás csoportjának azonosítója. Ha megadod a `discussion_id` értékét, a `group_id` figyelmen kívül marad |
| `discussion_id` | Egész szám, nem kötelező, alapértéke null. Annak a beszélgetési szálnak az azonosítója, amelyhez hozzáadod ezt a szavazást |
| `title` | Karakterlánc, kötelező. A szavazás címe |
| `poll_type` | Karakterlánc, kötelező. Értékei: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Karakterlánc, nem kötelező. A szavazás szövege |
| `details_format` | Karakterlánc, nem kötelező, alapértéke `md`. Értékei: `md` vagy `html` |
| `options` | Karakterláncok tömbje. Ha a `poll_type` értéke `proposal`, az érvényes értékek: `agree`, `disagree`, `abstain`, `block`. Ha a `poll_type` értéke `meeting`, adj meg ISO 8601 formátumú dátum- vagy dátum- és időkarakterláncokat. Minden más szavazástípusnál bármilyen karakterlánc érvényes |
| `closing_at` | ISO 8601 formátumú karakterlánc vagy null, alapértéke null. Példa: `2026-09-01T12:00:00Z`. Ha null, nem lehet szavazni, és a szavazás még előkészítés alatt áll |
| `specified_voters_only` | Logikai érték, nem kötelező, alapértéke false. Ha true, csak a megadott személyek szavazhatnak. Ha false, a csoport minden tagja meghívót kap a szavazásra |
| `hide_results` | Karakterlánc, nem kötelező, alapértéke `off`. Értékei: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Logikai érték, alapértéke false. A lehetőségeket véletlenszerű sorrendben jeleníti meg a szavazóknak |
| `anonymous` | Logikai érték, nem kötelező, alapértéke false. Elrejti a szavazók személyazonosságát |
| `recipient_audience` | `group` vagy null, nem kötelező, alapértéke null. Ha `group`, az egész csoport értesítést kap |
| `notify_on_closing_soon` | Karakterlánc, nem kötelező, alapértéke `nobody`. Értékei: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Az értesítendő vagy meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szavazásra meghívandó személyek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóba kerülő üzenet |
| `notify_recipients` | Logikai érték, alapértéke false. Ha false, értesítések küldése nélkül adja hozzá a személyeket. Ha true, mindenki, akit ebben a kérésben meghívsz, értesítő e-mailt kap |

<!-- translation-section: example-12 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Szavazás lekérése

Kérj le egy szavazást az egész számként megadott azonosítójával vagy a karakterláncként megadott kulcsával.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Szavazások listázása

Listázd egy csoportnak az API-kulcshoz tartozó felhasználó számára látható szavazásait. Nyilvánosan látható csoport esetén a csoporton kívüli felhasználó is listázhatja a nyilvános szavazásokat; a privát szavazásokhoz továbbra is csak azok a felhasználók férhetnek hozzá, akik a Loomióban is olvashatják őket. A válasz minden látható szavazás aktuális következtetését tartalmazza, így a `status=closed` használatával listázhatod azokat a javaslatokat, amelyekről már döntés született.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a szavazásait listázod |
| `status` | Karakterlánc, nem kötelező, alapértéke `active`. Értékei: `active`, `closed`, `all` |
| `limit` | Egész szám, nem kötelező, alapértéke 50. Oldalméret |
| `offset` | Egész szám, nem kötelező, alapértéke 0. A lapozás eltolása |

Korábbi paraméterek: a `per` és a `from` a `limit` és az `offset` alternatív neveként használhatók, és továbbra is működni fognak.

<!-- translation-section: example-14 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Szavazás szerkesztése

Szerkessz egy szavazást az API-kulcshoz tartozó felhasználó nevében. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie az adott szavazás szerkesztésére.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `title` | Frissített cím |
| `details` | A szavazás frissített részletei |
| `details_format` | `md` vagy `html`, nem kötelező, alapértéke `md` |
| `options` | A lehetőségek frissített nevei. A lehetőségek módosítása a szavazás állapotától függően hatással lehet a meglévő szavazatokra |
| `closing_at` | ISO 8601 formátumú karakterlánc vagy null |
| `recipient_audience` | `group` vagy null. Ha `group`, az egész csoport értesítést kap |
| `recipient_user_ids` | Az értesítendő vagy meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szavazásra meghívandó személyek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóba kerülő üzenet |

<!-- translation-section: example-15 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Szavazás logikai törlése

Törölj logikailag egy szavazást az API-kulcshoz tartozó felhasználó nevében. Ez töröltnek jelöli a szavazást, és megőrzi a szavazás rekordját.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Tagságok listázása

Listázd az API-kulcs felhasználója számára látható tagságokat. A csoport tagjai láthatják a tagok nevét, azonosítóját, tisztségét és szerepkörét. Az e-mail-címek csak az API-kulcs felhasználójának saját fiókjánál szerepelnek, vagy akkor, ha az API-kulcs felhasználója a csoport adminisztrátora.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek tagságait listázni szeretnéd |

<!-- translation-section: example-17 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Tagságok kezelése

Küldj egy listát az e-mail-címekről. A művelet minden új e-mail-címre meghívót küld a csoportba. A tagságok listázásától eltérően ehhez a művelethez csoportadminisztrátori jogosultság szükséges.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek tagságait kezelni szeretnéd |
| `emails` | Karakterláncok tömbje, kötelező. A csoportba meghívandó emberek e-mail-címei |
| `remove_absent` | Logikai érték. Ha igaz, eltávolítja a csoportból mindazokat, akiknek az e-mail-címe nem szerepel a listában |

<!-- translation-section: example-18 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Ha megadod a `remove_absent=1` paramétert, a csoport minden olyan tagja eltávolításra kerül, aki nem szerepel a listában. Légy óvatos, mert akár mindenkit eltávolíthatsz a csoportodból.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Ez egy objektumot ad vissza a következő tartalommal: `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
