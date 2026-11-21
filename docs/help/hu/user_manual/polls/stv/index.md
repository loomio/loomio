---
title: STV-választások
source_revision: cd27428bae8ec9057b7ab52ce2c41ac44f5b5b9e
source_file: docs/help/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 17b273381bad13de
  when-to-use-stv: d71b1619a6348f95
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 2a5074b9749c32ea
  counting-method: b7ff2dce779d15c1
  quota-type: cc4e99132e1ac8ab
  how-voting-works: a7c4734c1c1fc12c
  how-counting-works: 794084f981b2cf3f
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: 7ac0bae756fa5608
  round-by-round-details: c0ccc83e51dcaa1a
  exporting-ballots: 582555dd13633bf0
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: f506f60e0a9beacb
  when-to-use-stv: de2a208d7e50fc4c
  creating-an-stv-election: 2e4396fffe52151f
  number-of-seats: 1806d30629f8ba7a
  counting-method: 90fe8e383deadd8d
  quota-type: 302f1e8e2655f571
  how-voting-works: 46cb3485caa1eedc
  how-counting-works: 4bbc4737e6f9a8fa
  understanding-results: 9b42c12afd404f68
  method-and-quota: 8d225149d164a03e
  elected-candidates: 567d0cf0f90e79ad
  round-by-round-details: 577de8c35e762e8e
  exporting-ballots: aeed7970ab0bc490
  share-an-outcome: 710f776206e6db13
title_source: cd3e1a4cdc2456a6
title_generated: 67607ab7fbcfa361
---

<!-- translation-section: introduction -->

# STV-választások

Az **egyetlen átruházható szavazat (STV)** olyan rangsoroláson alapuló szavazási mód, amellyel egy vagy több jelöltet lehet megválasztani a jelöltek közül. Több jelölt megválasztásakor arányos képviseletet biztosít, így a megválasztott jelöltek tükrözik a szavazók eltérő nézeteit. Egyetlen jelölt megválasztásakor azonnali kieséses szavazásként működik.

<!-- translation-section: when-to-use-stv -->

## Mikor használj STV-t?

Használj STV-választást, ha:

- **Bizottságot, testületet vagy küldötteket** szeretnél választani a jelöltek közül
- **Arányos képviseletet** szeretnél biztosítani, amelyben a kisebbségi irányzatok a támogatottságukkal arányos számú helyet szerezhetnek
- **Egyetlen jelöltet** szeretnél megválasztani azonnali kieséses szavazással, amelyben a legkevesebb szavazatot kapó lehetőségre adott szavazatok a szavazók következőként rangsorolt lehetőségeire szállnak át, amíg az egyik lehetőség meg nem szerzi a többséget

>[!NOTE]
>Az STV **nem** azonos a Loomio [Rangsorolás szavazásával](/en/user_manual/polls/rank). A Rangsorolás az összes lehetőség pontszámait összeadva állítja elő az összesített preferenciasorrendet. Az STV kiesési köröket és szavazatátruházást használ, és egy vagy több jelölt megválasztására is alkalmas.

<!-- translation-section: creating-an-stv-election -->

## STV-választás létrehozása

Szavazás indításakor válaszd ki az **STV választás** típust, majd add hozzá a jelölteket a szavazás lehetőségeiként. A szavazást a **helyek számának**, a **számlálási módszernek** és a **kvóta típusának** beállításával szabhatod testre.

Ebben a példában az Oatmilk Cooperative három embert választ a visszaváltható csomagolás próbaüzemének felügyeletére. Az űrlap ismerteti a feladatkört, felsorol öt jelöltet, és skót STV-t használ Droop-kvótával.

![](form.png)

<!-- translation-section: number-of-seats -->

### Helyek száma

Hány jelöltet szeretnél megválasztani. Ennek a számnak legalább 1-nek és a jelöltek számánál kisebbnek kell lennie. Egyetlen jelölt megválasztására szolgáló azonnali kieséses választáshoz állítsd 1-re.

<!-- translation-section: counting-method -->

### Számlálási módszer

A szavazatok megszámlálására két módszer áll rendelkezésre:

Skót STV
  : Ajánlott. A súlyozott inkluzív Gregory-módszer (Weighted Inclusive Gregory Method, WIGM), amelyet 2007 óta használnak a skót önkormányzati választásokon. Pontosan meghatározott, egyszerű szabályokat alkalmaz. A legtöbb szervezet számára ez a legmegfelelőbb.
  
Meek STV
  : Pontosabb módszer, amelynek számlálását csak számítógép tudja elvégezni. Amikor egy jelöltet megválasztanak, a Meek-módszer minden szavazatból folyamatosan továbbadja azt a részt, amelyre a jelöltnek nincs szüksége, a szavazó rangsorában később szereplő jelölteknek. Ez azokra a szavazatokra is vonatkozik, amelyek a számlálás későbbi szakaszában jutnak el hozzá. Ha egy jelölt kiesik, a szavazatokat úgy számolják újra, mintha az adott jelölt nem is indult volna. Kevesebb szavazat vész el, mint a skót STV esetében, de a számlálás kézzel nem ellenőrizhető.

