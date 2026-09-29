---
title: Névtelen szavazás
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: d5c276b2785919c3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: cdaa1f5c3ca1e179
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 51460c8a6b663aba
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 3dd2c9e6d06debda
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 2ba76a1748304f96
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: af09f60a84d3a341
  how-anonymous-voting-protects-voters: efbb1b05a58feab1
  while-voting-is-open: 9c75f2cff798bc71
  votes-cannot-be-changed: da9f55d7ce132e1b
  why-anonymous-votes-do-not-have-reasons: 9d55496278209a06
  results-and-exports: 5bc23d98a91d03d4
  participation-verification: f98a09fe259a8bf8
  reminders: 6977d9f0579fe2f0
  what-coordinators-and-administrators-can-see: a75e0e50ad2c68ca
  limits-of-anonymous-voting: c08f3cdc54be2f73
  questions: da64f98c28ad9eee
  can-a-coordinator-see-how-i-voted: 2465a727190b594c
  can-i-see-my-vote-after-submitting-it: a0cef9bc880e956d
  can-i-change-or-withdraw-my-vote: 31c74b9264a93266
  will-i-receive-an-email-confirming-my-vote: e7b30694ab5eb316
  does-a-public-poll-reveal-more-information: e9dcee9e60a39379
  is-anonymous-voting-suitable-for-every-election: 6b09aab1145e8978
title_source: 1bc4567506ad4d51
title_generated: afeda824cbeb1a7d
---

<!-- translation-section: introduction -->

# Névtelen szavazás

A névtelen szavazás, más néven titkos szavazás, elkülöníti a részvételi adatokat a leadott szavazatoktól. A szavazás koordinátorai láthatják, kik szavazhattak, és ha már legalább hárman szavaztak, ellenőrizhetik a részvételt. Az alkalmazás felhasználói nem tudják összekapcsolni a leadott szavazatot azzal, aki leadta.

Ez az oldal bemutatja, hogyan védi a szavazókat a névtelen szavazás, milyen adatok maradnak meg, és hol vannak a védelem korlátai.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Hogyan védi a névtelen szavazás a szavazókat

A névtelen szavazás két külön adathalmazt tart fenn:

| Részvételi adatok | Leadott szavazatok |
| --- | --- |
| Ki szavazhat | A kiválasztott lehetőségek vagy pontszámok |
| Kit hívtak meg, és ki hívta meg | Melyik szavazáshoz tartozik a szavazat |
| Szavazott-e az adott személy | Nincs név vagy felhasználói fiók |
| Nincsenek kiválasztott lehetőségek vagy pontszámok | Nincs kapcsolat a részvételi adatokkal |

Nincs olyan közös azonosító, amely összekötné ezeket az adatokat. A leadott szavazatok nem tartalmazzák a leadás pontos idejét, a meghívási adatokat, az írásos indoklásokat, a mellékleteket és más olyan metaadatokat sem, amelyek segíthetnének azonosítani a szavazót.

Az elkülönítés már a szavazat tárolásakor megtörténik. A védelem nem pusztán azon múlik, hogy a felület elrejti a neveket.

<!-- translation-section: while-voting-is-open -->

## Amíg tart a szavazás

Az eredmények a szavazás lezárásáig mindenki elől rejtve maradnak. Ez a szavazás koordinátoraira, a csoportadminisztrátorokra és az alkalmazást használó példányadminisztrátorokra is vonatkozik.

Amikor valaki szavaz:

- a szavazatát a neve és a részvételi adatai nélkül tárolja a rendszer;
- a részvételi adatai jelzik, hogy szavazott;
- nem jön létre szavazási esemény, értesítés, e-mail, hozzászólás vagy aktivitási bejegyzés;
- a leadás után nem kap másolatot a választásairól; és
- a felület csak azt erősíti meg, hogy a szavazatát rögzítette a rendszer.

A részvételi adatok nem tárolják pontosan, mikor szavazott az adott személy. A leadott szavazatok nem a leadás ideje szerint vannak rendezve.

