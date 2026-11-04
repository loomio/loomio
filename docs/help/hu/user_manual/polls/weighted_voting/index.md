---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: 1cc0b5130642217b
  results: a0eeeda5a9e70a97
generated:
  introduction: 8da463db03c81410
  set-members-vote-weights: d514e814b623a6d1
  use-weighted-voting-in-a-poll: 02dee6bac10acb07
  results: 3c276f8c45fe77f1
title: Súlyozott szavazás
title_source: 0b971991dfcacbab
title_generated: 0d7fde4370c0d725
source_revision: ad60e7728a4b8d578ec70fa26577556ee051c09d
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
---

<!-- translation-section: introduction -->

# Súlyozott szavazás

A súlyozott szavazás lehetővé teszi, hogy egyes szavazatok többet számítsanak másoknál. Minden szavazónak van szavazati súlya. Például:

- Egy lakóközösség minden ingatlannak egy szavazatot ad. A három ingatlant képviselő tag szavazati súlya `3`.
- Egy dolgozói szövetkezet meghatározott idejű tagság után ad szavazati jogot. Az újabb tagok szavazati súlya `0`, így részt vehetnek a beszélgetésben és megismerhetik a szavazás folyamatát anélkül, hogy szavazataik befolyásolnák az eredményt.
- Egy vállalat a tulajdoni részesedésük alapján ad szavazatokat a részvényeseknek. A részvények 12,5%-át birtokló személy szavazati súlya `12.5`.

<!-- translation-section: set-members-vote-weights -->

## A tagok szavazati súlyának beállítása

A csoport adminja megnyithatja a csoport **Tagok** oldalát, és kiválaszthatja a **Szavazati súlyok szerkesztése** lehetőséget. Add meg a szavazati súlyokat, majd válaszd ki a **Szavazati súlyok mentése** lehetőséget. A szavazati súly legalább `0` lehet, legfeljebb három tizedesjeggyel. Név vagy e-mail-cím alapján kereshetsz meg valakit. Ha minden tagnak ugyanazt a szavazati súlyt szeretnéd megadni, válaszd ki **Az összes szavazati súly beállítása** lehetőséget.

![A csoport tagjainak szavazati súlyai](member-weights.png)

A tag szavazati súlya átmásolódik minden olyan szavazásba, amelyhez hozzáadják. Ha később megváltoztatod, az nem módosítja azokat a szavazásokat, amelyekbe már átmásolódott.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Súlyozott szavazás használata egy szavazásban

Nyisd meg a **További beállítások** részt a szavazás űrlapján, és válaszd ki a **Súlyozott szavazás használata** lehetőséget. A szavazás megnyitása után is be- vagy kikapcsolhatod a súlyozott szavazást. A kikapcsolás a szavazásban minden szavazati súlyt `1`-re állít, és az adott szavazásban módosított szavazati súlyok elvesznek.

Ha a csoportod egy bevett folyamatban súlyozott szavazást használ, válaszd ki a **Súlyozott szavazás használata** lehetőséget egy [szavazási sablonban](/en/user_manual/polls/poll_templates). Az ebből a sablonból indított szavazások súlyozott szavazást használnak.

![A Súlyozott szavazás használata beállítás egy szavazásban](poll-setting.png)

A súlyozott szavazás ezekkel a szavazástípusokkal használható: [Javaslat](/en/user_manual/polls/proposals), [Kiválasztás](/en/user_manual/polls/choose), [Pontozás](/en/user_manual/polls/score), [Pontelosztás](/en/user_manual/polls/allocate) és [Rangsorolás](/en/user_manual/polls/rank).

Ugyanabban a szavazásban nem használhatsz súlyozott szavazást és [névtelen szavazást](/en/user_manual/polls/anonymous_voting).

Egy szavazó szavazati súlyának módosításához válaszd ki a **Szavazók kezelése** lehetőséget, majd a neve melletti szavazati súlyt. Ha mindenkiét módosítani szeretnéd, válaszd ki **Az összes szavazati súly beállítása** lehetőséget. Átmásolhatod minden tag szavazati súlyát a csoportból, vagy mindenkinek ugyanazt az értéket adhatod meg. Azok a szavazók, akik nem tagjai a csoportnak, `1` szavazati súlyt kapnak.

![A Szavazók kezelése gomb egy szavazásban](poll-manage-voters.png)

![Egy szavazás szavazói egyéni szavazati súlyokkal](poll-voter-weights.png)

<!-- translation-section: results -->

## Eredmények

Az eredmények egymás mellett mutatják a súlyozás nélküli és a súlyozott összesítéseket:

- A Javaslat és a Kiválasztás típusú szavazások a **Szavazatok** és a **Súlyozott szavazatok** értékeit mutatják.
- A Pontozás, a Pontelosztás és a Rangsorolás típusú szavazások a **Pont** és a **Súlyozott pontok** értékeit mutatják.

A diagram a súlyozott eredményt mutatja. Válaszd ki egy oszlop fejlécét, ha inkább annak az oszlopnak az adatait szeretnéd megjeleníteni a diagramon. Aki láthatja a szavazatokat, az minden szavazó szavazati súlyát is láthatja.

A Javaslat és a Kiválasztás típusú szavazásoknál a **Nem szavazott** sor a **Szavazatok** oszlopban a még nem szavazók számát, a **Súlyozott szavazatok** oszlopban pedig a még le nem adott szavazati súlyt mutatja. Ezek az oszlopok és **a jogosultak szavazati súlyának %-a** oszlop a diagramon azokat is tartalmazzák, akik még nem szavaztak. **a leadott szavazati súly %-a** oszlop üresen hagyja a **Nem szavazott** sort, és kihagyja azt a diagramból.

A szavazati súlyok a [határozatképességre](/en/user_manual/polls/quorum) és a [szavazati arányra vonatkozó követelményekre](/en/user_manual/polls/vote_share_requirements) is érvényesek.

Az alábbi példában Jamie az **Egyetért** lehetőségre szavaz `2` szavazati súllyal. Hárman a **Nem ért egyet** lehetőségre szavaznak, `1`, `0` és `0` szavazati súllyal. Két ember, akiknek a szavazati súlya `2` és `1`, még nem szavazott.

Az Egyetértek lehetőség a négy leadott szavazatból egyet kapott, de a leadott szavazati súly kétharmadát teszi ki. A jogosultak szavazati súlyának felét adták le, így a 60 százalékos határozatképességi küszöböt nem érték el.

![Egy javaslat eredménye szavazatokkal és súlyozott szavazatokkal](weighted-proposal-result.png)