<!-- translation-section: quota-type -->

### Kvóta típusa

A kvóta az a legkisebb szavazatszám, amelyre egy jelöltnek szüksége van egy hely megszerzéséhez. Kétféle lehet:

Droop
  : Ajánlott. Az STV-választások szokásos kvótája, amelyet Írországban, Ausztráliában és Skóciában használnak. Ez a legkisebb kvóta, amelyet legfeljebb annyi jelölt érhet el, ahány hely van. Ha a szavazók egy csoportja a saját jelöltjeit rangsorolja az első helyekre, legalább annyi helyet szerez, ahány kvótányi szavazata van. Kiszámítása:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Nagyobb kvóta. A sok szavazattal rendelkező csoportok több szavazatot használnak fel minden megszerzett helyre, így a kisebb csoportok nagyobb eséllyel szerzik meg az utolsó helyeket. Kiszámítása:
    \\[ \frac{votes}{seats}\\]

Mindkét képletben a *votes* azoknak a szavazólapoknak a száma, amelyeken legalább egy jelölt szerepel a rangsorban.

A Meek STV kerekítés nélkül számítja ki a kvótát; a Droop-kvóta esetében a képlet votes ÷ (seats + 1). Minden körben újraszámítja a kvótát a jelölteknél még meglévő szavazatok alapján, és a megválasztáshoz a jelöltnek meg kell haladnia ezt az értéket.
  
  >[!TIP]
  > A Droop-kvóta mindig kisebb szavazatszámot ad, mint a Hare-kvóta. 100 szavazat és négy hely esetén a Droop-kvóta 21, a Hare-kvóta pedig 25. 100 szavazat és egy hely esetén a Droop-kvóta 51 (többség, több mint 50%), a Hare-kvóta pedig 100, ezért egyetlen jelölt megválasztásához a Droop-kvóta a megfelelő.

<!-- translation-section: how-voting-works -->

## Hogyan működik a szavazás?

Ebben a példában az Oatmilk Cooperative három embert választ az újrahasználható csomagolás próbaüzemének felügyeletére. A szavazók a vonal fölé húzzák a jelölteket, és a preferenciáik szerint rangsorolják őket:

![](stv-vote-in-progress.png)

- **1. hely** = a leginkább támogatott jelölt
- **2. hely** = a másodiknak választott jelölt
- Folytasd a rangsorolást annyi jelölttel, amennyivel szeretnéd

A szavazóknak legalább egy jelöltet rangsorolniuk kell, de nem szükséges minden jelöltet rangsorolniuk. A rangsorolható jelöltek számát nem korlátozza a helyek száma: a szavazók egyetlen jelölt megválasztásakor is megadhatnak további jelölteket, akár az összes jelöltet rangsorolva. A rangsorból kihagyott jelöltek nem kapnak támogatást az adott szavazótól.

Az STV-szavazásokban nincs beépített Tartózkodom lehetőség. A tartózkodni kívánó tagok egyszerűen kihagyhatják a szavazat leadását. Ne adj hozzá „Tartózkodom” nevű jelöltet, kivéve, ha a tartózkodásokat rögzíteni kell a szavazólapon, mert a Loomio ugyanúgy számolja, mint bármely más jelöltet: az ezt rangsoroló szavazólapok beleszámítanak a kvótába, és ha elég szavazó rangsorolja az első helyre, más lehetőségeknél tovább maradhat versenyben, vagy le is győzheti őket.

<!-- translation-section: how-counting-works -->

## Hogyan működik a számlálás?
A számlálás menete:

1. Kiszámítják a **kvótát**, vagyis a hely megszerzéséhez szükséges legkisebb szavazatszámot.
2. Megszámolják az **Elsődleges beállítások** szerinti szavazatokat minden jelöltnél.
3. Minden jelölt, aki eléri a kvótát, **megválasztott** lesz. A kvóta feletti többletszavazatait tört értékkel **átruházzák** a szavazók rangsorában következő jelöltekre, a legnagyobb többlettel kezdve. Szavazatokat csak olyan jelöltekre ruháznak át, akik még részt vesznek a számlálásban.
4. Ha nincs több átruházható többlet, a **legkevesebb szavazattal rendelkező jelölt kiesik**. Szavazatait teljes értékkel átruházzák a szavazók rangsorában következő jelöltekre.
5. Amikor a megmaradt jelöltek száma megegyezik a betöltetlen helyek számával, mindegyiküket megválasztják, akkor is, ha nem érték el a kvótát.
6. Egyébként a számlálás a 3. lépéstől ismétlődik, amíg minden helyet betöltenek.

