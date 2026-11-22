---
title: 設定
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/settings/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 4dfc411e9ec40783
  setting-up-a-proposal-or-poll: 9e0347d976f79179
  proposal-and-poll-templates: 822e5f4ed69852ee
  add-content: 6811509f271e7050
  voting-options: 28968995d558db8f
  edit-voting-options: 692bc37a97a0eea6
  opening-time: e9a9ca1825565db3
  more-settings: 6a7cd5bb6e0a9271
  reminder: 673e6181f026afe0
  anonymous-voting: 70e89af6ff170bc8
  vote-reason: 8f5d05ee4f950079
  hide-results: a59502626d4b75c6
  managing-polls: b26fc41e19371d54
  edit-poll: d544d21f39ce060f
  notification-history: f132def867659f30
  export-poll: d94d6cba846d9b25
  print: 8caef79f1356f7c4
  delete: 10850ca0cae15f77
  save-bookmark: 5415dd146c0190c1
  save-as-template: 2ddaebfb13ea40e4
  who-can-vote: c9cb72fec8cea6aa
  editing-settings-before-voting-opens: a3e52c6542c3eb4c
generated:
  introduction: 25c8c188e85958e3
  setting-up-a-proposal-or-poll: 16beec14d33069d9
  proposal-and-poll-templates: f638cffd6680b5cd
  add-content: 9bbddf9d095bd776
  voting-options: a6280c7ae7185339
  edit-voting-options: 6eede05ed0a2ef9f
  opening-time: 432f1cc695d836ef
  more-settings: cb78e189d55e48a0
  reminder: 0fc575f0a8c6f901
  anonymous-voting: 0ee0749ac46bea11
  vote-reason: f25479ba0da0a023
  hide-results: 657e46b90cd387b2
  managing-polls: 98a208666a4101b9
  edit-poll: e80319d4d38255bf
  notification-history: 9608d471484a177d
  export-poll: 202ae6457f1f89fe
  print: f6dbc1a1ebe1fdde
  delete: a85873702b322a5c
  save-bookmark: 4b1df16fd063bb65
  save-as-template: fd1bc747c1df3d0c
  who-can-vote: 968ea927d0063422
  editing-settings-before-voting-opens: 87a274ae9b068ac6
title_source: 74a883a037bc227f
title_generated: 0d8619aae051ae34
needs_review:
  vote-reason: use "選択肢" instead of "オプション" for "option"
---

<!-- translation-section: introduction -->

# 提案とアンケートの設定

提案やアンケートの動作、投票できる人、結果の表示方法を設定します。ほとんどの設定は、アンケートの作成時や編集時に利用できます。

<!-- translation-section: setting-up-a-proposal-or-poll -->

## 提案やアンケートの設定

<!-- translation-section: proposal-and-poll-templates -->

### 提案とアンケートのテンプレート

使用する提案やアンケートのテンプレートを選択します。

![](proposal_templates.png)

![タイトルと詳細、投票の選択肢、投票期間、投票できる人、折りたたまれた「その他の設定」パネルを含む提案フォーム](proposal_new.png)

<!-- translation-section: add-content -->

<a id="add-content"></a>

### タイトルと詳細

- **グループ:** 提案やアンケートに適切なグループが選択されていることを確認します。
- **タイトル:** 提案やアンケートに短く明確なタイトルを付けます。
- **詳細:** 参加者に何を決めてもらうのか、提案が採択された場合にどうなるのかを説明します。

テンプレートには、そのまま使うことも書き換えることもできる、記入のヒントが含まれています。[書式設定ツール](/en/user_manual/discussions/formatting)を使って、ファイルの添付、画像や表の挿入、見出しやリストの追加ができます。補足情報を共有し、長い提案を読みやすくできます。

<!-- translation-section: voting-options -->

### 投票の選択肢

各テンプレートには、初期設定の投票の選択肢が用意されています。テンプレートに応じて、意思決定の方法に合わせて選択肢を編集、削除、並べ替え、追加できます。

- 鉛筆のアイコンを選択して、投票の選択肢を編集します。
- ごみ箱のアイコンを選択して、投票の選択肢を削除します。
- ハンドルをドラッグして、投票の選択肢の順序を変更します。
- テンプレートで独自の選択肢を追加できる場合は、**選択肢を追加**を選択して投票の選択肢を追加します。

