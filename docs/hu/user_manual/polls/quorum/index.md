---
title: Határozatképesség
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 9839128a319f064c
  example-scenario: d18e76706b045478
title_source: 18ed8b6c5ab90343
title_generated: 6c41db0de288697e
---

<!-- translation-section: introduction -->

# Határozatképesség

A részvételi határozatképesség azt a legkisebb arányt jelenti, amelyben a szavazásra jogosultaknak részt kell venniük ahhoz, hogy a szavazás érvényes legyen. Akkor használd, ha a döntéshozatali folyamatotok meghatározott részvételi arányt ír elő.

Szavazás létrehozásakor nyisd meg a **További beállítások** részt, és add meg a szükséges százalékot a **Részvételi határozatképesség** mezőben. Ha nincs részvételi követelmény, hagyd üresen a mezőt.

![A részvételi határozatképesség beállítása 60 százalékos értékkel](./quorum-section.png)

A részvételi határozatképességet [szavazási sablonban](/en/user_manual/polls/poll_templates/) is beállíthatod. Így a sablonból létrehozott szavazások alapértelmezés szerint ezt az értéket használják.

<!-- translation-section: example-scenario -->

## Példa

A Zabtej Szövetkezet egy hathetes, visszaváltható palackokkal végzett próbaidőszakról beszélget. A szövetkezetnek most jóvá kell hagynia a próbaidőszak költségvetését.

Jamie kiválasztja a **Szavazás indítása** lehetőséget, majd a **Beleegyezés** javaslatsablont. Kitölti a címet, a részleteket, a válaszlehetőségeket, az időtartamot és a szavazókra vonatkozó beállításokat.

![A javaslat címe, részletei, válaszlehetőségei, időtartama és a szavazók beállításai](proposal-options.png)

Jamie a szavazást arra az öt emberre korlátozza, akik a próbaidőszak költségvetéséért felelnek.

A szövetkezet a jelentős döntésekhez 60 százalékos részvételt ír elő. Jamie ezért **60**-at ír a részvételi határozatképesség mezőjébe, majd elindítja a javaslatot.

Mielőtt bárki szavazna, az eredmények panelje jelzi, hogy a szükséges részvételi arány még nem teljesült.

![Még senki sem szavazott, így a 60 százalékos részvételi arány nem teljesült](pie-chart-0.png)

Jamie egyetért, Samira pedig nem ért egyet. A diagram frissül, de az öt jogosult szavazóból csak ketten vettek részt. Ez 40 százalékos részvétel, így a szükséges arány még nem teljesült.

![Öt jogosultból ketten szavaztak, a szükséges részvételi arány még nem teljesült](pie-chart-40.png)

Ezután Alex is egyetért. Az öt jogosult szavazóból hárman vettek részt, így teljesült a 60 százalékos részvételi követelmény. A követelmény mellett most zöld pipa látható. Jamie lezárhatja a szavazást korábban, vagy megvárhatja a többi szavazót.

![Öt jogosultból hárman szavaztak, így teljesült a 60 százalékos részvételi követelmény](pie-chart-60.png)
