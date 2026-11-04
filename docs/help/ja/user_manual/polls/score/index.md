---
title: スコア投票
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/score/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 7881bcdd5aad5df4
  when-to-use-score: 0ef92ec0bb907a3f
  example-score-possible-trial-locations: 3c9438177a822198
  set-up-the-poll: 29b0296533594cd6
  vote: 1113501e9e6736b7
  read-the-results: 3e996e9bcc830d1d
  share-an-outcome: 243aaac17e645331
generated:
  introduction: 8e8b7bd159f87eb3
  when-to-use-score: 24302733c38dff7a
  example-score-possible-trial-locations: c19a7209500542cd
  set-up-the-poll: 2614a5ec2b36101d
  vote: 3e10b31a36a7a497
  read-the-results: 81846ee1b48c223b
  share-an-outcome: 7e7afb3516dd6eeb
title_source: 38e5a46cbc5ad328
title_generated: 7e0f91665b9c2fe0
---

<!-- translation-section: introduction -->

# スコア

スコアは、共通の数値尺度を使って、参加者が各選択肢をどのように評価するかを測ります。選択とは異なり、すべての選択肢への回答を求めるため、結果からは何が好まれているかと、どの程度好まれているかの両方がわかります。

<!-- translation-section: when-to-use-score -->

## スコアを使う場面

スコアは、同じ質問に対して各選択肢を個別に評価できる場合に使います。次のような用途に適しています。

- プロジェクトの各部分の準備状況を評価する
- 複数の原則の重要性を評価する
- 会議で取り上げる議題の候補への関心を測る
- 共通の基準で助成金の申請を評価する
- 複数の提案の適切さを比較する

尺度の下限と上限が何を意味するかを定義します。共通の定義がないと、同じ数値でも投票者によって意味が異なることがあります。選択だけが必要な場合は[選択](/en/user_manual/polls/choose/)を、参加者が限られた予算の中で配分を調整する必要がある場合は[配分](/en/user_manual/polls/allocate/)を使います。

<!-- translation-section: example-score-possible-trial-locations -->

## 例：試験実施場所の候補を採点する

Oatmilk Cooperativeは、回収して再利用するボトルの試験運用を行う場所を選んでいます。顧客の利用しやすさ、スタッフの対応能力、保管場所、回収時の輸送を考慮して、4か所を0（**不適切**）から10（**理想的**）までの尺度で採点するようメンバーに求めます。

<!-- translation-section: set-up-the-poll -->

## アンケートを設定する

すべての選択肢に等しく当てはまる質問を1つ記載します。評価する項目を追加し、**最低スコア**と**最大スコア**を設定して、詳細欄で両端の数値の意味を説明します。選択肢の意味を記載すると、各項目の範囲を明確にできます。

![](form.png)

参加者が一貫して使える尺度を選びます。0–5の尺度は手早く使え、0–10の尺度ではより細かな違いを表せます。細かく採点できるほど良い情報が得られるとは限らないため、質問に適した最も短い尺度を使います。

周囲の人や表示順による影響を減らすには、匿名での投票や選択肢のランダム表示が役立つ場合があります。

<!-- translation-section: vote -->

## 投票する

参加者はスライダーを動かして、すべての選択肢を採点します。この例では、投票者は中央駅のカフェを8、川沿いの市場を6、大学のフードコートを7、港のオフィスを5と採点しています。

![](voting.png)

理由には、投票者がどのように尺度を適用したかを説明します。これにより、グループは情報不足による低いスコアと、内容に対する懸念による低いスコアを区別しやすくなります。

<!-- translation-section: read-the-results -->

## 結果を読む

結果には、各選択肢について次の情報が表示されます。

- **ポイント**：すべてのスコアの合計
- **平均**：スコアの平均値
- **有権者**：その選択肢を採点した人数

![](results.png)

この例では、**中央駅のカフェ**の平均が7.5で最も高くなっています。**港のオフィス**の平均は5.25で最も低く、川沿いの市場と大学のフードコートはどちらも7です。招待された5人のうち4人が投票しているため、グループはまだ1人が回答していないことも確認できます。

平均を比較するのは、選択肢ごとの投票者数が同程度の場合に限ります。小さな差に意味があると判断する前に、投票の理由を読みます。

<!-- translation-section: share-an-outcome -->

## 結論を共有する

アンケートが締め切られたら、結論を共有します。スコアを踏まえてどのような行動を取るか、同点の場合はどのように決めるかを説明します。結論の使い方については、[結論を共有する](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome)を参照してください。

![平均スコアが最も高い場所を選ぶ結論](outcome.png)
