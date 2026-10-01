---
title: Szavazati arányra vonatkozó követelmények
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  introduction: a033bf0acbdea486
  eligible-voters-and-votes-cast: 2d01bc7655195e4f
  different-vote-share-requirements: 282001c229690c9e
  detailed-example: 1f15a1144c4e971e
title_source: a654891ca817844e
title_generated: 899d1458530748ec
---

<!-- translation-section: introduction -->

# Szavazati arányra vonatkozó követelmények

Állíts be szavazati arányra vonatkozó követelményt egy lehetőségnél, ha a javaslat elfogadásához a támogatásnak el kell érnie egy meghatározott százalékot, vagy az ellenző szavazatok arányának egy meghatározott százalék alatt kell maradnia.

A szavazati arányra vonatkozó követelményt [részvételi küszöbbel](/en/user_manual/polls/quorum/) is kombinálhatod. Így a javaslat elfogadásához elegendő részvétel és megfelelő szavazati arány is szükséges.

A javaslat űrlapján kattints az egyik lehetőség melletti szerkesztés ikonra.

![A szerkesztés ikon az Egyetért lehetőség mellett](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Jogosult szavazók és leadott szavazatok

A százalékot a **Leadott szavazatok** vagy a **Jogosult szavazók** alapján számíthatod.

![Annak kiválasztása, hogy a szavazati arányra vonatkozó követelmény a leadott szavazatokon vagy a jogosult szavazókon alapuljon](./eligible-vs-cast.png)

A **Jogosult szavazók** a javaslatban szavazásra jogosult összes embert jelenti. A **Leadott szavazatok** csak a beküldött szavazatokat jelenti.

Ha a követelmény a jogosult szavazók legalább 75 százalékának egyetértése, az csak akkor teljesülhet, ha az összes jogosult szavazó legalább 75 százaléka erre a lehetőségre szavaz.

Ha a követelmény a leadott szavazatok legalább 60 százalékának egyetértése, az akkor is teljesülhet, ha nem mindenki szavaz, feltéve hogy a beküldött szavazatok 60 százaléka támogatja a lehetőséget. Állíts be részvételi küszöböt is, ha a folyamatod minimális részvételt ír elő.

<!-- translation-section: different-vote-share-requirements -->

## Többféle szavazati arányra vonatkozó követelmény

Egy javaslat több lehetőségéhez is beállíthatsz követelményt. Például:

- Az egyetértők aránya érje el a jogosult szavazók legalább 75 százalékát
- A Tartózkodik lehetőségre leadott szavazatok aránya legfeljebb a leadott szavazatok 30 százaléka lehet
- A Tiltakozás lehetőségre leadott szavazatok aránya legfeljebb a leadott szavazatok 0 százaléka lehet

Gyakori beállítás a **Legfeljebb 0%** követelmény. Ez azt jelenti, hogy a javaslat nem fogadható el, ha bárki ezt a lehetőséget választja. Használd a **Tiltakozás** lehetőségnél, hogy egyetlen tiltakozás is megakadályozza a javaslat elfogadását.

A követelményeket [szavazássablonhoz](/en/user_manual/polls/poll_templates/) is hozzáadhatod. Így a sablonból létrehozott új javaslatok alapértelmezés szerint használják őket.

<!-- translation-section: detailed-example -->

## Részletes példa

A Zabtej Szövetkezet arról dönt, hogy indítson-e hathetes próbaidőszakot a visszaváltható palackok használatára. Öten jogosultak szavazni.

A szövetkezet szabályai szerint a jogosult szavazók legalább 75 százalékának egyet kell értenie. Jamie szerkeszti a javaslat **Egyetért** lehetőségét, bekapcsolja a szavazati arányra vonatkozó követelményt, és **Legalább 75% a Jogosult szavazókból** értékre állítja.

![Az Egyetért lehetőséghez a jogosult szavazók legalább 75 százalékának támogatása szükséges](./agree-vote-option.png)

Jamie 60 százalékos részvételi küszöböt is beállít. Jamie és Samira az Egyetért lehetőségre szavaz. Minden leadott szavazat támogatja a javaslatot, de ez a jogosult szavazók mindössze 40 százalékát jelenti, így egyik követelmény sem teljesül.

![Ötből ketten szavaztak az Egyetért lehetőségre, és egyik követelmény sem teljesül](./first-vote-breakdown.png)

Ezután Alex és Morgan az Egyetért, Taylor pedig a Nem ért egyet lehetőségre szavaz. Mind az öten szavaztak, így teljesül a részvételi küszöb. Az öt jogosult szavazóból négyen egyetértenek. A 80 százalékos egyetértés meghaladja a 75 százalékos követelményt, ezért mindkét követelménynél zöld pipa jelenik meg.

![Mind az öten szavaztak, és mindkét követelmény teljesül](./final-vote-breakdown.png)
