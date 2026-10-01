---
title: Határozatképesség
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 98d078d4d2a3a430
  example-scenario: e1cc6cccc0fc2933
title_source: 18ed8b6c5ab90343
title_generated: 6c41db0de288697e
---

<!-- translation-section: introduction -->

# Határozatképesség

A határozatképesség a szavazásra jogosultak azon minimális százalékos aránya, akiknek részt kell venniük ahhoz, hogy a szavazás érvényes legyen. Használd, ha a döntéshozatali folyamatod meghatározott részvételi arányt követel meg.

Szavazás létrehozásakor nyisd meg a **További beállítások** részt, és add meg a szükséges százalékot a **Részvételi határozatképesség** mezőben. Hagyd üresen a mezőt, ha nincs határozatképességi követelmény.

![A határozatképesség beállítása 60 százalékos részvételi küszöbbel](./quorum-section.png)

Egy [szavazási sablonban](/en/user_manual/polls/poll_templates/) is beállíthatod a határozatképességi küszöböt, így az abból létrehozott szavazások alapértelmezés szerint ezt használják.

<!-- translation-section: example-scenario -->

## Példa

Az Oatmilk szövetkezet egy hathetes, visszaváltható palackokkal végzett próba bevezetéséről beszélget. A beszélgetés eljutott oda, hogy a szövetkezetnek jóvá kell hagynia a próba költségvetését.

Jamie kiválasztja a **Szavazás indítása** gombot, majd a **Beleegyezés** javaslatsablont, és kitölti a címet, a részleteket, a lehetőségeket, az időtartamot és a szavazók beállításait.

![A javaslat címe, részletei, lehetőségei, időtartama és a szavazók beállításai](proposal-options.png)

Jamie a próba költségvetéséért felelős öt emberre korlátozza a szavazásra jogosultak körét.

A szövetkezet a jelentős döntésekhez 60 százalékos részvételt követel meg, ezért Jamie **60**-at ír a részvételi határozatképesség mezőbe, és elindítja a javaslatot.

Mielőtt bárki szavazna, az eredmények panelje azt mutatja, hogy a szavazás még nem érte el a határozatképességi küszöböt.

![Még nincs leadott szavazat, és a szavazás nem érte el a 60 százalékos határozatképességi küszöböt](pie-chart-0.png)

Jamie az Egyetértek, Samira pedig a Nem értek egyet lehetőségre szavaz. A diagram frissül, de az öt jogosult szavazóból kettő csak 40 százalékos részvételt jelent, így a szavazás továbbra sem éri el a határozatképességi küszöböt.

![Ötből két szavazatot adtak le, és a szavazás még nem érte el a határozatképességi küszöböt](pie-chart-40.png)

Ezután Alex is az Egyetértek lehetőségre szavaz. Az öt jogosult szavazóból hárman részt vettek, így a szavazás elérte a 60 százalékos határozatképességi küszöböt. A követelmény mellett most zöld pipa jelenik meg. Jamie azonnal lezárhatja a szavazást, vagy várhat a többi szavazóra.

![Ötből három szavazatot adtak le, és a szavazás elérte a 60 százalékos határozatképességi küszöböt](pie-chart-60.png)
