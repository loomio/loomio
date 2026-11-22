---
title: スレッドの使い方
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/discussions/using_discussions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: f04bfcfd5d767c24
  thread-anatomy: 8c8f6393917dc4e4
  discussion-context: 82cfa27c1c3e6161
  notify-people-about-context-changes: 89165c012a1a710e
  navigation: e9cbf404a9e80417
  notifications-and-members: 21bb3b5d392c31c2
  email-notifications-for-this-thread: 3815be85f7e40239
  invite-people: 4759f5db4b8b6c31
  seen-by: 881b42cd1a2fed4d
  notified: cdfc025813eb6d6b
  actions: 2a239569629d46a9
  print: b626084908f85a8c
  markdown: f6468648c2fd6b91
  thread-settings-and-display: 9e1723af3ef1c96f
  pin-or-unpin-a-thread: 25265a99d3883d8f
  move-a-thread: 4d7231526110d371
  lock-or-unlock-a-thread: 5702025c2201f41f
  delete-a-thread: afd0742cbbb13eea
generated:
  introduction: 6cde0ae4f6ae3034
  thread-anatomy: df6ba6e7a21f6736
  discussion-context: 166d790b7fdbd30d
  notify-people-about-context-changes: a3e21a5f3adfdd2f
  navigation: 61cd2f7865f08475
  notifications-and-members: a88f9b3596e05958
  email-notifications-for-this-thread: 8c89b5bfdb61217f
  invite-people: 2d41f8db28d39218
  seen-by: 9c15b6c4f0cd00bc
  notified: 307e1a84b8c040c3
  actions: 8a7e22b741e11b00
  print: d5ee0f43f6df3f67
  markdown: 30eb9bb489dd5e6a
  thread-settings-and-display: ed1b144d3bc4720d
  pin-or-unpin-a-thread: b66cece092f9d57d
  move-a-thread: 3c6da7170d21c219
  lock-or-unlock-a-thread: 2792a645c129e715
  delete-a-thread: 1e6f9b883306a42e
title_source: 99e2d1eb313f35c4
title_generated: 1a2d46d8965028c7
needs_review:
  markdown: check the interface label "**賛成**" for "**Agree**"
---

<!-- translation-section: introduction -->

# スレッドの使い方

ディスカッションでは、背景説明、コメント、アンケート、結論を1つのスレッドにまとめます。このページでは、スレッドへの参加方法と、ナビゲーション、設定、操作の使い方を説明します。

<!-- translation-section: thread-anatomy -->

## スレッドの構成

一般的なスレッドは次のように表示されます。

![](thread_navigation.png)

スレッドの主な構成要素は次のとおりです。

- **グループ名** — スレッドが属するグループまたはサブグループに戻るリンクです。
- **アクセス設定** — スレッドを閲覧できる人を示します。グループのディスカッションは、グループのプライバシー設定に従って、グループのメンバーと、そのディスカッションに招待された人が閲覧できます。
- **カテゴリタグ** — タイトルの下に表示されるラベルで、関連するディスカッションをまとめます。
- **ディスカッションの背景説明** — スレッドの先頭にある投稿で、リアクションや編集の操作があります。
- **コメントとアンケート** — 背景説明の下に投稿される返信、アンケート、結論です。それぞれにリアクションなどの操作があります。
- **右側のサイドバー** — 節目へのショートカット（**ジャンプ**）、通知設定、**で見られる**と**通知済み**の一覧、スレッドの操作があります。

<!-- translation-section: discussion-context -->

## ディスカッションの背景説明

**背景説明**はスレッドの先頭にあり、会話や決定の目的と前提を説明します。

![](thread_context.png)

ディスカッションを開始するときに背景説明を書き、鉛筆アイコン（**編集**）で更新できます。会話が進むにつれて、新しい背景情報、議題、最終的な結論を背景説明に追加できます。

テキスト入力欄の下にある書式設定バーでは、テキストの書式設定、ファイルの添付、画像の挿入、動画の埋め込みができます。[テキストの書式設定とファイルの添付](/en/user_manual/discussions/formatting/)を参照してください。

![](thread_context_edit.png)

<!-- translation-section: notify-people-about-context-changes -->

### 背景説明の変更を通知する

