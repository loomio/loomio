---
title: STV-választások
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: 31e83bb5bc08829c
  quota-type: 12d5c4b5fe2abb1d
  how-voting-works: b9a7df3cedbe4d50
  how-counting-works: 50ba0a7800bc5667
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: a6c3dbb5548c7d41
  round-by-round-details: e4a8789dae29d49e
  exporting-ballots: 582555dd13633bf0
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: 1355ba8d32640fe8
  when-to-use-stv: c23e90a4472ab173
  creating-an-stv-election: 4c625b2a18ae3835
  number-of-seats: 43dff8b74452b4ee
  counting-method: 4110e05d2b519a3f
  quota-type: 9ef2ce5be4de0867
  how-voting-works: 1b303e68af05f439
  how-counting-works: 2b260429779831db
  understanding-results: fc73c168a3b2d361
  method-and-quota: ce683eedf4358a07
  elected-candidates: 3fa58134c3a6fd12
  round-by-round-details: 55e244c003978707
  exporting-ballots: 56e40b2269a91400
  share-an-outcome: 61926fca089c8389
title_source: cd3e1a4cdc2456a6
title_generated: 67607ab7fbcfa361
---

<!-- translation-section: introduction -->

# STV-választások

Az **átruházható szavazat (STV)** arányos képviseletet biztosító szavazási módszer, amellyel több jelöltet lehet megválasztani. A megválasztott jelöltek így a szavazók eltérő nézeteit is arányosan képviselhetik.

<!-- translation-section: when-to-use-stv -->

## Mikor használj STV-t?

Akkor használj STV-választást, ha:

- Több jelölt közül szeretnél **bizottságot, vezető testületet vagy küldötteket** választani
- **Arányos képviseletet** szeretnél biztosítani, hogy a kisebbségben lévő csoportok is a támogatottságuknak megfelelő számú helyet szerezhessenek
- Olyan választást tartasz, ahol a szavazók rangsorolják a jelölteket

>[!NOTE]
>Az STV **nem** azonos a Loomio [rangsoroló szavazásával](/en/user_manual/polls/rank/), amely pontszámok alapján segít kiválasztani egyetlen legjobb lehetőséget. Az STV több jelölt megválasztására szolgál, a szavazatok átruházásával és kieséses fordulókkal.

<!-- translation-section: creating-an-stv-election -->

## STV-választás létrehozása

Szavazás indításakor válaszd a **STV választás** típust, majd add hozzá a jelölteket szavazási lehetőségként. Beállíthatod a **helyek számát**, a **számlálási módszert** és a **kvóta típusát**.

Ebben a példában az Oatmilk Cooperative három embert választ a visszaváltható csomagolás kipróbálásának felügyeletére. Az űrlap ismerteti a feladatot, felsorol öt jelöltet, és skót STV-t használ Droop-kvótával.

![](form.png)

<!-- translation-section: number-of-seats -->

### Helyek száma

Ennyi jelöltet választanak meg. A helyek számának kisebbnek kell lennie a jelöltek számánál.

<!-- translation-section: counting-method -->

### Számlálási módszer

A szavazatok kétféle módszerrel számolhatók meg:

Skót STV : Ajánlott. A súlyozott inkluzív Gregory-módszer (WIGM), amelyet 2007 óta használnak a skót helyhatósági választásokon. Szabályai egyértelműek és könnyen követhetők. A legtöbb szervezet számára megfelelő.

Meek STV : Matematikailag pontosabb, ismételt számításon alapuló módszer. Ha egy jelölt kiesik, a szavazatokat úgy számolják újra, mintha a jelölt soha nem indult volna.

<!-- translation-section: quota-type -->

### Kvóta típusa

A kvóta az a legkevesebb szavazat, amelyre egy jelöltnek szüksége van egy hely megszerzéséhez. Két típusa választható:

Droop : Ajánlott. A legtöbb STV-választáson ezt a kvótát használják, többek között Írországban, Ausztráliában és Skóciában. A Droop-kvóta biztosítja, hogy a szavazók többsége a helyek többségét szerezze meg. Így számítható ki: \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Magasabb küszöb, amely arányosabb képviseletet ad a kisebb csoportoknak.
    A DSA helyi szervezetei a kisebbségi képviselet védelme érdekében ezt részesítik előnyben.
   Így számítható ki:
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > A Droop-kvóta mindig kevesebb szavazatot jelent, mint a Hare-kvóta. Ha például 100 szavazat érkezik négy helyre, a Droop-kvóta 21, a Hare-kvóta pedig 25.

<!-- translation-section: how-voting-works -->

## Hogyan működik a szavazás?

Ebben a példában az Oatmilk Cooperative három embert választ az újrahasználható csomagolás kipróbálásának felügyeletére. A szavazók a vonal fölé húzzák a jelölteket, majd a kívánt sorrendbe rendezik őket:

![](stv-vote-in-progress.png)

