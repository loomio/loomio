---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 8c7cc3b03271dce0
  set-members-vote-weights: bd5ef0bb7bdda7f4
  use-weighted-voting-in-a-poll: 5f873f381f0f2b0a
  results: af3df90b2c9a1a02
title: Súlyozott szavazás
title_source: 0b971991dfcacbab
title_generated: 0d7fde4370c0d725
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Súlyozott szavazás

A súlyozott szavazás lehetővé teszi, hogy egyes szavazatok többet számítsanak másoknál. Minden szavazónak van egy szavazati súlya. Például:

- Egy lakóközösség minden ingatlannak egy szavazatot ad. A három ingatlant képviselő tag szavazati súlya `3`.
- Egy szövetkezet igazgatósága hozza meg a döntést, de a működtetésben dolgozó munkatársak is részt vesznek a beszélgetésben. Az igazgatósági tagok szavazati súlya `1`. A működtetésben dolgozó munkatársak szavazati súlya `0`, így a szavazataikat rögzítik, de azok nem változtatják meg az eredményt.
- Egy vállalat a tulajdoni hányaduk alapján ad szavazatokat a részvényeseknek. Annak, aki a részvények 12,5%-át birtokolja, a szavazati súlya `12.5`.

<!-- translation-section: set-members-vote-weights -->

## A tagok szavazati súlyának beállítása

A csoport adminisztrátoraként nyisd meg a csoport **Tagok** oldalát, és válaszd ki a **Szavazati súlyok szerkesztése** lehetőséget. Add meg a szavazati súlyokat, majd válaszd ki a **Szavazati súlyok mentése** lehetőséget. A szavazati súlyok értéke `0` vagy annál nagyobb lehet, legfeljebb három tizedesjeggyel. Név vagy e-mail-cím alapján kereshetsz valakit. Ha minden tagnak ugyanazt a szavazati súlyt szeretnéd megadni, válaszd ki **Az összes szavazati súly beállítása** lehetőséget.

![A csoporttagok szavazati súlyai](member-weights.png)

A tag szavazati súlya minden olyan szavazásba átmásolódik, amelyhez hozzáadják. A későbbi módosítás nem változtatja meg azokat a szavazásokat, amelyekbe már átmásolódott.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Súlyozott szavazás használata egy szavazásban

Válaszd ki a **Súlyozott szavazás használata** lehetőséget a szavazás speciális beállításaiban. A szavazás megnyitása után is be- vagy kikapcsolhatod. A kikapcsolás a szavazásban minden szavazati súlyt `1`-re állít, és az adott szavazáshoz módosított szavazati súlyok elvesznek.

Ha a csoportod egy kialakult folyamatban használ súlyozott szavazást, válaszd ki a **Súlyozott szavazás használata** lehetőséget egy [szavazási sablonban](/en/user_manual/polls/poll_templates). Az ebből a sablonból indított szavazások súlyozott szavazást használnak.

![A Súlyozott szavazás használata beállítás egy szavazásban](poll-setting.png)

A súlyozott szavazás ezekkel a szavazástípusokkal használható: [Javaslat](/en/user_manual/polls/proposals), [Válassz](/en/user_manual/polls/choose), [Pontszám](/en/user_manual/polls/score), [Kiosztás](/en/user_manual/polls/allocate) és [Rangsorolás](/en/user_manual/polls/rank).

Ugyanabban a szavazásban nem használhatsz súlyozott szavazást és [névtelen szavazást](/en/user_manual/polls/anonymous_voting).

Egy szavazó szavazati súlyának módosításához válaszd ki a **Szavazók kezelése** lehetőséget, majd a neve melletti szavazati súlyt. Mindenki szavazati súlyának módosításához válaszd ki **Az összes szavazati súly beállítása** lehetőséget. Átmásolhatod az egyes tagok szavazati súlyát a csoportból, vagy mindenkinek ugyanazt az értéket adhatod meg. Azok a szavazók, akik nem csoporttagok, `1`-es szavazati súlyt kapnak.

![A Szavazók kezelése gomb egy szavazásban](poll-manage-voters.png)

![Egy szavazás szavazói egyéni szavazati súlyokkal](poll-voter-weights.png)

<!-- translation-section: results -->

## Eredmények

Az eredmények egymás mellett mutatják a súlyozás nélküli és a súlyozott összesítéseket:

- A Javaslat és a Válassz típusú szavazások a **Szavazatok** és a **Súlyozott szavazatok** oszlopot mutatják.
- A Pontszám, a Kiosztás és a Rangsorolás típusú szavazások a **Pont** és a **Súlyozott pontok** oszlopot mutatják.

A diagram a súlyozott eredményt mutatja. Válaszd ki egy oszlop fejlécét, ha inkább annak az oszlopnak az adatait szeretnéd megjeleníteni a diagramon. A jogosult szavazók száma és a határozatképesség az emberek számán alapul, nem a szavazati súlyokon. Aki láthatja a szavazatokat, az minden szavazó szavazati súlyát is láthatja.

![Egy javaslat eredménye szavazatokkal és súlyozott szavazatokkal](weighted-proposal-result.png)
