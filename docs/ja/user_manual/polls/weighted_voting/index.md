---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: '0059cca66d766ace'
  set-members-vote-weights: 51e9a022f2239bd7
  use-weighted-voting-in-a-poll: c70702bd817bb6a1
  results: e0fac6f61a4a5802
title: 加重投票
title_source: 0b971991dfcacbab
title_generated: c3ab3c21bb14998e
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# 加重投票

加重投票では、票によって集計への影響を変えることができます。各有権者には投票の重みが設定されます。例えば、次のような使い方があります。

- 住宅コミュニティで、各物件に1票を割り当てます。3つの物件を代表するメンバーの投票の重みは `3` です。
- 協同組合の理事会が意思決定を行い、運営スタッフも話し合いに参加します。理事の投票の重みは `1` です。運営スタッフの投票の重みは `0` なので、投票は記録されますが、結果には影響しません。
- 会社が株式の保有割合に応じて株主に票を割り当てます。株式の12.5%を保有する人の投票の重みは `12.5` です。

<!-- translation-section: set-members-vote-weights -->

## メンバーの投票の重みを設定する

グループ管理者は、グループの**メンバー**ページを開き、**投票の重みを編集する**を選択できます。投票の重みを入力し、**投票の重みを保存する**を選択します。投票の重みには `0` 以上の値を設定でき、小数点以下3桁まで入力できます。名前やメールアドレスでメンバーを検索できます。全メンバーに同じ投票の重みを設定するには、**すべての投票の重みを設定する**を選択します。

![グループメンバーの投票の重み](member-weights.png)

メンバーの投票の重みは、そのメンバーが追加される各投票にコピーされます。後から変更しても、すでにコピーされた投票の重みは変わりません。

<!-- translation-section: use-weighted-voting-in-a-poll -->

## 投票で加重投票を使用する

投票の詳細設定で**加重投票を使用する**を選択します。投票開始後も有効または無効にできます。無効にすると、その投票のすべての投票の重みが `1` に設定され、その投票で変更した投票の重みはすべて失われます。

グループの定例の意思決定手順で加重投票を使用する場合は、[投票テンプレート](/en/user_manual/polls/poll_templates)で**加重投票を使用する**を選択します。そのテンプレートから開始した投票では、加重投票が使用されます。

![投票の「加重投票を使用する」設定](poll-setting.png)

加重投票は、次の投票タイプで使用できます：[提案](/en/user_manual/polls/proposals)、[選ぶ](/en/user_manual/polls/choose)、[スコア](/en/user_manual/polls/score)、[割り当てる](/en/user_manual/polls/allocate)、[ランク](/en/user_manual/polls/rank)。

同じ投票で加重投票と[匿名投票](/en/user_manual/polls/anonymous_voting)を併用することはできません。

1人の有権者の投票の重みを変更するには、**有権者の管理**を選択し、その人の名前の横にある投票の重みを選択します。全員の投票の重みを変更するには、**すべての投票の重みを設定する**を選択します。グループから各メンバーの投票の重みをコピーすることも、全員に同じ値を設定することもできます。グループのメンバーではない有権者の投票の重みは `1` になります。

![投票の「有権者の管理」ボタン](poll-manage-voters.png)

![個別の投票の重みが設定された投票の有権者](poll-voter-weights.png)

<!-- translation-section: results -->

## 結果

結果には、重みを適用しない合計と重みを適用した合計が並んで表示されます。

- 提案と選ぶの投票では、**投票**と**加重投票**が表示されます。
- スコア、割り当てる、ランクの投票では、**ポイント**と**加重ポイント**が表示されます。

グラフには、重みを適用した結果が表示されます。列の見出しを選択すると、その列のグラフに切り替わります。有権者数と定足数は、投票の重みではなく人数で数えます。投票内容を閲覧できる人は、各有権者の投票の重みも確認できます。

![投票と加重投票を表示した提案の結果](weighted-proposal-result.png)
