---
title: サーバー API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: ed9db2dec737b16b
  authentication: 39f6343c79a0711b
  user-object: 15a82288e941eebc
  list-users: 337a3ce2a9751cb7
  example: 03fc41ea50f85735
  show-user: d3c15907f342f436
  examples: 740094053406452d
  update-user: 586d9bca8af2f801
  params: 4df254fe05c69d4f
  examples-2: 0161ec36e49710eb
  deactivate-user: 2d90607108cde26b
  examples-3: 608d2019b2df1748
  reactivate-user: 3dd8d19bca3d01da
  examples-4: 42e800938fb55b29
  redact-user: 0a27346629a67d26
  examples-5: d6a77841dd2fc9b0
  delete-user: 82827fc930da9a40
  examples-6: 58c6e7add6479fe6
  sso-profile-sync-settings: 3a0abeb4d6d7748b
title_source: 370e81eb20eece44
title_generated: 6693a36a8fbd5ef0
---

<!-- translation-section: introduction -->

# Loomio サーバー API ドキュメント

<!-- seo-description: Loomio サーバー API を使用して、セルフホスト環境の Loomio のユーザーアカウントを管理できます。 -->

`/api/b3` はサーバーレベルの操作に使用します。Loomio のユーザーアカウントとして行う操作には `/api/b2` を使用してください。

<!-- translation-section: authentication -->

## 認証

`B3_API_KEY` に、16文字を超える秘密の文字列を設定してください。

キーを Bearer トークンとして送信してください。

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

認証情報は `Authorization` ヘッダーでのみ送信してください。クエリ文字列やリクエストボディに含まれる API キーは拒否されます。

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

この Loomio 環境のすべてのユーザーアカウントを一覧で取得します。

`GET /api/b3/users`

<!-- translation-section: example -->

### 例

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

Loomio のユーザー ID または外部システムの識別情報でユーザーを検索します。

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### 例

Loomio のユーザー ID を使用する場合：

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

外部システムの識別情報を使用する場合：

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

Loomio のユーザー ID または外部システムの識別情報で検索したユーザーのプロフィール項目を更新します。

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### パラメータ

| 項目 | 説明 |
| --- | --- |
| `name` | 表示名 |
| `username` | Loomio のユーザー名 |
| `email` | メールアドレス |

<!-- translation-section: examples-2 -->

### 例

Loomio のユーザー ID を使用する場合：

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

外部システムの識別情報を使用する場合：

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

更新したユーザーを返します。

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## ユーザーの無効化

Loomio のユーザー ID または外部システムの識別情報で検索したユーザーアカウントを無効化します。

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### 例

Loomio のユーザー ID を使用する場合：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

外部システムの識別情報を使用する場合：

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

Loomio のユーザー ID または外部 ID で特定した、無効化済みのユーザーアカウントを再有効化します。

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### 使用例

Loomio のユーザー ID を使用する場合：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

外部 ID を使用する場合：

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

個人情報の削除では、ユーザーのコメントやその他の投稿コンテンツを所属グループ内に残し、名前、自己紹介、プロフィール写真、メールアドレス、ログイン認証情報、認証 ID、有効なセッションなど、個人の特定につながる既知の情報を削除します。

Loomio からユーザーを削除する際は、この方法を推奨します。

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### 使用例

Loomio のユーザー ID を使用する場合：

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

外部 ID を使用する場合：

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

削除では、ユーザーとそのユーザーが作成したレコードを削除します。スレッドからコメントが削除され、アンケートから投票が削除されます。また、データベースの関連付けにより、そのユーザーが作成したグループ、ディスカッション、アンケート、その他のレコードも削除される場合があります。

この操作では多くのデータが失われます。代わりに個人情報の削除を強く推奨します。

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### 使用例

Loomio のユーザー ID を使用する場合：

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

外部 ID を使用する場合：

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

## SSO プロフィール同期設定

別のシステムで Loomio のプロフィール項目を管理する場合は、これらの設定を使用します。

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` を設定すると、ユーザーは次の項目を自分で編集できなくなります。

| 項目 | 備考 |
| --- | --- |
| `name` | 外部同期で管理します |
| `username` | 外部同期で管理します |
| `email` | 外部同期で管理します |
| `avatar_kind` / `uploaded_avatar` | 外部同期で管理します |

`short_bio` や `location` など、Loomio 内で管理する項目は引き続き編集できます。

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` を設定すると、SSO のログインデータから `name` と `email` を更新します。これらの更新を外部同期スクリプトだけで行う場合は、コメントアウトしたままにするか、設定しないでください。

`LOOMIO_SSO_FORCE_USER_ATTRS` は既存のインストール環境でも引き続き機能します。ユーザーによる編集を無効にし、SSO ログイン時に `name` と `email` を更新します。
