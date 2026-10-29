---
title: Szavazási sablonok
source_revision: 00d781409c832b216c95759c1369678ad240e246
source_file: docs/help/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-29'
sections:
  introduction: a535465485cdbc13
  who-can-manage-templates: 6c3d5e693cd1dfdc
  create-a-poll-template: 0fafc6275b6c9153
  template-title-subtitle-and-help: 5a3f6c78e32fb066
  voting-method: c645269a1a17d1c8
  example-title-details-and-tags: 0f0d84a8b9b6ecb2
  response-options: 727afbf0dcea6069
  duration-and-settings: f1f3643e94524af9
  manage-the-template-list: 76e78b8a60f1d08c
  save-a-poll-as-a-template: 36dc7b5d410d0eea
  start-a-new-template: 4f14910d88b22de8
  configure-the-template: bec89f7804dd12f8
  edit-a-default-template: 6f1e7050d20ed373
generated:
  introduction: d0536d14f08b8f1f
  who-can-manage-templates: 138021fefe136330
  create-a-poll-template: 40e0eddc7f902d7c
  template-title-subtitle-and-help: 6513075b3eba60ff
  voting-method: '093e7de6c5c816ad'
  example-title-details-and-tags: c40bcf44faa3517c
  response-options: 969ece4fd4afe274
  duration-and-settings: 04d36bf6698bfd33
  manage-the-template-list: 6e59f45ace92921d
  save-a-poll-as-a-template: 803aeebd4d7a065e
  start-a-new-template: 41f96c7b3e0a6415
  configure-the-template: 166d47166cda7044
  edit-a-default-template: 8572d30093938299
title_source: 114cca246e357304
title_generated: bf81c7a2bbcc8a9b
---

<!-- translation-section: introduction -->

# Szavazási sablonok

A szavazási sablonok újra felhasználható kiindulópontok, amelyek a **Szavazás indítása** vagy az **Új szavazás** kiválasztásakor jelennek meg. A sablon egy szavazási módot kapcsol össze előre megadott útmutatással, válaszlehetőségekkel és beállításokkal.

Ezen az oldalon beállíthatod, hogy mely sablonok legyenek elérhetők egy csoport számára, vagy létrehozhatsz egyet a saját folyamatodhoz. Egy adott szavazáshoz a [Javaslatok](../proposals/) vagy a [Szavazások](../proposal_types/) oldalon találsz segítséget a sablon kiválasztásához. Egy teljes döntési folyamat támogatásához lásd a [Döntéshozatal](/en/guides/making_decisions/) oldalt.

Szavazás indításakor válaszd ki a **Javaslat** vagy a **Szavazás** fület, majd válassz a csoport számára elérhető sablonok közül.

A sablon bevezetőt, mintatartalmat, lehetőségeket és beállításokat tartalmaz. A szavazás indítása előtt tekintsd át és igazítsd ezeket az adott döntéshez. Az új szavazás szerkesztése nem módosítja az újra felhasználható sablont.

<!-- translation-section: create-a-poll-template -->

## Szavazási sablon létrehozása

<!-- translation-section: save-a-poll-as-a-template -->

### Mentés sablonként

Egy meglévő javaslat vagy szavazás újrafelhasználásához nyisd meg a műveleti menüjét, és válaszd a **Mentés sablonként** lehetőséget.

![Egy javaslat megnyitott műveleti menüvel és kiemelt Mentés sablonként lehetőséggel](save_as_template.png)

A szavazás dátumai, a szavazók, a szavazatok, az eredmények és a szavazás következtetése nem kerülnek bele a sablonba.

<!-- translation-section: start-a-new-template -->

### Új sablon indítása

Nyisd meg a sablonlistát, és válaszd az **Új sablon** lehetőséget. Indulj ki egy példából vagy egy üres sablonból, majd válaszd ki a csoportot, amely használni fogja.

![](proposal_template_setting.png)

<!-- translation-section: edit-a-default-template -->

### Alapértelmezett sablon szerkesztése

Egy alapértelmezett sablon, például a **Beleegyezés** átalakításához nyisd meg a műveleti menüjét, és válaszd ki a **Sablon szerkesztése** lehetőséget. Ez a lehetőség a csoportadminok számára érhető el. Mentéskor egyéni sablon jön létre a csoportod számára, az alapértelmezett változat pedig rejtetté válik a csoport sablonlistájában.

![A Beleegyezés alapértelmezett sablon a Sablon szerkesztése művelettel](edit_default_template.png)

<!-- translation-section: configure-the-template -->

## A sablon beállításai

Adj a sablonnak olyan nevet és alcímet, amelyek leírják, mikor érdemes használni. A többi mezőt is módosíthatod, hogy jobban megfeleljenek az újrafelhasználásnak. A **Sablon mentése** kiválasztása után a sablon megjelenik a listában, amikor valaki új javaslatot vagy szavazást indít.

