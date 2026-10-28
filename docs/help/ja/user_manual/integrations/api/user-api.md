---
title: ユーザーAPI
source_revision: 81fbad246f674a34694bb2ebfc8416dd04e46ee6
source_file: docs/help/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-28'
sections:
  introduction: 68d638b236cac8c3
  response-size-and-related-records: 6f8cf57b45766ad1
  endpoint-summary: faaeafa590fb56e0
  groups: 0473f1f7fb78f074
  list-groups: 9aef26f9b926766b
  get-a-group: 05fd7cc3b212e7e1
  webhooks: f65fa289f8c1b808
  list-webhooks: fa6555a40e1c4929
  create-a-webhook: 82f92d8c0291ebba
  update-a-webhook: 7e838aa6eba73663
  test-a-webhook-destination: bceeb98f6e8c0000
  delete-a-webhook: 36bb783e464646d0
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: 9f562d745e3eb6b2
  params: 9fa99390aca5fcce
  participation-report: 2d11a398e2293ea4
  params-2: 464322ffc1ac56e5
  example: 7cab9083deb72c59
  create-discussion: 560273365cd6c232
  params-3: 657d582c89333097
  example-2: 71b3da6ca440fc97
  show-discussion: e4c59f833a2e0f0e
  example-3: 2371364611978a4d
  list-discussions: 70edb4a95bf5cafd
  params-4: dcebc294fbb9d837
  example-4: 62b76a3e8ccd9d3f
  list-threads: 46509be0004f5b26
  params-5: 79b1cefac558effc
  example-5: 785a417a6afa1b29
  read-thread: d7b366d09189eeaf
  example-6: 13abd928820aa15e
  edit-discussion: 9bee023a69bdff84
  params-6: b819796d34354623
  example-7: a98e95cf6bec9f7d
  soft-delete-discussion: 97396a318d1c74a2
  example-8: e92d4004513fc701
  create-comment: a3c290a9028f0f28
  params-7: 5ad8ede0919c5f47
  example-9: a13b59af4b411c26
  edit-comment: fd9b7963e483d2a1
  params-8: 288331c60f3c9b28
  example-10: 48c0def4c835d801
  soft-delete-comment: be989b770bd2025a
  example-11: e9019f5c028e3632
  create-poll: f339b99e95def65f
  params-9: 1c63b4ef4047f3c3
  example-12: 58ea197b72a8bd0f
  show-poll: 40b4370bcac536e5
  example-13: 6e74d6164d61fd19
  list-polls: e52282b2b9fe775b
  params-10: e68e8cf62b21488d
  example-14: cda8994926bc7002
  edit-poll: b2c8cd57e7dea231
  params-11: 70b594511872194a
  example-15: fda29e1741869e22
  soft-delete-poll: 740d74b8f48adfd8
  example-16: aa8016ff2c0dcd5d
  list-memberships: 769573d5f0f4a077
  params-12: decaff0790566fb0
  example-17: 213d79e474d7ab1d
  manage-memberships: c492589da7e249c8
  params-13: 771b5338a4ba3d0b
  example-18: bacb90328233ce5b
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
  request-bodies: 0ec99fc25454f511
  poll-many-options: 54f4ab737df476d9
  poll-detailed-options: 1df1348a129c3991
  edit-poll-detailed-options: 2be9b78ff51be3ec
