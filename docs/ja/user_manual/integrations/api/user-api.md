---
title: ユーザーAPI
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: 2b783ec54f27b2ce
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: a8b52c1a9bfdb16c
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
  create-discussion: ad202a0bdbfa7c2e
  params-3: 529f10e32be74c5c
  example-2: f25daafbba33718c
  show-discussion: b61aea6bf3d55e16
  example-3: e095e8e34cd562a0
  list-discussions: f209b8feb7c795a6
  params-4: 3ec197245f595be6
  example-4: 37d59c03fee8a15b
  list-threads: 34edc6c34552e136
  params-5: a5f41285afccdc8b
  example-5: 81c145ad5f6eb232
  read-thread: 0de1409aaa00b9ac
  example-6: 7c7553e1a3e94070
  edit-discussion: 1ab04653354b8036
  params-6: 4d3f5862a5f948b4
  example-7: d2a61a34af9e99c3
  soft-delete-discussion: fdb0d4db8470524c
  example-8: 423894a70b5ce489
  create-comment: bf95ee58b610f2fd
  params-7: 7af2127e1f721b66
  example-9: 4e7d49ac39938c12
  edit-comment: 49e722ec6bca25a1
  params-8: b2be783e4398d866
  example-10: bf626a7f693182c3
  soft-delete-comment: afb51bf4074aeab7
  example-11: e39b758ad0d7aa62
  create-poll: b2a11ae34ce22151
  params-9: 3e592c12f9cbb757
  example-12: f5d6029049637276
  show-poll: 2e7a14ac23eeffa6
  example-13: 1a5acf0b8a6f62f2
  list-polls: 606f27566d6d5f98
  params-10: 1b1a6f003f91eb9a
  example-14: 710a82f6b2203f48
  edit-poll: 42b85770aebd8ef2
  params-11: 52d278a2f38d6a9f
  example-15: 8f7d523fc36f5da7
  soft-delete-poll: 0f1b24e1263dcfbe
  example-16: ec71cfcd4a0b98ab
  list-memberships: 82712683aa3a424a
  params-12: d2fc821e97d53145
  example-17: 266443e0eb35078c
  manage-memberships: 3c821029101515ad
  params-13: 249b307203206387
  example-18: ffd950cd7ab5aaec
generated:
  introduction: fc7e8136159a73ce
  authentication-change: ffbd7c9b0f5d008f
  response-size-and-related-records: 2e0e51d9125083e7
  endpoint-summary: '019d544008540f95'
  groups: 95e133438e155e03
  list-groups: dc0a213db13991f4
  get-a-group: f5099b59ce71efad
  webhooks: fee55121f971013b
  list-webhooks: d01ff33cf65f244d
  create-a-webhook: c9e2261279945c5e
  update-a-webhook: 833b7232e9def901
  test-a-webhook-destination: 592189c9a2f3f8ce
  delete-a-webhook: d6f03f1f56118417
  event-types: 80d8cb18b94fe2d8
  http-delivery: d2bc45a19e8b81ec
  payload-formats: 64b1fd11bf775f06
  search: e124a87ca1126491
  params: bae804f4e4f4edbe
  participation-report: a7b7d25cd0629752
  params-2: a8991a2831b30a16
  example: dcc9deb9c3e11b8f
  create-discussion: 14315f0a75e5f581
  params-3: 6c618ec142da5ec8
  example-2: 322e97033d399586
  show-discussion: c7245a95cde29a87
  example-3: 712619f54575a362
  list-discussions: 69c20ac847d68c44
  params-4: 3eed4bd2fe01f785
  example-4: cebc17f5571ba071
  list-threads: 7b5305b035581d54
  params-5: eb598e93636f7141
  example-5: ca1359000d3c7019
  read-thread: 85286e754419ecc8
  example-6: 49162bcc8c1304e7
  edit-discussion: 48623968ce5adeac
  params-6: 0c1e4ba5a820764c
  example-7: a730d5c27bc549e1
  soft-delete-discussion: cbbed1474ebf9615
  example-8: 134016325f19f153
  create-comment: 45c29b4c7c6326a5
  params-7: b8d2ddd9e6bb61a5
  example-9: f88a0ce7f4f15878
  edit-comment: 2314102a92fe23c6
  params-8: 63914f2da2b3b2ca
  example-10: 21c7b429b9735dac
  soft-delete-comment: e0a8cd5e8a77e354
  example-11: 61cbd7161ee80cef
  create-poll: ea267e5a3f549ab4
  params-9: ea85602b317c3ea7
  example-12: e5593f67b390b6bb
  show-poll: 7c07cafb461074f1
  example-13: 6ed56e1e8f602af8
  list-polls: 3cc81a86da9187ce
  params-10: '038cd367674e0717'
  example-14: bdce543069a50223
  edit-poll: da00d64adaef7695
  params-11: 18fc01723d6e7c91
  example-15: b1aac01bc7f5c9a5
  soft-delete-poll: caa6283baa421bf1
  example-16: a71589325f948993
  list-memberships: 027e902c87b05ca5
  params-12: 99a630eb1149a28f
  example-17: 06b87e38b698f4c5
  manage-memberships: 6d2efc9008daa606
  params-13: 69d7b818af65eefe
  example-18: 404613276b7f5c2d
