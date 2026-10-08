---
title: Felhasználói API
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
  introduction: b3abb14e43b63799
  authentication-change: 749558994f25009c
  response-size-and-related-records: cc4a3e2f9c96f82e
  endpoint-summary: 9552b6ef60366261
  groups: 416e445b12c9f929
  list-groups: d3bcc898343c1553
  get-a-group: 2964e7eaa1534ec3
  webhooks: d8e2bffc0f7d2805
  list-webhooks: 9e7b437384e0f4f2
  create-a-webhook: d7866d572a7b4495
  update-a-webhook: d0e0447be3ec506e
  test-a-webhook-destination: 3057b1d1557500b6
  delete-a-webhook: 59b80e297da6ffe1
  event-types: 2334d732d671806a
  http-delivery: 150134f105a1af59
  payload-formats: a14cda9d4b4b6899
  search: 682fce972f6720e6
  params: 7e67822160a6553f
  participation-report: ddc34962dd8e729d
  params-2: f7c0fd9ae9e9b26f
  example: b789ff16a6b1afcf
  create-discussion: bf29ef75d1d53ed9
  params-3: 9a5be7f7c3ab115e
  example-2: 1b153746050d6ef7
  show-discussion: 59d95f9a83fbb7cf
  example-3: 784553fa46b05a22
  list-discussions: 7e20c3a868f509f3
  params-4: 64aa303b92784332
  example-4: b4a79b23cff114d4
  list-threads: e1b523972811e44f
  params-5: f0b38e122e1de992
  example-5: 5b540b5d089ee459
  read-thread: ab832c12e82fe395
  example-6: 20ab3fc45afd576a
  edit-discussion: 36e07950f050abd2
  params-6: 560e088d18aaef0c
  example-7: d7a8af42ee8c3b8a
  soft-delete-discussion: ea5598498f1edb17
  example-8: 5c19b934bfd67843
  create-comment: 05b9c9a0c18df725
  params-7: d0c061520b8b4ba3
  example-9: 52a99d7feed14cc1
  edit-comment: 540e4eca8bf38cb7
  params-8: 03e0fab97743bb48
  example-10: 6420c8e56783fa22
  soft-delete-comment: 04ca2be7a0f62664
  example-11: 0f3a5b5abfca4020
  create-poll: 429c1feb0c22e6d0
  params-9: 94246af62a48ca9b
  example-12: 5aa979418c6e1d79
  show-poll: c8b3157193b261e2
  example-13: 26a88ad91585edd2
  list-polls: 6df18999afbc770e
  params-10: f6d334373b186bc2
  example-14: 6f31a4d032c805bc
  edit-poll: 151f7768fe13c347
  params-11: 314749e8dd78d252
  example-15: 65055ca15b3280b4
  soft-delete-poll: 570196254928a651
  example-16: a719ba5488a406c7
  list-memberships: c2aa5ba0f354a416
  params-12: bb891859fee16c3a
  example-17: 747605072570c858
  manage-memberships: d3198f9f6e44c2d9
  params-13: 2e4ed06e37c715b5
  example-18: 4c2fefaf4751ba74
title_source: c23fb6526b722360
title_generated: 788437eb515e46bd
---

<!-- translation-section: introduction -->

# A Loomio felhasználói API dokumentációja

<!-- seo-description: A Loomio felhasználói API segítségével más szoftverekből hozhatsz létre és kezelhetsz beszélgetéseket, hozzászólásokat, szavazásokat, szálakat és csoporttagságokat. -->

A `/api/b2` a Loomio-integrációk felhasználói API-ja. Egy felhasználói fiók API-kulcsát használja, és minden műveletet az adott felhasználó nevében hajt végre.

A csoportműveletek az API-kulcshoz tartozó felhasználó tagságait és csoportjogosultságait használják. A példányadminisztrátori szerepkör nem bővíti az API-kulcs hozzáférését a csoportokhoz vagy tartalmakhoz; a példányszintű adminisztrációhoz használd a szerver API-t.

