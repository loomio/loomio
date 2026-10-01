---
title: 投票に招待する
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  invite-people-to-vote-in-a-poll: 471461be604dcb34
  invite-guests-or-experts: 3a4d29c72de63aac
  invite-a-subgroup-to-vote: 0b3c443cdeeee2c1
  engage-people-while-a-poll-is-running: acfd2f7fc38b5c0b
  add-voters-to-the-poll: c4a79e34617328aa
  remove-people-from-the-poll: 2f622b69bdff20a7
  remind-people-to-vote: b876d786afe0a889
  view-notification-history: 5f6e611b2f40b54d
  close-early: 7479d08f28c8e65d
  reopen: 8dc14f8a886e8b4a
title_source: 4801d1a3dba7ce3d
title_generated: '010598b1d68b0563'
---

<!-- translation-section: introduction -->

# 投票に招待する

<!-- translation-section: invite-people-to-vote-in-a-poll -->

## 投票への参加を呼びかける

通知を送って、投票に招待できます。

投票を開始すると、**投票に招待する**欄が表示されます。**スレッド内の全員**やグループを選ぶか、招待する人の名前やメールアドレスを入力します。

![](proposal_invite.png)

招待にはメッセージを添えることもできます。

![](proposal_invite_members.png)

グループのチップを選ぶと、招待する人の一覧が表示されます。招待から外すには、名前の横にある x を選びます。

![](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

### ゲストや専門家を招待する

メールアドレスを入力して、ゲストを投票に招待することもできます。ゲストには、この投票にのみ参加する権限が与えられます。

投票がスレッド内にある場合、ゲストはそのスレッドとコメントも閲覧できます。ただし、コメントの投稿、スレッド内のほかの投票への参加、グループ内のほかのスレッドの閲覧はできません。

![](proposal_invite_guest.png)

<!-- translation-section: invite-a-subgroup-to-vote -->

### サブグループを投票に招待する

招待された人だけが投票できるようにするには、投票の作成時に**選ばれた人のみ**を選びます。その後、親グループ内のサブグループを招待できます。[代理投票者](/en/user_manual/groups/delegated_voters/)も参照してください。

![招待された人のみを選択](invited-people-only.png)
![サブグループを投票に招待](invite-voters-subgroup.png)

<!-- translation-section: engage-people-while-a-poll-is-running -->

## 投票中に参加を促す

投票の下部には、投票中に参加を促すための機能があります。

![](proposal_after_start.png)

<!-- translation-section: add-voters-to-the-poll -->

### 投票者を追加する

新しい投票者はいつでも追加できます。開始日時を設定した投票では、投票開始前にも追加できます。

**有権者の管理**を選ぶと、有権者の管理画面が開きます。グループ内の全員を招待したり、名前でメンバーを追加したりできます。ゲストの招待が許可されている場合は、メールアドレスでゲストを追加することもできます。**有権者を探す、または招待する**に入力すると、すでに投票に参加している人も絞り込まれます。最近追加された投票者から順に表示されます。ページ切り替えの操作で一覧全体を確認できます。

開始日時が設定されていて、まだ投票が始まっていない場合、投票者にはすぐに通知は届きません。投票が始まると通知されます。

<!-- translation-section: remove-people-from-the-poll -->

### 投票から人を削除する

**有権者の管理**を選び、有権者の管理画面で対象者の名前を探します。名前の横にあるごみ箱ボタンを選び、**有権者を削除する**で確定します。

![有権者の管理画面で投票者の横にあるごみ箱ボタン](proposal_invite_remove.png)

匿名投票からは人を削除できません。

たとえば、理事会のメンバーに代わって投票を作成した管理者に投票権がない場合は、自分自身を削除できます。

投票の重みを使用する投票では、投票の管理者が同じ画面で[投票の重みを確認・編集](/en/user_manual/polls/weighted_voting)できます。

<!-- translation-section: remind-people-to-vote -->

### 投票を促す通知を送る

**思い出させる**を選ぶと、まだ投票していない人に通知を送れます。初期設定では**投票に招待された全員**が選ばれています。チップを選ぶと、送信先の確認や変更ができます。

![](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### 通知履歴を確認する

投票の下部にある三点メニュー（**⋯**）を開き、**通知履歴**を選びます。

![投票の操作メニューにある通知履歴](../../discussions/notifying_people/poll_notification_history.png)

通知履歴には、投票に招待された人、各招待の送信日時、確認できる場合は既読かどうかが表示されます。

![投票の通知履歴](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### 早めに閉める

**早めに閉める**を選ぶと、予定された終了時刻より前に投票を終了できます。

全員が投票を終えた場合や、投票を続ける必要がなくなった場合などに使えます。

![](proposal_close_early.png)

<!-- translation-section: reopen -->

### 再開する

終了した投票で**再開**を選び、新しい終了日時を設定します。

匿名投票は再開できません。

![](proposal_reopen.png)
