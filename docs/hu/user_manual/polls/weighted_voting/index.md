---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 96145d7bff253030
  set-members-vote-weights: d514e814b623a6d1
  use-weighted-voting-in-a-poll: 73899f9058a36db7
  results: 736b60bbaa774ba6
title: Súlyozott szavazás
title_source: 0b971991dfcacbab
title_generated: 0d7fde4370c0d725
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Súlyozott szavazás

A súlyozott szavazás lehetővé teszi, hogy egyes szavazatok többet számítsanak másoknál. Minden szavazónak van szavazati súlya. Például:

- Egy lakóközösség minden ingatlannak egy szavazatot ad. A három ingatlant képviselő tag szavazati súlya `3`.
- Egy szövetkezet igazgatósága hozza meg a döntést, de a működtetésért felelős munkatársak is részt vesznek a beszélgetésben. Az igazgatóság tagjainak szavazati súlya `1`. A működtetésért felelős munkatársak szavazati súlya `0`, így a szavazataikat rögzítik, de azok nem változtatják meg az eredményt.
- Egy vállalat a tulajdoni részesedésük alapján ad szavazatokat a részvényeseknek. A részvények 12,5%-át birtokló személy szavazati súlya `12.5`.

<!-- translation-section: set-members-vote-weights -->

## A tagok szavazati súlyának beállítása

A csoport adminja megnyithatja a csoport **Tagok** oldalát, és kiválaszthatja a **Szavazati súlyok szerkesztése** lehetőséget. Add meg a szavazati súlyokat, majd válaszd ki a **Szavazati súlyok mentése** lehetőséget. A szavazati súly legalább `0` lehet, legfeljebb három tizedesjeggyel. Név vagy e-mail-cím alapján kereshetsz meg valakit. Ha minden tagnak ugyanazt a szavazati súlyt szeretnéd megadni, válaszd ki **Az összes szavazati súly beállítása** lehetőséget.

![A csoport tagjainak szavazati súlyai](member-weights.png)

A tag szavazati súlya átmásolódik minden olyan szavazásba, amelyhez hozzáadják. Ha később megváltoztatod, az nem módosítja azokat a szavazásokat, amelyekbe már átmásolódott.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Súlyozott szavazás használata egy szavazásban

Válaszd ki a **Súlyozott szavazás használata** lehetőséget a szavazás speciális beállításaiban. A szavazás megnyitása után is be- vagy kikapcsolhatod. A kikapcsolás a szavazásban minden szavazati súlyt `1`-re állít, és az adott szavazásban módosított szavazati súlyok elvesznek.

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

A diagram a súlyozott eredményt mutatja. Válaszd ki egy oszlop fejlécét, ha inkább annak az oszlopnak az adatait szeretnéd megjeleníteni a diagramon. A szavazásra jogosultak számánál és a határozatképességnél a személyek számítanak, nem a szavazati súlyok. Aki láthatja a szavazatokat, az minden szavazó szavazati súlyát is láthatja.

![Egy javaslat eredménye szavazatokkal és súlyozott szavazatokkal](weighted-proposal-result.png)
