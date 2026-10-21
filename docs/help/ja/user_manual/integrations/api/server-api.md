---
title: サーバー API
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
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
  introduction: e4068667c6bae0ee
  authentication: 3d5959d1c6caae6d
  user-object: 15a82288e941eebc
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
title_source: 370e81eb20eece44
title_generated: 6693a36a8fbd5ef0
---

<!-- translation-section: introduction -->

# Loomio サーバー API ドキュメント

<!-- seo-description: Loomio サーバー API を使用して、セルフホストの Loomio 環境でユーザーアカウントを管理できます。 -->

`/api/b3` はサーバーレベルの操作に使用します。Loomio のユーザーアカウントとして行うユーザー向けの操作には、`/api/b2` を使用してください。

<!-- translation-section: authentication -->

## 認証

`B3_API_KEY` に、16 文字を超える秘密の文字列を設定してください。

キーを Bearer トークンとして送信します。

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

認証情報は `Authorization` ヘッダーでのみ送信してください。クエリ文字列やリクエスト本文に含まれる API キーは拒否されます。

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
