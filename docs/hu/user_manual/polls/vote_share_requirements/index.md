---
title: Szavazati arányra vonatkozó követelmények
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: c97281f29d615dea
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: 0d25794ec996d42c
  detailed-example: dc765c43a22a28a1
generated:
  introduction: dd9954d58fd681fc
  eligible-voters-and-votes-cast: 2d01bc7655195e4f
  different-vote-share-requirements: 596fcee3511c08e4
  detailed-example: 862caf3211625b2e
title_source: a654891ca817844e
title_generated: 899d1458530748ec
---

<!-- translation-section: introduction -->

# Szavazati arányra vonatkozó követelmények

Állíts be szavazati arányra vonatkozó követelményt egy lehetőségnél, ha a javaslat elfogadásához a támogatásnak el kell érnie egy meghatározott százalékot, vagy az ellenző szavazatok arányának egy meghatározott százalék alatt kell maradnia.

A szavazati arányra vonatkozó követelményt [részvételi küszöbbel](/en/user_manual/polls/quorum/) is kombinálhatod. Így a javaslat elfogadásához elegendő részvétel és megfelelő szavazati arány is szükséges.

Javaslat létrehozásakor kattints az egyik lehetőség melletti szerkesztés ikonra.

![A szerkesztés ikon az Egyetértés lehetőség mellett](edit-highlight-on-option.png)

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

- Az Egyetértés aránya érje el a jogosult szavazók legalább 75 százalékát
- A Tartózkodik aránya legfeljebb a leadott szavazatok 30 százaléka lehet
- A Tiltakozás aránya legfeljebb a leadott szavazatok 0 százaléka lehet

A követelményeket [szavazássablonhoz](/en/user_manual/polls/poll_templates/) is hozzáadhatod. Így a sablonból létrehozott új javaslatok alapértelmezés szerint használják őket.

<!-- translation-section: detailed-example -->

## Részletes példa

A Zabtej Szövetkezet arról dönt, hogy jóváhagyja-e a visszaváltható palackok hathetes próbaidőszakának költségvetését. Öten jogosultak szavazni.

Jamie a **Beleegyezés** javaslatsablont használja, szerkeszti az Egyetértés lehetőséget, és bekapcsolja a szavazati arányra vonatkozó követelményt.

A szövetkezet szabályai szerint a javaslatot a jogosult szavazók legalább 75 százalékának támogatnia kell. Jamie a követelményt **Legalább 75% a Jogosult szavazókból** értékre állítja.

![Az Egyetértés lehetőséghez a jogosult szavazók legalább 75 százalékának támogatása szükséges](./consent-vote-option.png)

Jamie 60 százalékos részvételi küszöböt is beállít. Jamie és Samira egyetértésre szavaz. Minden leadott szavazat támogatja a javaslatot, de ez a jogosult szavazók mindössze 40 százalékát jelenti, így egyik követelmény sem teljesül.

![Ötből ketten szavaztak egyetértésre, és egyik követelmény sem teljesül](./first-vote-breakdown.png)

Ezután Alex és Morgan egyetértésre, Taylor pedig az egyet nem értésre szavaz. Mind az öten szavaztak, így teljesül a részvételi küszöb. Az öt jogosult szavazóból négyen egyetértenek. A 80 százalékos egyetértés meghaladja a 75 százalékos követelményt, ezért mindkét követelménynél zöld pipa jelenik meg.

![Mind az öten szavaztak, és mindkét követelmény teljesül](./final-vote-breakdown.png)