generated:
  introduction: 8691e487dc224f4a
  response-size-and-related-records: e3bddf04408e3ae9
  endpoint-summary: e431ca7f4887b94a
  groups: 95e133438e155e03
  list-groups: 1aad4a6ced9907f1
  get-a-group: 56a4ce2d25a152a9
  webhooks: a97fdb82fc1bf29e
  list-webhooks: '8716849316074560'
  create-a-webhook: cdf787748041f9af
  update-a-webhook: a2eac18b4b67c21c
  test-a-webhook-destination: 99b51b7c8bcaa503
  delete-a-webhook: 2b71ffda4dda0660
  event-types: 58b300d9c7dff84b
  http-delivery: d426ce00962fbf95
  payload-formats: 7f06ed33b553976f
  search: 7e4fccd4af9bb60c
  params: c091dde3106f3489
  participation-report: 3bc3d81d6d638616
  params-2: 52cec69d241a4f8a
  example: ad7c8deb9be9a7f4
  create-discussion: 5181a75bac8fbe8d
  params-3: 220f2f80da75ae28
  example-2: 3732b62e47fb5aba
  show-discussion: 2498525307df09e0
  example-3: 5eceb8f3738e14ad
  list-discussions: 407f14142b0762b3
  params-4: 10d24176aa54c5b1
  example-4: d9b9228171c94dc5
  list-threads: 531599e53748edbb
  params-5: b174e3f7ed633494
  example-5: 19338e3d2926ed2b
  read-thread: a1c043194a5fb6d7
  example-6: 6a9d82697c72c972
  edit-discussion: a9f6103168f84d91
  params-6: 5b5bafc2621bce4f
  example-7: f91f1ba1d7d750e9
  soft-delete-discussion: a19bf420a35487b6
  example-8: 68165790935c5e3b
  create-comment: 34e93fa2a864d8cc
  params-7: f641417d13ce4bb8
  example-9: 62b8fd08ab9a61bb
  edit-comment: b67c21b7554a44f3
  params-8: 016f76a103d930e4
  example-10: d2987c7875b600f5
  soft-delete-comment: b5517f1c192e797e
  example-11: e650c1d3bbf1b726
  create-poll: 22753bc7ecd7d858
  params-9: 7303dd8a367f7187
  example-12: 9caac9b478ea55c5
  show-poll: d361bd6fa74339d7
  example-13: 717c34541ea8142c
  list-polls: 25e8a49c9f0451dc
  params-10: d63c307be555d850
  example-14: '01695dc83aa0cfa8'
  edit-poll: 5c6e3a9ebd483296
  params-11: 7960d9aba879021c
  example-15: 3705fa94b135e0a6
  soft-delete-poll: 1f20374b41f82d9d
  example-16: ec7c4e73c4fb03a9
  list-memberships: af3ca92fb4e9ad4a
  params-12: 86c22f1ce78077b5
  example-17: 6c79e3da7ff232f3
  manage-memberships: 7bf10ac28dd3022a
  params-13: aab3e7cf0b72b2e6
  example-18: 2cb066c2ec271c9f
  pagination: 37d5df239aa8c9b0
  comments: 329bd304204146ee
  discussions: 314a377991d455fd
  memberships: e105d51243cc1ae0
  polls: 53518c90603f9924
  threads: 61f8fceb9c2cc2e3
  request-bodies: 861faf64e2098ad2
  poll-many-options: b937c703620dc4e3
  poll-detailed-options: 02ffece2849ba4a5
  edit-poll-detailed-options: 94f62c0dcc0c75bb
title_source: c23fb6526b722360
title_generated: 9d80e3857ccdabb2
---

<!-- translation-section: introduction -->

# LoomioユーザーAPIドキュメント

<!-- seo-description: LoomioユーザーAPIを使用して、他のソフトウェアからディスカッション、コメント、アンケート、スレッド、グループのメンバー登録を作成・管理できます。 -->

`/api/user0`は、Loomioとの連携に使用するユーザー向けAPIです。ユーザーアカウントのAPIキーを使用し、すべての操作はそのユーザーとして実行されます。

グループに対する操作には、APIキーのユーザーのメンバー登録とグループ権限が適用されます。インスタンス管理者であっても、APIキーでアクセスできるグループやコンテンツの範囲は広がりません。インスタンス全体の管理にはサーバーAPIを使用してください。

操作を実行するLoomioユーザーアカウントのAPIキーを使用してください。連携用のアカウントをアンケートに招待したり、通知を送信したりする必要がない場合は、専用のボットアカウントが役立ちます。

ログインしているユーザーは、[APIアクセスページ](/profile/api_access)でAPIキーとグループIDを確認できます。

APIキーは`Authorization: Bearer`ヘッダーで送信してください。URLはプロキシやアクセスログに記録される可能性があるため、クエリ文字列に含まれるAPIキーは拒否されます。

```text
Authorization: Bearer YOUR_API_KEY
```

