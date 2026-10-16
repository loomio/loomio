---
title: ユーザーAPI
source_revision: 28ecc59f68d407f76f08133bfa0172aadbb53065
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-15'
sections:
  introduction: b6e6ec7463276869
  response-size-and-related-records: 298da635bf97dadd
  endpoint-summary: 258f7560def524ec
  groups: 0473f1f7fb78f074
  list-groups: 01de10c378eeba37
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: 6093df92815f7156
  create-a-webhook: 007312bcc204853a
  update-a-webhook: 124b07d2c401e319
  test-a-webhook-destination: 8fc3ac4ad10de6f6
  delete-a-webhook: 34eda1e07d65db80
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: bb5a1cfc7a6179aa
  params: 7eebe4e259830976
  participation-report: a1798112a78390fe
  params-2: 464322ffc1ac56e5
  example: 63bed6e82107f992
  create-discussion: 958fc684640462a9
  params-3: 657d582c89333097
  example-2: 57681d83fffe9515
  show-discussion: 40102aeffe4f1286
  example-3: c0ebd013a1b7fbd2
  list-discussions: '09ff7f0d3a937b41'
  params-4: dcebc294fbb9d837
  example-4: ffda1a4726380e2f
  list-threads: '09f7bd670e581400'
  params-5: 79b1cefac558effc
  example-5: a40ae2317faab46d
  read-thread: ac36d1b81c1eeed4
  example-6: 8c582a286e04ca75
  edit-discussion: 918161e7aa8f4aa6
  params-6: b819796d34354623
  example-7: 552295f78d3490af
  soft-delete-discussion: c8ffe951171e6f07
  example-8: 965c5761f34f9920
  create-comment: f95f56b81c8f22b5
  params-7: 5ad8ede0919c5f47
  example-9: 70ee3750f1543e9b
  edit-comment: 80322da74162d58f
  params-8: 288331c60f3c9b28
  example-10: ec89de8cc86b6fc8
  soft-delete-comment: 04baf86923c7e8f1
  example-11: f3675b780da755cd
  create-poll: cf62e787784a5e87
  params-9: df1611a9dedef2d8
  example-12: fa7410dd3a0a385f
  show-poll: d759508986aab08c
  example-13: 2867289a6c2beb9d
  list-polls: 56e5ed4ae45e5428
  params-10: e68e8cf62b21488d
  example-14: 40958a09c058d4cc
  edit-poll: 65467ad0b431ddbf
  params-11: 77f118397592bc05
  example-15: e56befa0f2ae3360
  soft-delete-poll: 61cf76310e08d7ff
  example-16: afbf95df96734a4d
  list-memberships: 5fab06bb8ecf1fd0
  params-12: decaff0790566fb0
  example-17: 5d92092b70ce545a
  manage-memberships: 802d39c06674d395
  params-13: 771b5338a4ba3d0b
  example-18: a50b01823a6935a0
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
generated:
  introduction: 9da9960a32538ae1
  response-size-and-related-records: 9a95d0eda8dfb508
  endpoint-summary: b92be0b615dc4c99
  groups: 95e133438e155e03
  list-groups: 2d0b6168f54f3af9
  get-a-group: 7830c66e98310029
  webhooks: a97fdb82fc1bf29e
  list-webhooks: 1798cef1adf8f7ae
  create-a-webhook: f1d3af8c65abed95
  update-a-webhook: c7ca6006b3319fe6
  test-a-webhook-destination: 6ef63f6f3927f257
  delete-a-webhook: fa05cd9105fe6559
  event-types: 58b300d9c7dff84b
  http-delivery: d426ce00962fbf95
  payload-formats: 7f06ed33b553976f
  search: 76bd16eff39d8e6e
  params: e825314583844ba8
  participation-report: 9451a8c2e0e36f7a
  params-2: 52cec69d241a4f8a
  example: 69849361e6ddd8a6
  create-discussion: 60ea2a9eef8d86a0
  params-3: 220f2f80da75ae28
  example-2: 20ac4d891c4c5be5
  show-discussion: a5905cd4d0f00103
  example-3: 5999591fc3fdc5fe
  list-discussions: 1314660e24d2dcaa
  params-4: 10d24176aa54c5b1
  example-4: 215961baca984d84
  list-threads: aef85b72536459f0
  params-5: b174e3f7ed633494
  example-5: b452bd91ddc27e1f
  read-thread: 01aeb93c94183d02
  example-6: 8b9b96c1954fc695
  edit-discussion: 1bf1646e5788cb13
  params-6: 5b5bafc2621bce4f
  example-7: d31868a3a07137d3
  soft-delete-discussion: 4e6e3e809585735b
  example-8: 8668370bfe6c9bcf
  create-comment: 36862355490530bb
  params-7: f641417d13ce4bb8
  example-9: 9ba5ea9827a5d056
  edit-comment: db1e5e13a126fdcd
  params-8: 016f76a103d930e4
  example-10: c63bb38414a488cf
  soft-delete-comment: 5878a2556e0bebd8
  example-11: 2db3578935c73e40
  create-poll: 5d4d3976844cc546
  params-9: c770bb7be72d7ba2
  example-12: cdd05d2c0c52f5af
  show-poll: 0afa4c044d2a5a4e
  example-13: 3dc7eb8975517c53
  list-polls: 202be987ea0cf89c
  params-10: d63c307be555d850
  example-14: 6360b30322cc4cbe
  edit-poll: 6174c701515e30be
  params-11: 00db866433098d9f
  example-15: 2f06f262cd54794d
  soft-delete-poll: d458ec93f7cc43b0
  example-16: 957d900d42630f65
  list-memberships: 349e28939f2855b6
  params-12: 86c22f1ce78077b5
  example-17: c37f5cf610df7358
  manage-memberships: ad89014e0b273ef8
  params-13: aab3e7cf0b72b2e6
  example-18: d9a65d79f5ecc0e8
  pagination: 37d5df239aa8c9b0
  comments: 329bd304204146ee
  discussions: 314a377991d455fd
  memberships: e105d51243cc1ae0
  polls: 53518c90603f9924
  threads: 61f8fceb9c2cc2e3
