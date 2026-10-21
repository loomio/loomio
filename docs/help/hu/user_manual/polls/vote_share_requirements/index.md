---
title: Szavazati arányra vonatkozó követelmények
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: dd647f06e3600784
  eligible-voters-and-votes-cast: 5933f0fc011fa890
  different-vote-share-requirements: '09b534e644fda4c0'
  detailed-example: c5d02cc747af70bb
title_source: a654891ca817844e
title_generated: 899d1458530748ec
---

<!-- translation-section: introduction -->

# Szavazati arányra vonatkozó követelmények

Állíts be egy lehetőséghez szavazati arányra vonatkozó követelményt, ha a javaslat elfogadásához meghatározott százalékú támogatás szükséges, vagy az ellenző szavazatok arányának egy meghatározott százalék alatt kell maradnia.

A szavazati arányra vonatkozó követelményeket [határozatképességi küszöbbel](/en/user_manual/polls/quorum/) is kombinálhatod, hogy elegendő részvételre és a szavazatok meghatározott megoszlására is szükség legyen.

A javaslat űrlapján válaszd ki az egyik lehetőség melletti szerkesztés ikont.

![A szerkesztés ikon az Egyetértek lehetőség mellett](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Jogosult szavazók és leadott szavazatok

A százalék alapja a **Leadott szavazatok** vagy a **Jogosult szavazók** száma lehet.

![Annak kiválasztása, hogy a szavazati arányra vonatkozó követelmény alapja a leadott szavazatok vagy a jogosult szavazók száma legyen](./eligible-vs-cast.png)

A **Jogosult szavazók** közé mindenki beletartozik, aki szavazhat a javaslatról. A **Leadott szavazatok** csak a már beküldött szavazatokat jelentik.

Ha a követelmény a jogosult szavazók 75 százalékának egyetértése, a javaslat csak akkor fogadható el, ha az összes jogosult szavazó legalább 75 százaléka erre a lehetőségre szavaz.

Ha a követelmény a leadott szavazatok 60 százalékának egyetértése, a javaslat akkor fogadható el, ha a beküldött szavazatok 60 százaléka támogatja a lehetőséget, a teljes részvételi aránytól függetlenül. Állíts be határozatképességi küszöböt, ha a folyamatotok minimális részvételi arányt is megkövetel.

<!-- translation-section: different-vote-share-requirements -->

## Különböző szavazati arányra vonatkozó követelmények

Egy javaslat több lehetőségéhez is tartozhat követelmény. Például:

- Az egyetértő szavazatok arányának el kell érnie a jogosult szavazók 75 százalékát
- A tartózkodó szavazatok aránya legfeljebb a leadott szavazatok 30 százaléka lehet
- A vétók aránya legfeljebb a leadott szavazatok 0 százaléka lehet

Gyakori beállítás a **Legfeljebb 0%** követelmény használata egy lehetőségnél. Ez azt jelenti, hogy a javaslat nem fogadható el, ha bárki ezt a lehetőséget választja. Használd a **Vétózom** lehetőségnél, hogy egyetlen vétó is megakadályozza a javaslat elfogadását.

Egy [szavazási sablonhoz](/en/user_manual/polls/poll_templates/) is hozzáadhatsz követelményeket, így a sablonból létrehozott új javaslatok alapértelmezetten ezeket használják.

<!-- translation-section: detailed-example -->

## Részletes példa

Az Oatmilk Cooperative arról dönt, hogy hat héten át kipróbálja-e a visszaváltható palackok használatát. Öt ember jogosult szavazni.

A szövetkezet döntési folyamata a jogosult szavazók legalább 75 százalékának egyetértését követeli meg. Jamie szerkeszti a javaslat **Egyetért** lehetőségét, bekapcsolja a szavazati arányra vonatkozó követelményt, és **A Jogosult szavazók legalább 75%-a** értékre állítja.

![Az Egyetértek lehetőség, amelyhez a jogosult szavazók legalább 75 százalékának támogatása szükséges](./agree-vote-option.png)

Jamie 60 százalékos határozatképességi küszöböt is beállít. Jamie és Samira egyetértő szavazatot ad le. Minden beküldött szavazat támogatja a javaslatot, de ezek a jogosult szavazók mindössze 40 százalékát képviselik, így egyik követelmény sem teljesült.

![Öt emberből ketten adtak le egyetértő szavazatot, és egyik követelmény sem teljesült](./first-vote-breakdown.png)

Ezután Alex és Morgan egyetértő, Taylor pedig ellenző szavazatot ad le. Mind az öt ember szavazott, így teljesült a határozatképességi követelmény, és az öt jogosult szavazóból négy egyetért. A 80 százalékos egyetértési arány meghaladja az előírt 75 százalékos szavazati arányt, ezért mindkét követelmény mellett zöld pipa jelenik meg.

![Mind az öt ember szavazott, és mindkét követelmény teljesült](./final-vote-breakdown.png)