title_source: c23fb6526b722360
title_generated: 9d80e3857ccdabb2
---

<!-- translation-section: introduction -->

# LoomioユーザーAPIドキュメント

<!-- seo-description: LoomioユーザーAPIを使って、他のソフトウェアからディスカッション、コメント、アンケート、スレッド、グループのメンバー登録を作成・管理できます。 -->

`/api/b2` は、Loomioとの連携に使用するユーザー向けAPIです。ユーザーアカウントのAPIキーを使用し、すべての操作はそのユーザーとして実行されます。

グループの操作には、APIキーのユーザーのメンバー登録とグループ内の権限が適用されます。インスタンス管理者であっても、APIキーでアクセスできるグループやコンテンツは増えません。インスタンス全体の管理にはサーバーAPIを使用してください。

操作を実行するLoomioユーザーアカウントのAPIキーを使用してください。連携用アカウントをアンケートに招待したり、通知を送ったりする必要がない場合は、専用のボットアカウントが便利です。

ログイン済みのユーザーは、[APIアクセスページ](/profile/api_access)でAPIキーとグループIDを確認できます。

APIキーは `Authorization: Bearer` ヘッダーで送信してください。URLはプロキシやアクセスログに記録される可能性があるため、クエリ文字列に含まれるAPIキーは拒否されます。

<!-- translation-section: authentication-change -->

### 認証方法の変更

以前は、URLパラメーター `api_key` でAPIキーを指定できました。現在、`?api_key=YOUR_API_KEY` を使用したリクエストは機能しません。代わりにHTTPの `Authorization` ヘッダーを使用してください。

```text
Authorization: Bearer YOUR_API_KEY
```

例では `YOUR_API_KEY`、グループID `123`、`https://www.loomio.com/` を使用しています。使用するAPIキー、グループID、Loomioの設置先URLに置き換えてください。

<!-- translation-section: response-size-and-related-records -->

## レスポンスのサイズと関連レコード

ユーザーAPIのレスポンスは複合形式です。主要なレコードに加えて、トピック、グループ、ユーザー、アンケート、リアクションなどの関連レコードが含まれます。これにより、クライアントは1回のリクエストでローカルのレコードストアにデータを格納できますが、単純な連携に必要な量を超えるデータが含まれる場合があります。

`compact=1`を指定すると、データ量の多い関連トピック、グループ、親グループ、メンバーシップ、リアクション、タグ、翻訳を省略できます。主要なレコードと、その内容を解釈するために必要な関連レコードは引き続き含まれます。

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

省略する種類を直接指定するには、単数形のレコード種別をスペースで区切って`exclude_types`に指定します。例えば、`exclude_types=group reaction`を指定すると、関連するグループとリアクションが省略されます。よく使われる値は、`topic`、`group`、`parent`、`membership`、`reaction`、`tag`、`translation`、`user`、`discussion`、`poll`、`poll_option`、`stance`、`stance_choice`、`outcome`（結論）、`topic_item`です。省略の対象は関連レコードであり、エンドポイントでリクエストした主要なリソースには適用されません。

