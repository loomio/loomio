---
title: 投票テンプレート
source_revision: 00d781409c832b216c95759c1369678ad240e246
source_file: docs/help/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-29'
sections:
  introduction: a535465485cdbc13
  who-can-manage-templates: 6c3d5e693cd1dfdc
  create-a-poll-template: 0fafc6275b6c9153
  template-title-subtitle-and-help: 5a3f6c78e32fb066
  voting-method: c645269a1a17d1c8
  example-title-details-and-tags: 0f0d84a8b9b6ecb2
  response-options: 727afbf0dcea6069
  duration-and-settings: f1f3643e94524af9
  manage-the-template-list: 76e78b8a60f1d08c
  save-a-poll-as-a-template: 36dc7b5d410d0eea
  start-a-new-template: 4f14910d88b22de8
  configure-the-template: bec89f7804dd12f8
  edit-a-default-template: 6f1e7050d20ed373
generated:
  introduction: b639b0623cf3c623
  who-can-manage-templates: ca9ce236b6e42ea8
  create-a-poll-template: 4231b06a60e5dd40
  template-title-subtitle-and-help: 54d6c9a919de49b7
  voting-method: a09300b8f89542b7
  example-title-details-and-tags: 555bddc190301689
  response-options: 0d23ec7906ce6ab3
  duration-and-settings: fb453195b431beae
  manage-the-template-list: 318125ec61eeefea
  save-a-poll-as-a-template: 723208bb847716c3
  start-a-new-template: 97787fe021e66307
  configure-the-template: 6a7fbe6df6006da3
  edit-a-default-template: 81b5fdb907a06b19
title_source: 114cca246e357304
title_generated: 9112f2db22c72b79
---

<!-- translation-section: introduction -->

# アンケートテンプレート

アンケートテンプレートは、**投票を開始する**または**新しい投票**を選択したときに表示される、再利用可能なひな形です。投票方法に、あらかじめ用意した説明、回答の選択肢、設定を組み合わせたものです。

このページでは、グループで利用できるテンプレートを設定する方法や、独自の進め方に合わせてテンプレートを作成する方法を説明します。個別の投票に使うテンプレートを選ぶには、[提案](../proposals/)または[アンケート](../proposal_types/)を参照してください。意思決定のプロセス全体を進めるには、[決定を行う](/en/guides/making_decisions/)を参照してください。

投票を開始するときは、**提案**または**アンケート**タブを選択し、グループで利用できるテンプレートの中から1つ選びます。

テンプレートには、導入文、内容の例、選択肢、設定が用意されています。投票を開始する前に、個別の決定に合わせてこれらを確認し、編集してください。新しい投票を編集しても、再利用するテンプレートは変更されません。

<!-- translation-section: create-a-poll-template -->

## アンケートテンプレートを作成する

<!-- translation-section: save-a-poll-as-a-template -->

### テンプレートとして保存する

既存の提案やアンケートを再利用するには、その操作メニューを開き、**テンプレートとして保存**を選択します。

![提案の操作メニューを開き、「テンプレートとして保存」が強調表示されている様子](save_as_template.png)

投票日時、投票者、投票、結果、アンケートの結論はテンプレートに保存されません。

<!-- translation-section: start-a-new-template -->

### 新しいテンプレートを作成する

テンプレート一覧を開き、**新しいテンプレート**を選択します。サンプルまたは空のテンプレートから始め、そのテンプレートを使うグループを選びます。

![](proposal_template_setting.png)

<!-- translation-section: edit-a-default-template -->

### 既定のテンプレートを編集する

**同意**などの既定のテンプレートを調整するには、アクションメニューを開いて**テンプレートの編集**を選択します。この操作はグループ管理者が行えます。保存すると、グループ専用のテンプレートが作成され、既定のテンプレートはグループのテンプレート一覧で非表示になります。

![テンプレートの編集アクションが表示された既定の同意テンプレート](edit_default_template.png)

<!-- translation-section: configure-the-template -->

## テンプレートの設定

