---
title: チャット連携
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: 8663af0a2c7b70ae
  what-it-looks-like-in-chat: 8729d56458e6ba9d
  generate-a-webhook-url: 110c92ddd0e16e00
  set-up-a-chat-integration: 912e54873aed2e33
  invite-to-poll: 3c6a315c075af62a
  automatic-notifications: f93736de9cb59c9b
title_source: 0eca19d30c6d7d3c
title_generated: 603b48500dacd1b4
---

<!-- translation-section: introduction -->

# チャット連携

Loomioからチャットルームに通知を送信できます。

チャットツールとLoomioは併用できます。短いやり取りや最新情報の共有にはチャットを使います。参加する時間が必要な話題、決定が必要な話題、グループで記録を残したい話題はLoomioに移します。

LoomioはSlack、Discord、Microsoft Teams、Matrix、Mattermostに対応しています。

個別に投票やスレッドへの参加を招待するのと同じように、いつでもチャットルームに通知を送信できます。

スレッドの開始など、特定の出来事が起きたときに毎回通知するよう設定することもできます。

<!-- translation-section: what-it-looks-like-in-chat -->

## チャットでの表示例
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Webhook URLを取得する
対応する各サービスの設定手順を用意しています。利用するサービスの手順に従って、Loomioでチャット連携を追加する際に必要なWebhook URLを取得してください。

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

このWebhook方式は、HTMLまたはMarkdown形式の受信Webhookに対応するほかのサービスでも利用できます。たとえばZapierやRocketchatです。 その場合はMattermostボットを選び、カスタムWebhook URLを入力してください。

<!-- translation-section: set-up-a-chat-integration -->

## チャット連携を設定する

利用するサービスを設定すると（上記参照）、Webhook URLが取得できます。 グループメニューから**チャット連携**を開き、グループに新しいチャット連携を追加します。

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

最初はチェックボックスを選ばず、名前（「Discord #general」など）とURLを入力して、フォームの下部にある保存ボタンをクリックしてください。

![](loomio-chatbot-form.png)

後から自動通知を受け取る場合は、連携の設定に戻って対象のイベントを選択してください。

<!-- translation-section: invite-to-poll -->

### 投票に招待する

提案への投票を呼びかける通知をチャットルームに送信する方法です。 「結論を共有する」「スレッドに招待する」「投票を促す」「投票の編集」なども同じ手順です。

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### 自動通知
特定の出来事が起きるたびに通知するには、チャット連携を編集して、そのイベントを選択します。

![](chatbot_enable_automatic_notifications.png)