title_source: c23fb6526b722360
title_generated: 9d80e3857ccdabb2
---

<!-- translation-section: introduction -->

# LoomioユーザーAPIドキュメント

<!-- seo-description: LoomioユーザーAPIを使用して、他のソフトウェアからディスカッション、コメント、アンケート、スレッド、グループのメンバー登録を作成・管理できます。 -->

`/api/b2`は、Loomioとの連携に使用するユーザー向けAPIです。ユーザーアカウントのAPIキーを使用し、すべての操作はそのユーザーとして実行されます。

グループに対する操作には、APIキーのユーザーのメンバー登録とグループ権限が適用されます。インスタンス管理者であっても、APIキーでアクセスできるグループやコンテンツの範囲は広がりません。インスタンス全体の管理にはサーバーAPIを使用してください。

操作を実行するLoomioユーザーアカウントのAPIキーを使用してください。連携用のアカウントをアンケートに招待したり、通知を送信したりする必要がない場合は、専用のボットアカウントが役立ちます。

ログインしているユーザーは、[APIアクセスページ](/profile/api_access)でAPIキーとグループIDを確認できます。

APIキーは`Authorization: Bearer`ヘッダーで送信してください。URLはプロキシやアクセスログに記録される可能性があるため、クエリ文字列に含まれるAPIキーは拒否されます。

```text
Authorization: Bearer YOUR_API_KEY
```

例では、`YOUR_API_KEY`、グループID`123`、`https://www.loomio.com/`を使用しています。使用するAPIキー、グループID、Loomioのインストール先URLに置き換えてください。

<!-- translation-section: endpoint-summary -->

## エンドポイント一覧

| メソッド | エンドポイント | 用途 |
| --- | --- | --- |
| `POST` | `/api/b2/comments` | コメントまたは返信を作成します |
| `PATCH` | `/api/b2/comments/:id` | コメントを編集します |
| `DELETE` | `/api/b2/comments/:id` | コメントを論理削除します |
| `POST` | `/api/b2/discussions` | ディスカッションを作成します |
| `GET` | `/api/b2/discussions/:id` | ディスカッションを取得します |
| `GET` | `/api/b2/discussions` | グループ内のディスカッションを一覧表示します |
| `PATCH` | `/api/b2/discussions/:id` | ディスカッションを編集します |
| `DELETE` | `/api/b2/discussions/:id` | ディスカッションを論理削除します |
| `GET` | `/api/b2/groups` | APIキーのユーザーのグループを一覧表示します |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | 閲覧できるグループを取得します |
| `GET` | `/api/b2/memberships` | グループのメンバー登録を一覧表示します |
| `POST` | `/api/b2/memberships` | メンバーを追加し、必要に応じてリストに含まれないメンバーを削除します |
| `GET` | `/api/b2/reports` | 参加状況レポートを生成します |
| `POST` | `/api/b2/polls` | アンケートを作成します |
| `GET` | `/api/b2/polls/:id` | アンケートを取得します |
| `GET` | `/api/b2/polls` | グループ内のアンケートを一覧表示します |
| `PATCH` | `/api/b2/polls/:id` | アンケートを編集します |
| `DELETE` | `/api/b2/polls/:id` | アンケートを論理削除します |
| `GET` | `/api/b2/search` | 閲覧できるディスカッション、コメント、アンケート、投票、結論を検索します |
| `GET` | `/api/b2/threads` | 閲覧できるディスカッションのスレッドと単独のアンケートのスレッドを一覧表示します |
| `GET` | `/api/b2/threads/:topic_id` | スレッドを取得します |
| `GET` | `/api/b2/threads/:topic_id/items` | スレッド内の項目を順序付きで取得します |
| `GET` | `/api/b2/threads/:topic_id/markdown` | スレッド全体をMarkdownで取得します |
| `GET` | `/api/b2/chatbots` | グループのチャット連携とWebhookを一覧表示します |
| `POST` | `/api/b2/chatbots` | チャット連携またはWebhookを作成します |
| `PATCH` | `/api/b2/chatbots/:id` | チャット連携またはWebhookを更新します |
| `DELETE` | `/api/b2/chatbots/:id` | チャット連携またはWebhookを削除します |
| `POST` | `/api/b2/chatbots/check` | Webhookの接続テストを送信します |