コレクションの正確な件数が定義されている場合、コレクションのレスポンスには`meta.total`が含まれます。総件数は`limit`と`offset`を適用する前に計算されます。検索など、返すレコード数を意図的に制限するエンドポイントでは、`null`を返す代わりに`meta.total`を省略します。

<!-- translation-section: endpoint-summary -->

## エンドポイント一覧

| メソッド | エンドポイント | 用途 |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | APIキーのユーザーのグループ一覧を取得します |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | 閲覧可能なグループを取得します |
| `GET` | `/api/b2/reports` | 参加状況レポートを生成します |
| `GET` | `/api/b2/search` | 閲覧可能なディスカッション、コメント、アンケート、投票、結論を検索します |
| `POST` | `/api/b2/discussions` | ディスカッションを作成します |
| `GET` | `/api/b2/discussions/:id` | ディスカッションを取得します |
| `GET` | `/api/b2/discussions` | グループ内のディスカッション一覧を取得します |
| `PATCH` | `/api/b2/discussions/:id` | ディスカッションを編集します |
| `DELETE` | `/api/b2/discussions/:id` | ディスカッションを論理削除します |
| `GET` | `/api/b2/threads` | 閲覧可能なディスカッションのスレッドと単独のアンケートのスレッドの一覧を取得します |
| `GET` | `/api/b2/threads/:topic_id` | スレッドを取得します |
| `GET` | `/api/b2/threads/:topic_id/items` | スレッド内の項目を順序どおりに取得します |
| `GET` | `/api/b2/threads/:topic_id/markdown` | スレッド全体をMarkdown形式で取得します |
| `POST` | `/api/b2/comments` | コメントまたは返信を作成します |
| `PATCH` | `/api/b2/comments/:id` | コメントを編集します |
| `DELETE` | `/api/b2/comments/:id` | コメントを論理削除します |
| `POST` | `/api/b2/polls` | アンケートを作成します |
| `GET` | `/api/b2/polls/:id` | アンケートを取得します |
| `GET` | `/api/b2/polls` | グループ内のアンケート一覧を取得します |
| `PATCH` | `/api/b2/polls/:id` | アンケートを編集します |
| `DELETE` | `/api/b2/polls/:id` | アンケートを論理削除します |
| `GET` | `/api/b2/memberships` | グループのメンバー登録一覧を取得します |
| `POST` | `/api/b2/memberships` | メンバーを追加し、必要に応じて一覧に含まれないメンバーを削除します |
| `GET` | `/api/b2/chatbots` | グループのチャット連携とWebhookの一覧を取得します |
| `POST` | `/api/b2/chatbots` | チャット連携またはWebhookを作成します |
| `PATCH` | `/api/b2/chatbots/:id` | チャット連携またはWebhookを更新します |
| `DELETE` | `/api/b2/chatbots/:id` | チャット連携またはWebhookを削除します |
| `POST` | `/api/b2/chatbots/check` | Webhookの接続テストを送信します |

<!-- translation-section: groups -->

## グループ

<!-- translation-section: list-groups -->

### グループ一覧の取得

APIキーのユーザーが有効なメンバー登録を持つグループを返します。

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

レスポンスには、条件に一致するすべてのレコードが、ページ分割されていない `groups` 配列に含まれます。親グループとサブグループが含まれ、サブスクリプションが現在有効でないグループも含まれます。有効なグループのみを連携の対象にする場合は、`enabled` フィールドを確認してください。

主なグループのフィールドは次のとおりです。

