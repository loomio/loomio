---
title: サーバー API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: a357cdc2bfc0223e
  authentication: cbabcc874f053455
  user-object: c3a00ec4e3d66b09
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
generated:
  introduction: 971a2689970d5cd2
  authentication: 1dafd8586775e199
  user-object: 15a82288e941eebc
  list-users: 45cbe23a282830e3
  example: 0725252badee05a3
  show-user: 41028a87ef8b98a8
  examples: 0e7ec0786d4fe260
  update-user: 2836b3f592733df5
  params: 52f8ef47c03db108
  examples-2: 9144a41b6996cd1f
  deactivate-user: d6789294716725c9
  examples-3: 7aaa17fb1439bbbb
  reactivate-user: 2fc6d5d6df2738c0
  examples-4: 639ce3f91920efca
  redact-user: 31095e22aa44605a
  examples-5: 0ce8cfb8e0d47c98
  delete-user: c971e46732c7a02c
  examples-6: b64f3e85436a5c21
  sso-profile-sync-settings: 2ca5c8ccb87c7b22
title_source: 370e81eb20eece44
title_generated: 6693a36a8fbd5ef0
---

<!-- translation-section: introduction -->

# Loomio サーバー API ドキュメント

<!-- seo-description: セルフホストの Loomio 環境でユーザーアカウントを管理するには、Loomio サーバー API を使用します。 -->

`/api/b3` はサーバー単位の操作に使用します。Loomio のユーザーアカウントとして行う操作には `/api/b2` を使用します。

<!-- translation-section: authentication -->

## 認証

`B3_API_KEY` に 16 文字を超える秘密の値を設定します。

キーをベアラートークンとして送信します。

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

認証情報は `Authorization` ヘッダーでのみ送信します。クエリ文字列やリクエスト本文に含めた API キーは拒否されます。

<!-- translation-section: user-object -->

## ユーザーオブジェクト

ユーザーのレスポンスは次の形式です。

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
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

## ユーザー一覧

Loomio 環境のすべてのユーザーアカウントを一覧表示します。

`GET /api/b3/users`

<!-- translation-section: example -->

### 例

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

戻り値：

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## ユーザーの取得

Loomio のユーザー ID または外部 ID でユーザーを検索します。

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### 例

Loomio のユーザー ID で検索：

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

外部 ID で検索：

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

戻り値：

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## ユーザーの更新

Loomio のユーザー ID または外部 ID で指定したユーザーのプロフィール項目を更新します。

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

### 例

Loomio のユーザー ID で検索：

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

外部 ID で検索：

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

更新後のユーザーが返されます。

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## ユーザーの無効化

Loomio のユーザー ID または外部 ID で指定したユーザーアカウントを無効化します。

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### 例

Loomio のユーザー ID で検索：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

外部 ID で検索：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

戻り値：

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## ユーザーの再有効化

Loomio のユーザー ID または外部 ID で指定した無効化済みのユーザーアカウントを再有効化します。

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### 例

Loomio のユーザー ID で検索：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

外部 ID で検索：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

戻り値：

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## ユーザーの個人情報の削除

個人情報を削除しても、ユーザーのコメントなどの投稿内容は所属グループ内に残ります。一方、名前、自己紹介、プロフィール写真、メールアドレス、ログイン認証情報、外部 ID、有効なセッションなど、既知の個人を特定できる情報は削除されます。

Loomio からユーザーを削除する場合は、この方法を推奨します。

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### 例

Loomio のユーザー ID で検索：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

外部 ID で検索：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

戻り値：

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## ユーザーの削除

削除すると、ユーザーとそのユーザーが作成した記録が削除されます。コメントはスレッドから、投票は世論調査から削除されます。ユーザーが作成したグループ、ディスカッション、世論調査などの記録も、データベース上の関連付けによって削除される場合があります。

削除すると多くのデータが失われます。代わりに個人情報の消去を強く推奨します。

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### 例

Loomio のユーザー ID で検索：

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

外部 ID で検索：

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

戻り値：

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## SSOプロフィール同期の設定

別のシステムでLoomioのプロフィール項目を管理する場合は、これらの設定を使用します。

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` を設定すると、ユーザーは次の項目を自分で編集できなくなります。

| 項目 | 備考 |
| --- | --- |
| `name` | 外部同期で管理 |
| `username` | 外部同期で管理 |
| `email` | 外部同期で管理 |
| `avatar_kind` / `uploaded_avatar` | 外部同期で管理 |

`short_bio` や `location` など、Loomio内で管理する項目は引き続き編集できます。

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` を設定すると、SSOログイン時のデータで `name` と `email` が更新されます。外部同期スクリプトだけでこれらの項目を更新する場合は、この設定をコメントアウトするか、設定しないでください。

`LOOMIO_SSO_FORCE_USER_ATTRS` は既存の環境でも引き続き使用できます。この設定はユーザーによる編集を無効にし、SSOログイン時に `name` と `email` を更新します。
