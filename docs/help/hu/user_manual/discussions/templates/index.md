---
title: Beszélgetési sablonok
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: 7e9723081f24e3e2
  how-templates-are-used: 32def3a80f6ac655
  choose-who-is-notified-by-default: 60956973a9d98035
  template-settings: 25d0e5d468c1fa60
  example-bottle-trial-review: 591cce7d11ee6789
  create-a-template: c19ee5eb7fe092af
  manage-the-template-list: 59c330c041d44cc6
  share-templates-between-groups: cbf0ef07f239a2bd
  let-members-create-templates: 1758e3b5a9e5c568
  templates-for-non-members: 5508f8208a742556
  related: ddf6006b7540f500
title_source: 5ac608aa42806d13
title_generated: b1d1b8868cc08b68
---

<!-- translation-section: introduction -->

# Beszélgetési sablonok

A beszélgetési sablonok segítenek a csoportodnak abban, hogy minden alkalommal ugyanúgy indítsatok beszélgetéseket. Egy sablon megadhatja a címet, a leírást, a címkéket és a beszélgetést indító személynek szóló útmutatót. Az alapbeállításokat is meghatározza, például azt, hogy kapjon-e értesítést az egész csoport, és milyen szavazásokat javasoljon a Loomio.

A csoport minden új beszélgetése egy sablonból indul. Amikor valaki a **Beszélgetés indítása** gombot választja, a Loomio megjeleníti a csoport sablonjait. Az **Üres sablon** is sablon, így a csoportod annak alapbeállításait is módosíthatja.

A sablonok jól használhatók a csoportod ismétlődő folyamataihoz, például projektek értékeléséhez, tanácskérési folyamatokhoz, találkozók előkészítéséhez, finanszírozási döntésekhez vagy dokumentumok jóváhagyásához. A beszélgetést indító személy az indítás előtt továbbra is mindent szerkeszthet.

<!-- translation-section: how-templates-are-used -->

## A sablonok használata

1. Egy tag a csoport oldalán kiválasztja a **Beszélgetés indítása** gombot.
2. A Loomio felsorolja a csoport látható sablonjait. Mindegyiknél megjelenik a cím és az alcím.
3. A tag kiválaszt egy sablont. A Loomio megnyitja az új beszélgetés űrlapját, a sablon alapján kitöltve.
4. A sablon súgója útmutatóként megjelenik az űrlap tetején.
5. A tag szerkeszti a címet, a leírást, a címkéket és a meghívottak listáját, majd kiválasztja a **Beszélgetés indítása** gombot.

![](list.png)

Egy sablon módosítása csak a módosítás után indított beszélgetésekre hat. A korábban abból indított beszélgetések megtartják a tartalmukat és a beállításaikat.

<!-- translation-section: choose-who-is-notified-by-default -->

## Válaszd ki, ki kapjon alapértelmezés szerint értesítést

A **Meghív** beállítás határozza meg, hogy az új beszélgetés űrlapja alapértelmezés szerint kiket hív meg. Két lehetőség közül választhatsz:

- **Mindenki a csoportban**: a csoport megjelenik a beszélgetés űrlapjának **Meghív** mezőjében, és a beszélgetés indításakor minden tag értesítést kap.
- **Egyik sem**: a **Meghív** mező kezdetben üres. Senki sem kap értesítést, hacsak a szerző nem ad hozzá embereket.

A Loomio beépített sablonjai, köztük az **Üres sablon**, a **Mindenki a csoportban** beállítást használják. Ha a csoportod nem szeretné, hogy minden új beszélgetésről minden tag értesítést kapjon, szerkeszd a csoport által használt sablonokat, és állítsd a **Meghív** mezőt az **Egyik sem** értékre.

![](use.png)

A szerző a beszélgetés indítása előtt mindig módosíthatja a meghívottak listáját. Eltávolíthatja a csoportot, hogy senki se kapjon értesítést, vagy helyette hozzáadhat konkrét személyeket. Ez a beállítás csak az értesítésekre hat. A csoport tagjai bármelyik lehetőséget választod, továbbra is megtalálhatják és elolvashatják a beszélgetést a csoportban.

A csoport csak akkor kerül a meghívottak listájára, ha a szerző jogosult az egész csoport értesítésére. Az adminok ezt mindig megtehetik. A tagok akkor tehetik meg, ha a csoport engedélyei között be van kapcsolva az **A tagok mindenkit értesíthetnek a csoportban** beállítás.

<!-- translation-section: template-settings -->

## A sablon beállításai

A csoport adminjai a sablonlistában a sablon melletti műveleti menüből szerkeszthetik a sablont. Az űrlapon a következő beállítások találhatók:

![](form.png)

