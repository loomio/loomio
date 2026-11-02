---
title: Szavazók kezelése
source_revision: adca14fde066a1ed3f6b2bb163d402235efbc709
source_file: docs/help/en/user_manual/polls/manage_voters/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-29'
sections:
  introduction: ea21036eb694c27f
  invite-people-to-vote-in-a-poll: c087ce6e0173270f
  invite-guests-or-experts: c6e4d0e0811de6f2
  engage-people-while-a-poll-is-running: d0eb90b4b53003bc
  add-voters-to-the-poll: 621bd4bf8ed67895
  remove-people-from-the-poll: be96ad95169a79a3
  remind-people-to-vote: ab98343bd2bc18eb
  view-notification-history: 675d77824d320d89
  close-early: e09d92a63b72c516
  reopen: f80ab5f17351d679
  choose-an-audience: a7a00bf75338b395
  check-your-recipients: 7c3de537341ecd1b
  send-the-invitations: 7ca4926c4ff46564
generated:
  introduction: ec35e6e9f4579e9a
  invite-people-to-vote-in-a-poll: 54730e5b2862cb15
  invite-guests-or-experts: '053807ad6efb2899'
  engage-people-while-a-poll-is-running: 0e96138790e25658
  add-voters-to-the-poll: 86cbf0392afc8445
  remove-people-from-the-poll: 99031bc8968afc76
  remind-people-to-vote: f52a6e4bc4f5c613
  view-notification-history: f494da2afc410f43
  close-early: b6b92deedf3693ee
  reopen: 076ea1a20a92eed8
  choose-an-audience: b988f61c1ba8573b
  check-your-recipients: 4841e647c9e622c8
  send-the-invitations: 4a049826b93b3e29
title_source: 10858faa0464257e
title_generated: 12376556fe21b2f2
---

<!-- translation-section: introduction -->

# Szavazók kezelése

A **Szavazók kezelése** funkcióval szavazati jogot adhatsz embereknek, és meghívhatod őket egy javaslatban vagy szavazásban való részvételre.

<!-- translation-section: invite-people-to-vote-in-a-poll -->

<a id="invite-people-to-vote-in-a-poll"></a>
<a id="add-voters-to-the-poll"></a>

## Hívj meg embereket szavazni

Miután elindítasz egy szavazást a **Csak kiválasztott személyek** beállítással, megnyílik a **Szavazók kezelése** ablak. A szavazásnál a **Szavazók kezelése** lehetőséget választva is megnyithatod.

![A Szavazók kezelése gomb egy szavazás alján](proposal_after_start.png)

<!-- translation-section: choose-an-audience -->

### Válaszd ki a címzetteket

Kattints az üres **Szavazók keresése vagy meghívása** mezőre a javaslatok megtekintéséhez. A következő sorrendben jelennek meg:

- a csoportod
- a csoportod **küldöttei**, ha a csoportodnak vannak [delegált szavazói](/en/user_manual/groups/delegated_voters)
- csatlakoztatott csevegőszobák, például a Slackben vagy a Microsoft Teamsben
- alcsoportok és a szülőcsoport
- egyes tagok

Egy [közvetlen szálban](/en/user_manual/discussions/direct_discussions) a lista csoport helyett a **Mindenki ebben a témában** lehetőséget kínálja fel.

![A Szavazók kezelése ablak a csoportot, annak küldötteit, egy csevegőszobát és egy alcsoportot ajánlja fel](proposal_invite.png)

<a id="invite-a-subgroup-to-vote"></a>

Válassz ki egy címzetti kört, hogy egyszerre hívd meg az oda tartozó embereket. Az **Oatmilk Cooperative** kiválasztásával például az adott csoport tagjai kerülnek a címzettek közé. Egy csatlakoztatott csevegőszobát is kiválaszthatsz, hogy ott tedd közzé a meghívót. A csevegőszobában való közzététel nem adja hozzá annak tagjait szavazóként.

<!-- translation-section: check-your-recipients -->

### Ellenőrizd, kik szerepelnek a címzettek között

Miután kiválasztasz egy címzetti kört, a mező megjeleníti a nevét és az oda tartozó emberek számát. Ellenőrizd ezt a számot a meghívó elküldése előtt.

![Az Oatmilk Cooperative kiválasztva, a címzettek száma a mező alatt látható](proposal_invite_members.png)

Kattints a címzetti kör nevére az egyes emberek listájának kibontásához. Ezután a név melletti **×** kiválasztásával kihagyhatod az illetőt ebből a meghívóból. Ezzel nem távolítod el a csoportból.