例では、`YOUR_API_KEY`、グループID`123`、`https://www.loomio.com/`を使用しています。使用するAPIキー、グループID、Loomioのインストール先URLに置き換えてください。

<!-- translation-section: request-bodies -->

### リクエスト本文の送信

`Content-Type: application/json`を指定してJSONを送信します。cURLの例では、このヘッダーを自動的に設定する`--json`を使用しています。ディスカッション、コメント、アンケートの作成・編集エンドポイントは、フラットなオブジェクトと、`{"poll": {...}}`のようにリソース名の下にネストされたオブジェクトのどちらも受け付けます。

配列は、`"options": ["foo", "bar"]`のようにJSON配列として送信します。代わりにフォームエンコーディングを使用する場合は、`options[]=foo&options[]=bar`のようにフィールド名に角括弧を付ける必要があります。`options=foo&options=bar`のように繰り返すと、最後の値だけが保持されます。

各リクエストの後に、HTTPステータスとレスポンス本文を確認してください。検証に失敗すると、`errors`オブジェクトとともに`422`が返されます。アンケートの作成に成功すると、`polls`にアンケートが、`poll_options`にその選択肢が返されます。

<!-- translation-section: endpoint-summary -->

## エンドポイント一覧

| メソッド | エンドポイント | 用途 |
| --- | --- | --- |
| `POST` | `/api/user0/comments` | コメントまたは返信を作成します |
| `PATCH` | `/api/user0/comments/:id` | コメントを編集します |
| `DELETE` | `/api/user0/comments/:id` | コメントを論理削除します |
| `POST` | `/api/user0/discussions` | ディスカッションを作成します |
| `GET` | `/api/user0/discussions/:id` | ディスカッションを取得します |
| `GET` | `/api/user0/discussions` | グループ内のディスカッションを一覧表示します |
| `PATCH` | `/api/user0/discussions/:id` | ディスカッションを編集します |
| `DELETE` | `/api/user0/discussions/:id` | ディスカッションを論理削除します |
| `GET` | `/api/user0/groups` | APIキーのユーザーのグループを一覧表示します |
| `GET` | `/api/user0/groups/:id_or_key_or_handle` | 閲覧できるグループを取得します |
| `GET` | `/api/user0/memberships` | グループのメンバー登録を一覧表示します |
| `POST` | `/api/user0/memberships` | メンバーを追加し、必要に応じてリストに含まれないメンバーを削除します |
| `GET` | `/api/user0/reports` | 参加状況レポートを生成します |
| `POST` | `/api/user0/polls` | アンケートを作成します |
| `GET` | `/api/user0/polls/:id` | アンケートを取得します |
| `GET` | `/api/user0/polls` | グループ内のアンケートを一覧表示します |
| `PATCH` | `/api/user0/polls/:id` | アンケートを編集します |
| `DELETE` | `/api/user0/polls/:id` | アンケートを論理削除します |
| `GET` | `/api/user0/search` | 閲覧できるディスカッション、コメント、アンケート、投票、結論を検索します |
| `GET` | `/api/user0/threads` | 閲覧できるディスカッションのスレッドと単独のアンケートのスレッドを一覧表示します |
| `GET` | `/api/user0/threads/:topic_id` | スレッドを取得します |
| `GET` | `/api/user0/threads/:topic_id/items` | スレッド内の項目を順序付きで取得します |
| `GET` | `/api/user0/threads/:topic_id/markdown` | スレッド全体をMarkdownで取得します |
| `GET` | `/api/user0/chatbots` | グループのチャット連携とWebhookを一覧表示します |
| `POST` | `/api/user0/chatbots` | チャット連携またはWebhookを作成します |
| `PATCH` | `/api/user0/chatbots/:id` | チャット連携またはWebhookを更新します |
| `DELETE` | `/api/user0/chatbots/:id` | チャット連携またはWebhookを削除します |
| `POST` | `/api/user0/chatbots/check` | Webhookの接続テストを送信します |

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
curl 'https://www.loomio.com/api/user0/threads/123/items?compact=1' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