Annak a Loomio-felhasználói fióknak az API-kulcsát használd, amely a műveleteket végrehajtja. Egy külön botfiók hasznos, ha az integrációnak nem kell meghívókat kapnia szavazásokhoz vagy értesítéseket fogadnia.

A bejelentkezett felhasználók az [API-hozzáférési oldalon](/profile/api_access) találják meg az API-kulcsukat és a csoportazonosítóikat.

Az API-kulcsot az `Authorization: Bearer` fejlécben küldd el. A rendszer elutasítja a lekérdezési karakterláncban megadott API-kulcsokat, mert a proxyk és a hozzáférési naplók rögzíthetik az URL-eket.

<!-- translation-section: authentication-change -->

### A hitelesítés változása

Korábban az API-kulcsot `api_key` URL-paraméterként is meg lehetett adni. A `?api_key=YOUR_API_KEY` paramétert használó kérések már nem működnek. Helyette használd a HTTP `Authorization` fejlécét:

```text
Authorization: Bearer YOUR_API_KEY
```

A példákban a `YOUR_API_KEY` API-kulcs, a `123` csoportazonosító és a `https://www.loomio.com/` URL szerepel. Cseréld le ezeket a saját API-kulcsodra, csoportazonosítódra és Loomio-telepítésed URL-jére.

<!-- translation-section: response-size-and-related-records -->

## A válasz mérete és a kapcsolódó rekordok

A felhasználói API válaszai összetett formátumot használnak: az elsődleges rekordokat kapcsolódó rekordok, például témák, csoportok, felhasználók, szavazások és reakciók kísérik. Így a kliens egyetlen kérésből feltölthet egy helyi rekordtárat, de a válasz több adatot is tartalmazhat, mint amennyire egy egyszerű integrációnak szüksége van.

Add meg a `compact=1` paramétert a nagy méretű kapcsolódó témák, csoportok, szülőcsoportok, tagságok, reakciók, címkék és fordítások kihagyásához. Az elsődleges rekordok és a tartalmuk értelmezéséhez szükséges kapcsolódó rekordok továbbra is szerepelnek a válaszban.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

A közvetlen szabályozáshoz add meg az `exclude_types` paramétert szóközzel elválasztott, egyes számú rekordtípusokkal. Például az `exclude_types=group reaction` kihagyja a kapcsolódó csoportokat és reakciókat. Gyakori értékek: `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` és `topic_item`. A kizárások a kapcsolódó rekordokra vonatkoznak, nem a végponttól kért elsődleges erőforrásra.

A gyűjteményeket visszaadó válaszok tartalmazzák a `meta.total` mezőt, ha a gyűjtemény pontos mérete meghatározott. A teljes elemszám kiszámítása a `limit` és az `offset` alkalmazása előtt történik. Azok a végpontok, például a keresés, amelyek szándékosan korlátozott eredményhalmazt adnak vissza, kihagyják a `meta.total` mezőt ahelyett, hogy `null` értéket adnának vissza.

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
| `GET` | `/api/b2/threads/:topic_id/markdown` | Teljes szál lekérése Markdown formátumban |
| `POST` | `/api/b2/comments` | Hozzászólás vagy válasz létrehozása |
| `PATCH` | `/api/b2/comments/:id` | Hozzászólás szerkesztése |
| `DELETE` | `/api/b2/comments/:id` | Hozzászólás logikai törlése |
| `POST` | `/api/b2/polls` | Szavazás létrehozása |
| `GET` | `/api/b2/polls/:id` | Szavazás lekérése |
| `GET` | `/api/b2/polls` | Egy csoport szavazásainak listázása |
| `PATCH` | `/api/b2/polls/:id` | Szavazás szerkesztése |
| `DELETE` | `/api/b2/polls/:id` | Szavazás logikai törlése |
| `GET` | `/api/b2/memberships` | Egy csoport tagságainak listázása |
| `POST` | `/api/b2/memberships` | Tagok hozzáadása és igény szerint a listából hiányzó tagok eltávolítása |
| `GET` | `/api/b2/chatbots` | Egy csoport csevegési integrációinak és webhookjainak listázása |
| `POST` | `/api/b2/chatbots` | Csevegési integráció vagy webhook létrehozása |
| `PATCH` | `/api/b2/chatbots/:id` | Csevegési integráció vagy webhook frissítése |
| `DELETE` | `/api/b2/chatbots/:id` | Csevegési integráció vagy webhook törlése |
| `POST` | `/api/b2/chatbots/check` | Webhook-kapcsolat tesztelése |