![A csoport címzettjeinek kibontott névlistája, minden név mellett eltávolítási gombbal](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

<a id="invite-guests-or-experts"></a>

### Adj hozzá embereket név vagy e-mail-cím alapján

Beírhatod valakinek a nevét, és kiválaszthatod a javaslatok közül, vagy megadhatsz egy e-mail-címet, hogy új embert hívj meg. Ugyanahhoz a meghívóhoz több embert is hozzáadhatsz.

![Egy csoporttagnak és egy e-mail-címmel megadott vendégnek címzett meghívó, küldésre kész üzenettel](proposal_invite_guest.png)

A vendégek hozzáférést kapnak ehhez a szavazáshoz. Ha a szavazás egy szálban található, a szálat és annak hozzászólásait is elolvashatják. A meghívó nem jogosítja fel őket arra, hogy hozzászóljanak a szálhoz, szavazzanak a szál más szavazásaiban, vagy lássák a csoport többi szálát.

<!-- translation-section: send-the-invitations -->

### Küldd el a meghívókat

Írj egy üzenetet arról, hogy miben kéred az emberek döntését, majd válaszd a **Meghív** lehetőséget. Hagyd bejelölve az **Értesítések küldése** jelölőnégyzetet, hogy a meghívottak értesítést kapjanak. Töröld a jelölést, ha értesítés küldése nélkül szeretnél szavazókat hozzáadni.

Időzített szavazásnál válaszd a **Szavazók hozzáadása** lehetőséget. Az emberek akkor kapják meg a meghívójukat, amikor megnyílik a szavazás.

<!-- translation-section: engage-people-while-a-poll-is-running -->

<a id="engage-people-while-a-poll-is-running"></a>

## Az emberek meghívása után

<!-- translation-section: add-voters-to-the-poll -->

### Adj hozzá további szavazókat

Bármikor újra megnyithatod a **Szavazók kezelése** ablakot, hogy embereket adj hozzá, akár egy időzített szavazás megnyitása előtt is. Az ablak a meglévő szavazókat is felsorolja, a legutóbb hozzáadott emberekkel az élen. Írj be egy nevet, hogy megtalálj valakit, vagy használd a lapozógombokat egy hosszabb lista böngészéséhez.

<!-- translation-section: remove-people-from-the-poll -->

### Távolíts el embereket a szavazásból

Válaszd ki az illető melletti kuka gombot, majd erősítsd meg az eltávolítást a **Szavazó eltávolítása** lehetőséggel, hogy megvond a szavazati jogát ebben a szavazásban. Például egy vezetőségi szavazást létrehozó személy eltávolíthatja saját magát, ha nem jogosult szavazni.

![A Szavazók kezelése ablak a meglévő szavazókkal, az egyik szavazó kuka gombja kiemelve](proposal_invite_remove.png)

Névtelen szavazásból nem lehet embereket eltávolítani. A [szavazati súlyokat](/en/user_manual/polls/weighted_voting) használó szavazásoknál a szál adminjai itt át is tekinthetik és módosíthatják a súlyokat.

<!-- translation-section: remind-people-to-vote -->

### Emlékeztesd az embereket a szavazásra

Válaszd az **Emlékeztet** lehetőséget a szavazásnál, válaszd ki, kik kapják meg az emlékeztetőt, írj egy üzenetet, majd válaszd az **Emlékeztet** lehetőséget az elküldéséhez. Az **Akik még nem szavaztak** lehetőséggel azokat érheted el, akiknek a válaszára még szükség van.

![Emlékeztető azoknak címezve, akik még nem szavaztak, a döntési határidőről szóló üzenettel](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### Tekintsd meg az értesítési előzményeket

Nyisd meg a szavazás hárompontos menüjét (**⋯**), és válaszd az **Értesítési előzmények** lehetőséget. Itt láthatod, kit hívtak meg, mikor küldték el az egyes meghívókat, és elolvasták-e őket, ha ez az információ rendelkezésre áll.

![Értesítési előzmények egy szavazási meghívó címzettjeivel](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### Lezárás most

Válaszd a **Lezárás most** lehetőséget, ha már mindenki szavazott, vagy a szavazásnak már nem kell nyitva maradnia.

<!-- translation-section: reopen -->

### Újranyitás

Egy lezárt szavazásnál válaszd az **Újranyit** lehetőséget, majd állíts be új záró dátumot és időpontot. Azokat a szavazásokat, amelyek a szavazás lezárásáig elrejtik az eredményeket, beleértve a névtelen szavazásokat is, nem lehet újranyitni; amíg nyitva vannak, meghosszabbíthatod a szavazási időt.
