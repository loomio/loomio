---
title: Névtelen szavazás
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: 525d47463a6f267b
  how-anonymous-voting-protects-voters: 2c4d295d3753babb
  while-voting-is-open: 8ff6ba56e8c7f60e
  votes-cannot-be-changed: 57bb9827fe8f0e38
  why-anonymous-votes-do-not-have-reasons: 7ddc57348428c53e
  results-and-exports: c7a8e8613826506f
  participation-verification: 9dc7817184df6441
  reminders: 234357493d6bf65d
  what-coordinators-and-administrators-can-see: 2cc05897d00305ab
  limits-of-anonymous-voting: 4e48659f4729c86c
  questions: da64f98c28ad9eee
  can-a-coordinator-see-how-i-voted: 259abba0bba12b82
  can-i-see-my-vote-after-submitting-it: 42f92f0098159367
  can-i-change-or-withdraw-my-vote: ba1e032b8292c0c8
  will-i-receive-an-email-confirming-my-vote: 1867daf9065f890a
  does-a-public-poll-reveal-more-information: 4e3512d8c036f81c
  is-anonymous-voting-suitable-for-every-election: 1a79d1a244bd0aa7
title_source: 1bc4567506ad4d51
title_generated: afeda824cbeb1a7d
---

<!-- translation-section: introduction -->

# Névtelen szavazás

A névtelen szavazás, más néven vak szavazás, elkülöníti a szavazók részvételi nyilvántartását maguktól a szavazatoktól. A szavazás lezárása után mindenki, aki látja az eredményeket, azt is láthatja, hogy ki vett részt, de a Loomio használatával senki sem kapcsolhatja össze a szavazatot azzal, aki leadta.

Ez az oldal bemutatja, hogyan működik a névtelen szavazás, milyen információkat őriz meg, és mik ennek a védelemnek a korlátai.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Hogyan védi a névtelen szavazás a szavazókat

A névtelen szavazás két külön adathalmazt tárol:

| Részvételi nyilvántartás | Leadott szavazatok |
| --- | --- |
| Ki jogosult szavazni | A kiválasztott lehetőségek vagy pontszámok |
| Kit hívtak meg, és ki hívta meg | A szavazás, amelyhez a szavazat tartozik |
| Az egyes jogosult személyek szavaztak-e | Nincs név vagy felhasználói fiók |
| Nincsenek kiválasztott lehetőségek vagy pontszámok | Nincs kapcsolat a részvételi nyilvántartással |

Nincs közös azonosító, amely összekapcsolná ezeket az adatokat. A leadott szavazatokból a leadás időpontja, a meghívó adatai, a szavazatok indoklásai, a mellékletek és a szavazó azonosítását lehetővé tevő egyéb metaadatok is hiányoznak.

Az elkülönítés a szavazat mentésekor történik, nem csupán a nevek felületen való elrejtésén múlik.

<!-- translation-section: while-voting-is-open -->

## Amíg a szavazás nyitva van

Az eredmények a szavazás lezárásáig mindenki elől rejtve maradnak, beleértve a szálak adminjait, a csoportok adminjait és a Loomio-példány adminjait is.

Amikor valaki szavaz:

- a szavazatát a neve és a részvételi nyilvántartásával való kapcsolat nélkül tárolja az alkalmazás;
- a részvételi nyilvántartásában jelzi, hogy szavazott;
- nem hoz létre szavazati eseményt, értesítést, e-mailt, hozzászólást vagy tevékenységbejegyzést;
- a leadás után nem küldi vissza a kiválasztott lehetőségek másolatát; és
- a felület csak azt erősíti meg, hogy a szavazatot rögzítette.

A részvételi nyilvántartás nem tárolja, hogy az adott személy pontosan mikor szavazott, és a leadott szavazatok nincsenek a leadás időpontja szerint rendezve.

<!-- translation-section: votes-cannot-be-changed -->

