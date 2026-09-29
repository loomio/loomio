---
title: Matrix
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: '048815d7af84fd02'
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix連携

新しいディスカッション、提案、コメント、投票、結論があると、LoomioからMatrixのチャンネルに通知を送れます。

Matrixのチャットルームでは一部のHTMLを使えます。Loomioもこの機能を利用しています。

Matrix連携には、ほかのチャット連携と異なり、Webhookを使いません。専用のボットクライアントを使います。

ボットがログインするためのMatrixユーザーを作成します。

ボット用のユーザーを作成したら、そのユーザーでログインし、次の情報を確認します。

このガイドではElementを使用します。

---

LoomioのグループからMatrixチャット連携を追加します
![LoomioのMatrixボットメニュー](loomio-add-matrix-bot.png)

次のフォームに入力します
![LoomioのMatrixボット設定フォーム](loomio-matrix-bot-form.png)

アクセストークンを確認するには、ここから始めます
![Matrixの設定メニュー](matrix-settings-menu.png)

設定ページを開きます
![Matrixの設定](matrix-settings.png)

アクセストークンはここに表示されます
![Matrixのアクセストークン](matrix-access-token.png)

次にルームIDを確認します
![Matrixのルーム設定](matrix-room-settings.png)

ルームIDはここに表示されます
![MatrixのルームID](matrix-room-id.png)