![](vote_options.png)

<!-- translation-section: edit-voting-options -->

### 投票の選択肢の編集

投票の選択肢の横にある鉛筆のアイコンを選択して、編集します。

- **選択肢の名前:** 選択肢を表す短い名前です。
- **アイコン:** 親指を上げる、親指を下げる、棄権、ブロックなど、選択肢を表すアイコンです。
- **意味:** この選択肢を選ぶことの意味を説明する文です。
- **理由を尋ねる質問:** 投票者に選んだ理由の説明を促す質問です。

![](proposal_edit_option.png)

<!-- translation-section: opening-time -->

### 投票期間

初期設定では、アンケートを開始するとすぐに投票が開始されます。後で投票を開始するように予約する場合は、**投票はすぐに開始されます**のチェックを外し、開始日時を選択します。

予約すると、投票開始前にディスカッションの時間を設けたり、事前にアンケートを準備して投票者を追加したりできます。予約されたアンケートは開始前でも閲覧できますが、開始時刻までは投票できません。投票者には、追加された時点ではなく、投票開始時に通知が届きます。

予定時刻より前に投票を開始するには、**投票の編集**を選択し、**投票はすぐに開始されます**にチェックを入れて保存します。

- **アンケート開始時に投票者に通知:** 初期設定ではチェックが入っており、投票開始時にすべての投票者に通知が届きます。通知を送らずに投票を開始する場合は、チェックを外します。
- **締め切り日時:** 投票を締め切る日時を選択します。投票に十分な時間を確保します。例えば、会議の前に締め切るようにしたり、週末の締め切りを避けたりすると、適切なタイミングでリマインダーが届きます。アンケートの受付中は、早めに締め切ったり、締め切り日時を延長したりできます。

<!-- translation-section: who-can-vote -->

### 誰が投票できますか？

アンケートに投票できる人を選択します。

- **グループ内の誰でも**（または**スレッド内の誰でも**）: 後から参加する人も含め、アンケートにアクセスできる全員が投票できます。
- **選ばれた人のみ:** 追加した人だけが投票できます。理事会や委員会など、一部のメンバーだけが投票する場合に使用します。

**選ばれた人のみ**のアンケートを開始すると、**有権者の管理**が開き、投票者を追加できます。投票者は後から追加または削除できます。[投票者の管理](/en/user_manual/polls/manage_voters)を参照してください。

<!-- translation-section: more-settings -->

## その他の設定

**その他の設定**を開くと、リマインダー、匿名投票、投票の理由、結果の表示、[定足数](/en/user_manual/polls/quorum/)、[加重投票](/en/user_manual/polls/weighted_voting/)、**選択肢をランダムな順序で表示する**を設定できます。選択肢のランダム表示は、選択、スコア、配分、ランクのアンケートで利用でき、表示順による偏りを減らします。

![](settings_advanced.png)

<!-- translation-section: reminder -->

### リマインダー

アンケートの締め切り24時間前に「まもなく締め切り」の通知を送信し、参加を促したり、投票内容を見直す機会を設けたりします。

通知先の選択肢：

- 誰にも通知しない
- 作成者
- 未投票の人（初期設定）
- すべての投票者

投票期間が24時間以上の匿名アンケートでは、投票資格があり、まだ投票していない人に、締め切りまでの最後の24時間にLoomioが自動でリマインダーを送信します。このリマインダーはアンケートの設定では変更できません。

<!-- translation-section: anonymous-voting -->

### 匿名投票

有効にすると、Loomioは投票を投票者を特定する情報とは別に保存します。結果は投票が締め切られるまで非表示になり、投票者は理由の追加、送信済みの投票の確認、投票の変更ができません。

投票者を特定する情報と投票を分離する仕組み、保持される情報、保護の限界については、[匿名投票](/en/user_manual/polls/anonymous_voting)を参照してください。

> [!WARNING]
> 投票開始後は、匿名投票を有効または無効に変更できません。匿名のアンケートは、締め切り後に再開できません。

