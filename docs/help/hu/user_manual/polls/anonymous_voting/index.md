---
title: Névtelen szavazás
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: 2adb64c67ec4a37b
  how-anonymous-voting-protects-voters: 6148b5938f7b434e
  while-voting-is-open: 4ce6fb67585eafbd
  votes-cannot-be-changed: d46e5d276c32812b
  why-anonymous-votes-do-not-have-reasons: a4c41c47a40dacd6
  results-and-exports: 2ddae1eb2986cf79
  participation-verification: b330a3399a0ff953
  reminders: 6c429a1c23d63d39
  what-coordinators-and-administrators-can-see: 3518f56047bfcd8d
  limits-of-anonymous-voting: bb689a71f029522f
  questions: da64f98c28ad9eee
  can-a-coordinator-see-how-i-voted: c346c6d212702e6b
  can-i-see-my-vote-after-submitting-it: 92156275f68bd541
  can-i-change-or-withdraw-my-vote: 1fc597af0ae63186
  will-i-receive-an-email-confirming-my-vote: f88c509d3d45bafa
  does-a-public-poll-reveal-more-information: 4e3512d8c036f81c
  is-anonymous-voting-suitable-for-every-election: 231378ba745c0662
title_source: 1bc4567506ad4d51
title_generated: afeda824cbeb1a7d
---

<!-- translation-section: introduction -->

# Névtelen szavazás

A névtelen szavazás, más néven vak szavazás, elkülöníti a szavazókról vezetett nyilvántartást maguktól a szavazatoktól. A szavazás lezárása után mindenki, aki látja az eredményeket, azt is láthatja, hogy ki vett részt. A Loomio használatával senki sem kapcsolhatja össze a leadott szavazatot azzal, aki leadta.

Ez az oldal bemutatja a névtelen szavazás által nyújtott védelmet, a megőrzött információkat és a garancia korlátait.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Hogyan védi a névtelen szavazás a szavazókat

A névtelen szavazás két külön adathalmazt tárol:

| Részvételi nyilvántartás | Leadott szavazatok |
| --- | --- |
| Ki jogosult szavazni | A kiválasztott lehetőségek vagy pontszámok |
| Kit hívtak meg, és ki hívta meg | A szavazás, amelyhez a szavazat tartozik |
| Szavazott-e az egyes jogosult személy | Nincs név vagy felhasználói fiók |
| Nincsenek kiválasztott lehetőségek vagy pontszámok | Nincs kapcsolat a részvételi nyilvántartással |

Nincs közös azonosító, amely összekapcsolná ezeket az adatokat. A leadott szavazatokból a leadás tényleges időpontja, a meghívó adatai, az írásos indoklások, a mellékletek és a szavazó azonosítását segítő egyéb metaadatok is hiányoznak.

Az elkülönítés a szavazat tárolásakor történik. Nem csupán a nevek felületen való elrejtésén múlik.

<!-- translation-section: while-voting-is-open -->

## Amíg a szavazás nyitva van

Az eredmények a szavazás lezárásáig mindenki elől rejtve maradnak. Ez az alkalmazást használó szavazási koordinátorokra, csoportadminokra és a Loomio-példány adminjaira is vonatkozik.

Amikor valaki szavaz:

- a leadott szavazatát a neve és a részvételi nyilvántartásával való kapcsolat nélkül tárolja az alkalmazás;
- a részvételi nyilvántartásában jelzi, hogy szavazott;
- nem hoz létre szavazati eseményt, értesítést, e-mailt, hozzászólást vagy tevékenységbejegyzést;
- a leadás után nem küldi vissza a kiválasztott lehetőségek másolatát; és
- a felület csak azt erősíti meg, hogy a szavazatot rögzítette.

A részvételi nyilvántartás nem tárolja a szavazás pontos időpontját. A leadott szavazatok nincsenek a leadás időpontja szerint rendezve.

<!-- translation-section: votes-cannot-be-changed -->

## A szavazatok nem módosíthatók

Minden jogosult személy egyszer szavazhat. A leadott névtelen szavazat nem tekinthető meg újra, nem módosítható, nem vonható vissza és nem cserélhető le, még koordinátor vagy admin által sem.