<!-- translation-section: pagination -->

## ページ分割

ディスカッション、グループ、メンバー登録、アンケート、スレッド、スレッド内の項目、Webhookでは、`limit`（既定値`50`）と`offset`（既定値`0`）を指定できます。グループ、スレッド内の項目、Webhookでは、`limit`の上限は`500`です。

次のページを取得するには、返された主要レコードの件数だけ`offset`を増やしてください。`meta.total`は条件に一致する全件数です。関連レコードはページの件数に含まれません。

参加状況レポートは要求されたデータ全体を返し、検索は最大20件の結果を返します。どちらもページ分割には対応していません。

ディスカッション、アンケート、メンバー登録では、従来の別名である`per`（`limit`に対応）と`from`（`offset`に対応）も指定できます。新しい連携には`limit`と`offset`を使用してください。

<!-- translation-section: response-size-and-related-records -->

## 関連レコード

ユーザーAPIのレスポンスは複合形式を使用します。主要レコードに加えて、トピック、グループ、ユーザー、アンケート、リアクションなどの関連レコードが含まれます。これにより、クライアントは1回のリクエストでローカルのレコードストアにデータを格納できますが、単純な連携に必要な量を超えるデータが含まれる場合があります。

`compact=1`を指定すると、データ量の多い関連トピック、グループ、親グループ、メンバー登録、リアクション、タグ、翻訳を省略できます。主要レコードと、その内容を解釈するために必要な関連レコードは引き続き含まれます。

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

省略する種類を直接指定するには、単数形のレコード種別をスペースで区切って`exclude_types`に指定します。例えば、`exclude_types=group reaction`は関連するグループとリアクションを省略します。よく使われる値は、`topic`、`group`、`parent`、`membership`、`reaction`、`tag`、`translation`、`user`、`discussion`、`poll`、`poll_option`、`stance`、`stance_choice`、`outcome`（結論）、`topic_item`です。除外は関連レコードに適用され、エンドポイントで要求した主要リソースには適用されません。

コレクションのレスポンスには、正確な件数が定義されている場合に`meta.total`が含まれます。合計件数は、`limit`と`offset`を適用する前に計算されます。検索など、意図的に返す件数を制限しているエンドポイントでは、`null`を返す代わりに`meta.total`を省略します。

<!-- translation-section: comments -->

## コメント

<!-- translation-section: create-comment -->

### コメントの作成

APIキーのユーザーとしてディスカッションにコメントを作成します。

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `discussion_id` | 整数、必須。コメントを投稿するディスカッションのIDです |
| `body` | コメントの本文です。添付ファイルがない場合は必須です |
| `body_format` | `md` または `html`、任意。既定値は `md` です |

<!-- translation-section: example-9 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

### コメントの編集

APIキーのユーザーとしてコメントを編集します。Loomioと同じ権限が適用されるため、そのユーザーには対象のコメントを編集する権限が必要です。

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `body` | 更新後のコメント本文です |
| `body_format` | `md` または `html`、任意。既定値は `md` です |

<!-- translation-section: example-10 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

### コメントの論理削除

APIキーのユーザーとしてコメントを論理削除します。コメントは削除済みになり、本文は非表示になりますが、レコードは保持されます。

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: discussions -->

## ディスカッション

<!-- translation-section: create-discussion -->

### ディスカッションの作成

APIキーのユーザーとしてディスカッションを作成します。

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `group_id` | スレッドを作成するグループです |
| `title` | スレッドのタイトルです。必須です |
| `description` | スレッドの背景説明です。任意です |
| `description_format` | `md`または`html`です。任意で、既定値は`md`です |
| `recipient_audience` | `group`またはnullです。`group`の場合は、新しいスレッドについてグループ全体に通知します |
| `recipient_user_ids` | 通知するユーザー、またはスレッドに招待するユーザーのIDの配列です |
| `recipient_emails` | スレッドに招待する人のメールアドレスの配列です |
| `recipient_message` | 招待メールに含めるメッセージです |