| フィールド | 説明 |
| --- | --- |
| `id` | 他のユーザーAPIエンドポイントで使用する数値のグループID |
| `key` | LoomioのURLで使用する固定の短いキー |
| `handle` | 人が読みやすいグループのハンドル |
| `name` | グループ名 |
| `full_name` | 親グループの情報を含むグループ名 |
| `parent_id` | サブグループの場合は数値の親グループID、それ以外は `null` |
| `enabled` | グループとそのサブスクリプションが有効かどうか |
| `memberships_count` | 有効なメンバー登録と承認待ちのメンバー登録の数 |
| `accepted_memberships_count` | 承認済みのメンバー登録数 |
| `pending_memberships_count` | 承認待ちの招待数 |
| `admin_memberships_count` | グループ管理者数 |
| `delegates_count` | 代表者数 |
| `discussions_count` | グループに直接属するディスカッション数 |
| `polls_count` | グループに直接属するアンケート数 |
| `subgroups_count` | サブグループ数 |

レスポンスには、追加のグループ設定、関連する親グループのレコード、APIユーザーのメンバー登録が含まれる場合があります。クライアントでは、使用しないフィールドを無視してください。

<!-- translation-section: get-a-group -->

### グループの取得

APIキーのユーザーが閲覧できるグループを1件返します。

`GET /api/b2/groups/:id_or_key_or_handle`

識別子には、グループの数値ID、キー、ハンドルを使用できます。

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

レスポンスには `groups` 配列にグループが含まれ、一覧取得のエンドポイントと同じフィールドを使用します。APIキーのユーザーがアクセスできないグループを要求すると、権限エラーが返されます。

<!-- translation-section: webhooks -->

## Webhook

ユーザーAPIはリクエストに基づいて動作し、連携先がデータを読み取ったり変更したりする際にLoomioを呼び出します。グループのWebhookは、Loomioから連携先へのプッシュ通知を提供します。選択されたグループのイベントが発生すると、Loomioがエンドポイントに送信するため、連携先で変更を確認するためにREST APIを定期的に呼び出す必要はありません。

Webhookはグループごとに設定し、グループ管理者の権限が必要です。Loomioの画面から次の手順で管理できます。

1. グループを開きます。
2. グループメニューを開き、**チャット連携**を選択します。
3. エンドポイントが受け付けるペイロード形式に対応する連携を追加します。汎用のエンドポイントには、Mattermost/Markdown形式を使用してください。
4. 名前と送信先URLを入力します。
5. Loomioが自動送信するイベントを選択します。
6. 連携を保存し、**テスト接続**を使ってテストメッセージを送信します。

推測できないURLを持つHTTPSの送信先を使用してください。Loomioでは、送信先が公開アドレスに名前解決される必要があり、ローカルまたはプライベートネットワークのアドレスへのリクエストはブロックされます。

エージェントや他の連携は、以下に記載するBearer認証のchatbotエンドポイントを使ってWebhookを管理することもできます。このリソースはLoomioのチャット連携との互換性のために `chatbots` と呼ばれていますが、汎用の送信Webhookも表します。

<!-- translation-section: list-webhooks -->

### Webhook一覧の取得

グループに設定されているチャット連携を返します。APIキーのユーザーは、そのグループの管理者である必要があります。レスポンスには送信先URLが含まれるため、一般のグループメンバーに公開してはいけません。

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

レスポンスには、次のフィールドを持つ `chatbots` 配列が含まれます。

| フィールド | 説明 |
| --- | --- |
| `id` | 更新と削除に使用する連携ID |
| `group_id` | イベントを受信するグループ |
| `name` | 連携の管理用の名前 |
| `kind` | 送信Webhookの場合は `webhook`、Matrix連携の場合は `matrix` |
| `webhook_kind` | ペイロード形式：`markdown`、`slack`、`discord`、`microsoft`、`webex` |
| `server` | 送信先URL |
| `event_kinds` | 自動送信するイベント |
| `notification_only` | メッセージに通知の見出しのみを含めるかどうか |

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

APIキーのユーザーは、`group_id` で指定したグループの管理者である必要があります。保存する前に、送信先が公開URLであることが検証されます。

<!-- translation-section: update-a-webhook -->

### Webhookの更新

`PATCH /api/b2/chatbots/:id`

変更するフィールドを送信してください。`group_id` を変更してWebhookを別のグループに移すことはできません。

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Webhook送信先のテスト

設定の保存前または保存後に、Markdown対応のテストメッセージを送信先に送信します。

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Webhook を削除する

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

設定を削除すると、以後の送信は停止します。Loomio のグループ内のコンテンツは削除されません。