<!-- translation-section: votes-cannot-be-changed -->

## A szavazatok nem módosíthatók

Minden szavazásra jogosult személy egyszer szavazhat. A leadott névtelen szavazatot senki sem tekintheti meg, módosíthatja, vonhatja vissza vagy cserélheti le, a koordinátorok és az adminisztrátorok sem.

Ahhoz, hogy valaki később előhívhassa vagy lecserélhesse a szavazatát, tartós kapcsolatot kellene fenntartani közte és a szavazata között. A névtelen szavazás szándékosan nem hoz létre ilyen kapcsolatot.

Leadás előtt gondosan nézd át a választásaidat.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Miért nincs indoklás a névtelen szavazatokhoz

Az új névtelen szavazatokhoz nem lehet írásos indoklást vagy mellékletet csatolni. Az indoklás tartalmazhat neveket, személyes adatokat, felismerhető írásmódot, említéseket vagy más, a szavazót azonosító információt. Az egyes szavazatokat is könnyebben megkülönböztethetővé tenné az összesített eredménytől.

A résztvevők továbbra is megvitathatják a szavazást a hozzá tartozó témában, ha ott lehetőség van hozzászólni. Ezek a hozzászólások névvel megjelenő, szokásos beszélgetési bejegyzések, és nem kapcsolódnak a névtelen szavazathoz.

<!-- translation-section: results-and-exports -->

## Eredmények és exportálás

A szavazás lezárása után a rendszer az elkülönített szavazatokból számítja ki az eredményeket. Ezeket összesítve, valamint a szavazás típusának megfelelő más összesített eredményekkel együtt jeleníti meg.

Az alkalmazás nem teszi közzé a szavazatok azonosítóit, leadási sorrendjét vagy leadási idejét. A szavazások exportja összesített eredményeket tartalmaz, nem külön sort minden névtelen szavazathoz. Kivétel a lezárt STV-választás, amely BLT-formátumban exportálható. A BLT-export tartalmazza a választás újraszámlálásához szükséges jelöltsorrendeket. Az azonos sorrendű szavazólapokat csoportosítja, és nem tartalmazza a szavazók személyazonosságát vagy a szavazólapok metaadatait.

A lezárt névtelen szavazást nem lehet újranyitni.

<!-- translation-section: participation-verification -->

## A részvétel ellenőrzése

A szavazás koordinátorai megtekinthetik a névvel ellátott részvételi adatokat. Ezek mindig megmutatják, kik szavazhattak. Ha már legalább hárman szavaztak, azt is megmutatják, hogy az egyes személyek szavaztak-e, de azt soha, hogy hogyan szavaztak. Ha a szavazás háromnál kevesebb szavazattal zárul, a részvételi állapot rejtve marad.

A többi résztvevő nem láthatja ezeket a névvel ellátott részvételi adatokat. A szavazás eredményeihez való hozzáférés nem ad hozzáférést a részvételi adatokhoz.

A koordinátorok a szavazás ideje alatt további szavazásra jogosult személyeket adhatnak hozzá, akkor is, ha mások már szavaztak. A már szavazó személyeket nem lehet eltávolítani a névtelen szavazásból.

<!-- translation-section: reminders -->

## Emlékeztetők

A legalább 24 órán át tartó névtelen szavazásnál a még nem szavazó jogosultak egy automatikus emlékeztetőt kapnak az utolsó 24 órában.

Az emlékeztető címzettjeit a rendszer kizárólag a részvételi adatok alapján választja ki. Nem vizsgálja a leadott szavazatokat, és nem hoz létre kapcsolatot velük. Ha módosul a határidő, az óránkénti ellenőrzés az aktuális határidőt használja; a szavazáshoz nem tart fenn külön időzített emlékeztetőt.

A 24 óránál rövidebb szavazási időszakú szavazásokhoz nem küld automatikus emlékeztetőt a rendszer.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Mit láthatnak a koordinátorok és az adminisztrátorok

