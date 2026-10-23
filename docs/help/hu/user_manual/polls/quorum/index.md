---
title: Határozatképesség
source_revision: ad60e7728a4b8d578ec70fa26577556ee051c09d
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: dbfdebe6e23060db
  example-scenario: d247e0866095c321
generated:
  introduction: adb84d888e40b51c
  example-scenario: 89acd8cce4fff1cd
title_source: 18ed8b6c5ab90343
title_generated: 6c41db0de288697e
---

<!-- translation-section: introduction -->

# Határozatképesség

A határozatképesség a szavazásra jogosultak azon minimális százalékos aránya, akiknek részt kell venniük ahhoz, hogy a szavazás érvényes legyen. Használd, ha a döntéshozatali folyamatod meghatározott részvételi arányt követel meg.

[Súlyozott szavazás](/en/user_manual/polls/weighted_voting) esetén a határozatképesség számítása a szavazati súlyokon alapul. Például Jamie szavazati súlya `2`, Samiráé `1`, Alexé pedig `1`. Ha csak Jamie szavaz, a szavazásra jogosultak összesített szavazati súlyának fele vesz részt. Ha Samira is szavaz, a részvétel eléri a 75 százalékot, így teljesül a 60 százalékos határozatképességi küszöb.

Szavazás létrehozásakor nyisd meg a **További beállítások** részt. Add meg a szükséges százalékot a **Határozatképesség** mezőben. Hagyd üresen a mezőt, ha nincs határozatképességi követelmény.

![A határozatképesség beállítása 60 százalékos részvételi küszöbbel](./quorum-section.png)

Egy [szavazási sablonban](/en/user_manual/polls/poll_templates/) is beállíthatod a határozatképességi küszöböt, így az abból létrehozott szavazások alapértelmezés szerint ezt használják.

<!-- translation-section: example-scenario -->

## Példa

Az Oatmilk szövetkezet egy hathetes, visszaváltható palackokkal végzett próba bevezetéséről beszélget. A beszélgetés eljutott oda, hogy a szövetkezetnek jóvá kell hagynia a próba költségvetését.

Jamie kiválasztja a **Szavazás indítása** gombot, majd a **Beleegyezés** javaslatsablont, és kitölti a címet, a részleteket, a lehetőségeket, az időtartamot és a szavazók beállításait.

![A javaslat címe, részletei, lehetőségei, időtartama és a szavazók beállításai](proposal-options.png)

Jamie a próba költségvetéséért felelős öt emberre korlátozza a szavazásra jogosultak körét.

A szövetkezet a jelentős döntésekhez 60 százalékos részvételt követel meg, ezért Jamie **60**-at ír a **Határozatképesség** mezőbe, és elindítja a javaslatot.

Mielőtt bárki szavazna, az eredmények panelje azt mutatja, hogy a szavazás még nem érte el a határozatképességi küszöböt.

![Még nincs leadott szavazat, és a szavazás nem érte el a 60 százalékos határozatképességi küszöböt](pie-chart-0.png)

Jamie az Egyetértek, Samira pedig a Nem értek egyet lehetőségre szavaz. A diagram frissül, de az öt jogosult szavazóból kettő csak 40 százalékos részvételt jelent, így a szavazás továbbra sem éri el a határozatképességi küszöböt.

![Ötből két szavazatot adtak le, és a szavazás még nem érte el a határozatképességi küszöböt](pie-chart-40.png)

Ezután Alex is az Egyetértek lehetőségre szavaz. Az öt jogosult szavazóból hárman részt vettek, így a szavazás elérte a 60 százalékos határozatképességi küszöböt. A követelmény mellett most zöld pipa jelenik meg. Jamie azonnal lezárhatja a szavazást, vagy várhat a többi szavazóra.

![Ötből három szavazatot adtak le, és a szavazás elérte a 60 százalékos határozatképességi küszöböt](pie-chart-60.png)