<!-- translation-section: event-types -->

### イベントの種類

Webhook では、次の種類のイベントを受信対象にできます。

| イベント | 送信されるタイミング |
| --- | --- |
| `new_discussion` | ディスカッションが開始されたとき |
| `discussion_edited` | ディスカッションが編集されたとき |
| `new_comment` | コメントが作成されたとき |
| `poll_created` | 投票が開始されたとき |
| `poll_edited` | 投票が編集されたとき |
| `poll_closing_soon` | 投票の締め切りが近づいたとき |
| `poll_expired` | 投票の締め切りに達したとき |
| `poll_closed_by_user` | ユーザーが投票を手動で締め切ったとき |
| `poll_reopened` | 投票が再開されたとき |
| `outcome_created` | 結論が公開されたとき |
| `outcome_updated` | 結論が更新されたとき |
| `outcome_review_due` | 結論の見直し期限になったとき |
| `stance_created` | 票が投じられたとき |
| `stance_updated` | 投票内容が変更されたとき |

Webhook は 1 つのグループに属し、そのグループで受信対象に設定したイベントを受け取ります。対応する自動送信イベントが選択されていなくても、一部の通知を共有または送信するときに連携を明示的に選択できます。

<!-- translation-section: http-delivery -->

### HTTP による送信

Loomio は、次のヘッダーを付けた非同期の HTTP `POST` を設定済みの URL に送信します。

```text
Content-Type: application/json; charset=utf-8
```

リクエストのタイムアウトは 5 秒です。`204 No Content` を含む `2xx` 応答は成功として扱われます。Webhook の受信側は速やかに応答し、時間のかかる処理は非同期で行ってください。重複した送信や順序の前後にも対応してください。

現在、Loomio は Webhook の署名、共有シークレットのヘッダー、イベント ID、送信 ID を付けません。送信先 URL 全体を認証情報として扱い、公開しないでください。受信サービスが対応している場合は、推測されにくいトークンを URL に含めてください。安定した機械可読のイベント形式や署名付きの送信が必要な場合は、Webhook を変更通知として使い、認証済みのユーザー API から最新のレコードを取得してください。

<!-- translation-section: payload-formats -->

### ペイロード形式

Webhook のペイロードは、チャットサービス向けの表示用メッセージです。Loomio のレコード全体をシリアライズしたものではありません。メッセージ内のリンクは、対象となる Loomio のコンテンツを示します。構造化された最新の状態が必要な場合は、ユーザー API で取得できます。

| 連携形式 | 主な JSON フィールド |
| --- | --- |
| Mattermost/Markdown | `text`、`icon_url`、`username` |
| Slack | `text` |
| Discord | `content`、約 1,900 文字まで |
| Microsoft Teams | `@type`、`@context`、`themeColor`、`text`、`sections` |
| Webex | `markdown` |

たとえば、一般的な Markdown 形式では、次のような本文を送信します。

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

メッセージの正確な文面は、イベント、グループの言語設定、通知のみの設定、Loomio のバージョンによって異なります。受信側では文章を解析せず、選択した形式で定義されている最上位のフィールドを使用してください。

<!-- translation-section: search -->

## 検索

API キーのユーザーに表示できるディスカッション、コメント、投票、票、結論を検索します。グループのメンバーでなくても、公開コンテンツは結果に含まれます。非公開コンテンツには、通常のトピックの閲覧権限が適用されます。

`GET /api/b2/search`

<!-- translation-section: params -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `query` | 検索文字列。完全一致とあいまい一致に対応します |
| `group_id` | 表示できる 1 つのグループに結果を限定します |
| `org_id` | 表示できる親グループと、その表示できるサブグループに結果を限定します。直接ディスカッションには `0` を使います |
| `type` | 結果を `Discussion`、`Comment`、`Poll`、`Stance`、`Outcome` のいずれか 1 種類に限定します |
| `types` | 結果の種類をカンマで区切ったリスト |
| `tag` | このタグが付いたトピックに結果を限定します |
| `author_id` | 1 人の投稿者によるコンテンツに結果を限定します。`query` がない場合は、その投稿者の最近の閲覧可能な活動を返します |
| `order` | `authored_at_desc` を指定すると、一致したコンテンツを投稿日時の降順に並べます |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