<!-- translation-section: groups -->

## Csoportok

<!-- translation-section: list-groups -->

### Csoportok listázása

Visszaadja azokat a csoportokat, amelyekben az API-kulcshoz tartozó felhasználónak aktív tagsága van.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

A válasz az összes megfelelő rekordot egy nem lapozott `groups` tömbben tartalmazza. Szülőcsoportokat és alcsoportokat is tartalmaz, köztük olyan csoportokat, amelyek előfizetése jelenleg nem aktív. Ellenőrizd az `enabled` mezőt, ha az integrációnak csak engedélyezett csoportokkal kell működnie.

A fontosabb csoportmezők:

| Mező | Leírás |
| --- | --- |
| `id` | A többi felhasználói API-végpont által használt numerikus csoportazonosító |
| `key` | A Loomio URL-jeiben használt állandó rövid kulcs |
| `handle` | A csoport ember számára olvasható azonosítója |
| `name` | A csoport neve |
| `full_name` | A csoport neve a szülőcsoport nevével együtt |
| `parent_id` | Alcsoport esetén a szülőcsoport numerikus azonosítója, egyébként `null` |
| `enabled` | A csoport és az előfizetése aktív-e |
| `memberships_count` | Az aktív és függőben lévő tagságok száma |
| `accepted_memberships_count` | Az elfogadott tagságok száma |
| `pending_memberships_count` | A függőben lévő meghívók száma |
| `admin_memberships_count` | A csoportadminisztrátorok száma |
| `discussions_count` | A közvetlenül a csoportban lévő beszélgetések száma |
| `polls_count` | A közvetlenül a csoportban lévő szavazások száma |
| `subgroups_count` | Az alcsoportok száma |

A válasz további csoportbeállításokat, kapcsolódó szülőcsoportrekordokat és az API-felhasználó tagságait is tartalmazhatja. A kliensek hagyják figyelmen kívül azokat a mezőket, amelyeket nem használnak.

<!-- translation-section: get-a-group -->

### Csoport lekérése

Visszaad egy, az API-kulcshoz tartozó felhasználó számára látható csoportot.

`GET /api/b2/groups/:id_or_key_or_handle`

Az azonosító lehet a csoport numerikus azonosítója, kulcsa vagy ember számára olvasható azonosítója.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

A válasz a `groups` tömbben tartalmazza a csoportot, és ugyanazokat a mezőket használja, mint a listázási végpont. Ha az API-kulcshoz tartozó felhasználó nem fér hozzá a kért csoporthoz, a kérés jogosultsági hibát ad vissza.

<!-- translation-section: webhooks -->

## Webhookok

A felhasználói API kérésalapú: az integráció akkor hívja meg a Loomiót, amikor adatot szeretne olvasni vagy módosítani. A csoport webhookja lehetővé teszi az ellenkező irányú adatküldést. A Loomio a kiválasztott csoporteseményeket a bekövetkezésükkor elküldi a végpontodra, így az integrációnak nem kell rendszeresen lekérdeznie a REST API-t a változásokért.

A webhookokat csoportonként kell beállítani, és ehhez csoportadminisztrátori jogosultság szükséges. A Loomio felületén így kezelheted őket:

