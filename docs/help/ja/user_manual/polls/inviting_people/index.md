---
title: 投票に招待する
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/inviting_people/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0635cf23fcaaa95b
  invite-people-to-vote-in-a-poll: cfbf5caf71d1d5ca
  invite-guests-or-experts: 0717537bbd36fa07
  invite-a-subgroup-to-vote: 3ac684bdca4b3365
  engage-people-while-a-poll-is-running: 69971de8d56c0a74
  add-voters-to-the-poll: 48f3b4a1edb5a037
  remove-people-from-the-poll: ceec3f0319728807
  remind-people-to-vote: 177c881cb1b0dfb9
  view-notification-history: 52d930341c048008
  close-early: 0c46e8066719fc2f
  reopen: 9575383179a411cc
generated:
  introduction: 8f87b6e6b3e25a97
  invite-people-to-vote-in-a-poll: a6fc7e7b0ae4a0d6
  invite-guests-or-experts: 6c080c03679fdb46
  invite-a-subgroup-to-vote: 6f3228f1d5dab373
  engage-people-while-a-poll-is-running: eef79ac1d5980464
  add-voters-to-the-poll: ae6b8b389ce12125
  remove-people-from-the-poll: 31a3fca1759f8209
  remind-people-to-vote: 862645ba318945ab
  view-notification-history: 3d57fe3583c72c7a
  close-early: 3bf9b98777d391b8
  reopen: 3f0b0b428f2f79ae
title_source: 4801d1a3dba7ce3d
title_generated: '010598b1d68b0563'
---

<!-- translation-section: introduction -->

# 投票に招待する

<!-- translation-section: invite-people-to-vote-in-a-poll -->

## アンケートへの投票に招待する

通知を送信して、アンケートへの投票に招待します。

アンケートを開始すると、**投票に招待する**ボックスが表示されます。**スレッド内の全員**やグループなどの招待先を選択するか、個人の名前やメールアドレスを入力します。

![](proposal_invite.png)

招待には任意でメッセージを添えることができます。

![](proposal_invite_members.png)

グループのチップを選択すると、招待する人の一覧が展開されます。名前の横にある x を選択すると、その人を招待先から除外できます。

![](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

### ゲストや専門家を招待する

メールアドレスを入力して、ゲストをアンケートに招待することもできます。ゲストには、このアンケートにのみ参加する権限が付与されます。

アンケートがスレッド内にある場合、ゲストはそのスレッドとコメントも閲覧できます。ただし、コメントの投稿、スレッド内の他のアンケートへの参加、グループ内の他のスレッドの閲覧はできません。

![](proposal_invite_guest.png)

<!-- translation-section: invite-a-subgroup-to-vote -->

### サブグループを投票に招待する

投票できる人を招待された人に限定するには、アンケートの作成時に**選ばれた人のみ**を選択します。その後、親グループ内のサブグループを招待できます。[投票者の委任](/en/user_manual/groups/delegated_voters/)も参照してください。

![招待された人のみを選択する](invited-people-only.png)
![サブグループを投票に招待する](invite-voters-subgroup.png)

<!-- translation-section: engage-people-while-a-poll-is-running -->

## アンケートの実施中に参加を促す

アンケートの下部には、アンケートの実施中に参加を促すための機能がいくつかあります。

![](proposal_after_start.png)

<!-- translation-section: add-voters-to-the-poll -->

### アンケートに投票者を追加する

アンケートにはいつでも新しい人を追加できます。開始日時が設定されたアンケートでは、投票の開始前にも追加できます。

**有権者の管理**を選択すると、投票者の管理ウィンドウが開きます。グループ内の全員を招待したり、名前でメンバーを追加したりできます。ゲストの招待が許可されている場合は、メールアドレスでゲストを追加することもできます。**有権者を探す、または招待する**に入力すると、アンケートにすでに追加されている人も絞り込まれます。最近追加された投票者から順に表示されます。ページ切り替えの操作で一覧全体を確認できます。

アンケートに開始日時が設定されていて、投票がまだ始まっていない場合、投票者にはすぐに通知は送信されません。投票が始まると通知されます。

<!-- translation-section: remove-people-from-the-poll -->

### アンケートから人を削除する

**有権者の管理**を選択し、投票者管理ウィンドウで対象者の名前を探します。名前の横にあるごみ箱ボタンを選択し、**有権者を削除する**を確認します。

![投票者管理ウィンドウの投票者の横にあるごみ箱ボタン](proposal_invite_remove.png)

匿名のアンケートから人を削除することはできません。

例えば、理事会のメンバーに代わってアンケートを作成した管理者は、自分に投票する権限がない場合、自分自身を削除できます。

票の重みを使用するアンケートでは、アンケートのコーディネーターが同じウィンドウで[票の重みを確認・編集](/en/user_manual/polls/weighted_voting)できます。

<!-- translation-section: remind-people-to-vote -->

### 投票を促す通知を送る

**思い出させる**を選択すると、まだ投票していない人に通知を送信できます。初期設定では、**投票に招待された全員**が選択されています。チップを選択すると、通知先を確認または変更できます。

![](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### 通知履歴を確認する

アンケートの下部にある三点メニュー（**⋯**）を開き、**通知履歴**を選択します。

![アンケートの操作メニューにある通知履歴](../../discussions/notifying_people/poll_notification_history.png)

履歴には、投票に招待された人と各招待の送信日時が表示されます。既読情報を取得できる場合は、招待が読まれたかどうかも表示されます。

![アンケートの通知履歴](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### 早めに締め切る

**早めに締め切る**を選択すると、予定された締め切り日時より前にアンケートを締め切ることができます。

全員が投票を終えた場合や、投票の受付を続ける必要がなくなった場合などに使用できます。

![](proposal_close_early.png)

<!-- translation-section: reopen -->

### 再開する

締め切り済みのアンケートで**再開**を選択し、新しい締め切り日時を設定します。

匿名のアンケートは再開できません。

![](proposal_reopen.png)