## A szavazatok nem módosíthatók

Minden jogosult személy egyszer szavazhat. A leadott névtelen szavazat nem tekinthető meg újra, nem módosítható, nem vonható vissza és nem cserélhető le, még admin által sem.

Ahhoz, hogy valaki visszakereshesse vagy lecserélhesse a szavazatát, kapcsolatra lenne szükség közte és a szavazata között. A névtelen szavazás szándékosan nem hoz létre ilyen kapcsolatot.

Leadás előtt gondosan ellenőrizd a kiválasztott lehetőségeket.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Miért nincs indoklás a névtelen szavazatokhoz

A névtelen szavazatok nem tartalmazhatnak indoklást vagy mellékletet. Az indoklások neveket, személyes adatokat, jellegzetes írásmódot vagy a szavazót azonosító említéseket tartalmazhatnak, és megkönnyíthetik az egyes szavazatok felismerését az eredmények között.

A résztvevők továbbra is beszélgethetnek a szavazásról annak szálában. Ezek szokásos, névvel ellátott hozzászólások, és nem kapcsolódnak névtelen szavazathoz.

<!-- translation-section: results-and-exports -->

## Eredmények és exportálás

A szavazás lezárása után a Loomio az elkülönített szavazatokból számítja ki az eredményeket, és megjeleníti az adott szavazástípusnak megfelelő összesítést.

A Loomio nem teszi közzé a szavazatok azonosítóit, leadási sorrendjét vagy leadási időpontját. A szavazások exportjai csak összesített eredményeket tartalmaznak, nem pedig minden szavazathoz külön sort. Az egyetlen kivétel a lezárt STV-választás, amely újraszámláláshoz BLT formátumban exportálható. A BLT-export a jelöltek rangsorait sorolja fel, az egyező szavazólapokat csoportosítva, a szavazók személyazonossága és a szavazólapok metaadatai nélkül.

A névtelen szavazás a lezárása után nem nyitható újra.

<!-- translation-section: participation-verification -->

## Ki vett részt

A névtelen szavazás lezárása után mindenki, aki látja az eredményeket, azt is láthatja, hogy ki vett részt. Amíg a szavazás nyitva van, ezt senki sem láthatja.

A lista megtekintéséhez válaszd ki a **Szavazatok megtekintése** lehetőséget. A lista mindig megmutatja, hogy ki volt jogosult szavazni, de soha nem mutatja meg, hogy ki hogyan vagy mikor szavazott. Azt csak akkor mutatja meg, hogy az egyes személyek szavaztak-e, ha elegen vettek részt: el kell érni a szavazás határozatképességi küszöbét, ha van ilyen; egyébként a jogosult szavazók legalább felének kell szavaznia, de minden esetben legalább három szavazat szükséges.

A csoport tagjai és a szavazás szavazói azt is látják, hogy az egyes személyek mikor csatlakoztak a csoporthoz, és ki hívta meg őket. A csoport adminjai az e-mail-címeket is látják, hogy meg tudják különböztetni az azonos nevű embereket.

Mivel mindenki, aki látja az eredményeket, azt is láthatja, hogy ki szavazott, az egyoldalú eredmény felfedheti, hogy az emberek hogyan szavaztak. Ha például minden szavazat az Egyetértek lehetőségre érkezett, akkor minden szavazó egyetértett.

Az adminok újabb szavazásra jogosult személyeket adhatnak hozzá, amíg a szavazás nyitva van, akkor is, ha mások már szavaztak. A meglévő szavazók nem távolíthatók el a névtelen szavazásból.

<!-- translation-section: reminders -->

## Emlékeztetők

A legalább 24 órán át tartó névtelen szavazás utolsó 24 órájában egy automatikus emlékeztetőt kapnak azok a jogosult személyek, akik még nem szavaztak.

A Loomio kizárólag a részvételi nyilvántartás alapján választja ki a címzetteket, a leadott szavazatok vizsgálata nélkül.