1. Nyisd meg a csoportot.
2. Nyisd meg a csoport menüjét, és válaszd ki a **Csevegési integrációk** lehetőséget.
3. Add hozzá a végpontod által fogadott üzenetformátumnak megfelelő integrációt. Általános célú végponthoz használd a Mattermost/Markdown formátumot.
4. Adj meg egy nevet és a cél URL-jét.
5. Válaszd ki azokat az eseményeket, amelyeket a Loomio automatikusan küldjön el.
6. Mentsd el az integrációt, majd a **Kapcsolat tesztelése** lehetőséggel küldj egy tesztüzenetet.

Használj HTTPS-célcímet nem kitalálható URL-lel. A Loomio megköveteli, hogy a cél nyilvános címre oldódjon fel, és blokkolja a helyi vagy privát hálózati címekre irányuló kéréseket.

Az ágensek és más integrációk az alább ismertetett, Bearer-hitelesítést használó chatbot-végpontokon keresztül is kezelhetik a webhookokat. Az erőforrás neve a Loomio csevegési integrációival való kompatibilitás miatt `chatbots`, de általános kimenő webhookokat is jelöl.

<!-- translation-section: list-webhooks -->

### Webhookok listázása

Visszaadja a csoporthoz beállított csevegési integrációkat. Az API-kulcshoz tartozó felhasználónak a csoport adminisztrátorának kell lennie. A válasz cél-URL-eket tartalmaz, ezért nem tehető hozzáférhetővé a csoport egyszerű tagjai számára.

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
| `webhook_kind` | Üzenetformátum: `markdown`, `slack`, `discord`, `microsoft` vagy `webex` |
| `server` | A cél URL-je |
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

Az API-kulcshoz tartozó felhasználónak a `group_id` által megadott csoport adminisztrátorának kell lennie. Mentés előtt a rendszer ellenőrzi, hogy a cél nyilvános URL-e.

<!-- translation-section: update-a-webhook -->

### Webhook frissítése

`PATCH /api/b2/chatbots/:id`

Küldd el a módosítani kívánt mezőket. A webhook nem helyezhető át másik csoportba a `group_id` módosításával.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Webhook célcímének tesztelése

Küldj Markdown-kompatibilis tesztüzenetet a célcímre a beállítások mentése előtt vagy után.

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

A konfiguráció törlése leállítja a további kézbesítéseket. A Loomio-csoport tartalmát nem törli.

<!-- translation-section: event-types -->

### Eseménytípusok

Egy webhook a következő eseménytípusokra iratkozhat fel:

| Esemény | Mikor történik a küldés |
| --- | --- |
| `new_discussion` | Beszélgetés indul |
| `discussion_edited` | Beszélgetést szerkesztenek |
| `new_comment` | Hozzászólás jön létre |
| `poll_created` | Szavazás indul |
| `poll_edited` | Szavazást szerkesztenek |
| `poll_closing_soon` | Közeledik a szavazás lezárásának időpontja |
| `poll_expired` | Elérkezik a szavazás lezárásának időpontja |
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

A kérés időkorlátja öt másodperc. A `2xx` válasz sikeresnek számít, beleértve a `204 No Content` választ is. A webhookot fogadó szolgáltatások válaszoljanak gyorsan, a hosszabb feladatokat aszinkron módon dolgozzák fel, és kezeljék az ismétlődő vagy eltérő sorrendben érkező kézbesítéseket.

A Loomio jelenleg nem ad hozzá webhook-aláírást, közös titkot tartalmazó fejlécet, eseményazonosítót vagy kézbesítési azonosítót. Kezeld a teljes cél-URL-t hitelesítő adatként, ne tedd nyilvánossá, és helyezz el benne egy kitalálhatatlan tokent, ha a fogadó szolgáltatás ezt támogatja. Ha stabil, géppel olvasható eseménysémára vagy aláírt kézbesítésre van szükséged, használd a webhookot változásértesítésként, és kérd le az aktuális rekordokat a hitelesített Felhasználói API-n keresztül.