[![A Szabályzatmódosítás beleegyezési folyamata sablon teljes űrlapja](poll_template_new.png)](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### A sablon címe, alcíme és súgója

A címmel és az alcímmel magyarázd el, mikor érdemes a sablont választani. A folyamatra vonatkozó útmutatást, a döntési szabályokat és a segédanyagokra mutató hivatkozásokat a **Sablon súgó** mezőben add meg.

<!-- translation-section: voting-method -->

### Szavazási mód

Válaszd ki, mit kell kifejezniük a résztvevőknek, és hogyan kell kiszámítani az eredményt.

- **Javaslat**: válaszolj egy állításra a meghatározott álláspontok egyikével;
- **Kiválasztás**: válassz ki egy vagy több lehetőséget;
- **Pontozás**: értékelj minden lehetőséget egy skálán;
- **Pontelosztás**: oszd el a rendelkezésre álló korlátozott számú pontot;
- **Rangsorolás**: rendezd a lehetőségeket a preferenciáid sorrendjébe;
- **Időpontszavazás**: jelezd, mikor érsz rá; és
- **STV**: rangsorold a jelölteket egy arányos, több győztest választó szavazáson.

A szavazási mód megváltoztatása módosítja a sablonban elérhető mezőket és az eredmény kiszámítását.

<!-- translation-section: example-title-details-and-tags -->

### Mintacím, részletek és címkék

Használj segítő kérdéseket vagy útmutatást a mintacímhez és a részletekhez, ha minden szavazáshoz más tartalomra van szükség. Csak akkor adj meg alapértelmezett kategóriacímkéket, ha azok a sablon minden használatakor érvényesek.

<!-- translation-section: response-options -->

### Válaszlehetőségek

Az olyan szavazási módoknál, mint a Javaslat és a Kiválasztás, beállíthatod a válaszlehetőségeket. Válaszd ki a lehetőség melletti ceruza ikont az alábbiak szerkesztéséhez:

- **Opció neve**: a válasz rövid megnevezése;
- **Ikon**: a válasz vizuális jelölése;
- **Jelentése**: mit fejez ki a lehetőség kiválasztása; és
- **Indoklás kérése**: a kérdés, amely akkor jelenik meg, amikor valaki megindokolja a válaszát.

![](poll_type_edit_option.png)

Úgy határozd meg a lehetőségeket, hogy a résztvevők találgatás nélkül meg tudják különböztetni őket. A jelentésük feleljen meg a csoportod által ténylegesen használt döntési szabályoknak.

<!-- translation-section: duration-and-settings -->

### Időtartam és beállítások

Állíts be olyan alapértelmezett időtartamot, amely a sablon legtöbb használatához megfelelő. A szerző az egyes szavazásoknál módosíthatja a lezárás időpontját.

Más alapbeállítások az eredmények láthatóságát, a névtelen szavazást, a [súlyozott szavazást](../weighted_voting/), a szavazatok indoklásának követelményeit, az emlékeztetőket, a határozatképességet és az adott szavazási mód működését szabályozhatják. A hatásukról a [Javaslatok és szavazások beállításai](../settings/) oldalon olvashatsz.

<!-- translation-section: manage-the-template-list -->

## A sablonok kezelése

A sablon melletti műveleti menüben a következőket teheted:

- **Szerkesztés**: módosíthatod az újra felhasználható tartalmát és alapbeállításait;
- **Mozgat**: másik helyre teheted a listában;
- **Elrejt**: elrejtheted a szavazást indító emberek elől; vagy
- **Törlés**: törölheted azt az egyéni sablont, amelyre már nincs szükség.

![A csoport sablonlistája a Szabályzatmódosítás beleegyezési folyamata sablon megnyitott műveleti menüjével](template_manage.png)

Válaszd a **Rejtett sablonok megjelenítése** lehetőséget az elrejtett sablonok áttekintéséhez vagy visszaállításához. Az alapértelmezett sablonok elrejthetők vagy a csoporthoz igazíthatók, de nem törölhetők.

A sablon módosítása nem változtatja meg a belőle már elindított javaslatokat vagy szavazásokat.

<!-- translation-section: who-can-manage-templates -->

### Ki kezelheti a sablonokat

A csoport adminisztrátorai a csoportjuk összes szavazási sablonját létrehozhatják és kezelhetik. A **Csoport beállítások** → **Engedélyek** alatt bekapcsolhatják az **A tagok sablonokat hozhatnak létre** beállítást. Ha ez be van kapcsolva, a tagok sablonokat hozhatnak létre, és kezelhetik a saját maguk által létrehozott sablonokat.
