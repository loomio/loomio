---
title: 選ぶ
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/choose/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: f9d6a5bfb7445de0
  when-to-use-choose: f8a798497cac5a43
  example-set-a-planning-meeting-agenda: 32a94a916dbf84e5
  set-up-the-poll: a16095b63c57e0c9
  vote: d170451131c544cf
  read-the-results: e675d12da1a4ba8a
  share-an-outcome: f6afc1713b921265
generated:
  introduction: b1578c946b248a5e
  when-to-use-choose: cdadd31baef171f6
  example-set-a-planning-meeting-agenda: 0151a3d67174538e
  set-up-the-poll: 1b973800e276bbe7
  vote: 19c43cca7d25ba0f
  read-the-results: c752b2f5ec86faeb
  share-an-outcome: 817a376075b161c8
title_source: c7f937836f5d82d5
title_generated: 2c01205b05f1ad12
needs_review:
  share-an-outcome: use "結論" instead of "結果" for "outcome"
---

<!-- translation-section: introduction -->

# 選択

選択は、最も人気のある選択肢を見つけたり、候補を絞り込んだりするためのシンプルなアンケートです。参加者は、設定された上限と下限に応じて、1つ以上の選択肢を選びます。この投票方法は、一般に多肢選択式と呼ばれます。

<!-- translation-section: when-to-use-choose -->

## 選択を使う場面

選択肢がそれぞれ明確に異なり、各選択肢を何人が選んだかを数える必要がある場合に、選択を使います。次のような用途に適しています。

- 候補の中から会場を1つ選ぶ場合
- 議題を最大3つ選ぶ場合
- 次のラウンドに進めるデザインを決める場合
- メンバーがどのサービスを利用する予定か確認する場合

選択では、選んだ選択肢を記録しますが、好みの強さや優先順位は記録しません。各選択肢への支持の強さを測るには[スコア](/en/user_manual/polls/score/)、予算に限りがある場合は[配分](/en/user_manual/polls/allocate/)、優先順位が重要な場合は[ランク](/en/user_manual/polls/rank/)を使います。

<!-- translation-section: example-set-a-planning-meeting-agenda -->

## 例：計画会議の議題を決める

Oatmilk Cooperativeでは、回収して再利用するボトルの試験運用について、次の計画会議でどの項目に最も時間を割くかを決める必要があります。このアンケートでは、各参加者に最大2つの議題を選んでもらいます。詳細には結果の使い方を説明し、各選択肢には、他の選択肢との違いが分かるだけの情報を記載しています。

<!-- translation-section: set-up-the-poll -->

## アンケートを設定する

アンケートのタイトルには、具体的な質問を記載します。**詳細**には、参加者が考慮すべきことと、結果をどのように使うかを説明します。選択肢をすべて追加してから、**最小限の選択肢**と**最大限の選択肢**を設定します。

![](form.png)

参加者が必ず1つだけ選ぶ必要がある場合は、下限と上限を両方とも1に設定します。候補を絞り込みたい場合は、上限を増やします。ほぼすべての選択肢を選べるほど上限を大きくすると、結果が判断に役立ちにくくなるため、避けます。

選択肢の横にある鉛筆アイコンから、意味や補足説明を追加します。短い選択肢名が複数の意味に解釈される可能性がある場合に役立ちます。

![](edit_option.png)

**その他の設定**にある**選択肢をランダムな順序で表示する**を使うと、同じ選択肢を常に最初に表示することによる影響を減らせます。

![](random_order.png)

<!-- translation-section: vote -->

## 投票する

投票フォームには、選べる選択肢の数が表示されます。この例では、投票者は**カフェからの回収日程**と**洗浄の作業手順**を選び、その選択と試験運用を結び付ける理由を記載します。

![](voting.png)

理由からは、その選択肢がなぜ重要なのか、参加者がどのような作業を含むと考えているのかが分かります。決定に理由が重要な場合は、アンケートを開始する前に、投票理由の設定を行います。

<!-- translation-section: read-the-results -->

## 結果を確認する

結果には、すべての票に対して各選択肢が獲得した票の割合、その選択肢を選んだ投票者の数、まだ投票していない人が表示されます。各参加者は2つの選択肢を選べるため、この割合は人数の割合ではなく、票数の割合を表します。

![](results.png)

この例では、**カフェからの回収日程**は3票、**洗浄の作業手順**と**返却率の報告**はそれぞれ2票を獲得しています。この結果は、カフェからの回収に最も多くの議題時間を割くことを支持しています。ただし、同票の議題については、残りの時間をどう配分するかを主催者が決める必要があります。

<!-- translation-section: share-an-outcome -->

## 結論を共有する

アンケートが締め切られたら、結論を共有します。同数の場合の扱いも含め、グループが結果をもとに何をするかを説明します。結論の仕組みについては、[結論を共有する](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome)を参照してください。

![カフェからの回収に会議の時間を最も多く割り当てる結論](outcome.png)