<!-- translation-section: example-2 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

### ディスカッションの取得

整数のディスカッションID、または文字列のキーを使ってディスカッションを取得します。

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

### ディスカッションの一覧取得

グループ内でAPIキーのユーザーが閲覧できるディスカッションの一覧を取得します。公開グループでは、メンバーでなくても公開ディスカッションの一覧を取得できます。非公開ディスカッションは、Loomioでその内容を閲覧できるユーザーのみが取得できます。

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数です。必須です。ディスカッションの一覧を取得するグループのIDです |
| `status` | 文字列です。任意で、既定値は`open`です。値は`open`、`closed`、`all`です |
| `limit` | 整数です。任意で、既定値は50です。1ページあたりの件数です |
| `offset` | 整数です。任意で、既定値は0です。ページ分割のオフセットです |

従来のパラメーター：`per`と`from`は、それぞれ`limit`と`offset`の別名として受け付けられ、引き続き使用できます。

<!-- translation-section: example-4 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: edit-discussion -->

### ディスカッションの編集

APIキーのユーザーとしてディスカッションを編集します。Loomioと同じ権限が適用されるため、そのディスカッションを編集する権限が必要です。

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `title` | 更新後のタイトルです |
| `description` | 更新後の背景説明です |
| `description_format` | `md`または`html`です。任意で、既定値は`md`です |
| `recipient_audience` | `group`またはnullです。`group`の場合は、編集についてグループ全体に通知します |
| `recipient_user_ids` | 通知するユーザー、またはスレッドに招待するユーザーのIDの配列です |
| `recipient_emails` | スレッドに招待する人のメールアドレスの配列です |
| `recipient_message` | 招待メールに含めるメッセージです |

<!-- translation-section: example-7 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

### ディスカッションの論理削除

APIキーのユーザーとしてディスカッションを論理削除します。ディスカッションは削除済みになりますが、レコードは保持されます。

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: groups -->

## グループ

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"s_count` | グループ管理者の人数です |\n| `delegates_count` | 代表者の人数です |\n| `discussions_count` | グループ直下のディス","after":"s_count` | グループ管理者の人数です |\n| `discussions_count` | グループ直下のディス"} -->

### グループの一覧取得

APIキーのユーザーが有効なメンバー登録を持つグループを返します。

`GET /api/b2/groups`

| 名前 | 説明 |
| --- | --- |
| `limit` | 整数、任意、既定値50、最大500。ページサイズ |
| `offset` | 整数、任意、既定値0。ページ分割のオフセット |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/groups?limit=50&offset=0'
```

レスポンスには、グループIDの昇順に並んだ`groups`の1ページ分が含まれ、`meta.total`には条件に一致するグループの総数が含まれます。親グループとサブグループが含まれ、現在サブスクリプションが有効でないグループも含まれます。有効なグループだけを連携の対象にする場合は、`enabled`フィールドを確認してください。

主なグループフィールドは次のとおりです。

| フィールド | 説明 |
| --- | --- |
| `id` | 他のユーザーAPIエンドポイントで使用する数値のグループIDです |
| `key` | LoomioのURLで使用する、変わらない短いキーです |
| `handle` | 人が読みやすいグループのハンドル名です |
| `name` | グループ名です |
| `full_name` | 親グループの情報を含むグループ名です |
| `parent_id` | サブグループの場合は数値の親グループID、それ以外は`null`です |
| `enabled` | グループとそのサブスクリプションが有効かどうかを示します |
| `memberships_count` | 有効なメンバー登録と承認待ちのメンバー登録の合計件数です |
| `accepted_memberships_count` | 承認済みのメンバー登録の件数です |
| `pending_memberships_count` | 承認待ちの招待の件数です |
| `admin_memberships_count` | グループ管理者の人数です |
| `discussions_count` | グループ直下のディスカッションの件数です |
| `polls_count` | グループ直下のアンケートの件数です |
| `subgroups_count` | サブグループの件数です |

レスポンスには、追加のグループ設定、関連する親グループのレコード、APIユーザーのメンバー登録が含まれる場合があります。クライアントでは、使用しないフィールドを無視してください。

<!-- translation-section: get-a-group -->

### グループの取得

APIキーのユーザーが閲覧できるグループを1件返します。

`GET /api/b2/groups/:id_or_key_or_handle`

識別子には、グループの数値ID、キー、ハンドル名を使用できます。

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

レスポンスには、一覧取得エンドポイントと同じフィールドを持つグループが`groups`配列に含まれます。APIキーのユーザーがアクセスできないグループを要求すると、権限エラーが返されます。

<!-- translation-section: memberships -->

## メンバー登録

<!-- translation-section: list-memberships -->

### メンバー登録の一覧取得

APIキーのユーザーが閲覧できるメンバー登録を一覧で取得します。グループのメンバーは、メンバーの名前、ID、肩書き、役割を閲覧できます。メールアドレスは、APIキーのユーザー自身のアカウントの場合、またはAPIキーのユーザーがグループ管理者の場合にのみ含まれます。

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数、必須。メンバー登録を一覧で取得するグループのID |
| `limit` | 整数、任意、既定値50。ページサイズ |
| `offset` | 整数、任意、既定値0。ページ分割のオフセット |

従来のパラメーターである`per`と`from`も、それぞれ`limit`と`offset`の別名として引き続き使用できます。

レスポンスには、`memberships`の1ページ分と関連する`users`が含まれます。`meta.total`は、ページ分割前の、グループ内で閲覧できるメンバー登録の総数です。

<!-- translation-section: example-17 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123&limit=50&offset=0'
```