Ahhoz, hogy valaki visszakereshesse vagy lecserélhesse a szavazatát, tartós kapcsolatra lenne szükség közte és a szavazat között. A névtelen szavazás szándékosan nem hoz létre ilyen kapcsolatot.

Leadás előtt gondosan ellenőrizd a kiválasztott lehetőségeket.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Miért nincs indoklás a névtelen szavazatokhoz

Az új névtelen szavazatok nem tartalmazhatnak írásos indoklást vagy mellékletet. Az indoklások neveket, személyes adatokat, jellegzetes írásmódot, említéseket vagy más, a szavazót azonosító információt tartalmazhatnak. Az egyes szavazatokat is könnyebb lenne megkülönböztetni az összesített eredménytől.

A résztvevők továbbra is beszélgethetnek a szavazásról annak szálában, ahol elérhető a beszélgetés. Ezek a hozzászólások névvel ellátott, szokásos hozzászólások a beszélgetésben, és nem kapcsolódnak névtelen szavazathoz.

<!-- translation-section: results-and-exports -->

## Eredmények és exportálás

A szavazás lezárása után az alkalmazás az elkülönített szavazatokból számítja ki az eredményeket, és összesített számokként, valamint a szavazástípus által támogatott egyéb összesített eredményekként jeleníti meg őket.

Az alkalmazás nem teszi közzé a szavazatok azonosítóit, leadási sorrendjét vagy leadási időpontját. A szavazások exportjai összesített eredményeket tartalmaznak, nem pedig minden névtelen szavazathoz külön sort. Kivétel a lezárt STV-választás, amely BLT formátumban exportálható. A BLT-export a szavazatok újraszámlálásához szükséges jelöltrangsorokat tartalmazza, az azonos rangsorú szavazólapokat csoportosítva, a szavazók személyazonossága és a szavazólapok metaadatai nélkül.

A névtelen szavazás a lezárása után nem nyitható újra.

<!-- translation-section: participation-verification -->

## Ki vett részt

A névtelen szavazás lezárása után mindenki, aki látja az eredményeket, azt is láthatja, hogy ki vett részt. Amíg a szavazás nyitva van, ezt senki sem láthatja.

A lista megtekintéséhez válaszd ki a **Szavazatok megtekintése** lehetőséget. A lista mindig megmutatja, hogy ki volt jogosult szavazni. Azt csak akkor mutatja meg, hogy az egyes személyek szavaztak-e, ha elegen szavaztak. Ehhez el kell érni a szavazás határozatképességi küszöbét, ha van ilyen; egyébként a jogosult szavazók legalább felének kell szavaznia, de minden esetben legalább három szavazat szükséges. A lista soha nem mutatja meg, hogy ki hogyan vagy mikor szavazott.

A csoport tagjai és a szavazás szavazói azt is látják, hogy az egyes személyek mikor csatlakoztak a csoporthoz, és ki hívta meg őket. A csoport adminjai az e-mail-címeket is látják, hogy meg tudják különböztetni az azonos nevű embereket.

Mivel mindenki, aki látja az eredményeket, azt is láthatja, hogy ki szavazott, az egyoldalú eredmény felfedheti, hogy az emberek hogyan szavaztak. Ha például minden szavazat az Egyetértek lehetőségre érkezett, akkor minden szavazó egyetértett.

A koordinátorok újabb szavazásra jogosult személyeket adhatnak hozzá, amíg a szavazás nyitva van, akkor is, ha mások már szavaztak. A meglévő szavazók nem távolíthatók el a névtelen szavazásból.

<!-- translation-section: reminders -->

## Emlékeztetők

A legalább 24 órán át tartó névtelen szavazás utolsó 24 órájában egy automatikus emlékeztetőt kapnak azok a jogosult személyek, akik még nem szavaztak.

Az emlékeztető címzettjeinek kiválasztása kizárólag a részvételi nyilvántartás alapján történik. Az alkalmazás ehhez nem vizsgálja meg a leadott szavazatokat, és nem hoz létre kapcsolatot velük. Ha a határidő megváltozik, az óránkénti emlékeztető-ellenőrzés az aktuális határidőt használja, és nem tart fenn külön ütemezett emlékeztetőt a szavazáshoz.