- **1. hely** = a leginkább támogatott jelölt
- **2. hely** = a második választás
- Annyi jelöltet rangsorolj, amennyit szeretnél

Nem kell minden jelöltet rangsorolni. A rangsorba nem tett jelöltek nem részesülnek az adott szavazó támogatásából.

<!-- translation-section: how-counting-works -->

## Hogyan működik a számlálás?
A számlálás menete:

1. Kiszámítják a **kvótát** (a mandátum megszerzéséhez szükséges legkevesebb szavazatot).
2. Minden jelöltnél összeszámolják az **Elsődleges beállítások** szerinti szavazatokat.
3. Ha egy jelölt eléri a kvótát, **megválasztják**. A kvótán felüli szavazatait tört értékkel **átruházzák** a szavazók következőként rangsorolt jelöltjeire.
4. Ha senki sem éri el a kvótát, a **legkevesebb szavazatot kapott jelölt kiesik**. Szavazatait teljes értékkel átruházzák a szavazók következőként rangsorolt jelöltjeire.
5. A folyamat addig ismétlődik, amíg minden mandátumot be nem töltenek.

>[!TIP]
>Ha egy szavazó egyetlen versenyben maradt jelöltet sem rangsorolt, a szavazólapja „kimerül”, és a szavazata már nem számít bele az eredménybe. Ezért általában érdemes több jelöltet rangsorolni.

<!-- translation-section: understanding-results -->

## Az eredmények értelmezése

A szavazás lezárása után az eredmények több szakaszban jelennek meg. Ezen a választáson Samira Patel, Alex Morgan és Morgan Price szerzi meg a bizottság három helyét:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Módszer és kvóta

Felül láthatod a számlálási módszert (skót STV vagy Meek STV), a kvóta típusát (Droop vagy Hare), valamint a kvótát: ennyi szavazatra volt szüksége egy jelöltnek egy hely megszerzéséhez.

<!-- translation-section: elected-candidates -->

### Megválasztott jelöltek

A megválasztott jelölteket öt oszlopból álló összefoglaló táblázat mutatja:

| Oszlop | Jelentés |
|--------|---------|
| **Jelölt** | A megválasztott jelölt neve |
| **Megválasztott forduló** | Az a számlálási forduló, amelyben a jelölt elérte a kvótát és helyet szerzett. Az 1. forduló azt jelenti, hogy ehhez elegendők voltak az első helyre sorolások; a későbbi fordulókban kiesett vagy többletszavazattal rendelkező jelöltektől átruházott szavazatokra is szükség volt. |
| **Elsődleges beállítások** | Hány szavazó sorolta a jelöltet az első helyre. Ez a jelölt közvetlen támogatottságát mutatja a szavazatok átruházása előtt. |
| **Végső összesítés** | A jelölt szavazatainak száma a megválasztása pillanatában. Az átruházott szavazatok miatt ez gyakran magasabb, mint az első helyre sorolások száma. |
| **Többlet** | Ennyivel haladta meg a jelölt végső szavazatszáma a kvótát (végső összesítés mínusz kvóta). A nagyobb többlet azt jelzi, hogy a jelölt a megválasztásához szükségesnél több támogatást kapott. A skót STV-ben ezt a többletet továbbosztják a szavazók következő választásai között. |

Ha a számlálás döntetlent eredményez, és bármelyik versenyben maradt jelölt kiejtése megváltoztatná a végeredményt, ezeket a jelölteket külön táblázat mutatja. Ilyenkor nem választanak önkényesen győztest.

<!-- translation-section: round-by-round-details -->

### Körről körre részletek

Nyisd meg a **Körről körre részletek** szakaszt a szavazatok átruházásának és a jelöltek kiesésének megtekintéséhez. Minden sor egy jelöltet, minden oszlop egy számlálási fordulót jelöl:

![](stv-results.png)

A zöld kiemelés a jelölt megválasztását, a piros a kiesését, a narancssárga pedig a döntetlent jelzi.

<!-- translation-section: share-an-outcome -->

## Következtetés megosztása

Amikor a választás lezárul, ossz meg egy következtetést. Nevezd meg a megválasztottakat, és írd le, mikor kezdődik a megbízatásuk. A következtetések működéséről a [Következtetés megosztása](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) című részben olvashatsz.

![A megválasztott bizottsági tagokat megnevező következtetés](outcome.png)

<!-- translation-section: exporting-ballots -->

## Szavazólapok exportálása

A választás lezárása után az eredmények megtekintésére jogosultak BLT-formátumban exportálhatják a szavazólapokat független újraszámláláshoz vagy ellenőrzéshez. Az export tartalmazza a jelöltek rangsorolását, az azonos rangsorokat pedig egyetlen sorba vonja össze a hozzájuk tartozó szavazólapok számával. Névtelen választás esetén nem tartalmazza a szavazók személyazonosságát, a szavazólapok azonosítóit, a beküldés időpontját vagy sorrendjét.