- **Sablon címe**: a sablonlistában megjelenő rövid név.
- **Sablon alcíme**: egy sor, amely elmagyarázza, mikor érdemes használni a sablont.
- **Sablon súgó**: az új beszélgetés űrlapjának tetején megjelenő útmutató. Itt magyarázd el a folyamatot, és adj meg hasznos hivatkozásokat. Ez nem része a beszélgetésnek.
- **Csoport**: azt határozza meg, hogy a sablon a csoportban indít-e beszélgetést, vagy közvetlen beszélgetést indít. A közvetlen beszélgetést csak a meghívott személyek láthatják.
- **Alapértelmezett cím**: minden új beszélgetéshez előre kitöltött cím. A szerző szerkesztheti.
- **Példa cím**: az üres címmezőben megjelenő példa. Akkor használd, ha egy alapértelmezett cím nem illene minden beszélgetéshez.
- **Címkék**: minden új beszélgetéshez hozzáadott címkék. A szerző eltávolíthatja őket.
- **Leírás**: a beszélgetés kezdőszövege. Használj címsorokat, kérdéseket vagy hivatkozásokat, hogy segíts az embereknek megfogalmazni a mondanivalójukat.
- **Meghív**: azt határozza meg, hogy alapértelmezés szerint meghívja-e a csoport minden tagját. Lásd: [Válaszd ki, ki kapjon alapértelmezés szerint értesítést](#choose-who-is-notified-by-default).
- **Szavazási sablonok**: az ehhez a folyamathoz javasolt szavazások. Az új beszélgetés űrlapján jelennek meg. Akkor is ezek jelennek meg először, amikor valaki szavazást indít a beszélgetésben. Nem indulnak el automatikusan.
- **Egyidejű szavazások engedélyezése**: azt határozza meg, hogy egyszerre több szavazás is nyitva lehet-e a beszélgetésben.
- **Hozzászóláshossz-korlát**: a hozzászólások választható maximális hossza.

Csak akkor használj alapértelmezett címet, ha az minden alkalommal pontos marad. Egyébként írj olyan példacímet, amely arra ösztönzi a szerzőt, hogy nevezze meg az adott értékelést, időszakot, dokumentumot vagy döntést.

<!-- translation-section: example-bottle-trial-review -->

## Példa: a palack-visszaváltási próba értékelése

Az Oatmilk Cooperative minden ciklus után értékeli a visszaváltható palackok próbaüzemét. A sablon címe „A palack-visszaváltási próba értékelése”, és alapértelmezett címet is megad. Hozzáadja a „Palack-visszaváltási próba” címkét. A leírás arra kéri a tagokat, hogy olvassák el a heti jelentést, és vegyék figyelembe a visszaváltási arányokat, a mosási nyilvántartásokat, a kávézók visszajelzéseit és a szállítási költségeket. Először hangulatfelmérést, majd Beleegyezés típusú szavazást javasol.

Ez azért működik sablonként, mert a cél és az értékelés alapjául szolgáló adatok köre minden ciklusban ugyanaz. Csak a megfigyelések és a döntések változnak.

<!-- translation-section: create-a-template -->

## Hozz létre sablont

A csoport adminjai a sablonlistában kiválaszthatják az **Új sablon** gombot. Válassz egy példát a Loomio galériájából, vagy kezdj egy üres sablonnal, majd alakítsd az igényeidhez, és mentsd el.

A galériában kereshetsz és szűrhetsz. Egy példa csak akkor kerül a csoportodba, amikor elmented.

<!-- translation-section: manage-the-template-list -->

## A sablonlista kezelése

Egy csoport létrehozásakor a Loomio a csoport típusához illő sablonokat ad hozzá. Kezdetben csak az **Üres sablon** és a **Gyakorlati megbeszélés** látható. A többi rejtett, és az adminok megjeleníthetik őket.

A csoport adminjai a sablon melletti műveleti menüben:

- szerkeszthetik a tartalmát és a beállításait;
- elrejthetik a sablonlistából;
- újra megjeleníthetik a **Rejtett sablonok** közül;
- átrendezhetik a látható sablonok sorrendjét;
- exportálhatják JSON-fájlként; vagy
- törölhetik.

Az elrejtett sablon megmarad későbbi használatra. Egy sablon törlése nem törli az abból indított beszélgetéseket.

<!-- translation-section: share-templates-between-groups -->

## Ossz meg sablonokat csoportok között

Válaszd ki a sablon műveleti menüjében a **JSON exportálása** lehetőséget, hogy fájlként letöltsd. Ha egy másik csoportban szeretnéd használni, válaszd ki az **Új sablon**, majd a **JSON importálása** lehetőséget. Az űrlap az importált tartalommal nyílik meg, így mentés előtt átnézheted.

Az egyéni szavazási sablonokra mutató hivatkozások nem kerülnek bele a fájlba. Ezeket a szavazási sablonokat külön exportáld és importáld.

<!-- translation-section: let-members-create-templates -->

## Engedélyezd a tagoknak a sablonok létrehozását

Alapértelmezés szerint csak a csoport adminjai hozhatnak létre és szerkeszthetnek sablonokat. Egy admin bekapcsolhatja az **A tagok sablonokat hozhatnak létre** beállítást a **Csoport beállítások** → **Engedélyek** alatt.

Ha ez be van kapcsolva, a tagok beszélgetési és szavazási sablonokat hozhatnak létre, és szerkeszthetik az általuk létrehozott sablonokat. Az adminok a csoport minden sablonját szerkeszthetik. Egy tag sablonja a mentés után megjelenik a csoport sablonlistájában, ezért az engedély bekapcsolása előtt állapodjatok meg az elnevezés és az ellenőrzés módjában.

<!-- translation-section: templates-for-non-members -->

## Sablonok nem tagok számára

Ha a **Nem tagok is indíthatnak beszélgetéseket** beállítás be van kapcsolva, a csoporton kívüli emberek ugyanabból a sablonlistából választhatnak. A beszélgetési űrlapjuk alapértelmezés szerint soha nem hívja meg a csoportot. Lásd: [Privát beküldések gyűjtése](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Kapcsolódó oldalak

- [Szavazási sablonok](/en/user_manual/polls/poll_templates)