省略する種類を直接指定するには、単数形のレコード種別をスペースで区切って`exclude_types`に指定します。例えば、`exclude_types=group reaction`は関連するグループとリアクションを省略します。よく使われる値は、`topic`、`group`、`parent`、`membership`、`reaction`、`tag`、`translation`、`user`、`discussion`、`poll`、`poll_option`、`stance`、`stance_choice`、`outcome`（結論）、`topic_item`です。除外は関連レコードに適用され、エンドポイントで要求した主要リソースには適用されません。

コレクションのレスポンスには、正確な件数が定義されている場合に`meta.total`が含まれます。合計件数は、`limit`と`offset`を適用する前に計算されます。検索など、意図的に返す件数を制限しているエンドポイントでは、`null`を返す代わりに`meta.total`を省略します。

<!-- translation-section: comments -->

## コメント

<!-- translation-section: create-comment -->

### コメントの作成

APIキーのユーザーとしてディスカッションにコメントを作成します。

`POST /api/user0/comments`

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
curl https://www.loomio.com/api/user0/comments \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "discussion_id": 123,
    "body": "example comment",
    "body_format": "md"
  }'
```

<!-- translation-section: edit-comment -->

### コメントの編集

APIキーのユーザーとしてコメントを編集します。Loomioと同じ権限が適用されるため、そのユーザーには対象のコメントを編集する権限が必要です。

`PATCH /api/user0/comments/:id`

<!-- translation-section: params-8 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `body` | 更新後のコメント本文です |
| `body_format` | `md` または `html`、任意。既定値は `md` です |

<!-- translation-section: example-10 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/comments/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "body": "updated comment",
    "body_format": "md"
  }'
```

<!-- translation-section: soft-delete-comment -->

### コメントの論理削除

APIキーのユーザーとしてコメントを論理削除します。コメントは削除済みになり、本文は非表示になりますが、レコードは保持されます。

`DELETE /api/user0/comments/:id`

<!-- translation-section: example-11 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/comments/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: discussions -->

## ディスカッション

<!-- translation-section: create-discussion -->

### ディスカッションの作成

APIキーのユーザーとしてディスカッションを作成します。

`POST /api/user0/discussions`

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
curl https://www.loomio.com/api/user0/discussions \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "example thread",
    "recipient_emails": [
      "person@example.com"
    ]
  }'
```

<!-- translation-section: show-discussion -->

### ディスカッションの取得

整数のディスカッションID、または文字列のキーを使ってディスカッションを取得します。

`GET /api/user0/discussions/:id`

<!-- translation-section: example-3 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/discussions/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-discussions -->

### ディスカッションの一覧取得

グループ内でAPIキーのユーザーが閲覧できるディスカッションの一覧を取得します。公開グループでは、メンバーでなくても公開ディスカッションの一覧を取得できます。非公開ディスカッションは、Loomioでその内容を閲覧できるユーザーのみが取得できます。

`GET /api/user0/discussions`

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
curl 'https://www.loomio.com/api/user0/discussions?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-discussion -->

### ディスカッションの編集

APIキーのユーザーとしてディスカッションを編集します。Loomioと同じ権限が適用されるため、そのディスカッションを編集する権限が必要です。

`PATCH /api/user0/discussions/:id`

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
curl https://www.loomio.com/api/user0/discussions/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated thread title",
    "description": "updated context",
    "description_format": "md"
  }'
```

<!-- translation-section: soft-delete-discussion -->

### ディスカッションの論理削除

APIキーのユーザーとしてディスカッションを論理削除します。ディスカッションは削除済みになりますが、レコードは保持されます。

`DELETE /api/user0/discussions/:id`

<!-- translation-section: example-8 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/discussions/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: groups -->

## グループ

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"s_count` | グループ管理者の人数です |\n| `delegates_count` | 代表者の人数です |\n| `discussions_count` | グループ直下のディス","after":"s_count` | グループ管理者の人数です |\n| `discussions_count` | グループ直下のディス"} -->

### グループの一覧取得

APIキーのユーザーが有効なメンバー登録を持つグループを返します。

`GET /api/user0/groups`

| 名前 | 説明 |
| --- | --- |
| `limit` | 整数、任意、既定値50、最大500。ページサイズ |
| `offset` | 整数、任意、既定値0。ページ分割のオフセット |

