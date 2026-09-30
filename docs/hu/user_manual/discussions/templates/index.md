---
title: Beszélgetési sablonok
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: b8b4e292f72c1236
  how-templates-are-used: cf8ddc443006f22f
  choose-who-is-notified-by-default: 4c8192574ab6e486
  template-settings: e3526988d5d1e860
  example-bottle-trial-review: b3587db948805bc9
  create-a-template: 0e7d682ca82b8de5
  manage-the-template-list: b4ac8570b792c722
  share-templates-between-groups: 168cf25a30db9fdf
  let-members-create-templates: 2f1699d920f3eb5f
  templates-for-non-members: 1af6b934a2307d1c
  related: ddf6006b7540f500
title_source: 5ac608aa42806d13
title_generated: b1d1b8868cc08b68
---

<!-- translation-section: introduction -->

# Beszélgetési sablonok

A beszélgetési sablonok segítenek a csoportodnak abban, hogy az ismétlődő beszélgetéseket azonos módon indítsa el. A sablon címet, leírást, címkéket és útmutatást adhat a beszélgetés indítójának. Alapértelmezett beállításokat is megadhat, például hogy értesüljön-e az egész csoport, és mely szavazásokat javasolja a Loomio.

A csoportban minden új beszélgetés sablonból indul. Amikor valaki a **Beszélgetés indítása** lehetőséget választja, a Loomio megmutatja a csoport sablonjait. Az **Üres sablon** is sablon, így annak alapértelmezett beállításait is módosíthatjátok.

A sablonok jól használhatók a csoportban ismétlődő folyamatokhoz, például projektértékeléshez, tanácskéréshez, megbeszélés előkészítéséhez, támogatási döntésekhez vagy dokumentumok jóváhagyásához. A beszélgetés indítója az indítás előtt mindent szerkeszthet.

<!-- translation-section: how-templates-are-used -->

## A sablonok használata

1. Egy tag a csoport oldalán kiválasztja a **Beszélgetés indítása** lehetőséget.
2. A Loomio felsorolja a csoport látható sablonjait. Mindegyiknél megjelenik a cím és az alcím.
3. A tag kiválaszt egy sablont. A Loomio megnyitja az új beszélgetés űrlapját a sablonból kitöltött adatokkal.
4. A sablon útmutatása az űrlap tetején jelenik meg.
5. A tag szerkeszti a címet, a leírást, a címkéket és a meghívottak listáját, majd kiválasztja a **Beszélgetés indítása** lehetőséget.

![](list.png)

A sablon módosítása csak a módosítás után indított beszélgetésekre hat. A korábban indított beszélgetések tartalma és beállításai megmaradnak.

<!-- translation-section: choose-who-is-notified-by-default -->

## Válaszd ki, kik kapjanak értesítést alapértelmezés szerint

A **Meghív** beállítás határozza meg, hogy az új beszélgetés űrlapja alapértelmezés szerint kiket hív meg. Két lehetőség van:

- **Mindenki a csoportban**: a csoport megjelenik a beszélgetés űrlapjának **Meghív** mezőjében, és a beszélgetés indításakor minden tag értesítést kap.
- **Egyik sem**: a **Meghív** mező üresen jelenik meg. Senki nem kap értesítést, hacsak a szerző nem ad hozzá embereket.

A Loomio beépített sablonjai, köztük az **Üres sablon**, a **Mindenki a csoportban** beállítást használják. Ha nem szeretnétek, hogy minden új beszélgetésről értesítést kapjon az összes tag, szerkeszd a csoport által használt sablonokat, és állítsd a **Meghív** mezőt **Egyik sem** értékre.

![](use.png)

A szerző az indítás előtt bármikor módosíthatja a meghívottak listáját. Eltávolíthatja a csoportot, hogy senki ne kapjon értesítést, vagy helyette konkrét embereket adhat hozzá. Ez a beállítás csak az értesítésekre hat. A csoport tagjai bármelyik lehetőség mellett megtalálhatják és elolvashatják a beszélgetést a csoportban.

A csoport csak akkor kerül a meghívottak listájára, ha a szerző értesítheti az egész csoportot. Az adminisztrátorok ezt mindig megtehetik. A tagok akkor tehetik meg, ha a csoport engedélyei között be van kapcsolva **A tagok mindenkit értesíthetnek a csoportban**.

<!-- translation-section: template-settings -->

## A sablon beállításai

A csoport adminisztrátorai a sablonlistában, a sablon melletti műveleti menüből szerkeszthetik a sablont. Az űrlapon ezek a beállítások szerepelnek:

![](form.png)

