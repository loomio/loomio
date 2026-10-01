---
title: スコア投票
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  introduction: abb2f64418ab3887
  when-to-use-score: 002f902ff8d2afaa
  example-score-possible-trial-locations: 0bf4d271e11184b1
  set-up-the-poll: e2ed6723e654a583
  vote: a2fa402494512629
  read-the-results: e2864a261e489868
  share-an-outcome: 18243d257779877e
title_source: 38e5a46cbc5ad328
title_generated: 7e0f91665b9c2fe0
---

<!-- translation-section: introduction -->

# スコア投票

スコア投票では、参加者が共通の数値尺度で各選択肢を評価します。選択投票とは異なり、すべての選択肢への回答を求めます。そのため、結果から何を好むかに加え、どの程度好むかも分かります。

<!-- translation-section: when-to-use-score -->

## スコア投票を使う場面

すべての選択肢を同じ問いに基づいて個別に評価できる場合は、スコア投票を使います。たとえば、次のような場合に適しています。

- プロジェクトの各部分の準備状況を評価する
- 複数の原則の重要度を評価する
- 会議の議題候補への関心を測る
- 共通の基準で助成金の申請を評価する
- 複数の提案の適合性を比較する

尺度の最低点と最高点が何を意味するかを定義します。共通の定義がなければ、同じ数字でも投票者によって意味が異なる場合があります。選択肢を選ぶだけでよい場合は[選択投票](/en/user_manual/polls/choose/)を、参加者が限られた予算の中で配分を決める必要がある場合は[配分投票](/en/user_manual/polls/allocate/)を使います。

<!-- translation-section: example-score-possible-trial-locations -->

## 例：試験実施場所の候補を評価する

オーツミルク協同組合は、返却可能なボトルの試験実施場所を選んでいます。顧客のアクセス、スタッフの対応力、保管場所、回収時の輸送を考慮し、メンバーに4つの場所を0（**不適切**）から10（**理想的**）で評価してもらいます。

<!-- translation-section: set-up-the-poll -->

## 投票を設定する

すべての選択肢に同じように当てはまる質問を1つ示します。評価する項目を追加し、**最低スコア**と**最大スコア**を設定して、詳細にそれぞれの点数が意味することを説明します。選択肢の説明には、各項目の評価範囲を明記できます。

![](form.png)

参加者が一貫して使える尺度を選びます。0～5の尺度は手軽に使えます。0～10の尺度なら、より細かな違いを示せます。細かくしても、必ずしも有用な情報が増えるわけではありません。質問に合う、できるだけ簡潔な尺度を使います。

ほかの人の影響や選択肢の表示順による影響を減らしたい場合は、匿名投票や選択肢のランダム表示が役立ちます。

<!-- translation-section: vote -->

## 投票する

参加者はスライダーを動かして、すべての選択肢に点数を付けます。この例では、投票者は中央駅のカフェに8点、川沿いの市場に6点、大学のフードコートに7点、港のオフィスに5点を付けています。

![](voting.png)

投票理由には、その尺度をどう当てはめたかを説明します。これにより、グループは低い点数が情報不足によるものか、具体的な懸念によるものかを区別できます。

<!-- translation-section: read-the-results -->

## 結果を読む

結果には、選択肢ごとに次の情報が表示されます。

- **ポイント**：すべての点数の合計
- **平均**：点数の平均
- **有権者**：その選択肢に点数を付けた人数

![](results.png)

この例では、**中央駅のカフェ**の平均が7.5で最も高く、**港のオフィス**の平均が5.25で最も低くなっています。川沿いの市場と大学のフードコートは、どちらも7です。招待された5人のうち4人が投票済みなので、グループは1人の回答がまだないことも確認できます。

平均を比較するのは、選択肢ごとの投票者数がほぼ同じ場合に限ります。わずかな差に意味があると判断する前に、投票理由を読みます。

<!-- translation-section: share-an-outcome -->

## 結論を共有する

投票が終了したら、結論を共有します。点数を受けてどのような行動を取るか、同点の場合はどのように決めるかを説明します。結論の使い方については、[結論を共有する](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome)を参照してください。

![平均点が最も高い場所を選ぶ結論](outcome.png)