```bash
curl 'https://www.loomio.com/api/user0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
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

`GET /api/user0/groups/:id_or_key_or_handle`

識別子には、グループの数値ID、キー、ハンドル名を使用できます。

```bash
curl https://www.loomio.com/api/user0/groups/123 \
  -H 'Authorization: Bearer YOUR_API_KEY'

curl https://www.loomio.com/api/user0/groups/example-group \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

レスポンスには、一覧取得エンドポイントと同じフィールドを持つグループが`groups`配列に含まれます。APIキーのユーザーがアクセスできないグループを要求すると、権限エラーが返されます。

<!-- translation-section: memberships -->

## メンバー登録

<!-- translation-section: list-memberships -->

### メンバー登録の一覧取得

APIキーのユーザーが閲覧できるメンバー登録を一覧で取得します。グループのメンバーは、メンバーの名前、ID、肩書き、役割を閲覧できます。メールアドレスは、APIキーのユーザー自身のアカウントの場合、またはAPIキーのユーザーがグループ管理者の場合にのみ含まれます。

`GET /api/user0/memberships`

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
curl 'https://www.loomio.com/api/user0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: manage-memberships -->

### メンバー登録の管理

メールアドレスのリストを送信します。新しいメールアドレスすべてにグループへの招待を送ります。メンバー登録の一覧取得とは異なり、この操作にはグループ管理者の権限が必要です。

`POST /api/user0/memberships`

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
curl https://www.loomio.com/api/user0/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ]
  }'
```

`remove_absent=1`を指定すると、リストに含まれていないグループのメンバーはすべてグループから削除されます。グループの全メンバーを削除する可能性があるため、注意してください。

```bash
curl https://www.loomio.com/api/user0/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ],
    "remove_absent": 1
  }'
```

この操作は、`{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`を含むオブジェクトを返します。

<!-- translation-section: participation-report -->

## 参加状況レポート

Loomioの参加状況レポートで使用されるものと同じ、集計済みの参加データを返します。

`GET /api/user0/reports`

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
curl 'https://www.loomio.com/api/user0/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09' \
  -H 'Authorization: Bearer YOUR_API_KEY'
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

`POST /api/user0/polls`

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
| `options` | 選択肢の名前を文字列の配列で指定します。`proposal` では、`agree`、`disagree`、`abstain`、`block` を使うと、標準のラベル、アイコン、意味、入力を促す文が設定されます。`meeting` では、ISO 8601形式の日付または日時の文字列を指定します。その他のアンケートの種類では、選択肢の名前を指定します。選択肢の詳細を設定する場合は、代わりに `poll_options_attributes` を使います |
| `poll_options_attributes` | `options` の代わりに使います。名前、意味、入力を促す文、アイコン、表示順を持つ選択肢オブジェクトの配列です。[選択肢の詳細を設定してアンケートを作成する](#create-a-poll-with-detailed-options)を参照してください |
| `reason_prompt` | 文字列、省略可能。投票の理由の入力を促す共通の文です。`poll`、`score`、`ranked_choice` など、選択肢ごとの入力を促す文がない種類のアンケートで使います |
| `stance_reason_required` | 文字列、既定値は `optional`。値：`disabled`、`optional`、`required`、`required_for_disagree_or_block`、`required_for_block`。最後の2つは `disagree` と `block` のアイコンに適用されます。匿名アンケートでは投票の理由が無効になります |
| `closing_at` | ISO 8601形式の文字列または null、既定値は null。例：`2026-09-01T12:00:00Z`。null の場合、投票は無効になり、アンケートは作成中として扱われます |
| `specified_voters_only` | 真偽値、省略可能、既定値は false。true の場合、指定された人だけが投票できます。false の場合、グループの全員が投票に招待されます |
| `hide_results` | 文字列、省略可能、既定値は `off`。値：`off`、`until_vote`、`until_closed` |
| `shuffle_options` | 真偽値、既定値は false。投票者に選択肢をランダムな順序で表示します |
| `anonymous` | 真偽値、省略可能、既定値は false。投票者が誰であるかを非表示にします |
| `recipient_audience` | `group` または null、省略可能、既定値は null。`group` の場合、グループ全体に通知されます |
| `notify_on_closing_soon` | 文字列、省略可能、既定値は `nobody`。値：`nobody`、`author`、`voters_uncast`、`voters` |
| `recipient_user_ids` | 通知または招待するユーザーのIDの配列です |
| `recipient_emails` | 投票に招待する人のメールアドレスの配列です |
| `recipient_message` | 招待メールに含めるメッセージです |
| `notify_recipients` | 真偽値、既定値は false。false の場合、通知を送信せずに人を追加します。true の場合、このリクエストで招待された全員に通知メールが送信されます |

<!-- translation-section: example-12 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "example poll",
    "poll_type": "proposal",
    "options": [
      "agree",
      "disagree"
    ],
    "closing_at": "2026-09-01T12:00:00Z",
    "recipient_emails": [
      "person@example.com"
    ]
  }'
```

<!-- translation-section: poll-many-options -->

#### 多くの選択肢を持つアンケートの下書きを作成する

すべての選択肢の名前を `options` 配列で送信します。`closing_at` を省略すると、投票が無効になった作成中のアンケートが作成されます。そのスレッドを閲覧できる人に対してアンケートが非表示になるわけではありません。投票を開始する準備ができたら、未来の日時を指定した `closing_at` を追加します。

すべての選択肢の名前を配列に追加します。

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Meeting venue",
    "poll_type": "poll",
    "options": [
      "Town hall",
      "Library",
      "Community centre"
    ]
  }'