応答には `search_results` 配列が含まれます。各結果には、一致したレコードと閲覧可能な関連情報を示す `searchable_type`、`searchable_id`、`highlight`、`group_id`、`group_name`、`discussion_key`、`poll_key`、`author_id`、`author_name`、`authored_at`、`tags` などのフィールドがあります。結果に該当しないフィールドは `null` になります。

<!-- translation-section: participation-report -->

## 参加レポート

Loomio の参加レポートと同じ集計データを返します。

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `section` | レポートのセクション: `base`、`users`、`countries`。個人ごとの活動には `users` を使います |
| `group_scope` | `custom` または `my`。ユーザー API キーにインスタンス全体へのアクセス権はないため、従来の値 `all` は `my` として扱われます |
| `group_ids` | `group_scope=custom` の場合に指定する、カンマで区切ったグループ ID。API ユーザーがメンバーでないグループの ID は無視されます |
| `start_month` | 集計を開始する月。形式は `YYYY-MM`。既定値は 12 か月前です |
| `end_month` | 集計を終了する月。形式は `YYYY-MM`。既定値は当月です |
| `interval` | `base` セクションの集計間隔: `day`、`week`、`month`、`year` |
| `member_type` | `section=users` とともに `delegate` を指定すると、現在の代表者のみを返します |

選択したグループのいずれかで有効な代表者メンバーシップを持つ人が、代表者です。活動件数は、選択したすべてのグループを通じて集計されます。すべての活動件数がゼロでも、代表者の行は返されます。件数にはスレッド、コメント、投票、票、結論、リアクションが含まれますが、投票参加率ではありません。ユーザーの行には、記名投票で割り当てられた投票機会、投じられた票、投じられなかった票の数も含まれます。匿名投票は、個人ごとの投票件数からすべて除外されます。`all_votes_cast` が true になるのは、少なくとも 1 件の投票機会が割り当てられ、そのすべてで票が投じられた場合だけです。

この API には、Loomio 内のレポートと同じグループ閲覧ルールが適用されます。ユーザー API キーでは、そのユーザーがアクセスできないグループのレポートデータは取得できません。

<!-- translation-section: example -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

`users` 配列には、活動データの各項目を含む行が入ります。

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

<!-- translation-section: create-discussion -->

## ディスカッションを作成する

APIキーのユーザーとしてディスカッションを作成します。

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `group_id` | スレッドを作成するグループ |
| `title` | スレッドのタイトル。必須 |
| `description` | スレッドの背景情報。省略可能 |
| `description_format` | `md` または `html`。省略可能。既定値は `md` |
| `recipient_audience` | `group` または null。`group` の場合は、新しいスレッドについてグループ全体に通知します |
| `recipient_user_ids` | 通知する、またはスレッドに招待するユーザーのIDの配列 |
| `recipient_emails` | スレッドに招待する人のメールアドレスの配列 |
| `recipient_message` | 招待メールに含めるメッセージ |

<!-- translation-section: example-2 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## ディスカッションを取得する

整数のディスカッションID、または文字列のキーを指定して、ディスカッションを取得します。

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## ディスカッションの一覧を取得する

グループ内でAPIキーのユーザーに表示されるディスカッションの一覧を取得します。公開グループでは、メンバー以外も公開ディスカッションの一覧を取得できます。非公開ディスカッションは、Loomioで閲覧権限のあるユーザーにのみ表示されます。

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数。必須。ディスカッションの一覧を取得するグループのID |
| `status` | 文字列。省略可能。既定値は `open`。指定できる値: `open`、`closed`、`all` |
| `limit` | 整数。省略可能。既定値は50。1ページあたりの件数 |
| `offset` | 整数。省略可能。既定値は0。ページ分割の開始位置 |

従来の指定方法: `per` と `from` は、それぞれ `limit` と `offset` の別名として引き続き使用できます。

<!-- translation-section: example-4 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## スレッドの一覧を取得する