- **Sablon címe**: a sablonlistában megjelenő rövid név.
- **Sablon alcíme**: egy sor arról, mikor érdemes használni a sablont.
- **Sablon súgó**: az új beszélgetés űrlapjának tetején megjelenő útmutatás. Itt ismertetheted a folyamatot, és hivatkozhatsz a szükséges anyagokra. Nem lesz része a beszélgetésnek.
- **Csoport**: a sablon a csoportban vagy közvetlen beszélgetésként indítson-e beszélgetést. A közvetlen beszélgetést csak a meghívottak láthatják.
- **Alapértelmezett cím**: az új beszélgetésekhez előre kitöltött cím. A szerző szerkesztheti.
- **Példa cím**: az üres címmezőben megjelenő példa. Akkor használd, ha ugyanaz az alapértelmezett cím nem illene minden beszélgetéshez.
- **Címkék**: az új beszélgetésekhez hozzáadott címkék. A szerző eltávolíthatja őket.
- **Leírás**: a beszélgetés kezdőszövege. Címsorokkal, kérdésekkel vagy hivatkozásokkal segítheted, hogy mit írjanak a résztvevők.
- **Meghív**: alapértelmezés szerint meghívja-e a csoport minden tagját. Lásd: [Válaszd ki, kik kapjanak értesítést alapértelmezés szerint](#choose-who-is-notified-by-default).
- **Szavazási sablonok**: a folyamathoz javasolt szavazások. Megjelennek az új beszélgetés űrlapján, és elsőként szerepelnek, amikor valaki szavazást indít a beszélgetésben. Nem indulnak el automatikusan.
- **Egyidejű szavazások engedélyezése**: lehet-e egyszerre egynél több nyitott szavazás a beszélgetésben.
- **Hozzászóláshossz-korlát**: a hozzászólások megadható maximális hossza.

Csak akkor adj meg alapértelmezett címet, ha az minden alkalommal pontos lesz. Egyébként írj olyan példacímet, amely segít a szerzőnek megnevezni az adott értékelést, időszakot, dokumentumot vagy döntést.

<!-- translation-section: example-bottle-trial-review -->

## Példa: a visszaváltható palackok kipróbálásának értékelése

Az Oatmilk Cooperative minden ciklus után értékeli a visszaváltható palackok kipróbálását. A sablon címe „A palackok kipróbálásának értékelése”, és alapértelmezett címet is tartalmaz. Hozzáadja a „Palackok kipróbálása” címkét. A leírás arra kéri a tagokat, hogy olvassák el a heti jelentést, és vegyék figyelembe a visszaváltási arányt, a mosási nyilvántartást, a kávézók visszajelzéseit és a szállítási költségeket. Előbb egy helyzetfelmérést, majd egy egyetértésen alapuló döntést javasol.

Ez azért használható sablonként, mert a cél és a vizsgált adatok minden ciklusban azonosak. Csak a megfigyelések és a döntések változnak.

<!-- translation-section: create-a-template -->

## Sablon létrehozása

A csoport adminisztrátorai a sablonlistában kiválaszthatják az **Új sablon** lehetőséget. Válassz egy példát a Loomio gyűjteményéből, vagy indulj egy üres sablonból, majd alakítsd át és mentsd el.

A gyűjteményben kereshetsz és szűrhetsz. A példa csak akkor kerül a csoportodhoz, amikor elmented.

<!-- translation-section: manage-the-template-list -->

## A sablonlista kezelése

Egy csoport létrehozásakor a Loomio a csoport típusához illő sablonokat ad hozzá. Kezdetben csak az **Üres sablon** és a **Gyakorlati megbeszélés** látható. A többi sablon rejtett, de az adminisztrátorok láthatóvá tehetik őket.

A csoport adminisztrátorai a sablon melletti műveleti menüben:

- szerkeszthetik a tartalmát és a beállításait;
- elrejthetik a sablonlistából;
- láthatóvá tehetik a **Rejtett sablonok** közül;
- átrendezhetik a látható sablonokat;
- exportálhatják JSON-fájlként; vagy
- törölhetik.

Az elrejtett sablon később is használható. A sablon törlése nem törli a belőle indított beszélgetéseket.

<!-- translation-section: share-templates-between-groups -->

## Sablonok megosztása csoportok között

A sablon műveleti menüjében válaszd a **JSON exportálása** lehetőséget a fájl letöltéséhez. Ha egy másik csoportban szeretnéd használni, válaszd az **Új sablon**, majd a **JSON importálása** lehetőséget. Az űrlap az importált tartalommal nyílik meg, így mentés előtt átnézheted.

Az egyéni szavazási sablonokra mutató hivatkozások nem kerülnek bele a fájlba. Ezeket a szavazási sablonokat külön exportáld és importáld.

<!-- translation-section: let-members-create-templates -->

## Sablonok létrehozásának engedélyezése a tagoknak

Alapértelmezés szerint csak a csoport adminisztrátorai hozhatnak létre és szerkeszthetnek sablonokat. Egy adminisztrátor bekapcsolhatja **A tagok sablonokat hozhatnak létre** beállítást a **Csoport beállítások** → **Engedélyek** alatt.

Ha ez be van kapcsolva, a tagok beszélgetési és szavazási sablonokat hozhatnak létre, és szerkeszthetik a saját sablonjaikat. Az adminisztrátorok a csoport minden sablonját szerkeszthetik. A tagok sablonjai mentés után megjelennek a csoport sablonlistájában, ezért az engedély bekapcsolása előtt állapodjatok meg az elnevezés és az ellenőrzés módjában.

<!-- translation-section: templates-for-non-members -->

## Sablonok nem tagok számára

Ha a **Nem tagok is indíthatnak beszélgetéseket** beállítás be van kapcsolva, a csoporton kívüliek ugyanabból a sablonlistából választhatnak. Az ő beszélgetési űrlapjuk alapértelmezés szerint soha nem hívja meg a csoportot. Lásd: [Privát beküldések gyűjtése](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Kapcsolódó oldalak

- [Szavazási sablonok](/en/user_manual/polls/poll_templates)