<!-- translation-section: vote-reason -->

### 投票の理由

投票者に、選んだ理由を説明するよう促します。利用できる設定はテンプレートによって異なります。

- **オプション:** 投票の理由を記入するかどうかを投票者が選べます。
- **反対またはブロックするには必須:** 反対またはブロックのアイコンを使用する選択肢を選んだ場合、理由の記入が必要です。
- **ブロックに必要:** ブロックのアイコンを使用する選択肢を選んだ場合、理由の記入が必要です。
- **必須:** すべての投票者に理由の記入が必要です。
- **無効:** 投票の理由の入力欄が表示されません。

![](vote_reason_options.png)

条件付きの設定は、選択肢の名前ではなく投票アイコンに基づいて適用されるため、「反対」の名前を「異議」に変更しても適用されます。同意テンプレートの初期設定は**反対またはブロックするには必須**で、コンセンサステンプレートの初期設定は**ブロックに必要**です。その他のテンプレートの初期設定は**オプション**です。アンケートの作成者は、アンケートごとにこの設定を変更できます。

**理由を最大500文字に制限する:** 投票の理由を簡潔にするため、初期設定ではチェックが入っています。長い理由を記入できるようにするには、チェックを外します。

<!-- translation-section: hide-results -->

### 結果を非表示にする

他の人の投票内容を見ずに投票できるように、アンケートの結果を非表示にします。

- **投票するまで:** 自分の投票を送信すると、各投票者が選んだ選択肢と投票の理由を確認できます。
- **投票が締め切られるまで:** アンケートが締め切られるまで、結果、投票への返信、投票の理由に含まれるメンションが非表示になります。アンケートの受付中は締め切り日時を延長できますが、締め切り後は再開できません。

<!-- translation-section: editing-settings-before-voting-opens -->

### 投票開始前の設定の編集

アンケートを編集する権限を持つ人は、投票開始前であれば、匿名投票や結果の表示設定を含む詳細と設定を変更できます。投票が始まると匿名設定は変更できなくなり、締め切りまで非表示にする設定の結果を早めに公開することもできません。

<!-- translation-section: managing-polls -->

## アンケートの管理

アンケートの右下にある三点メニューを開きます。

![](proposal_edit.png)

<!-- translation-section: edit-poll -->

### アンケートの編集

**投票の編集**を選択すると、アンケートの内容や設定を変更できます。

<!-- translation-section: save-as-template -->

### テンプレートとして保存

**テンプレートとして保存**を選択すると、アンケートの内容、投票の選択肢、説明、設定を再利用できます。あらかじめ入力されたフォームを確認し、テンプレートの名前とサブタイトルを入力して、**テンプレートを保存**を選択します。グループのメンバーは、新しいアンケートを開始する際にこのテンプレートを選択できるようになります。

グループ管理者はテンプレートを保存できます。グループの権限設定で**メンバーはテンプレートを作成できます**が有効になっている場合は、メンバーも保存できます。詳しくは、[アンケートのテンプレート](/en/user_manual/polls/poll_templates)をご覧ください。

<!-- translation-section: notification-history -->

### 通知履歴

**通知履歴**には、通知を受けた人と、各通知が既読になっているかどうかが表示されます。

![](proposal_notification_history.png)

<!-- translation-section: export-poll -->

### アンケートのエクスポート

**輸出**を選択すると、分析や保存のために、アンケートの状況と結果をスプレッドシート（.csv）ファイルとしてダウンロードできます。

<!-- translation-section: print -->

### 印刷

スレッドの三点メニューを開き、**印刷する**を選択すると、ディスカッションとそのアンケートを印刷用のHTML形式で表示できます。印刷したり、公開や保存のためにPDFとして保存したりできます。

![](proposal_print.png#width-80)

<!-- translation-section: delete -->

### 削除

**消去**を選択して確認すると、アンケートが完全に削除されます。削除したアンケートは復元できません。スレッドには**アイテムが削除されました**という表示が残ります。

![](proposal_delete.png)

<!-- translation-section: save-bookmark -->

### ブックマークを保存

**ブックマークを保存**を選択してアンケートをブックマークに追加すると、後からすぐに開けます。