A 24 óránál rövidebb szavazási időszakú szavazásoknál az alkalmazás nem küld ilyen automatikus emlékeztetőt.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Mit láthatnak az adminok

Az alkalmazáson keresztül a szál adminja, a csoport adminja vagy a Loomio-példány adminja a következőket láthatja:

- a szavazást és a szavazásra jogosult személyeket;
- azt, hogy az egyes jogosult személyek szavaztak-e (ha a szerepkörük hozzáférést biztosít ehhez, és elegen szavaztak); és
- az összesített eredményeket a szavazás lezárása után.

Az alkalmazáson keresztül nem láthatják:

- hogy melyik személyhez mely kiválasztott lehetőségek tartoznak;
- az egyes szavazatokat vagy szavazási mintázatokat;
- egy adott szavazat leadásának időpontját; vagy
- a szavazathoz kapcsolódó indoklást, mellékletet, eseményt vagy értesítést.

<!-- translation-section: limits-of-anonymous-voting -->

## A névtelen szavazás korlátai

A névtelen szavazás megakadályozza, hogy a Loomio felhasználói összekapcsolják a szavazatot a szavazóval. Nem nyújt kriptográfiai védelmet olyan szerverüzemeltetővel szemben, aki megvizsgálhatja az adatbázist, a biztonsági mentéseket, a szervernaplókat, a folyamatok memóriáját, a hálózati forgalmat vagy a módosított kódot.

Maguk az eredmények is adhatnak támpontokat. Egy kis csoport, az egyhangú eredmény, a kiválasztott lehetőségek egyedi kombinációja vagy a szavazáson kívül megosztott hozzászólások megkönnyíthetik annak kikövetkeztetését, hogy valaki hogyan szavazott.

Vedd figyelembe a csoport méretét és a döntés érzékenységét, mielőtt az alkalmazásszintű névtelen szavazásra támaszkodsz.

<!-- translation-section: questions -->

## Kérdések

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Láthatja bárki, hogyan szavaztam?

Nem. A Loomio használatával senki sem kapcsolhat össze téged a szavazatoddal. Ha már elegen szavaztak, mindenki, aki látja az eredményeket, azt is láthatja, hogy részt vettél-e. Amíg ezt a küszöböt nem érik el, még az is rejtve marad, hogy szavaztál-e.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Megnézhetem a szavazatomat, miután leadtam?

Nem. A Loomio megerősíti, hogy rögzítette a szavazatodat, és törli a kiválasztott lehetőségeket a képernyőről. Nem tudja visszakeresni a szavazatodat anélkül, hogy létrehozná azt a kapcsolatot, amelyet a névtelen szavazás elkerül.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Módosíthatom vagy visszavonhatom a szavazatomat?

Nem. Mivel nincs kapcsolat közted és a szavazatod között, a Loomio nem tudja azonosítani, melyik szavazatot kell módosítania vagy eltávolítania.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Kapok emailt a szavazatom megerősítéséről?

Nem. A szavazat leadásakor csak a képernyőn jelenik meg visszaigazolás, és frissül a részvételi nyilvántartásod. Az alkalmazás nem küld emailt, és nem hoz létre értesítést vagy tevékenységi bejegyzést.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Több információt tesz láthatóvá egy nyilvános szavazás?

Egy nyilvános szavazás lezárása után bárki láthatja az eredményeket és azt, hogy kik vettek részt. Az egyéni szavazatokat, valamint a tagság és a meghívók részleteit nem láthatják.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Minden választáshoz megfelelő a névtelen szavazás?

Nem. Az alkalmazáson belül elkülöníti a szavazókat a szavazatoktól. A szerver üzemeltetőivel szembeni védelmet vagy független kriptográfiai ellenőrzést igénylő választásokhoz olyan rendszerre van szükség, amelyet ezekre a követelményekre terveztek.
