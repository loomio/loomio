---
title: Bizalmas beadványok gyűjtése
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 1d263d407af586d9
  enable-private-submissions: 3520fbea1fb1267f
  set-up-a-private-submission-process: e9e30dd30ab9d468
  make-a-submission: ac6611a046f0bf9f
  review-submissions: 7014e6ac14301129
generated:
  introduction: 5b5949a0752ceff9
  enable-private-submissions: 18d789b449b489ae
  set-up-a-private-submission-process: 065abc6e3cc12f80
  make-a-submission: 39f94cb1bae83465
  review-submissions: 397a6c8d96a5017d
title_source: e82ab76916d594f4
title_generated: c40961866422e032
---

<!-- translation-section: introduction -->

# Bizalmas beadványok gyűjtése

Használj zárt csoportot bizalmas beadványok gyűjtésére olyan emberektől, akik nem tagjai a csoportnak. Minden beadványból külön beszélgetés lesz, amelyben a beküldő és a csoport elbíráló csapata információt cserélhet, kérdéseket tehet fel és rögzítheti a döntést. A beküldők nem láthatják a csoport többi bizalmas beszélgetését vagy beadványát.

A jelölések jól példázzák ezt a felhasználási módot, amikor a jelöltek adatait vagy névsorát bizalmasan kell kezelni a kiválasztás során. Bárki jelölheti saját magát vagy valaki mást egy választásra, kinevezésre, bizottsági, vezetőségi vagy képviselői szerepre, miközben a kiválasztó bizottság minden jelölést külön beszélgetésben bírál el.

További felhasználási területek, ahol a beadványok nem lehetnek nyilvánosak:

- Panaszok, veszélyeztetésről szóló bejelentések, biztonsági aggályok és incidensjelentések
- Fellebbezések és egyedi ügyekben hozott döntések felülvizsgálatára irányuló kérelmek
- Közvetítésre, konfliktuskezelésre vagy személyes támogatásra irányuló kérelmek
- Személyes, pénzügyi vagy jogosultsági adatokat tartalmazó pályázatok, például rászorultsági támogatásokra vagy ösztöndíjakra
- Zárt ajánlatok vagy pályázati ajánlatok, amelyeket az elbírálás során bizalmasan kell kezelni

Ebben a folyamatban a beküldők nem látják egymás beadványait, de a beküldés nem névtelen. A beküldőknek felhasználói fiókra van szükségük, és a zárt csoport minden tagja láthatja a beadványokat. Mielőtt érzékeny adatok kezelésére használnád a csoportot, gondold át, kik a tagjai.

<!-- translation-section: enable-private-submissions -->

## Bizalmas beadványok beküldésének engedélyezése

Adminnak kell lenned abban a csoportban vagy alcsoportban, ahol a beadványokat gyűjteni szeretnéd.

1. Nyisd meg a csoportot.
2. Válaszd ki a **Beállítások** menüpontot (vagy a **Több**, majd **A csoportbeállítások szerkesztése** menüpontot).
3. Nyisd meg az **Engedélyek** lapot.
4. Kapcsold be a **Nem tagok is indíthatnak beszélgetéseket** beállítást.
5. Mentsd el a csoportbeállításokat.

![Az Engedélyek lap a csoportbeállításokban, a Nem tagok is indíthatnak beszélgetéseket beállítás kiemelve](non_members_can_start_discussions.png)

Ez a beállítás csak **Nyitott** és **Zárt** csoportoknál érhető el. **Titkos** csoportoknál nem jelenik meg. Ha nem látod, nyisd meg az **Adatvédelem** lapot a csoportbeállításokban, és állítsd a **Csoport adatvédelme** beállítást **Zárt** (bizalmas beadványokhoz ajánlott) vagy **Nyitott** értékre, majd térj vissza az **Engedélyek** lapra.

Ennek az engedélynek a bekapcsolása nem teszi nyilvánossá a csoport beszélgetéseit. Aki nem tag, új beszélgetést indíthat, és vendégként hozzáférhet ahhoz, de a csoport többi bizalmas beszélgetését nem láthatja.

<!-- translation-section: set-up-a-private-submission-process -->

## Bizalmas beadványok beküldési folyamatának kialakítása

1. Hozz létre egy külön alcsoportot a beadványok kezelésére, és állítsd az adatvédelmét **Zárt** értékre. Az alcsoport elkülöníti a beadványokat a szülőcsoport többi munkájától.
2. Add hozzá az alcsoporthoz tagként a kiválasztó bizottság tagjait vagy a beadványok elbírálásáért felelős más személyeket. Az alcsoport minden tagja láthat minden beadványt, ezért csak olyanokat adj hozzá, akiknek hozzá kell férniük ezekhez.
3. Hozz létre egy [beszélgetéssablont](/en/user_manual/discussions/templates) az alcsoportban. Add meg benne a kérdéseket és a beküldőktől kért információkat. Különböző típusú beadványokhoz különböző beszélgetéssablonokat hozhatsz létre.
4. Ha a beküldők nem kérhetik az alcsoporthoz való csatlakozást, állítsd a tagságot **Csak meghívóval** értékre.
5. [Engedélyezd a bizalmas beadványok beküldését](#enable-private-submissions) az alcsoport engedélyei között.
6. Próbáld ki a folyamatot egy olyan fiókkal, amely nem tagja az alcsoportnak.
7. Oszd meg az alcsoport oldalát a leendő beküldőkkel. A beadvány beküldése előtt be kell jelentkezniük a felhasználói fiókjukba.

<!-- translation-section: make-a-submission -->

## Beadvány beküldése

A beküldő megnyitja az alcsoportot, és kiválasztja a **Beszélgetés indítása** lehetőséget. A Loomio megjeleníti az alcsoportban elérhető beszélgetéssablonokat. A beküldő kiválasztja a megfelelő beszélgetéssablont, megválaszolja a kérdéseit, és elindítja a beszélgetést.

A beszélgetés az alcsoporthoz tartozik, de a beküldő nem válik az alcsoport tagjává. A Loomio vendégként hozzáadja a saját beszélgetési szálához, így láthatja a beszélgetést, és részt vehet benne a bizottsággal vagy az elbíráló csapattal együtt. Az alcsoport többi bizalmas beszélgetését vagy beadványát nem láthatja.

<!-- translation-section: review-submissions -->

## Beadványok elbírálása

Az alcsoport tagjai láthatják az alcsoport minden beadványhoz tartozó beszélgetését. További kérdéseket tehetnek fel, és hozzászólásokkal, szavazásokkal vagy más beszélgetési eszközökkel végezhetik el az elbírálást.

Ha másnak is információt kell adnia, az alcsoport megfelelő engedéllyel rendelkező tagja meghívhatja a beadványhoz tartozó beszélgetésbe. Például ha valaki jelölést küld be, az alcsoport meghívhatja a jelöltet a szálba, ha szükség van a részvételére. A meghívott személy vendégként csatlakozik, és nem fér hozzá az alcsoport többi bizalmas beszélgetéséhez.

Minden beküldő láthatja a saját beadványát, de az alcsoport többi bizalmas beszélgetését vagy beadványát nem. A beküldési időszak végén kapcsold ki a **Nem tagok is indíthatnak beszélgetéseket** beállítást. A meglévő beszélgetések és a vendégek hozzáférése változatlan marad.
