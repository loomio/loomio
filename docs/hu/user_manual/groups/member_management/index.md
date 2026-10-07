---
title: Tagok kezelése
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: f216b18771a2c2a9
  administering-your-group: 27aed40959adef57
  managing-subgroups: 76b2fd61123a8a8a
  removing-members: f00aea52bfcd3547
  leaving-group: 02f69c9806d6beda
  set-title: 835b25d246477b4a
  member-email-addresses: cae570f30b671275
generated:
  introduction: 94d82cee3ecb6496
  administering-your-group: f88971e605ec8115
  managing-subgroups: 17d15a1c854d21da
  removing-members: 87a2d7584a591beb
  leaving-group: febb3e91c9bc92b4
  set-title: ff532d79fa2da32f
  member-email-addresses: 8e86cd0869710340
title_source: 23ac3a7fe9ee72a2
title_generated: e9f1ed3c33a8ce3e
---

<!-- translation-section: introduction -->

# Tagok kezelése

Ha admin vagy, a csoportod oldalán a **Tagok** fülön kezelheted a tagokat.

Kattints a csoporttagtól jobbra található három pontra (**⋮**), hogy megadd a címét, adminná vagy delegálttá tedd, vagy eltávolítsd a csoportból.

![Tagműveletek menüje az Oatmilk Cooperative tagjainak oldalán](member_management.png)

<!-- translation-section: administering-your-group -->

## A csoportod adminisztrálása
A Loomio-csoportokban csak két felhasználótípus van: **tag** és **admin**.

Az adminok végzik a csoport adminisztratív feladatait: tagokat adnak hozzá és távolítanak el, kezelik a tagok jogosultságait, beállítják a csoport adatvédelmi szintjét, és kezelik az előfizetési csomagokat. Emellett láthatják a tagok e-mail-címét, és exportálhatják a csoport adatait.

Az új Loomio-csoportot létrehozó személy alapértelmezés szerint admin lesz. Javasoljuk, hogy a csoportodban legalább egy másik megbízható személynek is adj adminjogokat, hogy mindig legyen valaki, aki kezelni tudja a csoportot. A csoportodban tetszőleges számú admin lehet.

Ha egy tagot **adminná** szeretnél tenni, nyisd meg a Tagok fület, keresd meg a tagot, és kattints a neve melletti három pontra (**⋮**). Válaszd ki az **Adminisztrátor jogok megadása** lehetőséget. A neve mellett megjelenik egy `Admin` címke.

![Adminisztrátor jogok megadása művelet egy tag menüjében](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## Alcsoportok kezelése
A szülőcsoport adminjai csatlakozhatnak annak nyílt, zárt és **Látható a szülőcsoport számára** beállítású alcsoportjaihoz, majd adminjogokat adhatnak maguknak ezekben az alcsoportokban.

Válaszd ki a **Kapcsolódj a csoporthoz** lehetőséget az alcsoport oldalán.

![Csatlakozás a csoporthoz gomb az Oatmilk Cooperative egyik zárt alcsoportjában](member_join_subgroup.png)

Miután csatlakoztál az alcsoporthoz, magadnak is adhatsz adminjogokat, ugyanúgy, ahogyan bárki másnak.

>[!Note]
>Ezek a jogosultságok nem terjednek ki a [**titkos** alcsoportokra](/en/user_manual/groups/subgroups/?highlight=secret#permissions).

<!-- translation-section: removing-members -->

## Tagok eltávolítása
Ha az **Eltávolítás a csoportból** lehetőségre kattintasz, meg kell erősítened az eltávolítást. Az eltávolítás után a felhasználó többé nem fér hozzá a csoport oldalaihoz, szálaihoz, szavazásaihoz vagy javaslataihoz. Nem kap több e-mailt vagy értesítést a csoport tevékenységéről. A felhasználó korábbi hozzászólásai és szavazatai azonban változatlanul megmaradnak.

![Eltávolítás a csoportból művelet egy tag menüjében](member_remove.png)

Ha szeretnéd, később újra hozzáadhatod az eltávolított tagokat a csoporthoz.

<!-- translation-section: leaving-group -->

## Kilépés a csoportból
Ha ki szeretnél lépni egy csoportból, nyisd meg a csoport oldalát, nyisd meg a hárompontos menüt, és kattints a **Kilépés a csoportból** lehetőségre.

![Kilépés a csoportból művelet az Oatmilk Cooperative beállítási menüjében](member_leave_group.png)

<!-- translation-section: set-title -->

## Cím megadása
A Tagok fülön a **cím** mezővel megadhatod a csoportban betöltött szerepedet vagy az általad képviselt szervezetet. Te vagy a csoport egyik adminja a neved melletti hárompontos menü **Cím megadása** lehetőségével módosíthatja a címedet.

![Cím megadása művelet egy tag menüjében](member_set_title.png)

A különböző alcsoportokban eltérő címeid lehetnek.

<!-- translation-section: member-email-addresses -->

## A tagok e-mail-címei

Csak az adminok láthatják a csoporttagok e-mail-címeit. Erre időnként szükség lehet a csoport tagságának ellenőrzéséhez.

A tagok e-mail-címeinek megtekintéséhez tölts le egy CSV-fájlt az [adatexportálással](/en/user_manual/groups/data_export/), majd nyisd meg Excelben vagy Google Táblázatokban.

A csoport exportált adatfájlja minden alcsoport minden tagját és e-mail-címét tartalmazza.

A Tagok fülön e-mail-cím alapján is kereshetsz tagokat. Ha valakit el szeretnél távolítani, az e-mail-címe alapján megkeresheted, majd eltávolíthatod.