A tört érték csak azt a szavazatrészt osztja szét, amelyre a megválasztott jelöltnek nincs szüksége. Például ha a kvóta 26, és egy jelöltnek 40 szavazata van, a többlete 14. Mind a 40 szavazólapja a rangsorban következő jelölthöz kerül, egyenként 14 ÷ 40 = 0,35 szavazat értékkel.

A skót STV esetében minden átruházott szavazat értékét öt tizedesjegyre lefelé kerekítik, ahogy a skót önkormányzati választásokon is.

Ha két vagy több jelöltnek van a legkevesebb szavazata, az esik ki, akinek a legutóbbi olyan korábbi körben kevesebb szavazata volt, amelyben az állásuk eltért.

>[!TIP]
>Egy szavazólap csak addig számít, amíg a rangsorában szerepel olyan jelölt, aki még részt vesz a számlálásban. Ha már nincs ilyen jelölt, a szavazólap „kimerül”, és többé nem számít.

<!-- translation-section: understanding-results -->

## Az eredmények értelmezése

A szavazás lezárása után az eredmények több részben jelennek meg. Ezen a választáson Samira Patel, Alex Morgan és Morgan Price tölti be a három bizottsági helyet:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Módszer és kvóta

Felül láthatod a számlálási módszert (skót STV vagy Meek STV), a kvóta típusát (Droop vagy Hare), valamint magát a kvótát: azt a szavazatszámot, amelyre egy jelöltnek szüksége volt egy hely megszerzéséhez.

<!-- translation-section: elected-candidates -->

### Megválasztott jelöltek

A megválasztott jelölteket összefoglaló táblázat öt oszlopból áll:

| Oszlop | Jelentés |
|--------|---------|
| **Jelölt** | A megválasztott jelölt neve |
| **Megválasztott forduló** | Melyik számlálási körben érte el a kvótát és szerzett helyet. Az 1. kör azt jelenti, hogy kizárólag az első helyre rangsoroló szavazatokkal nyert; a későbbi körök azt jelentik, hogy kiesett jelöltektől vagy más jelöltek többletéből átruházott szavazatokra is szüksége volt. |
| **Elsődleges beállítások** | Hány szavazó rangsorolta ezt a jelöltet az első helyre. Ez a jelölt közvetlen támogatottságát mutatja a szavazatátruházások előtt. |
| **Végső összesítés** | A jelölt szavazatainak összesített értéke a megválasztásakor. A szavazatátruházások miatt ez gyakran magasabb az első helyre rangsoroló szavazatok számánál. |
| **Többlet** | Mennyivel haladta meg a jelölt végső összesítése a kvótát (végső összesítés mínusz kvóta). A nagyobb többlet a győzelemhez szükségesnél erősebb támogatottságot jelent. A skót STV esetében ezt a többletet elosztják a szavazók rangsorában következő jelöltek között. |

Előfordul, hogy a korábbi körök alapján sem lehet feloldani a holtversenyt. Ha a holtverseny nem befolyásolja, hogy kit választanak meg, a számlálás folytatódik. Ha befolyásolja, a számlálás az adott körben megáll. Azok a jelöltek, akik a holtverseny feloldásától függetlenül nyernek, megválasztottként jelennek meg. Azok a jelöltek, akik a holtverseny feloldásától függően nyerhetnek vagy veszíthetnek, külön táblázatban jelennek meg. A Loomio holtversenyben állóként mutatja őket, ahelyett, hogy véletlenszerűen választana közülük.

<!-- translation-section: round-by-round-details -->

### Részletek körről körre

Nyisd le a **Körről körre részletek** részt a szavazatátruházások és a kiesések megtekintéséhez. Minden sor egy jelöltet, minden oszlop egy számlálási kört jelöl. A számok azt mutatják, hogy az adott kör elején hány szavazata volt a jelöltnek:

![](stv-results.png)

A zöld kiemelés a jelölt megválasztását, a piros a kiesését, a narancssárga pedig a holtversenyét jelzi.

<!-- translation-section: share-an-outcome -->

## Következtetés megosztása

Amikor a választás lezárul, ossz meg egy következtetést. Nevezd meg a megválasztott személyeket, és írd le, mikor kezdődik a megbízatásuk. A következtetések működéséről a [Következtetés megosztása](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) oldalon olvashatsz.

![A megválasztott bizottsági tagokat megnevező következtetés](outcome.png)

<!-- translation-section: exporting-ballots -->

## Szavazólapok exportálása

A választás lezárása után azok, akik megtekinthetik az eredményeket, BLT formátumban exportálhatják a szavazólapokat független újraszámlálás vagy ellenőrzés céljából. Az export tartalmazza a jelöltek rangsorolását, és az azonos rangsorolásokat egyetlen sorba vonja össze, feltüntetve a szavazólapok számát. Névtelen választások esetén nem tartalmazza a szavazók személyazonosságát, a szavazólapok azonosítóit, a beküldés időpontját vagy sorrendjét.
