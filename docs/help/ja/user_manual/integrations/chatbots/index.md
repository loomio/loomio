---
title: チャット連携
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: 5a727120f9967d49
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: 6c617201d66f192b
  what-it-looks-like-in-chat: ecd3e57dcc39f4fe
  generate-a-webhook-url: ec36889a83521485
  set-up-a-chat-integration: 3ce2905d961dda88
  invite-to-poll: '048790c3d1aecfa3'
  automatic-notifications: 9ef065038a27431d
title_source: 0eca19d30c6d7d3c
title_generated: 603b48500dacd1b4
---

<!-- translation-section: introduction -->

# チャット連携

Loomioからチャットルームに通知を送信できます。

チャットツールとLoomioは組み合わせて使えます。短いやり取りやタイムリーな情報共有にはチャットを使います。参加するための時間が必要な場合、決定を行う必要がある場合、グループで記録を長く残す必要がある場合は、重要な話題をLoomioに移します。

LoomioはSlack、Discord、Microsoft Teams、Matrix、Mattermostに対応しています。

スレッドやアンケートに参加者を招待する際に、チャットルームへ手動で通知を送信できます。また、ディスカッションの開始など、特定のイベントが発生したときに通知を自動送信するように設定することもできます。

<!-- translation-section: what-it-looks-like-in-chat -->

## チャットでの表示例

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## チャットサービスを接続する

利用するチャットサービスのガイドに従い、Webhook URL（Matrixの場合はボットのアクセストークンとルームID）を取得します。

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

ZapierやRocket.Chatなど、HTMLまたはMarkdown形式の受信Webhookに対応するほかのサービスも接続できます。Loomioで**最重要**のチャット連携を選択し、独自のWebhook URLを入力します。

<!-- translation-section: set-up-a-chat-integration -->

## チャット連携を設定する

チャット連携を追加または編集するには、グループ管理者である必要があります。

1. チャットサービスを設定した後（上記参照）、Loomioのグループページで**設定**を開き、**チャット連携**を選択します。

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. 利用するサービスのチャット連携を新しく追加し、名前（「Discord #general」など）を入力して、Webhook URLを貼り付けます。

   ![](loomio-chatbot-form.png)

3. 自動通知を送信したいイベントを選択して保存します。手動でのみ通知を送信する場合は、イベントを選択せずに保存します。この設定はいつでも変更できます。

<!-- translation-section: invite-to-poll -->

### 手動で通知を送信する

アンケートやディスカッションについてチャットルームに通知するには、該当する項目を開き、**招待する**（または**結論を共有する**、**投票をリマインドする**、**アンケートの編集**などの通知操作）を選択します。送信先の一覧からチャット連携を選択し、通知を送信します。

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### 自動通知

特定のイベントが発生するたびに通知を送信するには、チャット連携を編集し、そのイベントを選択します。

![](chatbot_enable_automatic_notifications.png)