APIキーのユーザーに表示されるディスカッションと投票のスレッドを、最近のアクティビティ順に取得します。スレッドIDは `topic_id` です。

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `limit` | 整数。省略可能。既定値は50。1ページあたりの件数 |
| `offset` | 整数。省略可能。既定値は0。ページ分割の開始位置 |

<!-- translation-section: example-5 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## スレッドを読む

スレッド、時系列に並んだイベント、または表示可能な内容をまとめたMarkdown文書を取得します。

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### 例

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

`items` エンドポイントは、表示可能なコメント、投票、投票内容、結論を含むイベントを時系列順に返します。`markdown` エンドポイントは、表示可能なスレッド全体を1つのMarkdown文書として返します。投票理由は、APIキーのユーザーに表示される場合にのみ含まれます。

すべてのスレッドエンドポイントには、Loomioの画面と同じ権限が適用されます。APIキーを使っても、通常は開けないスレッドにはアクセスできません。

<!-- translation-section: edit-discussion -->

## ディスカッションを編集する

APIキーのユーザーとしてディスカッションを編集します。Loomioと同じ権限が適用され、そのディスカッションの編集権限が必要です。

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `title` | 更新後のタイトル |
| `description` | 更新後の背景情報 |
| `description_format` | `md` または `html`。省略可能。既定値は `md` |
| `recipient_audience` | `group` または null。`group` の場合は、編集についてグループ全体に通知します |
| `recipient_user_ids` | 通知する、またはスレッドに招待するユーザーのIDの配列 |
| `recipient_emails` | スレッドに招待する人のメールアドレスの配列 |
| `recipient_message` | 招待メールに含めるメッセージ |

<!-- translation-section: example-7 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## ディスカッションをソフト削除する

APIキーのユーザーとしてディスカッションをソフト削除します。ディスカッションは削除済みとして扱われますが、レコードは残ります。

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## コメントを作成する

APIキーのユーザーとしてディスカッションにコメントを作成します。

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `discussion_id` | 整数。必須。コメントを投稿するディスカッションのID |
| `body` | コメント本文。添付ファイルを指定しない場合は必須 |
| `body_format` | `md` または `html`。省略可能。既定値は `md` |

<!-- translation-section: example-9 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## コメントを編集する

APIキーのユーザーとしてコメントを編集します。Loomioと同じ権限が適用され、そのコメントの編集権限が必要です。

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `body` | 更新後のコメント本文 |
| `body_format` | `md` または `html`。省略可能。既定値は `md` |

<!-- translation-section: example-10 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## コメントをソフト削除する

APIキーのユーザーとしてコメントをソフト削除します。コメントは削除済みとして扱われ、本文は非表示になりますが、レコードは残ります。

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## 投票を作成する

API キーのユーザーとして投票を作成します。

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数。省略可能。既定値は null。投票を作成するグループの ID です。`discussion_id` を指定した場合、`group_id` は無視されます |
| `discussion_id` | 整数。省略可能。既定値は null。投票を追加するディスカッションのスレッド ID です |
| `title` | 文字列。必須。投票のタイトルです |
| `poll_type` | 文字列。必須。値は `proposal`、`poll`、`count`、`score`、`ranked_choice`、`meeting`、`dot_vote` です |
| `details` | 文字列。省略可能。投票の本文です |
| `details_format` | 文字列。省略可能。既定値は `md`。値は `md` または `html` です |
| `options` | 文字列の配列です。`poll_type` が `proposal` の場合、有効な値は `agree`、`disagree`、`abstain`、`block` です。`poll_type` が `meeting` の場合、ISO 8601 形式の日付または日時の文字列を指定します。その他の投票形式では任意の文字列を指定できます |
| `closing_at` | ISO 8601 形式の文字列または null。既定値は null。例: `2026-09-01T12:00:00Z`。null の場合、投票は無効になり、作成中として扱われます |
| `specified_voters_only` | 真偽値。省略可能。既定値は false。true の場合、指定された人だけが投票できます。false の場合、グループ全員に投票への招待が送られます |
| `hide_results` | 文字列。省略可能。既定値は `off`。値は `off`、`until_vote`、`until_closed` です |
| `shuffle_options` | 真偽値。既定値は false。選択肢を投票者ごとにランダムな順序で表示します |
| `anonymous` | 真偽値。省略可能。既定値は false。投票者の身元を隠します |
| `recipient_audience` | `group` または null。省略可能。既定値は null。`group` の場合、グループ全員に通知します |
| `notify_on_closing_soon` | 文字列。省略可能。既定値は `nobody`。値は `nobody`、`author`、`undecided_voters`、`voters` です |
| `recipient_user_ids` | 通知または招待するユーザー ID の配列です |
| `recipient_emails` | 投票に招待する人のメールアドレスの配列です |
| `recipient_message` | メールの招待状に含めるメッセージです |
| `notify_recipients` | 真偽値。既定値は false。false の場合、通知せずに人を追加します。true の場合、このリクエストで招待した全員に通知メールを送ります |