Az összesen 24 óránál rövidebb ideig tartó szavazásoknál az alkalmazás nem küld ilyen automatikus emlékeztetőt.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Mit láthatnak a koordinátorok és az adminok

Az alkalmazáson keresztül a szavazás koordinátora, a csoport adminja vagy a Loomio-példány adminja a következőket láthatja:

- a szavazást és a szavazásra jogosult személyeket;
- azt, hogy az egyes jogosult személyek szavaztak-e, ha a szerepkörük hozzáférést biztosít ehhez, és elegen szavaztak; és
- az összesített eredményeket a szavazás lezárása után.

Az alkalmazás funkcióival nem láthatják:

- hogy melyik személyhez mely kiválasztott lehetőségek tartoznak;
- az egyes szavazatokat vagy szavazási mintázatokat;
- egy adott szavazat leadásának időpontját; vagy
- a leadott szavazathoz kapcsolódó indoklást, mellékletet, eseményt vagy értesítést.

<!-- translation-section: limits-of-anonymous-voting -->

## A névtelen szavazás korlátai

Ezek a védelmi intézkedések megakadályozzák, hogy az alkalmazás felhasználói összekapcsolják a leadott szavazatot a szavazójával. Nem nyújtanak kriptográfiai védelmet olyan üzemeltetővel szemben, aki hozzáfér az adatbázishoz, a biztonsági mentésekhez, a szervernaplókhoz, a folyamatok memóriájához, a hálózati forgalomhoz vagy az alkalmazás módosított változatához.

Maga az eredmény is felfedhet információkat. A szavazók kis száma, az egyhangú eredmény, a kiválasztott lehetőségek jellegzetes kombinációja vagy a szavazáson kívül megosztott információk megkönnyíthetik annak kikövetkeztetését, hogy valaki mit választott. A szavazók a leadott szavazatuktól független beszélgetésben is dönthetnek úgy, hogy felfedik a kilétüket.

Vedd figyelembe a szavazók számát és a döntés érzékenységét, amikor eldöntöd, hogy megfelelő-e az alkalmazásszintű névtelen szavazás.

<!-- translation-section: questions -->

## Kérdések

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Láthatja bárki, hogyan szavaztam?

Nem. Ha már elegen szavaztak, azok, akik látják az eredményeket, azt is láthatják, hogy szavaztál-e. Az alkalmazáson keresztül senki sem kapcsolhat össze téged egy leadott szavazattal. Addig az is rejtve marad, hogy szavaztál-e.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Megnézhetem a szavazatomat, miután leadtam?

Nem. Az alkalmazás megerősíti, hogy rögzítette a szavazatodat, majd törli a választásaidat a szavazási felületről. Nem tudja visszakeresni a szavazatodat anélkül, hogy létrehozná azt a kapcsolatot, amelyet a névtelen szavazás szándékosan elkerül.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Módosíthatom vagy visszavonhatom a szavazatomat?

Nem. Nincs olyan kapcsolat, amely alapján az alkalmazás azonosítani tudná, melyik leadott szavazatot kell módosítania vagy eltávolítania.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Kapok emailt a szavazatom megerősítéséről?

Nem. A szavazat leadásakor csak a képernyőn jelenik meg visszaigazolás, és frissül a részvételi nyilvántartásod. Az alkalmazás nem küld megerősítő emailt, és nem hoz létre értesítést vagy tevékenységi eseményt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Több információt tesz láthatóvá egy nyilvános szavazás?

Egy nyilvános szavazás lezárása után bárki láthatja az eredményeket és azt, hogy kik vettek részt. Az egyéni szavazatokat, valamint a tagság és a meghívók részleteit nem láthatják.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Minden választáshoz megfelelő a névtelen szavazás?

Nem. Az alkalmazáson belül elkülöníti a személyazonosságokat a szavazatoktól. A rendszer üzemeltetőivel szembeni védelmet igénylő döntésekhez vagy a függetlenül ellenőrizhető kriptográfiai választásokhoz olyan rendszerre van szükség, amelyet ezekre a követelményekre terveztek.
