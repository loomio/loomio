---
title: 匿名投票
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: c3fc10128329bf45
  how-anonymous-voting-protects-voters: be1b674aea1a8396
  while-voting-is-open: 531ef27743664e75
  votes-cannot-be-changed: 231a780179405c4d
  why-anonymous-votes-do-not-have-reasons: d624c1128f7b83f9
  results-and-exports: '096efcd7adb1b6d7'
  participation-verification: ec7879d6307b3ca6
  reminders: ea39ed16fd1324d2
  what-coordinators-and-administrators-can-see: 9d0279678c8ac9de
  limits-of-anonymous-voting: be4ba7641345786d
  questions: 883d548ca99120b0
  can-a-coordinator-see-how-i-voted: c0916356f9ee51ea
  can-i-see-my-vote-after-submitting-it: 617b31fcffd1b8e4
  can-i-change-or-withdraw-my-vote: 37a1395214ac972c
  will-i-receive-an-email-confirming-my-vote: 9f77559256bfe6b5
  does-a-public-poll-reveal-more-information: 9754d85f71ac46f7
  is-anonymous-voting-suitable-for-every-election: 8e201f1aaadb333c
title_source: 1bc4567506ad4d51
title_generated: 55edffe99178b192
---

<!-- translation-section: introduction -->

# 匿名投票

匿名投票は、ブラインド投票とも呼ばれ、誰が投票したかという記録と投票そのものを分離します。アンケートが締め切られた後は、結果を閲覧できる人なら誰でも、誰が参加したかを確認できますが、Loomioを利用する人は誰も、投票を投票した人と結び付けることができません。

このページでは、匿名投票の仕組み、保持される情報、この保護の限界について説明します。

<!-- translation-section: how-anonymous-voting-protects-voters -->

## 匿名投票で投票者を保護する仕組み

匿名アンケートでは、次の2種類の記録を別々に保持します。

| 参加記録 | 送信された投票 |
| --- | --- |
| 投票資格がある人 | 選択された選択肢やスコア |
| 招待された人と招待した人 | 投票が属するアンケート |
| 投票資格がある各人の投票の有無 | 氏名やユーザーアカウントは含まれません |
| 選択された選択肢やスコアは含まれません | 参加記録との関連付けはありません |

これらの記録を結び付ける共通のIDはありません。送信された投票には、送信時刻、招待の詳細、投票理由、添付ファイル、投票者の特定につながるその他のメタデータも含まれません。

この分離は、投票を保存する時点で行われます。画面上で氏名を隠すことだけに依存するものではありません。

<!-- translation-section: while-voting-is-open -->

## 投票受付中

アンケートが締め切られるまで、結果は誰にも表示されません。スレッド管理者、グループ管理者、インスタンス管理者も同様です。

投票すると、次の処理が行われます。

- 投票は、氏名や参加記録と結び付けずに保存されます。
- 参加記録に投票済みであることが記録されます。
- 投票イベント、通知、メール、コメント、アクティビティの記録は作成されません。
- 送信後に選択内容のコピーが返されることはありません。
- 画面には、投票が記録されたことだけが表示されます。

参加記録には、その人が投票した正確な時刻は保存されません。送信された投票は、送信時刻順には並べられません。

<!-- translation-section: votes-cannot-be-changed -->

## 投票は変更できません

投票資格がある人は、それぞれ1回投票できます。送信された匿名の投票は、管理者であっても、確認、変更、撤回、差し替えができません。

投票した人が自分の投票を取得したり差し替えたりするには、その人と投票を結び付ける必要があります。匿名投票では、そのような関連付けを意図的に作成しません。

送信前に、選択内容を十分に確認してください。

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## 匿名の投票に理由を付けられない理由

匿名の投票には、投票理由や添付ファイルを含めることができません。理由には、氏名、個人情報、文章の特徴、メンションなど、投票者を特定する情報が含まれる可能性があり、結果の中から個々の投票を区別しやすくなることがあります。

参加者は引き続きアンケートのスレッドで話し合うことができます。これらのコメントは、通常の氏名付きの投稿であり、匿名の投票には関連付けられません。

<!-- translation-section: results-and-exports -->

## 結果とエクスポート

アンケートが締め切られると、Loomioは参加記録から分離された投票を基に結果を計算し、そのアンケートの種類に応じた集計結果を表示します。

Loomioは、投票のID、送信順序、送信時刻を公開しません。アンケートのエクスポートには、投票ごとの行ではなく、集計結果のみが含まれます。唯一の例外は、締め切り済みのSTV選挙で、再集計のためにBLT形式でエクスポートできます。BLT形式のエクスポートには候補者の順位が記載され、同じ順位の票が複数ある場合はまとめられます。投票者の識別情報や票のメタデータは含まれません。

