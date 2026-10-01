---
title: STV-választások
source_revision: cf8da02f691349beecf6ac6444971fad130d4ddd
source_file: docs/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: b7ff2dce779d15c1
  quota-type: f9ab31d93916bf24
  how-voting-works: bace7c735dbb39f1
  how-counting-works: 794084f981b2cf3f
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: 7ac0bae756fa5608
  round-by-round-details: c0ccc83e51dcaa1a
  exporting-ballots: 582555dd13633bf0
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: 1355ba8d32640fe8
  when-to-use-stv: c23e90a4472ab173
  creating-an-stv-election: 4c625b2a18ae3835
  number-of-seats: 43dff8b74452b4ee
  counting-method: 6883b32453468c8e
  quota-type: 5ffd7b1979c262f7
  how-voting-works: 3643bc60b4df1803
  how-counting-works: 77a4e764c4569ca7
  understanding-results: fc73c168a3b2d361
  method-and-quota: ce683eedf4358a07
  elected-candidates: 26b645df0e03e9d7
  round-by-round-details: c44bee17944273c2
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

Scottish STV
  : Ajánlott. A súlyozott inkluzív Gregory-módszer (WIGM), amelyet 2007 óta használnak a skót helyhatósági választásokon. Szabályai egyértelműek és könnyen követhetők. A legtöbb szervezet számára megfelelő.
  
Meek STV
  : Pontosabb módszer, amellyel csak számítógép tudja megszámolni a szavazatokat. Ha egy jelöltet megválasztanak, a Meek-módszer minden szavazatból folyamatosan továbbadja a megválasztásához nem szükséges részt a szavazó később rangsorolt jelöltjeinek. Ez azokra a szavazatokra is vonatkozik, amelyek a számlálás későbbi szakaszában kerülnek hozzá. Ha egy jelölt kiesik, a szavazatokat úgy számolják újra, mintha a jelölt soha nem indult volna. Kevesebb szavazat vész el, mint a Scottish STV esetén, de a számlálás kézzel nem ellenőrizhető.

<!-- translation-section: quota-type -->

### Kvóta típusa

A kvóta az a legkevesebb szavazat, amelyre egy jelöltnek szüksége van egy hely megszerzéséhez. Két típusa választható:

Droop
  : Ajánlott. Az STV-választások szokásos kvótája, amelyet Írországban, Ausztráliában és Skóciában használnak. Ez a legkisebb kvóta, amelyet legfeljebb annyi jelölt érhet el, ahány betöltendő hely van. Az a szavazói csoport, amely a saját jelöltjeit rangsorolja az első helyekre, legalább annyi helyet szerez, ahány kvótányi szavazattal rendelkezik. Így számítható ki:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Nagyobb kvóta. A sok szavazattal rendelkező csoportok minden megszerzett helyre több szavazatot használnak fel, ezért a kisebb csoportok nagyobb eséllyel szerzik meg az utolsó helyeket. Így számítható ki:
    \\[ \frac{votes}{seats}\\]

Mindkét képletben a *votes* azoknak a szavazólapoknak a száma, amelyeken legalább egy jelöltet rangsoroltak.

A Meek STV kerekítés nélkül számítja ki a kvótát; a Droop esetén ez votes ÷ (seats + 1). Minden fordulóban újraszámítja a kvótát a jelölteknél még meglévő szavazatokból, és a megválasztáshoz a jelöltnek meg kell haladnia ezt az értéket.
  
  >[!TIP]
  > A Droop-kvóta mindig kevesebb szavazatot jelent, mint a Hare-kvóta. Ha például 100 szavazat érkezik négy helyre, a Droop-kvóta 21, a Hare-kvóta pedig 25.

<!-- translation-section: how-voting-works -->

## Hogyan működik a szavazás?

Ebben a példában az Oatmilk Cooperative három embert választ az újrahasználható csomagolás kipróbálásának felügyeletére. A szavazók a vonal fölé húzzák a jelölteket, majd a kívánt sorrendbe rendezik őket:

![](stv-vote-in-progress.png)

- **1. hely** = a leginkább támogatott jelölt
- **2. hely** = a második választás
- Annyi jelöltet rangsorolj, amennyit szeretnél

Legalább egy jelöltet rangsorolni kell, de nem kell minden jelöltet rangsorolni. A rangsorba nem tett jelöltek nem részesülnek az adott szavazó támogatásából.

<!-- translation-section: how-counting-works -->

## Hogyan működik a számlálás?
A számlálás menete:

