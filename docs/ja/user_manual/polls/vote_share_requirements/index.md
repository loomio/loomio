---
title: 投票割合の要件
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: 6de41a070ca168dd
  eligible-voters-and-votes-cast: fdc9da98acd84b6d
  different-vote-share-requirements: b73064247eac6a65
  detailed-example: aa04e010f24d9fd6
title_source: a654891ca817844e
title_generated: 1ded9d960ce79938
---

<!-- translation-section: introduction -->

# 投票割合の要件

提案の可決に一定割合以上の賛成、または一定割合以下の反対が必要な場合は、選択肢に投票割合の要件を設定します。

投票割合の要件は[定足数](/en/user_manual/polls/quorum/)と組み合わせることで、十分な参加と特定の票の分布の両方を条件にできます。

提案のフォームで、選択肢の横にある編集アイコンを選択します。

![賛成の選択肢の横にある編集アイコン](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## 投票資格のある人と投票数

割合の基準には、**投票数**または**有権者**を選択できます。

![投票割合の要件の基準として投票数か有権者を選択する画面](./eligible-vs-cast.png)

**有権者**は、その提案に投票できるすべての人を指します。**投票数**は、提出された票のみを指します。

投票資格のある人の75パーセントが賛成するという要件では、投票資格のある人全体の少なくとも75パーセントがその選択肢に投票した場合にのみ、提案を可決できます。

提出された票の60パーセントが賛成するという要件では、全体の投票率にかかわらず、提出された票の60パーセントがその選択肢を支持すれば、提案を可決できます。手続き上、最低限の参加率も必要な場合は、定足数を追加します。

<!-- translation-section: different-vote-share-requirements -->

## 選択肢ごとに異なる投票割合の要件

提案では、複数の選択肢に要件を設定できます。例えば、次のように設定します。

- 賛成は、投票資格のある人の75パーセント以上
- 棄権は、提出された票の30パーセント以下
- ブロックは、提出された票の0パーセント以下

選択肢を**0%以下**に設定するのは、よく使われる方法です。誰かがその選択肢を選ぶと、提案を可決できなくなります。**ブロック**に設定すると、1票のブロックで提案の可決を止められます。

[アンケートのテンプレート](/en/user_manual/polls/poll_templates/)にも要件を追加できます。そのテンプレートから作成する新しい提案には、これらの要件が初期設定として適用されます。

<!-- translation-section: detailed-example -->

## 詳しい例

Oatmilk Cooperativeでは、回収して再利用する瓶を6週間試験的に導入するかどうかを決めようとしています。投票資格のある人は5人です。

この協同組合の手続きでは、投票資格のある人の少なくとも75パーセントが賛成する必要があります。Jamieは提案の**賛成**の選択肢を編集し、投票割合の要件を有効にして、**有権者の75%以上**に設定します。

![投票資格のある人の75パーセント以上を必要とする賛成の選択肢](./agree-vote-option.png)

Jamieは定足数も60パーセントに設定します。JamieとSamiraが賛成に投票します。提出された票はすべて提案に賛成していますが、投票資格のある人の40パーセントにとどまるため、どちらの要件も満たしていません。

![5人中2人が賛成に投票し、どちらの要件も満たしていない状態](./first-vote-breakdown.png)

その後、AlexとMorganが賛成に、Taylorが反対に投票します。5人全員が投票したため定足数を満たし、投票資格のある5人中4人が賛成しています。賛成の割合は80パーセントで、投票割合の要件である75パーセントを上回るため、両方の要件に緑色のチェックマークが表示されます。

![5人全員が投票し、両方の要件を満たした状態](./final-vote-breakdown.png)