テンプレートをどのようなときに使うかがわかる名前とサブタイトルを付けます。ほかの項目も、再利用しやすいように変更できます。**テンプレートを保存**を選択すると、新しい提案やアンケートを開始するときに、そのテンプレートが一覧に表示されます。

[![方針変更の同意プロセス用テンプレートのフォーム全体](poll_template_new.png)](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### テンプレートのタイトル、サブタイトル、ヘルプ

タイトルとサブタイトルで、どのようなときにテンプレートを選ぶかを説明します。**テンプレートのヘルプ**には、進め方の説明、決定のルール、参考資料へのリンクを記載します。

<!-- translation-section: voting-method -->

### 投票方法

参加者に何を表明してもらうかと、結果をどのように計算するかを選びます。

- **提案**: あらかじめ定めた立場を選んで、提示された内容に回答します。
- **選ぶ**: 1つ以上の選択肢を選びます。
- **スコア**: すべての選択肢を尺度に沿って評価します。
- **配分**: 限られた持ち点を配分します。
- **ランク**: 選択肢を希望順に並べます。
- **日程調整**: 都合のよい日時を示します。
- **STV**: 複数の当選者を比例的に選ぶ選挙で、候補者を希望順に並べます。

投票方法を変更すると、テンプレートで利用できる項目と結果の計算方法が変わります。

<!-- translation-section: example-title-details-and-tags -->

### タイトル、詳細、タグの例

投票ごとに異なる内容が必要な場合は、タイトルと詳細の例に、記入を促す文を使います。分類用のタグを初期設定に追加するのは、そのテンプレートを使うたびに適用できる場合だけにします。

<!-- translation-section: response-options -->

### 回答の選択肢

提案や選択などの投票方法では、回答の選択肢を設定できます。選択肢の横にある鉛筆アイコンを選択すると、次の項目を編集できます。

- **選択肢名**: 回答を示す短いラベルです。
- **アイコン**: 選択肢を視覚的に示す目印です。
- **意味**: その選択肢を選ぶことで何を表明するかを示します。
- **理由のプロンプト**: 回答の理由を説明するときに表示される質問です。

![](poll_type_edit_option.png)

参加者が推測せずに違いを理解できるよう、選択肢を定めます。それぞれの意味は、グループが実際に使っている決定のルールに合わせます。

<!-- translation-section: duration-and-settings -->

### 期間と設定

テンプレートの通常の用途に適した期間を初期設定として指定します。作成者は、個別の投票の締め切り日時を変更できます。

ほかの初期設定では、結果の公開範囲、匿名投票、[加重投票](../weighted_voting/)、投票理由の必須設定、リマインダー、定足数、投票方法ごとの動作を設定できます。それぞれの効果については、[提案とアンケートの設定](../settings/)を参照してください。

<!-- translation-section: manage-the-template-list -->

## テンプレートを管理する

テンプレートの横にある操作メニューから、次の操作ができます。

- **編集**: 再利用する内容と初期設定を編集します。
- **動く**: 一覧内の別の位置に移動します。
- **隠れる**: 投票を開始する人に表示されないようにします。
- **消去**: 不要になった独自のテンプレートを削除します。

![グループのテンプレート一覧で、方針変更の同意プロセス用テンプレートの操作メニューを開いた様子](template_manage.png)

**非表示のテンプレートを表示**を選択すると、非表示にしたテンプレートを確認したり、再表示したりできます。標準のテンプレートは非表示にしたり、グループに合わせて編集したりできますが、削除はできません。

テンプレートを変更しても、そのテンプレートからすでに開始した提案やアンケートは変更されません。

<!-- translation-section: who-can-manage-templates -->

### テンプレートを管理できる人

グループ管理者は、グループ内のすべてのアンケートテンプレートを作成、管理できます。**グループ設定** → **権限**で、**メンバーはテンプレートを作成できます**を有効にできます。有効にすると、メンバーはテンプレートを作成し、自分が作成したテンプレートを管理できます。
