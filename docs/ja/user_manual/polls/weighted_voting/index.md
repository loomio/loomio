---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: e3d67479309d4b6d
  set-members-vote-weights: 20cf383c6b1ac9e2
  use-weighted-voting-in-a-poll: bac2c3ba9e58d57f
  results: 03531f7bdb8dd047
title: 加重投票
title_source: 0b971991dfcacbab
title_generated: c3ab3c21bb14998e
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# 加重投票

加重投票では、一部の票を他の票よりも大きく数えることができます。各投票者には票の重みが設定されます。例えば、次のように使えます。

- 住宅コミュニティで、各物件に1票を与えます。3つの物件を代表するメンバーの票の重みは `3` になります。
- 協同組合の理事会が決定を行い、運営スタッフも話し合いに参加します。理事の票の重みは `1` にします。運営スタッフの票の重みは `0` にするため、投票は記録されますが、結果には影響しません。
- 会社が株主に持株比率に応じた票を与えます。株式の12.5%を保有する人の票の重みは `12.5` になります。

<!-- translation-section: set-members-vote-weights -->

## メンバーの票の重みを設定する

グループの管理者は、グループの**メンバー**ページを開き、**投票の重みを編集する**を選択できます。票の重みを入力し、**投票の重みを保存する**を選択します。票の重みには `0` 以上の値を、小数点以下3桁まで設定できます。名前やメールアドレスで検索して、対象の人を見つけられます。すべてのメンバーに同じ票の重みを設定するには、**すべての投票の重みを設定する**を選択します。

![グループのメンバーの票の重み](member-weights.png)

メンバーの票の重みは、そのメンバーが追加される各アンケートにコピーされます。後から変更しても、すでにコピーされているアンケートの票の重みは変わりません。

<!-- translation-section: use-weighted-voting-in-a-poll -->

## アンケートで加重投票を使用する

アンケートの詳細設定で、**加重投票を使用する**を選択します。投票開始後も、有効または無効にできます。無効にすると、アンケート内のすべての票の重みが `1` に設定され、そのアンケートで変更した票の重みは失われます。

グループの定められた手順で加重投票を使う場合は、[アンケートのテンプレート](/en/user_manual/polls/poll_templates)で**加重投票を使用する**を選択します。そのテンプレートから開始したアンケートでは、加重投票が使われます。

![アンケートの「加重投票を使用する」設定](poll-setting.png)

加重投票は、次のアンケート形式で使用できます。[提案](/en/user_manual/polls/proposals)、[選択](/en/user_manual/polls/choose)、[スコア](/en/user_manual/polls/score)、[配分](/en/user_manual/polls/allocate)、[ランク](/en/user_manual/polls/rank)です。

同じアンケートで、加重投票と[匿名投票](/en/user_manual/polls/anonymous_voting)を併用することはできません。

1人の投票者の票の重みを変更するには、**有権者の管理**を選択し、その人の名前の横にある票の重みを選択します。全員の票の重みを変更するには、**すべての投票の重みを設定する**を選択します。グループから各メンバーの票の重みをコピーするか、全員に同じ値を設定できます。グループのメンバーではない投票者の票の重みは `1` になります。

![アンケートの「有権者の管理」ボタン](poll-manage-voters.png)

![個別の票の重みが設定されたアンケートの投票者](poll-voter-weights.png)

<!-- translation-section: results -->

## 結果

結果では、重みを適用しない合計と、重みを適用した合計が並んで表示されます。

- 提案と選択のアンケートでは、**投票**と**加重投票**が表示されます。
- スコア、配分、ランクのアンケートでは、**ポイント**と**加重ポイント**が表示されます。

グラフには、重みを適用した結果が表示されます。列の見出しを選択すると、その列のデータをグラフに表示できます。投票資格のある投票者数と定足数は、票の重みではなく人数で数えます。投票を閲覧できる人は、各投票者の票の重みも閲覧できます。

![投票と加重投票を表示した提案の結果](weighted-proposal-result.png)