<!-- translation-section: example-12 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## 投票を取得する

整数の投票 ID または文字列のキーを使って投票を取得します。

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## 投票の一覧を取得する

グループ内で API キーのユーザーに表示できる投票を一覧表示します。公開グループでは、メンバー以外も公開投票を一覧表示できます。非公開の投票は、Loomio で閲覧権限があるユーザーに限られます。レスポンスには表示可能な各投票の現在の結論も含まれます。`status=closed` を使うと、決定済みの提案を一覧表示できます。

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数。必須。投票を一覧表示するグループの ID です |
| `status` | 文字列。省略可能。既定値は `active`。値は `active`、`closed`、`all` です |
| `limit` | 整数。省略可能。既定値は 50。1 ページあたりの件数です |
| `offset` | 整数。省略可能。既定値は 0。ページ送りの開始位置です |

従来の指定方法: `per` と `from` は、それぞれ `limit` と `offset` の別名として引き続き使用できます。

<!-- translation-section: example-14 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## 投票を編集する

API キーのユーザーとして投票を編集します。Loomio と同じ権限が適用され、その投票の編集権限が必要です。

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `title` | 更新後のタイトルです |
| `details` | 更新後の投票の詳細です |
| `details_format` | `md` または `html`。省略可能。既定値は `md` です |
| `options` | 更新後の選択肢名です。選択肢の変更は、投票の状態によって既存の票に影響する場合があります |
| `closing_at` | ISO 8601 形式の文字列または null です |
| `recipient_audience` | `group` または null。`group` の場合、グループ全員に通知します |
| `recipient_user_ids` | 通知または招待するユーザー ID の配列です |
| `recipient_emails` | 投票に招待する人のメールアドレスの配列です |
| `recipient_message` | メールの招待状に含めるメッセージです |

<!-- translation-section: example-15 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## 投票を論理削除する

API キーのユーザーとして投票を論理削除します。投票は破棄されますが、レコードは残ります。

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## メンバーシップの一覧を取得する

API キーのユーザーに表示できるメンバーシップを一覧表示します。グループのメンバーは、メンバーの名前、ID、肩書き、役割を閲覧できます。メールアドレスが含まれるのは、API キーのユーザー自身のアカウントか、そのユーザーがグループ管理者の場合だけです。

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数。必須。メンバーシップを一覧表示するグループの ID です |

<!-- translation-section: example-17 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## メンバーシップを管理する

メールアドレスの一覧を送信すると、新しいメールアドレスの人をグループに招待します。メンバーシップの一覧取得とは異なり、この操作にはグループ管理者の権限が必要です。

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### パラメータ

| 名前 | 説明 |
| --- | --- |
| `group_id` | 整数。必須。メンバーシップを管理するグループの ID です |
| `emails` | 文字列の配列。必須。グループに招待する人のメールアドレスです |
| `remove_absent` | 真偽値。true の場合、メールアドレスが一覧にない人をグループから削除します |

<!-- translation-section: example-18 -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

`remove_absent=1` を指定すると、一覧に含まれないグループのメンバーが削除されます。グループの全員が削除される可能性があるため、注意してください。

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

レスポンスは `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}` を含むオブジェクトです。
