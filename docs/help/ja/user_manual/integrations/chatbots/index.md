---
title: チャット連携
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: 2689a3400a6785c9
  what-it-looks-like-in-chat: 8729d56458e6ba9d
  generate-a-webhook-url: 9cff1c648827e6bd
  set-up-a-chat-integration: 4daf3652d2d58632
  invite-to-poll: 644291e7e8554176
  automatic-notifications: 4e6499f3c7260c5f
title_source: 0eca19d30c6d7d3c
title_generated: 603b48500dacd1b4
---

<!-- translation-section: introduction -->

# チャット連携

Loomioからチャットルームに通知を送信できます。

チャットツールとLoomioは組み合わせて使えます。短いやり取りやタイムリーな情報共有にはチャットを使います。参加するための時間が必要な場合、決定を行う必要がある場合、グループで記録を長く残す必要がある場合は、重要な話題をLoomioに移します。

LoomioはSlack、Discord、Microsoft Teams、Matrix、Mattermostに対応しています。

個々の人を投票やスレッドへの参加に招待するのと同じ方法で、必要なときにチャットルームに通知を送信できます。

スレッドの開始など、特定のイベントが発生するたびに通知を送信するように設定することもできます。

<!-- translation-section: what-it-looks-like-in-chat -->

## チャットでの表示例
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Webhook URLを生成する
対応している各サービスの設定手順を用意しています。利用するサービスの手順に従い、Loomioにチャット連携を追加するために必要なWebhook URLを取得してください。

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Webhookを使うこの仕組みは、HTMLまたはMarkdown形式の受信Webhookに対応するほかのシステムでも利用できます。例えば、ZapierやRocketchatなどです。Mattermostボットを選択し、独自のWebhook URLを指定してください。

<!-- translation-section: set-up-a-chat-integration -->

## チャット連携を設定する

利用するサービスを設定すると（上記参照）、Webhook URLを取得できます。グループメニューから**チャット連携**を開き、グループに新しいチャット連携を追加してください。

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

この段階では、チェックボックスを選択する必要はありません。名前（「Discord #general」など）とURLを入力し、フォームの下部にある保存ボタンをクリックしてください。

![](loomio-chatbot-form.png)

後から自動通知を受け取るようにしたい場合は、連携の設定に戻り、該当するイベントを選択してください。

<!-- translation-section: invite-to-poll -->

### アンケートに招待する

提案への投票を呼びかける通知をチャットルームに送信する手順です。結論の共有、スレッドへの招待、投票のリマインダー、アンケートの編集なども同じ手順で通知できます。

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### 自動通知
特定のイベントが発生するたびに通知を送信するには、チャット連携を編集し、そのイベントを選択してください。

![](chatbot_enable_automatic_notifications.png)
