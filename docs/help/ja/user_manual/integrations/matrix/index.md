---
title: Matrix
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 114ab8c916ca5fba
generated:
  introduction: e7e7c1d36deade49
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix連携

Loomioでは、新しいディスカッション、アンケート、コメント、投票、結論が投稿されると、Matrixのルームに通知を送信できます。チャット連携を追加するには、グループ管理者である必要があります。

他のLoomioのチャット連携とは異なり、Matrix連携ではWebhookを使用しません。Loomioは、ボットとして動作するMatrixユーザーアカウントを通じて接続し、書式付きのメッセージをルームに投稿します。

このガイドではElementクライアントを使用します。

---

1. Loomio用のMatrixユーザーアカウントを作成し、Elementでそのアカウントにサインインして、通知を表示するMatrixのルームに招待します。このセッションはサインインしたままにしておきます。サインアウトするとアクセストークンが無効になります。

2. Loomioのグループでグループメニューを開き、**チャット連携**を選択して、**マトリックス**のチャット連携を追加します。

   ![LoomioのMatrixボットメニュー](loomio-add-matrix-bot.png)

   ![LoomioのMatrixボット設定フォーム](loomio-matrix-bot-form.png)

3. Elementでボットのアカウントメニューを開き、**すべての設定**を選択します。

   ![Matrixの設定メニュー](matrix-settings-menu.png)

4. **ヘルプとバージョン情報**を開き、**詳細設定**セクションまでスクロールします。

   ![Matrixの設定](matrix-settings.png)

5. **アクセストークン**をコピーし、Loomioのフォームに貼り付けます。

   ![Matrixのアクセストークン](matrix-access-token.png)

6. ルームの**設定**メニューを開き、**詳細設定**に移動します。

   ![Matrixのルーム設定](matrix-room-settings.png)

7. **内部ルームID**をコピーし、Loomioのフォームに貼り付けて、連携を保存します。

   ![MatrixのルームID](matrix-room-id.png)
