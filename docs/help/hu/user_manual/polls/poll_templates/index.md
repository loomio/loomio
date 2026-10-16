---
title: Szavazási sablonok
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: f11182d62d99dbcc
  voting-methods-and-templates: 24be471686aa2dfd
  use-a-template: 8b19cdf141c41c9b
  who-can-manage-templates: 60218ef791438e19
  create-a-poll-template: c20dd8c57c3deab0
  template-title-subtitle-and-help: 3ad53a8b118aabd3
  voting-method: 761137852812fea8
  example-title-details-and-tags: 9dbbd0510d2d6cc1
  response-options: 727afbf0dcea6069
  duration-and-settings: a364411a3bebb3ae
  save-and-test-the-template: 8c48386c69ea309a
  manage-the-template-list: 0c124d7958c3f80a
generated:
  introduction: 90776350e8371577
  voting-methods-and-templates: 7034ca65c73320f6
  use-a-template: 95fbde37f42a7d5a
  who-can-manage-templates: d23915dc8f1143dd
  create-a-poll-template: b4a55a14ef0ca319
  template-title-subtitle-and-help: 3e09ec00082ba0ec
  voting-method: d531810f0756c5d7
  example-title-details-and-tags: 43c546aabbe67d80
  response-options: 969ece4fd4afe274
  duration-and-settings: 04dfa77a83d57426
  save-and-test-the-template: 71f228badf8b54a2
  manage-the-template-list: e6a63dd30ffafa9c
title_source: 114cca246e357304
title_generated: bf81c7a2bbcc8a9b
---

<!-- translation-section: introduction -->

# Szavazási sablonok

A szavazási sablonok újra felhasználható kiindulópontok, amelyek a **Szavazás indítása** vagy az **Új szavazás** kiválasztásakor jelennek meg. A sablon egy szavazási módot kapcsol össze előre megadott útmutatással, válaszlehetőségekkel és beállításokkal.

Ezen az oldalon beállíthatod, hogy mely sablonok legyenek elérhetők egy csoport számára, vagy létrehozhatsz egyet a saját folyamatodhoz. Egy adott szavazáshoz a [Javaslatok](../proposals/) vagy a [Szavazások](../proposal_types/) oldalon találsz segítséget a sablon kiválasztásához. Egy teljes döntési folyamat támogatásához lásd a [Döntéshozatal](/en/guides/making_decisions/) oldalt.

<!-- translation-section: voting-methods-and-templates -->

## Szavazási módok és sablonok

A szavazási mód határozza meg, hogyan válaszolnak a résztvevők, és hogyan számítja ki a Loomio az eredményt. Ilyen például a Javaslat, a Kiválasztás, a Pontozás, a Pontelosztás, a Rangsorolás, az Időpontszavazás és az STV.

A szavazási sablon ezek egyikét használja, és újra felhasználható alapbeállításokat ad hozzá. A Hangulatfelmérés, a Tanácskérés, a Beleegyezés és a Konszenzus például különböző sablonok, amelyek a Javaslat szavazási módra épülnek. Az útmutatásuk és a válaszlehetőségeik eltérnek, bár a Loomio ugyanúgy kezeli a bennük leadott szavazatokat.

<!-- translation-section: use-a-template -->

## Sablon használata

Szavazás indításakor válaszd ki a **Javaslat** vagy a **Szavazás** fület, majd válassz a csoport számára elérhető sablonok közül.

![](proposal_templates_list.png)

A sablon bevezetőt, mintatartalmat, lehetőségeket és beállításokat ad meg. A szavazás indítása előtt nézd át és igazítsd ezeket az adott döntéshez. Az új szavazás szerkesztése nem módosítja az újra felhasználható sablont.

<!-- translation-section: who-can-manage-templates -->

## Ki kezelheti a sablonokat