```

<!-- translation-section: poll-detailed-options -->

#### 選択肢の詳細を設定してアンケートを作成する

名前の一覧を指定する場合は `options` を使い、各選択肢に意味、理由の入力を促す文、アイコンが必要な場合は `poll_options_attributes` を使います。リクエストごとにどちらか一方の形式を選択します。どちらの形式も、フラットなJSON本文、または `poll` オブジェクト内で使えます。

`poll_options_attributes` の各オブジェクトでは、次のフィールドを指定できます。

| フィールド | 説明 |
| --- | --- |
| `name` | 文字列、新しい選択肢では必須。投票者に表示されるラベルです |
| `meaning` | 文字列、省略可能。この選択肢を選ぶことの意味を説明します |
| `prompt` | 文字列、省略可能。`proposal`、`count`、`check` でこの選択肢を選んだときに表示される、理由の入力を促す文です。その他のアンケートの種類では、アンケートに `reason_prompt` を設定します |
| `icon` | 文字列、省略可能。`proposal`、`count`、`check` では、`agree`、`disagree`、`abstain`、`block` を使います |
| `priority` | 整数。`0` から始まる選択肢の表示順です。選択肢ごとに異なる値を指定します。ただし、日程調整の選択肢は日付順に並びます |
| `test_operator` | 文字列または null、省略可能。得票率の条件です。`gte` は以上、`lte` は以下を意味します。null に設定すると条件が無効になります |
| `test_percent` | 整数、省略可能。得票率の条件に使う割合を `0` から `100` で指定します |
| `test_against` | 文字列、省略可能。`score_percent` は、投じられたスコアまたはポイントの合計に対する、その選択肢の割合を比較します。`voter_percent` は、投票資格のあるすべての投票者に対する、その選択肢に投票した人の割合を比較します |
| `id` | 整数。既存の選択肢を編集する場合に指定し、新しい選択肢では省略します |
| `_destroy` | 真偽値、省略可能。既存の選択肢の `id` とともに `true` を指定すると、その選択肢を削除します |

独自の選択肢ラベルと入力を促す文を使って提案を作成します。

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Should we adopt this proposal?",
    "poll_type": "proposal",
    "stance_reason_required": "optional",
    "poll_options_attributes": [
      {
        "name": "Support",
        "meaning": "I support adopting this proposal",
        "prompt": "What do you support about it?",
        "icon": "agree",
        "priority": 0
      },
      {
        "name": "Oppose",
        "meaning": "I would prefer another approach",
        "prompt": "What would you change?",
        "icon": "disagree",
        "priority": 1
      }
    ]
  }'
```