<!-- translation-section: manage-memberships -->

### メンバー登録の管理

メールアドレスのリストを送信します。新しいメールアドレスすべてにグループへの招待を送ります。メンバー登録の一覧取得とは異なり、この操作にはグループ管理者の権限が必要です。

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数、必須。メンバー登録を管理するグループのID |
| `emails` | 文字列の配列、必須。グループに招待する人のメールアドレス |
| `remove_absent` | 真偽値。trueの場合、メールアドレスがリストに含まれていない人をグループから削除します |

<!-- translation-section: example-18 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

`remove_absent=1`を指定すると、リストに含まれていないグループのメンバーはすべてグループから削除されます。グループの全メンバーを削除する可能性があるため、注意してください。

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

この操作は、`{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`を含むオブジェクトを返します。

<!-- translation-section: participation-report -->

## 参加状況レポート

Loomioの参加状況レポートで使用されるものと同じ、集計済みの参加データを返します。

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### パラメーター

| 名前 | 説明 |
| --- | --- |
| `section` | レポートのセクションです。`base`、`users`、`countries`のいずれかを指定します。個人別の活動には`users`を使用します |
| `group_scope` | `custom`または`my`です。ユーザーAPIキーにはインスタンス全体へのアクセス権が付与されないため、旧形式の値`all`は`my`として扱われます |
| `group_ids` | `group_scope=custom`の場合に、グループIDをカンマ区切りで指定します。APIユーザーがメンバーとして所属していないグループのIDは無視されます |
| `start_month` | 集計対象の最初の月を`YYYY-MM`形式で指定します。既定値は12か月前です |
| `end_month` | 集計対象の最後の月を`YYYY-MM`形式で指定します。既定値は今月です |
| `interval` | `base`セクションの集計間隔です。`day`、`week`、`month`、`year`のいずれかを指定します |
| `member_type` | `section=users`とともに`delegate`を指定すると、現在の代表者のみを返します |

選択したグループのいずれかで、有効な代表者のメンバー資格を持つ人を代表者として扱います。件数は、選択したすべてのグループを通じて集計されます。すべての活動件数がゼロでも、代表者の行は返されます。集計対象はスレッド、コメント、アンケート、投票、結論、リアクションの件数であり、投票参加率ではありません。ユーザーの行には、記名式の投票について、投票権が付与された件数、投票済みの件数、未投票の件数も含まれます。匿名アンケートは、個人別のすべての投票件数から除外されます。`all_votes_cast`がtrueになるのは、少なくとも1件の投票権が付与され、付与されたすべての投票権について投票済みの場合のみです。

APIには、アプリ内のレポートと同じグループの閲覧権限が適用されます。ユーザーAPIキーでは、そのユーザーがアクセスできないグループのレポートデータを取得できません。

<!-- translation-section: example -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

`users`配列には、活動データの全項目を含む行が格納されます。

```json
{
  "users": [
    {
      "id": 456,
      "name": "Ada Lovelace",
      "country": "NZ",
      "delegate": true,
      "threads": 2,
      "comments": 8,
      "polls": 1,
      "votes": 5,
      "votes_cast": 5,
      "votes_issued": 6,
      "votes_missed": 1,
      "all_votes_cast": false,
      "outcomes": 1,
      "reactions": 4
    }
  ]
}
```

<!-- translation-section: polls -->

## アンケート

<!-- translation-section: create-poll -->

### アンケートの作成

