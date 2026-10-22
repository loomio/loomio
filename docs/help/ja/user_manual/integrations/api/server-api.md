---
title: サーバー API
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 8b28f9c34e3f7575
  authentication: cbabcc874f053455
  user-object: 7e9e8ff3e48a4055
  list-users: c7d62eee05e7a6a4
  example: 2f817ab1533206e6
  show-user: 36fa596a6a5c2fd8
  examples: 522d17246020d82f
  update-user: 39d632ce15d489d3
  params: 368f797e2a2b5c3d
  examples-2: 3aab846e77253829
  deactivate-user: 132d435583a46920
  examples-3: d8c7c152ab2b0ace
  reactivate-user: 309592dead978456
  examples-4: 95251484d1fd7e1d
  redact-user: 47ea30122aa92fae
  examples-5: 9d3bb1c3a865f3e0
  delete-user: 2d5a1dbd23324e6f
  examples-6: 71ae30577730b261
  sso-profile-sync-settings: 416144004d040e4f
  provisioning: 590e1f295602247d
generated:
  introduction: 512cde618e1a759a
  authentication: 3d5959d1c6caae6d
  user-object: 20f0594f6c51a86f
  list-users: 5968d737b21206fb
  example: 8ca4a50914f75bea
  show-user: 4e832bae294cb5fe
  examples: 5d5fd2df61ffb744
  update-user: c93e3e9b28a34e48
  params: 52f8ef47c03db108
  examples-2: e968aa54e387bba8
  deactivate-user: 70c52ed33881ac16
  examples-3: cf59e5b94febf6b1
  reactivate-user: 2b483871ac808c26
  examples-4: 8d73c205d34410da
  redact-user: 5da8bf0cefced95f
  examples-5: 2720441e028231cb
  delete-user: 1ab6b263cf5fdddd
  examples-6: 5a2a8ccecacae5f1
  sso-profile-sync-settings: be27cb70115591ea
  provisioning: 15d7894427aa3c90
title_source: 370e81eb20eece44
title_generated: 6693a36a8fbd5ef0
---

<!-- translation-section: introduction -->

# Loomio サーバー API ドキュメント

<!-- seo-description: Loomio サーバー API を使用して、セルフホストの Loomio 環境でユーザーアカウントの作成、グループの検索、メンバーシップの管理ができます。 -->

`/api/b3` はサーバーレベルの操作に使用します。Loomio のユーザーアカウントとして行うユーザー向けの操作には、`/api/b2` を使用してください。

1つのサーバーキーで、アカウントの作成と管理、環境全体のグループの検索、メンバーシップと役割の管理ができます。ボットアカウント、ユーザー API キー、グループへの所属は必要ありません。ユーザー API キーには、引き続きそのユーザーのグループ権限が適用されます。

<!-- translation-section: authentication -->

## 認証

`B3_API_KEY` に、16 文字を超える秘密の文字列を設定してください。

キーを Bearer トークンとして送信します。

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

認証情報は `Authorization` ヘッダーでのみ送信してください。クエリ文字列やリクエスト本文に含まれる API キーは拒否されます。

<!-- translation-section: provisioning -->

## アカウントとメンバーシップの作成・管理

| メソッド | エンドポイント | 用途 |
| --- | --- | --- |
| `POST` | `/api/b3/users` | アカウントの作成 |
| `GET` | `/api/b3/groups` | 環境全体のグループの検索 |
| `GET` | `/api/b3/memberships` | グループのメンバーシップの一覧取得 |
| `POST` | `/api/b3/memberships` | メンバーの招待、またはメンバーシップ一覧全体の同期 |
| `PATCH` | `/api/b3/memberships/:id` | グループ管理者と代表者の役割の変更 |
| `DELETE` | `/api/b3/memberships/:id` | 1件のメンバーシップの取り消し |

既存のアカウントの更新、無効化、再有効化、個人情報の削除、アカウントの削除に使用するエンドポイントについては、後述します。

### アカウントの作成

`POST /api/b3/users`

必須の `email` を含む `user` オブジェクトを送信します。メールアドレスの前後の空白は削除され、小文字に変換されます。任意のフィールドは `name`、`username`、`is_admin` です。ここでの `is_admin` はインスタンス管理者を意味します。グループ管理者の役割はメンバーシップで管理します。`username` を省略すると、自動生成されます。未定義のフィールドは拒否されます。

```bash
curl https://loomio.example.org/api/b3/users \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "user": {
      "email": "ada@example.org",
      "name": "Ada Lovelace",
      "username": "ada",
      "is_admin": false
    }
  }'
```

