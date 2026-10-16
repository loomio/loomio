---
title: 匿名投票
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: df1cf938f21a4d2d
  how-anonymous-voting-protects-voters: 17f221ab45a10ad8
  while-voting-is-open: f789f6b19d3d7098
  votes-cannot-be-changed: c6fc31f7f7b6fe74
  why-anonymous-votes-do-not-have-reasons: 8fe54e4844111fb3
  results-and-exports: 2aca469868ba0b14
  participation-verification: 88397a0d7141c265
  reminders: 88a20342873efdfa
  what-coordinators-and-administrators-can-see: 9fc98a2f1238a713
  limits-of-anonymous-voting: ad34e02c831ef6b1
  questions: 883d548ca99120b0
  can-a-coordinator-see-how-i-voted: e2b193fa96d15c20
  can-i-see-my-vote-after-submitting-it: 7210167aa492ff02
  can-i-change-or-withdraw-my-vote: '0387e612b4dfc3ea'
  will-i-receive-an-email-confirming-my-vote: 39b2895bae07d643
  does-a-public-poll-reveal-more-information: 9754d85f71ac46f7
  is-anonymous-voting-suitable-for-every-election: 182483fac6c7640d
title_source: 1bc4567506ad4d51
title_generated: 55edffe99178b192
---

<!-- translation-section: introduction -->

# 匿名投票

匿名投票は、ブラインド投票とも呼ばれ、誰が投票したかという記録と投票そのものを分離します。アンケートが締め切られた後は、結果を閲覧できる人なら誰でも、誰が参加したかを確認できます。Loomioを利用する人は誰も、送信された投票を投票した人と結び付けることができません。

このページでは、匿名投票による保護、保持される情報、保証の限界について説明します。

<!-- translation-section: how-anonymous-voting-protects-voters -->

## 匿名投票で投票者を保護する仕組み

匿名アンケートでは、次の2種類の記録を別々に保持します。

| 参加記録 | 送信された投票 |
| --- | --- |
| 投票資格がある人 | 選択された選択肢やスコア |
| 招待された人と招待した人 | 投票が属するアンケート |
| 投票資格がある各人の投票の有無 | 氏名やユーザーアカウントは含まれません |
| 選択された選択肢やスコアは含まれません | 参加記録との関連付けはありません |

これらの記録を結び付ける共通の識別子はありません。送信された投票には、実際の送信時刻、招待情報、記述された理由、添付ファイル、投票者の特定につながるその他のメタデータも含まれません。

この分離は、投票を保存する時点で適用されます。画面上で氏名を隠すことだけに依存するものではありません。

<!-- translation-section: while-voting-is-open -->

## 投票受付中

アンケートが締め切られるまで、結果は誰にも表示されません。アプリケーションを利用するアンケートのコーディネーター、グループ管理者、インスタンス管理者も同様です。

投票すると、次の処理が行われます。

- 送信された投票は、氏名や参加記録と結び付けずに保存されます。
- 参加記録に投票済みであることが記録されます。
- 投票イベント、通知、メール、コメント、アクティビティの記録は作成されません。
- 送信後に選択内容のコピーが返されることはありません。
- 画面には、投票が記録されたことだけが表示されます。

参加記録には、その人が投票した正確な時刻は保存されません。送信された投票は、送信時刻順には並べられません。

<!-- translation-section: votes-cannot-be-changed -->

## 投票は変更できません

投票資格がある人は、それぞれ1回投票できます。送信された匿名の投票は、コーディネーターや管理者であっても、確認、変更、撤回、差し替えができません。

投票した人が自分の投票を取得したり差し替えたりするには、その人と投票を継続的に結び付ける必要があります。匿名投票では、そのような関連付けを意図的に作成しません。

送信前に、選択内容を十分に確認してください。

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## 匿名の投票に理由を付けられない理由

新しい匿名の投票には、理由の記述や添付ファイルを含めることができません。理由には、氏名、個人情報、文章の特徴、メンションなど、投票者を特定する情報が含まれる可能性があります。また、理由があると、集計結果の中から個々の投票を区別しやすくなります。

ディスカッションが利用できる場合、参加者は引き続きアンケートのスレッドで話し合うことができます。これらのコメントは、通常の氏名付きのディスカッションへの投稿であり、匿名の投票には関連付けられません。

<!-- translation-section: results-and-exports -->

## 結果とエクスポート

アンケートが締め切られると、参加記録から分離された投票を基に結果が計算され、合計や、そのアンケートの種類に対応したその他の集計結果として表示されます。

アプリケーションは、投票の識別子、送信順序、送信時刻を公開しません。アンケートのエクスポートには、匿名の投票ごとの行ではなく、集計結果が含まれます。ただし、締め切り済みのSTV選挙はBLT形式でエクスポートできます。BLT形式のエクスポートには、選挙の再集計に必要な候補者の順位が含まれ、同じ順位の票が複数ある場合はまとめられます。投票者の識別情報や票のメタデータは含まれません。