APIキーのユーザーとしてアンケートを作成します。

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数、省略可能、既定値は null。アンケートが属するグループのIDです。`discussion_id` を指定した場合、`group_id` は無視されます |
| `discussion_id` | 整数、省略可能、既定値は null。このアンケートを追加するディスカッションのスレッドのIDです |
| `title` | 文字列、必須。アンケートのタイトルです |
| `poll_type` | 文字列、必須。値：`proposal`、`poll`、`count`、`score`、`ranked_choice`、`meeting`、`dot_vote` |
| `details` | 文字列、省略可能。アンケートの本文です |
| `details_format` | 文字列、省略可能、既定値は `md`。値：`md` または `html` |
| `options` | 文字列の配列。`poll_type` が `proposal` の場合、有効な値は `agree`、`disagree`、`abstain`、`block` です。`poll_type` が `meeting` の場合、ISO 8601形式の日付または日時の文字列を指定します。その他のアンケートの種類では、任意の文字列が有効です |
| `closing_at` | ISO 8601形式の文字列または null、既定値は null。例：`2026-09-01T12:00:00Z`。null の場合、投票は無効になり、アンケートは作成中として扱われます |
| `specified_voters_only` | 真偽値、省略可能、既定値は false。true の場合、指定された人だけが投票できます。false の場合、グループの全員が投票に招待されます |
| `hide_results` | 文字列、省略可能、既定値は `off`。値：`off`、`until_vote`、`until_closed` |
| `shuffle_options` | 真偽値、既定値は false。投票者に選択肢をランダムな順序で表示します |
| `anonymous` | 真偽値、省略可能、既定値は false。投票者が誰であるかを非表示にします |
| `recipient_audience` | `group` または null、省略可能、既定値は null。`group` の場合、グループ全体に通知されます |
| `notify_on_closing_soon` | 文字列、省略可能、既定値は `nobody`。値：`nobody`、`author`、`undecided_voters`、`voters` |
| `recipient_user_ids` | 通知または招待するユーザーのIDの配列です |
| `recipient_emails` | 投票に招待する人のメールアドレスの配列です |
| `recipient_message` | 招待メールに含めるメッセージです |
| `notify_recipients` | 真偽値、既定値は false。false の場合、通知を送信せずに人を追加します。true の場合、このリクエストで招待された全員に通知メールが送信されます |

<!-- translation-section: example-12 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

### アンケートの取得

整数のアンケートID、または文字列のキーを使用してアンケートを取得します。

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

### アンケートの一覧取得

グループ内でAPIキーのユーザーが閲覧できるアンケートの一覧を取得します。公開されているグループでは、メンバーでなくても公開アンケートの一覧を取得できます。非公開アンケートは、Loomioで閲覧権限を持つユーザーだけが取得できます。レスポンスには、閲覧可能な各アンケートの現在の結論が含まれるため、`status=closed` を使用すると、決定済みの提案の一覧を取得できます。

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数、必須。アンケートの一覧を取得するグループのIDです |
| `status` | 文字列、省略可能、既定値は `active`。値：`active`、`closed`、`all` |
| `limit` | 整数、省略可能、既定値は 50。1ページあたりの件数です |
| `offset` | 整数、省略可能、既定値は 0。ページ分割のためのオフセットです |

従来のパラメーター：`per` と `from` はそれぞれ `limit` と `offset` の別名として受け付けられ、引き続き使用できます。

<!-- translation-section: example-14 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

### アンケートの編集

APIキーのユーザーとしてアンケートを編集します。Loomioと同じ権限が適用されるため、そのユーザーには対象のアンケートを編集する権限が必要です。

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `title` | 更新後のタイトルです |
| `details` | 更新後のアンケートの詳細です |
| `details_format` | `md` または `html`、省略可能、既定値は `md` |
| `options` | 更新後の選択肢の名前です。選択肢を変更すると、アンケートの状態によっては既存の投票に影響する場合があります |
| `closing_at` | ISO 8601形式の文字列または null |
| `recipient_audience` | `group` または null。`group` の場合、グループ全体に通知されます |
| `recipient_user_ids` | 通知または招待するユーザーのIDの配列です |
| `recipient_emails` | 投票に招待する人のメールアドレスの配列です |
| `recipient_message` | 招待メールに含めるメッセージです |

<!-- translation-section: example-15 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

### アンケートの論理削除

APIキーのユーザーとしてアンケートを論理削除します。アンケートを削除済みとして扱い、アンケートのレコードは保持します。

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: search -->

## 検索

APIキーのユーザーが閲覧できるディスカッション、コメント、アンケート、投票、結論を検索します。グループのメンバーでなくても、そのグループの公開コンテンツは結果に含まれます。非公開コンテンツには、通常のトピックの閲覧権限が適用されます。

`GET /api/b2/search`

<!-- translation-section: params -->

### パラメーター