レスポンスは HTTP `201` で、`user` オブジェクトを含みます。フィールドが無効な場合や、メールアドレスまたはユーザー名がすでに使用されている場合は、HTTP `422` を返します。アカウントを作成しても、招待の送信、ユーザーのログイン、メールアドレスの確認済みへの変更は行われません。通常の通知ワークフローで招待を送信するには、メンバーシップのエンドポイントを使用してグループに招待してください。

### グループの検索

`GET /api/b3/groups`

非公開グループやサブスクリプションの有効期限が切れたグループを含め、削除されていないすべてのグループを一覧表示します。結果は ID の昇順に並びます。`limit`（既定値と最大値は `50`）と `offset`（既定値は `0`）を使用して、ページごとに取得します。

```bash
curl 'https://loomio.example.org/api/b3/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "groups": [
    {
      "id": 123,
      "key": "examplegroup",
      "name": "Planning group",
      "handle": "planning",
      "parent_id": null,
      "group_privacy": "secret"
    }
  ],
  "meta": {
    "total": 1
  }
}
```

### メンバーシップの一覧取得

`GET /api/b3/memberships?group_id=123`

`group_id` は必須です。結果には承認済みのメンバーシップと承認待ちの招待が含まれ、メンバーシップ ID の昇順に並びます。取り消されたメンバーシップは含まれません。ページ分割には `limit`（既定値と最大値は `50`）と `offset`（既定値は `0`）を使用します。

```bash
curl 'https://loomio.example.org/api/b3/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "memberships": [
    {
      "id": 456,
      "group_id": 123,
      "user_id": 789,
      "user_email": "ada@example.org",
      "user_name": "Ada Lovelace",
      "admin": false,
      "delegate": false,
      "accepted_at": null,
      "pending": true
    }
  ],
  "meta": {
    "total": 1
  }
}
```

`admin` と `delegate` はグループ内の役割です。`accepted_at` は承認日時を表し、招待が承認待ちの場合は `null` です。このエンドポイントは、招待トークン、ログイン認証情報、投票を公開しません。

### メンバーの招待または同期

`POST /api/b3/memberships`

必須の `group_id` と `emails` 配列を送信します。既定では、一覧に含まれる人のうち、有効なメンバーシップをまだ持たない人を追加し、それ以外の人はそのまま残します。メールアドレスの前後の空白は削除され、小文字に変換され、重複が除かれます。新しいアドレスについては、アカウントと承認待ちの招待を作成します。同じ組織内の別の有効なグループにすでに所属し、メールアドレスが確認済みのメンバーは、ユーザー API の招待ワークフローと同様に、自動的に承認されます。

```bash
curl https://loomio.example.org/api/b3/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

メンバーシップ一覧全体を同期するには、`remove_absent` を明示的に `true` に設定します。一覧に含まれない人は、そのグループとサブグループから削除されます。空の配列を `remove_absent: true` とともに送信すると、グループ管理者を含む全員が削除されます。追加のみを行う場合は、`remove_absent` を省略するか `false` に設定してください。従来の値である `1` と `0` も使用できます。

```bash
curl https://loomio.example.org/api/b3/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org"
    ],
    "remove_absent": true
  }'
```

```json
{
  "added_emails": [],
  "removed_emails": [
    "alex@example.org"
  ]
}
```

同じリクエストを繰り返しても、メンバーシップが重複して作成されたり、招待が再送信されたりすることはありません。メンバーシップが取り消されたメンバーを再度招待すると、グループへのアクセスは復元されますが、以前の管理者の役割は復元されません。新しい招待と役割の変更には通常の通知ワークフローが使用され、操作したユーザーは記録されません。

メールアドレス一覧がない場合や形式が不正な場合、またはブール値が無効な場合は、HTTP `400` を返します。一覧に無効化されたアカウントが含まれている場合は、HTTP `422` を返します。追加する前に、明示的に再有効化してください。アカウントデータが無効な場合、サブスクリプションの上限に達した場合、その他のエラーが発生した場合は、新規アカウントの作成とメンバーシップの削除を含む同期全体がロールバックされます。追加には有効なグループが必要で、サブスクリプションのメンバー数の上限が適用されます。

### メンバーシップの役割の更新

`PATCH /api/b3/memberships/:id`

ブール値フィールド `admin` と `delegate` のいずれか、または両方を含む `membership` オブジェクトを送信します。省略した役割は変更されません。未定義のフィールドは拒否されます。このエンドポイントでは、メンバーシップの移譲、招待の承認、投票の重みの変更はできません。

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

一覧取得時のメンバーシップと同じフィールドを持つ `membership` オブジェクトを返します。役割を付与すると、通常の役割通知が作成されます。役割を変更せずに同じリクエストを繰り返しても、再度通知されません。役割の変更には有効なグループが必要です。取り消されたメンバーシップの場合は HTTP `404` を返します。

### 1件のメンバーシップの削除

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

`{"success": true}` を返します。削除すると、トピックへのアクセスと進行中のアンケートでの投票権を含め、そのグループとサブグループへのアクセスが取り消されます。アカウントの削除、無関係なグループの変更、スレッドへの直接のアクセス権の取り消しは行われません。削除を繰り返しても成功します。サブスクリプションの有効期限が切れたグループからもメンバーシップを削除できます。削除済みのグループの場合は HTTP `404` を返します。

<!-- translation-section: user-object -->

## ユーザーオブジェクト

ユーザーのレスポンスは次の形式です。

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
  "is_admin": false,
  "active": true,
  "deactivated_at": null,
  "identities": [
    {
      "id": 456,
      "identity_type": "oauth",
      "uid": "external-123",
      "email": "ada@example.org",
      "name": "Ada Lovelace"
    }
  ]
}
```