Az alkalmazásban a szavazás koordinátora, egy csoportadminisztrátor vagy egy példányadminisztrátor a jogosultságaitól függően láthatja:

- a szavazást és a szavazásra jogosult személyeket;
- hogy az egyes jogosultak szavaztak-e, ha a szerepkörük ezt lehetővé teszi, és már legalább hárman szavaztak; és
- a szavazás lezárása után az összesített eredményeket.

Az alkalmazás funkcióival nem láthatják:

- hogy mely választások tartoznak egy adott személyhez;
- az egyes szavazatokat vagy szavazási mintázatokat;
- hogy egy adott szavazatot mikor adtak le; vagy
- a leadott szavazathoz kapcsolódó indoklást, mellékletet, eseményt vagy értesítést.

<!-- translation-section: limits-of-anonymous-voting -->

## A névtelen szavazás korlátai

Ezek a védelmek megakadályozzák, hogy az alkalmazás felhasználói összekapcsolják a leadott szavazatot a szavazóval. Nem nyújtanak kriptográfiai védelmet olyan üzemeltetővel szemben, aki hozzáfér az adatbázishoz, a biztonsági mentésekhez, a szervernaplókhoz, a folyamatmemóriához, a hálózati forgalomhoz vagy az alkalmazás módosított változatához.

Maga az eredmény is árulkodhat. Kevés szavazó, egyhangú eredmény, a választások jellegzetes kombinációja vagy a szavazáson kívül megosztott információk alapján könnyebb lehet kikövetkeztetni valakinek a döntését. A szavazók a leadott szavazatuktól független beszélgetésben maguk is felfedhetik kilétüket.

Amikor eldöntöd, hogy megfelelő-e az alkalmazáson belüli névtelen szavazás, vedd figyelembe a szavazók számát és a döntés érzékenységét.

<!-- translation-section: questions -->

## Kérdések

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Láthatja a szavazás koordinátora, hogyan szavaztam?

Nem. Ha legalább hárman szavaztak, a koordinátor ellenőrizheti, hogy szavaztál-e, de az alkalmazásban nem kapcsolhatja össze a személyedet a leadott szavazatoddal. Három szavazat alatt az sem látható, hogy szavaztál-e.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Megnézhetem a szavazatomat a leadása után?

Nem. Az alkalmazás visszajelzi, hogy rögzítette a szavazatodat, majd eltávolítja a választásaidat a szavazási felületről. A szavazatodat csak akkor tudná visszakeresni, ha létrehozná azt a kapcsolatot, amelyet a névtelen szavazás kizár.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Megváltoztathatom vagy visszavonhatom a szavazatomat?

Nem. Nincs olyan kapcsolat a személyed és a szavazatod között, amely alapján az alkalmazás azonosíthatná, melyik leadott szavazatot kell módosítani vagy eltávolítani.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Kapok e-mailes visszaigazolást a szavazatomról?

Nem. Szavazáskor csak a képernyőn jelenik meg visszajelzés, és frissül a részvételi nyilvántartásod. Az alkalmazás nem küld visszaigazoló e-mailt, és nem hoz létre értesítést vagy tevékenységi eseményt.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Több információt fed fel egy nyilvános szavazás?

A nyilvános hozzáférés lehetővé teheti, hogy mások megtekintsék a szavazást és a lezárás után az összesített eredményeket. A névvel ellátott részvételi nyilvántartást és az egyes névtelen szavazatokat nem teszi hozzáférhetővé.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Minden választáshoz megfelelő a névtelen szavazás?

Nem. Az alkalmazáson belül elkülöníti a szavazók személyazonosságát a szavazatoktól. Ha a döntéshez a rendszer üzemeltetőivel szembeni védelemre vagy függetlenül ellenőrizhető kriptográfiai választásra van szükség, olyan rendszert kell használni, amely megfelel ezeknek a követelményeknek.