背景説明を編集するときは、**何が変わったのでしょうか？**に更新内容の要約を入力し、通知する人を選択します。

![変更内容の要約と通知先を指定してディスカッションの背景説明を編集する画面](../notifying_people/thread_editcontext.png)

スレッドには、背景説明を編集したことが記録され、通知先に選んだ人には要約が届きます。

![ディスカッションの背景説明が編集されたことを示すスレッド内の項目](../notifying_people/thread_edit_comment.png)

<!-- translation-section: navigation -->

## ナビゲーション

右側のサイドバーの**ジャンプ**から、スレッド内を移動できます。

- **始める**はディスカッションの背景説明に移動します。
- **あなたにとって新しい**は、スレッドに未読のアクティビティがあるときに表示されます。
- **最新**は、読み込まれている項目よりも新しいアクティビティがあるときに表示されます。
- 節目のリンクは、重要なコメント、アンケート、結論に直接移動します。
- **終わり**はスレッドの最新の項目に移動します。

H2またはH3の見出しを含むコメント、アンケート、提案は、節目のリンクとして自動的に表示されます。節目を選択すると、その項目に移動します。

![](thread_timeline_1.png)

コメント、アンケート、投票、結論を投稿すると、Loomioは本人が投稿した項目を既読にします。

<!-- translation-section: notifications-and-members -->

## 通知とメンバー

右側のサイドバーでは、スレッドのメール通知を設定できるほか、招待された人、スレッドを見た人、通知された人を確認できます。

<!-- translation-section: email-notifications-for-this-thread -->

### このスレッドのメール通知

現在の通知設定を選択すると、すべてのアクティビティについてメールを受け取る、自分が通知先に指定されたアクティビティのみ受け取る、メールを受け取らない、のいずれかを選べます。すべてのアクティビティについてメールを受け取る設定では、活発なスレッドから多くのメールが届く場合があります。

![ディスカッションのサイドバーで通知されたときにメールを受け取る設定を選択した状態](../notifying_people/thread_interact.png)

<!-- translation-section: invite-people -->

### 人を招待する

右側のサイドバーの**メンバーを招待する**を選択すると、人を招待したり、スレッドについて通知したりできます。グループ、サブグループ、親グループ、ゲスト、チャットルームについて詳しくは、[ディスカッションに人を招待する](/en/user_manual/discussions/inviting_people)を参照してください。

<!-- translation-section: seen-by -->

### 閲覧した人

**で見られる**には、スレッドを開いた人と、その日時が表示されます。重要な情報を関係者が見たかどうかを確認できます。

![スレッドのメンバー欄にある閲覧状況と通知済みの表示](../notifying_people/thread_engagement.png)

![スレッドのメンバーを一覧表示する閲覧状況ウィンドウ](../notifying_people/thread_seenby.png)

<!-- translation-section: notified -->

### 通知済み

**通知済み**を選択すると、招待、メンション、返信を含むスレッドの通知履歴が開きます。通知された人が表示され、既読情報が確認できる場合は、各通知が読まれたかどうかも表示されます。

![ディスカッションの通知履歴](../notifying_people/thread_notified.png)

<!-- translation-section: thread-settings-and-display -->

<a id="thread-settings-and-display"></a>

## スレッド設定

スレッド管理者とグループ管理者は、**スレッド設定**を選択して返信の配置を変更したり、ディスカッションのその他の設定を行ったりできます。

![](thread_display.png)

![レイアウト、アンケートの制限、添付権限、コメントの文字数制限を含むスレッド設定](thread_layout_options.png)

### レイアウト

**年代順**を選択すると項目が投稿順に表示され、**入れ子構造**を選択すると返信が返信先の項目の下にまとめて表示されます。この変更は、スレッドを利用する全員のレイアウトに適用されます。

<a id="allow-multiple-polls-at-the-same-time"></a>

### 同時に実施できるアンケートは1つのみ

チェックを入れると、現在のアンケートが締め切られるまで、誰も別のアンケートを開始できなくなります。新しいスレッドでは、既定でチェックが外れています。ディスカッションのテンプレートから開始したスレッドには、そのテンプレートの設定が適用されます。

### 管理者のみ添付可能

