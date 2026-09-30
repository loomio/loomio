---
title: 匿名投票
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: d5c276b2785919c3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: cdaa1f5c3ca1e179
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 51460c8a6b663aba
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 3dd2c9e6d06debda
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 2ba76a1748304f96
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: 4f5beb50f538ccd4
  how-anonymous-voting-protects-voters: df2298f7c54122be
  while-voting-is-open: 170fbed3f44532cb
  votes-cannot-be-changed: f3d705fc2ba9ae0c
  why-anonymous-votes-do-not-have-reasons: 7e807b5b2d861290
  results-and-exports: ec6c3d1d4662322b
  participation-verification: 3c8ebe1d54faaa53
  reminders: 053b855071d5c5d9
  what-coordinators-and-administrators-can-see: 6cd035f13a5e7127
  limits-of-anonymous-voting: 2cfd75861215da01
  questions: 01e0d5ad82158a42
  can-a-coordinator-see-how-i-voted: 7bd285e05f456e67
  can-i-see-my-vote-after-submitting-it: aed1996829bb03bc
  can-i-change-or-withdraw-my-vote: 4b6b548201c028ab
  will-i-receive-an-email-confirming-my-vote: fe5b075a0675561d
  does-a-public-poll-reveal-more-information: e1fea95cb2f8413e
  is-anonymous-voting-suitable-for-every-election: a63973aa269c6251
title_source: 1bc4567506ad4d51
title_generated: 55edffe99178b192
---

<!-- translation-section: introduction -->

# 匿名投票

匿名投票は、ブラインド投票とも呼ばれ、誰が投票したかという記録と投票内容を分けて保存します。投票のコーディネーターは、誰に投票資格があったかを確認できます。3人以上が投票すると、誰が投票したかも確認できます。アプリ上では、提出された票を投票者と結び付けることはできません。

このページでは、匿名投票による保護、保存される情報、匿名性の限界を説明します。

<!-- translation-section: how-anonymous-voting-protects-voters -->

## 匿名投票で投票者を保護する仕組み

匿名投票では、次の2種類の記録を分けて保存します。

| 参加記録 | 提出された票 |
| --- | --- |
| 投票資格がある人 | 選択した選択肢や点数 |
| 招待された人と招待した人 | 票が属する投票 |
| 投票資格がある各人が投票したかどうか | 氏名やユーザーアカウントは含まれない |
| 選択した選択肢や点数は含まれない | 参加記録へのリンクはない |

この2種類の記録を結び付ける共通の識別子はありません。提出された票には、実際の提出時刻、招待情報、記述した理由、添付ファイルなど、投票者の特定につながる情報も含まれません。

この分離は票を保存する際に行われます。画面上で氏名を隠すだけの仕組みではありません。

<!-- translation-section: while-voting-is-open -->

## 投票の受付中

投票が終了するまで、結果は誰にも表示されません。投票のコーディネーター、グループ管理者、インスタンス管理者も、アプリ上では結果を見られません。

誰かが投票すると、次のように処理されます。

- 提出された票は、投票者の氏名や参加記録との関連付けなしで保存されます。
- 参加記録には、投票済みであることが記録されます。
- 投票に関するイベント、通知、メール、コメント、アクティビティ項目は作成されません。
- 提出後に、選択内容のコピーは返されません。
- 画面には、票が記録されたことだけが表示されます。

参加記録には、その人が投票した正確な時刻は保存されません。提出された票も提出時刻順には並びません。

<!-- translation-section: votes-cannot-be-changed -->

## 投票後に票は変更できません

投票資格がある人は、それぞれ1回だけ投票できます。提出した匿名の票は、コーディネーターや管理者を含め、誰も確認、変更、撤回、差し替えできません。

自分の票を取り出したり差し替えたりするには、投票者と票を結ぶ情報を残す必要があります。匿名投票では、そのような情報を作りません。

提出する前に、選択内容をよく確認してください。

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## 匿名の票に理由を記載できない理由

新しく提出する匿名の票には、記述した理由や添付ファイルを含められません。理由には、氏名、個人情報、文章の特徴、メンションなど、投票者を特定できる情報が含まれる場合があります。また、集計結果から個々の票を区別しやすくなります。

スレッドでの議論が可能な場合、参加者はそこで投票について話し合えます。そのコメントは投稿者の名前が付いた通常の議論への投稿であり、匿名の票には添付されません。

<!-- translation-section: results-and-exports -->

## 結果とエクスポート

投票が終了すると、投票者から切り離された票をもとに結果が計算されます。結果は、投票の種類に応じた合計やその他の集計値として表示されます。