<!-- translation-section: payload-formats -->

### Adatformátumok

A webhookok által küldött adatok csevegőszolgáltatásokban való megjelenítésre szánt üzenetek. Nem teljes, szerializált Loomio-rekordok. Az üzenetben található hivatkozások azonosítják az érintett Loomio-tartalmat; az integráció a Felhasználói API-n keresztül kérhet további adatokat, ha strukturált formában van szüksége az aktuális állapotra.

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

Az üzenet pontos szövege az eseménytől, a csoport nyelvi beállításától, a csak értesítést küldő beállítástól és a Loomio verziójától függ. A fogadó szolgáltatások a kiválasztott formátum dokumentált legfelső szintű mezőire támaszkodjanak a mondatok szövegének elemzése helyett.

<!-- translation-section: search -->

## Keresés

Keress az API-kulcshoz tartozó felhasználó számára látható beszélgetések, hozzászólások, szavazások, szavazatok és következtetések között. Az eredmények akkor is tartalmaznak nyilvános tartalmat, ha a felhasználó nem tagja az adott csoportnak; a privát tartalomra továbbra is a szálak szokásos láthatósági szabályai vonatkoznak.

`GET /api/b2/search`

<!-- translation-section: params -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `query` | Keresési szöveg. Pontos és közelítő egyezések is támogatottak |
| `group_id` | Az eredmények szűkítése egy látható csoportra |
| `org_id` | Az eredmények szűkítése egy látható szülőcsoportra és annak látható alcsoportjaira. Közvetlen beszélgetésekhez használd a `0` értéket |
| `type` | Az eredmények szűkítése egy típusra: `Discussion`, `Comment`, `Poll`, `Stance` vagy `Outcome` |
| `types` | Az eredménytípusok vesszővel elválasztott listája |
| `tag` | Az eredmények szűkítése az ezzel a címkével ellátott szálakra |
| `author_id` | Az eredmények szűkítése egy szerző tartalmára. A `query` nélkül a szerző közelmúltbeli látható tevékenységét adja vissza |
| `order` | Állítsd `authored_at_desc` értékre a találatok létrehozási idő szerinti rendezéséhez |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

A válasz egy `search_results` tömböt tartalmaz. Minden találat azonosítja az egyező rekordot és annak látható környezetét többek között a következő mezőkkel: `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` és `tags`. A találatra nem vonatkozó mezők értéke `null`.

<!-- translation-section: participation-report -->

## Részvételi jelentés

Ugyanazokat az összesített részvételi adatokat adja vissza, amelyeket a Loomio részvételi jelentése használ.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `section` | A jelentés szakasza: `base`, `users` vagy `countries`. Személyenkénti tevékenységhez használd a `users` értéket |
| `group_scope` | `custom` vagy `my`. A régi `all` értéket `my` értékként kezeli, mert a Felhasználói API kulcsai soha nem kapnak a teljes példányra kiterjedő hozzáférést |
| `group_ids` | Vesszővel elválasztott csoportazonosítók, ha `group_scope=custom`. Figyelmen kívül hagyja azoknak a csoportoknak az azonosítóit, amelyekben az API felhasználója nem tag |
| `start_month` | Az első figyelembe vett hónap `YYYY-MM` formátumban; alapértelmezés szerint a 12 hónappal ezelőtti hónap |
| `end_month` | Az utolsó figyelembe vett hónap `YYYY-MM` formátumban; alapértelmezés szerint az aktuális hónap |
| `interval` | A `base` szakasz időköze: `day`, `week`, `month` vagy `year` |
| `member_type` | A `section=users` mellett állítsd `delegate` értékre, hogy csak a jelenlegi küldötteket adja vissza |