通常のアンケートでは、同じ選択肢の詳細形式を使い、アンケートに共通の `reason_prompt` を設定します。

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Choose a venue",
    "poll_type": "poll",
    "reason_prompt": "Why do you prefer this venue?",
    "stance_reason_required": "optional",
    "poll_options_attributes": [
      {
        "name": "Town hall",
        "meaning": "Central, accessible venue",
        "priority": 0
      },
      {
        "name": "Library",
        "meaning": "Smaller room with no hire fee",
        "priority": 1
      }
    ]
  }'
```

これらの例では `closing_at` を省略しているため、未来の締め切り日時を設定するまで投票は無効のままです。

<!-- translation-section: show-poll -->

### アンケートの取得

整数のアンケートID、または文字列のキーを使用してアンケートを取得します。

`GET /api/user0/polls/:id`

<!-- translation-section: example-13 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/polls/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-polls -->

### アンケートの一覧取得

グループ内でAPIキーのユーザーが閲覧できるアンケートの一覧を取得します。公開されているグループでは、メンバーでなくても公開アンケートの一覧を取得できます。非公開アンケートは、Loomioで閲覧権限を持つユーザーだけが取得できます。レスポンスには、閲覧可能な各アンケートの現在の結論が含まれるため、`status=closed` を使用すると、決定済みの提案の一覧を取得できます。

`GET /api/user0/polls`

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
curl 'https://www.loomio.com/api/user0/polls?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-poll -->

### アンケートの編集

APIキーのユーザーとしてアンケートを編集します。Loomioと同じ権限が適用されるため、そのユーザーには対象のアンケートを編集する権限が必要です。

`PATCH /api/user0/polls/:id`

<!-- translation-section: params-11 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `title` | 更新後のタイトルです |
| `details` | 更新後のアンケートの詳細です |
| `details_format` | `md` または `html`、省略可能、既定値は `md` |
| `options` | 更新後の選択肢の名前です。選択肢を変更すると、アンケートの状態によっては既存の投票に影響する場合があります |
| `poll_options_attributes` | `options` の代わりに使います。`id` を指定して選択肢の詳細オブジェクトを更新し、`id` のないオブジェクトを追加し、または `id` と `_destroy: true` を指定して選択肢を削除します。省略した選択肢は変更されません |
| `reason_prompt` | 選択肢ごとの入力を促す文がない種類のアンケートで使う、理由の入力を促す共通の文の更新内容です |
| `stance_reason_required` | 更新後の理由の入力条件です。アンケートの作成時と同じ値を使います |
| `closing_at` | ISO 8601形式の文字列または null |
| `recipient_audience` | `group` または null。`group` の場合、グループ全体に通知されます |
| `recipient_user_ids` | 通知または招待するユーザーのIDの配列です |
| `recipient_emails` | 投票に招待する人のメールアドレスの配列です |
| `recipient_message` | 招待メールに含めるメッセージです |

<!-- translation-section: example-15 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated poll title",
    "details": "updated details",
    "details_format": "md"
  }'
```

<!-- translation-section: edit-poll-detailed-options -->

#### 選択肢の詳細を編集する

作成または取得時のレスポンスに含まれる `poll_options` 配列から、選択肢のIDを取得します。各既存の選択肢の `id` とともに、変更するフィールドだけを送信します。

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "poll_options_attributes": [
      {
        "id": 456,
        "meaning": "Updated explanation",
        "prompt": "What would improve this proposal?"
      },
      {
        "name": "Abstain",
        "meaning": "I leave the decision to others",
        "icon": "abstain",
        "priority": 2
      }
    ]
  }'
