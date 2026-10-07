---
title: Alcsoportok
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: 5bdd92ce200f197a
  permissions: ee02991523f1ebe4
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: ee3713d0233cae02
  add-a-subgroup: 403fc6fe9c56ff91
  subgroup-settings: 16d3adb394b9f23e
  privacy: 7fd50bdbcee5c0d1
  permissions: 1f56658a5167bfab
  find-subgroups: 4a9b8588abd2a44d
  invite-to-a-subgroup: 6b62a1bbab58947c
  simultaneously-invite-people-to-subgroups-and-parent-group: 9a32f87b98d4beff
  administer-a-subgroup: b12db1ce0ba3b431
  delete-a-subgroup: b425952ca6a4401b
title_source: 9f81e728f70cae3e
title_generated: a74a4851d37bc4f2
---

<!-- translation-section: introduction -->

# Alcsoportok

Az alcsoportok segítenek megszervezni a kommunikációt és a tagok együttműködését, hogy a megfelelő emberek dolgozzanak együtt.

Egy szervezetnek például a következő alcsoportjai lehetnek:
- vezetőtestület
- munkacsapat vagy projektmunkacsoport
- egy témával foglalkozó csoport (például „stratégia” vagy „tanulás”)

Az alcsoportok ugyanúgy működnek, mint a csoportok, de a szülőcsoporton belül helyezkednek el. A legtöbb elérhető funkció és beállítás megegyezik a szülőcsoportéval. Ez azt is jelenti, hogy valaki tagja lehet az alcsoportodnak, például a vezetőtestületnek, anélkül, hogy a szülőcsoportnak is tagja lenne.

<!-- translation-section: add-a-subgroup -->

## Alcsoport hozzáadása

>[!Note]
>Az új alcsoportok hozzáadásának lehetőségét a csoport [jogosultsági beállításai](/en/user_manual/groups/settings/permissions) szabályozzák. Alapértelmezés szerint csak az adminok indíthatnak új alcsoportokat.

Alcsoport hozzáadásához nyisd meg a szülőcsoportod oldalát, majd kattints az oldalsávban az **Új alcsoport** gombra.  

![Új alcsoport gomb az Oatmilk Cooperative oldalsávjában](subgroups-sidebar.png)

Kattints az **Új alcsoport** gombra, adj nevet az alcsoportnak, és válaszd ki az adatvédelmi beállítást, majd kattints **Az alcsoport indítása** gombra.

![Új alcsoport létrehozására szolgáló űrlap a csomagolási munkacsoporthoz](subgroups_new.png)

Ha készen állsz, [hívj meg embereket](/en/user_manual/groups/inviting_people/) az alcsoportba.

Az alcsoport [csoportbeállításait](/en/user_manual/groups/settings/) az alcsoport oldalán található fogaskerékikonra kattintva módosíthatod.

