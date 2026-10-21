---
title: Matrix
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 9b923eadb01d1eff
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix連携

Loomioでは、新しいディスカッション、提案、コメント、投票、結論が投稿されると、Matrixのチャンネルに通知を送信できます。

Matrixではチャットルーム内で一部のHTMLを使用でき、Loomioもこの機能を活用しています。

Matrix連携は、他のチャット連携とは少し異なります。Webhookは使用せず、この連携専用に開発したボットクライアントを使用します。

ボットがログインするためのMatrixユーザーを作成する必要があります。

ボット用のユーザーを作成したら、そのユーザーでログインして、以下の情報を取得します。

このガイドではElementを使用します。

---

Loomioのグループから、Matrixチャット連携を追加します
![LoomioのMatrixボットメニュー](loomio-add-matrix-bot.png)

以下のフォームに必要な情報を入力します
![LoomioのMatrixボット設定フォーム](loomio-matrix-bot-form.png)

アクセストークンを確認するには、まず設定メニューを開きます
![Matrixの設定メニュー](matrix-settings-menu.png)

以下が設定ページです
![Matrixの設定](matrix-settings.png)

以下がアクセストークンです
![Matrixのアクセストークン](matrix-access-token.png)

次に、ルームIDを確認します
![Matrixのルーム設定](matrix-room-settings.png)

以下の場所に表示されています。
![MatrixのルームID](matrix-room-id.png)
