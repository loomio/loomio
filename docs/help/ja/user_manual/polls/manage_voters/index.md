---
title: 有権者の管理
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
  introduction: b7795b7385836c84
  invite-people-to-vote-in-a-poll: 1293f18a7b4882cb
  invite-guests-or-experts: 4ed19aac084705c5
  engage-people-while-a-poll-is-running: b9e5c8c5c6a8247b
  add-voters-to-the-poll: 1cb76908f4c3c2f8
  remove-people-from-the-poll: 251b2c3e26d802b7
  remind-people-to-vote: e82494f287e28233
  view-notification-history: e065424d8ad29e4a
  close-early: 701e0de243a1162e
  reopen: 76ab0000750ed570
  choose-an-audience: 18550912fd7ea79d
  check-your-recipients: 71ccc641e3d51539
  send-the-invitations: e0c676d51cf8b069
title_source: 10858faa0464257e
title_generated: ecbb5e3fb9bc7db0
---

<!-- translation-section: introduction -->

# 有権者の管理

**有権者の管理**で投票する権限を付与し、提案やアンケートへの参加を招待します。

<!-- translation-section: invite-people-to-vote-in-a-poll -->

<a id="invite-people-to-vote-in-a-poll"></a>
<a id="add-voters-to-the-poll"></a>

## 投票に招待する

**選ばれた人のみ**でアンケートを開始すると、**有権者の管理**ウィンドウが開きます。アンケートで**有権者の管理**を選択して開くこともできます。

![アンケートの下部にある「有権者の管理」ボタン](proposal_after_start.png)

<!-- translation-section: choose-an-audience -->

### 招待先を選択する

空の**有権者を探す、または招待する**欄をクリックすると、候補が次の順序で表示されます。

- 所属するグループ
- グループに[委任された投票者](/en/user_manual/groups/delegated_voters)がいる場合は、そのグループの**代表者**
- SlackやMicrosoft Teamsなどの接続されたチャットルーム
- サブグループと親グループ
- 個々のメンバー

[ダイレクトスレッド](/en/user_manual/discussions/direct_discussions)では、グループの代わりに**スレッド内の全員**が候補に表示されます。

![グループ、その代表者、チャットルーム、サブグループの候補が表示された「有権者の管理」ウィンドウ](proposal_invite.png)

<a id="invite-a-subgroup-to-vote"></a>

招待先を選択すると、そこに含まれる人をまとめて招待できます。例えば、**Oatmilk Cooperative**を選択すると、そのグループの人が含まれます。接続されたチャットルームを選択して、そこに招待を投稿することもできます。チャットルームに投稿しても、そのメンバーは投票者として追加されません。

<!-- translation-section: check-your-recipients -->

### 招待に含まれる人を確認する

招待先を選択すると、その名前と含まれる人数が欄に表示されます。招待を送信する前に、この人数を確認します。

![Oatmilk Cooperativeが選択され、欄の下に招待先の人数が表示されている状態](proposal_invite_members.png)

招待先の名前をクリックすると、個々の人の一覧が展開されます。名前の横にある**×**を選択すると、その人を今回の招待から除外できます。グループから削除されることはありません。

![グループの招待先を展開した状態。各人の名前と削除ボタンが表示されています](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

<a id="invite-guests-or-experts"></a>

### 名前やメールアドレスで追加する

名前を入力して候補から選択したり、メールアドレスを入力して新しい人を招待したりすることもできます。同じ招待に複数の人を追加できます。

![グループメンバーとメールアドレスで指定したゲストを宛先にし、送信するメッセージを入力した招待](proposal_invite_guest.png)

ゲストには、このアンケートにアクセスする権限が付与されます。アンケートがスレッド内にある場合は、そのスレッドとコメントも閲覧できます。この招待では、スレッドへのコメントの投稿、スレッド内の他のアンケートへの投票、グループ内の他のスレッドの閲覧は許可されません。

<!-- translation-section: send-the-invitations -->

### 招待を送信する

何を決めてもらうのかを説明するメッセージを追加し、**招待する**を選択します。招待する人に通知するには、**通知を送信する**にチェックを入れたままにします。通知を送信せずに投票者を追加するには、チェックを外します。

開始日時が設定されたアンケートでは、**投票者を追加**を選択します。投票が始まると、招待が届きます。

<!-- translation-section: engage-people-while-a-poll-is-running -->

<a id="engage-people-while-a-poll-is-running"></a>

## 招待後の操作

<!-- translation-section: add-voters-to-the-poll -->

### 投票者を追加する

**有権者の管理**を再び開くと、いつでも人を追加できます。開始日時が設定されたアンケートでは、投票の開始前にも追加できます。このウィンドウには、既存の投票者も最近追加された人から順に表示されます。名前を入力して人を探したり、一覧が長い場合はページ切り替えの操作で確認したりできます。

<!-- translation-section: remove-people-from-the-poll -->

### アンケートから人を削除する

名前の横にあるごみ箱ボタンを選択し、**有権者を削除する**を確認すると、その人がこのアンケートで投票する権限を取り消せます。例えば、理事会の投票を準備する人は、自分に投票する権限がない場合、自分自身を削除できます。

![既存の投票者が表示され、投票者のごみ箱ボタンが強調された「有権者の管理」ウィンドウ](proposal_invite_remove.png)

匿名のアンケートから人を削除することはできません。[票の重み](/en/user_manual/polls/weighted_voting)を使用するアンケートでは、スレッド管理者がここで重みを確認・編集することもできます。

<!-- translation-section: remind-people-to-vote -->

### 投票を促す通知を送る

アンケートで**思い出させる**を選択し、通知先を選んでメッセージを追加した後、**思い出させる**を選択して送信します。**未投票の人**を選択すると、まだ回答が必要な人に通知できます。

![未投票の人を宛先にし、決定の期限についてのメッセージを添えた通知](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### 通知履歴を確認する

アンケートの三点メニュー（**⋯**）を開き、**通知履歴**を選択すると、招待された人と各招待の送信日時を確認できます。既読情報を取得できる場合は、招待が読まれたかどうかも確認できます。

![アンケートの招待先が表示された通知履歴](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### 早めに締め切る

全員が投票を終えた場合や、投票の受付を続ける必要がなくなった場合は、**早めに締め切る**を選択します。

<!-- translation-section: reopen -->

### 再開

締め切り済みのアンケートで**再開**を選択し、新しい締め切り日時を設定します。匿名のアンケートを含め、投票が締め切られるまで結果を非表示にするアンケートは再開できません。締め切り前であれば、締め切り日時を延長できます。