アプリは、票の識別子、提出順、提出時刻を公開しません。投票のエクスポートには、匿名の票ごとの行ではなく集計結果が含まれます。ただし、終了したSTV選挙はBLT形式でエクスポートできます。BLTエクスポートには再集計に必要な候補者の順位が含まれ、同じ順位の票はまとめられます。投票者の身元や票のメタデータは含まれません。

匿名投票は、終了後に再開できません。

<!-- translation-section: participation-verification -->

## 投票状況の確認

投票のコーディネーターは、氏名付きの参加記録を閲覧できます。この記録には、投票資格があった人が常に表示されます。3人以上が投票すると、各人が投票したかどうかも表示されますが、投票内容は表示されません。投票数が3票未満のまま終了した場合、各人の投票状況は引き続き非表示になります。

ほかの参加者は、この氏名付きの参加情報を閲覧できません。投票結果を閲覧できても、参加記録を閲覧できるようにはなりません。

コーディネーターは投票の受付中、ほかの人がすでに投票した後でも、 投票資格がある人を追加できます。すでに投票した人を匿名投票から 削除することはできません。

<!-- translation-section: reminders -->

## リマインダー

投票期間が24時間以上の匿名投票では、投票資格がある未投票の人に、終了前の24時間以内に自動リマインダーが1回届きます。

リマインダーの送信対象は参加記録だけをもとに選ばれます。提出された票を調べたり、票と参加記録を結び付けたりすることはありません。締め切りが変更された場合、1時間ごとのリマインダー確認では現在の締め切りが使われます。投票ごとに別のリマインダー予定は保持されません。

投票期間が合計24時間未満の場合、この自動リマインダーは送信されません。

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## コーディネーターと管理者が見られる情報

投票のコーディネーター、グループ管理者、インスタンス管理者は、アプリ上で次の情報を閲覧できる場合があります。

- 投票と、投票資格がある人。
- その役割に閲覧権限があり、3人以上が投票した場合は、投票資格がある各人が投票したかどうか。
- 投票終了後の集計結果。

アプリの機能を使っても、次の情報は閲覧できません。

- 誰がどの選択肢を選んだか。
- 個々の票や投票パターン。
- 特定の票が提出された時刻。
- 提出された票に関連する理由、添付ファイル、イベント、通知。

<!-- translation-section: limits-of-anonymous-voting -->

## 匿名投票の限界

これらの保護により、アプリの利用者は提出された票を投票者と結び付けられません。ただし、データベース、バックアップ、サーバーログ、プロセスのメモリ、ネットワーク通信、改変されたアプリを調べられる運用者に対して、暗号技術による保護を提供するものではありません。

結果自体から情報が分かる場合もあります。投票者が少ない場合、全員が同じ選択をした場合、選択肢の組み合わせが特徴的な場合、投票の外で情報が共有された場合には、個人の選択を推測しやすくなります。投票者が、提出した票とは別の議論で自分の選択を明かすこともあります。

アプリ上の匿名投票が適しているか判断する際は、有権者の数と決定の機密性を考慮してください。

<!-- translation-section: questions -->

## よくある質問

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### 投票の管理者は、誰がどのように投票したかを見ることができますか？

いいえ。3人以上が投票すると、投票の管理者は各人が投票したかどうかを確認できます。ただし、アプリ上で投票者と投票内容を結びつけることはできません。投票者が3人未満の場合、各人の投票状況も表示されません。

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### 投票後に自分の投票内容を見ることはできますか？

いいえ。アプリは投票が記録されたことを確認し、投票画面から選択内容を消去します。投票者と投票内容を結びつける情報は作成されないため、投票内容を呼び出すことはできません。

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### 投票を変更したり取り消したりできますか？

いいえ。どの投票を変更または削除すべきか特定できる情報がないため、変更も取り消しもできません。

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### 投票の確認メールは届きますか？

いいえ。投票時には画面上に記録の確認が表示され、投票状況の記録が更新されます。確認メールは送信されず、通知やアクティビティの記録も作成されません。

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### 公開投票では、より多くの情報が見えますか？

公開投票では、投票と終了後の集計結果を閲覧できる場合があります。名前付きの投票状況の記録や、個々の匿名投票の内容は公開されません。

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### 匿名投票はすべての選挙に適していますか？

いいえ。匿名投票はアプリ上で投票者の身元と投票内容を分離します。システム運用者からの保護や、第三者が独立して検証できる暗号技術を使った選挙が必要な場合は、その要件に対応したシステムが必要です。