Egy személy akkor számít küldöttnek, ha bármelyik kiválasztott csoportban aktív küldötti tagsággal rendelkezik. A hozzá tartozó darabszámokat az összes kiválasztott csoportból összesíti. A küldöttek sorait akkor is visszaadja, ha minden tevékenység darabszáma nulla. A darabszámok a szálakat, hozzászólásokat, szavazásokat, szavazatokat, következtetéseket és reakciókat fedik le; nem a szavazási részvétel arányát mutatják. A felhasználók sorai az azonosított szavazásokban kiadott, leadott és elmulasztott szavazólapok számát is tartalmazzák. A névtelen szavazások kimaradnak minden személyenkénti szavazati darabszámból. Az `all_votes_cast` csak akkor igaz, ha legalább egy szavazólapot kiadtak, és minden kiadott szavazólapot leadtak.

Az API ugyanazokat a csoportláthatósági szabályokat alkalmazza, mint az alkalmazásban elérhető jelentés. Egy felhasználói API-kulcs nem teheti elérhetővé olyan csoportok jelentésadatait, amelyekhez a felhasználó nem fér hozzá.

<!-- translation-section: example -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

A `users` tömb a tevékenységi adatokat tartalmazó teljes sorokat adja vissza:

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

Hozz létre beszélgetést az API-kulcshoz tartozó felhasználóként.

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
| `recipient_message` | Az e-mailes meghívóban szereplő üzenet |

<!-- translation-section: example-2 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Beszélgetés lekérése

Kérj le egy beszélgetést az egész számként megadott azonosítójával vagy a szövegként megadott kulcsával.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Beszélgetések listázása

Listázd egy csoportnak az API-kulcshoz tartozó felhasználó számára látható beszélgetéseit. Nyilvánosan látható csoport esetén a nem tagok is listázhatják a nyilvános beszélgetéseket; a privát beszélgetésekhez továbbra is csak azok a felhasználók férhetnek hozzá, akik a Loomióban is olvashatják őket.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a beszélgetéseit listázni szeretnéd |
| `status` | Szöveg, opcionális, alapértelmezett értéke `open`. Értékek: `open`, `closed`, `all` |
| `limit` | Egész szám, opcionális, alapértelmezett értéke 50. Oldalméret |
| `offset` | Egész szám, opcionális, alapértelmezett értéke 0. Eltolás a lapozáshoz |

Korábbi paraméterek: a `per` és a `from` a `limit` és az `offset` alternatív neveként használható, és továbbra is működni fog.

<!-- translation-section: example-4 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Szálak listázása

Listázd az API-kulcshoz tartozó felhasználó számára látható beszélgetési és szavazási szálakat a legutóbbi aktivitás szerint rendezve. A szál azonosítója a `topic_id` értéke.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `limit` | Egész szám, opcionális, alapértelmezett értéke 50. Oldalméret |
| `offset` | Egész szám, opcionális, alapértelmezett értéke 0. Eltolás a lapozáshoz |

<!-- translation-section: example-5 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Szál olvasása

Olvasd el a szálat, annak rendezett eseményfolyamát vagy teljes látható Markdown-dokumentumát.

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

Az `items` végpont a rendezett eseményfolyamot adja vissza, beleértve a látható hozzászólásokat, szavazásokat, szavazatokat és következtetéseket. A `markdown` végpont a teljes látható szálat egyetlen Markdown-dokumentumként adja vissza. A szavazatok indoklásai csak akkor szerepelnek benne, ha láthatók az API-kulcshoz tartozó felhasználó számára.

Minden szálvégpont ugyanazokat a jogosultságokat érvényesíti, mint a Loomio felülete. Az API-kulcs nem biztosít hozzáférést olyan szálhoz, amelyet a felhasználó egyébként nem nyithat meg.

<!-- translation-section: edit-discussion -->

## Beszélgetés szerkesztése

Szerkessz egy beszélgetést az API-kulcshoz tartozó felhasználó nevében. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie az adott beszélgetés szerkesztésére.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `title` | Frissített cím |
| `description` | Frissített leírás |
| `description_format` | `md` vagy `html`, opcionális, alapértelmezett értéke `md` |
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