1. Kiszámítják a **kvótát** (a mandátum megszerzéséhez szükséges legkevesebb szavazatot).
2. Minden jelöltnél összeszámolják az **Elsődleges beállítások** szerinti szavazatokat.
3. Minden jelöltet **megválasztanak**, aki eléri a kvótát. A kvótán felüli többletszavazataikat tört értékkel **átruházzák** a szavazók következőként rangsorolt jelöltjeire, a legnagyobb többlettel kezdve. Szavazatokat csak a számlálásban még részt vevő jelöltek kaphatnak.
4. Ha nem maradt átruházható többlet, a **legkevesebb szavazatot kapott jelölt kiesik**. Szavazatait teljes értékkel átruházzák a szavazók következőként rangsorolt jelöltjeire.
5. Ha a megmaradt jelöltek száma megegyezik a még betöltendő mandátumok számával, mindegyiküket megválasztják, akkor is, ha nem érték el a kvótát.
6. Egyébként a számlálás a 3. lépéstől ismétlődik, amíg minden mandátumot be nem töltenek.

A tört értékkel csak a megválasztott jelöltnek már nem szükséges szavazatokat osztják tovább. Ha például a kvóta 26, és egy jelöltnek 40 szavazata van, a többlete 14. Mind a 40 szavazólap a rajta következőként rangsorolt jelölthöz kerül, egyenként 14 ÷ 40 = 0,35 szavazat értékben.

A Scottish STV esetén minden átruházott szavazat értékét öt tizedesjegyre lefelé kerekítik, ahogyan a skót önkormányzati választásokon is.

Ha két vagy több jelöltnek van a legkevesebb szavazata, az esik ki, akinek a legutóbbi korábbi fordulóban kevesebb szavazata volt.

>[!TIP]
>Egy szavazólap csak addig számít, amíg szerepel a rangsorában olyan jelölt, aki még részt vesz a számlálásban. Ha egy ilyen jelölt sem marad, a szavazólap „kimerül”, és már nem számít bele az eredménybe.

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
| **Többlet** | Ennyivel haladta meg a jelölt végső szavazatszáma a kvótát (végső összesítés mínusz kvóta). A nagyobb többlet azt jelzi, hogy a jelölt a megválasztásához szükségesnél több támogatást kapott. A Scottish STV esetén ezt a többletet továbbosztják a szavazók következő választásai között. |

Néha a korábbi fordulók alapján sem lehet feloldani a döntetlent. Ha a döntetlen nem befolyásolja, hogy kit választanak meg, a számlálás folytatódik. Ha befolyásolja, a számlálás az adott fordulóban megáll. Azok a jelöltek, akik a döntetlen feloldásától függetlenül nyernek, megválasztottként jelennek meg. Azok a jelöltek, akik a döntetlen feloldásától függően nyerhetnek vagy veszíthetnek, külön táblázatban jelennek meg. A Loomio döntetlenként mutatja az eredményüket, ahelyett hogy véletlenszerűen kiválasztaná valamelyiküket.

<!-- translation-section: round-by-round-details -->

### Körről körre részletek

Nyisd meg a **Körről körre részletek** szakaszt a szavazatok átruházásának és a jelöltek kiesésének megtekintéséhez. Minden sor egy jelöltet, minden oszlop egy számlálási fordulót jelöl. Minden szám azt mutatja, hogy az adott forduló elején hány szavazata volt a jelöltnek:

![](stv-results.png)

A zöld kiemelés a jelölt megválasztását, a piros a kiesését, a narancssárga pedig a döntetlent jelzi.

<!-- translation-section: share-an-outcome -->

## Következtetés megosztása

Amikor a választás lezárul, ossz meg egy következtetést. Nevezd meg a megválasztottakat, és írd le, mikor kezdődik a megbízatásuk. A következtetések működéséről a [Következtetés megosztása](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) című részben olvashatsz.

![A megválasztott bizottsági tagokat megnevező következtetés](outcome.png)

<!-- translation-section: exporting-ballots -->

## Szavazólapok exportálása

A választás lezárása után az eredmények megtekintésére jogosultak BLT-formátumban exportálhatják a szavazólapokat független újraszámláláshoz vagy ellenőrzéshez. Az export tartalmazza a jelöltek rangsorolását, az azonos rangsorokat pedig egyetlen sorba vonja össze a hozzájuk tartozó szavazólapok számával. Névtelen választás esetén nem tartalmazza a szavazók személyazonosságát, a szavazólapok azonosítóit, a beküldés időpontját vagy sorrendjét.