A csoport adminisztrátorai a csoportjuk összes szavazási sablonját létrehozhatják és kezelhetik. A **Csoport beállítások** → **Engedélyek** alatt bekapcsolhatják az **A tagok sablonokat hozhatnak létre** beállítást. Ha ez be van kapcsolva, a tagok sablonokat hozhatnak létre, és kezelhetik a saját maguk által létrehozott sablonokat.

<!-- translation-section: create-a-poll-template -->

## Szavazási sablon létrehozása

Nyisd meg a sablonlistát, és válaszd az **Új sablon** lehetőséget. Indulj ki egy példából vagy egy üres sablonból, majd válaszd ki a csoportot, amely használni fogja.

![](proposal_template_setting.png)

A sablon űrlapján határozhatod meg az útmutatást és az alapbeállításokat, amelyeket az emberek a szavazás indításakor kapnak.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### A sablon címe, alcíme és súgója

- **Sablon címe**: a sablonlistában megjelenő rövid név.
- **Sablon alcíme**: egy mondatban elmagyarázza, mikor érdemes használni.
- **Sablon súgó**: a sablon használatakor az információs panelen jelenik meg. Ismertesd a célját és azokat a szabályokat, amelyeket a résztvevőknek ismerniük kell, és adj meg hivatkozásokat a kapcsolódó szabályzatokra vagy útmutatókra.

![](template_WAAP_intro.png)

Használj egyszerű, pontos neveket, amelyek megkülönböztetik a sablont a csoport többi sablonjától.

<!-- translation-section: voting-method -->

### Szavazási mód

Válaszd ki, mit kell kifejezniük a résztvevőknek, és hogyan kell kiszámítani az eredményt.

![](poll_type_voting_method.png)

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

Adj meg olyan mintatartalmat, amely segít a szerzőnek megfogalmazni a szavazást. Ezek az értékek átkerülnek az új javaslatba vagy szavazásba, és az indítás előtt szerkeszthetők.

![](template_WAAP_details.png)

Használj segítő kérdéseket vagy útmutatást rögzített tartalom helyett, ha minden használatkor más címre vagy részletekre van szükség. Csak akkor adj meg alapértelmezett kategóriacímkéket, ha azok a sablon minden használatakor érvényesek.

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

![](poll_type_duration.png)

Más alapbeállítások az eredmények láthatóságát, a névtelen szavazást, a [súlyozott szavazást](../weighted_voting/), a szavazatok indoklásának követelményeit, az emlékeztetőket, a határozatképességet és az adott szavazási mód működését szabályozhatják. A hatásukról a [Javaslatok és szavazások beállításai](../settings/) oldalon olvashatsz.

<!-- translation-section: save-and-test-the-template -->

### A sablon mentése és kipróbálása

Mentés után hozz létre szavazástervezetet a sablonból. Ellenőrizd, hogy a bevezető, a segítő kérdések, a lehetőségek és az alapbeállítások annak is érthetők-e, aki nem vett részt a sablon létrehozásában. Egy tervezet létrehozásával azt is ellenőrizheted, hogy a kiválasztott szavazási mód a csoport által várt eredményt adja-e.

<!-- translation-section: manage-the-template-list -->

## A sablonlista kezelése

A sablon melletti műveleti menüben a következőket teheted:

- **Szerkesztés**: módosíthatod az újra felhasználható tartalmát és alapbeállításait;
- **Mozgat**: másik helyre teheted a listában;
- **Elrejt**: elrejtheted a szavazást indító emberek elől; vagy
- **Törlés**: törölheted azt az egyéni sablont, amelyre már nincs szükség.

![](template_manage.png)

Válaszd a **Rejtett sablonok megjelenítése** lehetőséget az elrejtett sablonok áttekintéséhez vagy visszaállításához. Az alapértelmezett sablonok elrejthetők vagy a csoporthoz igazíthatók, de nem törölhetők.

![](template_manage_settings.png)

A sablon módosítása nem változtatja meg a belőle már elindított javaslatokat vagy szavazásokat.
