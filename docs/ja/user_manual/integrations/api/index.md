---
title: API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 4c4d39f3e42f47ec
  user-api: 1866ba126c119145
  server-api: 9a8c213bd721738d
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

Loomio APIを使用すると、Loomioを他のソフトウェアや自動化されたワークフローと連携できます。

[OpenAPI 3.1仕様](openapi.yaml)には、公開されているユーザーAPIとサーバーAPIのすべての操作が、機械で読み取れる形式で記述されています。APIクライアントにインポートしたり、型情報を持つクライアントコードの生成に使用したりできます。以下のガイドでは、この仕様だけでは十分に表現されていないワークフロー、権限、動作を説明します。

<!-- translation-section: user-api -->

## ユーザーAPI

[ユーザーAPI](/en/user_manual/integrations/api/user-api)は、Loomioユーザーとして操作を実行します。そのユーザーの権限に応じて、グループの一覧を取得したり、スレッド、コメント、アンケート、グループのメンバーシップを作成・管理したりできます。

プッシュ型の連携では、[グループのWebhook](/en/user_manual/integrations/api/user-api#webhooks)が、選択されたLoomioのイベントをJSON形式でWebエンドポイントに送信します。Loomioのデータを読み取ったり変更したりするにはRESTエンドポイントを使用し、ポーリングせずにイベントを受信する連携にはWebhookを使用します。

<!-- translation-section: server-api -->

## サーバーAPI

[サーバーAPI](/en/user_manual/integrations/api/server-api)を使用すると、セルフホスト版Loomioの運用担当者がユーザーアカウントを管理できます。認証にはサーバー全体で共通のシークレットを使用します。
