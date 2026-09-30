---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: '09f7af150f5c1c1d'
  user-api: a9196f5e454caf71
  server-api: 570f40f05a8c325c
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

Loomio APIを使うと、Loomioをほかのソフトウェアや自動化されたワークフローと連携できます。

[OpenAPI 3.1仕様](openapi.yaml)には、公開されているUser APIとServer APIのすべての操作が、機械で読み取れる形式で記載されています。APIクライアントに読み込むか、型付きのクライアントコードの生成に利用できます。以下のガイドでは、仕様だけでは十分に説明できないワークフロー、権限、動作を解説します。

<!-- translation-section: user-api -->

## User API

[User API](/en/user_manual/integrations/api/user-api)は、Loomioユーザーとして操作を実行します。そのユーザーの権限に応じて、グループの一覧表示や、スレッド、コメント、投票、グループのメンバーシップの作成・管理ができます。

イベントを受け取る連携には、[グループのWebhook](/en/user_manual/integrations/api/user-api#webhooks)を使えます。選択したLoomioのイベントが、JSON形式でWebエンドポイントに送信されます。Loomioのデータの読み取りや変更にはRESTエンドポイントを使い、定期的に問い合わせずにイベントを受け取るにはWebhookを使います。

<!-- translation-section: server-api -->

## Server API

[Server API](/en/user_manual/integrations/api/server-api)を使うと、自分でホストするLoomioの運用者がユーザーアカウントを管理できます。認証にはサーバー全体で使用するシークレットを使います。