匿名アンケートは、締め切り後に再開できません。

<!-- translation-section: participation-verification -->

## 参加した人

匿名アンケートが締め切られた後は、結果を閲覧できる人なら誰でも、誰が参加したかを確認できます。投票受付中は、誰もこの情報を確認できません。

**投票を見る**を選択すると、一覧が表示されます。投票資格があった人は常に表示されます。誰がどのように投票したか、いつ投票したかは、一覧には表示されません。各人が投票したかどうかは、十分な人数が投票した場合にのみ表示されます。必要な票数は、定足数が設定されている場合はその定足数以上、設定されていない場合は投票資格がある人の半数以上です。いずれの場合も、最低3票が必要です。

グループのメンバーとアンケートの投票者は、各人がグループに参加した時期と、誰が招待したかも確認できます。グループ管理者は、同姓同名の人を区別できるように、メールアドレスも確認できます。

結果を閲覧できる人は誰でも、誰が投票したかを確認できるため、結果が一方に偏っていると、各人の投票内容が分かる場合があります。たとえば、すべての票が「賛成」であれば、投票した全員が賛成したことになります。

管理者は、投票受付中であれば、他の人が投票した後でも、投票資格がある人を追加できます。匿名アンケートから既存の投票者を削除することはできません。

<!-- translation-section: reminders -->

## リマインダー

投票期間が24時間以上の匿名アンケートでは、投票資格がある未投票の人に、締め切りまでの最後の24時間以内に自動リマインダーが1回送信されます。

Loomioは、送信された投票を確認せず、参加記録だけを基に送信対象を選びます。

投票期間が24時間未満のアンケートでは、この自動リマインダーは送信されません。

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## 管理者が確認できる情報

スレッド管理者、グループ管理者、インスタンス管理者は、アプリケーションを通じて次の情報を確認できる場合があります。

- アンケートと、投票資格がある人
- 役割に応じた閲覧権限があり、十分な人数が投票した場合の、投票資格がある各人の投票の有無
- アンケートが締め切られた後の集計結果

アプリケーションの機能を使って、次の情報を確認することはできません。

- どの選択内容が誰のものか
- 個々の投票や投票の傾向
- 特定の投票が送信された時刻
- 投票に関連付けられた投票理由、添付ファイル、イベント、通知

<!-- translation-section: limits-of-anonymous-voting -->

## 匿名投票の限界

匿名投票により、Loomioの利用者は、投票を投票者と結び付けることができません。ただし、データベース、バックアップ、サーバーログ、プロセスメモリ、ネットワーク通信、改変されたコードを調べられるサーバー運用者に対する、暗号技術による保護ではありません。

結果そのものが手がかりになる場合もあります。グループが小さい場合、投票が全会一致の場合、選択内容の組み合わせに特徴がある場合、アンケート外でコメントが共有されている場合は、個人の投票内容を推測しやすくなることがあります。

アプリケーションレベルの匿名投票を利用する際は、グループの規模と決定の機密性を考慮してください。

<!-- translation-section: questions -->

## 質問

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### 自分の投票内容を誰かが見ることはできますか？

いいえ。Loomioを利用する人は誰も、投票を投票した人と結び付けることができません。十分な人数が投票すると、結果を閲覧できる人なら誰でも、参加したかどうかを確認できます。その人数に達するまでは、投票したかどうかも表示されません。

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### 送信後に自分の投票を確認できますか？

いいえ。Loomioは投票が記録されたことを表示し、画面から選択内容を消去します。投票を取得するには、投票者と投票の間に関連付けを作る必要がありますが、匿名投票ではこの関連付けを作らない設計になっています。

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### 自分の投票を変更したり、取り消したりできますか？

いいえ。投票者と投票の間に関連付けがないため、Loomioは変更または削除する投票を特定できません。

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### 投票の確認メールは届きますか？

いいえ。投票すると、画面上に確認が表示され、参加記録が更新されるだけです。メールの送信や、通知・アクティビティ記録の作成は行われません。

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### 公開アンケートでは、より多くの情報が公開されますか？

公開アンケートが締め切られると、誰でも結果と参加者を確認できます。個々の投票や、グループへの参加と招待の詳細は確認できません。

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### 匿名投票はすべての選挙に適していますか？

いいえ。匿名投票は、アプリケーション上で投票者と投票を分離します。サーバー運用者からの保護や、暗号技術による独立した検証が必要な選挙には、それらの要件を満たすように設計されたシステムが必要です。