| 名前 | 説明 |
| --- | --- |
| `query` | 検索するテキストです。完全一致とあいまい一致に対応しています |
| `group_id` | 結果を閲覧可能な1つのグループに限定します |
| `org_id` | 結果を閲覧可能な親グループと、その閲覧可能なサブグループに限定します。ダイレクトディスカッションには`0`を使用します |
| `type` | 結果を`Discussion`、`Comment`、`Poll`、`Stance`、`Outcome`のいずれか1種類に限定します |
| `types` | 結果の種類をカンマ区切りで指定します |
| `tag` | 結果をこのタグが付いたトピックに限定します |
| `author_id` | 結果を1人の作成者によるコンテンツに限定します。`query`を指定しない場合は、その作成者の最近の活動のうち閲覧可能なものを返します |
| `order` | `authored_at_desc`に設定すると、一致するコンテンツを作成日時順に並べます |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

レスポンスには`search_results`配列が含まれます。各結果は、`searchable_type`、`searchable_id`、`highlight`、`group_id`、`group_name`、`discussion_key`、`poll_key`、`author_id`、`author_name`、`authored_at`、`tags`などのフィールドで、一致したレコードと、その閲覧可能な関連情報を示します。その結果に該当しないフィールドは`null`になります。

<!-- translation-section: threads -->

## スレッド

<!-- translation-section: list-threads -->

### スレッドの一覧取得

APIキーのユーザーが閲覧できるディスカッションのスレッドとアンケートのスレッドの一覧を、最新のアクティビティ順に取得します。スレッドのIDは、そのスレッドの`topic_id`です。

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `limit` | 整数、省略可能、既定値は50。1ページあたりの件数 |
| `offset` | 整数、省略可能、既定値は0。ページ分割のオフセット |

<!-- translation-section: example-5 -->

#### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

### スレッドの取得

スレッド、順序付けられたイベントストリーム、または閲覧可能な内容全体を含むMarkdown文書を取得します。

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

`items`エンドポイントでは、次のページ分割パラメーターを指定できます。

| 名前 | 説明 |
| --- | --- |
| `limit` | 整数、省略可能、既定値は50、最大値は500。1ページあたりの件数 |
| `offset` | 整数、省略可能、既定値は0。ページ分割のオフセット |

<!-- translation-section: example-6 -->

#### 例

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

`items`エンドポイントは、閲覧可能なコメント、アンケート、投票、結論を含むイベントストリームを、シーケンス番号の昇順で1ページ分返します。`meta.total`は、スレッド内の項目の総数です。ストリーム全体を読むには、後続のページを取得します。`markdown`エンドポイントは、スレッドの閲覧可能な内容全体を1つのMarkdown文書として返します。投票の理由は、APIキーのユーザーが閲覧できる場合にのみ含まれます。

すべてのスレッドエンドポイントには、Loomioの画面と同じ権限が適用されます。APIキーを使っても、そのユーザーが通常開けないスレッドにはアクセスできません。

<!-- translation-section: webhooks -->

## Webhook

ユーザーAPIはリクエストに基づいて動作します。連携システムは、データを読み取ったり変更したりするときにLoomioを呼び出します。グループのWebhookでは、Loomioから連携システムへデータを送信できます。選択したグループのイベントが発生すると、Loomioが指定のエンドポイントに送信するため、連携システムが変更を確認するためにREST APIを繰り返し呼び出す必要はありません。

Webhookはグループごとに設定し、設定にはグループ管理者の権限が必要です。Loomioの画面から次の手順で管理できます。

1. グループを開きます。
2. グループメニューを開き、**チャット連携**を選択します。
3. エンドポイントが受け付けるペイロード形式に合う連携を追加します。汎用のエンドポイントには、Mattermost/Markdown形式を使用してください。
4. 名前と送信先URLを入力します。
5. Loomioが自動送信するイベントを選択します。
6. 連携を保存し、**テスト接続**でテストメッセージを送信します。

推測できないURLを持つHTTPSの送信先を使用してください。Loomioでは、送信先が公開アドレスに名前解決される必要があり、ローカルまたはプライベートネットワークのアドレスへのリクエストはブロックされます。

エージェントやその他の連携システムでは、代わりに、以下で説明するBearer認証のチャットボットエンドポイントを通じてWebhookを管理できます。このリソースは、Loomioのチャット連携との互換性のために`chatbots`という名前になっていますが、一般的な送信用Webhookも表します。

<!-- translation-section: list-webhooks -->

### Webhookの一覧取得

グループに設定されているチャット連携を返します。APIキーのユーザーは、そのグループの管理者である必要があります。レスポンスには送信先URLが含まれるため、一般のグループメンバーに公開してはいけません。