<!-- translation-section: list-users -->

## ユーザー一覧の取得

Loomio 環境のすべてのユーザーアカウントを一覧で取得します。

`GET /api/b3/users`

<!-- translation-section: example -->

### 使用例

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

次のレスポンスを返します。

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## ユーザーの取得

Loomio のユーザー ID または外部の識別情報でユーザーを検索します。

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### 使用例

Loomio のユーザー ID を使用する場合：

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

外部の識別情報を使用する場合：

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

次のレスポンスを返します。

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## ユーザーの更新

Loomio のユーザー ID または外部の識別情報で検索したユーザーのプロフィール項目を更新します。

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### パラメーター

| 項目 | 説明 |
| --- | --- |
| `name` | 表示名 |
| `username` | Loomio のユーザー名 |
| `email` | メールアドレス |

<!-- translation-section: examples-2 -->

### 使用例

Loomio のユーザー ID を使用する場合：

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

外部の識別情報を使用する場合：

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

更新後のユーザーを返します。

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## ユーザーの無効化

Loomio のユーザー ID または外部の識別情報で検索したユーザーアカウントを無効化します。

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### 使用例

Loomio のユーザー ID を使用する場合：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

外部の識別情報を使用する場合：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

次のレスポンスを返します。

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## ユーザーの再有効化

Loomio のユーザー ID または外部 ID でユーザーアカウントを検索し、無効化されているアカウントを再有効化します。

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### 例

Loomio のユーザー ID を使用する場合:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

外部 ID を使用する場合:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

レスポンス:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## ユーザーの個人情報の削除

個人情報の削除では、ユーザーがグループ内に投稿したコメントやその他のコンテンツは保持されますが、名前、自己紹介、プロフィール写真、メールアドレス、ログイン認証情報、外部 ID、有効なセッションなど、個人の特定につながる既知の情報は削除されます。

Loomio からユーザーを削除する際は、この方法を推奨します。

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### 例

Loomio のユーザー ID を使用する場合:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

外部 ID を使用する場合:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

レスポンス:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## ユーザーの削除

削除では、ユーザーと、そのユーザーが作成したレコードが削除されます。スレッドからコメントが削除され、アンケートから投票が削除されます。また、データベースの関連付けによって、そのユーザーが作成したグループ、ディスカッション、アンケート、その他のレコードも削除される場合があります。

この操作では多くのデータが失われます。代わりに個人情報の削除を行うことを強く推奨します。

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### 例

Loomio のユーザー ID を使用する場合:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

外部 ID を使用する場合:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

レスポンス:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## SSO プロフィール同期の設定

別のシステムで Loomio のプロフィール項目を管理する場合は、以下の設定を使用します。

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` を設定すると、ユーザー自身による以下の項目の編集を禁止します:

| 項目 | 備考 |
| --- | --- |
| `name` | 外部同期で管理します |
| `username` | 外部同期で管理します |
| `email` | 外部同期で管理します |
| `avatar_kind` / `uploaded_avatar` | 外部同期で管理します |

ユーザーは引き続き、`short_bio` や `location` などの Loomio 内で管理する項目を編集できます。

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` を設定すると、SSO ログインデータから `name` と `email` を更新します。これらの更新を外部同期スクリプトのみで行う場合は、コメントアウトしたままにするか、設定しないでください。

既存のインストール環境では、引き続き `LOOMIO_SSO_FORCE_USER_ATTRS` を使用できます。この設定は、ユーザーによる編集を禁止するとともに、SSO ログイン時に `name` と `email` を更新します。
