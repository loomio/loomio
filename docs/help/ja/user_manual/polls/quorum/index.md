---
title: 定足数
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 60e6899e80a53a93
  example-scenario: ec3ccb9b0a10edc1
title_source: 18ed8b6c5ab90343
title_generated: cc555d51b9c1ff66
---

<!-- translation-section: introduction -->

# 定足数

定足数とは、アンケートが有効となるために参加する必要がある、投票資格を持つ人の最低割合です。組織の意思決定の手続きで一定の参加率が求められる場合に使用します。

アンケートを作成する際に、**その他の設定**を開き、**参加定足数**に必要な割合を入力します。定足数が不要な場合は、欄を空白のままにします。

![参加定足数を60％に設定した定足数の設定](./quorum-section.png)

[アンケートテンプレート](/en/user_manual/polls/poll_templates/)にも定足数を設定できます。そのテンプレートから作成するアンケートには、設定した定足数が初期設定として適用されます。

<!-- translation-section: example-scenario -->

## 利用例

Oatmilk協同組合では、返却式ボトルを6週間試験導入することについてディスカッションを行っています。ディスカッションが進み、協同組合として試験導入の予算を承認する段階に達しました。

Jamieは**投票を開始する**を選択し、**同意**の提案テンプレートを選び、タイトル、詳細、選択肢、期間、投票者の設定を入力します。

![提案のタイトル、詳細、選択肢、期間、投票者の設定](proposal-options.png)

Jamieは、投票できる人を試験導入の予算を担当する5人に限定します。

協同組合では重要な決定に60％の参加を求めているため、Jamieは参加定足数の欄に**60**と入力し、提案を開始します。

まだ誰も投票していない時点では、結果パネルに定足数に達していないことが表示されます。

![まだ投票がなく、60％の定足数に達していない状態](pie-chart-0.png)

Jamieは賛成、Samiraは反対に投票します。グラフは更新されますが、投票資格を持つ5人のうち2人の参加では参加率は40％なので、まだ定足数に達していません。

![5人のうち2人が投票し、まだ定足数に達していない状態](pie-chart-40.png)

続いてAlexが賛成に投票します。投票資格を持つ5人のうち3人が参加し、60％の定足数に達しました。定足数の要件に緑色のチェックマークが表示されます。Jamieはアンケートを早めに締め切ることも、残りの投票者の投票を待つこともできます。

![5人のうち3人が投票し、60％の定足数に達した状態](pie-chart-60.png)