`GET /api/b2/chatbots?group_id=123`

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数、必須。Webhookの一覧を取得するグループのID |
| `limit` | 整数、省略可能、既定値は50、最大値は500。1ページあたりの件数 |
| `offset` | 整数、省略可能、既定値は0。ページ分割のオフセット |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123&limit=50&offset=0'
```

レスポンスには、連携IDの昇順で並べられた`chatbots`の1ページ分が含まれ、`meta.total`にはグループ内の連携の総数が入ります。各連携には次のフィールドがあります。

| フィールド | 説明 |
| --- | --- |
| `id` | 更新と削除に使用する連携IDです |
| `group_id` | イベントの対象となるグループです |
| `name` | 連携の管理用の名前です |
| `kind` | 送信用Webhookの場合は`webhook`、Matrix連携の場合は`matrix`です |
| `webhook_kind` | ペイロード形式です。`markdown`、`slack`、`discord`、`microsoft`、`webex`のいずれかです |
| `server` | 送信先URLです |
| `event_kinds` | 自動送信するイベントです |
| `notification_only` | メッセージに通知の見出しだけを含めるかどうかを示します |

<!-- translation-section: create-a-webhook -->

### Webhookの作成

`POST /api/b2/chatbots`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": ["new_discussion", "new_comment", "poll_created", "outcome_created"],
    "notification_only": false
  }' \
  https://www.loomio.com/api/b2/chatbots
```

APIキーのユーザーは、`group_id`で指定したグループの管理者である必要があります。送信先は、保存される前に公開URLであることが検証されます。

<!-- translation-section: update-a-webhook -->

### Webhookの更新

`PATCH /api/b2/chatbots/:id`

変更するフィールドを送信してください。`group_id`を変更してWebhookを別のグループに移すことはできません。

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Webhook送信先のテスト

設定を保存する前または保存した後に、Markdownに対応したテストメッセージを送信先へ送信します。

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Webhookの削除

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

設定を削除すると、以後の配信が停止します。Loomioのグループ内のコンテンツは削除されません。

<!-- translation-section: event-types -->

### イベントの種類

Webhookでは、次の種類のイベントを受信するよう設定できます。

| イベント | 送信されるタイミング |
| --- | --- |
| `new_discussion` | ディスカッションが開始されたとき |
| `discussion_edited` | ディスカッションが編集されたとき |
| `new_comment` | コメントが作成されたとき |
| `poll_created` | アンケートが開始されたとき |
| `poll_edited` | アンケートが編集されたとき |
| `poll_closing_soon` | アンケートの締め切り時刻が近づいたとき |
| `poll_expired` | アンケートの締め切り時刻になったとき |
| `poll_closed_by_user` | アンケートが手動で締め切られたとき |
| `poll_reopened` | アンケートが再開されたとき |
| `outcome_created` | 結論が公開されたとき |
| `outcome_updated` | 結論が更新されたとき |
| `outcome_review_due` | 結論の見直し期限になったとき |
| `stance_created` | 投票が行われたとき |
| `stance_updated` | 投票が変更されたとき |

Webhookは1つのグループに属し、そのグループで受信対象に設定したイベントを受信します。対応する自動送信イベントが選択されていない場合でも、共有や一部の通知の送信時に、連携先を明示的に選択できます。

<!-- translation-section: http-delivery -->

### HTTP配信

Loomioは、次のヘッダーを付けて、設定されたURLに非同期のHTTP `POST`を送信します。

```text
Content-Type: application/json; charset=utf-8
```

リクエストのタイムアウトは5秒です。`204 No Content`を含む`2xx`レスポンスは成功として扱われます。Webhookの受信側は速やかに応答し、時間のかかる処理は非同期で実行してください。また、配信の重複や順序の入れ替わりに対応できるようにしてください。

現在、LoomioはWebhookの署名、共有シークレットのヘッダー、イベントID、配信IDを付加しません。送信先URL全体を認証情報として扱い、公開しないでください。受信側のサービスが対応している場合は、推測できないトークンをURLに含めてください。安定した機械可読のイベントスキーマや署名付き配信が必要な場合は、Webhookを変更通知として使い、認証付きのユーザーAPIから現在のレコードを取得してください。

<!-- translation-section: payload-formats -->

### ペイロードの形式

Webhookのペイロードは、チャットサービスでの表示を目的としたメッセージです。Loomioのレコードを完全にシリアライズしたものではありません。メッセージ内のリンクは、対象のLoomioコンテンツを示します。連携先で構造化された現在の状態が必要な場合は、ユーザーAPIから追加で取得できます。

| 連携形式 | 主なJSONフィールド |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`。約1,900文字に制限されます |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

例えば、汎用のMarkdown形式では、次のような構造の本文を送信します。

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

実際のメッセージの文面は、イベント、グループの言語設定、通知のみの設定、Loomioのバージョンによって異なります。受信側では、文面を解析するのではなく、選択した形式のドキュメントに記載された最上位のフィールドを使用してください。