Törölj logikailag egy beszélgetést az API-kulcshoz tartozó felhasználó nevében. Ez eltávolítja a beszélgetést, de megőrzi a beszélgetés adatbázisrekordját.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Hozzászólás létrehozása

Hozz létre egy hozzászólást egy beszélgetésben az API-kulcshoz tartozó felhasználó nevében.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `discussion_id` | Egész szám, kötelező. Annak a beszélgetésnek az azonosítója, amelyhez hozzászólsz |
| `body` | A hozzászólás szövege, kötelező, kivéve ha mellékletet adsz meg |
| `body_format` | `md` vagy `html`, opcionális, alapértelmezés: `md` |

<!-- translation-section: example-9 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Hozzászólás szerkesztése

Szerkessz egy hozzászólást az API-kulcshoz tartozó felhasználó nevében. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultnak kell lennie az adott hozzászólás szerkesztésére.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `body` | A hozzászólás frissített szövege |
| `body_format` | `md` vagy `html`, opcionális, alapértelmezés: `md` |

<!-- translation-section: example-10 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Hozzászólás logikai törlése

Törölj logikailag egy hozzászólást az API-kulcshoz tartozó felhasználó nevében. Ez eltávolítja a hozzászólást és elrejti a szövegét, de megőrzi a hozzászólás adatbázisrekordját.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Szavazás létrehozása

Hozz létre egy szavazást az API-kulcshoz tartozó felhasználó nevében.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, nem kötelező, alapértelmezés: null. A szavazás csoportjának azonosítója. Ha megadod a `discussion_id` értékét, a `group_id` figyelmen kívül marad |
| `discussion_id` | Egész szám, nem kötelező, alapértelmezés: null. Annak a beszélgetési szálnak az azonosítója, amelyhez hozzáadod ezt a szavazást |
| `title` | Karakterlánc, kötelező. A szavazás címe |
| `poll_type` | Karakterlánc, kötelező. Értékek: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Karakterlánc, nem kötelező. A szavazás szövege |
| `details_format` | Karakterlánc, nem kötelező, alapértelmezés: `md`. Értékek: `md` vagy `html` |
| `options` | Karakterláncok tömbje. Ha a `poll_type` értéke `proposal`, az érvényes értékek: `agree`, `disagree`, `abstain`, `block`. Ha a `poll_type` értéke `meeting`, adj meg ISO 8601 formátumú dátumot vagy dátumot és időpontot tartalmazó karakterláncokat. Minden más szavazástípusnál bármilyen karakterlánc érvényes |
| `closing_at` | ISO 8601 formátumú karakterlánc vagy null, alapértelmezés: null. Példa: `2026-09-01T12:00:00Z`. Ha null, nem lehet szavazni, és a szavazás előkészítés alatt áll |
| `specified_voters_only` | Logikai érték, nem kötelező, alapértelmezés: false. Ha true, csak a megadott emberek szavazhatnak. Ha false, a csoport minden tagja meghívót kap a szavazásra |
| `hide_results` | Karakterlánc, nem kötelező, alapértelmezés: `off`. Értékek: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Logikai érték, alapértelmezés: false. A lehetőségek véletlenszerű sorrendben jelennek meg a szavazóknak |
| `anonymous` | Logikai érték, nem kötelező, alapértelmezés: false. Elrejti a szavazók személyazonosságát |
| `recipient_audience` | `group` vagy null, nem kötelező, alapértelmezés: null. Ha `group`, az egész csoport értesítést kap |
| `notify_on_closing_soon` | Karakterlánc, nem kötelező, alapértelmezés: `nobody`. Értékek: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Az értesítendő vagy meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szavazásra meghívandó emberek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóba kerülő üzenet |
| `notify_recipients` | Logikai érték, alapértelmezés: false. Ha false, értesítés küldése nélkül adja hozzá az embereket. Ha true, mindenki, akit ezzel a kéréssel meghívsz, értesítő e-mailt kap |

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