この設定を有効にすると、アンケートへの回答やメールでの返信を含め、スレッド全体で新しいファイルや本文中の画像を追加できるのは、スレッド管理者とグループ管理者のみになります。既存の添付ファイルは引き続き利用でき、参加者は自分の文章の編集や添付ファイルの削除を引き続き行えます。

ディスカッションやアンケートのテンプレートで、新しいスレッドに適用するこの設定を指定できます。[ディスカッションのテンプレート](/en/user_manual/discussions/templates)と[アンケートのテンプレート](/en/user_manual/polls/poll_templates)を参照してください。

### コメントの文字数制限

返信を簡潔にするために、コメントごとの最大文字数を設定できます。制限しない場合は空欄にします。この制限は、グループ管理者とスレッド管理者を含む全員に適用されます。

<!-- translation-section: actions -->

## 操作

右側のサイドバーには、スレッド全体に対する操作が一覧表示されます。一部の操作は、グループページのスレッドの横にある三点メニュー（**⋯**）にも表示されます。

表示される操作は権限によって異なります。グループ管理者はスレッドを管理でき、グループの設定によっては、メンバーにも一部の管理操作が許可されます。[グループの権限](/en/user_manual/groups/settings/permissions)を参照してください。

![](thread_admin.png)

<!-- translation-section: print -->

### 印刷

**印刷する**を選択すると、スレッドを印刷に適した表示で開きます。ブラウザーの印刷ダイアログを使うと、PDFとして保存できます。

![](thread_print_thread.png)

<!-- translation-section: markdown -->

### Markdown

**Markdown**を選択すると、スレッドを構造化されたMarkdownとしてエクスポートできます。**マークダウンをコピー**を選択するとクリップボードにコピーでき、**Markdownをダウンロード**を選択すると、議事録、記録の保存、文書、AIツールなどに使う`.md`ファイルとして保存できます。

![](../discussion_management/copy_markdown_menu.png)

エクスポートした文書の冒頭には、スレッドのキー、URL、グループ、日時、タグを含むYAMLフロントマターがあります。その後に、ディスカッションの背景説明とすべてのコメント、アンケート、投票、結論が、スレッドの順序と入れ子構造に沿って含まれます。各アンケートは一つのセクションになり、コメント、投票、結論は、投稿者、投稿日時、項目番号、リアクションを示す引用形式で表示されます。

Loomioは、スレッドの公開範囲のルールを適用します。非表示の結果や投票の理由は含まれず、匿名アンケートでは投票者を特定できる情報は表示されません。投票するまで結果が非表示になる受付中のアンケートがある場合は、先に投票してください。投票するまで、**Markdown**と**印刷する**は利用できません。

例えば、コメント、リアクション、提案、2件の投票、返信、結論を含むディスカッションからは、次のMarkdownが生成されます。

```markdown
---
key: "fi2TAgeC"
url: "https://www.loomio.com/d/fi2TAgeC/returnable-bottles-for-cafe-customers"
group: "Oatmilk Cooperative"
created: "2026-09-10T23:28:30Z"
last_activity: "2026-09-10T23:28:30Z"
---

# Discussion: Returnable bottles for cafe customers · Samira Patel · 2026-09-10 23:28

Several cafe customers have asked whether we can supply oat milk in returnable glass bottles. This thread is for working through the practical questions before we decide whether to run a trial. 🥛

**We need a plan that cafe staff can explain easily** , including the deposit, collection days, and what happens when a bottle is damaged or not returned.

Please read the [draft bottle return guide](https://example.com/oatmilk-bottle-return-guide) and add any questions about washing capacity, food-safety checks, transport costs, or weekly reporting.

> **Alex Morgan** · 2026-09-10 23:28 · #1 · 👍 Jamie Chen, Samira Patel
>
> I can ask three cafes to track how many bottles are returned each week.

## Proposal: Run a six-week returnable bottle trial · Jamie Chen · 2026-09-10 23:28 · #2

- **Status:** Closed 2026-09-10T23:28:30Z
- **Options:** Agree; Abstain; Disagree

Supply returnable glass bottles to three cafe customers for six weeks, with one collection from each cafe every week.

<mark>Before launch, confirm the deposit guidance and the food-safety record for every washed batch.</mark>

| Measure | Review |
| --- | --- |
| Return rate | Weekly |
| Cleaning time | Each batch |
| Transport cost | End of trial |

### Current results

| Option | Votes | % of votes cast | % of eligible voters | Voters |
| --- | --- | --- | --- | --- |
| Agree | 1 | 50% | 33% | Samira Patel |
| Abstain | 1 | 50% | 33% | Alex Morgan |
| Disagree | 0 | 0% | 0% | No voters |
| Not voted | 1 |  | 33% | Jamie Chen |

> **Samira Patel** voted **Agree** · 2026-09-10 23:28 · #3 · ❤️ Jamie Chen
>
> The six-week trial gives us enough time to test collections and washing capacity.
>
> > **Alex Morgan** · 2026-09-10 23:28 · #4
> >
> > Could we confirm which cafes will participate before the trial starts?

> **Alex Morgan** voted **Abstain** · 2026-09-10 23:28 · #5
>
> I can support the trial once the collection dates are confirmed with each cafe.

> **Jamie Chen** shared an outcome · 2026-09-10 23:28 · #7
>
> Run the six-week bottle trial with three cafes. Review return rates, washing time, and transport costs each week.
```

