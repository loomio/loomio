---
title: 選ぶ
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/choose/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 3570d7d235e7bfad
  when-to-use-choose: 68cfcf5f85ef14c6
  example-set-a-planning-meeting-agenda: ceca06a3f71f9d74
  set-up-the-poll: 60f258f0eedb6323
  vote: 958df5aed5589661
  read-the-results: da240100a27bb2b4
  share-an-outcome: f6afc1713b921265
generated:
  introduction: a00423155ee082c0
  when-to-use-choose: cdadd31baef171f6
  example-set-a-planning-meeting-agenda: 0151a3d67174538e
  set-up-the-poll: d3e89fed16f3aeb7
  vote: c77a7f0c01dc7a45
  read-the-results: d677b9bfbdbc552f
  share-an-outcome: 817a376075b161c8
title_source: c7f937836f5d82d5
title_generated: 2c01205b05f1ad12
needs_review:
  share-an-outcome: use "結論" instead of "結果" for "outcome"
---

<!-- translation-section: introduction -->

# 選択

選択は、最も人気のある選択肢を見つけたり、候補を絞り込んだりするためのシンプルなアンケートです。参加者は、設定された上限と下限に応じて、1つ以上の選択肢を選びます。この投票方法は、多肢選択式とも呼ばれます。

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

アンケートのタイトルには、具体的な質問を記載します。**詳細**には、参加者が考慮すべきことと、結果をどのように使うかを説明します。各選択肢を追加してから、**最小限の選択肢**と**最大限の選択肢**を設定します。

![](form.png)

参加者が必ず1つだけ選ぶ必要がある場合は、下限と上限を両方とも1に設定します。候補を絞り込みたい場合は、上限を増やします。ほぼすべての選択肢を選べるほど上限を大きくすると、結果が判断に役立ちにくくなるため、避けます。

選択肢の横にある鉛筆アイコンを選択して、意味や補足説明を追加します。短い選択肢名が複数の意味に解釈される可能性がある場合に役立ちます。

![](edit_option.png)

最初の選択肢が有利になるのを避けるため、**その他の設定**にある**選択肢をランダムな順序で表示する**をオンにします。

![](random_order.png)

<!-- translation-section: vote -->

## 投票する

参加者は、選択数の下限と上限の範囲内で、希望する選択肢を選びます。この例では、投票者は**カフェからの回収日程**と**洗浄の作業手順**を選び、その選択と試験運用を結び付ける投票理由を記載します。

![](voting.png)

投票理由では、その選択肢がなぜ重要なのか、参加者がどのような作業を含むと考えているのかを説明できます。決定に理由が重要な場合は、アンケートを開始する前に、投票理由を必須にする設定を行います。

<!-- translation-section: read-the-results -->

## 結果を確認する

結果には、すべての票に対して各選択肢が獲得した票の割合、その選択肢を選んだ投票者の数、未投票の人が表示されます。各参加者は2つの選択肢を選べるため、この割合は人数の割合ではなく、票数の割合を表します。

![](results.png)

この例では、**カフェからの回収日程**は3票、**洗浄の作業手順**と**返却率の報告**はそれぞれ2票を獲得しています。この結果は、カフェからの回収に最も多くの議題時間を割くことを支持しています。同票の議題の間で残りの時間をどう配分するかは、主催者が決めます。

<!-- translation-section: share-an-outcome -->

## 結論を共有する

アンケートが締め切られたら、結論を共有します。同数の場合の扱いも含め、グループが結果をもとに何をするかを説明します。結論の仕組みについては、[結論を共有する](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome)を参照してください。

![カフェからの回収に会議の時間を最も多く割り当てる結論](outcome.png)
