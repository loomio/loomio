---
title: 投票割合の要件
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  introduction: 26f297dcbde00ad3
  eligible-voters-and-votes-cast: c5eadfbfcec2de4e
  different-vote-share-requirements: 73e529049d0abf87
  detailed-example: fea34e913864a79e
title_source: a654891ca817844e
title_generated: 1ded9d960ce79938
---

<!-- translation-section: introduction -->

# 投票割合の要件

提案の可決に一定割合以上の賛成、または一定割合以下の反対が必要な場合は、選択肢に投票割合の要件を設定します。

投票割合の要件は[定足数](/en/user_manual/polls/quorum/)と組み合わせられます。これにより、十分な参加と、指定した投票割合の両方を可決の条件にできます。

提案フォームで、選択肢の横にある編集アイコンを選びます。

![「同意する」の選択肢の横にある編集アイコン](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## 有権者と投票数

割合の基準には、**投票数**または**有権者**を選べます。

![投票割合の要件の基準として投票数または有権者を選ぶ画面](./eligible-vs-cast.png)

**有権者**は、提案に投票できる人全員を指します。**投票数**は、実際に投じられた票だけを指します。

有権者の75%以上の賛成が必要な場合は、投票できる人全員のうち75%以上がその選択肢に投票したときだけ可決されます。

投票数の60%以上の賛成が必要な場合は、全体の投票率にかかわらず、投じられた票の60%以上がその選択肢を支持すれば可決されます。最低限の参加人数も必要な場合は、定足数を設定します。

<!-- translation-section: different-vote-share-requirements -->

## 選択肢ごとに異なる投票割合の要件

一つの提案で、複数の選択肢に要件を設定できます。例えば、次のように設定します。

- 同意は有権者の75%以上
- 棄権は投票数の30%以下
- ブロックは投票数の0%以下

選択肢を**0%以下**に設定するのは、よく使われる方法です。その選択肢を一人でも選ぶと、提案は可決されません。**ブロック**にこの設定を使うと、一人のブロックで提案の可決を止められます。

[投票テンプレート](/en/user_manual/polls/poll_templates/)にも要件を追加できます。そのテンプレートから新しい提案を作成すると、要件が初期設定として適用されます。

<!-- translation-section: detailed-example -->

## 具体例

オーツミルク協同組合では、返却可能なボトルを6週間試験運用するかどうかを決めています。投票できる人は5人です。

この協同組合では、有権者の75%以上が同意することが必要です。ジェイミーは提案の**同意する**の選択肢を編集し、投票割合の要件を有効にして、**有権者の75%以上が賛成**に設定します。

![有権者の75%以上の賛成を必要とする「同意する」の選択肢](./agree-vote-option.png)

ジェイミーは定足数も60%に設定します。ジェイミーとサミラが同意に投票します。投じられた票はすべて提案を支持していますが、有権者全体の40%にすぎません。そのため、どちらの要件にも達していません。

![5人中2人が同意に投票し、どちらの要件にも達していない状態](./first-vote-breakdown.png)

続いてアレックスとモーガンが同意し、テイラーは反対します。5人全員が投票したため定足数に達し、有権者5人のうち4人が同意しました。賛成率は80%で、必要な75%を超えています。両方の要件に緑色のチェックマークが表示されます。

![5人全員が投票し、両方の要件に達した状態](./final-vote-breakdown.png)