見出しとラベルには、選択した言語が使われます。参加者が書いた内容は、元の言語のままです。

<!-- translation-section: pin-or-unpin-a-thread -->

### スレッドのピン留めと解除

ピン留めされたスレッドは、グループページの上部に表示されます。グループでは、新しいメンバーを迎えるディスカッション、ニュース、お知らせなどをよくピン留めします。

グループページでスレッドの横にある三点メニュー（**⋯**）を開き、**スレッドを固定**を選択します。ピン留めされたスレッドは、ピン留めした日時の順に並びます。順序を変更するには、ピン留めを外してから再度ピン留めします。

**スレッドのピン留めを外す**を選択すると、スレッドは通常のアクティビティに基づく表示順に戻ります。

![](../discussion_management/pin_thread.png)

<!-- translation-section: move-a-thread -->

### スレッドの移動

**スレッドを移動**を選択すると、スレッドを別のグループやサブグループに移動したり、ダイレクトスレッドに変更したりできます。移動先のグループのメンバーと、そのスレッドに招待された人が閲覧できるようになります。

移動する前に、Loomioはアクセスできなくなる人数を表示します。通知を送信せずに、その人たちをゲストとして残すことができます。

- **別のグループやサブグループへの移動：** ゲストとして残すには、移動先のグループでゲストを招待する権限が必要です。既存のゲストは引き続きアクセスできます。
- **ダイレクトスレッドへの変更：** 参加したことがある人は、自動的に引き続きアクセスできます。ゲストとして残す設定を選択すると、その他の現在のメンバーとゲストも引き続きアクセスできます。変更を行った人とスレッドの作成者がスレッド管理者になります。

![](../discussion_management/move_thread_select.png)

>[!Tip]
>ダイレクトスレッドのディスカッション、または非公開のサブグループで下書きを作成し、準備ができたらグループに移動します。

スレッド全体ではなく、特定の項目を移動する方法については、[スレッド間での項目の移動](/en/user_manual/discussions/moving_items/)を参照してください。

<!-- translation-section: lock-or-unlock-a-thread -->

### スレッドのロックと解除

スレッドをロックすると、そのままの状態で保存できます。ロックされたスレッドでは、誰も投稿、編集、招待を行えません。スレッドをロックできるのは、実施中のアンケートがすべて締め切られた後です。

**行動**の下にある**スレッドをロック**を選択します。ロックされたスレッドは、進行中のディスカッションの一覧から除外され、**ロック済み**のタグが付きます。

ロックされたスレッドを探すには、グループページでディスカッションのフィルターを開き、**ロック済み**を選択します。スレッドを開いて**スレッドのロックを解除**を選択すると、再びコメントや変更ができるようになります。

<!-- translation-section: delete-a-thread -->

### スレッドの削除

スレッドを削除すると完全に削除され、元に戻せません。後で必要になる可能性がある場合は、スレッドをロックしてください。

**スレッドの削除**を選択し、削除を確定します。

![](../discussion_management/thread_delete.png)