```

選択肢のIDは、編集中のアンケートに属している必要があります。編集にはアンケートを編集する権限が必要で、締め切り済みのアンケートは編集できません。匿名アンケートでは、最初の投票が送信されると、選択肢の設定も変更できなくなります。

<!-- translation-section: soft-delete-poll -->

### アンケートの論理削除

APIキーのユーザーとしてアンケートを論理削除します。アンケートを削除済みとして扱い、アンケートのレコードは保持します。

`DELETE /api/user0/polls/:id`

<!-- translation-section: example-16 -->

#### 例

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: search -->

## 検索

APIキーのユーザーが閲覧できるディスカッション、コメント、アンケート、投票、結論を検索します。グループのメンバーでなくても、そのグループの公開コンテンツは結果に含まれます。非公開コンテンツには、通常のトピックの閲覧権限が適用されます。

`GET /api/user0/search`

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
curl 'https://www.loomio.com/api/user0/search?query=quarterly+planning&type=Discussion' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

レスポンスには`search_results`配列が含まれます。各結果は、`searchable_type`、`searchable_id`、`highlight`、`group_id`、`group_name`、`discussion_key`、`poll_key`、`author_id`、`author_name`、`authored_at`、`tags`などのフィールドで、一致したレコードと、その閲覧可能な関連情報を示します。その結果に該当しないフィールドは`null`になります。

<!-- translation-section: threads -->

## スレッド

<!-- translation-section: list-threads -->

### スレッドの一覧取得

APIキーのユーザーが閲覧できるディスカッションのスレッドとアンケートのスレッドの一覧を、最新のアクティビティ順に取得します。スレッドのIDは、そのスレッドの`topic_id`です。

`GET /api/user0/threads`

<!-- translation-section: params-5 -->

#### パラメーター

| 名前 | 説明 |
| --- | --- |
| `limit` | 整数、省略可能、既定値は50。1ページあたりの件数 |
| `offset` | 整数、省略可能、既定値は0。ページ分割のオフセット |

<!-- translation-section: example-5 -->

#### 例

```bash
curl 'https://www.loomio.com/api/user0/threads?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: read-thread -->

### スレッドの取得

スレッド、順序付けられたイベントストリーム、または閲覧可能な内容全体を含むMarkdown文書を取得します。

`GET /api/user0/threads/:topic_id`

`GET /api/user0/threads/:topic_id/items`

`GET /api/user0/threads/:topic_id/markdown`

`items`エンドポイントでは、次のページ分割パラメーターを指定できます。

| 名前 | 説明 |
| --- | --- |
| `limit` | 整数、省略可能、既定値は50、最大値は500。1ページあたりの件数です |
| `offset` | 整数、省略可能、既定値は0。ページ分割のオフセットです |

<!-- translation-section: example-6 -->

#### 例

```text
GET https://www.loomio.com/api/user0/threads/<topic_id>
GET https://www.loomio.com/api/user0/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/user0/threads/<topic_id>/markdown
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

`GET /api/user0/chatbots?group_id=123`

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数、必須。Webhookの一覧を取得するグループのIDです |
| `limit` | 整数、省略可能、既定値は50、最大値は500。1ページあたりの件数です |
| `offset` | 整数、省略可能、既定値は0。ページ分割のオフセットです |

```bash
curl 'https://www.loomio.com/api/user0/chatbots?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
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

`POST /api/user0/chatbots`

```bash
curl https://www.loomio.com/api/user0/chatbots \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": [
      "new_discussion",
      "new_comment",
      "poll_created",
      "outcome_created"
    ],
    "notification_only": false
  }'
```

APIキーのユーザーは、`group_id`で指定したグループの管理者である必要があります。送信先は、保存される前に公開URLであることが検証されます。

<!-- translation-section: update-a-webhook -->

### Webhookの更新

`PATCH /api/user0/chatbots/:id`

変更するフィールドを送信してください。`group_id`を変更してWebhookを別のグループに移すことはできません。

```bash
curl https://www.loomio.com/api/user0/chatbots/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "name": "Planning events",
    "event_kinds": [
      "new_discussion",
      "outcome_created"
    ]
  }'
```

<!-- translation-section: test-a-webhook-destination -->

### Webhook送信先のテスト

設定を保存する前または保存した後に、Markdownに対応したテストメッセージを送信先へ送信します。

`POST /api/user0/chatbots/check`

```bash
curl https://www.loomio.com/api/user0/chatbots/check \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "server": "https://hooks.example.org/loomio/unguessable-token"
  }'
```

<!-- translation-section: delete-a-webhook -->

### Webhookの削除

`DELETE /api/user0/chatbots/:id`

```bash
curl https://www.loomio.com/api/user0/chatbots/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
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