匿名アンケートは、締め切り後に再開できません。

<!-- translation-section: participation-verification -->

## 参加した人

匿名アンケートが締め切られた後は、結果を閲覧できる人なら誰でも、誰が参加したかを確認できます。投票受付中は、誰もこの情報を確認できません。

**投票を見る**を選択すると、一覧が表示されます。投票資格があった人は常に表示されます。各人が投票したかどうかは、十分な人数が投票した場合にのみ表示されます。必要な票数は、定足数が設定されている場合はその定足数、設定されていない場合は投票資格がある人の半数です。いずれの場合も、最低3票が必要です。誰がどのように投票したか、いつ投票したかは、一覧には表示されません。

グループのメンバーとアンケートの投票者は、各人がグループに参加した時期と、誰が招待したかも確認できます。グループ管理者は、同姓同名の人を区別できるように、メールアドレスも確認できます。

結果を閲覧できる人は誰でも、誰が投票したかを確認できるため、結果が一方に偏っていると、各人の投票内容が分かる場合があります。たとえば、すべての票が「賛成」であれば、投票した全員が賛成したことになります。

コーディネーターは、投票受付中であれば、他の人が投票した後でも、投票資格がある人を追加できます。匿名アンケートから既存の投票者を削除することはできません。

<!-- translation-section: reminders -->

## リマインダー

投票期間が24時間以上の匿名アンケートでは、投票資格があり、まだ投票していない人に、締め切りまでの最後の24時間以内に自動リマインダーが1回送信されます。

リマインダーの送信対象は、参加記録だけを基に選ばれます。送信された投票を調べたり、投票との関連付けを作成したりすることはありません。締め切りが変更された場合、1時間ごとのリマインダーチェックは現在の締め切りを使用します。アンケートごとに別途リマインダーの送信予定を保持することはありません。

投票期間全体が24時間未満のアンケートでは、この自動リマインダーは送信されません。

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## コーディネーターと管理者が確認できる情報

アンケートのコーディネーター、グループ管理者、インスタンス管理者は、アプリケーションを通じて次の情報を確認できる場合があります。

- アンケートと、投票資格がある人
- 役割に応じた閲覧権限があり、十分な人数が投票した場合の、投票資格がある各人の投票の有無
- アンケートが締め切られた後の集計結果

アプリケーションの機能を使って、次の情報を確認することはできません。

- どの選択内容が誰のものか
- 個々の投票や投票の傾向
- 特定の投票が送信された時刻
- 送信された投票に関連する理由、添付ファイル、イベント、通知

<!-- translation-section: limits-of-anonymous-voting -->

## 匿名投票の限界

これらの保護により、アプリケーションの利用者は、送信された投票を投票者と結び付けることができません。ただし、データベース、バックアップ、サーバーログ、プロセスメモリ、ネットワーク通信、改変されたアプリケーションを調べられる運用者に対する、暗号技術による保護ではありません。

結果そのものから情報が明らかになる場合もあります。投票資格がある人が少ない場合、結果が全会一致の場合、選択内容の組み合わせに特徴がある場合、アンケート外で情報が共有されている場合は、個人の選択を推測しやすくなることがあります。また、投票者が、送信した投票とは別のディスカッションで、自分の投票内容を明かすこともあります。

アプリケーションレベルの匿名投票が適切かどうかを判断する際は、投票資格がある人の人数と、決定の機密性を考慮してください。

<!-- translation-section: questions -->

## 質問

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### 自分の投票内容を誰かが見ることはできますか？

いいえ。十分な人数が投票すると、結果を閲覧できる人は、投票したかどうかを確認できます。アプリケーションを通じて、送信された投票を投票した人と結び付けることは、誰にもできません。それまでは、投票したかどうかも表示されません。

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### 送信後に自分の投票を確認できますか？

いいえ。アプリケーションは投票が記録されたことを確認した後、投票画面から選択内容を破棄します。投票を取得するには、投票者と投票の間に関連付けを作る必要がありますが、匿名投票ではこの関連付けを作らない設計になっています。

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### 自分の投票を変更したり、取り消したりできますか？

いいえ。投票者と投票の間に関連付けがないため、アプリケーションは変更または削除する投票を特定できません。

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### 投票の確認メールは届きますか？

いいえ。投票すると、画面上に確認が表示され、参加記録が更新されるだけです。確認メールの送信や、通知・アクティビティイベントの作成は行われません。

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### 公開アンケートでは、より多くの情報が公開されますか？

公開アンケートが締め切られると、誰でも結果と参加者を確認できます。個々の投票や、グループへの参加と招待の詳細は確認できません。

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### 匿名投票はすべての選挙に適していますか？

いいえ。匿名投票は、アプリケーション上で投票者の身元と投票を分離します。システム運用者からの保護が必要な決定や、独立した検証が可能な暗号技術を用いた選挙には、それらの要件を満たすように設計されたシステムが必要です。