Listázd egy csoport szavazásait, amelyek láthatók az API-kulcshoz tartozó felhasználó számára. Egy nyilvánosan látható csoport nyilvános szavazásait olyan felhasználó is listázhatja, aki nem tagja a csoportnak; a privát szavazásokhoz továbbra is csak azok a felhasználók férhetnek hozzá, akik a Loomióban is olvashatják őket. A válasz minden látható szavazás aktuális következtetését tartalmazza, így a `status=closed` használatával listázhatod azokat a javaslatokat, amelyekről már döntés született.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a szavazásait listázod |
| `status` | Karakterlánc, nem kötelező, alapértelmezés: `active`. Értékek: `active`, `closed`, `all` |
| `limit` | Egész szám, nem kötelező, alapértelmezés: 50. Oldalméret |
| `offset` | Egész szám, nem kötelező, alapértelmezés: 0. A lapozás eltolása |

Korábbi paraméterek: a `per` és a `from` a `limit` és az `offset` alternatív neveként használható, és továbbra is működik.

<!-- translation-section: example-14 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Szavazás szerkesztése

Szerkessz egy szavazást az API-kulcshoz tartozó felhasználóként. Ugyanazok a jogosultságok érvényesek, mint a Loomióban: a felhasználónak jogosultsággal kell rendelkeznie az adott szavazás szerkesztéséhez.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `title` | Módosított cím |
| `details` | A szavazás módosított részletei |
| `details_format` | `md` vagy `html`, nem kötelező, alapértelmezés: `md` |
| `options` | A lehetőségek módosított nevei. A lehetőségek megváltoztatása a szavazás állapotától függően hatással lehet a meglévő szavazatokra |
| `closing_at` | ISO 8601 formátumú karakterlánc vagy null |
| `recipient_audience` | `group` vagy null. Ha `group`, az egész csoport értesítést kap |
| `recipient_user_ids` | Az értesítendő vagy meghívandó felhasználók azonosítóinak tömbje |
| `recipient_emails` | A szavazásra meghívandó emberek e-mail-címeinek tömbje |
| `recipient_message` | Az e-mailes meghívóba kerülő üzenet |

<!-- translation-section: example-15 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Szavazás logikai törlése

Törölj logikailag egy szavazást az API-kulcshoz tartozó felhasználóként. Ez töröltként jelöli a szavazást, de megtartja a szavazás rekordját.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Tagságok listázása

Listázza az API-kulcshoz tartozó felhasználó számára látható tagságokat. A csoport tagjai láthatják a tagok nevét, azonosítóját, titulusát és szerepkörét. Az e-mail-címek csak az API-kulcshoz tartozó felhasználó saját fiókjánál szerepelnek, illetve akkor, ha ez a felhasználó a csoport adminisztrátora.

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

Küldj egy listát az e-mail-címekről. A művelet minden új e-mail-címre meghívót küld a csoportba. A tagságok listázásával ellentétben ehhez a művelethez csoportadminisztrátori jogosultság szükséges.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Paraméterek

| Név | Leírás |
| --- | --- |
| `group_id` | Egész szám, kötelező. Annak a csoportnak az azonosítója, amelynek a tagságait kezelni szeretnéd |
| `emails` | Karakterláncokból álló tömb, kötelező. A csoportba meghívni kívánt emberek e-mail-címei |
| `remove_absent` | Logikai érték. Ha igaz, eltávolít a csoportból mindenkit, akinek az e-mail-címe nem szerepel a listában |

<!-- translation-section: example-18 -->

### Példa

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Ha megadod a `remove_absent=1` paramétert, a csoport minden olyan tagja eltávolításra kerül, aki nem szerepel a listában. Légy óvatos, mert a csoportod összes tagját eltávolíthatod.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

A válasz egy objektum, amely ezt tartalmazza: `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
