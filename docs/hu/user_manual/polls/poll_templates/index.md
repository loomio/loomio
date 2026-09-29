---
title: Szavazási sablonok
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  duration-and-settings: dc1fb9123eb808df
  save-and-test-the-template: 8c48386c69ea309a
  manage-the-template-list: 0c124d7958c3f80a
generated:
  introduction: ca49914c7ea16a02
  voting-methods-and-templates: b26a19cea30777a7
  use-a-template: 67b687ea39ff106f
  who-can-manage-templates: 293a55a5adf3ad30
  create-a-poll-template: a12fb236e296c014
  template-title-subtitle-and-help: bd8d463f8ad83d30
  voting-method: 13cc370e5e4ac5d0
  example-title-details-and-tags: '094db61a99e25980'
  response-options: e39237b0f500595d
  duration-and-settings: 4b887e1ddf481dca
  save-and-test-the-template: 2eca983dac40ae1e
  manage-the-template-list: 2cc44fe48d43d5d8
title_source: 114cca246e357304
title_generated: bf81c7a2bbcc8a9b
---

<!-- translation-section: introduction -->

# Szavazási sablonok

A szavazási sablonok újra felhasználható kiindulópontok, amelyek a **Szavazás indítása** vagy az **Új szavazás** kiválasztásakor jelennek meg. Egy sablon szavazási módszert, előre megadott útmutatást, válaszlehetőségeket és beállításokat tartalmaz.

Ezen az oldalon beállíthatod, mely sablonok érhetők el egy csoportban, vagy létrehozhatsz egyet a saját döntési folyamatotokhoz. Ha egy adott szavazáshoz szeretnél sablont választani, olvasd el a [Javaslatok](../proposals/) vagy a [Szavazások](../proposal_types/) oldalát. A teljes döntési folyamat támogatásához olvasd el a [Döntéshozatal](/en/guides/making_decisions/) útmutatót.

<!-- translation-section: voting-methods-and-templates -->

## Szavazási módszerek és sablonok

A szavazási módszer határozza meg, hogyan válaszolnak a résztvevők, és hogyan számítja ki a Loomio az eredményt. Ilyen módszer a Javaslat, a Választ, a Pontszám, a Kiosztás, a Rangsorolás, az Időpont választás és az STV.

A szavazási sablon ezek egyikét használja, és újra felhasználható alapbeállításokat ad hozzá. Például a helyzetfelmérés, a tanácskérés, a hozzájárulás és a konszenzus különböző, a Javaslat módszerre épülő sablonok. Az útmutatásuk és a válaszlehetőségeik eltérnek, bár a Loomio ugyanúgy kezeli a leadott szavazatokat.

<!-- translation-section: use-a-template -->

## Sablon használata

Szavazás indításakor válaszd a **Javaslat** vagy a **Szavazás** fület, majd válassz egyet a csoport számára elérhető sablonok közül.

![](proposal_templates_list.png)

A sablon bevezetőt, példatartalmat, lehetőségeket és beállításokat ad meg. A szavazás indítása előtt nézd át és igazítsd ezeket az adott döntéshez. Az új szavazás szerkesztése nem módosítja az újra felhasználható sablont.

<!-- translation-section: who-can-manage-templates -->

## Ki kezelheti a sablonokat?

A csoportadminisztrátorok a csoport összes szavazási sablonját létrehozhatják és kezelhetik. A **Csoport beállítások** → **Engedélyek** alatt bekapcsolhatják az **A tagok sablonokat hozhatnak létre** beállítást. Ha ez be van kapcsolva, a tagok sablonokat hozhatnak létre, és kezelhetik az általuk készített sablonokat.

<!-- translation-section: create-a-poll-template -->

## Szavazási sablon létrehozása

Nyisd meg a sablonok listáját, és válaszd az **Új sablon** lehetőséget. Indulj ki egy példából vagy egy üres sablonból, majd válaszd ki a csoportot, amely használni fogja.

![](proposal_template_setting.png)

A sablon űrlapján adhatod meg azt az útmutatást és azokat az alapbeállításokat, amelyeket az emberek szavazás indításakor látnak.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### A sablon címe, alcíme és súgója

- A **Sablon címe** a sablonok listájában megjelenő rövid név.
- A **Sablon alcíme** egy mondatban elmagyarázza, mikor érdemes használni.
- A **Sablon súgó** az információs panelen jelenik meg, amikor valaki használja a sablont. Írd le a sablon célját, a résztvevők számára fontos szabályokat, és adj meg hivatkozásokat a kapcsolódó szabályzatokra vagy útmutatókra.