![Csoportbeállítások szerkesztése a csomagolási munkacsoportban](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Az alcsoport beállításai

<!-- translation-section: privacy -->

### Adatvédelem

Válaszd ki, hogy kik találhatják meg az alcsoportot, attól függetlenül, hogy hogyan csatlakozhatnak hozzá:

| Adatvédelem | Ki találhatja meg | Ki olvashatja a szálait |
| --- | --- | --- |
| **Nyitott** | Bárki | Bárki |
| **Zárt** | Bárki | Az alcsoport tagjai és a meghívott vendégek |
| **Látható a szülőcsoport számára** | A szülőcsoport és az alcsoport tagjai | Az alcsoport tagjai és a meghívott vendégek |
| **Titkos** | Az alcsoport meghívott tagjai | Az alcsoport tagjai és a meghívott vendégek |

Ha szeretnéd, hogy a szülőcsoport tagjai önállóan csatlakozhassanak, válaszd ki a **Látható a szülőcsoport számára** beállítást, majd az **A(z) [szülőcsoport] tagjai jóváhagyás nélkül csatlakozhatnak** lehetőséget a **Hogyan csatlakoznak az emberek?** résznél az alcsoport létrehozásakor, vagy a **Csoportbeállítások szerkesztése → Adatvédelem** résznél. A szülőcsoporton kívüli embereknek meghívóra van szükségük. A tagok kiléphetnek az alcsoportból, majd újra csatlakozhatnak, amíg a szülőcsoport tagjai maradnak.

![Az alcsoport adatvédelmi beállításai a szülőcsoport számára való láthatósággal és jóváhagyás nélküli csatlakozással](subgroups_privacy_settings.png)

A csatlakozással az illető az alcsoport egyszerű tagjává válik. Ettől nem lesz admin, és a meglévő szálak adatvédelmi beállításai sem változnak.

A nyilvános alcsoportok is engedélyezhetik az azonnali csatlakozást; ha ezt a lehetőséget választod, bárki csatlakozhat. Ha a szülőcsoport privát, az alcsoportnál a **Látható a szülőcsoport számára** és a **Titkos** beállítás érhető el.

A **Látható a szülőcsoport számára** beállítású alcsoport privát marad, ha a szülőcsoportja nyilvánossá válik. Ha a szülőcsoportot priváttá teszed, a nyilvános alcsoportjai csak a szülőcsoport tagjai számára lesznek láthatók, és a szálaik priváttá válnak. A titkos alcsoportok változatlanok maradnak.

[A csoportok adatvédelméről itt olvashatsz](/en/user_manual/groups/settings/privacy).

<!-- translation-section: permissions -->

### Engedélyek

Az alcsoportok a szülőcsoporttól függetlenül működnek. Ha például az alcsoport adatvédelmi beállítása **Titkos**, akkor csak a meghívott tagok találhatják meg az alcsoportot, láthatják a tagjait és a szálait.

A **Zárt** és a **Látható a szülőcsoport számára** beállítású alcsoportok engedélyezhetik, hogy a szülőcsoport tagjai már a csatlakozás előtt olvashassák a privát szálakat. Kapcsold be az **A(z) [szülőcsoport] tagjai láthatják a privát szálakat** beállítást az **Engedélyek** résznél. Ezek az olvasók nem kapnak szavazati jogot, és nem válnak az alcsoport tagjaivá.

![Beállítás, amely lehetővé teszi, hogy a szülőcsoport tagjai lássák az alcsoport privát szálait](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Alcsoportok keresése

Nyisd meg az oldalsávot, és kattints a csoportod nevére az alcsoportjainak megtekintéséhez.

![Az Oatmilk Cooperative alcsoportjai az oldalsávban](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## Meghívás alcsoportba

Ugyanúgy hívj meg embereket egy alcsoportba, mint egy csoportba. Ha már tagjai ugyanazon szervezet valamelyik szülőcsoportjának vagy másik alcsoportjának, amelynek te is tagja vagy, beírhatod a nevüket, vagy kiválaszthatod az adott csoportot címzettként. Válaszd ki a címzetteket jelölő címkét, hogy a csoport helyett az egyes emberek jelenjenek meg, majd távolítsd el azokat, akiket nem szeretnél meghívni.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Emberek egyidejű meghívása alcsoportokba és a szülőcsoportba

Ha a szülőcsoport **Tagok** lapján a **Hívj meg embereket** gombot használod, egyszerre több alcsoportba is meghívhatsz embereket. Jelöld be azoknak az alcsoportoknak a jelölőnégyzetét, amelyekhez szeretnéd, hogy azonnal csatlakozzanak.

![A szülőcsoport és az alcsoport kiválasztása a meghívó űrlapján](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Alcsoport kezelése

Az alcsoportoknak lehetnek saját adminjaik, akik eltérhetnek a szülőcsoport adminjaitól.

A szülőcsoport adminja azonban bármelyik alcsoportban adminná teheti magát. Ez lehetővé teszi, hogy a szülőcsoport adminjai szükség esetén kezeljék az alcsoportokat.

Nyisd meg az Alcsoportok lapot, keresd meg az alcsoportot, és kattints a **Kapcsolódj a csoporthoz** gombra.

![Kapcsolódj a csoporthoz gomb egy zárt alcsoportban](member_join_subgroup.png)

Miután az alcsoport tagja lett, a szülőcsoport adminja az alcsoportban is adminná teheti magát.

![Adminná tétel művelet a szülőcsoport egyik adminja számára](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Alcsoport törlése

Az adminok ugyanúgy törölhetnek egy alcsoportot, mint egy csoportot. Alcsoport törlésekor ügyelj arra, hogy ne a szülőcsoportot töröld.

[Olvasd el, hogyan törölhetsz csoportokat](/en/user_manual/groups/deleting_your_group/).