![](template_WAAP_intro.png)

Használj egyszerű, egyértelmű neveket, amelyek megkülönböztetik a sablont a csoport többi sablonjától.

<!-- translation-section: voting-method -->

### Szavazási módszer

Válassz aszerint, hogy mit kell kifejezniük a résztvevőknek, és hogyan kell kiszámítani az eredményt.

![](poll_type_voting_method.png)

- **Javaslat**: válasz egy állításra előre meghatározott álláspontokkal;
- **Választ**: egy vagy több lehetőség kiválasztása;
- **Pontszám**: minden lehetőség értékelése egy skálán;
- **Kiosztás**: korlátozott számú pont elosztása;
- **Rangsorolás**: a lehetőségek sorrendbe állítása a preferenciák szerint;
- **Időpont választás**: a ráérés jelzése; és
- **STV**: jelöltek rangsorolása arányos, több győztest eredményező választáson.

A szavazási módszer megváltoztatásával a sablonban elérhető mezők és az eredmény kiszámítása is változik.

<!-- translation-section: example-title-details-and-tags -->

### Példacím, részletek és címkék

Adj meg példatartalmat, amely segít a szavazás megfogalmazásában. Ezek az értékek bekerülnek az új javaslatba vagy szavazásba, és az indítás előtt szerkeszthetők.

![](template_WAAP_details.png)

Ha a sablon minden használatakor más címre vagy részletekre van szükség, rögzített szöveg helyett adj meg kitöltési útmutatást. Alapértelmezett kategóriacímkéket csak akkor adj hozzá, ha a sablon minden használatakor érvényesek.

<!-- translation-section: response-options -->

### Válaszlehetőségek

Egyes módszereknél, például a Javaslat és a Választ esetében beállíthatod a válaszlehetőségeket. A szerkesztéshez kattints a lehetőség melletti ceruzaikonra:

- **Opció neve**: a válasz rövid neve;
- **Ikon**: a lehetőség képi jelölése;
- **Jelentése**: mit fejez ki a lehetőség kiválasztása; és
- **Indoklás kérése**: a kérdés, amely akkor jelenik meg, amikor valaki megindokolja a válaszát.

![](poll_type_edit_option.png)

Úgy határozd meg a lehetőségeket, hogy a résztvevők találgatás nélkül megértsék a különbséget köztük. A jelentésük feleljen meg a csoport tényleges döntési szabályainak.

<!-- translation-section: duration-and-settings -->

### Időtartam és beállítások

Állíts be olyan alapértelmezett időtartamot, amely a sablon legtöbb használatához megfelelő. Az indító az egyes szavazások zárási idejét módosíthatja.

![](poll_type_duration.png)

Más alapbeállítások szabályozhatják az eredmény láthatóságát, a névtelen szavazást, az indoklás kötelező megadását, az emlékeztetőket, a részvételi küszöböt és a választott módszer sajátos működését. A hatásukat a [Javaslatok és szavazások beállításai](../settings/) oldalon találod.

<!-- translation-section: save-and-test-the-template -->

### A sablon mentése és kipróbálása

Mentés után indíts egy szavazástervezetet a sablonból. Ellenőrizd, hogy a bevezető, a kitöltési útmutatás, a lehetőségek és az alapbeállítások annak is érthetők-e, aki nem készítette a sablont. A tervezetben azt is ellenőrizheted, hogy a választott szavazási módszer a csoport által várt eredményt adja-e.

<!-- translation-section: manage-the-template-list -->

## A sablonok listájának kezelése

A sablon melletti műveleti menüben a következőket teheted:

- **Szerkesztés**: módosíthatod az újra felhasználható tartalmat és az alapbeállításokat;
- **Mozgat**: áthelyezheted a sablont a lista másik helyére;
- **Elrejt**: elrejtheted a sablont a szavazást indítók elől; vagy
- **Törlés**: törölhetsz egy egyéni sablont, amelyre már nincs szükség.

![](template_manage.png)

A rejtett sablonok áttekintéséhez vagy visszaállításához válaszd a **Rejtett sablonok megjelenítése** lehetőséget. Az alapértelmezett sablonok elrejthetők vagy a csoport igényeihez igazíthatók, de nem törölhetők.

![](template_manage_settings.png)

A sablon módosítása nem változtatja meg a belőle már elindított javaslatokat vagy szavazásokat.
